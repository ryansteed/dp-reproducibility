from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Antecol(Study):
    id = 'antecol-2018'

    def data_paths(self) -> dict:
        return {
            "aer_primarysample": os.path.join(
                self.path(), "source/data", "aer_primarysample.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "faculty",
            "female_ratio",
            "full_ratio",
            "ug_students",
            "grad_students",
            "full_av_salary",
            "assist_av_salary"
        ]
    
    def _pre_processing(self, data):
        df = data["aer_primarysample"]
        n_faculty = df["faculty"] * 100
        df["n_female"] = df["female_ratio"] * n_faculty
        df["n_full"] = df["full_ratio"] * n_faculty
        df["full_total_salary"] = df["full_av_salary"] * df["n_full"]
        df["assist_total_salary"] = df["assist_av_salary"] * (n_faculty - df["n_full"])
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["aer_primarysample"]
        n_faculty = df["faculty"] * 100
        df["female_ratio"] = df["n_female"] / n_faculty
        df["full_ratio"] = df["n_full"] / n_faculty
        df["full_av_salary"] = np.where(
            df["n_full"] == 0,
            df["full_av_salary"],
            df["full_total_salary"] / df["n_full"]
        )
        df["assist_av_salary"] = df["assist_total_salary"] / (n_faculty - df["n_full"])
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `data/aer_regressions.do`: ###
        # use aer_primarysample
        # local ulist phd_rank phd_rank_miss post_doc ug_students grad_students faculty full_av_salary assist_av_salary revenue female_ratio full_ratio faculty_miss revenue_miss female_ratio_miss full_ratio_miss
        # local plist focs f_focs gncs f_gncs focs0 f_focs0 gncs0 f_gncs0
        # ...
        # xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
        # ...
        # do called_dofiles/table2_tests

        ### relevant regression code from `data/called_dofiles/table2_tests.do`: ###
        #--- clock-mentenure
        # eststo: lincom gncs
        # ...
        #--- clock-womentenure, clock-gendergap
        # *gncs - women - main results
        # lincom gncs+f_gncs

        sensitivities = {
            ### faculty: faculty size, in hundreds
            "faculty": {
                "sensitivity": lambda university: 1/100,
                "lb": 0.02
            },

            ### female_ratio: the fraction of the faculty who are female
            # female_ratio = n_female / (faculty * 100)
            # NOTE reconstructed n_female = female_ratio * faculty * 100
            "n_female": lambda university: 1,
            
            ### full_ratio: the fraction of the faculty who are full professors
            # full_ratio = n_full / (faculty * 100)
            # NOTE reconstructed n_full = full_ratio * faculty * 100
            "n_full": {
                "sensitivity": lambda university: 1,
                "lb": 1
            },
            
            ### ug_students: number of undergraduate students, in thousands
            "ug_students": lambda university: 1/1000,
            
            ### grad_students: number of graduate students, in thousands
            "grad_students": lambda university: 1/1000,
            
            ### full_av_salary: average salary of full professors, in thousands
            # full_av_salary = full_total_salary / n_full
            # NOTE reconstructing full_total_salary = full_av_salary * n_full
            # NOTE assuming salary capped at 500k
            "full_total_salary": lambda university: 500,
            
            ### assist_av_salary: average salary of assistant professors, in thousands
            # NOTE assuming professors either full or assistant
            # assist_av_salary = assist_total_salary / (faculty * 100 - n_full)
            # NOTE: reconstructing assist_total_salary = assist_av_salary * (faculty * 100 - n_full)
            "assist_total_salary": lambda university: 500,

            
            ### [not aggregate] tenure_policy_school: tenure at the policy university
            ### [not personal] phd_rank: PhD program rank
            ### [not personal] phd_rank_miss: indicator for missing phd_rank?
            ### [not aggregate] post_doc: n indicator for having donea postdoc
            ### [not personal] revenue: annual revenue
            ### [not personal] faculty_miss: indicator for missing faculty?
            ### [not personal] revenue_miss: indicator for missing revenue?
            ### [not personal] female_ratio_miss: indicator for missing female_ratio?
            ### [not personal] full_ratio_miss: indicator for missing full_ratio?
            ### [not aggregate] female
            ### [not personal] focs: FOCS indicates a female-only policy
            ### [not aggregate] f_focs: interaction term for female and focs (but did not find code to generate this variable)
            ### [not personal] gncs:  GNCS indicates a gender-neutral tenure clock stopping policy
            ### [not aggregate] f_gncs: interaction term for female and gncs
            ### [not personal] focs0 
            ### [not aggregate] f_focs0 
            ### [not personal] gncs0 
            ### [not aggregate] f_gncs0
            ### [not personal] pol_job_start: the year the policy job started
            ### [not personal] pol_u: policy university
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        man_result = Result.from_esttab(
            id="clock-mentenure",
            table=table,
            row="gncs",
            col="est1",
            expected_range=(0, None),
            est_stats={"est": "b", "se": "se"}
        )
        results.append(man_result)
        N = man_result.stats["N"]
        df_m = man_result.stats["df_m"]
        df_r = man_result.stats["df_r"]
        table = pd.read_csv(f"{self.path()}/results/lincom_result.csv", index_col="var")
        row=table.loc["female"]
        lincom_female = Result(
            id="clock-womentenure",
            est=float(row["est"]),
            se=float(row["se"]),
            t=float(row["t"]),
            p=float(row["p"]),
            N=N,
            df_m=df_m,
            df_r=df_r,
            expected_range=(None, 0)
        )
        results.append(lincom_female)
        row=table.loc["difference"]
        lincom_diff = Result(
            id="clock-gendergap",
            est=float(row["est"]),
            se=float(row["se"]),
            t=float(row["t"]),
            p=float(row["p"]),
            N=N,
            df_m=df_m,
            df_r=df_r,
            expected_range=(0, None)
        )
        results.append(lincom_diff)
        # first load N, df_m, df_r
        # can just grab any estimate from the table using load_esttab, and then copy those values 
        # by accessing the attributes N, df_m, df_r

        # then load the lincom output (however you decide to output it from stata)
        # to get b, se, p, t
        
        # and create a Result object manually using all those statistics
        # lincom_result = Result(
        #    id="indvar-depvar-lincom",
        #    b=b,
        #    se=se,
        #    ...
        # )
        return results