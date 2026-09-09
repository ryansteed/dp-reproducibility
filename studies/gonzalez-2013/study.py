from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Gonzalez(Study):
    id = 'gonzalez-2013'

    def data_paths(self) -> dict:
        return {
            "births_aggregate": os.path.join(
                self.path(), "source/Data_20110196", "births_aggregate.dta"
            ),
            "data_abortions_20110196": os.path.join(
                self.path(), "source/Data_20110196", "data_abortions_20110196.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> dict:
        # list all personal vars used in the regression
        return {
            "pre_replication": ["ln"],
            "post_replication": ["log_ive"]
        }
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df = noised_data["births_aggregate"]
        df["ln"] = np.log(df["n"])
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `dofile_fertility_20110196.do`: ###
        # use data_births_20110196, clear
        # ...
        # eststo main: xi: reg ln post i.post|mc i.post|mc2 i.post|mc3 days if mc>-91 & mc<30, robust
        # ...
        # use data_abortions_20110196, clear
        # ...
        # eststo: xi: reg log_ive post i.post|m i.post|m2 i.post|m3 days, robust
        sensitivities = {
            #--- data_births_20110196.dta
            # ln: natural log of number of conception in month
            #> from dofile_fertility_20110196.do [not run]:
            #> gen n=1
            #> collapse (count) n, by(mc3)
            #> ln = ln(n)
            # NOTE: reconstructing ln = ln(n)
            "n": lambda region: 1,

            #--- data_abortions_20110196.dta
            # log_ive: natural log of the monthly number of abortions in 12 out of the 17 Spanish regions
            #> gen n_tot = n_ive_and + n_ive_val + n_ive_rioja + n_ive_cat + n_ive_can + n_ive_mad + n_ive_gal + n_ive_bal + n_ive_pv + n_ive_castlm + n_ive_ast + n_ive_arag 
            #> ...
            #> gen log_ive = ln(n_tot)
            "n_ive_and":    lambda region: 1,
            "n_ive_val":    lambda region: 1,
            "n_ive_rioja":  lambda region: 1,
            "n_ive_cat":    lambda region: 1,
            "n_ive_can":    lambda region: 1,
            "n_ive_mad":    lambda region: 1,
            "n_ive_gal":    lambda region: 1,
            "n_ive_bal":    lambda region: 1,
            "n_ive_pv":     lambda region: 1,
            "n_ive_castlm": lambda region: 1,
            "n_ive_ast":    lambda region: 1,
            "n_ive_arag":   lambda region: 1,

            # [not personal] post: A post indicator for post-policy conception 
            # [not personal] mc:  Month of conception (0 = July 2007)
            # [not personal] mc2: 9 months before the birth month, 8 if premature
            # [not personal] mc3: calculated based on weeks of gestation
            # [not personal] days
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="bene-conception",
            table=table,
            row="post",
            col="main",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="bene-abortion",
            table=table,
            row="post",
            col="est1",
            expected_range=(None, 0)
        ))
        return results