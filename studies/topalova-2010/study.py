from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Topalova(Study):
    id = 'topalova-2010'

    def data_paths(self) -> dict:
        return {
            "rural_data": os.path.join(
                self.path(), "source/_data", "rural_data.dta"
            ),
            # "rural_region_data": os.path.join(
            #     self.path(), "source/_data", "rural_region_data.dta"
            # ),
            "urban_data": os.path.join(
                self.path(), "source/_data", "urban_data.dta"
            ),
            # "agriwage_data": os.path.join(
            #     self.path(), "source/_data", "agriwage_data.dta"
            # ),
            # "asi_data": os.path.join(
            #     self.path(), "source/_data", "asi_data.dta"
            # ),
            # "indpremia_data": os.path.join(
            #     self.path(), "source/_data", "indpremia_data.dta"
            # ),
            # "migration_data": os.path.join(
            #     self.path(), "source/_data", "migration_data.dta"
            # ),
            # "price_data": os.path.join(
            #     self.path(), "source/_data", "price_data.dta"
            # )
            # ...
        }
    
    def _pre_processing(self, data):
        for key in data.keys():
            df = data[key].copy()
            df["inpov_n"] = df["inpov"] * df["n"]
            df["consumption"] = np.exp(df["logmean"]) * df["n"]
            data[key] = df
        return data
    
    def _post_processing(self, noised_data):
        for key in noised_data.keys():
            df = noised_data[key].copy()
            df["inpov"] = df["inpov_n"] / df["n"]
            df["logmean"] = np.where(
                df["consumption"].isna(), # one case, leave invariant
                df["logmean"],
                np.log(df["consumption"] / df["n"])
            )
            noised_data[key] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Tables.do`: ###
        ## col3aa
        # use rural_data, replace;
        # ...
        # eststo col3aa: xi: ivreg inpov (tariff=trallmtariff) post  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);

        ## col4ab
        # global cov2 "pcnt_litpost pcnt_scstpost  pcnt_mfgpost  pcnt_farmpost  pcnt_tradepost  pcnt_tranpost  pcnt_minpost  pcnt_servpost  post_law ";
        # ...
        # use rural_data, replace;
        # ...
        #  xi: ivreg logmean (tariff=trallmtariff) post $cov2  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);

        ## col3ba
        # use urban_data, replace;
        # ...
        # eststo col3ba: xi: ivreg inpov (tariff=trallmtariff) post  i.regcod if (round==43 | round==55) [aw=n],  cluster(stateyear);

        ## col4bb
        # use urban_data, replace;
        # ...
        # eststo col4bb: xi: ivreg logmean (tariff=trallmtariff) post $cov2  i.regcod if (round==43 | round==55) [aw=n],  cluster(stateyear);


        ###
        vars_to_noise = {
            #--- rural_data
            ### n: Number of households in district
            "n": {
                "sensitivity": lambda district: 1,
                "lb": 1
            },

            ### inpov: Poverty rate (per household)
            # inpov = inpov_n / n
            # NOTE created var inpov_n = n * inpov
            # n already noised
            "inpov_n": lambda district: 1,

            ### logmean: Log Per Capita Consumption (per household)
            # consumption per capita has mean 312, std 180 
            # logmean = log(consumption / n)
            # NOTE: created inter var consumption = exp(logmean) * n
            # household expenditure
            # NOTE: assuming household expenditure max mean + 3*std
            # n already noised
            "consumption": {
                "sensitivity": lambda district: 852,
                "lb": 1
            },

            ### pcnt_*: Share * x Post
            # NOTE: # employees not available, so can't add DP noise

            ### [not personal] stateyear: state, year dummy
            ### [not personal] post_law: Goodlaw * post
            ### [not personal] round: NSS Survey Round
            ### [not personal] post: 1 if round==55
            ### [not personal] tariff: Scaled Tariff
            ### [not personal] trallmtariff: Unscaled Tariff
            ### [not personal] district: Unique district identifier


            #--- urban_data
            ### inpov: same as above
            ### [not personal] tariff: Scaled Tariff
            ### [not personal] trallmtariff: Unscaled Tariff
            ### [not personal] post: 1 if round==55
            ### [not personal] regcod: Region Code (as per 43rd round)
            ### [not personal] round: NSS Survey Round
            ### n: same as above
            ### [not personal] stateyear: state, year dummy
            ### logmean: same as above
            ### pcnt_*: same as above
            ### [not personal] post_law: Goodlaw * post
        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return [
            "n",
            "logmean",
            "inpov",
            # not noised
            # "pcnt_litpost",
            # "pcnt_scstpost",
            # "pcnt_mfgpost",
            # "pcnt_farmpost",
            # "pcnt_tradepost",
            # "pcnt_tranpost",
            # "pcnt_minpost",
            # "pcnt_servpost"
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="tariff-ruralpoverty",
            table=table,
            row="tariff",
            col="col3aa",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="tariff-ruralexpense",
            table=table,
            row="tariff",
            col="col4ab",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="tariff-urbanpoverty",
            table=table,
            row="tariff",
            col="col3ba",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="tariff-urbanexpense",
            table=table,
            row="tariff",
            col="col4bb",
            expected_range=(0, None)
        ))
        return results