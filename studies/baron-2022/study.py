from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Baron(Study):
    id = 'baron-2022'

    def data_paths(self) -> dict:
        return {
            "onestep_panel_tables": os.path.join(
                self.path(), "source/Replication/Data/Final", "onestep_panel_tables.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "student_count",
            "dropout_rate",
            "wkce_math10",
            "num_takers_math10",
            "log_instate_enr",
            "grade9lagged",
            *[f"op_percent_prev{i}" for i in range(1, 19)],
            *[f"op_percent2_prev{i}" for i in range(1, 19)],
            *[f"bond_percent_prev{i}" for i in range(1, 19)],
            *[f"bond_percent2_prev{i}" for i in range(1, 19)],
            *[f"op_win_prev{i}" for i in range(1, 19)],
            *[f"bond_win_prev{i}" for i in range(1, 19)]
        ]
    
    _ref_vars = ["op", "bond"]
    
    def _pre_processing(self, data):
        df = data["onestep_panel_tables"]
        df["dropout_student"] = df["student_count"] * df["dropout_rate"] / 100
        df["instate_enr"] = np.exp(df["log_instate_enr"])
        df["math_total"] = df["wkce_math10"] * df["num_takers_math10"]

        for i in range(1, 19):
            for v in self._ref_vars:
                df[f"{v}_allvotes_prev{i}"] = df[f"{v}_totalvotes_prev{i}"] / df[f"{v}_percent_prev{i}"] * 100
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["onestep_panel_tables"]
        df["dropout_rate"] = df["dropout_student"] / df["student_count"] * 100
        df["log_instate_enr"] = np.log(df["instate_enr"])
        df["wkce_math10"] = df["math_total"] / df["num_takers_math10"]
        
        # df["op_totalvotes_prev1"] = df["tmp_op_totalvotes_prev0"].shift(1)
        for i in range(1, 19):
            for v in self._ref_vars:
                df[f"{v}_percent_prev{i}"] = np.where(
                    (df[f"{v}_percent_prev{i}"] == 0), 0,
                    df[f"{v}_totalvotes_prev{i}"] / df[f"{v}_allvotes_prev{i}"] * 100,
                )
                assert (df[f"{v}_percent_prev{i}"].notna()).all(), f"NAs for {v} in prev{i}"
                df[f"{v}_percent2_prev{i}"] = df[f"{v}_percent_prev{i}"].astype('float64') ** 2
                df[f"{v}_win_prev{i}"] = df[f"{v}_percent_prev{i}"] >= 50
                # if v == "bond":
                #     print(df[[f"{v}_percent_prev{i}"]].head())
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `onestep_tables.do`: ###
        # use "${path}Data/Final/onestep_panel_tables"
        # ...
        # global quadratic op_win_prev* bond_win_prev* yrdums* ///
        # op_ismeas_prev* bond_ismeas_prev* op_month_prev* bond_month_prev* ///
        # op_percent_prev* op_percent2_prev*  ///
        # bond_percent_prev* bond_percent2_prev*  ///
        # recurring_prev* op_numelec_prev* bond_numelec_prev*
        # ...
        #--- spend-dropout
        # eststo: areg dropout_rate $quadratic [aw=student_count], absorb(district_code) cluster(district_code)
        # ...
        #--- spend-score
        # areg wkce_math10 $quadratic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
        # ...
        #--- spend-postenroll
        # areg log_instate_enr $quadratic grade9lagged, absorb(district_code) cluster(district_code)
        
        ###
        sensitivities = {
            ### student_count: Prior to 2005: Enrollment, After: Expected to Complete Term
            "student_count": {
                "sensitivity": lambda district: 1,
                "lb": 1 # weight variable, and will be used as the denominator in post processing
            },

            ### dropout_rate: 7-12 Combined Dropout Rate (pp)
            # The dropout rate for school district d in year t is calculated as the total number of students in grades 7–12 in district d who dropped out during year t divided by the total number of students in
            # grades 7–12 who were expected to complete the school term in school district d in year t
            # NOTE created inter var dropout_student = student_count * dropout_rate / 100
            # student_count already noised
            "dropout_student": lambda district: 1,

            ### num_takers_math10:  Number of Students Who Took the Math WKCE in Grade 10
            "num_takers_math10": {
                "sensitivity": lambda district: 1,
                "lb": 1
            },

            ### wkce_math10: Average Math WKCE Scale Score in Grade 10
            # NOTE created inter var math_total = wkce_math10 * num_takers_math10
            # scale scores: https://dpi.wi.gov/sites/default/files/imce/assessment/pdf/percentm.pdf
            # 10th grade test ranges from around 400 to around 700, so student can change by at most 300
            # num_takers_math10 already noised
            "math_total": lambda district: 300,

            ### log_instate_enr:  Log of First-Fall Enrollment in a State Inst.
            # NOTE created inter var instate_enr = exp(log_instate_enr)
            "instate_enr": {
                "sensitivity": lambda district: 1,
                "lb": 1
            },

            ### grade9lagged: Grade 9 Enrollment in t-3
            "grade9lagged": lambda district: 1,

            ### op_percent_prev*: percent vote share for operational referendum
            # assuming op_percent_prev* = op_totalvotes_prev* / op_allvotes_prev* * 100
            # NOTE created inter vars op_allvotes_prev* = op_totalvotes_prev* / op_percent_prev* * 100
            **{
                f"op_allvotes_prev{i}": {
                "sensitivity": lambda district: 1,
                "lb": 1
                } for i in range(1, 19)
            },
            **{
                f"op_totalvotes_prev{i}": {
                    "sensitivity": lambda district: 1,
                    "lb": 0
                } for i in range(1, 19)
            },

            ### op_percent2_prev*: op_percent_prev* ^ 2
            # NOTE reconstructing op_percent2_prev* = op_percent_prev* ^ 2
            # op_percent_prev* already noised

            ### bond_percent_prev*: percent vote share for bond referendum
            # same as above
            # NOTE created inter vars bond_allvotes_prev* = bond_totalvotes_prev* / bond_percent_prev* * 100
            **{
                f"bond_allvotes_prev{i}": {
                "sensitivity": lambda district: 1,
                "lb": 1
                } for i in range(1, 19)
            },
            **{
                f"bond_totalvotes_prev{i}": {
                    "sensitivity": lambda district: 1,
                    "lb": 0
                } for i in range(1, 19)
            }
            
            ### bond_percent2_prev*: bond_percent_prev* ^ 2
            # NOTE reconstructing bond_percent2_prev* = bond_percent_prev* ^ 2
            # bond_percent_prev* already noised

            ### op_win_prev*: whether op referendum passed
            # NOTE reconstructing op_win_prev* = op_percent_prev* >= 50
            # op_percent_prev* already noised
            
            ### bond_win_prev*: wether bond referendum passed
            # NOTE reconstructing bond_win_prev* = bond_percent_prev* >= 50
            # bond_percent_prev* already noised

            ### [not personal] op_numelec_prev*: ??
            ### [not personal] bond_numelec_prev*: ??
            ### [not personal] op_ismeas_prev*: variable about elections 
            ### [not personal] bond_ismeas_prev*: variable about elections 
            ### [not personal] yrdums*: year dummies
            ### [not personal] op_month_prev*: month in which the election was held
            ### [not personal] bond_month_prev*: month in which the election was held
            ### [not personal] recurring_prev*: type of operational measure (recurring or nonrecurring) 
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        result1 = Result.from_esttab(
            id="ignore-this",
            table=table,
            row="op_win_prev1",
            col="est1",
            expected_range=(0, 0),
            est_stats={"est": "b", "se": "se"}
        )
        N = result1.stats["N"]
        df_m = result1.stats["df_m"]
        df_r = result1.stats["df_r"]
        table = pd.read_csv(f"{self.path()}/results/lincom_result.csv", index_col="var")
        for id, (rowname, expected_range) in {
            "spend-dropout": ("dropout", (None, 0)),
            "spend-score": ("avg_math", (0, None)),
            "spend-postenroll": ("log_enrollment", (0, None))
        }.items():
            row=table.loc[rowname]
            lincom_result = Result(
                id=id,
                est=float(row["est"]),
                se=float(row["se"]),
                t=float(row["t"]),
                p=float(row["p"]),
                N=N,
                df_m=df_m,
                df_r=df_r,
                expected_range=expected_range
            )
            results.append(lincom_result)
        return results