from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Fernandez(Study):
    id = 'fernandez-2021'

    def data_paths(self) -> dict:
        return {
            "oes_2000_2019_modified": os.path.join(
                self.path(), "source", "oes_2000_2019_modified.dta"
            ),
            "pr_county_estab": os.path.join(
                self.path(), "source", "pr_county_estab.dta"
            )
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "tot_emp",
            "qtrly_estabs_count",
            "i_pop"
        ]
    
    def _pre_processing(self, data):
        df = data["pr_county_estab"]
        df["num_offices"] = df["qtrly_estabs_count"].astype('float64') * (df["i_pop"].astype('float64') / 100000)
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["pr_county_estab"]
        df.loc[
            df["i_pop"].notna() & df["i_pop"].astype('float64').gt(0),
            "qtrly_estabs_count"
        ] = np.round(df["num_offices"] / (df["i_pop"].astype('float64') / 100000))
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `AEA_PP_do_file.do`: ###
        #--- hurr-health
        # use "oes_2000_2019_modified.dta", clear
        # eststo: xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-0000" ,fe r i(state_fips) 
        #--- hur_phy, hur-phyrate
        # use "pr_county_estab.dta"
        # eststo: xtpoisson qtrly_estabs_count treat* i.time, fe i(area_fips) r 
        # eststo: xtpoisson qtrly_estabs_count treat* i.time, fe i(area_fips) r e(i_pop)
        sensitivities = {
            #--- hurr-health
            ### tot_emp: total healthcare employment
            "tot_emp": {
                "sensitivity": lambda state: 1,
                "lb": 1
            },

            #--- hur_phy, hur-phyrate
            ### i_pop: county population
            "i_pop": {
                "sensitivity": lambda countyquarter: 1,
                "lb": 1
            }

            ### qtrly_estabs_count: the number of physician offices per 100,000 people
            # qtrly_estabs_count = num_offices / (i_pop / 100000)
            # NOTE created inter var num_offices = qtrly_estabs_count * (i_pop / 100000)
            # i_pop already noised
            # [not personal] num_offices

            # [not personal] treat treat2008 treat_2014: dummy variable equal to 1 for Puerto Rico after 2017 and 0 otherwise
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table.csv")
        results.append(Result.from_esttab(
            id="hurr-health",
            table=table,
            row="treat",
            col="est1",
            expected_range=(None, 0)
        ))
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="hur-phy",
            table=table1,
            row="treat",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="hur-phyrate",
            table=table1,
            row="treat",
            col="est2",
            expected_range=(0, None)
        ))
        return results