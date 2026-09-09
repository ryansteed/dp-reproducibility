import pandas as pd
from warnings import simplefilter
simplefilter(action="ignore", category=pd.errors.PerformanceWarning)
import numpy as np
import numpy.typing as npt
from decimal import Decimal
from typing import Dict, Tuple

from diffprivlib.mechanisms import Laplace
import opendp.prelude as opendp
from opendp.mod import Metric, Measure
opendp.enable_features("contrib", "floating-point")
from simulate_privacy.config import logger


class Mechanism:
    @staticmethod
    def from_treatment(treatment: dict, **kwargs) -> list:
        """Factory for noise addition mechanisms from treatment parameters.

        Args:
            treatment (dict): Treatment parameters.

        Returns:
            list: List of Mechanisms.
        """
        mechanisms = []

        # only look at treatments relevant to mechanism selection
        treatment = {k: v for k, v in treatment.items() if k != "imputations"}
            
        # measurement error
        if treatment.get("cscale") is not None:
            # scaled coefficients of variation
            cscale = treatment.get("cscale")
            if cscale == "est":
                mechanisms.append(ErrorScaledEst(
                    a=treatment.get("a"),
                    b=treatment.get("b"),
                    shrink=treatment.get("shrink"),
                    **kwargs
                ))
            elif cscale == "static":
                mechanisms.append(Error(
                    a=treatment.get("a"),
                    shrink=treatment.get("shrink"),
                    **kwargs
                ))
            elif cscale is not None:
                raise ValueError(f"Unknown cscale value {cscale}")
            
        # privacy treatments (should come after error)
        if treatment.get("epsilon") is not None:
            if treatment.get("mechanism") == "laplace":
                mechanisms.append(Laplace(
                    epsilon=treatment.get("epsilon"),
                    **kwargs
                ))
            elif treatment.get("mechanism") == "gaussian":
                mechanisms.append(Gaussian(
                    epsilon=treatment.get("epsilon"),
                    # delta=1e-25,
                    **kwargs
                ))
            else:
                raise ValueError(f"Unknown mechanism: {treatment.get('mechanism')}")

        elif treatment == {}:
            return [Control(**kwargs)]
        
        if len(mechanisms) == 0:
            raise ValueError(f"Unknown treatment: {treatment}")
        
        seen_mech_privacy = False
        for mech in mechanisms:
            this_mech_privacy = isinstance(mech, DP)
            assert not (seen_mech_privacy and isinstance(mech, Error)), "Error mechanism following privacy mechanism."
            seen_mech_privacy = seen_mech_privacy or this_mech_privacy
        
        return mechanisms
    
    @staticmethod
    def adds_noise(treatment: dict) -> bool:
        """
        Args:
            treatment (dict): Treatment parameters.

        Returns:
            bool: True if the treatment adds noise to the data.
        """
        return treatment != {} and list(treatment.keys()) != ["imputations"]
    
    def __init__(self, sensitivity_matrix: dict) -> None:
        self.sensitivity_matrix = sensitivity_matrix
        if len(sensitivity_matrix) == 0:
            logger.warning("No variables provided to noise. Will not add noise.")
        
    @staticmethod
    def clean(x, settings):
        """Clip noised statistic if lb or ub provided. (Usually for weights that must be non-zero.)

        Args:
            x (_type_): _description_
            settings (_type_): _description_

        Returns:
            _type_: _description_
        """
        x = Mechanism._apply_bounds(
            x,
            lb=settings.get("lb"),
            ub=settings.get("ub")
        )
        if settings.get("integer"):
            x = np.round(x).astype(int)
        return x
    
    @staticmethod
    def _apply_bounds(x, lb=None, ub=None):
        if not (lb is None and ub is None):
            # NOTE: in some cases we must clip noise to provided bounds
            # (usually, requiring positive values for weights)
            x = np.clip(x, lb, ub)
        return x
    
    def _get_settings(self, var):
        settings = self.sensitivity_matrix.get(var)
        if type(settings) is not dict: # handle old formatting
                settings = {"sensitivity": settings}
        return settings

    def noise(self, data: Dict[str, pd.DataFrame]) -> dict:
        """Apply noise to the datasets.

        Args:
            data (Dict[str, pd.DataFrame]): Original datasets.

        Returns:
            dict: Noised datasets.
        """
        noised = {}
        for name, df in data.items():
            logger.debug(f"[{name}] Adding noise to {len(df)} rows...")
            noised[name] = self._noise_dataset(df)
        return noised
    
    def _noise_dataset(self, df: pd.DataFrame) -> pd.DataFrame:
        """Apply noise to a dataset.

        Args:
            df (pd.DataFrame): Dataset to noise

        Returns:
            pd.DataFrame: Noised dataset.
        """
        raise NotImplementedError
    
    @staticmethod
    def validate_noise(df_original, df_treated, vars_to_check=[], throw=True):
        """Check to make sure noise was added to datasets.

        Args:
            df_original (_type_): Original dataset.
            df_treated (_type_): Noised dataset.
            vars_to_check (list, optional): Variables to check for noise. Defaults to [].
            throw (bool, optional): Whether to raise an error if noise is not found. Defaults to True.

        Returns:
            _type_: Amount of noise added per column.
        """
        noise, _ = Mechanism.error(df_original, df_treated)
        not_noised = []
        for k in vars_to_check:
            if k not in noise.columns:
                raise KeyError(f"Variable {k} of type {df_original[k].dtype} not found in noise object. Not numeric?")
            # check to make sure noise was actually added to the variables
            if df_treated[k].isin([np.inf, -np.inf]).sum() > 0:
                raise ValueError(f"inf or -inf in treated {k}. Divide by zero error?")
            if noise[k].abs().sum() <= 0:
                not_noised.append(k)
                msg = f"Zero noise for {k}: {noise[k]}. `_noise` failed?"
                if throw:
                    logger.error(msg)
                else:
                    logger.warning(msg)
        if throw:
            assert len(not_noised) == 0, f"Variables {not_noised} were not noised."
        elif len(not_noised) > 0:
            logger.warning(f"Variables {not_noised} got no noise.")
        return noise
    
    @staticmethod
    def error(df_original: pd.DataFrame, df_treated: pd.DataFrame) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """Compute error (noise) applied to variables.

        Args:
            df_original (pd.DataFrame): Original dataframe.
            df_treated (pd.DataFrame): Noised dataframe.

        Returns:
            tuple: A tuple containing the error and the original dataframe (only numeric columns).
        """
        numerics = ['int8', 'int16', 'int32', 'int64', 'float16', 'float32', 'float64', 'bool']
        error = df_treated.select_dtypes(include=numerics) \
            - df_original.select_dtypes(include=numerics)
        return error, df_original.select_dtypes(include=numerics)


