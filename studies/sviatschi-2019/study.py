from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Sviatschi(Study):
    id = 'sviatschi-2019'

    def data_paths(self) -> dict:
        return {
            "pandillas2003": os.path.join(
                self.path(), "source","AEA","data","pandillas2003.dta"
            ),
            "final": os.path.join(
                self.path(), "source","AEA","final.dta"
            ), # for monitoring only, created by us
        }
    
    def vars_to_noise(self):
        # list all personal vars used in the regression
        return {
            "post_replication": [
                "treat7x9",
                "treat10x12",
                "treat13x15",
                "treat16x18"
            ]
        }
    
    def _pre_processing(self, data):
        return data
    
    def _post_processing(self, noised_data):
        return noised_data
    
    def time_index(self) -> str:
        return "year"
    
    def subset_index(self):
        return "area"

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `master.do`: ###
        # use "$data/census_cl2.dta",clear
        # ...
        # merge codigo using "$data/pandillas2003.dta"
        # ...
        # gen age1996=1996-s06p04a
        # replace TOTAL=0 if TOTAL==.
        # gen pandilla=(TOTAL>0)
        # gen treat7x9=(age1996==7 | age1996==8 | age1996==9)*pandilla
        # gen treat10x12=(age1996==10 | age1996==11 | age1996==12)*pandilla
        # gen treat13x15=(age1996==13 | age1996==14 | age1996==15)*pandilla
        # gen treat16x18=(age1996==16 | age1996==17 | age1996==18)*pandilla
        #--- treat7x9-crime
        # eststo: reghdfe educ_y treat7x9 treat10x12 treat13x15 treat16x18, absorb(i.codigo i.s06p03a) cluster(codigo)
        #--- treat7x9-crime1
        # eststo:reghdfe educ_y treat7x9 treat10x12 treat13x15 treat16x18 if s06p08a1==1, absorb(i.codigo i.s06p03a i.codigo#c.s06p03a) cluster(codigo)
        ###
        sensitivities = {            
            ### treat*: the number of years of schooling of individuals between 18 and 45 per cohort-municipality of birth
            # [not aggregate] age1996
            # pandilla: indicator for individuals living in a neighborhood with gangs in 1996
            # based on whether there was at least one homicide in the neighborhood in 1996
            #> gen pandilla=(TOTAL>0)
            # TOTAL: number of homicides in the neighborhood in 1996
            "TOTAL": lambda neighborhood: 1,
            
            ##  treat7x9: the number of years of schooling of individuals between 18 and 45 per cohort-municipality of birth
            # TOTAL already noised
            ## treat10x12: the number of years of schooling of individuals between 18 and 45 per cohort-municipality of birth
            # TOTAL already noised
            ## treat13x15: the number of years of schooling of individuals between 18 and 45 per cohort-municipality of birth
            # TOTAL already noised
            ## treat16x18: the number of years of schooling of individuals between 18 and 45 per cohort-municipality of birth
            # TOTAL already noised

            ### [not aggregate] educ_y: the total years of education for an individual born in year c and in municipality m
            ### [not aggregate] s06p08a1: indicator for individual living in same neighborhood all their life
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table.csv")
        results.append(Result.from_esttab(
            id="treat7x9-crime",
            table=table,
            row="treat7x9",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="treat7x9-crime1",
            table=table,
            row="treat7x9",
            col="est2",
            expected_range=(None, 0)
        ))
        return results