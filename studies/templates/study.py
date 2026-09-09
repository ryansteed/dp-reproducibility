from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class This(Study):
    id = 'author-year'

    def data_paths(self) -> dict:
        return {
            "dtaFile1": os.path.join(
                self.path(), "source", "dtaFile1.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "var1",
            # ...
        ]
    
    def _pre_processing(self, data):
        return data
    
    def _post_processing(self, noised_data):
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `doFile1.do`: ###
        ###
        sensitivities = {
            ### vargroup 1
            ## var1
            # relevant code:
            # notes about var1
            "var1": lambda area: 1,
            
            # ...
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table.csv")
        results.append(Result.from_esttab(
            id="indvar-depvar",
            table=table,
            row="indvar",
            col="depvar",
            expected_range=(None, None)
        ))
        return results