from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Jacob(Study):
    id = 'jacob-2024'

    def data_paths(self) -> dict:
        return {
            "SBE_base_data": os.path.join(
                self.path(), "source/replication/Final analysis data", "SBE_base_data.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "ln_enroll",
            "l_votes_per_seat_per_pop",
            "town",
            "rural",
            "urban",
            "perblk",
            "perhsp",
            "perfrl",
            "district_pct_trump",
            "agg_all",
            "baplusall"
        ]
    
    _student_shares = [
        "town",
        "rural",
        "urban",
        "perblk",
        "perhsp",
        "perfrl"
    ]
    
    def _pre_processing(self, data):
        df = data["SBE_base_data"]

        for v in self._student_shares:
            df[f"{v}_students"] = df[v] * df["tot_enroll"] * 1000
        df["test_total"] = df["agg_all"] * df["tot_enroll"] * 1000

        df["baplus_pop"] = df["baplusall"] * df["cnty_pop"]

        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["SBE_base_data"]
        df["ln_enroll"] = np.log(df["tot_enroll"])

        df["votes_per_seat"] = df["total_votes"] / df["seats_up_for_election"]
        df["votes_per_seat_per_pop"] = df["votes_per_seat"] / df["adult_civilian_population"]
        df["l_votes_per_seat_per_pop"] = np.where(
            df["votes_per_seat_per_pop"] > 0,
            np.log(df["votes_per_seat_per_pop"]),
            np.nan
        )

        df["district_pct_trump"] = np.where(
            df["district_vote_trump"].isna(),
            df["district_pct_trump"],
            df["district_vote_trump"] / df["district_vote_tot"]
        )

        for v in self._student_shares:
            df[v] = np.where(
                df["tot_enroll"].isna(),
                df[v],
                df[f"{v}_students"] / df["tot_enroll"] / 1000
            )
        df["agg_all"] = np.where(
            df["tot_enroll"].isna(),
            0,
            df["test_total"] / df["tot_enroll"] / 1000
        )

        df["baplusall"] = np.where(
            df["cnty_pop"] <= 0,
            0,
            df["baplus_pop"] / df["cnty_pop"]
        )
        
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `5_analysis.do`: ###
        # global finaldata "../Final analysis data"
        # ...
        # use "$finaldata/SBE_base_data.dta", clear
        # ...
        # tempfile tmp
        # save `tmp'
        # ...
        # global elvar "subdivision pri_partisan pri_nonpart any_incumbent ib11.el_month"
        # ...
        # /*******************************************************************************
        # table 5
        # ********************************************************************************/      
        # use `tmp',clear
        # eststo main: reg l_votes_per_seat_per_pop post_covid  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 , cl(office_name)
        
        sensitivities = {
            ### ln_enroll: Log District Total Enrollment
            # NOTE reconstructing ln_enroll = log(tot_enroll)
            # tot_enroll seems to be in 1,000s (see Table 2)
            "tot_enroll": {
                "sensitivity": lambda district: 1 / 1000,
                "lb": 1  # weighting var
            },

            ### l_votes_per_seat_per_pop: Log votes per seat per adult civilian
            # NOTE reconstructing l_votes_per_seat_per_pop = log(votes_per_seat_per_pop)
            # NOTE reconstructing votes_per_seat_per_pop = votes_per_seat / adult_civilian_population
            # NOTE reconstructing votes_per_seat = total_votes / seats_up_for_election
            # seats up for election not personal
            "total_votes": lambda district: 1,
            "adult_civilian_population": {
                "sensitivity": lambda district: 1 / 1000,
                "lb": 1  # weighting var
            },

            ### proportion students *
            # NOTE: created inter var *_students = * x tot_enroll x 1000
            # tot_enroll already noised
            ## town: proportion students in town locale school
            "town_students": lambda district: 1,
            ## rural: proportion students in rural locale schools
            "rural_students": lambda district: 1,
            ## urban: urban proportion students in rural locale school
            "urban_students": lambda district: 1,
            ## perblk: percent blacks in the district
            # per paper, this is the % students black
            "perblk_students": lambda district: 1,      
            ## perhsp: percent hispanic in the district
            # per paper, this is the % students hispanic
            "perhsp_students": lambda district: 1,      
            ## perfrl: percent free or reduced lunch in the district 
            # per paper, this is the % students FPL
            "perfrl_students": lambda district: 1,

            ### district_pct_trump: District Area-Weighted Trump 2016 Vote Percentage
            # NOTE reconstructing district_pct_trump = district_vote_trump / district_vote_tot
            "district_vote_trump": lambda district: 1,
            "district_vote_tot": lambda district: 1,
            
            ### agg_all: Aggregate District Mean Test Score (Weighted)
            # assuming agg_all = test_total / tot_enroll / 1000
            # NOTE created inter var test_total = agg_all x tot_enroll x 1000
            # tot_enroll already noised
            # NOTE assuming test score normalized to mean zero SD 1, then clipped at -3, 3 SD
            "test_total": lambda district: 3,
            
            ### baplusall: ba+ rate
            # seems to be county level, not district level
            # assuming baplusall = baplus_pop / cnty_pop
            # NOTE created inter var baplus_pop = baplusall x cnty_pop
            "cnty_pop": {
                "sensitivity": lambda district: 1 / 1000,
                "lb": 1  # weighting var
            },
            "baplus_pop": lambda district: 1,

            ### [not personal] post_covid: after march 10 2020
            ### [not personal] summer2020: Apr-Aug 2020
            ### [not personal] ay2022: Sept 2020 - Dec 2022
            ### [not personal] miss_scores:  Missing Test Scores
            ### [not personal] subdivision: whether subdivision
            ### [not personal] pri_partisan: whether primary election is partisan
            ### [not personal] pri_nonpart: whether primary is nonpartisan
            ### [not personal] any_incumbent: whether eleciton includes any incumbent
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="covid-turnout",
            table=table,
            row="post_covid",
            col="main",
            expected_range=(0, None),
            est_stats={"est": "b", "se": "se"}
        ))
        return results