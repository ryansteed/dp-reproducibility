from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Fisman(Study):
    id = 'fisman-2017'

    def data_paths(self) -> dict:
        return {
            "data_aej": os.path.join(
                self.path(), "source", "APP2016-0008_data", "data_aej.dta"
            ),
            # "gdptarget": os.path.join(
            #     self.path(), "source", "APP2016-0008_data", "gdptarget.dta"
            # ),
            "final1": os.path.join(
                self.path(), "source","APP2016-0008_data", "final1.dta"
            ), # created by us; including for monitoring
            "final2": os.path.join(
                self.path(), "source", "APP2016-0008_data", "final2.dta"
            ) # created by us; including for monitoring
        }
    
    def vars_to_noise(self):
        return {
            "post_replication": [
                "exceedquota",
                "ln_reported_lag",
                "exceedquota_lag",
                "ln_reported_exceedquota_x_lag"
            ]
        }

    _industries = [
        "all", "agriculture", "coal", "fire", "imct",
        "railway", "severeaccidents", "transportation"
    ]

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `deaths_aejfinal.do`: ###
        # save deathquota_short.dta, replace
        # ...
        #-- nsnp-dc
        # use deathquota_short.dta, clear
        # ...
        # foreach var in exceedquota {
        # ...
	    # xi: areg `var' post gdpprogress_ratio i.year i.industry if quarter==4 & var_post>0, absorb(province) cluster(province)
	    # eststo t2_`var'_3
        # ...
        # }
        # ...
        #-- lnceil-dgc
        # use deathquota_short,replace
        # ...
        # xi: areg ln_quota_amt ln_reported_lag ln_quota_amt_1lag exceedquota_lag ln_reported_exceedquota_x_lag i.yi i.py, absorb(provinceind) cluster(province)
        # eststo t3_4
        
        sensitivities = {
            #-- nsnp-dc
            ### exceedquota: whether death ceiling is exceeded
            #> from `deaths_aejfinal.do`:
            #> global industries "all agriculture coal fire imct railway severeaccidents transportation"
            #> reshape long quota reported ,i(province date) j(industry) string
            #> g qrate=reported/quota
            #> g exceedquota=qrate>1 if qrate~=. & quarter==4
            ## reported*: the # of realized deaths (cumulative)	
            **{f"reported{ind}": lambda province: 1 for ind in self._industries},
            #--

            #-- lnceil-dgc
            ### ln_reported_lag: lagged log of reported deaths
            #> g ln_reported=log(reported)
            #> ...
            #> g ln_reported_lag=l.ln_reported
            # reported noised above

            ### exceedquota_lag: exceedquota lagged
            #> gen exceedquota_lag = (l.qrate)>1 if l.qrate~=.
            # qrate (reported, quota) noised above

            ### ln_reported_exceedquota_x_lag 
            #> gen ln_reported_exceedquota_x_lag = exceedquota_lag * ln_reported_lag
            # ln_reported_lag, exceedquota_lag noised above

            #--
            ### [not personal] ln_quota_amt_1lag
            #> gen ln_quota_amt_1lag = l.ln_quota_amt
            ### [not personal] quota*: safety target for deaths
            ### [not personal] ln_quota_amt
            #> g quota_amt=quota if property_quota~="percentage" 
            #> ...
            #> g ln_quota_amt=log(quota_amt)
            ### [not personal] gdpprogress_ratio: the ratio of actual to targeted (real) GDP
            ### [not personal] post
            #> g post=year>effective_year
            ### [not personal] year: year index
            ### [not personal] industry: industry index
            ### [not personal] quarter: quarter index
            ### [not personal] province, provinceind: province index
            ### [not personal] yi: year-industry index
            ### [not personal] py: province-year index
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table.csv")
        results.append(Result.from_esttab(
            id="nsnp-dc",
            table=table,
            row="post",
            col="t2_exceedquota_3",
            expected_range=(None, 0)
        ))
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="lnceil-dgc",
            table=table1,
            row="ln_reported_exceedquota_x_lag",
            col="t3_4",
            expected_range=(0, 0)
        ))
        return results