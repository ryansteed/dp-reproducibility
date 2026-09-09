import numpy as np
import itertools
import pickle
import os
from joblib import Parallel, delayed
from tqdm import tqdm
import traceback
import shutil
from copy import deepcopy
from collections import defaultdict
from decimal import Decimal
from scipy.stats import t as t_dist

from simulate_privacy.config import LogManager, load_config
from simulate_privacy.analysis import ExperimentsDB, ResultsDB, NoiseDB, SensitivityDB
from simulate_privacy.mechanisms import Gaussian
from simulate_privacy.studies import Study, ReplicationError
from simulate_privacy.mechanisms import Mechanism, Control

from loguru import logger


class ExperimentHandler:
    def __init__(
        self,
        id: str,
        study_id: str,
        **treatment_kwargs
    ):
        """Handle experiment configs and kick-offs.

        Args:
            id (str): Experiment ID.
            study_id (str): Study ID to run, "all" to run all studies in config, or "rlf" to run last failed experiments.
        """
        self.id = id
        LogManager.add_summary_logger(self.id)
        self.make_treatments(**treatment_kwargs)
        self.make_experiments(study_id, **treatment_kwargs)
        logger.bind(summary=True).info(
            f"--- Experiment {self.id}: {study_id}, {len(self.experiments)} exps ---\n"
            f"treatments: {self.treatments}"
        )
        self.register_experiments()
    
    def make_treatments(
        self,
        epsilons: list[float] = [],
        epsilon_log: float = None,
        mechanisms: list[float] = ["laplace"],
        cscales: list[str] = ["static"],
        aparams: list[float] = [],
        bparams: list[float] = [],
        shrinks: list[str] = [None],
        imputations: list[int] = [],
        no_control: bool = False
    ):
        """Enumerate the treatments to be tested in this experiment.

        Args:
            epsilons (list[float], optional): Epsilon values to test. Defaults to [].
            epsilon_log (float, optional): Base for logarithmic spacing of epsilon values. Defaults to None.
            mechanisms (list[float], optional): Mechanisms to test. Defaults to ["laplace"].
            cscales (list[str], optional): C-scale types to test ("est" or "static"). Defaults to ["static"].
            aparams (list[float], optional): A parameters to test (the coefficient of variation). Defaults to [].
            bparams (list[float], optional): B parameters to test (the exponent on the variance). Defaults to [].
            shrinks (list[str], optional): Shrinkage constructions to test ("hudson-berger" or "morris-lysy"). Defaults to [None].
            imputations (list[int], optional): Imputation values to test. Defaults to [].
            no_control (bool, optional): Whether to include a control treatment. Defaults to False.

        Raises:
            ValueError: If the input parameters are invalid.
        """
        treatments = []
        ## Privacy noise
        treatments_privacy = []
        if epsilon_log is not None:
            if epsilon_log <= 0:
                raise ValueError("epsilon_log must be a positive integer number of points.")
            epsilons += list(np.logspace(-5, 3, num=int(epsilon_log)))
        if len(epsilons) > 0:
            treatments_privacy = [
                dict(epsilon=eps, mechanism=m)
                for eps, m in itertools.product(epsilons, mechanisms)
            ]
        print(treatments_privacy)
        ## Data error
        if len(aparams) > 0:
            for cscale in cscales:
                if cscale == "est":
                    treatments += [
                        dict(cscale=cscale, a=a, b=b, shrink=shrink)
                        for a, b, shrink in itertools.product(aparams, bparams, shrinks)
                    ]
                    if len(treatments_privacy) > 0:
                        treatments += [
                            dict(cscale=cscale, a=a, b=b, shrink=shrink, **t)
                            for a, b, shrink, t in itertools.product(aparams, bparams, shrinks, treatments_privacy)
                        ]
                elif cscale == "static":
                    # needs only a, shrink
                    if len(treatments_privacy) > 0:  # privacy on the margin of error
                        treatments += [
                            dict(cscale=cscale, a=a, shrink=shrink, **t)
                            for a, shrink, t in itertools.product(aparams, shrinks, treatments_privacy)
                        ]
                    else:  # error alone, no privacy treatments given
                        treatments += [
                            dict(cscale=cscale, a=a, shrink=shrink)
                            for a, shrink in itertools.product(aparams, shrinks)
                        ]
        else:
            treatments = treatments_privacy
        if not no_control:
            treatments.append({})  # Add None to replicate w/ original data
        ## Overimputation
        if len(imputations) > 0:
            treatments += [
                dict(imputations=i, **t)
                for i, t in itertools.product(
                    imputations, 
                    treatments if len(treatments) > 0 else [{}] # must have something to combine
                )
            ]
        if len(treatments) == 0:
            raise ValueError("No treatments provided, nothing to run.")
        self.treatments = treatments
    
    def make_experiments(self, study_id: str, **treatment_kwargs):
        """Generate experiments from treatments to be tested and studies to be reproduced.

        Args:
            study_id (str): Study ID to test.

        Raises:
            ValueError: If the input parameters are invalid.
        """
        if study_id == "rlf":
            failed_last = pickle.load(open(self._failed_cache_path(), "rb"))
            logger.bind(summary=True).info(f"Running last failed experiments only: {failed_last}")
            assert len(failed_last) > 0, "No failed experiments found."
            experiments = failed_last
            logger.debug(experiments)
            assert len(experiments) <= len(failed_last), "Failed experiments not a subset of all experiments."
        else:
            studies_to_run = load_config().get("studies", []) if study_id == "all" else [study_id]
            if len(treatment_kwargs.get("imputations")) > 0:
                logger.warning("Imputations only supported for studies with one dataset.")
                logger.warning("Imputations only supported when all reg vars in input dataset.")
                studies_to_run = [
                    s for s in studies_to_run
                    if len(Study.from_id(s).data_paths()) == 1
                ]
                studies_not_to_run = load_config().get("imputation-exclude", [])
                def supported_study(study_id):
                    study = Study.from_id(study_id)
                    first_df_cols = lambda st: list(st.load_data().values())[0].columns.values
                    if study_id in studies_not_to_run:
                        logger.debug(f"Skipping {study_id} — excluded from imputation by config.")
                        return False
                    if len(study.data_paths()) > 1:
                        logger.debug(f"Skipping {study_id} — multiple datasets.")
                        return False
                    if not (vars := set(study.get_all_vars_to_noise())).issubset(
                        df_cols := set(first_df_cols(study))
                    ):
                        logger.debug(f"Skipping {study_id} — vars to noise not all in data.")
                        return False
                    return True
                studies_to_run = [
                    s for s in studies_to_run
                    if supported_study(s)
                ]
                logger.debug("Supported studies for imputation: {}".format(studies_to_run))
            if len(studies_to_run) == 0:
                raise ValueError("No studies to run.")
            
            experiments = list(itertools.product(studies_to_run, self.treatments))

        self.experiments = experiments
        
    def _failed_cache_path(self):
        failed_path_dir = os.path.join(LogManager.log_dir, "failed")
        if not os.path.exists(failed_path_dir):
            os.makedirs(failed_path_dir)
        return os.path.join(failed_path_dir, f"{self.id}.pkl")
    
    def register_experiments(self):
        """Record experiments in this run.
        """
        # REGISTER EXPERIMENT, CLEAR RESULTS
        experiments_db = ExperimentsDB(name=self.id, transform=True)
        self.results_db = ResultsDB(name=self.id, transform=True) # initialize results DB
        NoiseDB(name=self.id, transform=True) # initialize noise DB
        SensitivityDB(name=self.id, transform=True) # initialize noise DB
        self.results_db.vacuum()
        # add/update experiment to database
        experiment_records = [
            dict(
                study_id=sid,
                experiment_id=self.id,
                rho=Gaussian._get_rho(treatment.get("epsilon")) if treatment.get("epsilon") is not None else None, # eps-DP implies rho-DP
                **{f"{k}_str": str(treatment.get(k)) for k in treatment.keys()}
            )
            for sid, treatment in self.experiments
        ]
        # update experiment record
        experiments_db.upsert_all(experiment_records)
    
    def run(self, num_runs: int, **run_kwargs):
        """Run the experiments in parallel and report results.

        Args:
            num_runs (int): Number of trials (simulated replications) per treatment x reproduced study.
        """
        sim_ids = list(range(num_runs))
        jobs = list(itertools.product(
            [(sid, t) for sid, t in self.experiments if t != {}], sim_ids
        )) + [
            ((sid, t), 1) for sid, t in self.experiments if t == {}
        ]
        jobs = [e + (simid,) for e, simid in jobs]

        # GENERATE NEW RESULTS
        results = Parallel(n_jobs=30)(
            delayed(RunHandler._handle_run)(
                self.id,
                study_id,
                sim_id,
                treatment=t,
                **run_kwargs
            )
            for study_id, t, sim_id in tqdm(jobs, desc='study')
        )

        failed = [(study_id, t) for (study_id, t, sim_id), res in zip(jobs, results) if res is None]
        if len(failed) > 0:
            pickle.dump(failed, open(self._failed_cache_path(), "wb"))
            logger.debug(f"Dumped failures to {self._failed_cache_path()}")
        # REPORT
        reports = [
            ExperimentHandler._study_status_message(res, study_id, t, sim_id)
            for (study_id, t, sim_id), res in zip(jobs, results)
        ]
        logger.bind(summary=True).info(
            "Finished replicating studies:\n"+"\n".join(reports)
        )

        self.results_db.vacuum()
    
    @staticmethod
    def _study_status_message(output, study_id, treatment, sim_id):
        return f'{"✅" if output is not None else "❌"} {study_id} ({treatment}, sim={sim_id})'


