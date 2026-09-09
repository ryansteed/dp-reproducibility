from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Guidetti(Study):
    id = 'guidetti-2021'

    def data_paths(self):
        return {
            "main_data": os.path.join(self.path(), "source", "main_data.dta")
        }

    def _pre_processing(self, data: pd.DataFrame) -> pd.DataFrame:
        for var in [
            "hrate_resp",
            "hrate_asthma",
            "hrate_pneu",
            "hrate_influ",
            "hrate_append",
            "hrate_epilep",
            "hrate_phimo",
            "hrate_bonefrac"
        ]:
            data["main_data"][f"count_{var}"] = data["main_data"][var] * data["main_data"]["population"] / 1e6
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        for var in [
            "hrate_resp",
            "hrate_asthma",
            "hrate_pneu",
            "hrate_influ",
            "hrate_append",
            "hrate_epilep",
            "hrate_phimo",
            "hrate_bonefrac"
        ]:
            noised_data["main_data"][var] = noised_data["main_data"][f"count_{var}"] / noised_data["main_data"]["population"] * 1e6
                
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "hrate_resp",
            "hrate_asthma",
            "hrate_pneu",
            "hrate_influ",
            "hrate_append",
            "hrate_epilep",
            "hrate_phimo",
            "hrate_bonefrac",
            "population" # will throw error b/c of rounding for high enough epsilon
        ]
    
    def other_vars(self) -> list:
        return [
            "pm",
            "ws",
            "ws_1",
            "dow",
            "month",
            "year",
            "temp",
            "humid",
            "temp2",
            "temphumid"
        ]
    
    def time_index(self) -> str:
        return "date"
    
    def subset_index(self):
        return "district"

    def sensitivity_matrix(self) -> dict:
        ### regression code from `reg.do`:  
        # global controls temp humid temp2 humid2 temphumid
        # ...
        # **2SLS
        # *Respiratory
        # foreach disease in resp asthma pneu influ { 
        # eststo: ivreghdfe hrate_`disease' ${controls} (pm = ws ws_1) [w = population], absorb(district dow month year) cluster(district date) 
        # estadd ysumm  
        # }
        # ...
        # *Others
        # foreach disease in epilep phimo append bonefrac{ 
        # eststo: ivreghdfe hrate_`disease' ${controls} (pm = ws ws_1) [w = population], absorb(district dow month year) cluster(district date) 
        # estadd ysumm  
        # }
        ###
        vars_to_noise = {
            ### hrate_* is the hospitalization rate caused by * per 1M children ###
            # hrate_* = count_hrate_* / population x 1M
            # CREATED INTER VARS count_hrate_* = hrate_* x population / 1M
            # now add noise to those plus population
            ## hrate_resp
            "count_hrate_resp": lambda district: 1,
            ## hrate_asthma
            "count_hrate_asthma": lambda district: 1,
            ## hrate_pneu
            "count_hrate_pneu": lambda district: 1,
            ## hrate_influ
            "count_hrate_influ": lambda district: 1,
            ## hrate_append
            "count_hrate_append": lambda district: 1,
            ## hrate_epilep
            "count_hrate_epilep": lambda district: 1,
            ## hrate_phimo
            "count_hrate_phimo": lambda district: 1,
            ## hrate_bonefrac
            "count_hrate_bonefrac": lambda district: 1,
            
            ### population ###
            "population": {
                "sensitivity": lambda district: 1,
                "lb": 1,
                "integer": True
            }
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table1a = self._load_esttab(f"{self.path()}/results/table1a.csv")
        results.append(Result.from_esttab(
            id="pm10-resp",
            table=table1a,
            row="pm",
            col="est1",
            expected_range=(0, None)  # should be positive, significant
        ))
        table1b = self._load_esttab(f"{self.path()}/results/table1b.csv")
        results.append(Result.from_esttab(
            id="pm10-epilepsy",
            table=table1b,
            row="pm",
            col="est1",
            expected_range=(None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="pm10-phimosis",
            table=table1b,
            row="pm",
            col="est2",
            expected_range=(None, 0)  # should be negative, significant
        ))
        results.append(Result.from_esttab(
            id="pm10-appendicitis",
            table=table1b,
            row="pm",
            col="est3",
            expected_range=(0, 0)  # should be insignificant
        ))
        results.append(Result.from_esttab(
            id="pm10-fracture",
            table=table1b,
            row="pm",
            col="est4",
            expected_range=(0, 0)  # should be insignificant
        ))
        return results
