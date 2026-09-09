from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Dellavigna(Study):
    id = 'dellavigna-2014'

    def data_paths(self) -> dict:
        return {
            "Data_AEJ_Replication": os.path.join(
                self.path(), "source/Replication-AEJ", "Data_AEJ_Replication.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "logpop",
            "Nazi_share",
            "people_listed",
            "male_share",
            "z2",
            "z3",
            "z6",
            "Croats",
            "higher_educ",
            "ec_active",
            "disable_share2",
        ]
    
    pop_vars = [
        "Croats",
        "higher_educ",
        "ec_active"
    ]
    
    def _pre_processing(self, data):
        df = data["Data_AEJ_Replication"]
        
        df["opspop"] = np.exp(df["logopspop"].astype('float64')) - 1
        for v in self.pop_vars:
            df[f"n_{v}"] = df[v] * df["opspop"]

        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["Data_AEJ_Replication"]

        df["logpop"] = np.log(df["population"].astype('float64') + 1)
        
        df["Nazi_share"] = np.sum([
            df[v].astype('float64').fillna(0) for v in [
                "hsp", "hcsp", "hp_hpp"
            ]
        ], axis=0) / (df["votes_counted"])
        
        df["male_share"] = df["males"] / df["population"]
        df["disable_share2"] = df["disabled_from_war"].astype('float64') / df["opspop"]

        # age 21-40
        df["z2"] = np.sum([df[v].fillna(0) for v in [
            "age20_24", "age25_29", "age30_34", "age35_39"
        ]], axis=0) / df["totpop"]
        # age 41-60
        df["z3"] = np.sum([df[v].fillna(0) for v in [
            "age40_44", "age45_49", "age50_54", "age55_59"
        ]], axis=0) / df["totpop"]
        # age 61+
        df["z6"] = np.sum([df[v].fillna(0) for
            v in ["age60_64", "age65_69", "age70_74", "age75_79", "age80_84", "age85_89", "age90_94", "age95plus"]
        ], axis=0) / df["totpop"]

        for v in self.pop_vars:
            df[v] = df[f"n_{v}"] / df["opspop"]

        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `AEJ_Replication_main.do`: ###
        # use Data_AEJ_Replication.dta,clear
        # ...
        # //lists of controls
        # global controls_short="log_distance_full logpop male_share z2 z3 z6 Croats higher_educ ec_active disable_share2  r1-r5" 
        # ...
        # local cond="[aweight=people_listed]"
        # ...
        # Table for the shares of parties in main sample (TABLE 3)
        # foreach dep_var in Nazi_share  {
        #     ...
        #     forval i=1/1 {
        #     ...    
        #     *OLS with all the controls
        #         foreach list in  controls_short ... {
        #             eststo `list': reg `dep_var' radio`i'   $`list' `cond', cluster (Opsina2)
        #             ...
        sensitivities = {
        ### logpop: village-level Population (logged) + 1
        # NOTE: reconstructed logpop = log(population + 1)
        "population": lambda village: 1,

        ### Nazi_share:  village-level Vote share for extremely nationalistic parties (HSP, HCSP, HP-HPP)
        # people_voted: people turned out to vote
        # NOTE: reconstructed Nazi_share = (hsp + hcsp + hp_hpp) / votes_counted
        "hsp": lambda village: 1,
        "hcsp": lambda village: 1,
        "hp_hpp": lambda village: 1,
        "votes_counted": lambda village: 1,

        ### people_listed: People listed to vote
        "people_listed": {
            "sensitivity": lambda village: 1,
            "lb": 0
        },

        ### male_share: village-level % of male population
        # NOTE: reconstructed male_share = males / population
        # population already noised
        "males": lambda village: 1,

        ### z2: village-level % of aged 21-40
        # NOTE: reconstructed z2 = (age20_24 + age25_29 + age30_34 + age35_39) / totpop
        "age20_24": lambda village: 1,
        "age25_29": lambda village: 1,
        "age30_34": lambda village: 1,
        "age35_39": lambda village: 1,
        "totpop": lambda village: 1,

        ### z3  village-level % of aged 41-60
        # NOTE: reconstructed z3 = (age40_44 + age45_49 + age50_54 + age55_59) / totpop
        # totpop already noised
        "age40_44": lambda village: 1,
        "age45_49": lambda village: 1,
        "age50_54": lambda village: 1,
        "age55_59": lambda village: 1,

        ### z6: village-level % of aged 61+
        # NOTE: reconstructed z6 = (age60_64 + age65_69 + age70_74 + age75_79 + age80_84 + age85_89 + age90_94 + age95plus) / totpop
        # totpop already noised
        "age60_64": lambda village: 1,
        "age65_69": lambda village: 1,
        "age70_74": lambda village: 1,
        "age75_79": lambda village: 1,
        "age80_84": lambda village: 1,
        "age85_89": lambda village: 1,
        "age90_94": lambda village: 1,
        "age95plus": lambda village: 1,

        ### popshare vars: village-level % of Opsina population
        # NOTE: created inter var opspop = exp(logopspop) - 1
        "opspop": lambda village: 1,
        # assuming * = n_* / opspop
        # NOTE: reconstructing n_* = * x opspop
        # population already noised
        ## Croats village-level % of Croats
        "n_Croats": lambda village: 1,
        ## higher_educ: village-level share of people with higher education
        "n_higher_educ": lambda village: 1,
        ## ec_active: village-level Economically active population, %
        "n_ec_active": lambda village: 1,
        
        ### disable_share2: village-level Disabled after the war of independence, % of opsina population
        # NOTE: reconstructing disable_share2 = disabled_from_war / opspop
        "disabled_from_war": lambda village: 1,

        ### [not personal] radio1: At least 1 RTS radio available
        ### [not personal] log_distance_full: Distance to Serbia, logged
        ### [not personal]war: Was important during the war
        ### [not personal]mon: Monument in the honor of died defendants of the town
        ### [not personal]name_of_the_streets_c: Names of the streets in Cyrillic script
        ### [not personal]name_of_the_streets_i: Names of the streets in Hungarian
        ### [not personal]pivo_S: Serbian beer in bars
        ### [not personal] r1-r5: county==County of Osijek-Baranja or other county
        ### [not personal]bliz: Large forest nearby
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="radio-vote",
            table=table,
            row="radio1",
            col="controls_long",
            expected_range=(0, None)
        ))
        # table5 = self._load_esttab(f"{self.path()}/results/table5.csv")
        # results.append(Result.from_esttab(
        #     id="radio-graffiti",
        #     table=table5,
        #     row="radio1",
        #     col="est2",
        #     expected_range=(0, None)
        # ))
        return results