class Control(Mechanism):
    """Control mechanism --- no noise added.
    """
    def _noise_dataset(self, df):
        return df


class AdditiveNoise(Mechanism):
    """Mechanism involving noise addition.
    """
    def _noise_dataset(self, df: pd.DataFrame) -> pd.DataFrame:
        df_noised = df.copy()
        for var in [
            v for v in self.sensitivity_matrix.keys()
            if v in df_noised.columns
        ]:
            logger.debug(f"> {var}")
            settings = self._get_settings(var)
            # convert to float for noise addition (might be int)
            df_noised[var] = df_noised[var].astype(float)
            # only noise non-NA values
            nas = df_noised[var].isna()
            if settings.get("sensitivity") is not None:
                noised = self._noise_var(df_noised.loc[~nas, var], var)
            else:
                noised = df_noised.loc[~nas, var]
            # add noise to non-NA entries in place
            df_noised.loc[~nas, var] = Mechanism.clean(noised, settings)
        logger.debug("... done.")
        return df_noised.drop(columns=[c for c in df_noised.columns if c.endswith("_sens")])
    
    def _noise_var(self, x: npt.ArrayLike, var: str) -> npt.ArrayLike:
        raise NotImplementedError


class DP(AdditiveNoise):
    """Differentially private mechanism.
    """
    def __init__(self, epsilon: float, year_cutoff: int = 1950, **kwargs) -> None:
        super().__init__(**kwargs)
        if epsilon is None:
            raise ValueError("Epsilon must not be None.")
        self.epsilon = epsilon
        self.year_cutoff = year_cutoff
        self.computed_sensitivities = {}
        # number of variables to be noised based on sensitivity matrix and dataset columns
        self._n_vars_to_noise = None
    
    def noise(self, data: dict) -> dict:
        # before noising, count variables that will be noised
        self._n_vars_to_noise = 0
        for df in data.values():
            self._n_vars_to_noise += len([v for v in self.sensitivity_matrix.keys() if v in df.columns])
        noised_data = super().noise(data)
        return noised_data
    
    def _validate_budget(self, current_budget: float, expected_budget: float, input_metric: Metric, output_measure: Measure):
        """Validate that the total privacy budget used matches the expected budget under sequential composition.

        Args:
            current_budget (float): Current total budget used (computed from the mechanisms).
            expected_budget (float): Expected total budget (from the treatment).
            input_metric (Metric): Input metric for the composition.
            output_measure (Measure): Output measure for the composition.
        """
        assert np.isclose(current_budget, expected_budget), \
            f"Total budget used {current_budget} != requested {expected_budget}"
        # check again using OpenDP, to make sure we did the composition right
        max_sensitivity = max(self.computed_sensitivities.values())
        comp = opendp.c.make_sequential_composition(
            input_domain=opendp.vector_domain(opendp.atom_domain(T=float)),
            input_metric=input_metric,
            output_measure=output_measure,
            d_in=max_sensitivity,
            d_mids=[expected_budget / len(self.computed_sensitivities) for s in self.computed_sensitivities],
        )
        assert np.isclose(comp.map(max_sensitivity), expected_budget), \
            f"Sequential composition does not match expected budget: {comp.map(1)} != {expected_budget}"
    
    def _noise_dataset(self, df):
        return super()._noise_dataset(df)
    
    def compute_sensitivity(self, var, values):
        settings = self._get_settings(var)
        sensitivity_func = settings["sensitivity"]
        sensitivity = values.apply(sensitivity_func).astype(float).values
        if (sensitivity < 0).sum() > 0:
            raise ValueError(f"Negative sensitivity.")
        if np.all(sensitivity == sensitivity[0]):
            # sensitivity is the same for all cells (should always be the case)
            sensitivity = sensitivity[0]
            last_sensitivity = self.computed_sensitivities.get(var)
            if last_sensitivity is not None:
                assert sensitivity == self.computed_sensitivities[var], \
                    f"Sensitivity for {var} is not the same for all datasets; {sensitivity} != {last_sensitivity}."
            self.computed_sensitivities[var] = sensitivity
            return sensitivity
        else:
            raise NotImplementedError("Sensitivity is not the same for all cells.")

    def _noise_var(self, x: npt.ArrayLike, var: str) -> npt.ArrayLike:
        """Noise a variable in the dataset.

        Args:
            x (npt.ArrayLike): Data variable to noise.
            var (str): Variable name.

        Returns:
            npt.ArrayLike: Noised variable.
        """
        # get sensitivity for the query (should be the same for all cells)
        sensitivity = self.compute_sensitivity(var, x)
        logger.debug(f"{var} sensitivity: {sensitivity}")
        
        # sensitivity is expressed WRT the cells (not the entire vector)
        # with parallel composition (treating cells as disjoint),
        # applying epsilon_per_query DP mech to each row => epsilon_per_query budget for the whole column
        # each cell contains data from a specific region x time, e.g. data from people in county A in year XXXX
        # so this means the unit of privacy is individual x row, e.g. individual x time x period
        # get mechanism with sensitivity of x
        mech = self._mech(sensitivity)
        
        noised = np.where(
            np.isnan(x),
            np.nan, # keep NaNs in x
            mech(x.fillna(0).astype(float).to_list())
        )
        # alternatively, with DiffPrivLib (tested, gives same results)
        # mech = Laplace(
        #     epsilon=epsilon,
        #     sensitivity=sensitivity
        # )
        # noised_dpl = np.where(
        #     np.isnan(values),
        #     np.nan, # keep NaNs
        #     values.apply(mech.randomise)
        # )
        return noised
    
    def _mech(self, sensitivity: float):
        """Return the DP mechanism to use.

        Args:
            sensitivity (float): Sensitivity of the query.
        """
        raise NotImplementedError


