from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Bohn(Study):
    id = 'bohn-2015'

    def data_paths(self) -> dict:
        return {
            "BohnFreedmanOwens_AER-PP_Data": os.path.join(
                self.path(), "source","Owens_AER-PP_ReplicationData", "BohnFreedmanOwens_AER-PP_Data.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "ln_arrests_hf",
            "i_povrate_enacted",
            "i_povrate_exLAW",
            "i_povrate_exSAW",
            "i_pct_foreign_enacted",
            "i_pct_foreign_exLAW",
            "i_pct_foreign_exSAW",
        ]
    
    pop_shares = [
        "povrate",
        "pct_foreign"
    ]
    treatments = [
        "enacted",
        "exLAW",
        "exSAW"
    ]
    
    def _pre_processing(self, data):
        df = data["BohnFreedmanOwens_AER-PP_Data"]

        df["pop"] = np.exp(df["ln_pop"])
        df["popinterpolated"] = df["arrests"].astype('float64') / df["arrests_hf"].astype('float64') * 1000

        for var in self.pop_shares:
            df[f"n_{var}"] = df[var] * df["pop"] / 100
            for t in self.treatments:
                df[f"{t}_{var}"] = np.where(
                    df[var] == 0,
                    0,
                    df[f"i_{var}_{t}"] / df[var]
                )
        
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["BohnFreedmanOwens_AER-PP_Data"]
        df["ln_pop"] = np.log(df["pop"])

        df["arrests_hf"] = np.where(
            df["arrests_hf"].isna(),
            np.nan,
            np.where(
                df["popinterpolated"].isna(),
                0,
                df["arrests"] / df["popinterpolated"] * 1000
            )
        )
        df["ln_arrests_hf"] = np.log(df["arrests_hf"].astype('float64') + np.float64(0.01))

        for var in self.pop_shares:
            df[var] = df[f"n_{var}"] / df["pop"] * 100
            for t in self.treatments:
                df[f"i_{var}_{t}"] = df[f"{t}_{var}"] * df[var]

        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `doFile1.do`: ###
        # use BohnFreedmanOwens_AER-PP_Data;
        # ...
        # foreach group in misdemeanor ... {;
        # 	foreach demog in povrate pct_foreign {;
        # 		...
        # 		eststo: areg ln_arrests_hf i_`demog'* _I* if group=="`group'" & sample=="ALL", absorb(bg) cluster(bg) robust;
        # 	};
        # };
        sensitivities = {
            ### ln_arrests_hf = ln(arrests_hf) : Ln Arrests per Capita, by Ethnicity [Bexar County]
            # NOTE: reconstructed ln_arrests_hf = log(arrests_hf + 0.01)
            # arrests_hf: Arrests per Capita, by Ethnicity [Bexar County]
            # [paper] arrests scaled by pop linearly interpolated between 1980 and 2000
            # seems to be arrests per 1000
            # arrests_hf = arrests / (popinterpolated) * 1000
            # NOTE: reconstructing popinterpolated = arrests / arrests_hf * 1000
            # NOTE assuming individual can only contribute to interpolated pop at most 1/2
            "popinterpolated": lambda blockgroup: 1/2,
            # arrests: Arrests (Excl. DUIs) [Bexar County]
            # very small number! this will be noisy
            "arrests": lambda blockgroup: 1,
            
            ### pop share vars
            # NOTE: reconstructed pop = exp(ln_pop)
            "pop": {
                "sensitivity": lambda blockgroup: 1,
                "lb": 1
            },
            # assuming i_`v'_`t` = `v` * `t`
            # assuming `v` = n_`v` / pop * 100
            # NOTE: reconstructed n_`v` = `v` * pop / 100
            # NOTE: reconstructed `t`_`v` = i_`v`_`t` / `v`
            # reconstructed `t`_`v` should be the same across `v`s
            # `t` vars are not personal
            # pop already noised
            #--- misde-poverty
            "n_povrate": lambda blockgroup: 1,
            ## i_povrate_enacted:Poverty Rate x IRCA Enacted 
            # povrate already noised
            ## i_povrate_exLAW:Poverty Rate x LAW Expiry
            # povrate already noised
            ## i_povrate_exSAW:Poverty Rate x SAW Expiry 
            # povrate already noised
            #--- misde-immigrant
            "n_pct_foreign": lambda blockgroup: 1,
            ## i_pct_foreign_enacted:Foreign Born x IRCA Enacted
            ## i_pct_foreign_exLAW:Foreign Born x LAW Expiry
            ## i_pct_foreign_exSAW:Foreign Born x SAW Expiry
            
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="misde-poverty",
            table=table,
            row="i_povrate_enacted",
            col="r_misdemeanor_povrate",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="misde-immigrant",
            table=table,
            row="i_pct_foreign_enacted",
            col="r_misdemeanor_pct_foreign",
            expected_range=(None, 0)
        ))
        return results