from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Drago(Study):
    id = 'drago-2014'

    def data_paths(self) -> dict:
        return {
            "meet_the_press_data_elections": os.path.join(
                self.path(), "source/AEJApp-2013-0038_meet_the_press_dataset_and_readme", "meet_the_press_data_elections.dta"
            ),
            # "meet_the_press_data_readership": os.path.join(
            #     self.path(), "source/AEJApp-2013-0038_meet_the_press_dataset_and_readme", "meet_the_press_data_readership.dta"
            # )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["meet_the_press_data_elections"]

        # deconstruct logpop_res_tagliacarne
        df["pop_res_tagliacarne"] = np.exp(df["logpop_res_tagliacarne"])

        # deconstruct turnout
        df["votes"] = df["turnout"].astype('float64') * df["pop_res_tagliacarne"].astype('float64')

        data["meet_the_press_data_elections"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["meet_the_press_data_elections"]

        # reconstruct du_diff_news_TOT
        # df["log_unem"] = np.log(df["empl_not"])
        # df["diff_log_unem"] = df["log_unem"].diff()

        # reconstruct diff_logpop_res_tagliacarne
        df["logpop_res_tagliacarne"] = np.log(df["pop_res_tagliacarne"])
        df["diff_logpop_res_tagliacarne"] = df.groupby("id_city_istat_2009")["logpop_res_tagliacarne"].diff()

        # reconstruct diff_turnout
        df["turnout"] = df["votes"] / df["pop_res_tagliacarne"]
        df["diff_turnout"] = df.groupby("id_city_istat_2009")["turnout"].diff()

        noised_data["meet_the_press_data_elections"] = df
        return noised_data

    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            # "diff_log_unem",
            "diff_logpop_res_tagliacarne",
            "diff_turnout"
        ]   
    
    def other_vars(self):
        return [
            "diff_log_unem",
            "diff_avg_rev_collect",
            "diff_reelected",
            "diff_own_espresso",
            "diff_own_rcs", 
            "diff_own_caltagirone",
            "diff_own_lastampa",
            # "diff_own_athesis", # no variance
            "diff_own_sesaab",
            "diff_own_edisud",
            "diff_own_monrif",
            "diff_own_ciarrapico",
            "diff_delta_log_comm",
            "diff_delta_log_finan",
            "du_diff_news_TOT",
            "recandidate",
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "id_city_istat_2009" # Municipality identifier from ISTAT in year 2009

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table4.do`: ###
        # use meet_the_press_data_elections , clear
        # ...
        #--- news-turnout
        # eststo newsturnout: areg diff_turnout du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne , r cluster(id_city_istat_2009) absorb(group_year_areageog)
        #--- news-reelected
        # keep if recandidate==1
        # eststo newsreelected: areg  diff_reelected du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
        ###
        ### relevant regression code from `table6.do`: ###
        # use meet_the_press_data_elections , clear
        # foreach var of varlist avg_rev_collect avg_expend_speed {
        # eststo `var': areg  diff_`var' du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
        # }
        ###
        sensitivities = {
            ### diff_log_unem: differenced Log of the provincial unemployment rate
            # log_unem = log(empl_not)
            # NOTE: # workers not given, not enough info for DP

            ### diff_logpop_res_tagliacarne: differenced Log of the population of the province
            # NOTE: reconstructed diff_logpop_res_tagliacarne = diff(logpop_res_tagliacarne)
            # NOTE: created var pop_res_tagliacarne = exp(logpop_res_tagliacarne)
            "pop_res_tagliacarne": lambda provinceyear: 1,

            #--- news-turnout
            ### diff_turnout: diff in turnout (as % of voting pop)
            # NOTE: assuming pop is voting age
            # turnout = votes / pop
            # NOTE: created var votes = turnout * pop
            # pop already noised
            "votes": lambda provinceyear: 1,

            ### [not personal] diff_avg_rev_collect: average value of revenue collection
            ### [not personal] diff_reelected: diff reelected to the next term
            ### [not personal] diff_own*: ownership dummies
            ### [not personal] diff_delta_log*: log of changes in # of new and ceased firms in commercial & financial sectors
            ### [not personal] du_diff_news_TOT: differenced average of newspaper entry

        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="news-turnout",
            table=table,
            row="du_diff_news_TOT",
            col="newsturnout",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="news-reelected",
            table=table,
            row="du_diff_news_TOT",
            col="newsreelected",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table6.csv")
        results.append(Result.from_esttab(
            id="news-speed",
            table=table,
            row="du_diff_news_TOT",
            col="avg_rev_collect",
            expected_range=(0, None)
        ))
        return results