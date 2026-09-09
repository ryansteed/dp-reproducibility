from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Egger(Study):
    id = 'egger-2010'

    def data_paths(self) -> dict:
        return {
            "EggerKoethenbuerger_AEJ_Data": os.path.join(
                self.path(), "source/Data", "EggerKoethenbuerger_AEJ_Data.dta.dta"
            ),
            "final": os.path.join(
                self.path(), "source/Data", "final.dta"
            ), # created by us, for comparision only
        }
    
    def vars_to_noise(self):
        return {
            "post_replication": [
                "lwpop",
                "lwpop_2",
                "lwpop_3",
                "right",
                "lwpop_r1",
                "lwpop_r2",
                "lwpop_r3"
            ]
        }

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `EggerKoethenbuerger_AEJ_results_27May2010.do`: ###
        # ****** Results Table 3 ******
        # foreach w in 15 ... {
        # use  window`w'_thresh1000_TALL_wpopdem.dta, replace
        # gen thresh=1000
        # foreach t in 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
        # append using  window`w'_thresh`t'_TALL_wpopdem.dta
        # replace thresh=`t' if thresh==.
        # }
        # gen right=lwpop>0
        # sum lwpop
        # gen lwpop_2=lwpop^2
        # gen lwpop_3=lwpop^3
        # gen lwpop_r1=lwpop*right
        # gen lwpop_r2=lwpop_2*right
        # gen lwpop_r3=lwpop_3*right
        # ...
        # eststo: reg lexptot right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
        # ...
        # }

        sensitivities = {
            ### lwpop: log population
            #>
            # foreach X in exptot exppers expsach expsachinv debt tratea trateb tratep wpop rcsize {
            # g l`X'=ln(`X')
            # }
            # ...
            # foreach pp in 1 2 3 4 5 {
            # g lwpop_`pp'=lwpop^`pp'
            # }
            #>
            # wpop: population
            "wpop": lambda municipalityyear: 1,

            ### lwpop_2
            #> gen lwpop_2=lwpop^2
            # lwpop already noised
            
            ### lwpop_3
            #> gen lwpop_r3=lwpop_3*right 
            # lwpop already noised

            ### right: "Treatment: council size to the right versus to the left of a threshold in election year t" 
            #> gen right=lwpop>0
            # lwpop already noised
            
            ### lwpop_r1
            #> gen lwpop*right
            # lwpop already noised
            
            ### lwpop_r2
            #> gen lwpop_2*right
            # lwpop already noised
            
            ### lwpop_r3
            #> gen lwpop_3*right
            # lwpop already noised

            ### [not personal] lexptot: "Total Municipal Expenditure"
            # comes from exptot
            # cross-referencing with Table 2, exptot appears to not be per capita

        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="size-expenditure",
            table=table,
            row="right",
            col="w15",
            expected_range=(0, None)
        ))
        return results