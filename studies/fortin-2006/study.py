from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Fortin(Study):
    id = 'fortin-2006'

    def data_paths(self) -> dict:
        return{
            "cpseddata": os.path.join(
                self.path(), "source", "cpseddata.dta"
            ),
            "edyrly": os.path.join(
                self.path(), "source", "edyrly.dta"
            ),
            # "final5": os.path.join(
            #     self.path(), "source", "final5.dta"
            # ),
            # ...
        }
    
    def _pre_processing(self,data):
        for key in self.data_paths().keys():
            df = data[key]
            if key == "edyrly":
                df["colage"] = np.exp(df["lncolage"])
                df["enroll_pub"] = np.exp(df["lntenpc"]) * df["colage"]
                df["lnsta"] = np.exp(df["lnstapc"]) * df["colage"]
                # print(df[["enroll_pub", "colage"]].describe())
            if key == "cpseddata":
                # cpseddata has colage in 10,000s; edyrly does not
                df["colage"] = np.exp(df["lncolage"]) * 10000
                df['enroll_pri'] = np.exp(df['lnpricol']) * df['colage']
                df['enroll_pub'] = np.exp(df['lnpubcol']) * df['colage']
                df["lnstap"] = np.exp(df["lnstappc"]) * df["colage"]
                # print(df[["enroll_pri", "colage"]].describe())
        return data
    
    def _post_processing(self,noised_data):
        for key in self.data_paths().keys():
            df = noised_data[key]
            if key == "edyrly":
                df["lncolage"] = np.log(df["colage"])
                df["lntenpc"] = np.log(df["enroll_pub"] / df["colage"])
                df["lnstapc"] = np.log(df["lnsta"] / df["colage"])
            if key == "cpseddata":
                df["lncolage"] = np.log(df["colage"] / 10000)
                df["lnpricol"] = np.log(df["enroll_pri"] / df["colage"])
                df["lnpubcol"] = np.log(df["enroll_pub"] / df["colage"])
                df["lnstappc"] = np.log(df["lnstap"] / df["colage"])
            noised_data[key] = df
        return noised_data
    
    
    def vars_to_noise(self):
        return {
            "pre_replication": [
                "pop",
                "lncolage",
                "lntenpc",
                "lnstapc",
                # "ygrsup",
                # "oldrsup",
                # "lnurate",
                # "GAP",
                # "vwgt",
                # "lnurate",
                "lnpricol"
            ],
            "post_replication": [
                "ppubnc"
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Table2_3.do`
        ## Table 2, col 3 -- owncor-sup
        # use cpseddata.dta;
        # ...
        # eststo owncorsup: reg GAP ygrsup oldrsup lnurate time time2 stdum* [weight=vwgt] , robust ;
        ###
        
        ### relevant regression code from `Table4.do`
        ## Table 4, col 1 -- lnstapc-enroll
        # use edyrly;
        # ...
        # eststo lnstapcenroll: reg lntenpc lncolage lnstapc lnavtui stdum1-stdum50 time  yrd* trst1-trst50 tr2st1-tr2st50 [weight=pop] , robust ;
        ###
        
        ### relevant regression code from `Table5.do`
        ## Table 5, col 5 -- owncor-sup-3
        # use cpseddata.dta;
        # ...
        # eststo owncorsup3: ivreg GAP (ygrsup=ppubnc lnpricol) oldrsup lnurate time time2 stdum*  [weight=vwgt] , robust ;
        ###

        ###
        vars_to_noise = {
            #-- owncor-sup, owncor-sup-3
            ### GAP: COLLEGE–HIGH SCHOOL LOG WAGE PREMIUM FOR WORKERS AGE 26 –35 
            # GAP = log ( college_wages / high_school_wages )
            # wage_pre: % difference between wages of college grads vs high school grads
            # NOTE: college wages or high school wages not provided in dataset; not enough info for DP sensitivity analysis

            ### ygrsup: Own-cohort relative supply ln(CY/HY)
            # ygrsup = log ( youngcolage / younghighschool )
            # NOTE: younger_workers or older_workers not provided in dataset; not enough info for DP sensitivity analysis

            ### oldrsup: Relative supply of older workers ln(CO/HO)
            # oldsup = log ( oldcolage / oldhighschool )
            # NOTE: older_workers or young_workers not provided in dataset; not enough info for DP sensitivity analysis

            ### lnurate: Log state unemployment rate
            # lnurate = log(num_employed / num_employees)
            # NOTE: num employees not provided, not enough info for DP

            ### vwgt: [paper] weights are the inverse of the sampling variance of the estimated wage premia
            # NOTE: not enough info for wage premia
            #--
            
            #-- lnstapc-enroll
            ### pop: population weights
            "pop": {
                "sensitivity": lambda stateyear: 1,
                "lb": 0
            },
            # ...

            ### lncolage: Log college-age population
            # comparing to edyrly, looks like pop is in 10,000s (despite paper summary stats)
            # NOTE: created  new var colage = exp(lncolage) * 1000
            "colage": lambda stateyear: 1,
            
            ### lntenpc: STATE LOG FTE-4YR PUBLIC ENROLLMENT RATES
            # lntenpc = log(enroll_pub / colage)
            # NOTE: created new var enroll_pub = exp(lntenpc) * colage
            "enroll_pub": lambda stateyear: 1,
            # already adding noise to lncolage

            ### lnstapc: Log state appropriations per college-age person
            # assuming lnstapc = log(sta / colage)
            # NOTE: created new var lnsta = exp(lnstapc) * colage
            # lnsta not private
            # colage already noised

            #-- owncor-sup-3
            ### ppubnc: Predicted log FTE 4-yr public enrollment per college-age person (predicted value)
            # created in authors' code Table5.do
            #> reg lnpubcol lncolage lnavtui lnstappc time stdum*  [weight=vwgt];
            #> predict ppubnc;
            # lncolage, vwgt already noised
            # lnavtui not private
            ## lnpubcol: Log FTE 4-yr public enrollment per college-age person
            # NOTE: created new var enroll_pub = exp(lnpubcol + lncolage)
            "enroll_pub": lambda ststateyearate: 1,
            ## lnstappc: Log state appropriations per college-age person
            # lnstappc = log(sta / colage)
            # NOTE: created new var lnsta = exp(lnstappc) * colage
            # lnsta not private
            # colage already noised

            ### lnpricol: Log FTE 4-yr private enrollment per college-age person
            # lnpricol = log(enroll_pri / colage) = log(enroll_pri) - lncolage
            # NOTE: created new var enroll_pri = exp(lnpricol + lncolage)
            "enroll_pri": lambda stateyear: 1,
            # colage noised above
            #--

            ### [not private] lnavtui: Log average public tuition
            ### [not private] stdum1-stdum50: State dummies
            ### [not private] time: time dummy
            ### [not private] trst*: time/state interactions
            ### [not private] lnavtui: Log average public tuition
        }
        return vars_to_noise

    
    def extract_results(self) -> list[Result]:
        results = []
        ## removed — not enough info for DP
        # table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        # results.append(Result.from_esttab(
        #     id="owncor-sup",
        #     table=table1,
        #     row="ygrsup",
        #     col="owncorsup",
        #     expected_range=(None, 0)
        # ))
        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="lnstapc-enroll",
            table=table2,
            row="lnstapc",
            col="lnstapcenroll",
            expected_range=(0, None)
        ))
        table3 = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="owncor-sup-3",
            table=table3,
            row="ygrsup",
            col="owncorsup3",
            expected_range=(None, 0)
        ))
        return results