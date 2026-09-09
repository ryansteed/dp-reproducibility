from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Bell(Study):
    id = 'bell-2022'

    def data_paths(self) -> dict:
        return {
            # Table 6
            # "cps_attendance_all_states": os.path.join(
            #     self.path(), "source", "Data", "cps_attendance_all_states.dta"
            # ),
            # Table 3
            "arrest_data_discontinuity_states": os.path.join(
                self.path(), "source", "Data", "arrest_data_discontinuity_states.dta"
            ),
        }
    
    def _pre_processing(self, data: pd.DataFrame) -> pd.DataFrame:
        table3data = "arrest_data_discontinuity_states"
        
        data[table3data]["arrest_rate_tot"] = np.exp(
            data[table3data]["log_arrest_rate_tot"]
        )
        data[table3data]["arrest_rate_tot"] = np.exp(
            data[table3data]["log_arrest_rate_tot"]
        )
        data[table3data]["arrests"] = data[table3data]["arrest_rate_tot"] * data[table3data]["population_est_cell"]

        data[table3data]["police"] = np.exp(
            data[table3data]["log_police"]
        )

        data[table3data]["black"] = \
            data[table3data]["pop_share_black"] * data[table3data]["population_est_cell"]
        
        data[table3data]["female"] = \
            data[table3data]["share_female_pop"] * data[table3data]["population_est_cell"]
        
        data[table3data]["other"] = \
            data[table3data]["pop_share_other"] * data[table3data]["population_est_cell"]
        
        return data
    
    def _post_processing(self, data: pd.DataFrame) -> pd.DataFrame:
        table3data = "arrest_data_discontinuity_states"
        
        data[table3data]["arrest_rate_tot"] = np.where(
            data[table3data]["population_est_cell"] == 0, # only happens 30 times
            data[table3data]["arrest_rate_tot"], # keep the old value
            data[table3data]["arrests"] / data[table3data]["population_est_cell"]
        )
        data[table3data]["log_arrest_rate_tot"] = np.log(
            data[table3data]["arrest_rate_tot"]
        )

        data[table3data]["log_police"] = np.log(
            data[table3data]["police"]
        )
        
        data[table3data]["log_pop"] = np.where(
            data[table3data]["population_est_cell"] == 0,
            data[table3data]["log_pop"], # keep the old value
            np.log(data[table3data]["population_est_cell"])
        )
        
        data[table3data]["pop_share_black"] = np.where(
            data[table3data]["population_est_cell"] == 0,
            data[table3data]["pop_share_black"], # keep the old value
            data[table3data]["black"] / data[table3data]["population_est_cell"]
        )
        
        data[table3data]["share_female_pop"] = np.where(
            data[table3data]["population_est_cell"] == 0,
            data[table3data]["share_female_pop"],
            data[table3data]["female"] / data[table3data]["population_est_cell"]
        )
        
        data[table3data]["pop_share_other"] = np.where(
            data[table3data]["population_est_cell"] == 0,
            data[table3data]["pop_share_other"],
            data[table3data]["other"] / data[table3data]["population_est_cell"]
        )
        
        return data
    
    def vars_to_noise(self) -> list:
        return [
            "log_arrest_rate_tot",
            "population_est_cell",
            "log_pop",
            "log_police",
            "pop_share_black",
            "share_female_pop",
            "pop_share_other"
        ]
    
    def other_vars(self) -> list:
        return [
            "disc",
            "crime_type",
            "age",
            "disc_id"
        ]
    
    def subset_index(self):
        return "fcounty"
    
    def time_index(self):
        return None
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Table 3.do`:
        # * ALL REFORMS - COLUMN (1)
        # reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if crime==1  & age<=18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
        # ...
        # qui: keep if   crime==1  & age<=18
        # qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
        # qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
        # ...
        # reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1  & age>18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
        # ...                                   
        # qui: keep if   crime==1  & age>18
        # qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
        # qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
        ###
        ### vars
        # - disc: discontinuity indicator [not personal data]
        # - crime: crime type [not personal data, just a marker for the row]
        # - age: age group [not personal data, just a marker for the row]
        # - log_arrest_rate_tot: Log Arrest Rate Total Across Crime Types
        # - population_est_cell: population cell (age, year, county)
        # - log_police: Log Police Officers
        # - log_pop: Log Population Cell
        # - pop_share_black: Share Black Population
        # - share_female_pop:  Share Female Population
        # - pop_share_other: Share Other Population
        ###
        
        ### `Table 6.do`: only personal data is mysterious weights
        # * 5 Year
        # * Regression
        # reghdfe school_hs disc [aw=weight] if time>=-5 & time<=4 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 , a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) cl(disc_id)
        # ...
        # * Bootstrap
        # qui: keep if time>=-5 & time<=4 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 
        # qui: hdfe school_hs disc [aw=weight], a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) gen(r_) clustervars(disc_id)
        # qui: reg r_* [aw=weight], cl(disc_id) nocons
        # boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
        # ...
        ###
        ### vars
        # - school_hs: high school attendance indicator
        # - weight: in Table 6, everything is an indicator except weight. weight is 
        ###

        vars_to_noise = {
            ## log_arrest_rate_tot: Log Arrest Rate Total Across Crime Types
            # CREATED INTER VAR arrests
            # NOTE ASSUMPTION: individual can have at most one arrest (or, protecting arrest record-level)
            "arrests": lambda county: 1,

            ## population_est_cell: population cell (age, year, county)
            "population_est_cell": {
                "sensitivity": lambda county: 1,
                "lb": 0
            },
            ## log_pop: Log Population Cell
            # RE-COMPUTED log_pop from population_est_cell in post

            ## log_police: Log Police Officers
            # CREATED INTERMEDIATE VAR POLICE
            "police": lambda county: 1,

            ## pop_share_black: Share Black Population
            # CREATED INTERMEDIATE VAR BLACK
            "black": lambda county: 1,

            ## share_female_pop:  Share Female Population
            # CREATED INTERMEDIATE VAR FEMALE
            "female": lambda county: 1,

            ## pop_share_other: Share Other Population
            # CREATED INTERMEDIATE VAR OTHER
            "other": lambda county: 1,
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        # table6 = self._load_mat2txt(f"{self.path()}/results/Table6A.txt")
        table3 = self._load_mat2txt(f"{self.path()}/results/Table3.txt")

        def se_from_95ci(lb, ub):
            return (ub - lb) / (2 * 1.96)

        # don't think this one is possible to add noise,
        # b/c uses mysterious (population?) weights not derived in code
        # results.append(Result(
        #     id="reform-attendance",
        #     est=table6.loc["Coefficient", "5-year"],
        #     se=se_from_95ci(
        #         table6.loc["CI_l", "5-year"],
        #         table6.loc["CI_u", "5-year"]
        #     ),
        #     p=table6.loc["P-value", "5-year"],
        #     N=table6.loc["N_obs", "5-year"],
        #     expected_range=(0, None) # original 95 CI
        # ))

        coef1 = Result(
            id="reform-arrestrate1518",
            est=table3.loc["Coefficient", "<18"],
            se=se_from_95ci(
                table3.loc["CI_l", "<18"],
                table3.loc["CI_u", "<18"]
            ),
            p=table3.loc["P-value", "<18"],
            N=table3.loc["N_obs", "<18"]
        )
        coef2 = Result(
            id="reform-arrestrate1924",
            est=table3.loc["Coefficient", ">=18"],
            se=se_from_95ci(
                table3.loc["CI_l", ">=18"],
                table3.loc["CI_u", ">=18"]
            ),
            p=table3.loc["P-value", ">=18"],
            N=table3.loc["N_obs", ">=18"],
            expected_range=(-0.069, 0)
        )
        coef1.expected_range = (None, float(coef2.est))
        coef2.expected_range = (float(coef1.est), 0)
        results += [coef1, coef2]
        return results