class RunHandler:
    @staticmethod
    def _handle_run(*args, **kwargs):
        try:
            results = RunHandler._run_study(*args, **kwargs)
        except Exception as e:
            logger.bind(summary=True).error(f"{e}")
            logger.error(traceback.format_exc())
            results = None
        return results
    
    @staticmethod
    def _run_study(
        *runner_args, **run_kwargs
    ):
        runner = RunHandler(*runner_args)
        return runner.run(**run_kwargs)
    
    def __init__(
        self,
        experiment_id: str,
        study_id: str,
        sim_id: int
    ):
        self.experiment_id = experiment_id
        self.study_id = study_id
        self.sim_id = sim_id
        
        # re-set up logger to avoid multiprocessing issues
        LogManager.setup_logger()
        LogManager.add_summary_logger(self.experiment_id)

        # the `from_id` method automatically chooses subclasses 
        # by matching on its `id` variable
        self.study = Study.from_id(self.study_id)
        logger.debug(f"Created {type(self.study)} study with ID {self.study.id}: {self.study}")
    
    def run(
        self,
        treatment: dict = {},
        from_cache: bool = False,
        save_to_cache: bool = False,
        keep_debug_folder: bool = False   
    ):
        """Run a single treatment x study replication.

        Args:
            treatment (dict, optional): Treatment parameters. Defaults to {}.
            from_cache (bool, optional): Whether to load treatment data from cache. Defaults to False.
            save_to_cache (bool, optional): Whether to save treatment data to cache. Defaults to False.
            keep_debug_folder (bool, optional): Whether to keep the debug folder. Defaults to False.

        Returns:
            _type_: List of returned results.
        """
        treatment_str = "_".join([f"{k}={v}" for k, v in treatment.items()])
        logger.info(f"# study {self.study_id}, sim={self.sim_id}, {treatment_str}")

        ## load original data
        data = self.study.load_data()
        logger.debug(f"{len(data)} dataset(s) loaded, number of rows: {[len(df) for df in data.values()]}")
        
        ## load treated data
        save_id = f"{treatment_str}_sim={self.sim_id}"
        if from_cache:
            try:
                noised_data, paths_treatment = self.study.load_treatment(save_id)
                logger.info(f"Loading treatment data from cache {paths_treatment}")
            except FileNotFoundError:
                logger.warning("No cached data found, treating data from scratch.")
                from_cache = False
        if not from_cache:
            paths_treatment = self.study.data_paths()
            noised_data = self.treat_data(data, treatment)
        if save_to_cache:
            self.study.save_treatment(noised_data, save_id) # save the noised data
        
        logger.debug(f"Replicating with new data: {paths_treatment}")
        
        ## spawn a replication handler
        replicator = ReplicationHandler.from_treatment(
            treatment, self.study
        )
        # if imputing from control {}, can't use error
        use_error = (treatment.get("imputations", -1) > 0 and Mechanism.adds_noise(treatment))
        replicator.spawn_treatment(noised_data, data if use_error else None)

        ## replicate
        try:
            replicator.replicate()
            # if noise was added, check to make sure all final variables were noised,
            # including those that are constructed during replication
            if Mechanism.adds_noise(treatment):
                logger.debug("Validating noise after replication...")
                replicator.validate_against_original(
                    data,
                    throw=(treatment.get("epsilon") is not None and treatment.get("epsilon") < 100) # just give a warning for epsilon > 100
                )
            results = replicator.save_results(save_id)
            logger.info(f"Replication {self.study_id} ({treatment}) completed: {results}")
            replicator.cleanup()
        except ReplicationError as e:
            if keep_debug_folder:
                logger.error(f"Keeping temporary directory at {self.study.path()}_debug for debugging")
                # copy study.path() to a new directory recursively
                shutil.copytree(self.study.path(), f"{self.study.path()}_debug")
            replicator.cleanup()
            raise e
        except Exception as e:
            replicator.cleanup()
            raise e

        if treatment == {}:
            # check to make sure results match the original paper
            replicator.validate_expected_results(results)
        
        ## record result in SQLite database
        records = [dict(
            res.to_dict(),
            **{f"{k}_str": str(treatment.get(k)) for k in treatment.keys()}
        ) for res in results]
        self._record(records, dict(
            study_id=self.study.id,
            experiment_id=self.experiment_id,
            sim_id=self.sim_id
        ), ResultsDB)

        logger.bind(summary=True).info(ExperimentHandler._study_status_message(results, self.study_id, treatment, self.sim_id))
        return results
    
    def treat_data(self, data: dict, treatment: dict):
        """Apply treatments to data before replication.

        Args:
            data (dict): Datasets to be used in the replication.
            treatment (dict): Treatment parameters to apply to the data.

        Returns:
            dict: Treated (noised) data.
        """
        # load noise mechanism based on treatment params
        mechs = Mechanism.from_treatment(
            treatment,
            sensitivity_matrix=self.study.sensitivity_matrix()
        )
        # apply noise to the data
        noised_data, preprocessed_data = self.study.noise(data, mechanisms=mechs)
        if Mechanism.adds_noise(treatment):
            # if noise was added, check to make sure final variables were noised
            self._validate_treatment(
                preprocessed_data, noised_data,
                throw=(treatment.get("epsilon") is not None and treatment.get("epsilon") < 100)
            )
            # and record the noise and sensitivities used
            self._record_treatment(
                data, noised_data, preprocessed_data, treatment,
                computed_sensitivities=(
                    mechs[-1].computed_sensitivities
                    if treatment.get("epsilon") is not None
                    else None
                )
            )
        return noised_data
    
    def _validate_treatment(self, data, noised_data, throw: bool):
        # check to make sure the vars got noised
        logger.debug("Validating noise after post-processing...")
        self.study.validate_noise(
            data,
            noised_data,
            self.study.get_vars_to_noise().pre_replication+list(self.study.sensitivity_matrix().keys()),
            warn_not_appearing=False,  # no need to warn yet, at this intermediate step; ignore created vars
            throw=throw # just give a warning for epsilon > 100
        )
        logger.debug("... validated.")
    
    def _record_treatment(
        self,
        data: dict, noised_data: dict, preprocessed_data: dict,
        treatment,
        computed_sensitivities
    ):
        records_noise = []
        records_sensitivity = []
        for name in data.keys():
            # record final noise for each noised variable (component or final, anything that got noised)
            error, original = Mechanism.error(data[name], noised_data[name])
            rmsd = error.pow(2).mean().pow(0.5)
            rmsd_norm = (rmsd / original.mean()).abs()
            logger.debug("{}: added RMSD/mean(original) {}", name, rmsd_norm[rmsd_norm > 0])
            records_noise += [dict(
                variable=v,
                dataset=name,
                rmsd=rmsd[v].astype('float64'),
                original_mean=original[v].mean().astype('float64'),
                original_std=original[v].std().astype('float64'),
                original_min=original[v].min().astype('float64'),
                original_max=original[v].max().astype('float64'),
                rmsd_norm=rmsd_norm[v],
                **{f"{k}_str": str(treatment.get(k)) for k in treatment.keys()}
            ) for v in rmsd.index if rmsd[v] > 0]
            # record final sensitivities — just component vars listed in the sensitivity matrix
            # should be the same for all runs; depends only on the dataset
            if computed_sensitivities is not None:    
                records_sensitivity += [dict(
                    variable=v,
                    dataset=name,
                    sensitivity=s.astype('float64'),
                    original_mean=preprocessed_data[name][v].mean().astype('float64'),
                    original_std=preprocessed_data[name][v].std().astype('float64'),
                    original_min=preprocessed_data[name][v].min().astype('float64'),
                    original_max=preprocessed_data[name][v].max().astype('float64')
                ) for v, s in computed_sensitivities.items() if v in preprocessed_data[name].columns]
        self._record(records_noise, dict(
            study_id=self.study.id,
            experiment_id=self.experiment_id,
            sim_id=self.sim_id
        ), NoiseDB)
        if computed_sensitivities is not None:
            self._record(records_sensitivity, dict(
                study_id=self.study.id,
                experiment_id=self.experiment_id
            ), SensitivityDB)
    
    def _record(self, records, key, DB):
        self._add_key_to_records(records, key)
        DB(name=self.experiment_id).upsert_all(records)
        # logger.debug(records)
    
    @staticmethod
    def _add_key_to_records(records, key):
        for r in records:
            r.update(key)
        return records


