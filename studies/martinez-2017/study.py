from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Martinez(Study):
    id = 'martinez-2017'

    def data_paths(self) -> dict:
        return {
            "VHeduc_Data": os.path.join(
                self.path(), "source/AEJApp-2015-0447_Dataset", "VHeduc_Data.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "lpopulation"
        ]
    
    def _post_processing(self, noised_data):
        df = noised_data["VHeduc_Data"]
        df['lpopulation'] = np.log(df['population'])
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `VHeduc_Do.do`: ###
        # use VHeduc_Data.dta, clear
        # ...
        #--- school-health
        # eststo health: areg dum i.post92##c.num_dev i.year lpopulation if dum !=., abs(v_id) cluster(idkab_num) 
        #--- school-doctor
        # eststo doctor: areg doc i.post92##c.num_dev i.year lpopulation if doc !=., abs(v_id) cluster(idkab_num) 
        #--- school-water
        # eststo water: areg safe i.post92##c.num_dev i.year lpopulation if safe !=., abs(v_id) cluster(idkab_num) 

        sensitivities = {
            ### lpopulation: log population in the village       
            "population": lambda village: 1,

            ### [not personal] doc: Whether there is a doctor in the village
            # relevant code:
            # notes about var1
            # "doc": lambda village: 1,
            # (not personal) dum: Primary health center in the village
            # (not personal) safe: Access to safe drinking water in the village
            # (not personal) i.post92: post 1992 dummy variable
            # (not personal) c.num_dev: num. INPRES schools. The number of INPRES schools is defined in deviations from its sample mean
            # (not personal) i.year: year dummy variable
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="school-health",
            table=table,
            row="1.post92#c.num_dev",
            col="health",
            expected_range=(0, None),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="school-doctor",
            table=table,
            row="1.post92#c.num_dev",
            col="doctor",
            expected_range=(0, None),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="school-water",
            table=table,
            row="1.post92#c.num_dev",
            col="water",
            expected_range=(0, None),
            est_stats={"est": "b", "se": "se"}
        ))
        return results