from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Allison(Study):
    id = 'allison-2023'

    def data_paths(self) -> dict:
        return {
            "city_sample": os.path.join(
                self.path(), "source", "Replication_JEEA","Input","city_sample.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict[str, pd.DataFrame]:
        df = data["city_sample"]

        # deconstruct arr_drugsale_spread
        df["arr_drugsale_b"] = df["arr_drugsale_b_p1k"] * df["population"] / 1000
        df["arr_drugsale_w"] = df["arr_drugsale_w_p1k"] * df["population"] / 1000
        data["city_sample"] = df

        # deconstruct p*
        self._pvars = [
            "hispanic", "black", "white", "asian", "aian", "unemployed", "nohsdiploma",
            "bachelors", "age65_up", "age0_24", "female"
        ]
        for v in self._pvars:
            df[f"n{v}"] = df[f"p{v}"] * df["population"]
        
        # deconstruct povertyrate
        df["poverty"] = df["povertyrate"] * df["population"]

        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["city_sample"]

        # reconstruct pop2
        df["pop2"] = np.power(df["population"].astype(np.int64), 2)

        # reconstruct p*
        for v in self._pvars:
            df[f"p{v}"] = df[f"n{v}"] / df["population"]
        
        # reconstruct arr_drugsale_spread
        df["arr_drugsale_b_p1k"] = df["arr_drugsale_b"] / df["population"] * 1000
        df["arr_drugsale_w_p1k"] = df["arr_drugsale_w"] / df["population"] * 1000
        df["arr_drugsale_diff"] = df["arr_drugsale_b_p1k"] - df["arr_drugsale_w_p1k"]
        # manually fix floating point errors for control case
        floating_pt_errs = [643, 1432, 2172, 9255, 9949, 10320]
        if np.isclose(df.loc[floating_pt_errs, "arr_drugsale_diff"], [
            -0.00086156, 0.00480461, -0.00299251, -0.00056541, -0.01536655, -0.01707172
        ]).all():
            df.loc[floating_pt_errs, "arr_drugsale_diff"] = [
                -0.00086153, 0.00480469, -0.00299257, -0.00056537, -0.01536636, -0.01707207
            ]
        df["arr_drugsale_spread"] = np.abs(df["arr_drugsale_diff"])
        
        # reconstruct povertyrate
        df["povertyrate"] = df["poverty"] / df["population"]

        # reconstruct pblackxhprime
        df["pblackxhprime"] = df["pblack"] * df["hprime"]

        noised_data["city_sample"] = df
        return noised_data
    
    def vars_to_noise(self):
        return [
            "population",
            "pop2",
            "arr_drugsale_spread",
            "phispanic",
            "pblack",
            "pwhite",
            "pasian",
            "paian",
            "punemployed",
            "pnohsdiploma",
            "pbachelors",
            "page65_up",
            "page0_24",
            "pfemale",
            "medhhinc",
            "povertyrate",
            # "seg_thiel",
            "pblackxhprime",
            # "hprime",
        ]
    
    def other_vars(self):
        return [
            "seg_thiel",
            "hprime",
            "sample",
            "fstate"
        ]
    
    def time_index(self) -> str:
        return "year"
    
    def subset_index(self) -> str:
        return "city"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `1_Tables.do`: ###
        #-- arr_pblackxhprime, arr_pblack
        # use city_sample.dta, clear
        # ...
        # keep if sample==1 //final sample limited to cities with: population>=25000  & pblack>.01  & pblack!=. & pwhite>.01 & pwhite!=. &  population!=. & exp_police!=. & exp_police>0 & shrink!=.  & arr_drugsale_spread!=.
        # global x population pop2 phispanic pasian paian punemployed pnohsdiploma pbachelors page65_up page0_24 pfemale medhhinc povertyrate seg_thiel 
        # ...
        # reghdfe arr_drugsale_spread pblack	pblackxhprime	hprime   $x  	     if sample==1 , a($fe_state) vce(cluster $cl )
        
        #-- ps_pblackxhprime, ps_pblack
        # ...
        # reghdfe exp_police pblack	pblackxhprime	hprime		$x   			if sample==1 ,  a($fe_city) vce(cluster $cl )  
        ###
        vars_to_noise = {
            #-- city_sample.dta
            ### population: Population
            "population": lambda cityyear: 1,
            
            ### pop2: Population squared
            # NOTE: reconstructed from population
            
            ### arr_drugsale_spread: Drug sale arrest rate distance
            # Paper: "The distance between arrest rates is the absolute value of the difference in arrest rates."
            # arr_drugsale_diff: Drug sale arrest rate difference (Black-White)
            # arr_drugsale_diff = arr_drugsale_b_p1k - arr_drugsale_w_p1k
            # NOTE: created vars arr_drugsale_* = arr_drugsale_*_p1k * population / 1000
            "arr_drugsale_b": lambda cityyear: 1,
            "arr_drugsale_w": lambda cityyear: 1,
            # population already noised

            #-- p* variables
            # NOTE: created vars n* = p* * population
            # population already noised
            ### phispanic: Percent Hispanic
            "nhispanic": lambda cityyear: 1,
            ### pblack: Percent Black
            "nblack": lambda cityyear: 1,
            ### pwhite: Percent White
            "nwhite": lambda cityyear: 1,
            ### pasian: Percent Asian
            "nasian": lambda cityyear: 1,
            ### paian: Percent AI/AN
            "naian": lambda cityyear: 1,
            ### punemployed: Percent Unemployed
            "nunemployed": lambda cityyear: 1,
            ### pnohsdiploma: Percent No HS Diploma
            "nnohsdiploma": lambda cityyear: 1,
            ### pbachelors: Percent Bachelors degree
            "nbachelors": lambda cityyear: 1,
            ### page65_up: Percent ages 65 and up
            "nage65_up": lambda cityyear: 1,
            ### page0_24: Percent ages 0-24
            "nage0_24": lambda cityyear: 1,
            ### pfemale: Percent Female
            "nfemale": lambda cityyear: 1,

            ### medhhinc: Median household Income
            # global sensitivity of median is max value divided by two
            # (imagining a dataset with both the max and the min, removing 
            # the max would alter the median by half the max)
            # hhinc appears to be in $1000s
            # NOTE: assuming clipping at 1,000,000
            "medhhinc": lambda cityyear: 1000/2,
            
            ### povertyrate: Poverty rate
            # NOTE: assuming denominator is population
            # NOTE: created var poverty = povertyrate * population
            # population already noised
            "poverty": lambda cityyear: 1,
            
            ### seg_thiel: Theil index of Segregation computed at census tract-level
            # NOTE: tract-level data not included; not enough info for DP

            ### hprime: $hprime$ = (50th income %tile Black - 10th income %tile Black) / (50th income %tile White - 10th income %tile White)
            # medhhinc_b: Median household income, black
            # medhhinc_w: Median household income, white
            # medhhinc_diff = medhhinc_b - medhhinc_w
            # NOTE: not enough info to determine 10th percentiles; not enough info for DP
            
            ### pblackxhprime: Percent Black $\times$ $hprime$
            # NOTE: reconstructed from hprime (invariant) and pblack

            ### [not personal] exp_police: Police spending (1M USD)
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []

        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        hprime = Result.from_esttab(
            id="arr_pblackxhprime",
            table=table,
            row="pblackxhprime",
            col="C",
            expected_range=None
        )
        pblack = Result.from_esttab(
            id="arr_pblack",
            table=table,
            row="pblack",
            col="C",
            expected_range=None
        )
        hprime.expected_range = (None, -pblack.est) # sum expected to be negative
        pblack.expected_range = (None, -hprime.est) # sum expected to be negative
        results.append(hprime)
        results.append(pblack)

        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        hprime_ps = Result.from_esttab(
            id="ps_pblackxhprime",
            table=table2,
            row="pblackxhprime",
            col="C_FE",
            expected_range=(0, 0)
        )
        pblack_ps = Result.from_esttab(
            id="ps_pblack",
            table=table2,
            row="pblack",
            col="C_FE",
            expected_range=(0, 0)
        )
        results.append(hprime_ps)
        results.append(pblack_ps)
        return results