from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Brinkman(Study):
    id = 'brinkman-2018'

    def data_paths(self) -> dict:
        return {
            "city_data_stata8": os.path.join(
                self.path(), "source/data", "city_data_stata8.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        return {
            "post_replication": [
                "per_own_U55_total",
                "ln_density",
                "inc_val",
                "ln_city_pop",
                "pop_change1980",
                "liabilities_pop",
                "uaal_pop",
                "uaal_income",
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `city_analysis_0817.do`: ###
        # use city_data_stata8
        # [controls created]
        # eststo: reg uaal_pop per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust  
        # ...
        # eststo: reg uaal_income per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
        # ...
        # eststo: reg uaal_rev per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
        # ...
        # eststo: reg uaal_value per_own_U55_total ln_density  inc_val ln_city_pop pop_change1980 liabilities_pop regd1 regd2 regd3, robust 
        ###
        sensitivities = {
            ### per_own_U55_total: percentage of households who own thier home
            #> from `city_analysis_0817.do` (run):
            # gen per_own=tot_own/tot_hh*100 
            # tot_own: total owner households  (count)
            "tot_own": lambda city: 1,
            # tot_hh: total housholds
            "tot_hh": lambda city: 1,

            ### ln_city_pop: log city population
            #> from `city_analysis_0817.do` (run):
            # gen ln_city_pop=ln(city_pop)
            # city_pop: population of the city in 2012
            "city_pop": lambda city: 1,

            ### ln_density: log population density
            #> from `city_analysis_0817.do` (run):
            # gen density=city_pop/land_area*2590000    //density in square miles
            # ...
            # gen ln_density=ln(density)                 //log density 
            # already noised city_pop
            # [not personal] land_area

            ### inc_val: ratio of median income and median house values
            #> from `city_analysis_0817.do` (run):
            # gen inc_val = median_hh_inc/median_house_value
            # median_hh_inc: Median household income 2012 ($/yr)
            # NOTE: assuming household income does not exceed 1,000,000
            "median_hh_inc": lambda city: 1000000/2,
            # [not personal] median_house_value: Median value of house   ($)

            ### pop_change1980: percentage population change between 2000 and 2012
            #> from `city_analysis_0817.do` (run):
            # gen pop_change1980 = (city_pop-pop_1980)/pop_1980
            # pop_1980: population of the city in 1980
            "pop_1980": lambda city: 1,
            # city_pop already noised

            ### liabilities_pop: liabilities per capita
            #> from `city_analysis_0817.do` (run):
            # gen liabilities_pop =liabilities/city_pop *1000000
            # city_pop already noised
            # [not personal] liabilities: total liabilities in pension plan

            #--- under-population
            ### uaal_pop: UAAL divided by population (2012)  ($)
            #> from `city_analysis_0817.do` (run):
            # gen uaal_pop=uaal2012/city_pop*1000000
            # city_pop already noised
            # [not personal] uaal2012: total unfunded liabilities in 2012 ($ millions)
            #---

            #--- under-income
            ### uaal_income: UAAL  divided by total income in city
            #> from `city_analysis_0817.do` (run):
            # gen uaal_income=uaal2012/(aggregate_hh_inc/100)*1000000
            # aggregate_hh_inc: total househould income yearly 2012 ($/yr)
            # NOTE: assuming household income does not exceed 1,000,000
            "aggregate_hh_inc": lambda city: 1000000,
            #---

            ### [not personal] uaal_rev: unfunded liabilities divied by own-source revenues X 100  (%)
            ### [not personal] uaal_value: UAAL divided by total housing value in city
            ### [not personal] regd1: regional dummy 1
            ### [not personal] regd2: regional dummy 2
            ### [not personal] regd3: regional dummy 3
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="under-population",
            table=table,
            row="per_own_U55_total",
            col="est2",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="under-income",
            table=table,
            row="per_own_U55_total",
            col="est4",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="under-revenue",
            table=table,
            row="per_own_U55_total",
            col="est6",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="under-house",
            table=table,
            row="per_own_U55_total",
            col="est8",
            expected_range=(None, 0)
        ))
        return results