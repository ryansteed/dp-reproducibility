from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Barbanchon(Study):
    id = 'barbanchon-2021'

    def data_paths(self) -> dict:
        return {
            "database": os.path.join(
                self.path(), "source/Input", "database.dta"
            ),
            "census_munic_pop_age_emp_8214": os.path.join(
               self.path(), "source/Source", "census_munic_pop_age_emp_8214.dta"
            ),
            # "database_LRcoalitions": os.path.join(
            #    self.path(), "source/Source", "database_LRcoalitions.dta"
            # ),
            #"database_allcandidates": os.path.join(
            #    self.path(), "source/Source", "database_allcandidates.dta"
            #),
            # "presidentialscore": os.path.join(
            #     self.path(), "source/Source", "presidentialscore.dta"
            # )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        return [
            "scoreP1",
            "betterpoli",
            "jobs",
            "contest3P_",
            # "age_ind_occ_egap",
            "scoreL1",
            # "inter*",
            "pop_tot_"
        ]
    
    def _skip_validation(self) -> list:
        return [
            "contest3P_"
        ]
    
    def _pre_processing(self, data):
        for key in data.keys():
            df = data[key]
            self._rounds = {
                "1UMP": "L1",
                "1PS": "L1",
                "2UMP": "L1",
                "2PS": "L1",
                "L1": "L1",
                "L2": "L2"
            }
            for round, denom in self._rounds.items():
                # deconstructing score*
                if (key == "database") | (key in ["L1", "L2"]):
                    df[f"voted{round}"] = df[f"score{round}"] * df[f"votants{denom}"]
            data[key] = df
        return data
    
    def _post_processing(self, noised_data):
        for key in noised_data.keys():
            df = noised_data[key]
            for round, denom in self._rounds.items():
                # reconstructing score*
                if (key == "database") | (key in ["L1", "L2"]):
                    df[f"score{round}"]  = df[f"voted{round}"] / df[f"votants{denom}"]
            noised_data[key] = df

            if key == "database":
                df = noised_data["database"]
                # reconstructing scoreP*
                df["scoreP1"] = np.where(
                    df["coalition"] == "UMP", df["score1UMP"], df["score1PS"]
                )
                df["scoreP2"] = np.where(
                    df["coalition"] == "UMP", df["score2UMP"], df["score2PS"]
                )
                # reconstructing betterpoli
                df["betterpoli"] = df["sum_betterpoli"] / df["n_betterpoli"]
                # reconstructing jobs
                df["jobs"] = df["sum_jobs"] / df["n_jobs"]
                # reconstructing contest3P_
                df["contest3P_"] = (df["scoreP2"] >= (0.5 - 3/100)) & (df["scoreP2"] <= (0.5 + 3/100))
                df["diffscore1_RL"] = df["score1UMP"] - df["score1PS"]
                df["contest3P1"] = df["diffscore1_RL"].between(-0.03, 0.03)
                df.loc[
                    (df["electionl"] == 2002) | (df["electionl"] == 2017),
                    "contest3P_"
                ] = df["contest3P1"]

            if key == "census_munic_pop_age_emp_8214":
                df["pop_tot_"] = np.round(df["pop_tot_"])
        
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Reg_DistrictLevel.do`: ###
        #-- attitude1-select, attitude2-select
        # use database, clear
        # ...
        # foreach var of varlist betterpoli jobs{
        # ...
        # eststo D_`var': xi: reghdfe F `var' gouv entry incumbent i.localmandate_ scoreP1, a(coal_election age_ PCS_3f_ alumni) cl(candidatid district_electionl_g)
        # ...
        # }
        # ...
        #--- contest-select
        # eststo F: xi: reghdfe F contest3P_ scoreP1 gouv entry incumbent age_ind_occ_egap i.localmandate_ if inrange(electionl,2002,2017), ///
	    #     a(coal_election age_ PCS_3f_ alumni circouniqueid) cl(candidatid district_electionl_g)
        ###

        ### relevant regression code from `Reg_MunicipalLevel.do`: ###
        # use ../Source/database_LRcoalitions, replace
        # ...
        # joinby candidatid electionl using "../Source/Legislatives-Municipalities.dta"
        # ...
        # joinby code_insee year_census using "../Source/census_munic_pop_age_emp_8214.dta"
        # ...
        # merge m:1 comr year using ../Source/wagegaps_muni
        
        #--- gap-vote
        # ...
        # eststo: xi: reghdfe scoreL1 inter inter3 inter4 inter4b intermissage interage interincumbent intergouv interentry inter2 [w=pop_tot_], ///
        # 	a(ce com_electionl) cl(candidatid com_electionl)  tolerance(1e-2)
        ###
        sensitivities = {
            #--- database
            ### scoreP1: Presidential Elect. Party Score (Round 1)
            #> from `CreateFinalSample.do` (NOT run):
            # gen scoreP1=score1UMP if coalition=="UMP"
            # replace scoreP1=score1PS if coalition=="PS"
            #>
            # assuming scoreP1 = voted* / votantsL1 where * is coalition
            # votantsL1: # of voters in the district for the first round of the legislative election
            "votantsL1": lambda districtyear: 1,
            # NOTE: created var voted1* = score1* * votantsL1
            "voted1PS": lambda districtyear: 1,
            "voted1UMP": lambda districtyear: 1,

            ### betterpoli: % agree with "Men better political leaders"
            # NOTE: reconstructed betterpoli = sum_betterpoli / n_betterpoli
            "sum_betterpoli": lambda districtyear: 1,
            "n_betterpoli": lambda districtyear: 1,
            
            ### jobs: % agree with "When jobs are scarce, men should have more right to a job than women"
            # NOTE: reconstructed jobs = sum_jobs / n_jobs
            "sum_jobs": lambda districtyear: 1,
            "n_jobs": lambda districtyear: 1,

            ### contest3P_: Contestable district using relevant presidential election score, dummy
            # equals 1 if the vote margin between the Left and the Right parties in the runoff of the previous Presidential election was between 3 and C3 percentage points (respectively, in the first round of the previous Presidential election for the 2002 and 2017 Presidential elections)
            #> from `CreateFinalSample.do` (NOT run):
            # gen scoreP2=score2UMP if coalition=="UMP"
            # replace scoreP2=score2PS if coalition=="PS"
            # ...
            # * Compute contestability measures based on presidential and parliamentary elections' scores
            # forvalues i=1(1)3{
            # gen contest`i'P=scoreP2>=0.5-`i'/100&scoreP2<=0.5+`i'/100 if missing(scoreP2)==0
            # label var contest`i'P "Party score within 2x`i' bandwidth around 0.5 in round 2 of previous presidential election"
            # ...
            # }
            # gen contest3P_=contest3P 
            # gen diffscore1_RL=score1UMP-score1PS
            #>
            # scoreP2: Presidential Elect. Party Score (Round 2)
            # assuming scoreP2 = voted* / votantsL1 where * is coalition
            # NOTE: created var voted2* = score2* * votantsL1
            # already votantsL1
            "voted2PS": lambda districtyear: 1,
            "voted2UMP": lambda districtyear: 1,

            ### age_ind_occ_egap: Gender gap in earnings (control. for AGE, IND, OCC)
            # some residualized earnings gap; code not provided
            # NOTE: not enough info for DP

            ### [not personal] electionl: election year
            ### [microdata] F: female dummy
            ### [not personal] gouv: Current or Former Govt. Member dummy
            ### [not personal] entry: First-time candidate dummy
            ### [not personal] incumbent: Incumbent dummy
            #---

            #--- database_LRcoalitions
            ### scoreL1: Electoral Score (vote share, Round 1 - legislative)
            # assuming scoreL1 = votedL1 / votantsL1
            # NOTE: created var votedL1 = scoreL1 * votantsL1
            # votantsL1 already noised
            "votedL1": lambda districtyear: 1,
            #---

            #--- wagegaps_muni
            ### inter*
            #> from `Reg_MunicipalLevel.do` (run):
            # cap gen inter=.
            # ...
            # foreach var of varlist age_ind_occ_egap {
            # replace bias=`var'
            # replace inter=F*`var'
            # replace interR=(parti_stab=="R")*F*`var'
            # replace interL=(parti_stab=="L")*F*`var'
            # replace inter2=(parti_stab=="R")*`var'
            # replace inter3=alumni*`var'
            # label var inter3 "Elite educ. x LM bias"
            # replace inter4=PCS_3f*`var'
            # label var inter4 "High educ. x LM bias"
            # replace inter4=0 if missing(PCS_3f)
            # replace inter4b=missing(PCS_3f)*`var'
            # label var inter4b "Miss. occ. x LM bias"
            # replace interincumbent=incumbent*`var'
            # replace intergouv=gouv*`var'
            # replace interentry=entry*`var'
            # replace intermissage=(age_==0)*`var'
            # replace interage=age_*`var'
            #     }
            #>
            # all of these require age_ind_occ_egap
            # NOTE: not enough info for DP 
            #--- 

            #--- census_munic_pop_age_emp_8214
            ### pop_tot_: Total population
            "pop_tot_": {
                "sensitivity": lambda districtyear: 1,
                "lb": 0
            }
            
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="attitude1-select",
            table=table,
            row="betterpoli",
            col="D_betterpoli",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="attitude2-select",
            table=table,
            row="jobs",
            col="D_jobs",
            expected_range=(None, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="gap-vote",
            table=table,
            row="inter",
            col="est5",
            expected_range=(None, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table4.csv")
        results.append(Result.from_esttab(
            id="contest-select",
            table=table,
            row="contest3P_",
            col="F",
            expected_range=(None, 0)
        ))
        return results