class Laplace(DP):
    def noise(self, data):
        # keep track of total epsilon used (sequential composition) for validation
        self._mechs = []
        self._epsilon_budget = 0
        data_noised = super().noise(data)
        self._validate_budget(
            current_budget=self._epsilon_budget,
            expected_budget=self.epsilon,
            input_metric=opendp.l1_distance(T=float),
            output_measure=opendp.max_divergence()
        )
        return data_noised
    
    def _mech(self, sensitivity: float):
        # add noise to each var with sequential composition
        # assuming that each individual can contribute to every var
        # so for a global budget epsilon, each var gets epsilon / n_vars
        epsilon_per_query = self.epsilon / self._n_vars_to_noise
        input_space = (
            opendp.vector_domain(opendp.atom_domain(T=float)),
            opendp.l1_distance(T=float)
        )
        # instantiate laplace mechanism
        mech = input_space >> opendp.m.then_laplace(
            scale=sensitivity/epsilon_per_query
        )
        # check that computed epsilon matches expected epsilon
        epsilon_computed = mech.map(d_in=sensitivity)
        if not np.isclose(epsilon_per_query, epsilon_computed):
            raise ValueError(
                f"Computed epsilon does not match provided epsilon: {epsilon_computed} != {epsilon_per_query}"
            )
        self._epsilon_budget += epsilon_computed
        self._mechs.append(mech)
        return mech


