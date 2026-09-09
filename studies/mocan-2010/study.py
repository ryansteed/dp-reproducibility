from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Mocan(Study):
    id = 'mocan-2010'

    def data_paths(self) -> dict:
        return {
            "Stpanel": os.path.join(
                self.path(), "source", "Stpanel.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict:
        df = data["Stpanel"]

        for rate in [
            "rpropert",
            "violent",
            "urplus",
            "urminus",
            "prisrat",
            "perwhite",
            "perblack",
            "perhisp",
            "perpopurban",
            "beerrat",
            "ppop15_19",
            "ppop20_24",
            "ppop25_34",
            "ppop35_44",
            "ppop45_54"
        ]:
            if rate in [
                "beerrat",
                "ppop15_19",
                "ppop20_24",
                "ppop25_34",
                "ppop35_44",
                "ppop45_54"
            ]:
                df[rate] = df[rate] / 100
            if rate in ["rpropert", "violent"]:
                df[rate] = df[rate] / 100000
            df[f"n_{rate}"] = df[rate] * df["pop"]
        data["Stpanel"] = df
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df = noised_data["Stpanel"]

        for rate in [
            "rpropert",
            "violent",
            "prisrat",
            "perwhite",
            "perblack",
            "perhisp",
            "perpopurban",
            "beerrat",
            "ppop15_19",
            "ppop20_24",
            "ppop25_34",
            "ppop35_44",
            "ppop45_54"
        ]:
            df[rate] = np.where(
                df["pop"] > 0,
                df[f"n_{rate}"] / df["pop"],
                np.nan
            )
            if rate in [
                "beerrat",
                "ppop15_19",
                "ppop20_24",
                "ppop25_34",
                "ppop35_44",
                "ppop45_54"
            ]:
                df[rate] = df[rate] * 100
            if rate in ["rpropert", "violent"]:
                df[rate] = df[rate] * 100000
            
        noised_data["Stpanel"] = df
        return noised_data
            

    def vars_to_noise(self) -> list:
        ### vars
        # # col 2 only
        # rpropert: property crime rate per 100,000 population
        # # col 4 only
        # violent: violent crime rate per 100,000 population
        # # both
        # urplus: unemployment rate if greater than last year; otherwise 0
        # urminus: unemployment rate if less than last year; otherwise 0
        # prisrat: prisoners/population
        # perwhite: % white
        # perblack: % black
        # perhisp: % hispanic
        # perpopurban: % urban population
        # beerrat: per capita beer consumption in the state
        # ppop15_19: % 15-19 year olds
        # ppop20_24: % 20-24 year
        # ppop25_34: % 25-34 year
        # ppop35_44: % 35-44 year
        # ppop45_54: % 45-54 year
        # pop: population
        ###
        return [
            "rpropert",
            "violent",
            # "urplus",
            # "urminus",
            "prisrat",
            "perwhite",
            "perblack",
            "perhisp",
            "perpopurban",
            "beerrat",
            "ppop15_19",
            "ppop20_24",
            "ppop25_34",
            "ppop35_44",
            "ppop45_54",
            "pop"
        ]
    
    def other_vars(self) -> list:
        return [
            "urplus",
            "urminus"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "state"

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Table_1.do`: ###
        # use Stpanel.dta;
        # eststo: xi: reg rpropert urplus urminus prisrat perwhite perblack perhisp perpopurban beerrat ppop15_19 ppop20_24 
        # ppop25_34 ppop35_44 ppop45_54  i.state i.year i.state*year   [weight=pop], robust  ;
        # eststo: xi: reg violent urplus urminus prisrat perwhite perblack perhisp perpopurban beerrat ppop15_19 ppop20_24 
        # ppop25_34 ppop35_44 ppop45_54 beerrat i.state i.year i.state*year    [weight=pop], robust  ;
        ###
        vars_to_noise = {   
            ### pop: population
            "pop": lambda state: 1,
            # created inter var n_`var` = `var` * pop for all of the below:
            ### rpropert: property crime rate per 100,000 population
            "n_rpropert": lambda state: 1,
            ### violent: violent crime rate per 100,000 population
            "n_violent": lambda state: 1,
            ### prisrat: prisoners/population
            "n_prisrat": lambda state: 1,
            ### perwhite: % white
            "n_perwhite": lambda state: 1,
            ### perblack: % black
            "n_perblack": lambda state: 1,
            ### perhisp: % hispanic
            "n_perhisp": lambda state: 1,
            ### perpopurban: % urban population
            "n_perpopurban": lambda state: 1,
            ### beerrat: per capita beer consumption in the state
            # n_beerrat is invariant; only pop is noised
            ### ppop15_19: % 15-19 year olds
            "n_ppop15_19": lambda state: 1,
            ### ppop20_24: % 20-24 year
            "n_ppop20_24": lambda state: 1,
            ### ppop25_34: % 25-34 year
            "n_ppop25_34": lambda state: 1,
            ### ppop35_44: % 35-44 year
            "n_ppop35_44": lambda state: 1,
            ### ppop45_54: % 45-54 year
            "n_ppop45_54": lambda state: 1,

            ### urplus: unemployment rate if greater than last year; otherwise 0
            # NOTE: can't noise, no data on labor force
            ### urminus: unemployment rate if less than last year; otherwise 0
            # NOTE: can't noise, no data on labor force
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        recession = Result.from_esttab(
            id="recession_property",
            table=table,
            row="urplus",
            col="est1",
            expected_range=(0, None)
        )
        recovery = Result.from_esttab(
            id="recovery_property",
            table=table,
            row="urminus",
            col="est1",
            expected_range=(0, recession.est)
        )
        recession.expected_range = (recovery.est, None)
        results.append(recession)
        results.append(recovery)
        results.append(Result.from_esttab(
            id="recession_violent",
            table=table,
            row="urplus",
            col="est2",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="recovery_violent",
            table=table,
            row="urminus",
            col="est2",
            expected_range=(0, 0)
        ))
        return results