from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Caselli(Study):
    id = 'caselli-2013'

    def data_paths(self) -> dict:
        return {
            "amc9770": os.path.join(
                self.path(), "source/AEJ_stata_files", "amc9770.dta"
            ),
            "final1": os.path.join(
                self.path(), "source/AEJ_stata_files", "final1.dta"
            ), # created by us, for monitoring only
            "final2": os.path.join(
                self.path(), "source/AEJ_stata_files", "final2.dta"
            ) # created by us, for monitoring only
        }
    
    def vars_to_noise(self):
        # list all personal vars used in the regression
        return {
            "pre_replication": [
                "oilandgasvalue2000_cap",
                "mun_budget_revenue_cap2000",
            ],
            "post_replication": [
                "pmun_exp_funct_educ_cult2000c",
                "pmun_exp_funct_hous_urban2000c",
                "pmun_exp_funct_transport2000c",
                "pmun_exp_funct_welf2000c",
                "mun_budget_revenue2000_pred_c",
            ]
        }
    
    def _pre_processing(self, data):
        for key in self.data_paths().keys():
            df = data[key]
            print(df.columns)
            df["oilandgasvalue2000"] = df["oilandgasvalue2000_cap"] * df["population2000"]
        return data
    
    def _post_processing(self, noised_data):
        for key in self.data_paths().keys():
            df = noised_data[key]
            df["oilandgasvalue2000_cap"] = df["oilandgasvalue2000"] / df["population2000"]
            df["mun_budget_revenue_cap2000"] = df["mun_budget_revenue2000"] / df["population2000"]
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `regressions_brazil_final.do`: ###
        # use amc9770, clear
        # sort new_code_1970_1997
        # ...

        #--- oil-revenue
        # *************************************************************
        # * Table: oil revenues, royalites, and municipality revenues *
        # *************************************************************
        # ...
        # foreach var of varlist mun_budget_revenue_cap2000 ... {
        # ...
        # eststo: areg `var' oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
        # ...
        # }
        # ...

        #--- revenue-house, revenue-education, revenue-transportation, revenue-social
        # ***********************************************************************************
        # * Table: oil revenues, municipal revenues, and municipal expenditures by category *
        # ***********************************************************************************
        # use amc9770, clear
        # sort new_code_1970_1997
        # ...
        # foreach var of newlist educ_cult ... hous_urban transport welf {
        #     reg mun_exp_funct_`var'2000 mun_exp_funct_`var'2001
        #     predict pmun_exp_funct_`var'2000
        #     replace pmun_exp_funct_`var'2000 = mun_exp_funct_`var'2000 if mun_exp_funct_`var'2000!=.
        #     gen pmun_exp_funct_`var'2000c = pmun_exp_funct_`var'2000 / population2000

        #     reg mun_exp_funct_`var'1991 mun_exp_funct_`var'1992
        #     predict pmun_exp_funct_`var'1991
        #     replace pmun_exp_funct_`var'1991 = mun_exp_funct_`var'1991 if mun_exp_funct_`var'1991!=.
        #     gen pmun_exp_funct_`var'1991c = pmun_exp_funct_`var'1991 / population1991

        #     gen ch_pmun_exp_funct_`var'_c = pmun_exp_funct_`var'2000c-pmun_exp_funct_`var'1991c
        #     }
        # ...
        # foreach var of varlist pmun*2000c {
        # ...
        # eststo: ivreg `var' (mun_budget_revenue2000_pred_c=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust 
        # ...
        # }
        sensitivities = {
            ### oilandgasvalue2000_cap: "Total municipal revenues per capita in 2000"
            # assuming oilandgasvalue2000_cap = oilandgasvalue2000 / population2000
            # NOTE: reconstructed oilandgasvalue2000 = oilandgasvalue2000_cap * population2000
            # [not personal] oilandgasvalue2000
            "population2000": lambda amc: 1,

            #--- oil-revenue
            ### mun_budget_revenue_cap2000: "Municipal revenues per capita in 2000"
            # NOTE: reconstructed mun_budget_revenue_cap2000 = mun_budget_revenue2000 / population2000
            # population2000 already noised
            
            #--- revenue-house, revenue-education, revenue-transportation, revenue-social
            ### pmun*2000c: Predicted municipal functional expenditures per capita in 2000
            #> from `regressions_brazil_final.do`:
            # reg mun_exp_funct_`var'2000 mun_exp_funct_`var'2001
            # predict pmun_exp_funct_`var'2000
            # replace pmun_exp_funct_`var'2000 = mun_exp_funct_`var'2000 if mun_exp_funct_`var'2000!=.
            # gen pmun_exp_funct_`var'2000c = pmun_exp_funct_`var'2000 / population2000
            #>
            # population2000 already noised above
            # [not personal] mun_exp_funct_`var'2000, mun_exp_funct_`var'2001: municipal functional expenditures from 2000, 2001
            ## pmun_exp_funct_educ_cult2000c
            ## pmun_exp_funct_hous_urban2000c
            ## pmun_exp_funct_transport2000c
            ## pmun_exp_funct_welf2000c

            ### mun_budget_revenue2000_pred_c: "The predicted municipal revenues per capita in 2000"
            #> from `regressions_brazil_final.do`:
            # gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000
            #>
            # [not personal] mun_budget_revenue2000_pred
            # population2000 already noised

            ### [not used] pred_chmun_budget_revenue_cap: "Change in total municipal revenues per capita from 1991–2000" 
            #> from `regressions_brazil_final.do`:
            # gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991
            # gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c
            #>
            # mun_budget_revenue2000_pred_c already noised
            # [not personal] mun_budget_revenue1991_pred
            # "population1991": lambda municipality: 1,
            ### [not personal] longitude
            ### [not personal] latitude
            ### [not personal] coast: "coast dummy"
            ### [not personal] coastal: "coastal dummy"
            ### [not personal] onshore: "onshore dummy"
            ### [not personal] state_capital: "state capital dummy"
            ### [not personal] dist*
            ## dist_federal_capital1998: "distance to the federal capital"
            ## dist_state_capital1998: "distance to the state capital"
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="oil-revenue",
            table=table,
            row="oilandgasvalue2000_cap",
            col="est1",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="revenue-house",
            table=table,
            row="mun_budget_revenue2000_pred_c",
            col="est3",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="revenue-education",
            table=table,
            row="mun_budget_revenue2000_pred_c",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="revenue-transportation",
            table=table,
            row="mun_budget_revenue2000_pred_c",
            col="est4",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="revenue-social",
            table=table,
            row="mun_budget_revenue2000_pred_c",
            col="est5",
            expected_range=(0, None)
        ))
        return results