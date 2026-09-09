from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Wang(Study):
    id = 'wang-2022'

    def data_paths(self) -> dict:
        return {
            "regdata": os.path.join(
                self.path(), "source", "Import competition and the gender employment gap in China_Replication files","data","regdata.dta"
            ),
            "final": os.path.join(
                self.path(), "source", "Import competition and the gender employment gap in China_Replication files","final.dta"
            ),
            # ...
        }
    
    _empsh_vars = [
        "agrsh90",
        "tersh90",
        "soesh90"
    ]
    
    def _pre_processing(self, data):
        df = data["regdata"]

        df["pop_f90"] = np.exp(df["lnpop_f90"])
        df["pop_m90"] = np.exp(df["lnpop_m90"])
        df["pop_m05"] = np.exp(df["dlnpop_m"] + df["lnpop_m90"])
        df["workers_f90"] = df["emplsh_f90"] * df["pop_f90"]
        df["workers_m90"] = df["emplsh_m90"] * df["pop_m90"]
        df["workers_m05"] = (df["demplsh_m"] + df["emplsh_m90"]) * df["pop_m05"]
        for var in self._empsh_vars:
            df[f"count_{var}"] = df[var] * (df["workers_m90"] + df["workers_f90"])
        
        data["regdata"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["regdata"]

        # reconstruct employment share variables
        for var in self._empsh_vars:
            df[var] = df[f"count_{var}"] / (df["workers_m90"] + df["workers_f90"])
        # reconstruct emplsh_m90
        df["emplsh_m90"] = df["workers_m90"] / df["pop_m90"]
        # reconstruct demplsh_m
        df["demplsh_m"] = df["workers_m05"] / df["pop_m05"] - df["emplsh_m90"]
        # reconstruct demplsh_m8290
        df["demplsh_m8290"] = df["emplsh_m90"] - df["emplsh_m82"]

        noised_data["regdata"] = df
        return noised_data

    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `tables.do`:
        # use "$datadir/regdata.dta",clear
        # global control90 "agrsh90 tersh90 soesh90 avlight90"
        # ...
        #-- dtarrif-emplmf
        # reg demplsh_m dtariff $control90 demplsh_m8290 emplsh_m90
        # ...
        #-- dtariff-female
        # reg dfiss_nsoe dtariff $control90 fiss_nsoe95, robust
        # ...
        #-- dtariff-dis
        # reg ddisc_nsoe dtariff $control90 disc_nsoe95, robust
        # ...
        #-- dtariff-compsh
        # reg dcompg_nsoe dtariff $control90 compg_nsoe95, robust
        ###

        
        vars_to_noise = { 
            ### employment share vars
            # *sh90 = count_*sh90 / (workers_m90 + workers_f90)
            # NOTE reconstructed count_*sh90 = *sh90 * (workers_m90 + workers_f90)
            # NOTE reconstructed workers_f90 = emplsh_f90 * pop_f90
            # NOTE reconstructed pop_f90 = exp(lnpop_f90)
            "pop_f90": lambda prefecture: 1,
            "workers_f90": lambda prefecture: 1,
            # NOTE reconstructed workers_m90 = emplsh_m90 * pop_m90
            # NOTE reconstructed pop_m90 = exp(lnpop_m90)
            "pop_m90": lambda prefecture: 1,
            "workers_m90": lambda prefecture: 1,
            ## agrsh90: 1990 Agricultural sector employment share
            "count_agrsh90": lambda prefecture: 1,
            ## tersh90: 1990 Tertiary sector employment share
            "count_tersh90": lambda prefecture: 1,
            ## soesh90: 1990 SOE employment share
            "count_soesh90": lambda prefecture: 1,
            
            #-- dtariff-emplmf
            ### emplsh_m90: 1990 Male employment rates
            # emplsh_m90 = workers_m90 / pop_m90
            # NOTE reconstructed pop_m90 = exp(lnpop_m90)
            "pop_m90": lambda prefecture: 1,
            # workers_m90 noised above

            ### demplsh_m: Delta Male employment rates 1990-2005
            # demplsh_m = workers_m05 / pop_m05 - emplsh_m90
            # emplsh_m90 already noised
            # dlnpop_m = lnpop_m05 - lnpop_m90
            # NOTE reconstructed pop_m05 = exp(dlnpop_m + lnpop_m90)
            "pop_m05": lambda prefecture: 1,
            # NOTE reconstructed workers_m05 = (demplsh_m + emplsh_90) * pop_m05
            "workers_m05": lambda prefecture: 1,

            ### demplsh_m8290: Delta Male employment rates: 1990-1982
            # demplsh_m8290 = emplsh_m90 - emplsh_m82
            # emplsh_m82 = workers_m82 / pop_m82
            # NOTE: partially noised, not enough info for emplsh_m82 (lnpop_m82 missing)
             
            #-- dtariff-female
            ### fiss_nsoe95: 1995 Female intensity: Non-SOE
            # fiss_nsoe95 = workers_f_nsoe95 / workers_nsoe95
            # NOTE not enough info to deconstruct; don't have pop_f_nsoe95 to get workers_f_nsoe95

            ### dfiss_nsoe: Delta Female intensity: Non-SOE
            # NOTE not enough info to deconstruct, see fiss_nsoe95
            
            #-- dtariff-dis
            # disc_nsoe95: 1995 Discrimination: Non-SOE
            # [paper] "To construct this measure, we rely on firm census data from 1995 and 2004 and regress firm operating profits on the female share separately for each two-digit sector s and year t, using the following specification"
            # NOTE not enough info to deconstruct, regression code not provided

            # ddisc_nsoe: Delta Discrimination: Non-SOE
            # NOTE not enough info to deconstruct, see disc_nsoe95
            
            #-- dtariff-compsh
            ### compg_nsoe95: 1995 Computer intensity: Non-SOE
            # [paper] CIpt = 100 * sum Espt / Ept CIst
            # where CIst is sectoral computer intensity, Espt/Ept is sectoral employment share
            # NOTE not enough info to deconstruct, sectoral data not provided            

            ### dcompg_nsoe: Delta Computer intensity: Non-SOE


            ### [not personal] dtariff: Delta Import tariffs
            ### [not personal] avlight90: 1990 regional intensity of nightlights
        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return [
            "agrsh90",
            "tersh90",
            "soesh90",
            "demplsh_m",
            "emplsh_m90",
            "demplsh_m8290",
            # "fiss_nsoe95",
            # "dfiss_nsoe",
            # "disc_nsoe95",
            # "ddisc_nsoe",
            # "compg_nsoe95",
            # "dcompg_nsoe"
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="dtariff-emplmf",
            table=table1,
            row="dtariff",
            col="empl_mf10",
            expected_range=(0, None)
        ))
        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="dtariff-female",
            table=table2,
            row="dtariff",
            col="fiss_nsoe",
            expected_range=(None, 0)
        ))
        table3 = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="dtariff-dis",
            table=table3,
            row="dtariff",
            col="disc_nsoe",
            expected_range=(0, None)
        ))
        table4 = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="dtariff-compsh",
            table=table4,
            row="dtariff",
            col="compsh_nsoe",
            expected_range=(None, 0)
        ))
        return results