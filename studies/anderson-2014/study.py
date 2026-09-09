from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os
import numpy as np


class Anderson(Study):
    id = 'anderson-2014'

    def data_paths(self):
        return {
            "compulsory_schooling_and_crime": os.path.join(
                self.path(), "source", "compulsory_schooling_and_crime.dta"
            )
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> dict:
        df = data["compulsory_schooling_and_crime"]

        # deconstruct pop_dense_thou
        # area = population / (pop_dense_thou * 1000)
        df["area"] = df["county_pop"] / (df["pop_dense_thou"] * 1000)

        # deconstruct popratio*
        for group in ["1315", "1618", "1921", "_male", "_black"]:
            df[f"count{group}"] = df[f"popratio{group}"] * df["county_pop"]

        # deconstruct *_rate
        # for c in [
        #     c for c in df.columns
        #     if c.endswith("_rate")
        # ]:
        #     var = c.replace("_rate", "")
        #     # total crime = (crimes*1000/(age pop)) / 100 * total pop * age pop ratio 
        #     df[var] = df[c] / 1000 * df["county_pop"] * np.where(
        #         df["age"] == 1315, df["popratio1315"],
        #         np.where(
        #             df["age"] == 1618, df["popratio1618"],
        #             np.where(
        #                 df["age"] == 1921, df["popratio1921"],
        #                 np.nan # otherwise, we don't care — all regressions use these age groups
        #             )
        #         )
        #     )
        
        # deconstruct real_ipc2000
        df["total_income"] = df["real_ipc2000"] * df["county_pop"]

        data["compulsory_schooling_and_crime"] = df
        return data

    def _post_processing(self, noised_data: pd.DataFrame) -> pd.DataFrame:
        df = noised_data["compulsory_schooling_and_crime"]
        # reconstruct pop_dense_thou
        newpop = df["county_pop"] / df["area"] / 1000
        df["pop_dense_thou"] = np.where(
            np.isnan(newpop), df["pop_dense_thou"], newpop
        )

        # reconstruct popratio*
        for group in ["1315", "1618", "1921", "_male", "_black"]:
            newpopratio = df[f"count{group}"] / df["county_pop"]
            df[f"popratio{group}"] = np.where(
                np.isnan(newpopratio),
                df[f"popratio{group}"],
                df[f"count{group}"] / df["county_pop"]
            )

        # reconstruct *_rate
        for c in [
            c for c in df.columns
            if c.endswith("_rate")
        ]:
            var = c.replace("_rate", "")
            newrate = 1000 * df[var] / (df["county_pop"] * np.where(
                df["age"] == 1315, df["popratio1315"],
                np.where(
                    df["age"] == 1618, df["popratio1618"],
                    np.where(
                        df["age"] == 1921, df["popratio1921"],
                        np.nan # otherwise, we don't care — all regressions use these age groups
                    )
                )
            ))
            df[c] = np.where(
                np.isnan(newrate), df[c], newrate # for other age groups, keep the old rate
            )
        
        # reconstruct log_income
        newipc = df["total_income"] / df["county_pop"]
        df["real_ipc2000"] = np.where(
            np.isnan(newipc), df["real_ipc2000"], newipc
        )
        df["log_income"] = np.log(df["real_ipc2000"])

        noised_data["compulsory_schooling_and_crime"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "total_crime1_rate",
            "property1_rate",
            "violent1_rate",
            "popratio1315",
            "popratio1618",
            "popratio_male",
            "popratio_black",
            "log_income",
            "pop_dense_thou"
        ]
    
    def other_vars(self):
        return [
            "log_wage",
            "mda18",
            "mda18_age1618",
            "mlda19",
            "mlda20",
            "mlda21",
            "agency_count",
            "age",
            "male",
            "flag_males",
            "sd_flag_totalcrime",
            "sd_flag_property1",
            "sd_flag_violent1"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "state_fips"

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `compulsory_schooling_and_crime.do`: ###
        # use compulsory_schooling_and_crime.dta
        # ...
        #--- all3
        # eststo: xi:  xtreg total_crime1_rate age1618 mda18 mda18_age1618 mlda19 mlda20 mlda21 log_wage log_income popratio1315 popratio1618 pop_dense_thou popratio_male popratio_black agency_count i.year state_fe* if (age == 1315 | age == 1618) & male == 1 & flag_males != 1 & sd_flag_totalcrime != 1 & count > 10  [pweight = ave_county_pop], fe cluster(state_fips)
        # ...
        #--- property3
        # eststo: xi:  xtreg property1_rate age1618 mda18 mda18_age1618 mlda19 mlda20 mlda21 log_wage log_income popratio1315 popratio1618 pop_dense_thou popratio_male popratio_black agency_count i.year state_fe* if (age == 1315 | age == 1618) & male == 1 & flag_males != 1 & sd_flag_property1 != 1 & count > 10 [pweight = ave_county_pop], fe cluster(state_fips)
        # ...
        #--- violent3
        # eststo: xi:  xtreg violent1_rate age1618 mda18 mda18_age1618 mlda19 mlda20 mlda21 log_wage log_income popratio1315 popratio1618 pop_dense_thou popratio_male popratio_black agency_count i.year state_fe* if (age == 1315 | age == 1618) & male == 1 & flag_males != 1 & sd_flag_violent1 != 1 & count > 10 [pweight = ave_county_pop], fe cluster(state_fips)
        ###
        sensitivity_county = {
            ### *_rate is arrests per 1000 people in age group, per the paper ###
            # ASSUMPTION: protecting arrest record-level privacy, since we don't know about repeat offenders
            # CREATED INTER VARS * = *_rate * county_pop * popratio[age group] / 1000
            "total_crime1": lambda county: 1,
            "property1": lambda county: 1,
            "violent1": lambda county: 1,
            "total_drug": lambda county: 1,
            # "larceny": lambda county: 1,
            # "burglary": lambda county: 1,
            # "mvt": lambda county: 1,
            # "arson": lambda county: 1,
            # "murder": lambda county: 1,
            # "rape": lambda county: 1,
            # "robbery": lambda county: 1,
            # "agg_assault": lambda county: 1,
            # "other_assault": lambda county: 1,
            # "drug_sale": lambda county: 1,
            # "drug_possess": lambda county: 1,

            ### these vars are percents of the county pop ###
            "count1315": lambda county: 1,
            "count1618": lambda county: 1,
            "count_male": lambda county: 1,
            "count_black": lambda county: 1,

            ### log_income = log(real_ipc2000) [precomputed] ###
            # real_ipc2000 is real personal income per capita in 2000 dollars
            # so real_ipc2000 = county_income / county_pop
            # tested this in stata to be sure --- not clear from the code
            # sensitivity of real_ipc2000 is max_income / county_pop
            # sensitivity of log_income is county_pop * max_income / county_income
            # NOTE ASSUMPTION: max income is 500000
            "total_income": lambda county: 500000,
            
            ### pop_dense_thou = population / (area * 1000)
            # we don't have an area variable, but we can figure it out using county_pop:
            # CREATED INTER VAR area = county_pop / (pop_dense_thou * 1000)
            "county_pop": {
                "sensitivity": lambda county: 1, # needs at least 1 person to avoid nan
                "lb": 1
            },
            
            ### these vars not personal data ###
            # log_wage: this is the county's minimum wage, constant for everyone
            # mda*: this is the minimum dropout age, a law, not about people
            # mlda*: minimum legal drinking age, not personal data
            # agency_count": lambda county: 1, # number of reporting agencies, not about people
        }
        return sensitivity_county

    def extract_results(self) -> list[Result]:
        results = []

        table4 = self._load_esttab(f"{self.path()}/results/table4_male.csv")
        for i, spec in enumerate([
            "all1", "all2", "all3",
            "property1", "property2", "property3",
            "violent1", "violent2", "violent3",
            "drug1", "drug2", "drug3"
        ]):
            if spec in ["all3", "property3", "violent3"]:
                results.append(Result.from_esttab(
                    id=f"{spec}-arrests",
                    table=table4,
                    row="mda18_age1618",
                    col=f"est{i+1}",
                    expected_range=(None, 0)  # should be negative, significant
                ))
        
        # table5 = self._load_esttab(f"{self.path()}/results/table5.csv")
        # for i, spec in enumerate([
        #     "larceny",
        #     "burglary",
        #     "auto",
        #     "arson",
        #     "murder", "rape", "robbery", "agg_assault", "simple_assault",
        #     # "selling", "possessing"  only care about property, violent crimes
        # ]):
        #     results.append(Result.from_esttab(
        #         id=f"{spec}-arrests",
        #         table=table5,
        #         row="mda18_age1618",
        #         col=f"est{i+1}",
        #         expected_range=(None, 0)  # should be negative, significant
        #     ))

        return results
