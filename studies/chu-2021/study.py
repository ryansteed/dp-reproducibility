from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Chu(Study):
    id = 'chu-2021'

    def data_paths(self) -> dict:
        return {
            "AEJ_main": os.path.join(
                self.path(), "source", "AEJ_main.dta"
            ),
            # "AEJ_firm": os.path.join(
            #     self.path(), "source", "AEJ_firm.dta"
            # )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        return {
            "pre_replication": [
                "lngdppc",
                "edu"
            ],
            "post_replication": [
                "lnpop"
            ]
        }
    
    def _pre_processing(self, data):
        for key in data.keys():
            df = data[key]

            if key == "AEJ_main":
                # deconstruct pop
                df["pop1"] = df["pop"] * 10000
                # deconstruct lngdppc
                df["gdp"] = np.exp(df["lngdppc"]) * df["pop1"]
                # deconstruct edu
                df["edu_total"] = df["edu"] * df["pop1"]
        
        return data
    
    def _post_processing(self, noised_data):
        for key in noised_data.keys():
            df = noised_data[key]

            if key == "AEJ_main":
                # reconstruct pop
                df["pop"] = df["pop1"] / 10000
                # reconstruct lngdppc
                df["lngdppc"] = np.log(df["gdp"] / df["pop1"])
                # reconstruct edu
                df["edu"] = df["edu_total"] / df["pop1"]

        
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `AEJ_do.do`: ###
        # use "AEJ_main", clear 
        # ...
        # * Control variables defined that will be used throughout
        # global auditorvar "male age tenure tenure2 edulevel edufin fromaud fromfin fromsup fromcitygov" 
        # global cityvar "lngdppc sec lnpop lngovrev govbalance finv edu "
        # global allvar "$auditorvar $cityvar"
        # ...

        #--- hometown-audit
        # local outcome "violate3"
        # ...
        # eststo m1: reghdfe `outcome' local_city $allvar, absorb(year icity)  cluster(icity)
        # ...

        #--- post2013-hometown
        # local outcome "violate3"
        # ...
        # eststo m2: reghdfe `outcome' local_city local_city_post2013 $allvar post2013*, absorb(year icity)  cluster(icity)
        # ...

        # local outcome "violate3"
        # ...
        #--- firstyear-hometown
        # eststo m1: reghdfe `outcome' $allvar local_city year1 local_city_year1, absorb(year icity )  cluster(icity)
        # ...
        #--- tenure-hometown
        # eststo m2: reghdfe `outcome' $allvar local_city local_city_tenure , absorb(year icity )  cluster(icity)
        # ...
        #--- tenure2-hometown
        # eststo m3: reghdfe `outcome' $allvar local_city local_city_tenure local_city_tenure2, absorb(year icity )  cluster(icity)
        # ...

        # NOT USED ----
        #--- hometown-soe
        # use "AEJ_firm.dta", clear
        # ...
        # global auditorvar "male age tenure tenure2 edulevel edufin fromaud fromfin fromsup fromcitygov"
        # global firmvar "lnta lev roa mb largest board dual indep manshare big4"
        # global cityvar "lngdppc sec lngovrev govbalance finv edu "
        # global allvar "$auditorvar $firmvar $cityvar"
        # ...
        # keep if lsoe==1
        # ...
        # eststo m4: reghdfe rm local_city $auditorvar $firmvar $cityvar , absorb(year firmid) cluster(icity)
        ###
        sensitivities = {
            #------ AEJ_main ----------------
            ### lngdppc: log(GDP (unit 1RMB)/population (unit 1 person)
            # lngdppc = log(gdp/pop1)
            # created var gdp = exp(lngdppc) * pop1
            # gdp not personal
            # noised pop1 below

            ### edu: average number of years of education, province-level
            # assuming edu = edu_total / pop1
            # pop1 noised below
            # NOTE: created var edu_total = edu * pop1
            # assuming max years of education is clipped at 10
            "edu_total": lambda city: 10,

            ### lnpop: logarithm of city population
            #> from `AEJ_do.do` (run):
            # gen lnpop=log(pop)
            #>
            # pop: population, unit: 10k
            # NOTE: created var pop1 = pop * 10000
            "pop1": {
                "sensitivity": lambda city: 1,
                "lb": 1
            },

            ### [not personal] sec: ratio of industrial output to total GDP
            ### [not private] lngovrev: ln(fiscal revenue of the city (unit: 10k RMB)
            ### [not private] govbalance: fiscal expenditure (unit 10k RMB)/fiscal revenue of the city (unit 10k RMB)
            ### [not private] finv: FDI/GDP
            ### [not personal] violate3: log(sus money: unit: 10k RMB), ln(total questionable expenditures found during the audit)
            ### [microdata, arguably public] male: gender of the chief auditor
            ### [microdata, arguably public] age: age of the chief auditor
            ### [microdata, arguably public] tenure: tenure of the chief auditor
            ### [microdata, arguably public] tenure2: tenure^2
            ### [microdata, arguably public] edulevel: education of the chief auditor
            ### [microdata, arguably public] edufin: whether chief auditor has a finance background
            ### [microdata, arguably public] fromaud
            ### [microdata, arguably public] fromfin
            ### [microdata, arguably public] fromsup
            ### [microdata, arguably public] fromcitygov
            ### [microdata, arguably public] local_city: whether the chief auditor of the province was born in the focal city
            ### [microdata, arguably public] local_city_post2013
            #> from `AEJ_do.do` (run):
            # gen local_city_post2013=local_city*post2013
            #>
            # local_city: local city dummy
            ### [not personal] post2013*: whether the year is greater than or equal to 2013
            ### [microdata, arguably public] year1
            # gen year1=tenure==1
            ### [microdata, arguably public] local_city_year1
            # gen local_city_year1=year1*local_city
            ### [microdata, arguably public] local_city_tenure
            # foreach var in tenure tenure2 {
            #     gen local_city_`var'=`var'*local_city
            # }
            ### [microdata, arguably public] local_city_tenure2

            # NOT USED ---
            #------ AEJ_firm ----------------
            #--- hometown-soe
            ### [not personal] rm: real earnings management(total value)
            ### [not personal] lnta: ln(total asset)
            ### [not personal] lev: total liabilities/total assets
            ### [not personal] roa: ROA
            ### [not personal] mb: market-to-book ratio
            ### [not personal] largest: shareholding ratio of the largest shareholder
            ### [not personal] board: log board members
            ### [not personal] dual: chairmain is the CEO
            ### [not personal] indep: number of independent directors / total number of board members
            ### [not personal] manshare: management shareholding ratio
            ### [not personal] big4: Big4Audit
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="hometown-audit",
            table=table,
            row="local_city",
            col="m1",
            expected_range=Result.relative_range(-0.471, tolerance=0.2)
        ))
        table = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="post2013-hometown",
            table=table,
            row="local_city_post2013",
            col="m2",
            expected_range=(0, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table5.csv")
        results.append(Result.from_esttab(
            id="firstyear-homwtown",
            table=table,
            row="local_city_year1",
            col="m1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="tenure-hometown",
            table=table,
            row="local_city_tenure",
            col="m2",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="tenure2-hometown",
            table=table,
            row="local_city_tenure2",
            col="m3",
            expected_range=(0, 0)
        ))
        # NOT USED — not enough info for DP
        # table = self._load_esttab(f"{self.path()}/results/table8.csv")
        # results.append(Result.from_esttab(
        #     id="hometown-soe",
        #     table=table,
        #     row="local_city",
        #     col="m4",
        #     expected_range=(0, None)
        # ))
        return results