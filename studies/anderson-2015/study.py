from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Anderson(Study):
    id = 'anderson-2015'

    def data_paths(self) -> dict:
        return {
            "programs-vill-aer": os.path.join(
                self.path(), "source/Data-AER-2013-0623", "programs-vill-aer.dta"
            )
            # 
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "gppop",
            "propc1",
            "propc4",
            "mlandc1"
        ]
    
    def _pre_processing(self, data):
        df = data["programs-vill-aer"]
        df["mpop"] = df["gppop"] * df["propc1"]
        df["scstpop"] = df["gppop"] * df["propc4"]
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["programs-vill-aer"]
        df["propc1"] = np.where(
            df["gppop"].isna(), df["propc1"],
            df["mpop"] / df["gppop"]
        )
        df["propc4"] = np.where(
            df["gppop"].isna(), df["propc4"],
            df["scstpop"] / df["gppop"]
        )
        df["mlandc1"] = df["marathaland"] * df["propc1"]
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `aer-table2.do`: ###
        # use programs-vill-aer.dta 
        # ...
        # eststo all: regress tprog marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 
        # ...
        # eststo poor: regress tptarget marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 
        # ...
        # eststo income: regress incomeprog marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 
        # ...
        # eststo nonincome: regress childelderprog marathaland propc1 mlandc1 gppop reserved  propc4 longitude latitude elevation distancetowater distancetoroad distancetorail water avgyrain wmahar marath evidar  secoc  secph  secnit jjarain , robust 
        

        sensitivities = {
            ### gppop: village population
            "gppop": lambda village: 1,

            ### propc1: Maratha population proportion
            # NOTE: reconstruct mpop = propc1 * gppop
            # gppop already noised
            "mpop": lambda village: 1,           

            ### propc4: SC/ST population proportion
            # NOTE: reconstruct scstpop = propc4 * gppop
            "scstpop": lambda village: 1,  

            ### mlandc1: marathaland * propc1
            # NOTE: reconstructing mlandc1 = marathaland * propc1
            # marathaland not personal
            # propc1 already noised

            # (not personal) tprog: all programs
            # (not personal) tptarget: BPL Programs (2): aggregated targeting to Below Poverty Line
            # (not personal) incomeprog: Income Programs (2): aggregated household data on income-related programs
            # (not personal) childelderprog: Non-income Programs (2): aggregated data on child/elder programs
            # (not personal) reserved: Dummy: GP seat reserved for SC/ST 
            # (not personal) longitude: Longitude
            # (not personal) latitude: Latitude
            # (not personal) elevation: Elevation
            # (not personal) distancetowater: Distance to Water
            # (not personal) distancetoroad: Distance to Road
            # (not personal) distancetorail: Distance to Rail
            # (not personal) avgyrain: rainfall levels
            # (not personal) jjarain: rainfall levels
            # (not personal) water: dummy variable, access to water?
            # (not personal) wmahar: dummy variable ??
            # (not personal) marath: dummy variable, maratha landlord
            # (not personal) evidar: dummy variable ??
            # (not personal) marathaland: dummy variable, maratha dominated (MLD)
            # (not personal) secoc: Secondary OC in soil
            # (not personal) secph: Primary OC in soil
            # (not personal) secnit: Secondary Nitrogen in soil
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="mld-all",
            table=table,
            row="marathaland",
            col="all",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="mld-poor",
            table=table,
            row="marathaland",
            col="poor",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="mld-income",
            table=table,
            row="marathaland",
            col="income",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="mld-nonincome",
            table=table,
            row="marathaland",
            col="nonincome",
            expected_range=(0, 0)
        ))
        return results