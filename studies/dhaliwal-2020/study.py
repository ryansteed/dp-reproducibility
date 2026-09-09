from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Dhaliwal(Study):
    id = 'dhaliwal-2020'

    def data_paths(self) -> dict:
        return {
            "AERAOpen_lcffruralpanel_0418_replication": os.path.join(
                self.path(), "source", "AERAOpen_lcffruralpanel_0418_replication.dta"
            )
            # ...
        }
    
    def vars_to_noise(self):
        return ["k12ada"]
    
    def other_vars(self):
        return [
            "totexp_1",
            "rural_distant",
            "rural_fringe",
            "town_locale",
            "suburb_locale",
            "urban_locale"
        ]
    
    def time_index(self):
        return "schendyr"
    
    def subset_index(self):
        return "dcode"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `AERAOpen_ruralfin_analysis.do`: ###
        #-- Table 3
        # use "AERAOpen_lcffruralpanel_0418_replication.dta"
        # ...
        # foreach var of varlist totexp_1 st_1 nonstudent_1 ///
        # capfacil_1  debt_1 nonagcs_1 prekadult_1 retiree_1 {
        #     eststo: regress `var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
        #     ...
        #     }
        ###
        vars_to_noise = {
            ### k12ada: Total K-12 ADA (average daily attendance) in 2017-2018 school year
            # 180 day calendar in CA in 2018: https://nces.ed.gov/programs/statereform/tab5_14.asp
            # k12ada = (attended1 + attended2 + ... attended180) / 180
            # equivalent to summing average attendance for each student
            # each student can change attended* by at most 1
            # NOTE: at most, student could not attend every days, thus reducing average daily attendance by 1
            "k12ada": {
                "sensitivity": lambda district: 1,
                "lb": 0
            }

            ### [not personal] totexp_1: Total cost of education by district (defn1)
            # all results use the first specification with totexp_1
            ### [not personal] rural_distant: ==1 if locale code rural distant
            ### [not personal] rural_fringe: ==1 if locale code rural fringe
            ### [not personal] town_locale: ==1 if NCES town locale code (31-33)
            ### [not personal] suburb_locale: ==1 if NCES suburban locale code (21-23)
            ### [not personal] urban_locale: ==1 if NCES urban locale code (11-13)
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="ruralremote-spend",
            table=table1,
            row="_cons",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="ruraldistant-spend",
            table=table1,
            row="rural_distant",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="ruralfringe-spend",
            table=table1,
            row="rural_fringe",
            col="est1",
            expected_range=(None, 0)
        ))
        # table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        # results.append(Result.from_esttab(
        #     id="ruralremote-change",
        #     table=table2,
        #     row="_cons",
        #     col="est1",
        #     expected_range=(0, None)
        # ))
        return results