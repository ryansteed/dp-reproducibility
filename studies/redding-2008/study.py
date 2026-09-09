from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Redding(Study):
    id = 'redding-2008'

    def data_paths(self) -> dict:
        return {
            "RemotenessAER_Main": os.path.join(
                self.path(), "source/RemotenessAER/regressions/main_results/data", "RemotenessAER_Main.dta"
            ),
            "final": os.path.join(
                self.path(), "source/RemotenessAER", "final.dta"
            ) # created by us, for monitoring only
            # ...
        }
    
    def vars_to_noise(self):
        # list all personal vars used in the regression
        return {
            "post_replication": [
                "g_pop"
            ]
        }
    
    # def _pre_processing(self, data):
    #     return data
    
    # def _post_processing(self, noised_data):
    #     return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `main_results.do`: ###
        # use regressions/main_results/data/RemotenessAER_Main.dta
        # so city year
        # tsset city year , generic
        # merge city using regressions/main_results/temp/matchpairs.dta
        # ...
        # *******************************
        # **** TABLE 2: Basic Table ****
        # *******************************

        # * Column (1), baseline specification 
        # eststo all: reg g_pop treat bzone yy* if year<1990&sample==1, cluster(city) 
        # ...
        # * Column (4), run baseline specification for small cities only 
        # eststo small: reg g_pop treat bzone yy* if year<1990&sample==1&size1919<med_size1919, cluster(city) 

        sensitivities = {
            ### g_pop: "Annualized growth rate of population based on the current and lagged population values"
            #> quietly by city: gen lagpop=pop[_n-1]
            #> gen g_pop=((pop/lagpop)^(1/length)-1)*100
            # pop: Population
            "pop": lambda cityyear: 1,

            ### [not personal] yy*: "year variables yy1: year== 1919.0000 to yy9: year== 1988.0000"

            ### [not personal] bzone: "Dummy variable of whether Distance to the East-West German border (km) < 75"
            #> gen bzone=0
            #> replace bzone=1 if dist_gg_border<75

            ### [not personal] treat: "Dummy variable of whether Distance to the East-West German border (km) < 75 multiply by dummy of year division"
            #> gen division=0
            #> replace division=1 if year>1939&year<1990
            #> ...
            #> gen treat=bzone*division
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(all := Result.from_esttab(
            id="division-growth",
            table=table,
            row="treat",
            col="all",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="division-growth-small",
            table=table,
            row="treat",
            col="small",
            expected_range=(None, all.est)
        ))
        return results