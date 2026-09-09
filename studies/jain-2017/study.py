from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Jain(Study):
    id = 'jain-2017'

    def data_paths(self) -> dict:
        return {
            "Common_tongue": os.path.join(
                self.path(), "source", "Common_tongue.dta"
            ),
            "final": os.path.join(
                self.path(), "source", "final.dta"
            ) # created by us, for monitoring
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["Common_tongue"]

        # deconstructing MinorityFraction
        df["tongue_diff"] = df["MinorityFraction"] * df["record1_100"]
        
        data["Common_tongue"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["Common_tongue"]

        # reconstructing switcher
        df["MinorityFraction"] = np.where(
            df["tongue_diff"].isna(),   
            df["MinorityFraction"],
            df["tongue_diff"] / df["record1_100"]
        )
        df["switcher"] = np.where(
            # impute two seeming errors in original coding...
            df["MinorityFraction"].isna() | np.isclose(df["MinorityFraction"], 0.051532) | np.isclose(df["MinorityFraction"], 0.438300),
            df["switcher"],
            (df["MinorityFraction"] >= 0).astype(int)
        )
        
        noised_data["Common_tongue"] = df
        return noised_data
    
    def vars_to_noise(self) -> dict:
        return {
            "pre_replication": [
                "switcher"
            ],
            "post_replication": [
                "Total_pop",
                "Rural_pop",
                "Literates_5_plus",
                "SC",
                "ST",
                "Literates_5_plus_rural",
                "SC_rural",
                "ST_rural",
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Common_tongue_do.do`: ###
        # use Common_tongue.dta, clear
        # ...
        # eststo: xi: reg Literates_5_plus switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid)
        # eststo: xi: reg Literates_5_plus_rural switcher SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid) 
        # eststo: xi: reg Middle_school switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid)
        # eststo: xi: reg Middle_school_rural switcher SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid) 
        ###
        sensitivities = {
            ### Total_pop: Log total population
            # from Common_tongue_do.do (run):
            # gen Total_pop = ln(record1_100)
            # record1_100: Total population
            "record1_100": lambda district: 1,

            ### switcher: Majority and minority district identifier
            # whether majority language does not match official province language
            # switcher = MinorityFraction > 0
            # MinorityFraction = (MotherTongue - OfficialLang) / Total Pop
            # record1_100: Total population
            # NOTE: created var tongue_diff = MinorityFraction * record1_100
            # record1_100 already noised
            "tongue_diff": lambda district: 2,

            ### Rural_pop: Log Total rural population
            # from Common_tongue_do.do (run):
            # gen Rural_pop = ln(record2_100)
            # record2_100: Rural population
            "record2_100": lambda district: 1,

            #--- total-lit
            ### Literates_5_plus: Log Literates (Age 5+) population/Total population
            # from Common_tongue_do.do (run):
            # gen Literates_5_plus = ln(record1_140/record1_100)
            # record1_100 already noised
            "record1_140": lambda district: 1,

            ### SC: SC Population/Total population  
            # from Common_tongue_do.do (run):
            # gen SC = record1_200/record1_100
            # record1_100 already noised
            "record1_200": lambda district: 1,

            ### ST: ST Population/Total population
            # from Common_tongue_do.do (run):
            # gen ST = record1_250/record1_100
            # record1_100 already noised
            "record1_250": lambda district: 1,
            #---

            #--- rural-lit
            ### Literates_5_plus_rural: Log Rural Literates (Age 5+) population/Total rural population
            # from Common_tongue_do.do (run):
            # gen Literates_5_plus_rural = ln(record2_140/record2_100)
            # record2_100 already noised
            "record2_140": lambda district: 1,

            ### SC_rural: SC Rural Population/Total rural population
            # from Common_tongue_do.do (run):
            # gen SC_rural = record2_200/record2_100
            # record2_100 already noised
            "record2_200": lambda district: 1,

            ### ST_rural: ST Rural Population/Total rural population
            # from Common_tongue_do.do (run):
            # gen ST_rural = record2_250/record2_100
            # record2_100 already noised
            "record2_250": lambda district: 1,
            #---

            ### [not personal] coastal: Dummy for coastal districts
            ### [not personal] british: Dummy for direct british rule districts
            ### [not personal] forest_land: Forest land
            ### [not personal] wasteland: Waste land
            ### [not personal] altitude: Elevation of district HQ (in 1000 ft)
            ### [not personal] latitude: Latitude
            ### [not personal] longitude: Longitude
            ### [not personal] rainfall_july_mean
            ### [not personal] rainfall_jan_mean
            ### [not personal] rainfall_july_sd
            ### [not personal] rainfall_jan_sd
            ### [not personal] aligned: Aligned with center
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table.csv")
        results.append(Result.from_esttab(
            id="total-lit",
            table=table,
            row="switcher",
            col="est1",
            expected_range=Result.relative_range(np.log(1-0.18), 0.2, ub=0) # 1-exp(est) = 0.18 => exp(est) = 1-0.18 => est = log(1-0.18)
        ))
        results.append(Result.from_esttab(
            id="rural-lit",
            table=table,
            row="switcher",
            col="est2",
            expected_range=Result.relative_range(np.log(1-0.201), 0.2, ub=0) # 1-exp(est) = 0.18 => exp(est) = 1-0.18 => est = log(1-0.18)
        ))
        return results