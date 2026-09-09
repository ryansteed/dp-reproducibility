from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Weber(Study):
    id = 'weber-2025'

    def data_paths(self) -> dict:
        return {
            "FINAL_PANEL_AERAOpen": os.path.join(
                self.path(), "source", "FINAL_PANEL_AERAOpen.dta"
            ),
            "final": os.path.join(
                self.path(), "source", "final.dta"
            ), # created by us, monitoring only
        }
    
    def vars_to_noise(self) -> dict[str, list[str]]:
        # list all personal vars used in the regression
        return {
            "post_replication": ["cases_per_1000"]
        }
    
    def _pre_processing(self, data):
        return data
    
    def _post_processing(self, noised_data):
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `doFile1.do`: ###
        # use "FINAL_PANEL_AERAOpen.dta", clear
        # ...
        # eststo: reg share_virtual fundgap_1_bd i.StateEncode##c.cases_per_1000 if normCS_CWIFT <= 50 & normCS_CWIFT >= 4 & fundgap_1_n <= 50  & fundgap_1_n >= -50  & year == 2019, cluster(fips_code)
        
        
        ###
        sensitivities = {
            ### cases_per_1000: Covid Cases per 1000 (county-level)
            # //Covid cases changed to per 1,000
            # NOTE: assuming population is invariant
            # NOTE: assuming max five cases per person
            #> replace cases_per_100k = cases_per_100k*.01
            #> rename cases_per_100k cases_per_1000
            "cases_per_100k": lambda county: 5/100000,

            ### fundgap_1_bd: NECM Funding Gap/Surplus (estimate from model with race covariate)
            # NOTE: code for model preds not provided; can't privatize

            ### [not personal?] normCS_CWIFT: current spending
            ### [not personal] fundgap_1_n: NECM Funding Gap/Surplus (estimate from model with no race covariate)
            ### [not personal] StateEncode: StateEncode
            ### [not personal] share_virtual: percentage of time in virtual schooling
            # From paper: 
            # For our measures of time spent in various pandemic instructional modes, we use data from the COVID-19 Data Hub (COVID-19 School Data Hub, 2022). 
            # Instructional models are classified as in-person, hybrid, remote/virtual; the data measure the percentage of the 2020–2021 school year each district spent offering one of these three models. 
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="spend-virtual",
            table=table,
            row="fundgap_1_bd",
            col="est1",
            expected_range=Result.relative_range(-0.009, 0.2)
        ))
        return results