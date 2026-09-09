from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Evans(Study):
    id = 'evans-2024'

    def data_paths(self) -> dict:
        return {
            "stacked_1": os.path.join(
                self.path(), "source/replication_code", "stata_data_files", "stacked_1.dta"
            ),
            "temp1": os.path.join(
                self.path(), "source/replication_code", "stata_data_files", "temp1.dta"
            ),
            # ...
        }
    
    def vars_to_noise(self) -> dict[str, list[str]]:
        # list all personal vars used in the regression
        return {
            "pre_replication": [
                "enroll_total",
                "single_parent",
                "high_school",
                "some_college",
                "college_deg",
                "poverty",
                "medhhincwkids_r"
            ],
            "post_replication": [
                "per_black",
                "per_asian",
                "per_hispanic",
                "per_other",
                "ca_rate",
            ]
        }
    
    pop_shares = [
        "high_school",
        "some_college",
        "college_deg",
        "poverty"
    ]
    def _pre_processing(self, data):
        for k in self.data_paths().keys():
            df = data[k]
            df["n_single_parent"] = df["single_parent"] / 100 * df["enroll_total"]
            for var in self.pop_shares:
                df[f"n_{var}"] = df[var] / 100 * df["pop"]
        return data
    
    def _post_processing(self, noised_data):
        for k in self.data_paths().keys():
            df = noised_data[k]
            df["single_parent"] = np.where(
                df["enroll_total"] > 0,
                df["n_single_parent"] / df["enroll_total"] * 100,
                df["single_parent"]
            )
            for var in self.pop_shares:
                df[var] = np.where(
                    df["pop"] > 0,
                    df[f"n_{var}"] / df["pop"] * 100,
                    df[var]
                )

        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `all_results_in_paper_1.do`: ###
        # use stata_data_files/stacked_1
        # ...
        # save stata_data_files/temp1, replace
        # ...
        # use stata_data_files/temp1
        # ...
        # *=========================================
        # *Results for Table 2
        # *=========================================
        # * basic regressions
        # eststo: areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
        # single_parent high_school some_college college_deg poverty  medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
        # ...
        # *=========================================
        # *Results for Table 3
        # *=========================================
        # local quintiles "povertyg ..."
        # foreach i of local quintiles {
        # sort `i'
        # by `i': eststo: areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
        # single_parent high_school some_college college_deg poverty medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
        # ...
        # }

        sensitivities = {
            ### enroll_total: total enrollment
            "enroll_total": {
                "sensitivity": lambda district: 1,
                "lb": 1  # weighting var
            },

            ### per_black: percentage of students who are black 
            #> gen per_black=100*enroll_black/enroll_total
            "enroll_black": lambda district: 1,
            # enroll_total already noised

            ### per_asian: percentage of students who are asian
            #> gen per_asian=100*enroll_asian/enroll_total
            "enroll_asian": lambda district: 1,
            # enroll_total already noised

            ### per_hispanic: percentage who are hispanic
            #> gen per_hispanic=100*enroll_hispanic/enroll_total
            "enroll_hispanic": lambda district: 1,
            # enroll_total already noised

            ### per_other: percentage of other race
            #> gen per_other=100*(enroll_total-enroll_white-enroll_hispanic-enroll_black-enroll_asian)/enroll_total
            "enroll_white": lambda district: 1,
            # enroll_total, enroll_hispanic, enroll_black, enroll_asian already noised

            ### ca_rate: chronically absent %
            # gen ca_rate=100*ca/enroll_total
            # enroll_total already noised
            # ca: chronically absent students
            "ca": lambda district: 1,

            ### single_parent: percentage of children in the district boundary living in single parent household
            # NOTE: assumign denominator is enroll_total
            # single_parent = n_single_parent / enroll_total * 100
            # NOTE: created inter var n_single_parent = single_parent / 100 * enroll_total
            "n_single_parent": lambda district: 1,
            # enroll_total already noised

            ### pop shares: % adults *
            # * = n_* / pop * 100
            # NOTE: created inter vars n_* = pop * per_* / 100
            ## high_school: % adults aged 25+ with high school degree 
            "n_high_school": lambda district: 1,
            ## some_college: % adults aged 25+ with some college
            "n_some_college": lambda district: 1,
            ## college_deg: % adults aged 25+ with 4-year college degree
            "n_college_deg": lambda district: 1,
            ### poverty: percent in poverty
            "n_poverty": lambda district: 1,

            ### medhhincwkids_r: % median hh income for families w kids < 18
            #> gen cpi=292.655
            #> replace cpi=255.657 if year==1819
            #> gen medhhincwkids_r=medhhincwkids*292.655/cpi
            # NOTE: assuming household income clipped at 500k
            "medhhincwkids": lambda district: 500000 / 2,

            ### [not personal] share_hybrid: % days hybrid school
            #> replace share_hybrid=100*share_hybrid

            ### [not personal] share_virtual: % days virtual school
            #> replace share_virtual=100*share_virtual

            ### [not personal] year2122 
            #> gen year2122=year==2122
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="virtual-absent",
            table=table,
            row="share_virtual",
            col="est1",
            expected_range=(0.048, 0.089) # abstract gives 95% CI
        ))
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="virtual-lowq",
            table=table,
            row="share_virtual",
            col="est1",
            expected_range=(None, 0)
        ))
        virtual5q = Result.from_esttab(
            id="virtual-5q",
            table=table,
            row="share_virtual",
            col="est5",
            expected_range=(0.072, 0.141) # abstract gives 95% CI
        )
        results.append(Result.from_esttab(
            id="virtual-4q",
            table=table,
            row="share_virtual",
            col="est4",
            expected_range=(0, virtual5q.est)
        ))
        results.append(virtual5q)
        return results