from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Guzman(Study):
    id = 'guzman-2022'

    def data_paths(self) -> dict:
        return {
            "Master_data_covid_EHI": os.path.join(
                self.path(), "source/CovidAndEthnicDivision_Replication", "Master_data_covid_EHI.dta"
            )
            # ...
        }
    
    def _post_processing(self, noised_data):
        df = noised_data["Master_data_covid_EHI"]

        # df["EHI"] = 0.0
        # ethraces = [
        #     "hisp",
        #     "white",
        #     "black",
        #     "native",
        #     "asian",
        #     "pacisl",
        #     "other",
        #     # "twoormoreraces"
        #     # "hispanicorlatinoofanyrace",
        #     # "whitealone",
        #     # "blackorafricanamericanalone",
        #     # "americanindianandalaskanativealo",
        #     # "asianalone",
        #     # "nativehawaiianandotherpacificisl",
        #     # "someotherracealone"
        # ]
        # for ethrace in ethraces:
        #     df["EHI"] += np.power(df[ethrace], 2)
        # df["EHI"] = 1 - df["EHI"] / np.power(df["totalpopulation"]-df["twoormoreraces"], 2)

        noised_data["Master_data_covid_EHI"] = df
        return noised_data
    
    def stata_version(self):
        return 118
    
    def vars_to_noise(self):
        return [
            "var_case",
            "death",
            # "EHI",
            # "seg_index"
        ]
    
    def other_vars(self) -> Dict[str, str]:
        return [
            "EHI",
            "seg_index",
            "national_lockdown",
            "county_lockdown",
            "stringencyindex",
            "safer_home",
            "istate"
        ]
    
    def time_index(self) -> str:
        return "date2"
    
    def subset_index(self) -> str:
        return "fips"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Create_tables_CovidEthnicDivision.do`: ###
        ## reg5_case_P2, reg5_death_P2
        # use Master_data_covid_EHI.dta, clear
        # ...
        # rename national_lockdown P1
        # rename county_lockdown P2
        # rename stringencyindex P3
        # rename safer_home P4
        # rename business_close P5
        # ...
        # foreach index of varlist  EHI {
        # foreach y of varlist  case death case1 death1 {
        # foreach policy of varlist  P1 P2 P4 P5 {
        # ...
        # eststo reg5_`y'_`policy': reghdfe `y'  i.`policy'##c.`index', absorb(fips date2) cluster(istate)
        # ...

        ## reg5_case_1_medianw_P2, reg5_death_1_medianw_P2, reg5_case_2_medianw_P2, reg5_death_2_medianw_P2
        # use Master_data_covid_EHI.dta, clear
        # ...
        # foreach index of varlist  EHI {
        # foreach median of varlist  medianw median_bw {
        # foreach x of numlist  1(1)2 {
        # foreach y of varlist  case death case1 death1  {
        # foreach policy of varlist  P1 P2 P4 P5 {
        # reg5_`y'_`x'_`median'_`policy': reghdfe `y'  i.`policy'##c.`index' if `median'==`x', absorb(fips date2) cluster(istate)
        # ...

        ###
        vars_to_noise = {
            #-- Master_data_covid_EHI.dta
            ### case: Cumulative covid cases per county-day
            # rename case case1
            # gen case=case1/pop*100000
            "pop": {
                "sensitivity": lambda county: 1,
                "lb": 1
            },
            "var_case": lambda county: 1, # using _case b/c case is reserved word; edited authors code to rename before running

            ### death: Cumulative covid deaths per county-day
            # rename death death1
            # gen death=death1/pop*100000
            "death": lambda county: 1,

            ### EHI: EFI (county-level ethnic diversity)
            # "This index measures the probability that two randomly selected individuals from the same county belong to two different ethnic groups."
            # should be 1 - HHI
            # NOTE: could not noise; my construction is slightly off

            ### seg_index: White/non-white Segr. index
            # xtile medianw = seg_index, nq(2)
            # special index computed from evenness of distribution in a given census tract
            # NOTE: not enough info about construction for DP sensitivity
            
            ### [not personal] fips: fips dummy
            ### [not personal]  date2: date dummy
            ### [not personal]  istate: state dummy
            ### [not personal] county_lockdown: County emergency declaration dummy
            # rename county_lockdown P2
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="edi-covidcase",
            table=table,
            row="1.P2#c.EHI",
            col="reg5_case_P2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="edi-coviddeath",
            table=table,
            row="1.P2#c.EHI",
            col="reg5_death_P2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="edi_bmediancase",
            table=table,
            row="1.P2#c.EHI",
            col="reg5_case_1_medianw_P2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="edi_bmediandeath",
            table=table,
            row="1.P2#c.EHI",
            col="reg5_death_1_medianw_P2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="edi_amediancase",
            table=table,
            row="1.P2#c.EHI",
            col="reg5_case_2_medianw_P2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="edi_amediandeath",
            table=table,
            row="1.P2#c.EHI",
            col="reg5_death_2_medianw_P2",
            expected_range=(0, None)
        ))
        return results