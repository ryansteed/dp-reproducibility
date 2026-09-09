from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class He(Study):
    id = 'he-2017'

    def data_paths(self) -> dict:
        return {
            "workfile_AEJ": os.path.join(
                self.path(), "source/APP2016-0079_data", "workfile_AEJ.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "l_subsidy_rate",
            "l_disability_rate",
            "l_poor_reg_rate"
        ]
    
    def _post_processing(self, noised_data):
        noised_df = noised_data["workfile_AEJ"]
        noised_df["disability_rate"] = noised_df["nca_26"] / noised_df["village_pop"] * 1000
        noised_df['l_disability_rate'] = np.log(noised_df["disability_rate"] + 1)
        noised_df["subsidy_rate"] = noised_df["subsidy_pop"]/noised_df["village_pop"]*1000
        noised_df['l_subsidy_rate'] = np.log(noised_df["subsidy_rate"] + 1)
        noised_df["poor_reg_rate"] = np.where(
            noised_df["poor_reg_rate"].isna(),
            np.nan,
            noised_df["nca_24"] / noised_df["nc3_16"] * 100
        )
        noised_df['l_poor_reg_rate'] = np.log(noised_df["poor_reg_rate"] + 1)
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `1_CGVO_Main_Tables.do`: ###
        # use $path/workfile_AEJ, clear
        # ...
        # *** Main Results ***
        # local v_fe "v_fe*"
        # local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"
        # ...
        #--- cgvo-poor
        # eststo: reg l_poor_reg_rate cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
        #--- lcgvo-poor
        # eststo: reg l_poor_reg_rate lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
        # ...
        #--- lcgvo-disable
        # eststo: reg l_disability_rate lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
        #--- cgvo-subsidize
        # eststo: reg l_subsidy_rate cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
        #--- lcgvo-subsidize
        # eststo: reg l_subsidy_rate lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
        ###

        sensitivities = {
            ### l_subsidy_rate: log of the number of formally registered residents with subsidy in a village per 1000 residents
            #> The code below are not in the do file. Tried in stata and this is how they get this variable. 
            #> gen subsidy_rate = subsidy_pop/village_pop * 1000
            #> gen l_subsidy_rate = log(subsidy_rate + 1)
            #> the number of formally registered residents with disabilities in a village
            # NOTE: reconstructing subsidy_rate = subsidy_pop / village_pop * 1000
            "subsidy_pop": lambda village: 1,
            "village_pop": lambda village: 1,

            ### l_disability_rate: log of the number of residents with disabilities in a village per 1000 residents
            # The code below are not in the do file. Tried in stata and this is how they get this variable.
            #> gen l_disability_rate = log(disability_rate + 1)
            # nca_26: number of disabled people in the village
            # NOTE: reconstructing disability_rate = nca_26 / village_pop * 1000
            # village_pop already noised
            "nca_26": lambda village: 1,

            ### l_poor_reg_rate: Registered poor households (per 100, log)
            # nc3_16: total number of households
            # assuming l_poor_reg_rate = log(poor_reg_rate + 1)
            # NOTE: reconstructing poor_reg_rate = nca_24 / nc3_16 * 100
            "nca_24": lambda village: 1,
            "nc3_16": lambda village: 1,

            # [not personal] cgvo: dummy variable on whether a village introduce —the College Graduate Village Officials (CGVOs) program
            # [not personal] lag_cgvo: lage of cgvo.
            # [not personal] precipitation: total precipitation for the day in inches
            # [not personal] temperature: mean temperature in degrees fahrentheit
            # [not personal] v_fe*: village fixed effect
            # [not personal] t*: year fixed effect
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="cgvo-poor",
            table=table,
            row="cgvo",
            col="est1",
            expected_range=(0, None),
        ))
        results.append(Result.from_esttab(
            id="lcgvo-poor",
            table=table,
            row="lag_cgvo",
            col="est2",
            expected_range=(0, None),
        ))
        # results.append(Result.from_esttab(
        #     id="cgvo-disable",
        #     table=table,
        #     row="cgvo",
        #     col="est1",
        #     expected_range=(0, 0),
        #     est_stats={"est": "b", "se": "se"}
        # ))
        results.append(Result.from_esttab(
            id="lcgvo-disable",
            table=table,
            row="lag_cgvo",
            col="est4",
            expected_range=(0, None),
        ))
        results.append(Result.from_esttab(
            id="cgvo-subsidize",
            table=table,
            row="cgvo",
            col="est5",
            expected_range=(0, None),
        ))
        results.append(Result.from_esttab(
            id="lcgvo-subsidize",
            table=table,
            row="lag_cgvo",
            col="est6",
            expected_range=(0, None),
        ))
        return results