class Gaussian(DP):
    def noise(self, data):
        self._mechs = []
        # convert epsilon bound to rho for zCDP
        rho = self._get_rho(self.epsilon)
        logger.info("Converting eps={} to rho={}".format(self.epsilon, rho))
        # keep track of total rho used for later validation
        self._rho_budget = 0
        data_noised = super().noise(data)
        self._validate_budget(
            current_budget=self._rho_budget,
            expected_budget=rho,
            input_metric=opendp.l2_distance(T=float),
            output_measure=opendp.zero_concentrated_divergence()
        )
        return data_noised

    
    def _mech(self, sensitivity):
        # add noise to each var with sequential composition
        rho_per_query = self._get_rho(self.epsilon) / self._n_vars_to_noise
        input_space = (
            opendp.vector_domain(opendp.atom_domain(T=float)),
            opendp.l2_distance(T=float) # equiv to L1 for 1-d function
        )
        mech = input_space >> opendp.m.then_gaussian(
            # scale = 2 * sensitivity ** 2 * np.log(1.25 / delta_per_query) / (epsilon_per_query ** 2)
            scale = sensitivity / np.sqrt(2 * rho_per_query)
        )
        # check that computed rho matches expected rho
        rho_computed = mech.map(sensitivity)
        assert np.isclose(rho_per_query, rho_computed), \
            f"Computed epsilon does not match provided epsilon: {rho_computed} != {rho_per_query}"
        self._rho_budget += rho_computed
        self._mechs.append(mech)
        return mech
    
    @staticmethod
    def _get_rho(epsilon: float):
        """Convert epsilon to rho for zCDP using the conversion formula from Steinke (2024): https://differentialprivacy.org/pdp-to-zcdp/."""
        exp_epsilon = np.exp(Decimal(epsilon))
        return float(Decimal(epsilon) * (exp_epsilon - 1) / (exp_epsilon + 1))
        # deprecated bound:
        # https://arxiv.org/pdf/1605.02065#subsection.3.1
        # return epsilon ** 2 / 2


