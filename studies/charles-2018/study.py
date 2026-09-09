from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Charles(Study):
    id = 'charles-2018'

    def data_paths(self) -> dict:
        return {
            "msa_education_2000_2013_same": os.path.join(
                self.path(), "source/chn_housing_booms_and_college/chn", "msa_education_2000_2013_same.dta"
            ),
            "analysis_sample_FINAL_v2_main_same": os.path.join(
                self.path(), "source/chn_housing_booms_and_college/chn", "analysis_sample_FINAL_v2_main_same.dta"
            ),
            "controls": os.path.join(
                self.path(), "source/chn_housing_booms_and_college/chn", "controls.dta"
            ), # created by authors; including only for monitoring
            # "post_replication": os.path.join(
            #     self.path(), "source/chn_housing_booms_and_college", "post_replication.dta"
            # ),  # created by us; including only for monitoring
            # "share_foreign": os.path.join(
            #     self.path(), "source/chn_housing_booms_and_college/chn", "share_foreign.dta"
            # ),
            # ...
        }
    
    def vars_to_noise(self):
        # list all personal vars used in the regression
        return {
            "post_replication": [
                "d_any_18_25_a1",
                "d_bachelor_18_25_a1",
                "pop_prev",
                "wgt",
                "college_share_2000",
                "female_employed_share_2000"
                # "share_foreign_18_55_2000"
            ]
        }
    
    def _pre_processing(self, data):
        return data
    
    def _post_processing(self, noised_data):
        noised_data["analysis_sample_FINAL_v2_main_same"]["pop_prev"] = np.log(
            noised_data["analysis_sample_FINAL_v2_main_same"]["pop_msa_all_2000"]
        )
        return noised_data

    def sensitivity_matrix(self) -> dict:
        # NOTE: skipping build.do to make processing simpler

        ### relevant code from `main.do`: ###
        # use  ./chn/analysis_sample_FINAL_v2_main_same.dta, replace
        # capture drop pop_prev
        # gen pop_prev = log(pop_18_25_00 + pop_26_55_00)
        # gen female_employed_share_2000 = emp_f_00 / pop_f_00
        # gen college_share_2000 = (emp_me_00 + emp_he_00) / emp_tot_00
        # keep metarea pop_prev female_employed_share_2000 college_share_2000
        # sort metarea
        # save ./chn/controls.dta, replace
        ###

        ### relevant regression code from `table3_educ.do`: ###
        # use "./chn/msa_education_2000_2013_same.dta
        # ...
        # merge metarea using chn/xwalk_metarea_to_state_and_region.dta, uniqusing
        # ...
        # merge metarea using chn/main_data.dta, uniqusing uniqmaster
        # ...
        # merge metarea using ./chn/share_foreign.dta, uniqusing uniqmaster
        # ...
        # merge metarea using ./chn/controls.dta, uniqusing uniqmaster
        # ...

        ## house-college
        # global controls = "college_share_2000 female_employed_share_2000 pop_prev share_foreign_18_55_2000"
        # replace wgt = exp(pop_prev)
        # ...
        # ivreg2 d_any_18_25`type'a1 (housing_demand_shock = iv) $controls [aw=wgt], cluster(statefip)
        # post_param "Fstat" e(widstat)
        # est store iv1

        ## house-bachelor
        # ** 
        # ** Only report Bachelors for 00-06
        # **
        # if ("`3'" == "") {
        # ivreg2 d_bachelor_18_25`type'a1 (housing_demand_shock = iv) $controls [aw=wgt], cluster(statefip)
        # post_param "Fstat" e(widstat)
        # est store iv2
        # }
        ###

        sensitivities = {
            #### FROM msa_education_2000_2013_same
            ### d_`level'_18_25_a1: Dependent variable is 2000–2006 change in share with `level` education
            #> from `table3_educ.do`: #
            # local type = "`1'"
            # ...
            # local first = "2000"
            # local last = "2007"
            # local num = "3"
            # ...
            # local levels = "assoc bachelor any"
            # foreach level of local levels {
            # gen d_`level'_26_33`type'a1 = (`level'_26_33`type'`last')/(pop_26_33`type'`last')  - ///
            # (`level'_26_33`type'`first')/(pop_26_33`type'`first') 
            # gen d_`level'_18_25`type'a1 = (`level'_18_25`type'`last')/(pop_18_25`type'`last')  - ///
            # (`level'_18_25`type'`first')/(pop_18_25`type'`first') 
            # }
            #>
            # d_`level'_18_25_a1 = (`level'_18_25_2007)/(pop_18_25_2007) - (`level'_18_25_2000)/(pop_18_25_2000)`
            # gen pop_18_25_`year' = pop_22_25_`year' + pop_18_21_`year'
            "pop_18_21_2000": lambda msa: 1,
            "pop_18_21_2007": lambda msa: 1,
            "pop_22_25_2000": lambda msa: 1,
            "pop_22_25_2007": lambda msa: 1,

            ## d_any_18_25_a1: Dependent variable is 2000–2006 change in share with college education
            # gen any_18_25_`year' = any_college_22_25_`year' + any_college_18_21_`year'
            # any_`age'_`year': count of people with any college edu in age group in year 
            "any_college_18_21_2000": lambda msa: 1,
            "any_college_18_21_2007": lambda msa: 1,
            "any_college_22_25_2000": lambda msa: 1,
            "any_college_22_25_2007": lambda msa: 1,
            # pop* already noised

            ## d_bachelor_18_25_a1: Dependent variable is 2000–2006 change in share with bachelor education
            # gen bachelor_18_25_`year' = bachelor_22_25_`year' + bachelor_18_21_`year'
            # bachelor_`age'_`year': count of people with bachelor's in age group in year 
            "bachelor_18_21_2000": lambda msa: 1,
            "bachelor_18_21_2007": lambda msa: 1,
            "bachelor_22_25_2000": lambda msa: 1,
            "bachelor_22_25_2007": lambda msa: 1,
            ####

            #### FROM analysis_sample_FINAL_v2_main_same -> controls.dta
            ### pop_prev: The log of the MSA’s total population as measured in 2000
            # gen pop_prev = log(pop_18_25_00 + pop_26_55_00) 
            #> from `main.do`:
            # capture drop pop_prev
            # gen pop_prev = log(pop_18_25_00 + pop_26_55_00)
            # ...
            # gen pop_prev = log(pop_tot_00)
            #>
            # to be safe, noising all the options, but theoretically just pop_tot_00 should be enough
            "pop_msa_all_2000": lambda msa: 1,
            "pop_18_25_00": lambda msa: 1,
            "pop_26_55_00": lambda msa: 1,
            "pop_tot_00": lambda msa: 1,
            
            ### wgt: regression weight, MSA’s total population
            #> from table3_educ.do:
            # replace wgt = exp(pop_prev)
            #>
            # pop_prev already noised

            ### college_share_2000: the share of employed workers with a college degree
            # gen college_share_2000 = (emp_me_00 + emp_he_00) / emp_tot_00
            "emp_me_00": lambda msa: 1,  # middle ed
            "emp_he_00": lambda msa: 1,  # high ed
            "emp_tot_00": lambda msa: 1,  # total employed

            ### female_employed_share_2000: the share of women in the labor force
            # gen female_employed_share_2000 = emp_f_00 / pop_f_00
            "emp_f_00": lambda msa: 1,
            "pop_f_00": lambda msa: 1,
            ####
            
            #### FROM share_foreign.dta
            ### share_foreign_18_55_2000: the fraction of the MSA that is foreign-born
            # assuming share_foreign_18_55_2000 = foreign_18_55_2000 / pop_18_55_2000
            # NOTE: cannot noise, numerator/denominator not provided in this dta file
            ####

            ### [not personal] housing_demand_shock: We use as a proxy for local housing demand the sum of changes in both local housing prices and quantities. 
            # egen units_sum_04_06 = rowmean(units2004-units2006)
            # egen units_sum_98_00 = rowmean(units1998-units2000)
            # gen units_growth = log(units_sum_04_06) - log(units_sum_98_00)
            # gen housing_demand_shock = deltaP + units_growth
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="house-college",
            table=table,
            row="housing_demand_shock",
            col="iv1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="house-bachelor",
            table=table,
            row="housing_demand_shock",
            col="iv2",
            expected_range=(0, 0)
        ))
        return results