class ReplicationHandler:
    @staticmethod
    def from_treatment(treatment, *args, **kwargs):
        if treatment.get("imputations") is not None:
            return ImputationHandler(*args, **kwargs, imputations=treatment.get("imputations"))
        else:
            return ReplicationHandler(*args, **kwargs)

    def __init__(self, study):
        self.study = study

    def spawn_treatment(self, noised_data: dict, data_original: dict = None):
        # set up symlinks to the treatment data file(s)
        self.study.spawn_treatment(noised_data)
    
    def replicate(self):
        self.study.replicate()
    
    def validate_against_original(self, data: dict, throw: bool = True):
        """Validate noised data against original data.

        Args:
            data (dict): Original data.
            throw (bool, optional): Whether to throw an error if validation fails. Defaults to True.
        """
        noised_data_after_replication = self.study.load_data()
        logger.debug("Validating noise after replication...")
        self.study.validate_noise(
            data,
            noised_data_after_replication,
            # now check all vars for noise, including inter vars
            self.study.get_all_vars_to_noise()+list(self.study.sensitivity_matrix().keys()),
            throw=throw
        )
    
    def validate_expected_results(self, results: dict):
        # check to make sure the results match the original paper
        self.study.validate_expected_results(results)
    
    def extract_results(self):
        return self.study.extract_results()
    
    def save_results(self, id: str):
        dir = self._results_dir()
        if not os.path.exists(dir):
            os.mkdir(dir)
        results = self.extract_results()
        pickle.dump(
            results,
            open(os.path.join(dir, f"{id}.pkl"), "wb")
        )
        return self.load_saved_results(id)

    def load_saved_results(self, id: str):
        return pickle.load(
            open(os.path.join(self._results_dir(), f"{id}.pkl"), "rb")
        )

    def _results_dir(self):
        return os.path.join(Study._path_results(), self.study.id)

    def cleanup(self):
        self.study.cleanup()


