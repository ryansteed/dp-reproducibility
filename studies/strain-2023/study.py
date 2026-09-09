from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Strain(Study):
    id = 'strain-2023'

    def data_paths(self) -> dict:
        return {
            "aggregate-analysis": os.path.join(
                self.path(), "source", "ICPSR replication package v3", "Economic Inquiry Replication", "data","proc", "aggregate-analysis.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["aggregate-analysis"]

        # deconstructing lnnewcases
        df["newcases"] = np.exp(df["lnnewcases"])

        data["aggregate-analysis"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["aggregate-analysis"]

        # reconstructing epop_cps_2554
        df["epop_cps_2554"] = df["totemp_2554"] / df["statepop_2554"] * 100
        # reconstructing ur_cps_2554
        df["totlabforce_2554"] = df["totemp_2554"] + df["totunemp_2554"]
        df["ur_cps_2554"] = df["totunemp_2554"] / df["totlabforce_2554"] * 100
        # reconstructing lnnewcases
        df["lnnewcases"] = np.log(df["newcases"])

        noised_data["aggregate-analysis"] = df
        return noised_data
    
    def vars_to_noise(self):
        return [
            "statepop_2554",
            "epop_cps_2554",
            "ur_cps_2554",
            "lnnewcases",
        ]
    
    def other_vars(self):
        return [
            "stringencyindex",
            # "baseyear2019", # generated from year
            "endfpucandpua",
            "endonlyfpuc",
            # "post", # generated from month
            "year",
            "month"
        ]
    
    def time_index(self):
        return None # year, month included separately in authors' reg; will do the same
    
    def subset_index(self):
        return "statefip"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `07-table-3.do`: ###
        # use "$wrkdir/aggregate-analysis.dta", clear
        # ...
        #--- fpucandpua-emp
        # local agelist 2554 1664 16plus
        # *** Table 3 Panel A: CPS EPOP END BOTH PUA AND PUA OR ONLY FPUC SEPARATELY
        # foreach age of local agelist {
        #     ...
        #     eststo: reghdfe epop_cps_`age' i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=statepop_`age'], absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip) cluster(statefip)
        # }
        # ...
        #--- fpucandpua-unemp
        # *** Table 3 Panel B: CPS UR END BOTH PUA AND PUA OR ONLY FPUC SEPARATELY
        # foreach age of local agelist {
        #     ...
        #     eststo:reghdfe ur_cps_`age' i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases [aw=statepop_`age'] if inrange(date,733,739), absorb(i.statefip i.month) cluster(statefip)
        #     ...
        # }
        ###
        vars_to_noise = {
            ### statepop_2554: State Population Ages 25-54
            # constructed in `02-clean-aggregate-data.do`, but we are skipping that file
            "statepop_2554": {
                "sensitivity": lambda statemonth: 1,
                "lb": 1 # used for weights
            },

            #--- fpucandpua-emp
            ### epop_cps_2554: EPOP CPS Ages 25-54
            # EPOP: state employment population ratio
            # based on `02-clean-aggregate-data.do` (skipped),
            # NOTE: reconstructed epop_cps_2554 = totemp_2554 / statepop_2554
            # already noised statepop_2554
            "totemp_2554": lambda statemonth: 1,
            #---

            #--- fpucandpua-unemp
            ### ur_cps_2554: UR CPS Ages 25-54
            # UR: state unemployment rate
            # based on `02-clean-aggregate-data.do` (skipped),
            # NOTE: reconstructed totlabforce_2554 = totemp_2554 + totunemp_2554
            # NOTE: reconstructed ur_cps_2554 = totunemp_2554 / totlabforce_2554
            # already noised totemp_2554
            "totunemp_2554": lambda statemonth: 1,

            ### lnnewcases: Ln New Monthly State Covid-19 Cases
            # NOTE: assuming a person can get COVID at most twice per month
            # NOTE: created new var newcasese = exp(lnnewcases)
            "newcases": {
                "sensitivity": lambda statemonth: 2,
                "lb": 1
            }
            #---

            ### [not personal] stringencyindex: Mean Monthly Stringency Index
            # stringency of covid restrictions
            ### [not personal] baseyear2019: dummy
            ### [not personal] endfpucandpua: State Ended Both FPUC and PUA in June 2021
            ### [not personal] endonlyfpuc: State Ended Only FPUC in June 2021
            ### [not personal] post
            # gen post =.
            # replace post = 0 if inrange(month,2,6)
            # replace post = 1 if inrange(month,7,8)
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table1= self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="fpucandpua-emp",
            table=table1,
            row="1.endfpucandpua#1.baseyear2019#1.post",
            col="est3",
            expected_range=(0, None)
        ))
        table2= self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="fpucandpua-unemp",
            table=table2,
            row="1.endfpucandpua#1.post",
            col="est2",
            expected_range=(None, 0)
        ))
        return results