from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Furtado(Study):
    id = 'furtado-2024'

    def data_paths(self) -> dict:
        return {
            "Ready4RegressBaseline": os.path.join(
                self.path(), "source","Data","Ready4RegressBaseline.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "age",
            "yrsusa",
            "race_b",
            "race_a",
            "race_h",
            "race_m",
            "race_an",
            "race_o",
            "female",
            "edu_hs",
            "goodeng",
            "enroll",
            "l_shind_manuf_cbp",
            "l_sh_popedu_c",
            # "l_sh_empl_f",
            "d_tradeusch_pw_adh",
            # "d_tradeotch_pw_lag_adh",
            "cell_wt",
            "d_goodeng",
            "d_enroll"
        ]
    
    _pct_vars = [
        "race_b",
        "race_a",
        "race_h",
        "race_m",
        "race_an",
        "race_o",
        "female",
        "edu_hs",
        "goodeng",
        "enroll"
    ]

    _avg_vars = [
        "age",
        "yrsusa",
    ]
    
    def _pre_processing(self, data):
        df = data["Ready4RegressBaseline"]
        for var in self._pct_vars:
            df[f"count_{var}"] = df[var].astype('float64') / 100 * df["popczyr"].astype('float64')
        for var in self._avg_vars:
            df[f"sum_{var}"] = df[var].astype('float64') * df["popczyr"].astype('float64')
        df["count_l_shind_manuf_cbp"] = df["l_shind_manuf_cbp"] / 100 * df["l_no_workers_totcbp"]
        df["count_l_sh_popedu_c"] = df["l_sh_popedu_c"] / 100 * df["l_popcount"]
        df["d_tradeusch"] = df["d_tradeusch_pw_adh"] * df["l_no_workers_totcbp"]
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["Ready4RegressBaseline"]
        for var in self._pct_vars:
            df[var] = df[f"count_{var}"] * 100 / df["popczyr"]
        for var in self._avg_vars:
            df[var] = df[f"sum_{var}"] / df["popczyr"]
        df["l_shind_manuf_cbp"] = df["count_l_shind_manuf_cbp"] * 100 / df["l_no_workers_totcbp"]
        df["l_sh_popedu_c"] = df["count_l_sh_popedu_c"] * 100 / df["l_popcount"]
        df["d_goodeng"] = -df.groupby("czone")["goodeng"].diff(-1).fillna(-df["d_goodeng"])
        df["d_enroll"] = -df.groupby("czone")["enroll"].diff(-1).fillna(-df["d_enroll"])
        df["d_tradeusch_pw_adh"] = df["d_tradeusch"] / df["l_no_workers_totcbp"]
        df["cell_wt"] = df["popczyr"] / df["totpopyear"]
                
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `5_grp_MakeTables.do`: ###
        # use "Ready4RegressBaseline.dta", clear
        # ...
        #-- import-eng
        # eststo: ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  sum goodeng [aw = cell_wt]
        # ...
        #-- import-edu
        # use Ready4RegressBaseline.dta, clear
        # eststo: ivreg2 d_enroll (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  sum enroll [aw = cell_wt]
        sensitivities = {

            ### *: % * in commuting zone(cz)
            # NOTE reconstructed count_* = */100 * popczyr
            # popczyr: population in the cz
            "popczyr": {
                "sensitivity": lambda czyr: 1,
                "lb": 1
            },
            ## race_b: Percent Black
            "count_race_b": lambda czyr: 1,
            ## race_a: Percent Asian
            "count_race_a": lambda czyr: 1,
            ## race_h: Percent Hispanic
            "count_race_h": lambda czyr: 1,
            ## race_m: Percent married
            "count_race_m": lambda czyr: 1,
            ## race_an: Percent American Indian
            "count_race_an": lambda czyr: 1,
            ## race_o: Percent other
            "count_race_o": lambda czyr: 1,
            ## female: Percent female
            "count_female": lambda czyr: 1,
            ## edu_hs: Percent with high school education
            "count_edu_hs": lambda czyr: 1,
            ## goodeng: % good english
            "count_goodeng": lambda czyr: 1,
            ## enroll: % enrolled in school
            "count_enroll": lambda czyr: 1,

            ### age: Average age
            # NOTE reconstructed sum_age = age * popczyr
            # NOTE assuming age clipped at 120
            # popczyr already noised
            "sum_age": lambda czyr: 120,

            ### yrsusa: Average years in usa
            # NOTE reconstructed sum_yrsusa = yrsusa * popczyr
            # NOTE assuming years in usa clipped at 120
            # popczyr already noised
            "sum_yrsusa": lambda czyr: 120,
            
            ### l_shind_manuf_cbp: % employment in manufacturing, lagged
            # l_shind_manuf_cbp = count_l_shind_manuf_cbp / l_no_workers_totcbp * 100
            # NOTE reconstructed count_l_shind_manuf_cbp = l_shind_manuf_cbp / 100 * l_no_workers_totcbp
            "count_l_shind_manuf_cbp": lambda czyr: 1,
            "l_no_workers_totcbp": lambda czyr: 1,

            ### l_sh_popedu_c: % pop with college degree, lagged
            # l_sh_popedu_c = count_l_sh_popedu_c / l_popcount * 100
            # NOTE reconstructed count_l_sh_popedu_c = l_sh_popedu_c / 100 * l_popcount
            "count_l_sh_popedu_c": lambda czyr: 1,
            "l_popcount": {
                "sensitivity": lambda czyr: 1,
                "lb": 1
            },

            ### d_tradeusch_pw_adh: change in imports per worker
            # NOTE reconstructed d_tradeusch = d_tradeusch_pw_adh * l_no_workers_totcbp 
            # already noised l_no_workers_totcbp

            ### d_tradeotch_pw_lag_adh: change in imports per worker lagged
            # NOTE not noised, can't figure out how to reconstruct

            ### l_sh_empl_f: Percent of women employed
            # NOTE # female workers not available from autor-2013, can't noise

            ### cell_wt: cell weight
            #> from `collapsedifs.do` (not run):
            # gen cell_wt = popczyr/totpopyear
            #>
            # NOTE: reconstrcuted cell_wt = popczyr / totpopyear
            # popczyr already noised
            "totpopyear": lambda czyr: 1,

            ### d_goodeng: change in % good english; first difference?
            # NOTE: reconstructed d_goodeng = first diff goodeng
            # NOTE: only partially reconstrcuted; base year not provided

            ### d_enroll: change in % enrolled in school; first difference
            # NOTE: reconstructed d_enroll = first diff enroll
            # NOTE: only partially reconstrcuted; base year not provided
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="import-eng",
            table=table,
            row="d_tradeusch_pw_adh",
            col="est1",
            expected_range=Result.relative_range(0.5, tolerance=0.2)
        ))
        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="import-edu",
            table=table2,
            row="d_tradeusch_pw_adh",
            col="est2",
            expected_range=(0, None)
        ))
        
        return results