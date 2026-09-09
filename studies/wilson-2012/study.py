from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Wilson(Study):
    id = 'wilson-2012'

    def data_paths(self) -> dict:
        return {
            "Master.Final": os.path.join(
                self.path(), "source", "data", "Master.Final.dta"
            ),
            # "Master_Controls_and_Outcomes": os.path.join(
            #     self.path(), "source", "data", "Master_Controls_and_Outcomes.dta"
            # )
        }
    
    def load_data(self) -> dict:
        data = super().load_data()
        for key in data.keys():
            df = data[key]
            # drop columns to be computed in script
            df = df.drop(columns=[
                c for c in df.columns if c.endswith("_lessDOL")
                    or c.endswith("_lessDOL_mill_cap")
                    or c.endswith("_Percap")
                    or c.endswith("3yrMADifference")
            ])
            data[key] = df
        return data
    
    def valuelabel_colname_mapping(self) -> dict:
        return {"Fips": "state"}

    def _post_processing(self, noised_data):
        for key in noised_data.keys():
            df = noised_data[key]

            # for v in [
            #     "obl_lessDOL",
            #     "pay_lessDOL",
            #     "ann_lessDOL",
            # ]:
            #     df[f"{v}_mill_cap"] = df[v] / (df["StatePopulation"].astype('float64') * 1000)
            #     df[f"{v}_mill_cap"] = df[f"{v}_mill_cap"] / 1000000

            # reconstruct change_emp_rate
            # reconstruct taxbenefits_cap
            df["taxbenefits_cap"] = df["taxbenefits"] / (1000000*(df["StatePopulation"] * 1000))
            # reconstruct ED_instrument
            df["ED_instrument"] = df["hhs_school_age"] / df["StatePopulation"]
            # reconstructd DOT_predict_instrument
            df["DOT_predict_instrument"] = df["DOT_predict"] / (df["StatePopulation"] * 1000)
            # reconstruct HHS_instrument
            # df["HHS_instrument"] = (df["medicaid_fy2007"] / (df["StatePopulation"] * 1000))

            noised_data[key] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return {
            "pre_replication": [
                "ED_instrument"
            ],
            "post_replication": [
                "obl_lessDOL_mill_cap",
                "ann_lessDOL_mill_cap",
                "pay_lessDOL_mill_cap",
                "taxbenefits_cap",
                # "change_emp_rate",
                "RealAnnualPI_3yrMADifference",
                # "HHS_instrument",
            ] # vars constructed by authors'code
        }
    
    def other_vars(self) -> list:
        return [
            "change_emp_rate",
            "cont_drchange_emp_rate",
            "cont_lchange_emp_rate",
            "house_price_runup",
            "HHS_instrument",
            "DOT_predict_instrument",
            "ED_instrument",
            "cont"
        ]
    
    def time_index(self):
        return None # regs do not use time index
    
    def subset_index(self):
        return "state"

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Wilson_AEJEP_2012.do`: ###
        # foreach stimulus in obl_lessDOL_mill_cap ann_lessDOL_mill_cap pay_lessDOL_mill_cap {
        # ...
        # reg change_emp_rate `stimulus' RealAnnualPI_3yrMADifference taxbenefits_cap cont*change_emp_rate house_price_runup if state~=11 & time == `finaldate' 
        # ...
        # local instruments "HHS_instrument ED_instrument DOT_predict_instrument"	
        # ivregress 2sls change_emp_rate (`stimulus' = `instruments') RealAnnualPI_3yrMADifference taxbenefits_cap cont*change_emp_rate house_price_runup if state ~= 11 & time == `finaldate' , first
        ###
        vars_to_noise = {
            ### per capita variables ###
            # all constructed from StatePopulation
            #> from `Program.ExcludingDOL.do` (run):
            # gen obl_lessDOL = obligations - finaltotalobl_dlrDOL
            # gen pay_lessDOL = payments - finaltotalpd_dlrDOL
            # gen ann_lessDOL = announcements - finaltotalpd_dlrDOL
            # ...
            # foreach varname of varlist obl_lessDOL pay_lessDOL ann_lessDOL {
            #     gen `varname'_mill_cap = `varname'/(StatePopulation*1000)
            #     replace `varname'_mill_cap = `varname'_mill_cap / 1000000
            # }
            #>
            # state population is in 1000s
            "StatePopulation": lambda state: 1/1000,
            ## obl_lessDOL_mill_cap: ARRA obligations per capita
            ## ann_lessDOL_mill_cap: ARRA spending announcements per capita
            ## pay_lessDOL_mill_cap: ARRA payments per capita
            ## taxbenefits_cap = taxbenefits/(1000000*(StatePopulation*1000))

            ### change_emp_rate - change in total nonfarm employment per capita 2009 ###
            # relevant code from `Wilson_AEJEP_2012.do` (run):
            # gen PreStateEmployment_tmp = StateEmployment if time==`pre'
	        # bysort state: egen PreStateEmployment = min(PreStateEmployment_tmp)
            # gen change_emp_rate = (StateEmployment - PreStateEmployment)/popweight09
            # NOTE: could not reconstruct accurately
            # "StateEmployment": lambda state: 1,
            # "popweight09": lambda state: 1, # paper says popweight09 is 2009 population

            ### RealAnnualPI_3yrMADifference ###
            # relevant code from Program.3yrMAControls.do (run):
            # gen AnnualStatePI_cap = AnnualStatePI/(StatePopulation*1000)
            # generate RealAnnualPI_3yrMADifference = (AnnualStatePI_cap + L12.AnnualStatePI_cap + L24.AnnualStatePI_cap)/3 - (L12.AnnualStatePI_cap + L24.AnnualStatePI_cap + L36.AnnualStatePI_cap)/3 if time == ym(2006,1)
            # difference in 3yr avg of real personal income per capita 2005-2006
            # annual state PI, in millions
            # ASSUMPTION: 500,000 max personal income
            "AnnualStatePI": lambda state: 0.5, # in millions

            ### ED_instrument ###
            # state's school-aged population share
            # relevant code:
            # gen school_age_pop1 = school_age_pop if time == ym(2008,1)
            # bysort state: egen hhs_school_age = min(school_age_pop1)
            # gen ED_instrument = hhs_school_age/StatePopulation
            # NOTE: reconstructed hhs_school_age = school_age_pop1
            # NOTE: reconstructed ED_instrument = hhs_school_age/StatePopulation
            "hhs_school_age": lambda state: 1/1000,

            ### DOT_predict_instrument ###
            # per paper, constructed by regressing DOT ARRA obls on total lane miles of federal highways, total vehicle miles, estimated tax payments attributable to highway users, and FHWA obl limitations
            # relevant code:
            # reg DOT_Obligations dot_taxpayments dot_vehiclemiles dot_lanemiles dot_obligationlimitation if state ~= 11 & time == `finaldate'
            # predict DOT_predict, xb
            # gen DOT_predict_instrument = DOT_predict/(StatePopulation*1000)
            # NOTE reconstructed DOT_predict_instrument = DOT_predict/(StatePopulation*1000)
            ## [not personal data] DOT_Obligations
            ## dot_taxpayments - NOTE not clear how to compute sensitivity
            ## [not personal data] dot_vehiclemiles
            ## [not personal data] dot_lanemiles
            ## [not personal data] dot_obligationlimitation
            ### [not personal data] house_price_runup ###
            # per paper, growth in house price index

            ## HHS_instrument
            # pre-ARRA state Medicaid expenditures per capita
            # relevant code:
            # gen HHS_instrument_thousands = HHS_instrument/1000
            # gen HHS_instrument = medicaid_fy2007/(StatePopulation*1000) if time == ym(2009,1)
            # gen HHS_instrument = 0.062*(medicaid_fy2007/(StatePopulation*1000)) if time == ym(2009,1)
            # NOTE: does not reconstruct accurately
            ## [not personal data] medicaid_fy2007 --- Medicaid expenditures total

        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table5 = self._load_esttab(f"{self.path()}/results/Table5.csv")
        results.append(Result.from_esttab(
            id="ann_lessDOL_mill_cap-ivreg_T_Emp_Rate_Ann__cer",
            table=table5,
            row="ann_lessDOL_mill_cap",
            col="ivreg_T_Emp_Rate_Ann__cer",
            expected_range=Result.relative_range(8, tolerance=0.2)  # should be around 8
        ))
        results.append(Result.from_esttab(
            id="pay_lessDOL_mill_cap-ivreg_T_Emp_Rate_Pay__cer",
            table=table5,
            row="pay_lessDOL_mill_cap",
            col="ivreg_T_Emp_Rate_Pay__cer",
            expected_range=(0, None)
        ))
        return results