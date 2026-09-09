from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Bellego(Study):
    id = 'bellego-2024'

    def data_paths(self) -> dict:
        return {
            # "data_for_analysis": os.path.join(
            #     self.path(), "source/data/processed", "data_for_analysis.dta"
            # ),
            # "UPP_Data": os.path.join(
            #     self.path(), "source/data/preprocessed", "UPP_Data.csv"
            # ),
            "UPP_Crime": os.path.join(
                self.path(), "source/data/preprocessed", "UPP_Crime.csv"
            ),
            "final": os.path.join(
                self.path(), "source/code", "final.dta"
            ) # created by us, for monitoring purposes only
        }
    
    def _save_csv(self, df, path):
        df.astype(str).to_csv(path, index=False) # authors code expects strings
    
    # def _pre_processing(self, data):
    #     # df = data["data_for_analysis"]
    #     vars = [
    #         "totalrobbery", "totaltheft", "threat",
    #         "homicideintentional", "bodyinjurydeathfollowed", "robberydeathfollowed",
    #         "bodyinjuryintentional", "attemptedmurder"
    #     ]
    #     print(data["UPP_Crime"].columns)
    #     print(data["UPP_Crime"][vars])
    #     print(data["UPP_Crime"][vars].describe())
    #     print(data["UPP_Crime"].groupby("year")[vars].sum().describe())
    #     # data["data_for_analysis"] = df
    #     return data      
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `2_descriptive_stat_and_main_analysis.do`: ###
        # * With UPP linear trend
        # use $processed/data_for_analysis.dta, clear
        # ...
        # forv l=2/2 {
        #     forv p=1/1 {
        #         * Without our fix for the endogeneous reporting bias
        #         eststo clear
        #         foreach v of varlist murder violencenokill totalrobbery totaltheft extortion policeaction policekill threat rape totevent {
        #         eststo: quietly xtreg ln`l'_p`p'_`v' intervention pacified upp_timetrend* i.date , fe vce(cluster upp) 
        #         }
        #         ...
        #     }
        # }
        ###
        vars_to_noise = {
            #-- data_for_analysis
            
            ### ln2_p1_*: log ((crime + 0.5) per capita)
            # generated in `1_build_main_data.do`
            # *** Dependent variables (to fix the endogeneous reporting bias using accident as a proxy variable)
            # foreach v of varlist homicideintentional-eventsregistration policekill-streetrobbery {
            # gen p1_`v' = `v' / pop10
            # }
            # foreach v of varlist homicideintentional-eventsregistration policekill-streetrobbery {
            # gen epsilon1=1
            # gen epsilon2=0.5
            # gen epsilon3=0.25
            # gen ln1_p1_`v' = log((`v'+epsilon1) / pop10)
            # gen ln2_p1_`v' = log((`v'+epsilon2) / pop10)
            # gen ln3_p1_`v' = log((`v'+epsilon3) / pop10)
            # }
            # NOTE: assuming units of 1, no evidence otherwise
            # gen pop10 = population
            "population": lambda favelamonth: 1,
            
            # crime vars range from 0 to 71... so what's the unit?
            # pretty sure it's 1 --- small because monthly per favela
            ## murder
            # gen murder =  homicideintentional + bodyinjurydeathfollowed + robberydeathfollowed
            "homicideintentional": lambda favelamonth: 1,
            "bodyinjurydeathfollowed": lambda favelamonth: 1,
            "robberydeathfollowed": lambda favelamonth: 1,

            ## totalrobbery
            "totalrobbery": lambda favelamonth: 1,
            
            ## violencenokill
            # gen violencenokill = bodyinjuryintentional + attemptedmurder
            "bodyinjuryintentional": lambda favelamonth: 1,
            "attemptedmurder": lambda favelamonth: 1,

            ## totaltheft
            "totaltheft": lambda favelamonth: 1,
            
            ## threat
            "threat": lambda favelamonth: 1,

            ### [not personal] intervention: dummy for police pacifying the area
            ### [not personal] pacified: dummy for area being pacified
            ### [not personal] upp_timetrend*: time dummies
            ### [not personal] date: date dummies

        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return {
            "pre_replication": [], 
            "post_replication": [
                "ln2_p1_murder",
                "ln2_p1_totalrobbery",
                "ln2_p1_violencenokill",
                "ln2_p1_totaltheft",
                "ln2_p1_threat",
            ] # vars constructed by authors code
        }
    
    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1_2_1.csv")
        results.append(Result.from_esttab(
            id="pacif-murder",
            table=table,
            row="pacified",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="pacif-robbery",
            table=table,
            row="pacified",
            col="est3",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="pacif-assult",
            table=table,
            row="pacified",
            col="est2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="pacif-theft",
            table=table,
            row="pacified",
            col="est4",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="pacif-threat",
            table=table,
            row="pacified",
            col="est8",
            expected_range=(0, None)
        ))
        return results