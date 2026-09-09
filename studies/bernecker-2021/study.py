from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Bernecker(Study):
    id = 'bernecker-2021'

    def data_paths(self) -> dict:
        return {
            "experimentation_replicationdata": os.path.join(
                self.path(), "source", "experimentation_replicationdata.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        ### vars
        # [not personal] experiment_pooled: number of policy experiments
        # lmargin: Governor's Past Vote Margin
        # pop_1000: population per 1000
        # aged: %population 65 and older
        # kids: %population under 18
        # int_lameduck_margin: lameduck x passed vote margin
        # [not personal] gov_age: governor's age
        # [not personal] lameduck: dummy if governor is a lame duck
        ###
        return [
            "pop_1000",
            "aged",
            "kids"
        ]
    
    def other_vars(self):
        return [
            "experiment_pooled",
            "lmargin",
            "int_lameduck_margin",
            "gov_age",
            "lameduck"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "state"
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict:
        df = data["experimentation_replicationdata"]
        df["n_aged"] = df["pop_1000"] * df["aged"] / 100
        df["n_kids"] = df["pop_1000"] * df["kids"] / 100

        data["experimentation_replicationdata"] = df
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df = noised_data["experimentation_replicationdata"]
        df["aged"] = df["n_aged"] / df["pop_1000"] * 100
        df["kids"] = df["n_kids"] / df["pop_1000"] * 100

        noised_data["experimentation_replicationdata"] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `experiment_replication.do`: ###
        # use "$data/experimentation_replicationdata.dta", clear;
        # ...
        # foreach Y of varlist experiment_pooled {;
        # ...
        # eststo: xi: areg `Y' lmargin gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
        # ...
        # eststo: xi: areg `Y' lmargin int_lameduck_margin lameduck gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
        ###
        sensitivities = {
            ### lmargin: Governor's Past Vote Margin
            # NOTE: can't noise, missing total votes
            ### int_lameduck_margin: lameduck x passed vote margin
            # NOTE: can't noise, missing total votes
            
            ### pop_1000: population per 1000
            "pop_1000": lambda state: 1/1000,
            
            ### aged: %population 65 and older
            # created inter var `n_aged` = pop_1000 * aged
            "n_aged": lambda state: 1/1000,
            
            ### kids: %population under 18
            # created inter var `n_kids` = pop_1000 * kids
            "n_kids": lambda state: 1/1000
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="support-experiment",
            table=table1,
            row="lmargin",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="lameduck-experiment",
            table=table1,
            row="lmargin",
            col="est2",
            expected_range=(None, 0)
        ))
        return results