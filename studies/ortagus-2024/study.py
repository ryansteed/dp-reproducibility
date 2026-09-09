from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Ortagus(Study):
    id = 'ortagus-2024'

    def data_paths(self) -> dict:
        return {
            "new_data": os.path.join(
                self.path(), "source", "new_data.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "ln_fteug",
            "ln_instruct_fte",
            "ln_stcollage2",
            "stbaabove_p",
            "ln_stinccap",
            "stunemprate",
            "stcoll2_black_p",
            "stcoll2_hisp_p",
            "stcoll2_amind_p",
        ]
    
    def _pre_processing(self, data):
        df = data["new_data"]
        df["exp_ins_adjusted"] = df["instruct_fte"] * df["fteug"]
        df["pop"] = df["stbaabove"] / df["stbaabove_p"] * 100
        df["lnincome"] = df["ln_stinccap"] + np.log(df["pop"])

        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["new_data"]
        
        df["ln_fteug"] = np.where(
            df["fteug"] > 0,
            np.log(df["fteug"]),
            np.nan
        )
        # CLOSE BUT NOT QUITE
        # df["instruct_fte"] = np.where(
        #     df["fte"].isna(), np.where(
        #         df["fteug"] == 0, np.nan,
        #         df["exp_ins_cpi18"].astype('float') / df["fteug"],
        #     ),
        #     df["exp_ins_cpi18"] / df["fte"]
        # )
        df["ln_instruct_fte"] = np.where(
            df["fteug"].isna() | (df["fteug"] == 0) |  (df["exp_ins_adjusted"] == 0) | df["exp_ins_adjusted"].isna(),
            df["ln_instruct_fte"],
            np.log(df["exp_ins_adjusted"] / df["fteug"])
        )
        df["ln_stcollage2"] = np.log(df["stcollage2"])
        df["stbaabove_p"] = df["stbaabove"] / df["pop"] * 100
        df["ln_stinccap"] = df["lnincome"] - np.log(df["pop"])

        df["stunemprate"] = np.round(
            df["stunemp"] / df["stlabforce"] * 100,
            1
        )

        for r in ["black", "hisp", "amind"]:
            df[f"stcoll2_{r}_p"] = np.where(
                df[f"st{r}"] == 0, 0,
                df[f"stcoll2_{r}"] / df[f"st{r}"] * 100
            )
        
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `dofile.do`: ###
        # use "new_data.dta", clear
        # ...
        # local covariates "ln_tuition2 ln_fteug ln_instruct_fte ln_stinccap stunemprate stbaabove_p ln_stcollage2 stcoll2_black_p stcoll2_hisp_p stcoll2_amind_p"
        # ...
        #--- fund-totalrevenue
        # eststo:reghdfe ln_total_adj local_pct `covariates', absorb(unitid year) cl(unitid)
        #--- fund-ruralrevenue
        # eststo:reghdfe ln_total_adj local_pct `covariates' if rural == 1, absorb(unitid year) cl(unitid)
        ###
        sensitivities = {
            ### ln_fteug: full-time equivalent undergraduate enrollment (logged)
            # NOTE: reconstruct ln_fteug = log(fteug)
            "fteug": {
                "sensitivity": lambda state: 1,
                "lb": 1
            },

            ### ln_instruct_fte: instructional expenditures per full-time equivalent student (logged)
            # NOTE: reconstructing ln_instruct_fte = log(instruct_fte)
            # assuming instruct_fte = exp_ins_adjusted / fteug
            # NOTE inter var exp_ins_adjusted = instruct_fte * fteug
            # exp_ins_adjusted not personal
            # fteug already noised

            ### ln_stcollage2: log of State college-age_2 population (age 18-25, HS diploma)
            # NOTE reconstructing ln_stcollage2 = log(stcollage2)
            "stcollage2": lambda state: 1,

            ### stbaabove_p: percentage of adults with a bachelor’s degree or higher
            # assuming stbaabove_p = stbaabove / pop * 100
            # NOTE creating inter var pop = stbaabove / stbaabove_p * 100
            "stbaabove": lambda state: 1,
            "pop": {
                "sensitivity": lambda state: 1,
                "lb": 1
            },

            ### ln_stinccap: state income per capita (logged)
            # assuming ln_stinccap = log(income) - log(pop)
            # NOTE creating inter var ln_income = ln_stinccap + log(pop)
            # income not personal
            # pop already noised

            ### stunemprate: unemployment rate
            # NOTE reconstructing stunemprate = stunemp / stlabforce * 100
            "stunemp": lambda state: 1,
            "stlabforce": {
                "sensitivity": lambda state: 1,
                "lb": 1
            },
            # pop already noised

            ### College-aged population by race
            # NOTE reconstructing stcoll2_*_p = stcoll2_* / st* * 100
            ## stcoll2_black_p: State college-age_2 Black population
            "stblack": {
                "sensitivity": lambda state: 1,
                "lb": 1
            },
            "stcoll2_black": lambda state: 1,
            ## stcoll2_hisp_p:  State college-age_2 Hispanic population
            "sthisp": {
                "sensitivity": lambda state: 1,
                "lb": 1
            },
            "stcoll2_hisp": lambda state: 1,
            ## stcoll2_amind_p: State college-age_2 Asian/Pacific Islander population
            "stamind": {
                "sensitivity": lambda state: 1,
                "lb": 1
            },
            "stcoll2_amind": lambda state: 1,

            # (not personal) ln_total_adj: total institutional revenue
            # (not personal) local_pct: colleges’ level of reliance on local funding 
            # (not personal) ln_tuition2: tuition (logged)
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="fund-totalrevenue",
            table=table,
            row="local_pct",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="fund-ruralrevenue",
            table=table,
            row="local_pct",
            col="est2",
            expected_range=(None, 0)
        ))
        return results