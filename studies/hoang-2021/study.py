from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Hoang(Study):
    id = 'hoang-2021'

    def data_paths(self) -> dict:
        return {
            "Data": os.path.join(
                self.path(), "source", "Data.dta"
            )
            # ...
        }
    
    def _pre_processing(self, data):
        df = data["Data"]

        # deconstruct *pc vars
        self._pcvars = [
            "ell",
            "black",
            "lunchfr"
        ]
        for v in self._pcvars:
            df[v] = df[f"{v}pc"] / 100 * df["enrtot"]

        data["Data"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["Data"]

        # reconstruct lnenrtot
        df["lnenrtot"] = np.log(df["enrtot"])
        
        # reconstruct *pc vars
        for v in self._pcvars:
            df[f"{v}pc"] = df[v] / df["enrtot"] * 100

        noised_data["Data"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "lnenrtot",
            "ellpc",
            "blackpc",
            "lunchfrpc"
        ]
    
    def other_vars(self):
        return [
            "vg",
            # I* vars cause collinear error, removing
            # "Ir_n0", "Ir_n1", "Ir_n2", "Ir_n3", "Ir_n4",
            # "Ir_p1", "Ir_p2", "Ir_p3", "Ir_p4", "Ir_p5",
            # "Ir_p6", "Ir_p7", "Ir_p8", "Ir_p9", "Ir_p10", "Ir_p11",
            "P",
            "vg_res",
            "vg_com",
            "v",
            "N",
            "I",
            "pretrend",
            "posttrend"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "id"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Do-file.do`: ###
        # use "Data", clear
        # ...
        #--- N-nontif
        # eststo: xtreg v I N pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
        #--- I-nontif
        # eststo: xtreg vg I N pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
        # ...
        #--- I10-resi
        # eststo: xtreg vg_res Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
        # ...
        #--- I10-comm
        # eststo:xtreg vg_com Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
        ###
        sensitivities = {
            ### lnenrtot: Logged total enrollment
            # NOTE: reconstructed lnenrtot = ln(enrtot)
            "enrtot": lambda districtyear: 1,

            ### *pc vars
            # *pc = * / enrtot * 100
            # NOTE: created vars * = *pc / 100 * enrtot
            ## ellpc: Percent of ELL students
            "ell": lambda districtyear: 1,
            ## blackpc: Percent of African American students
            "black": lambda districtyear: 1,
            ## lunchfrpc: Percent of free and reduced price lunch students
            "lunchfr": lambda districtyear: 1,

            ### [not personal] vg: V_g = V + I_e
            ### [not personal] Ir_n0-4: I_r, when r=-*
            ### [not personal] Ir_p1-11: I_r, when r=+*
            ### [not personal] P: Prior-year I of discontinued TIF districts, P
            ### [not personal] vg_res: V_g for residential property
            # NOTE: considering this not personal, despite residential
            ### [not personal] vg_com: V_g for commercial property
            ### [not personal] v: Total non-TIF taxable property value (V)
            ### [not personal] yeard*: Year Dummy for *
            ### [not personal] N: # of active TIF (tax increment financing) districts, N
            ### [not personal] I: Incremental value, I
            ### [not personal] pretrend: pre-trend lag
            ### [not personal] posttrend: post-trend lag
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table.csv")
        results.append(Result.from_esttab(
            id="I-nontif",
            table=table,
            row="I",
            col="est2",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="N-nontif",
            table=table,
            row="Nvar",
            col="est1",
            expected_range=(0, 0)
        ))
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="I10-resi",
            table=table1,
            row="Ir_p10",
            col="est1",
            expected_range=(0, None)
        ))
        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="I10-comm",
            table=table2,
            row="Ir_p10",
            col="est1",
            expected_range=(0, None)
        ))
        return results