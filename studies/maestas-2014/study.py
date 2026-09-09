from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Maestas(Study):
    id = 'maestas-2014'

    def data_paths(self) -> dict:
        return {
            "MA_state_data": os.path.join(
                self.path(), "source/P2014_1138_data", "MA_state_data.dta"
            ),
            "MA_county_data": os.path.join(
                self.path(), "source/P2014_1138_data", "MA_county_data.dta"
            )
            # ...
        }

    def _pre_processing(self, data):
        for key in data.keys():
            df = data[key]
            # deconstruct app vars
            apps_vars = ["allapps", "DIonly", "SSItotal", "SSDItotal"]
            for v in apps_vars:
                df[f"{v}_total"] = df[v] * df["wapop"] / 1000
            # deconstruct ue
            df["unemployed"] = df["ue"] * df["wapop"] / 100
            data[key] = df
        return data
    
    def _post_processing(self, noised_data):
        for key in noised_data.keys():
            df = noised_data[key]
            # reconstruct app vars
            apps_vars = ["allapps", "DIonly", "SSItotal", "SSDItotal"]
            for v in apps_vars:
                df[f"{v}_total"] = np.clip(df[f"{v}_total"], 0, df["wapop"])
                df[v] = df[f"{v}_total"] / df["wapop"] * 1000
            # reconstruct UE
            df["unemployed"] = np.clip(df["unemployed"], 0, df["wapop"])
            df["ue"] = df["unemployed"] / df["wapop"] * 100
            noised_data[key] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `MMS_MA_analysis.do`: ###
        ## Table 0
        # use MA_state_data.dta, clear
        # ...
        # eststo m_allapps: reg allapps MAXpost* post* ue stnum1 stnum3-stnum9 i.qnum [aw=wapop], cluster(state)

        ## Table 2
        # use MA_county_data.dta, clear
        # ...
        # foreach var of varlist allapps DIonly SSItotal SSDItotal {
        #     eststo m2_`var': reg `var' MAX* post* ue qnum* i.county [aw=wapop] if lowHI==1, cluster(state)
        #     * outreg2 MAX* using countyresults.txt, append
        # }

        ## Table 3
        # use MA_county_data.dta, clear
        # ...
        # foreach var of varlist allapps DIonly SSItotal SSDItotal {
        #     eststo m3_`var': reg `var' MAX* post* ue qnum* i.county [aw=wapop] if lowHI==0, cluster(state)
        #     outreg2 MAX* using countyresults.txt, append	
        # }
        ###
        vars_to_noise = {
            #--- MA_state_data
            ### wapop: working age population
            "wapop": {
                "sensitivity": lambda statecounty: 1,
                "lb": 1  # weighting var
            },

            ### allapps: Applications per 1000 working age residents
            # allapps = allapps_total / wapop * 1000
            # NOTE: created var allapps_total = allapps * wapop / 1000
            "allapps_total": lambda statecounty: 1,

            ### ue: local unemployment rate * 100
            # ue = unemployed / wapop * 100
            # NOTE: created var unemployed = ue * wapop / 100
            # wapop already noised
            "unemployed": lambda statecounty: 1,

            # [not personal] MAXpost*: dummy
            # [not personal] post*: dummy
            # [not personal] stnum*: dummy
            # [not personal] qnum: dummy
            # [not personal] state: dummy
            
            #--- MA_county_data
            ### allapps: same as above

            ### DIonly: DI applications per 1000 working age residents
            # NOTE: created var DIonly_total = DIonly * wapop / 1000
            "DIonly_total": {
                "sensitivity": lambda statecounty: 1,
                "lb": 1  # each county needs at least one
            },
            
            ### SSItotal: SSI applications per 1000 working age residents
            # NOTE: created var SSItotal = SSIonly * wapop / 1000
            "SSItotal_total": lambda statecounty: 1,
            
            ### SSDItotal: SSDI applications per 1000 working age residents
            # NOTE: created var SSDItotal = SSDIonly * wapop / 1000
            "SSDItotal_total": lambda statecounty: 1,

            ### ue: same as above

            ### wapop: same as above

            ### lowHI: health insurance coverage rate < 88%
            # gen lowHI=(nohi05>=.12)
            # nohi05: no health insurance coverage in 2005
            # NOTE: cannot noise, don't know the county population
            
            # [not personal] MAX*: dummies
            # [not personal] post*: dummies
            # [not personal] qnum*: dummies
            # [not personal] county: dummy
            
        }
        return vars_to_noise

    def vars_to_noise(self):
        return [
            "wapop",
            "allapps",
            "ue",
            "DIonly",
            "SSItotal",
            "SSDItotal",
            # "lowHI" # not noised
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table0.csv")
        results.append(Result.from_esttab(
            id="reform-applicate2007",
            table=table,
            row="MAXpost1",
            col="m_allapps",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="reform-applicate2008",
            table=table,
            row="MAXpost2",
            col="m_allapps",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="reform-applicate2009",
            table=table,
            row="MAXpost3",
            col="m_allapps",
            expected_range=(0, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="reform-highcounty08",
            table=table,
            row="MAXpost2",
            col="m3_allapps",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="reform-lowcounty07",
            table=table,
            row="MAXpost1",
            col="m2_allapps",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="reform-lowcounty08",
            table=table,
            row="MAXpost2",
            col="m2_allapps",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="reform-lowssi07",
            table=table,
            row="MAXpost1",
            col="m2_SSItotal",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="reform-lowssi08",
            table=table,
            row="MAXpost2",
            col="m2_SSItotal",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="reform-lowssdi08",
            table=table,
            row="MAXpost2",
            col="m2_DIonly",
            expected_range=(0, None)
        ))
        return results