class ImputationHandler(ReplicationHandler):
    def __init__(self, study, imputations):
        super().__init__(study)
        self.m = imputations
        # create m imputations
        self.handlers = [
            ReplicationHandler(deepcopy(study))
            for _ in range(self.m)
        ]
    
    def spawn_treatment(self, noised_data, data_original = None):
        logger.debug(
            "Using known error distribution for imputation" if data_original is not None
            else "No noise added, using proportion of population error for imputation"
        )
        imps = self.get_imputations(
            noised_data,
            data_original=data_original,
            qui=(not os.environ.get("LOG_LEVEL") == "DEBUG")
        )
        assert len(imps) == self.m, f"Expected {self.m} imputations, got {len(imps)}"
        for i, imp in enumerate(imps):
            self.handlers[i].spawn_treatment(imp, data_original)
    
    def get_imputations(
            self, noised_data,
            data_original = None,
            stop_after: int = 3000,
            qui: bool = True
        ):
        logger.debug(f"Generating {self.m} imputations...")
        assert len(noised_data) == 1, "Overimputation only works for studies with one dataset"
        df_key = list(noised_data.keys())[0]
        before_imputation = noised_data[df_key].copy()
        before_imputation["uuid"] = range(len(before_imputation))

        vars_noised = [
            v for v in self.study.get_all_vars_to_noise()
            # exclude collinear vars
            if v not in self.study.collinear_vars()
        ]
        # will allow more studies
        # vars_noised = list(self.study.sensitivity_matrix().keys())
        assert set(vars_noised) <= set(before_imputation.columns.values), \
            f"Some vars to noise {vars_noised} not in data {before_imputation.columns}"
        other_vars = self.study.other_vars()
        ts = self.study.time_index()
        cs = self.study.subset_index()
        
        cols = vars_noised + other_vars + ["uuid"]
        if ts is not None: cols += [ts]
        if cs is not None: cols += [cs]
        imputation_df = before_imputation[cols]

        # generate imputations with Amelia R library
        import rpy2.robjects as robjects
        from rpy2.robjects import pandas2ri

        robjects.r.source("R/overimputation.R")
        r_mo = robjects.r["mo"]
        with (robjects.default_converter + pandas2ri.converter).context():
            kwargs = dict(
                m=self.m,
                stop_after=stop_after,
                ncpus=1,
                idvars=robjects.StrVector(["uuid"]),
                qui=qui
            )
            if data_original is not None:
                kwargs["data_original"] = data_original[df_key]
            if ts is not None:
                kwargs["ts"] = ts
            if cs is not None:
                kwargs["cs"] = cs
            imps = r_mo(
                imputation_df,
                robjects.StrVector(vars_noised),
                robjects.StrVector(other_vars),
                **kwargs
            )

        # clean imputations
        imps_clean = []
        before_imputation_partial = before_imputation[before_imputation.columns.difference(vars_noised)]
        m = Control(sensitivity_matrix=self.study.sensitivity_matrix())
        for k, imp in imps["imputations"].items():
            # 1) join in other unused variables
            imp_joined = imp[["uuid"] + vars_noised].merge(
                before_imputation_partial,
                how="left",
                on="uuid",
                validate="1:1"
            ).drop(columns=["uuid"])
            # make sure original columns preserved
            assert len(imp_joined.columns.difference(noised_data[df_key].columns)) == 0, \
                f"Imputation columns {imp_joined.columns} do not match original columns {noised_data[df_key].columns}"
            # 2) use mechanism to apply any required bounds
            for v in vars_noised:
                settings = m._get_settings(v)
                imp_joined[v] = Mechanism.clean(imp_joined[v], settings)
            # do any other final cleaning steps (rounding, etc.); will not overwrite final vars
            imps_clean.append(self.study._clean({df_key: imp_joined}))
            # final cleaning, in case things changed

        return imps_clean

    def validate_expected_results(self, *args, **kwargs):
        raise ValueError("""
            ImputationHandler does not support control condition;
            should not be used to validate expected results.
        """)
    
    def extract_results(self):
        # get all results
        results = []
        for imp in self.handlers:
            results += imp.extract_results()
        # combine results
        return self._combine_results(results)

    def _combine_results(self, results):
        # combine results (adapt mi.combine)
        # https://rdrr.io/cran/Amelia/src/R/combine.R
        # Rubin rules (Rubin, 1978)
        # point estimate is the simple average
        # variance estimate is avg variance + correction factor
        #-- from https://rdrr.io/cran/Amelia/src/R/combine.R
        # ests <- est.matrix(mi_tidy, "estimate")
        # ses <- est.matrix(mi_tidy, "std.error")
        # wi.var <- rowMeans(ses ^ 2)
        # out$estimate <- rowMeans(ests)
        # diffs <- sweep(ests, 1, rowMeans(ests))
        # bw.var <- rowSums(diffs ^ 2) / (m - 1)
        # out$std.error <- sqrt(wi.var + bw.var * (1 + 1 / m))
        # r <- ((1 + 1 / m) * bw.var) / wi.var
        # df <- (m - 1) * (1 + 1 / r) ^ 2
        # miss.info <- (r + 2 / (df + 3)) / (r + 1)
        # out$statistic <- out$estimate / out$std.error
        # out$p.value <- 2 * stats::pt(out$statistic, df = df, lower.tail = FALSE)
        # out$df <- df
        # out$r <- r
        #--
        logger.debug(f"Combining {self.m} results...")
        result_lists = defaultdict(list)
        # need to group results by ID before combine
        for res in results:
            result_lists[res.id].append(res)
        results_combined = []
        for v in result_lists.values():
            if len(v) < 2:
                # no need to combine, just return the original
                results_combined += v
                continue
            assert len(v) == self.m, f"Expected {self.m} imputation results, got {len(v)}"
            # adapted from https://rdrr.io/cran/Amelia/src/R/combine.R
            ests = [r.est for r in v]
            ses = [r.se for r in v]
            m = len(v)
            wi_var = np.mean(np.array(ses) ** 2)
            est = np.mean(ests)
            diffs = np.array(ests) - est
            bw_var = np.sum(diffs ** 2) / (m - 1)
            se = np.sqrt(wi_var + bw_var * Decimal(1 + 1 / m))
            assert se != v[0].se
            t = est / se
            r = (Decimal(1 + 1 / m) * bw_var) / wi_var
            df = (m - 1) * (1 + 1 / r) ** 2  # imputation adjusted degrees of freedom
            p = 2 * t_dist.sf(np.abs(np.float64(t)), np.float64(df))
            assert p <= 1 and p >= 0, f"p-value {p} out of bounds"
            # combine results using first Result object
            combined = deepcopy(v[0])
            combined.update_stats(
                est=est, se=se,
                p=p, t=t
                # all other attributes (df_m, N, etc.) stay the same
            )
            results_combined.append(combined)
        return results_combined


    def replicate(self, *args, **kwargs):
        for i, imp in enumerate(self.handlers):
            logger.debug(f"Replicating w/ imputation {i+1}/{self.m}...")
            imp.replicate(*args, **kwargs)
    
    def validate_against_original(self, *args, **kwargs):
        for imp in self.handlers:
            imp.validate_against_original(*args, **kwargs)
    
    def cleanup(self, *args, **kwargs):
        for imp in self.handlers:
            imp.cleanup(*args, **kwargs)
