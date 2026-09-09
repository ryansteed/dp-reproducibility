from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Luca(Study):
    id = 'luca-2015'

    def data_paths(self) -> dict:
        return {
            "LeeLucaOwensSharma_AER_PP_CrimeData": os.path.join(
                self.path(), "source/AERPP-Replication-Data", "LeeLucaOwensSharma_AER_PP_CrimeData.dta"
            )
            # "dtaFile2": os.path.join(
            #     self.path(), "source/AERPP-Replication-Data", "LeeLucaOwensSharma_AER_PP_NFHSData.dta"
            # ),
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["LeeLucaOwensSharma_AER_PP_CrimeData"]

        self._pc_vars = {
            "women_indexnf": 10000,
            "women_index_f": 10000,
            # "women_index": 10000,
            "literacy": 100, # percentage * 100
            "urban": 100, # percentage * 100
            "pcgdp": 1,
            "pcpolice": 1000
        }
        for v, unit in self._pc_vars.items():
            df[f"n_{v}"] = df[v] * df["pop"] / unit

        data["LeeLucaOwensSharma_AER_PP_CrimeData"] = df
        return data

    def _post_processing(self, noised_data):
        df = noised_data["LeeLucaOwensSharma_AER_PP_CrimeData"]

        for v, unit in self._pc_vars.items():
            df[v] = np.where(
                df["pop"].isna(),
                df[v], # leave invariant --- though these rows should be dropped anyways
                (df[f"n_{v}"] / df["pop"] * unit)
            )

        noised_data["LeeLucaOwensSharma_AER_PP_CrimeData"] = df
        return noised_data

    def vars_to_noise(self):
        return [
            "pop",
            "women_indexnf",
            "women_index_f",
            "women_index",
            "literacy",
            "urban",
            "pcgdp",
            # "unemp",
            "pcpolice",
        ]
    
    def _clean(self, noised_data):
        df = noised_data["LeeLucaOwensSharma_AER_PP_CrimeData"]
        df["women_index"] = df["women_index_f"] + df["women_indexnf"]
        noised_data["LeeLucaOwensSharma_AER_PP_CrimeData"] = df
        return noised_data
    
    def collinear_vars(self):
        return ["women_index"]
    
    def other_vars(self):
        return [
            "prohib",
            "unemp"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "State"

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `LeeLucaOwensSharm_AER_PP.do`: ###
        ## Table 1
        # use LeeLucaOwensSharma_AER_PP_CrimeData.dta, clear ;
        # ...
        # global controls literacy urban pcgdp unemp pcpolice ;
        # xi i.State i.year ;
        # eststo: reg women_indexnf prohib  _I*  $controls [aw=pop], cluster(State) ;
        # eststo: reg women_index_f prohib  _I*  $controls [aw=pop], cluster(State) ;
        # eststo: reg women_index prohib  _I*  $controls [aw=pop], cluster(State) ;
        ###
        vars_to_noise = {
            ### pop: state population
            # appears to be units 1
            "pop": lambda state: 1,

            ### women_indexnf: Reported non-fatal violence per 10,000 pop
            # women_indexnf = n_women_indexnf / pop * 10000
            # NOTE: created var n_women_indexnf = women_indexnf * pop / 10000
            "n_women_indexnf": lambda state: 1,
            # pop already noised

            ### women_index_f: Reported fatal violence per 10,000 pop
            # NOTE: created var n_women_index_f = women_index_f * pop / 10000
            "n_women_index_f": lambda state: 1,
            # pop already noised

            ### women_index: Reported violence per 10,000 pop
            # NOTE: reconstructed women_index = women_index_f + women_indexnf
            # "n_women_index": lambda state: 1,
            # pop already noised

            ### literacy: literacy rate
            # NOTE: created var n_literacy = literacy / 100 * pop
            "n_literacy": lambda state: 1,
            # pop already noised

            ### urban: % of state pop in urban areas
            # NOTE: created var n_urban = urban / 100 * pop
            "n_urban": lambda state: 1,
            # pop already noised
            
            ### pcgdp: per capita GDP
            # NOTE: created var n_pcgdp = pcgdp * pop
            # gdp is not private
            # pop already noised

            ### unemp: unemployment rate
            # NOTE: labor force size missing, not enough info for DP

            ### pcpolice: total police officers per 1000 state pop
            # NOTE: created var n_pcpolice = pcpolice * pop / 1000
            "n_pcpolice": lambda state: 1,
            # pop already noised
            
            ### [not personal] prohib: state prohibition dummy
            ### [not personal] State: dummy
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="prohibit-nonfatal",
            table=table,
            row="prohib",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="prohibit-fatal",
            table=table,
            row="prohib",
            col="est2",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="prohibit-all",
            table=table,
            row="prohib",
            col="est3",
            expected_range=(None, 0)
        ))
        return results