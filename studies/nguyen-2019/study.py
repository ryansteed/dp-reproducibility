from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Nguyen(Study):
    id = 'nguyen-2019'

    def data_paths(self) -> dict:
        return {
            "replication_input": os.path.join(
                self.path(), "source/App2017-0543__data", "replication_input.dta"
            ), 
            "final": os.path.join(
                self.path(), "source/App2017-0543__data", "final.dta"
            ), # created by us, for validation only
            # ...
        }
    
    yrs = list(range(1999, 2013))  # 1999 to 2012
    def vars_to_noise(self) -> dict[str, list[str]]:
        # list all personal vars used in the regression
        year_interactions = [f"{v}{yr}" for v in [
            "poptot",
            "popdensity",
            "pminority",
            "pcollege",
            "medincome",
        ] for yr in self.yrs]
        return {
            "post_replication": year_interactions
        }

            
    def _pre_processing(self, data):
        df = data["replication_input"]
        # deconstruct popdensity = poptot / landarea
        df["landarea"] = df["poptot"] / df["popdensity"]
        # deconstruct pminority = minority/poptot
        df["minority"] = df["pminority"] * df["poptot"]
        # deconstruct pcollege = college/poptot
        df["college"] = df["pcollege"] * df["poptot"]
        return data
    
    def _post_processing(self, noised_data):
        noised_df = noised_data["replication_input"]
        # reconstruct popdensity
        noised_df["popdensity"] = np.where(
            noised_df["landarea"].isna(),
            0,
            noised_df["poptot"] / noised_df["landarea"]
        )
        # reconstruct pminority
        noised_df["pminority"] = noised_df["minority"] / noised_df["poptot"]
        # reconstruct pcollege
        noised_df["pcollege"] = noised_df["college"] / noised_df["poptot"]
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `main_results.do`: ###
        # use replication_input, clear
        # ...
        ## local chars poptot popdensity pminority pcollege ///
            ##     medincome pincome cont_totalbranches cont_brgrowth 

            ## foreach var in `chars' {
            ##     forvalues year = 1999/2013 {
            ##         gen `var'`year' = `var' * ydum`year'
            ##     }
            ## }
            ## drop `chars'
        # ...
        # eststo m1: ivreghdfe AmtSBL_Rev1 ///
        # poptot* popdensity* pminority* pcollege* medincome* ///
        # cont_totalbranches* cont_brgrowth* ///
        # (POST_close = POST_expose), ///
        # absorb(indivID group_timeID) ///
        # vce(cluster clustID)

        sensitivities = {
            ### poptot*: total population * year dummy variable
            "poptot": lambda tract: 1,

            ### popdensity*:  population per square mile * year dummy variable
            # popdensity = poptot / landarea
            # NOTE created inter var landarea = poptot / popdensity
            # [not personal] landarea
            # poptot already noised

            ### pminority*:  fraction minority * year dummy variable
            # pminority = minority / poptot
            # NOTE: created inter var minority = pminority * poptot
            "minority": lambda tract: 1,     

            ### pcollege*: fraction college-educated * year dummy variable
            # pcollege = college / poptot
            # NOTE: created inter var college = pcollege * poptot
            "college": lambda tract: 1,

            ### medincome*: median family income * year dummy variable
            # assuming income capped at 500k (see max)
            "medincome": lambda tract: 500000 / 2,

            ### [not personal] AmtSBL_Rev1: small business loan originations, $ value
            ### [not personal] cont_totalbranches*: total number of bank branches, as of year in which the merger is announced * year dummy variable
            ### [not personal] cont_brgrowth*: average branch growth over the last 2 years, as of year in which the merger is a * year dummy variable
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="close-credit",
            table=table,
            row="POST_close",
            col="m1",
            expected_range=Result.relative_range(-871.4, tolerance=0.2)
        ))
        return results