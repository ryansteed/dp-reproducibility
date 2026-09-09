import pandas as pd
import numpy as np
from typing import Callable, Dict
import os
import subprocess
import pkgutil
import shutil
import tempfile
import pyreadr
import json
from collections import namedtuple

from simulate_privacy.config import logger
from simulate_privacy.analysis import Result
from simulate_privacy.mechanisms import Mechanism


VarsToNoise = namedtuple(
    "VarsToNoise",
    ["pre_replication", "post_replication"],
    defaults=[[], []]
)

class Study:
    @classmethod
    def from_id(cls, study_id: str, *args, **kwargs):
        """Factory method to produce correct subclass from a study id string.

        Args:
            study_id (str): the study ID. should match a directory in `studies/`.

        Raises:
            ValueError: Errors if study does not match a subclass in `studies.py`.

        Returns:
            Study: The correct Study subclass object.
        """
        # load plugin subclasses from study folders
        path = os.path.join(Study._path_studies(), study_id)
        study_plugins = {
            name: finder.find_module(name).load_module(name)
            for finder, name, ispkg
            in pkgutil.iter_modules(path=[path])
            if name == "study"
        }
        if len(study_plugins) < 1:
            raise ValueError(f"Study plugin {path}/study.py not found.")
        
        MAPPING = {c.id: c for c in Study.__subclasses__()}

        if study_id not in MAPPING.keys():
            raise ValueError(f'Unknown study {study_id}')
        return MAPPING[study_id](*args, **kwargs)
    
    @classmethod
    def _path_studies(cls):
        base_path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(base_path, "../studies")

    @classmethod
    def _path_data(cls):
        base_path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(base_path, "../data")
    
    @classmethod
    def _path_results(cls):
        base_path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(base_path, "../results")
    
    def __init__(self) -> None:
        self._temp_treat_dir = None
        self._value_labels = {}

    def path(self) -> str:
        # should be relative to the current working directory,
        # not always pointing at the original directory
        return os.path.join(
            Study._path_studies(),
            self.id if self._temp_treat_dir is None else os.path.basename(
                self._temp_treat_dir.name
            )
        )

    def save_treatment(self, data: Dict[str, pd.DataFrame], id: str) -> dict:
        """Save treated datasets in treatment directory.

        Args:
            data (Dict[str, pd.DataFrame]): Dataframes to save.
            id (str): ID for the treatment.

        Returns:
            dict: Paths for the saved data files.
        """
        paths = self._treatment_data_paths(id)
        self._save_data_to_paths(data, paths)
        return paths
    
    def _save_data_to_paths(self,
            data: Dict[str, pd.DataFrame],
            paths: Dict[str, str],
            categoricals: list = []
        ) -> dict:
        """Save dataframes to the given paths, handling categoricals/labels.

        Args:
            data (Dict[str, pd.DataFrame]): Dataframes to save.
            paths (Dict[str, str]): Paths to save each dataframe to.
            # categoricals (list, optional): List of vars that need to be saved as longs with value labels.
            #     Defaults to [].
        """
        for name, df in data.items():
            # remove old file
            os.remove(paths[name])
            # write new file
            if paths[name].endswith(".dta"):
                # convert categoricals to their original codes + labels
                vc_map = self.valuelabel_colname_mapping()
                value_labels = {
                    vc_map.get(k, k): v for k, v in self._value_labels[name].items() # use same value labels as before
                    if vc_map.get(k, k) in df.columns
                }
                df.to_stata(
                    paths[name],
                    value_labels=value_labels,
                    version=self.stata_version(),
                    write_index=False
                )
            elif paths[name].endswith(".csv"):
                self._save_csv(df, paths[name])
            elif paths[name].endswith(".txt"):
                self._save_csv(df, paths[name], sep="\t")
            elif paths[name].endswith(".Rdata"):
                pyreadr.write_rdata(paths[name], df, df_name=name)
            else:
                raise ValueError(f"Unknown file extension for {paths[name]}")
    
    def stata_version(self) -> int:
        """Version of Stata being used. (Affects data I/O.)

        Returns:
            int: STata version number. Defaults to 114.
        """
        return 114
    
    def valuelabel_colname_mapping(self) -> dict:
        """
        Returns:
            dict: Mapping between value label group titles (e.g. Fips) and the column names they apply to (e.g. state).
        """
        return {}

    def load_treatment(self, id):
        paths = self._treatment_data_paths(id)
        try:
            data = self._load_data_from_paths(paths)
            return data, paths
        except FileNotFoundError as e:
            logger.error(f"Could not load treatment data from {paths}")
            raise e
        
    def _treatment_data_paths(self, id: str) -> dict:
        dir = os.path.join(Study._path_data(), self.id)
        if not os.path.exists(dir):
            os.mkdir(dir)
        return {
            name: os.path.join(dir, f"{name}_{id}{os.path.splitext(path)[1]}")
            for name, path in self.data_paths().items()
        }

    def validate_expected_results(self, results: list):
        """Check the reproduced results against expected results (copied to a JSON file directly from the paper).

        Args:
            results (list): Set of results to check.
        """
        expected_results_path = os.path.join(self.path(), 'expected-results.json')
        with open(expected_results_path, 'r') as f:
            expected_results = [Result(**result) for result in json.load(f)]
            # check that the results match the original results
            if results != expected_results:
                raise ValueError(
                    "Results do not match expected results.\n" 
                    f"Expected but not returned: {[e for e in expected_results if e not in results]}.\n"
                    f"Returned but not expected: {[e for e in results if e not in expected_results]}"
                )
        # check that the results fall within the expected ranges
        for result in results:
            result.validate_expected_range()
        return True


    def data_paths(self) -> dict:
        """
        Returns:
            dict: Dictionary (name: path) of data files used to produce the original results.
        """
        raise NotImplementedError
    
    def spawn_treatment(self, data_treated: Dict[str, pd.DataFrame]):
        """Spawn a temporary "treatment" directory to run treated replication without modifying the original directory.

        Args:
            data_treated (Dict[str, pd.DataFrame]): Treatment data to replicate with.
        """
        self._temp_treat_dir = self._create_temp_directory()
        logger.debug(f"Working treatment directory: {self._temp_treat_dir.name}")
        data_paths = self.data_paths()
        # save treated data to temp dir
        self._save_data_to_paths(data_treated, data_paths)

    def _create_temp_directory(self):
        # This function creates a temporary directory using a unique prefix based on the study path.
        # It then copies all files and subdirectories from the original study directory to the temporary directory.
        # This ensures that each replication attempt operates on its own isolated copy of the study data,
        # avoiding conflicts when running multiple replications in parallel.
        tempdir = tempfile.TemporaryDirectory(
            prefix=f"tmp_{os.path.basename(self.path())}_",
            dir=self._path_studies()
        )
        for item in os.listdir(self.path()):
            s = os.path.join(self.path(), item)
            d = os.path.join(tempdir.name, item)
            if os.path.isdir(s):
                shutil.copytree(
                    s, d,
                    # don't copy contents from /results
                    ignore=shutil.ignore_patterns("*") if item == "results" else None
                )
            else:
                shutil.copy2(s, d)
        logger.debug(f"Spawned temporary directory {tempdir} for replication")
        return tempdir
    
    # DEPRECATED — now saving treated data directly to temp dir
    def validate_treatment(self, data_paths_treatment: Dict[str, str]):
        # dfs_treatment = self._load_data_from_paths(data_paths_treatment)
        logger.debug(f"Comparing {data_paths_treatment} to {self.data_paths()}")
        for name, df_current in self.load_data().items():
            assert df_current.equals(data_paths_treatment[name]), f"Treatment dataframe does not match spawn dir: {name}."

    def cleanup(self):
        self._temp_treat_dir.cleanup()
        self._temp_treat_dir = None

    def load_data(self) -> Dict[str, pd.DataFrame]:
        """Load study datasets from current directory.

        Returns:
            Dict[str, pd.DataFrame]: Study datasets loaded from the current directory.
        """
        paths = self.data_paths()
        data = self._load_data_from_paths(paths)    
        assert all(k in data.keys() for k in paths.keys()), f"Data columns do not match paths: {data.keys()} vs {paths.keys()}"
        return data
    
    def _load_data_from_paths(self, paths):
        data = {}
        for name, path in paths.items():
            if path.endswith(".dta"):
                data[name] = self._read_stata(path, name)
            elif path.endswith(".csv"):
                data[name] = self._read_csv(path)
            elif path.endswith(".txt"):
                data[name] = self._read_csv(path, sep="\t")
            elif path.endswith(".Rdata"):
                data[name] = pyreadr.read_r(path)[name]
            else:
                raise ValueError(f"Unknown file extension for {path}")
        return data
    
    def _read_stata(self, path, name):
        df = pd.read_stata(
            path,
            convert_dates=False,
            convert_categoricals=False
        ).rename(columns={
            "case": "var_case" # reserved word
        })
        reader = pd.read_stata(
            path,
            convert_dates=False,
            convert_categoricals=False,
            iterator=True
        )
        self._value_labels[name] = reader.value_labels()
        return df
    
    def _read_csv(self, path, sep=","):
        return pd.read_csv(path, sep=sep)
    
    def _save_csv(self, df, path, sep=","):
        df.to_csv(path, index=False, sep=sep)

    def extract_results(self) -> list[Result]:
        """Extract numerical results after replication.

        Returns:
            list[Result]: List of numerical results extracted from the replication.
        """
        raise NotImplementedError
    
    def replicate(self):
        """Execute study replication using pre-defined `make results` monoscript.

        Raises:
            ReplicationError: Replication failed due to an error in the `make results` command.
        """
        try:
            logger.debug(f"# {self.id} > `make results`")
            working_directory = self.path() if self._temp_treat_dir is None else self._temp_treat_dir.name
            logger.debug(f"Executing 'make results' in {working_directory}")
            # call `make results` in the current directory
            subprocess.run(
                "make results",
                cwd=working_directory,
                shell=True,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            logger.debug("subprocess.run called successfully")
        except subprocess.CalledProcessError as e:
            error_msg = f"Command 'make results' failed with exit code {e.returncode}"
            error_msg += f"\nStandard output: {e.stdout.decode()}"
            error_msg += f"\nStandard error: {e.stderr.decode()}"
            logger.error(error_msg)
            raise ReplicationError(error_msg)

    def noise(self, data: Dict[str, pd.DataFrame], mechanisms: list[Mechanism]) -> tuple[dict, dict]:
        """Apply noise to data using provided noise mechanisms.

        Args:
            data (Dict[str, pd.DataFrame]): Datasets to noise.
            mechanisms (list[Mechanism]): Mechanisms to use to apply noise.

        Returns:
            tuple[dict]: Datasets after noise infusion and postprocessing; and datasets after pre-processing (before noise is applied).
        """
        logger.debug("Treating data...")
        # check to make sure pre, post-processing will not alter data
        self.validate_processing(data)
        data_preprocessed = self._pre_processing({name: df.copy() for name, df in data.items()})
        logger.debug("Pre-processed data")
        noised = data_preprocessed
        for mech in mechanisms:
            logger.debug(f"Applying mech {mech}")
            noised = mech.noise(noised)
        logger.debug("Treated data")
        data_postprocessed = self._match_data_types(
            data,
            self._clean(self._post_processing(noised))
        )
        logger.debug("Post-processed data")
        return data_postprocessed, data_preprocessed
    
    def validate_noise(
            self,
            data: Dict[str, pd.DataFrame],
            noised: Dict[str, pd.DataFrame],
            vars_to_noise: list,
            throw=True,
            warn_not_appearing=True
        ):
        """Check if noise was successfully added to treated datasets. 

        Args:
            data (Dict[str, pd.DataFrame]): Original datasets.
            noised (Dict[str, pd.DataFrame]): Noised datasets.
            vars_to_noise (list): Variables to check for noise.
            throw (bool, optional): Whether to raise an error if noise is not found. Defaults to True.
            warn_not_appearing (bool, optional): Whether to warn if variables do not appear in the dataset. Defaults to True.

        Returns:
            _type_: _description_
        """
        # we cannot know if derivative vars were noised during replication,
        # if computation happens in-memory (i.e. in the original authors' code).
        # instead, we can only check that the component vars were noised as expected.
        logger.debug(f"Validating noise for {vars_to_noise}")
        vars_checked = []
        for name, df in data.items():
            vars_to_check = [
                k for k in vars_to_noise
                if k in df.columns and k not in self._skip_validation()
            ]
            vars_checked += vars_to_check
            logger.debug(f"Validating noise for {vars_to_check} in {name}")
            noise = Mechanism.validate_noise(
                df, noised[name], vars_to_check=vars_to_check, throw=(throw and not self._low_noise_expected())
            )
            if len(vars_to_check) > 0:
                rmse = noise.pow(2).mean().pow(0.5)
                logger.debug("Noising variables {}", data[name][vars_to_check].describe())
                logger.debug("Added noise, RMSE {}", rmse[vars_to_check])
        vars_not_checked = [v for v in vars_to_noise if v not in vars_checked]
        if warn_not_appearing and (len(vars_not_checked) > 0):
            logger.warning(f"Vars {vars_not_checked} do not appear in dataset. (Expected for intermediate vars post-replication.)")
        return True
    
    def _low_noise_expected(self) -> bool:
        return True
    
    def _skip_validation(self) -> list[str]:
        return []
    
    def sensitivity_matrix(self, year_cutoff: int = 1950) -> dict:
        """Global sensitivity of statistical queries used to produce the findings.

        Args:
            year_cutoff (int, optional): Ignore variables before this year. Defaults to 1950.

        Returns:
            dict: Dictionary mapping variable names to functions that compute the global sensitivity of the variable's query. Functions should return a constant value (float) representing the global sensitivity of the query. (Callables are used to handle experimental cases where global sensitivities were computed based on the data itself, which is not differentially private; this feature is not used in the final results.) For variables that require clipping, return a dict with "sensitivity" and "ub" (int) and/or "lb" (int) specified.
        """
        raise NotImplementedError
    
    def validate_processing(self, data: Dict[str, pd.DataFrame], tolerance=1e-6):
        """Ensure original data do not change as a result of
        post- and pre-processing (with no noise).

        Args:
            data (Dict[str, pd.DataFrame]): Data to validate.
        """
        logger.debug("Validating processing...")
        data_processed = self._pre_processing({name: df.copy(deep=True) for name, df in data.items()})
        data_post_processed = self._match_data_types(
            data,
            self._clean(self._post_processing(data_processed))
        )
        self._allclose(data, data_post_processed)
        logger.debug("... validated.")
    
    @staticmethod
    def _allclose(data, data_new):
        for name, df in data.items():
            for c in df.columns:
                if df[c].isnull().all():
                    # ignore empty columns
                    equal = True
                elif ("float" in str(df[c].dtype) or "int" in str(df[c].dtype)) and not df[c].isnull().all():
                    equal = np.allclose(df[c], data_new[name][c], equal_nan=True)
                    close = np.isclose(df[c], data_new[name][c], equal_nan=True)
                    cmprsn = np.stack((df[c].values[~close], data_new[name][c].values[~close]))
                    errs = cmprsn.shape[1]
                    err_idx = df[~close].index
                else:
                    equal = df[c].equals(data_new[name][c])
                    cmprsn = df[c].compare(
                        data_new[name][c],
                        result_names=("old", "new")
                    )
                    errs = len(cmprsn)
                    err_idx = "NA"
                dtype_old = Study.type_conversions.get(str(df[c].dtype), str(df[c].dtype))
                dtype_new = Study.type_conversions.get(str(data_new[name][c].dtype), str(data_new[name][c].dtype))
                assert (
                    df[c].dtype == data_new[name][c].dtype
                ) or (dtype_old == dtype_new), f"""
                    Data processing altered dtype of {name}.{c}. 
                    {df[c].dtype} != {data_new[name][c].dtype}
                    """
                assert equal, f"""
                    Data processing altered {name}.{c} ({errs}/{len(data_new[name])} rows). 
                    old->new: {cmprsn} 
                    at {err_idx}
                """
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> dict:
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        # for name in noised_data.keys():
        #     for query, transform_list in transforms.items():
        #         for transform in transform_list:
        #             noised_data[name][query] = transform(noised_data[name][query])
        return noised_data
    
    def _clean(self, noised_data) -> pd.DataFrame:
        """
        Final post processing step for cleaning noisy data for regression.
        Should not utilize any variables other than the final vars_to_noise().
        """
        return noised_data

    type_conversions = {
        'int16': 'int64',
        'int32': 'int64',
        'float32': 'float64'
    }
    
    @staticmethod
    def _match_data_types(before, after):
        # match types
        for name, df in after.items():
            types = {
                v: Study.type_conversions.get(str(t), str(t))
                for v,t in before[name].dtypes.to_dict().items()
            }
            after[name] = df.astype(types)
        return after
    
    def get_vars_to_noise(self) -> VarsToNoise:
        vars_to_noise = self.vars_to_noise()
        return VarsToNoise(**vars_to_noise) if isinstance(vars_to_noise, dict) else VarsToNoise(vars_to_noise)
    
    def get_all_vars_to_noise(self) -> list[str]:
        vars_to_noise = self.get_vars_to_noise()
        return vars_to_noise.pre_replication + vars_to_noise.post_replication

    def vars_to_noise(self) -> list[str]:
        """Variables used in the study that should be noised. Does not include component variables,
        only the final variable that should have noise (before any pre-processing or post-processing).

        Returns:
            list[str]: A list or lists of variables in the original datasets
                that should be noised. The first list contains variables that
                are constructed before replication (by our code), the second list
                (optional) contains variables constructed after replication.
        """
        raise NotImplementedError

    def other_vars(self) -> list[str]:
        raise NotImplementedError
    
    def collinear_vars(self) -> list[str]:
        """
        vars_to_noise() that are collinear with others in the dataset.
        These should be constructed in _clean().
        Used to avoid collinear warnings during multiple overimputation.
        """
        return []
    
    def time_index(self) -> str:
        """
        Returns:
            str: Column name of time index (e.g., "yr") used in the datasets, if any.
        """
        raise NotImplementedError
    
    def subset_index(self) -> str:
        """
        Returns:
            str: Column name of non-time subsetting index (e.g., "county") used in the datasets, if any.
        """
        raise NotImplementedError

    def _load_esttab(self, path: str) -> pd.DataFrame:
        """Load results from Stata's `esttab` command.

        Args:
            path (str): Path to CSV output.

        Returns:
            pd.DataFrame: Loaded results from Stata's `esttab` command.
        """
        table = pd.read_csv(path, na_values=".").rename(columns={
            "Unnamed: 0": "var"
        })
        cols = []
        for top, bottom in zip(table.columns, table.iloc[0]):
            if "Unnamed" not in top:
                current_top = top
            cols.append(f"{current_top}_{bottom}")
        table = table.dropna(subset=["var"]).set_index("var")
        # table.columns = [f"{v}_{x}" for v in table.columns if "Unnamed" not in v for x in ("b", "se")]
        table.columns = cols[1:]
        return table
    
    def _load_mat2txt(self, path: str) -> pd.DataFrame:
        """Load results from `mat2txt` command.

        Args:
            path (str): Path to the text file.

        Returns:
            pd.DataFrame: Loaded results from `mat2txt` command.
        """
        table = pd.read_csv(path, sep="\t").rename(columns={
            "Unnamed: 0": "var"
        }).set_index("var")
        return table


class ReplicationError(Exception):
    pass