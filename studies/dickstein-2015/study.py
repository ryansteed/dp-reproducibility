from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Dickstein(Study):
    id = 'dickstein-2015'

    def data_paths(self) -> dict:
        return {
            "county_data_P-P": os.path.join(
                self.path(), "source/Logs-and-do-files", "county_data_P-P.dta"
            ),
            "region_data": os.path.join(
                self.path(), "source/Logs-and-do-files", "region_data.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        for key in data.keys():
            df = data[key].copy()
            if key.startswith("county"):
                df["persons1864yrs2010_n"] = df["persons1864yrs2010"] * 1000
                df["old"] = df["persons1864yrs2010_n"] * df["relold"]
            elif key.startswith("region"):
                df["pop"] = np.exp(df["logPop"]) * 1000
                df["old"] = df["pop"] * df["relold"]
                df["Urban_n"] = df["Urban"] * df["pop"]
            data[key] = df
        return data
    
    def _post_processing(self, noised_data):
        for key in noised_data.keys():
            df = noised_data[key].copy()
            if key.startswith("county"):
                df["persons1864yrs2010"] = df["persons1864yrs2010_n"] / 1000
                df["relold"] = df["old"] / df["persons1864yrs2010_n"]
                ## Gr
                # rest_pop_75 = df["RestPop"].quantile(0.75, interpolation="midpoint")
                # rest_urb_75 = df["RestUrb"].quantile(0.75, interpolation="midpoint")
                # # had to tweak these to match; stata operates slightly differently?
                # rest_pop_50 = df["RestPop"].quantile(0.50, interpolation="midpoint")
                # rest_urb_50 = df["RestUrb"].quantile(0.50, interpolation="midpoint")
                # df["Gr"] = np.where(
                #     df["Gr"].isna(), np.nan,
                #     np.where(
                #         (df["RestPop"] > rest_pop_75) & 
                #         (df["RestUrb"] > rest_urb_75),
                #         2,
                #         np.where(
                #             (df["RestPop"] <= rest_pop_50) &
                #             (df["RestUrb"] <= rest_urb_50), 
                #             0,
                #             1
                #         )
                #     )
                # )
            elif key.startswith("region"):
                df["logPop"] = np.log(df["pop"] / 1000)
                df["relold"] = df["old"] / df["pop"]
                df["Urban"] = df["Urban_n"] / df["pop"]
                df["Urbsq"] = df["Urban"] ** 2
            noised_data[key] = df
        return noised_data

    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `county_tables_main.do`, `region_do.do`: ###

        ## County est2, est4
        # areg SP51 i.Gr ded  Median Inc_25k_100k  GAF relold   smallem    hosp, a(state) cl(region_post)
        # ...
        # areg Nins i.Gr  Median    Inc_25k_100k  GAF relold   smallem    hosp, a(state) cl(region_post)
        
        ## Region est2, est4
        # areg Nins logPop landArea Urban Urbsq Median  Inc_25k_100k  GAF  relold smallfirm hosps, a(state) rob cl(state)
        # ...
        # areg Price logPop landArea Urban Urbsq ded Median  Inc_25k_100k  GAF  relold smallfirm hosps, a(state) rob cl(state)
        ###
        vars_to_noise = {
            #--- county_data_P-P
            ### Median: Median HH income ($1,000)
            # NOTE: assuming max household income 500,000
            "Median": lambda county: 500/2,

            ### Inc_25k_100k: % of HH with income between $25k and $100k
            # NOTE: # of HHs not provided, not enough info for DP

            ### relold: Fraction of 18-64 year-old population aged 40-64
            # persons1864yrs2010: County Population 18-64 (1,000)
            # NOTE: created var persons1864yrs2010_n = persons1864yrs2010 * 1000
            # relold = old / persons1864yrs2010_n
            # NOTE: created var old = persons1864yrs2010_n * relold
            "old": lambda county: 1,
            "persons1864yrs2010_n": {
                "sensitivity": lambda county: 1,
                "lb": 1
            },

            ### smallem: % Working for Small Employer
            # NOTE: not noised, we don't know # employees

            ### Gr: How premium is grouped
            # Control (0): rest of region pop and rest of region urban share below 50%
            # Bundled (2): rest of region pop and rest of region urban share above 75%
            # Intermediate (1): everything else
            # RestPop: rest of region population
            # RestUrb: rest of region % urban share
            # NOTE: could not noise; not constructed, could not reconstruct

            ### [not personal] GAF: Medicare Geographic Adjustment Factor
            ### [not personal] SP51: Yearly Price (premium of benchmark silver plan)
            ### [not personal] ded: Deductible of the second lowest priced silver plan
            ### [not personal] state: state dummy
            ### [not personal] region_post: group(region state)
            ### [not personal] hosps: Number Short Term General Hositals
            ### [not personal] Nins: N. insurers

            #--- region_data
            ### logPop: Log Population
            # assuming population in thousands as in totpop1864 from county file; see summary stats
            # NOTE: created var pop = exp(logPop) * 1000
            "pop": lambda region: 1,

            ### Urban: Proportion population Urban
            # NOTE: created var Urban_n = Urban * pop
            "Urban_n": lambda region: 1,
            
            ### Urbsq: Urban squared
            # NOTE: reconstructed from Urban

            ### MedianIncome: Median income (1000's)
            # NOTE: same as median
            # NOTE: assuming max household income 500,000
            "MedianIncome": lambda county: 500/2,

            ### Inc_25k_100k: same as above
            
            ### relold: same as above

            ### smallfirm: Proportion of employees in small establishments
            # NOTE: not noised, we don't know # employees
            
            ### [not personal] Nins: Number of insurers
            ### [not personal] GAF: same as above
            ### [not personal] landArea: land area in 100s of square miles
            ### [not personal] hosps: same as above
            ### [not personal] state: same as above
            ### [not personal] Price: Annual Premium of Benchmark Plan
            ### [not personal] deductible: Deductible of Benchmark Plan
        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return [
            # "Median", # not noised
            # "MedianIncome", # not noised
            # "Inc_25k_100k", # not noised
            "relold",
            # "smallem", # not noised
            # "Gr",
            "logPop",
            "Urban",
            "Urbsq",
            # "smallfirm" # not noised
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/county.csv")
        results.append(Result.from_esttab(
            id="bundle-insurer",
            table=table,
            row="2.Gr",
            col="est4",
            expected_range=(0,None)
        ))
        results.append(Result.from_esttab(
            id="bundle-premium",
            table=table,
            row="2.Gr",
            col="est2",
            expected_range=(None, 0)
        ))

        table = self._load_esttab(f"{self.path()}/results/region.csv")
        results.append(Result.from_esttab(
            id="population-insurer",
            table=table,
            row="logPop",
            col="est2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="population-premium",
            table=table,
            row="logPop",
            col="est4",
            expected_range=(None, 0)
        ))
        return results