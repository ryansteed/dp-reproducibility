from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Bostwick(Study):
    id = 'bostwick-2022'

    def data_paths(self) -> dict:
        return {
            "ipeds_cleaned_final": os.path.join(
                self.path(), "source/Data", "ipeds_cleaned_final.dta"
            ),
            'final': os.path.join(
                self.path(), "source/Data", "final.dta"
            ), # created by us, for monitoring only
        }
    
    def vars_to_noise(self) -> dict:
        # list all personal vars used in the regression
        return {
            "post_replication": [
                "faculty",
                "meansize",
                "per_white",
                "per_urm",
                "per_fem",
                "gradrate4yr",
            ]
        }
    
    def _post_processing(self, noised_data):
        df = noised_data["ipeds_cleaned_final"]

        df["gradrate4yr"] = df["tot4yrgrads"] / df["totcohortsize"]

        df["meansize"] = df.groupby("unitid")["totcohortsize"].transform("mean")

        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `IPEDS_Analysis_Tables.do`:
        # use ipeds_cleaned_final.dta, replace
        # ...
        # *Define controls 
        # global timevar "instatetuition faculty  costs per_urm per_white  per_fem"
        # ...
        # ***Table 3: Effect of Switching to Semesters on Graduation Rates (main table of results) 
        # ...
        # *Column 4
        # eststo: areg gradrate4yr  block1 block2     i.year c.year#i.unitid $timevar   [aw=meansize]  , cluster(unitid) abs(unitid)
        ###

        ###
        sensitivities = {
            ### faculty: Instructional staff on 9, 10, 11 or 12 month contract-total
            "faculty": lambda institution: 1,
            
            ### per_fem: percent of students female
            #> gen per_fem=(w_cohortsize/totcohortsize)
            "totcohortsize": {
                "sensitivity": lambda institution: 1,
                "lb": 1
            },

            "w_cohortsize": lambda institution: 1,
           
            ### per_white: percent of students white 
            #> gen per_white=(white_cohortsize/totcohortsize)
            # totcohortsize already noised
            "white_cohortsize": lambda institution: 1,
            
            ### per_urm: percent of students who are urms
            #> gen per_urm=(urm_cohortsize/totcohortsize)
            # totcohortsize already noised
            "urm_cohortsize": lambda institution: 1,

            ### gradrate4yr: four-year graduation rate
            #> gen gradrate4yr=tot4/totcoh
            # NOTE: reconstructing gradrate4yr = tot4yrgrads / totcohortsize
            # totcohortsize already noised
            "tot4yrgrads": lambda institution: 1,

            ### meansize: All regressions are weighted by average cohort size
            #> generation code in "Master_Create_IPEDS.do"
            #> *drop very small schools as they are not representative.
            #> *Estimates are not sensitive to this sample selection 
            #> bysort unitid: egen meansize = mean(totcohortsize)
            #> drop if meansize<100
            # NOTE: reconstructing meansize = by unitid: mean(totcohortsize)
            # totcohortsize already noised

            # (not personal) block1: post-period indicator
            # (not personal) block2: post-period indicator
            # (not personal) i.year
            # (not personal) i.unitid
            # (not personal) instatetuition: In-state average tuition for full-time undergraduates
            # (not personal) costs: Total current funds expenditures transfers
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="switch-graduate",
            table=table,
            row="block2",
            col="est1",
            expected_range=(None, 0),
            est_stats={"est": "b", "se": "se"}
        ))
        return results