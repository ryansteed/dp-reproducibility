from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Kumar(Study):
    id = 'kumar-2024'

    def data_paths(self) -> dict:
        return {
            "state_year_panel_dataset": os.path.join(
                self.path(), "source/replicate/data", "state_year_panel_dataset.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "beapop",
            "lfpr",
            # "L1lnrahem",
            "age",
            "female",
            "married",
            # "child",
            "white",
            "black",
            "hsgrad",
            "collegeplus"
        ]
    
    _pop_shares = ["age","female","married","white","black","hsgrad","collegeplus"]
    
    def _pre_processing(self, data):
        df = data["state_year_panel_dataset"]
        df["lf"] = df["lfpr"] / 100 * df["beapop"]
        for i in self._pop_shares: 
            df[f"{i}_total"] = df[i] * df["beapop"]
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["state_year_panel_dataset"]
        # lfpr
        df["lfpr"] = np.where(
            df["beapop"].isna(),
            df["lfpr"], 
            df["lf"] / df["beapop"] * 100
        )
        # L1nrahem
        df["L1lnrahem"] = df["lnrahem"].shift(1)
        # share vars
        for i in self._pop_shares: 
            df[i] = np.where(df["beapop"].notna(),
                             df[f"{i}_total"] / df["beapop"], 
                             df[i])
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table3.do`: ###
        # use "../data/state_year_panel_dataset.dta", clear
        # ...
        # global expl1 L1lnrahem L1sttaxr L1lnhpifhfa
        # global expl2 age female married child white black hsgrad collegeplus
        # ...
        # eststo: reg lfpr _Istatefips* _Iyear* _IdivXyea* _IstaXt_* $expl1 $expl2 inter_bra texas_post1997to2003 texas_post2003 [w=beapop], robust cluster(statefips)
        
        sensitivities = {
            ### beapop: state population
            "beapop": lambda state: 1,

            ### lfpr: labor force participation rate (LFPR)
            # assuming lfpr = lf / beapop * 100
            # NOTE created inter var lf = lfpr / 100 * beapop
            # beapop already noised
            "lf": lambda state: 1,

            ### L1lnrahem: Lagged State Log real wage (manuf, avg)
            # assuming L1lnrahem = lag(l1nrahem)
            # assuming l1nrahem = ln(real wage)
            # NOTE cannot noise without denominator (# manuf workers)

            ### state-level demographic variables
            # NOTE: reconstruct variable_total = variable * beapop
            # beapop already noised
            ## age: Average age
            # NOTE: assuming age no greater than 120
            "age_total": lambda state: 120,
            ## female: Share Female
            "female_total": lambda state: 1,
            ## married: Share Married
            "married_total": lambda state: 1,
            ## white: Share white
            "white_total": lambda state: 1,
            ## black: Share black
            "black_total": lambda state: 1,
            ## hsgrad: Share with hign school
            "hsgrad_total": lambda state: 1,
            ## collegeplus: Share with college+
            "collegeplus_total": lambda state: 1,

            ### child: Share HH with Children
            # NOTE: # households not given, cannot noise

            ### [not personal] L1sttaxr: Lagged State average income tax rate
            ### [not personal] L1lnhpifhfa: Lagged State Log house price index
            ### (not personal)_Istatefips*: state fips indicator variable
            ### (not personal)_Iyear*: year indicator variable
            ### (not personal)_IdivXyea*
            ### (not personal)_IstaXt_* 
            ### (not personal) inter_bra: bank branching index 
            ### (not personal) texas_post1997to2003: Texas X 1997-2003
            ### (not personal) texas_post2003: Texas X Post 2003
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="hel-labor",
            table=table,
            row="texas_post1997to2003",
            col="hellabor",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        results.append(Result.from_esttab(
            id="heloc-labor",
            table=table,
            row="texas_post2003",
            col="hellabor",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        return results