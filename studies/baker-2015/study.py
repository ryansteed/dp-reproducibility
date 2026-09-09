from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Baker(Study):
    id = 'baker-2015'

    def data_paths(self) -> dict:
        return {
            "results_data": os.path.join(
                self.path(), "source", "Baker_Data-and-Code","results_data.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]):
        df = data["results_data"]

        # deconstruct lpop = log(pop)
        df["pop"] = np.exp(df["lpop"])
        # deconstruct OfficersPerCap = Police / pop
        df["Police"] = df["OfficersPerCap"] * df["pop"]
        # deconstruct CumWeightedAllImmPerCap = CumWeightedAllImm / pop
        df["CumWeightedAllImm"] = df["CumWeightedAllImmPerCap"] * df["pop"]
        # deconstruct logemp
        df["emp"] = np.exp(df["logemp"])
        # deconstruct UnemploymentRate = Unemployment / (Unemployment + Employment)
        df["unemp"] = df["emp"] * df["UnemploymentRate"]/100 / (1 - df["UnemploymentRate"]/100)
        # deconstruct povrate
        df["pov"] = df["povrate"] / 100 * df["pop"]
        # deconstruct NumberOfAbortionsLag14PerCap
        df["NumberOfAbortionsLag14"] = df["NumberOfAbortionsLag14PerCap"] * df["pop"]
        # deconstruct lTotal*CrimesPerCap
        self._crimetypes = ["All", "Violent", "Property"]
        for crime in self._crimetypes:
            df[f"Total{crime}Crimes"] = np.exp(df[f"lTotal{crime}CrimesPerCap"]) * df["pop"]

        data["results_data"] = df
        return data

    def _post_processing(self, noised_data: Dict[str, pd.DataFrame]):
        noised_df = noised_data["results_data"]

        # reconstruct lpop
        noised_df["lpop"] = np.log(noised_df["pop"])
        # reconstruct OfficersPerCap
        noised_df["OfficersPerCap"] = noised_df["Police"] / noised_df["pop"]
        # reconstruct CumWeightedAllImmPerCap
        noised_df["CumWeightedAllImmPerCap"] = noised_df["CumWeightedAllImm"] / noised_df["pop"]
        # reconstruct logemp
        noised_df["logemp"] = np.log(noised_df["emp"])
        # reconstruct UnemploymentRate
        noised_df["UnemploymentRate"] = np.where(
            noised_df["unemp"].isna(),
            1,
            noised_df["unemp"] / (noised_df["unemp"] + noised_df["emp"])
        ) * 100
        # reconstruct povrate
        noised_df["povrate"] = noised_df["pov"] / noised_df["pop"] * 100
        # reconstruct NumberOfAbortionsLag14PerCap
        noised_df["NumberOfAbortionsLag14PerCap"] = noised_df["NumberOfAbortionsLag14"] / noised_df["pop"]
        # reconstruct lTotal*CrimesPerCap
        for crime in self._crimetypes:
            noised_df[f"lTotal{crime}CrimesPerCap"] = np.log(noised_df[f"Total{crime}Crimes"] / noised_df["pop"])

        noised_data["results_data"] = noised_df
        return noised_data
    
    def vars_to_noise(self):
        return [
            "lpop",
            "CumWeightedAllImmPerCap",
            "logemp",
            "UnemploymentRate",
            "povrate",
            # "logincome",
            "OfficersPerCap",
            "NumberOfAbortionsLag14PerCap",
            "lTotalAllCrimesPerCap",
            "lTotalViolentCrimesPerCap",
            "lTotalPropertyCrimesPerCap"
        ]
    
    def other_vars(self):
        return [
            "logincome",
            "crack_index",
            "yy1", "yy2", "yy3", "yy4", "yy5",
            "yy6", "yy7", "yy8", "yy9", "yy10",
            "yy11", "yy12", "yy13", "yy14", "yy15",
            "yy16", "yy17", "yy18", "yy19", "yy20"
        ]
    
    def time_index(self):
        return None # only included as dummies, include manually
    
    def subset_index(self):
        return "cc"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table1.do`: ###
        ###     
        # use results_data
        #--- irca-allcrime
        # eststo:areg lTotalAllCrimesPerCap CumWeightedAllImmPerCap lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20, absorb(cc) cluster(cc)
        # ...
        #--- irca-violentcrime
        # eststo:areg lTotalViolentCrimesPerCap CumWeightedAllImmPerCap lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20, absorb(cc) cluster(cc)
        #--- irca-propertycrime
        # eststo:areg lTotalPropertyCrimesPerCap CumWeightedAllImmPerCap lpop UnemploymentRate povrate logincome logemp OfficersPerCap  crack_index NumberOfAbortionsLag14PerCap yy1-yy20, absorb(cc) cluster(cc)
        ###

        vars_to_noise = {
            ### lpop: Population
            # assuming this is the log population
            # NOTE: created new variable pop = exp(lpop)
            "pop": lambda countyyear: 1,

            ### CumWeightedAllImmPerCap: IRCA Per Capita
            # assuming CumWeightedAllImmPerCap = IRCA / pop
            # IRCA is number of IRCA apps, not private
            # NOTE: created var CumWeightedAllImm = CumWeightedAllImmPerCap * pop
            # pop already noised

            ### logemp: Log Employment
            # NOTE: created var emp = exp(logemp)
            "emp": lambda countyyear: 1,

            ### UnemploymentRate: Unemp. Rate
            # UnemploymentRate = Unemployment / (Unemployment + Employment) * 100
            # EmploymentRate = 1 - UnemploymentRate/100
            # unemp / emp = UnemploymentRate/100 / (1 - UnemploymentRate/100)
            # NOTE: created var unemp = emp * UnemploymentRate/100 / (1 - UnemploymentRate/100)
            "unemp": lambda countyyear: 1,

            ### povrate: Poverty Rate
            # assuming povrate = pov / pop * 100
            # NOTE: created var pov = povrate / 100 * pop
            "pov": lambda countyear: 1,

            ### logincome: Log Income
            # NOTE: can't tell if this is log income or total income; not enough info for DP

            ### OfficersPerCap: Police Per Capita
            # OfficersPerCap = Police / exp(lpop)
            # NOTE: created new variable Police = OfficersPerCap * pop
            # pop already
            "Police": lambda countyyear: 1,

            ### [not personal] crack_index: Crack Index

            ### NumberOfAbortionsLag14PerCap: Lagged Abortions
            # assuming this is the number of abortions per capita
            # NumberOfAbortionsLag14PerCap = NumberOfAbortionsLag14 / pop
            # NOTE: created var NumberOfAbortionsLag14 = NumberOfAbortionsLag14PerCap * pop
            "NumberOfAbortionsLag14": lambda countyyear: 1,

            ### [not personal] yy*: year dummies

            ### lTotal*CrimesPerCap: Crime Per Capita
            ## ltotal*CrimesPerCap = log(total*Crimes / pop)
            # NOTE: created vars total*Crimes = exp(lTotal*CrimesPerCap) * pop
            #--- irca-allcrime
            ## lTotalAllCrimesPerCap
            "TotalAllCrimes": lambda countyyear: 1,

            #--- irca-violentcrime
            ## lTotalViolentCrimesPerCap
            "TotalViolentCrimes": lambda countyyear: 1,

            #--- irca-propertycrime
            ### lTotalPropertyCrimesPerCap
            "TotalPropertyCrimes": lambda countyyear: 1,

        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="irca-allcrime",
            table=table,
            row="CumWeightedAllImmPerCap",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="irca-violentcrime",
            table=table,
            row="CumWeightedAllImmPerCap",
            col="est3",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="irca-propertycrime",
            table=table,
            row="CumWeightedAllImmPerCap",
            col="est4",
            expected_range=(None, -1.333)
        ))
        return results