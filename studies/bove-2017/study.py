from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Bove(Study):
    id = 'bove-2017'

    def data_paths(self) -> dict:
        return {
            "militarization": os.path.join(
                self.path(), "source/1033-Project", "militarization.dta"
            ),
            # "police": os.path.join(
            #     self.path(), "source/1033-Project", "police.dta"
            # )
            # ...
        }
    def _pre_processing(self, data: Dict[str, pd.DataFrame]):
        df = data["militarization"]

        # deconstruct PovertyPercentAllAges
        df["poverty_denominator"] = df["PovertyEstimateAllAges"] / df["PovertyPercentAllAges"] * 100
        
        # deconstruct Unempl_Rate = Unemployment/pop
        df["Unemployment"] = df["Unempl_Rate"] * df["Laborforce"] / 100

        # deconstruct crime
        self._subcrime_vars = [
            "rmurder",
            "rrobbery",
            "rassault",
            "rburglary",
            "rlarceny",
            "rmvtheft"
        ]
        # df["rother"] = df["crime"] * df["pop"] / 100000 - df[self._subcrime_vars].sum(axis=1)

        data["militarization"] = df
        return data
    
    def _post_processing(self, noised_data: Dict[str, pd.DataFrame]):
        noised_df = noised_data["militarization"]

        # reconstruct PovertyPercentAllAges
        noised_df["PovertyPercentAllAges"] = noised_df["PovertyEstimateAllAges"] / noised_df["poverty_denominator"] * 100

        # reconstruct lMedian
        noised_df["lMedian"] = np.log(noised_df["MedianHouseholdIncome"])

        # reconstruct Unempl_Rate
        noised_df["Unempl_Rate"] = noised_df["Unemployment"] / noised_df["Laborforce"] * 100
        
        # reconstruct lpop
        noised_df["lpop"] = np.where(
            noised_df["pop"] != 0,
            np.log(noised_df["pop"]),
            np.nan
        )
        
        # reconstruct share*
        noised_df["shareage1519"] = noised_df["age1519"] / noised_df["pop_age_sum"]
        noised_df["shareage2024"] = noised_df["age2024"] / noised_df["pop_age_sum"]
        noised_df["shareage2529"] = noised_df["age2529"] / noised_df["pop_age_sum"]
        noised_df["shareage3034"] = noised_df["age3034"] / noised_df["pop_age_sum"]
        noised_df["sharemale"] = noised_df["male"] / noised_df["pop_age_sum"]
        noised_df["shareblack"] = noised_df["black"] / noised_df["pop_age_sum"]

        # reconstruct crime, murder, robbery, assault, burglary, larceny, mvteft
        noised_df["crime"] = np.where(
            noised_df["crime"].isna(),
            np.nan, # preserve na
            noised_df[self._subcrime_vars].sum(axis=1)
        ) / noised_df["pop"] * 100000
        noised_df["murder"] = np.where(noised_df["pop"] != 0, noised_df["rmurder"] / noised_df["pop"] * 100000, np.nan)
        noised_df["robbery"] = np.where(noised_df["pop"] != 0, noised_df["rrobbery"] / noised_df["pop"] * 100000, np.nan)
        noised_df["assault"] = np.where(noised_df["pop"] != 0, noised_df["rassault"] / noised_df["pop"] * 100000, np.nan)
        noised_df["burglary"] = np.where(noised_df["pop"] != 0, noised_df["rburglary"] / noised_df["pop"] * 100000, np.nan)
        noised_df["larceny"] = np.where(noised_df["pop"] != 0, noised_df["rlarceny"] / noised_df["pop"] * 100000, np.nan)
        noised_df["mvtheft"] = np.where(noised_df["pop"] != 0, noised_df["rmvtheft"] / noised_df["pop"] * 100000, np.nan)
        
        noised_data["militarization"] = noised_df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [      
            "PovertyPercentAllAges",
            "lMedian",
            "Unempl_Rate",
            "lpop",
            "sharemale",
            "shareblack",
            "shareage1519",
            "shareage2024",
            "shareage2529",
            "shareage3034",
            "crime",
            "murder",
            "robbery",
            "assault",
            "burglary",
            "larceny",
            "mvtheft"
        ]
    
    def other_vars(self) -> list:
        return [
            "ltotal_cost",
            # "milex_iv" # created from milex
            "milex"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "fips"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `analysis.do`: ###
        # use militarization.dta, clear
        # ...
        # gen milex_iv= Aid1/7*log(L2.milex)
        # ...
        # eststo clear
        # mat B=J(1,9,.)
        # local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
        # eststo: xtreg crime `controls' statetimefe_* ltotal_cost, fe  cl(State) 

        # local i=2
        # local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
        # eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv, fe  cl(State) 
        # foreach  instrument of varlist milex_iv{
        # foreach var of varlist ltotal_cost {
        # foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
        # local i=`i'+1
        # eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument'), fe  cl(State) 
        # qui sum `depvar'
        # mat B[1,`i']=_b[ltotal_cost]/r(mean)
        # }
        # }
        # }
        # local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
        ###
        sensitivities = {
            #--- militarization.dta
            ### PovertyPercentAllAges: Percent Poverty
            # PovertyPercentAllAges = PovertyEstimateAllAges / poverty_denominator * 100
            # NOTE: created var poverty_denominator = PoveryEstimateAllAges / PovertyPercentAllAges * 100
            "poverty_denominator": lambda county: 1,
            "PovertyEstimateAllAges": lambda county: 1,

            ### lMedian: Log Median Income
            # sensitivity of median is max / 2
            # NOTE: reconstructing lMedian = log(MedianHouseholdIncome)
            # NOTE: assuming household income clipped at 500k
            "MedianHouseholdIncome": lambda county: 500000/2,

            ### Unempl_Rate: Unemployment Rate
            # Unempl_Rate = Unemployment / Laborforce * 100
            # NOTE: created var Unemployment = Unempl_Rate * Laborforce / 100
            "Unemployment": lambda county: 1,
            "Laborforce": lambda county: 1,

            ### lpop: Log Population
            # NOTE: reconstructed lpop = log(pop)
            "pop": lambda county: 1,

            ###  share*: Share *
            # NOTE: reconstructing share* = * / pop_age_sum
            "pop_age_sum": lambda county: 1,
            ## sharemale: Share Male
            "male": lambda county: 1,
            ## shareblack: Share Blacks
            "black": lambda county: 1,
            ## shareage1519: Share Age 15-19
            "age1519": lambda county:1,
            ## shareage2024: Share Age 20-24
            "age2024": lambda county:1,
            ## shareage2529: Share Age 25-29
            "age2529": lambda county:1,
            ## shareage3034: Share Age 30-34
            "age3034": lambda county:1,

            ### crime: Crime Rate per 100,000
            # crime = sum(subcrimes) / pop * 100000
            # pop already noised
            # subcrimes noised below

            ### subcrime rates
            # NOTE: reconstructed * = r* / pop
            ## murder: Murder Rate
            "rmurder": lambda county:1,
            ## robbery: Robbery Rate
            "rrobbery": lambda county:1,
            ## assault: Assault Rate
            "rassault": lambda county:1,
            ## burglary: Burglary Rate
            "rburglary": lambda county:1,
            ## larceny: Larceny Rate
            "rlarceny": lambda county:1,
            ## mvtheft: Vehicle Theft Rate
            "rmvtheft": lambda county:1,

            ### [not personal] ltotal_cost: Lagged Total Aid
            ### [not personal] milex_iv: US Military spending in constant 2011 USDm
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="military-crime",
            table=table,
            row="ltotal_cost",
            col="est3",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="military-larceny",
            table=table,
            row="ltotal_cost",
            col="est8",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="military-vehicle",
            table=table,
            row="ltotal_cost",
            col="est9",
            expected_range=(None, 0)
        ))
        return results