class Error(AdditiveNoise):
    """Mechanism for adding noise to simulate measurement error (not privacy)."""
    def __init__(
            self, 
            a: float,
            shrink: str = None,
            **kwargs
        ) -> None:
        """
        Args:
            a (float): Coefficient of variation (CV).
            shrink (str, optional): Shrinkage construction ("hudson-berger" or "morris-lysy"). If None, no shrinkage is applied. Defaults to None.
        """
        self.a = a
        self.shrink = shrink
        if self.a < 0:
            raise ValueError("Param `a` must be non-negative.")
        super().__init__(**kwargs)
    
    def _noise_var(self, x: npt.ArrayLike, var: str) -> npt.ArrayLike:
        x = x.astype('float64')

        # should have no NAs or Infs
        assert np.isfinite(x).all() & ~np.isnan(x).any(), f"Inf or NA in x: {x}"

        # can't use coefficient of variation with zero values, so impute smallest non-zero value for variance calculation
        zeros = (x == 0)
        smallest_magnitude = np.min(np.abs(x[~zeros]))
        if zeros.sum() > 0:
            logger.warning(f"{zeros.sum()}/{len(zeros)} zeros found; imputing smallest non-zero value {smallest_magnitude} for variance calc.")
        x_imputed = np.maximum(np.abs(x), smallest_magnitude)
        
        # draw from x <- x + N(0, (c_ix_i)^2)
        c = self._c(x_imputed)
        assert np.isnan(c).sum() == 0, f"NaN in c: {c}"
        assert np.isfinite(c).all(), f"Inf in c: {c}"
        v = (x_imputed * c) ** 2
        assert np.isfinite(v).all(), f"Inf in variance: {v}"
        mu, variance = self._shrink(x, v)
        assert np.isfinite(variance).all(), f"Inf in variance: {variance}"
        assert np.isfinite(mu).all(), f"Inf in mean: {mu}"
        assert x.shape == variance.shape

        noise = np.random.normal(0, np.sqrt(variance)) # scale is standard deviation
        assert np.isfinite(noise).all(), f"Inf in noise: {noise}"
        return mu + noise
    
    def _shrink(
        self,
        x: npt.ArrayLike, 
        v: npt.ArrayLike,
        rescale: bool = False
    ) -> Tuple[npt.ArrayLike]:
        """Apply shrinkage to mean and variance.

        Args:
            x (npt.ArrayLike): Mean.
            v (npt.ArrayLike): Variance.
            rescale (bool, optional): Whether to rescale the data before shrinkage. Defaults to False.

        Returns:
            Tuple[npt.ArrayLike]: (shrinkage mean, shrinkage variance)
        """
        shrink = self.shrink
        # expecting 1-dimensional arrays
        x = np.array(x)
        v = np.array(v)
        assert x.ndim == 1
        assert v.ndim == 1
        assert (v > 0).all(), f"Variance must be positive: {v[v <= 0]}"
        k = len(x)
        if (v[0] == v).all():
            logger.warning(f"Variance is the same for all cells, cannot shrink.")
            shrink = None
        if shrink is None:
            # by default, just return x, v
            b = np.zeros(k)
            beta = 0
        # see https://www.science.org/doi/10.1126/science.adf9724
        # see also https://github.com/khoffm4/dp-policy-shrink/blob/master/dp_policy/titlei/mechanisms.py
        # and https://github.com/khoffm4/dp-policy-shrink/blob/master/notebooks/JS_Compairson_summary_results.Rmd
        elif shrink == "hudson-berger":
            # use hudson-berger construction
            # B_hat_i = ((k-2)/V)/(np.sum((count / V)**2))
            # mean_HB = (1-B_hat_i_HB)*count + B_hat_i_HB*beta_hat_0
            # sd_HB =  sqrt(V*(1-B_hat_i_HB))
            beta = 0
            # beta = np.sum(x / v) / (np.sum(1 / v))
            b = np.minimum(
                1,
                ((k - 2) / v) / (np.sum(x / v) ** 2)
            )
        elif shrink == "morris-lysy":
            # https://arxiv.org/pdf/1203.5610

            # count = count/(pop_total+1)
            # V = V/((pop_total+1)**2)
            # beta_hat_0 = np.sum(count / V)  /(np.sum(1/V))            
            # sigma_sq_hat = 1/(k-r) * np.sum((count - beta_hat_0)**2 /V )
            # B_hat_H =   (k-r-2)/(k-4) * 1/sigma_sq_hat
            # V_H = k/(np.sum(1/V))
            # A_hat = V_H * (1-B_hat_H) /B_hat_H
            # B_hat_i = (V / (V+ A_hat))
            # mean_ML = (1- B_hat_i_H_prop)*Prop + B_hat_i_H_prop*beta_hat_0_prop
            # sd_ML = sqrt(V_Prop*(1-B_hat_i_H_prop))
            r = 1

            if rescale:
                # rescale v such that sum(1/v) = 2k
                # equiv to rescaling 1/v <- 1/v * k / sum(1/v)
                rescale_factor = np.sqrt(k / np.sum(1 / v))
                # rescale_factor = np.max(x) - np.min(x)
                x = x / rescale_factor
                v = v / (rescale_factor ** 2)

            beta = np.sum(x / v) / (np.sum(1 / v))

            sigma_sq_hat = 1 / (k - r) * np.sum((x - beta) ** 2 / v) # MSE in population
            assert sigma_sq_hat > 0, f"Sigma_sq_hat must be positive: {sigma_sq_hat}"
            b_h = np.minimum(
                (k - r - 2) / (k - r) * 1 / sigma_sq_hat,
                1
            )
            assert b_h >= 0, f"B_h must be positive: {b_h}"
            v_h = k / (np.sum(1 / v))
            assert (v_h > 0).all(), f"v_h must be positive: {v_h}"
            a_hat = v_h * (1 - b_h) / b_h
            assert (v + a_hat > 0).all(), f"V + A_hat must be positive: {v[v + a_hat <= 0]} + {a_hat}"
            b = np.minimum(1, v / (v + a_hat))
        else:
            raise ValueError(f"Unrecognized shrinkage method {shrink}.")
    
        if shrink is not None:
            logger.debug("Shrinking with beta={}, B: {}".format(beta, pd.Series(b).describe()))
            # logger.debug("Alternative beta={}".format(np.sum(x / v) / (np.sum(1 / v))))

        oob = (b < 0) | (b > 1)
        assert not oob.any(), f"Shrinkage parameter b out of bounds, must be in [0, 1]: {b[oob]}"
        mu = (1 - b) * x + b * beta
        variance = (1 - b) * v

        if rescale and shrink == "morris-lysy":
            # rescale back to original scale
            mu = mu * np.sqrt(rescale_factor)
            variance = variance * rescale_factor
        
        return mu, variance
    
    def _c(self, x: npt.ArrayLike) -> npt.ArrayLike:
        return self.a
    

class ErrorScaledEst(Error):
    """Experimental: Data error simulation with exponential scaling.
    """
    def __init__(self, a: float, b: float = 0.5, **kwargs) -> None:
        """
        Args:
            a (float): Coefficient of variation (CV).
            b (float, optional): Exponent to modify coefficient of variation such that v = (a / x ^ b) * x, where x is the original mean. Defaults to 0.5.

        Raises:
            ValueError: _description_
        """
        super().__init__(a, **kwargs)
        self.b = b
        if self.b is None:
            self.b = 0.5
            logger.info(f"Setting `b' to default value {self.b}")
        if self.b > 1:
            raise ValueError("Param `b` must be less than or equal to 1.")
    
    def _c(self, x: npt.ArrayLike) -> npt.ArrayLike:
        return self.a / (x ** self.b)
