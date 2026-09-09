from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Glenn(Study):
    id = 'glenn-2009'

    def data_paths(self) -> dict:
        return {
            "streg128_new": os.path.join(
                self.path(), "source", "AEJPol2007-0029_data","streg128_new.dta"
            ),
            "streg256_new": os.path.join(
                self.path(), "source", "AEJPol2007-0029_data","streg256_new.dta"
            )
            # ...
        }
    
    def _post_processing(self, noised_data):
        for name in noised_data.keys():
            df = noised_data[name]
            df["lpop00"] = np.log(df["pop00"])
            noised_data[name] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `stregs.do`: ###
        #-- salestax-128
        # use streg128_new.dta
        # ...
        # eststo: nbreg torder lpop00 homeintf salestax cpergas calif shiptime
        # ...
        #-- salestax-256
        # use streg256_new.dta
        # ...
        # eststo: nbreg torder lpop00 homeintf salestax cpergas calif shiptime
        ###
        vars_to_noise = {
            #-- streg128_new
            ### torder: orders of 128MB module
            "torder": {
                "sensitivity": lambda stateyear: 1,
                "lb": 0
            },
            ### lpop00: log(Population)
            # NOTE: reconstructing from pop00
            "pop00": lambda stateyear: 1,
            ### homeintf: % households with home internet access
            # NOTE: # hhs not included, not enough noise for DP
            
            ### [not personal] salestax: offline sales tax rate
            ### [not personal] cpergas: computer stores / gas stations
            ### [not personal] calif: california dummy
            ### [not personal] shiptime: USPS ground shipping time
            
            #-- streg256_new
            ### toorder: same as above
            ### lpop00: same as above
            ### homeintf: same as above
            ### salestax: same as above
            ### cpergas: same as above
            ### calif: same as above
            ### shiptime: same as above
        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return [
            "torder",
            "lpop00",
            # "homeintf"
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table128 = self._load_esttab(f"{self.path()}/results/table128.csv")
        results.append(Result.from_esttab(
            id="salestax-128",
            table=table128,
            row="salestax",
            col="est1",
            expected_range=(0, None)
        ))
        table256 = self._load_esttab(f"{self.path()}/results/table256.csv")
        results.append(Result.from_esttab(
            id="salestax-256",
            table=table256,
            row="salestax",
            col="est1",
            expected_range=(0, None)
        ))
        return results