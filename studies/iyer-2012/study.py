from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Iyer(Study):
    id = 'iyer-2012'

    def data_paths(self) -> dict:
        return {
            "tables1to5.dta": os.path.join(
                self.path(), "source", "20110220_IMMT_ReplicationData", "tables1to5.dta"
            ),
            # "tables6.dta": os.path.join(
            #     self.path(), "source", "20110220_IMMT_ReplicationData", "table6.dta"
            # )
            # ...
        }

    def _pre_processing(self, data):
        df = data["tables1to5.dta"]

        # deconstructing p*
        for v in ["rural", "lit", "farm", "cgsdp"]:
            df[v] = df[f"p{v}"] * df["ipop"]
        # deconstructing p* per 1000
        for v in ["pol_strength", "cr_womtot", "kidmen", "murder", "suic_f"]:
            df[v] = df[f"p{v}"] * df["ipop"] / 1000

        data["tables1to5.dta"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["tables1to5.dta"]

        # reconstructing pfemale
        df["ifemale"] = df["ipop"] - df["imale"]
        df["pfemale"] = df["ifemale"] / df["imale"]
        # reconstructing p*
        for v in ["rural", "lit", "farm", "cgsdp"]:
            df[f"p{v}"] = df[v] / df["ipop"]
        # reconstructing p* per 1000
        for v in ["pol_strength", "cr_womtot", "kidmen", "murder", "suic_f"]:
            df[f"p{v}"] = df[v] / df["ipop"] * 1000
            if v != "pol_strength":
                df[f"lp{v}"] = np.where(
                    df[f"lp{v}"].isna(),
                    np.nan,
                    np.log(df[f"p{v}"])
                )

        noised_data["tables1to5.dta"] = df
        return noised_data
    
    def vars_to_noise(self):
        return [
            "pfemale",
            "prural",
            "plit",
            "pfarm",
            "pcgsdp",
            "ppol_strength",
            "lpcr_womtot",
            "lpkidmen",
            "lpmurder",
            "lpsuic_f"
        ]
    
    def other_vars(self):
        return [
            "postwres",
            "womancm"
        ]
    
    def time_index(self) -> str:
        return "year"
    
    def subset_index(self):
        return "stateid"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `IMMT_20110220.do`: ###
        #-- postwres-crime
        # use tables1to5.dta, clear
        # ...
        # foreach X in lprape2 lpwomgirl lpcr_womtot{
        # ...
        # xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strength i.stateid*year i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
        # ...
        # }

        #-- postwres-mencrime
        # use tables1to5.dta, clear
        # ...
        # foreach X in  lpcr_prop lpcr_order lpcr_econ lpkidmen {
        # ...
        # eststo core6: xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.stateid*year i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
        # ...
        # }

        #-- postwres-murder
        # use tables1to5.dta, clear
        # ...
        # eststo core3: xi: areg lpmurder postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
        # ...
        #-- postwres-suicide
        # foreach X in lpsuic_f lpsuic_m {
        # ...
        # eststo: xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
        # ...
        # }
        ###
        vars_to_noise = {
            ### pfemale: Female-male ratio
            # pfemale = ifemale / imale
            # NOTE: reconstructed pfemale = (ipop - imale) / imale
            "imale": lambda provinceyear: 1,
            "ipop": {
                "sensitivity": lambda provinceyear: 1,
                "lb": 1
            },

            ### p* vars
            # NOTE: created var * = p* * ipop
            # already noised ipop
            ## prural: Fraction rural
            "rural": lambda provinceyear: 1,
            ## plit: Fraction literate
            "lit": lambda provinceyear: 1,
            ## pfarm: Fraction in farming
            "farm": lambda provinceyear: 1,
            ## pcgsdp: Per capita Gross State Domestic Product
            # domestic product not private; already noised ipop
            
            ### ppol_strength: Number of police personnel per 1000 pop
            # NOTE: created var police = ppol_strength * ipop / 1000
            "pol_strength": {
                "sensitivity": lambda provinceyear: 1,
                "lb": 0,
            },
            # already noised ipop

            #-- postwres-crime
            ### lpcr_womtot:  Log(total crimes against women per 1000 women)
            # lpcr_womtot = log(pcr_womtot)
            # pcr_womtot exists
            # NOTE: created var * = p* * ipop / 1000
            "cr_womtot": {
                "sensitivity": lambda provinceyear: 1,
                "lb": 1,
            },
            # ipop already noised

            #-- postwres-mencrime
            ### lpkidmen: Log(kidnapping of men and boys per 1000 men)
            # NOTE: created var * = p* * ipop / 1000
            "kidmen": {
                "sensitivity": lambda provinceyear: 1,
                "lb": 1,
            },
            # ipop already noised

            #-- postwres-murder
            ### lpmurder: Log(murders per 1000 pop)
            # NOTE: created var * = p* * ipop / 1000
            "murder": {
                "sensitivity": lambda provinceyear: 1,
                "lb": 1,
            },
            # ipop already noised

            #-- postwres-suicide
            ### lpsuic_f: Log(suicides of women per 1000 women)
            # NOTE: created var * = p* * ipop / 1000
            "suic_f": {
                "sensitivity": lambda provinceyear: 1,
                "lb": 1
            },
            # ipop already noised

            ### [not personal] postwres: Post-reservation dummy
            ### [not personal] womancm: Women Chief Minister dummy
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table3 = self._load_esttab(f"{self.path()}/results/table3_lpcr_womtot.csv")
        results.append(Result.from_esttab(
            id="postwres-crime",
            table=table3,
            row="postwres",
            col="m6",
            expected_range=(0, None)
        ))
        table4 = self._load_esttab(f"{self.path()}/results/table4_lpkidmen.csv")
        results.append(Result.from_esttab(
            id="postwres-mencrime",
            table=table4,
            row="postwres",
            col="core6",
            expected_range=(0, 0)
        ))
        table5 = self._load_esttab(f"{self.path()}/results/table5_lpsuic_f.csv")
        results.append(Result.from_esttab(
            id="postwres-murder",
            table=table5,
            row="postwres",
            col="core3",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="postwres-suicide",
            table=table5,
            row="postwres",
            col="m5",
            expected_range=(0, 0)
        ))
        # table6 = self._load_esttab(f"{self.path()}/results/table6_s_attack.csv")
        # results.append(Result.from_esttab(
        #     id="reswomen-crime",
        #     table=table6,
        #     row="res_woman",
        #     col="f_anycrime",
        #     expected_range=(0, 0)
        # ))
        # no aggregate data
        # table7 = self._load_esttab(f"{self.path()}/results/table7.csv")
        # results.append(Result.from_esttab(
        #     id="reswomen-report",
        #     table=table7,
        #     row="res_woman",
        #     col="f_ave_fir",
        #     expected_range=(0, None)
        # ))
        return results