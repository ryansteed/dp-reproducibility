from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Dieterle(Study):
    id = 'dieterle-2020'

    def data_paths(self) -> dict:
        return {
            # "BBD-lodes": os.path.join(
            #     self.path(), "source/data/Data", "BBD-lodes.dta"
            # ),
            "BBD-RD": os.path.join(
                self.path(), "source/data/Data", "BBD-RD.dta"
            )
            # ...
        }

    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict:
        df1 = data["BBD-RD"]
        # deconstruct ln_unemp
        df1["unemp_r"] = np.exp(df1["ln_unemp"])
        df1["emppop"] = np.exp(df1["ln_emppop"])
        df1["unemp"] = df1["unemp_r"] * df1["emppop"]
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df1 = noised_data["BBD-RD"]
        # reconstruct ln_unemp
        df1["unemp_r"] = np.where(
            df1["unemp"].isna() | df1["unemp"].isna(),
            df1["unemp_r"],
            df1["unemp"] / df1["emppop"]
        )
        df1["ln_unemp"] = np.log(df1["unemp_r"])
        df1["ln_emppop"] = np.log(df1["emppop"])
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "ln_unemp",
            "ln_unemp_res_1",
            # "wgt" # could not noise
        ]
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code: ###
        # Table 1
        # eststo: areg ln_unemp ln_ui [aweight=wgt]  if     ln_unemp_res_1<., absorb(st_bound_qtr_id) cluster(st_by_bound)
        # foreach r in 1 aicc{
        #     areg ln_unemp_res_`r' ln_ui_res_`r' [aweight=wgt] , absorb(st_bound_qtr_id) cluster(st_by_bound)
        #     ...
        # }
        # Table 5
        # eststo: xtreg work_neigh_frac ui_avail_yr_avg_diff i.year , fe vce(cluster st_county_cd)
        # eststo: xtreg work_neigh_frac ui_avail_yr_avg_diff l.ui_avail_yr_avg_diff i.year , fe vce(cluster st_county_cd)
        # eststo: xtreg work_neigh_frac ui_avail_yr_avg_diff l(1/3).ui_avail_yr_avg_diff i.year , fe vce(cluster st_county_cd)
        ###
        ### vars:
        ## from BBD-RD
        # ln_unemp
        # [not personal data] ln_ui
        # wgt
        # ln_unemp_res_1
        # ln_ui_res_1
        ## from BBD-lodes
        # work_neigh_frac
        # [not personal data] ui_avail_yr_avg_diff
        ###
        vars_to_noise = {
            ## ln_unemp, ln_unemp_res_1
            # relevant code from `BBD-RD-data.do`:
            # *log unemployment rate
            # gen ln_unemp=ln(unemp_r)
            # ...
            # foreach y of varlist ln_unemp ln_ui{
            # foreach r in 1 aicc{
            # gen double `y'_res_`r'=.
            # }
            # }
            # unfortunately, can't get the constructing file to run
            # so will have to reverse engineer
            # CREATED INTER VARS unemp, emppop
            "emppop": lambda state: 1,
            "unemp": lambda state: 1,

            ## wgt
            # regression code from BBD-RD-data:
            # total POP10_TOTAL
            # gen wgt=POP10_TOTAL/_b[POP10_TOTAL]
            # can't do this one --- missing original data, only have intermediate

            ## [not personal data] ln_ui - weeks of unemp insurance available in state
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []

        table = self._load_esttab(f"{self.path()}/results/Table1.csv")
        results.append(Result.from_esttab(
            id="ln_ui-ln_unemp",
            table=table,
            row="ln_ui",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="ln_ui_res_1-ln_unemp",
            table=table,
            row="ln_ui_res_1",
            col="est2",
            expected_range=(None, None)
        ))

        # Can't do this one, not enough data
        # table = self._load_esttab(f"{self.path()}/results/Table5.csv")
        # results.append(Result.from_esttab(
        #     id="ui_avail_yr_avg_diff-work_neigh_frac",
        #     table=table,
        #     row="ui_avail_yr_avg_diff",
        #     col="est3",
        #     expected_range=(None, 0)
        # ))

        return results