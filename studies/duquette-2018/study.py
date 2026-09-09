from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Duquette(Study):
    id = 'duquette-2018'

    def data_paths(self) -> dict:
        return {
            "state_year": os.path.join(
                self.path(), "source", "OpenICPSR","data","state_year.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["state_year"]

        # deconstructing lnpop
        df["pop"] = np.exp(df["lnpop"]) * 1000

        # deconstructing ln_c_styear
        df["c_styear"] = np.exp(df["ln_c_styear"]) * 1000 * df["pop"]

        # deconstructing lnrpcpi
        df["rpc"] = np.exp(df["lnrpcpi"]) * df["pop"]

        data["state_year"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["state_year"]
        
        # reconstructing lnpop
        df["lnpop"] = np.log(df["pop"] / 1000)

        # reconstructing popsh
        # popsh_old = df["popsh"].values
        # df["popsh"] = df.groupby("year")["pop"].transform(lambda x: x / x.sum())
        # df["popsh"] = np.where(
        #     (df["popsh"] != popsh_old) & np.isclose(df["popsh"], popsh_old, atol=1e-4, rtol=1e-2),
        #     popsh_old, # allow some small discrepancies due to floating point differences in control
        #     df["popsh"]
        # )

        # reconstructing ln_c_styear
        df["ln_c_styear"] = np.log(df["c_styear"] / 1000 / df["pop"])

        # reconstructing lnrpcpi
        df["lnrpcpi"] = np.log(df["rpc"] / df["pop"])
        
        noised_data["state_year"] = df
        return noised_data
    
    def other_vars(self) -> list[str]:
        return [
            "ln_sht01_frank",
            "lnur",
            "ln_gov",
            "ln_t01",
            "popsh",
            "lfs_irate_t01"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "stfips"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `reg_sy_total_ineq_tax.do`: ###
        # use "$data/state_year", clear
        # ...
        # lobal symacro "lnur  lnpop lnrpcpi ln_gov"  //lnrpcpi
        # global ln_income "ln_t01"
        # global ln_itax "lfs_irate_t01"
        # global ln_inequality "ln_sht01_frank"
        # ...
        # eststo A4: areg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income stfx isweighted [aw=popsh],  absorb(stfips) vce(cluster stfips)
        ###
        vars_to_noise = {
            ### lnpop: ln population (looks like in 1000s)
            # NOTE: created var pop = exp(lnpop)
            "pop": lambda stateyear: 1,

            ### ln_c_styear: ln inflation-adjusted total itemized contributions divided by state population
            # ln_c_styear = ln(c_styear / pop)
            # c_styear should be in the 100s of millions, so looks like it's in 1000s
            # NOTE: created var c_styear = exp(ln_c_styear) * 1000 * pop
            # NOTE: so let's assume income clipped at 500k; itemized contributions usually max 60%
            "c_styear": lambda stateyear: 500000 * 0.6,

            ### ln_sht01_frank: ln Frank’s state-level share of income to top 1%
            # NOTE: not enough info for DP; need total income

            ### lnur: ln unemployment rate
            # NOTE: labor force not available, not enough info for DP

            ### lnrpcpi: ln real per capita personal income
            # lnrpcpi = ln(rpc / pop)
            # NOTE: created var rpc = exp(lnrpcpi) * pop
            # NOTE: assuming personal income at most 500,000
            "rpc": lambda stateyear: 500000,

            ### ln_gov: ln share of total government employees
            # NOTE: labor force not available, not enough info for DP

            ### ln_t01: income of top 1% in that state-year in 2016 dollars
            # NOTE: not sure how to privatize; heavy tail, no reasonable upper bound. skipping.

            ### popsh: population share
            # by year: pop / pop.sum()
            # NOTE: could not reconsturct exactly, not noised

            ### [not personal] lfs_irate_t01: ln ordinary federal and state combined tax price of giving with ordinary income equal to the Top Income Cutoff

        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return [
            "lnpop",
            "ln_c_styear",
            # "ln_sht01_frank",
            # "lnur",
            "lnrpcpi",
            # "ln_gov",
            # "ln_t01",
            # "popsh",
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="ln_sht01_frank-ln_c_styear",
            table=table1,
            row="ln_sht01_frank",
            col="A4",
            expected_range=(None, 0)
        ))
        return results