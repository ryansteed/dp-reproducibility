from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Bordignon(Study):
    id = 'bordignon-2016'

    def data_paths(self) -> dict:
        return {
            "dual_ballot_replication": os.path.join(
                self.path(), "source/20131024_replication", "dataset/dual_ballot_replication.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "pop15000",  
            "pop15000_2",
            "pop15000_3",
            "t15000_int1",
            "t15000_int2",
            "t15000_int3",
            "end_rev_transf_pc",
            "income_pc",
            "active_pop",
            # "elderly_index",
            # "family_size",
        ]
    
    def _pre_processing(self, data):
        df = data["dual_ballot_replication"]

        self._pc_vars = [
            "end_rev_transf",
            "income"
        ]
        for v in self._pc_vars:
            df[v] = df[f"{v}_pc"] * df["pop_census"]
        df["active"] = df["active_pop"] * df["pop_census"]

        data["dual_ballot_replication"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["dual_ballot_replication"]
        
        df["pop15000"] = df["pop_census"] - 15000
        df["pop15000_2"] = np.power(df["pop15000"].astype('float64'), 2)
        df["pop15000_3"] = np.power(df["pop15000"].astype('float64'), 3)
        df["t15000_int1"] = df["t15000"] * df["pop15000"]
        df["t15000_int2"] = df["t15000"] * df["pop15000_2"]
        df["t15000_int3"] = df["t15000"] * df["pop15000_3"]

        for v in self._pc_vars:
            df[f"{v}_pc"] = df[v] / df["pop_census"]
        df["active_pop"] = df["active"] / df["pop_census"]

        noised_data["dual_ballot_replication"] = df
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `20131024_replication.do`: ###
        # use dataset/dual_ballot_replication.dta
        # xtset id_city_istat year_election
        # ...
        ### TABLE 1 - runoff-candidate
        # local covariates north CE south area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit
        # foreach var in number_candidates ... {
        # eststo: reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates',r cluster(id_city_istat)
        # ...
        ### TABLE 3 - runoff-outcome
        # local covariates north CE south area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit
        # foreach var in number_candidates ... {
        # ...
        # eststo: xi: xtreg `var' t15000 i.year_election `covariates',fe
        # ...
        ### TABLE 4
        # local covariates north CE area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit
        ## runoff-timevar
        # foreach var in var_ord {
        # eststo: reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates', r cluster(id_city_istat)
        # ...
        ## runoff-crossvar
        # local covariates north CE area alt_max
        # foreach var in var3_ordinaria {
        # eststo: reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates' [aw=w],r
        # ...
        # 
        ###

        sensitivities = {

            ### pop15000: population normalized at 15,000 (i.e. population - 15000)
            # NOTE: reconstructed pop15000 = pop_census - 15000
            "pop_census": lambda municipality: 1,
            ### pop15000_2: population normalized ^2
            # NOTE: reconstructed pop15000_2 = pop15000^2
            # pop15000 already noised
            ### pop15000_3: population normalized ^3
            # NOTE: reconstructed pop15000_3 = pop15000^3
            # pop15000 already noised
            ### t15000_int1: population normalized * treated dummy
            # NOTE: reconstructed t15000_int1 = t15000 * pop15000
            # pop15000 already noised
            ### t15000_int2: population normalized ^2 * treated dummy
            # NOTE: reconstructed t15000_int2 = t15000 * pop15000_2
            # pop15000_2 already noised
            ### t15000_int3: population normalized ^3 * treated dummy
            # NOTE: reconstructed t15000_int3 = t15000 * pop15000_3
            # pop15000_3 already noised
            
            ### end_rev_transf_pc: value of rev_transf_pc at termination (this should be per-capita transfers)
            # NOTE reconstructed end_rev_transf = end_rev_transf_pc * pop_census
            # end_rev_transf not personal
            # pop_census already noised
            
            ### income_pc:  disposable income per capita in euros (2005)
            # NOTE assuming disposable income clipped at 500k euros; reconstructed income = income_pc * pop_census
            "income": lambda municipality: 500000,
            
            ### elderly_index: elderly index (2005)
            # NOTE: can't find a definition for this variable, not sure if it is personal; not noised
            
            ### active_pop: active population / total population (2005)
            # NOTE: reconstructed active = active_pop * pop_census
            "active": lambda municipality: 1,
            
            ### family_size: family size (2005) --- guessing this is average family size? not clear
            # NOTE: no definition, not noised
            
            ### [not personal] number_candidates: number of candidates for the mayor office
            ### [not personal] var_ord: time variance of the property tax rate
            ### [not personal] var3_ordinaria: Cross-sectional variance of business property tax rate
            # foreach x in ordinaria_cs {
            # egen auxiliary2=sd(`x'),by(bin100 year_election)
            # g var2_`x'=auxiliary2^2
            # drop auxiliary2
            # egen var3_`x'=mean(var2_`x'),by(bin100)
            # sort bin100
            # }
            ### [not personal] t15000:  dummy for treated municipality
            ### [not personal] north: northern Italy dummy
            ### [not personal] CE: Centre-Italy dummy
            ### [not personal] south: southern Italiy dummy
            ### [not personal] area: area size of the municipality
            ### [not personal] alt_max: altitude
            ### [not personal] duration: number of days in office
            ### [not personal] term_limit: term limit binding
            ### [not personal] w: weights given by (the inverse of) the numerosity of each bin [paper]
            # egen size100=count(id_city_istat),by(bin100)
            # g w=1/size100
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="runoff-candidate",
            table=table,
            row="t15000",
            col="est1",
            expected_range=(0, None)
        ))
        # table = self._load_esttab(f"{self.path()}/results/table2.csv")
        # results.append(Result.from_esttab(
        #     id="runoff-pretreat",
        #     table=table,
        #     row="t15000",
        #     col="est1",
        #     expected_range=(0, 0)
        # ))
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="runoff-outcome",
            table=table,
            row="t15000",
            col="est1",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="runoff-timevar",
            table=table,
            row="t15000",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="runoff-crossvar",
            table=table,
            row="t15000",
            col="est2",
            expected_range=(None, 0)
        ))
        return results