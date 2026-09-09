from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os
import re


class Ahmed(Study):
    id = 'ahmed-2024'

    def data_paths(self) -> dict:
        return {
            "enroll_main": os.path.join(
                self.path(), "source/replication-files-rml/data", "clean_data/enroll_main.csv"
            ),
            "lagalization_dummies": os.path.join(
                self.path(), "source/replication-files-rml/data", "clean_data/lagalization_dummies.csv"
            ),
            "completion": os.path.join(
                self.path(), "source/replication-files-rml/data", "clean_data/completion.csv"
            ),
            "grad_rates": os.path.join(
                self.path(), "source/replication-files-rml/data", "clean_data/grad_rates.csv"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            # "ln_STUFACR",
            # "ln_per_capita_income",
            # "ln_unemply_rate",
            # "is_large_inst",
            "ln_AGE1824_TOT",
            "ln_AGE1824_FEM_SHARE",
            "ln_NETMIG",
            "ln_CTOTALT_lead4",
            "ln_CTOTALT_lead5",
            # "grad_rate_bachelor_6_years_lead3",
            # "grad_rate_associate_4_years_lead6",
        ]
    
    def _pre_processing(self, data):
        for name, df in data.items():
            if "ln_AGE1824_FEM_SHARE" in df.columns:
                if "AGE1824_FEM_SHARE" not in df.columns:
                    df["AGE1824_FEM_SHARE"] = np.exp(df["ln_AGE1824_FEM_SHARE"])
                df["AGE1824_FEM"] = df["AGE1824_FEM_SHARE"] * df["AGE1824_TOT"]
        return data
    
    def _post_processing(self, noised_data):
        for name, df in noised_data.items():
            if "ln_CTOTALT" in df.columns:
                df["ln_CTOTALT"] = np.log(1 + df["CTOTALT"].astype('float64'))
                for i in range(1, 7):
                    df[f"ln_CTOTALT_lead{i}"] = df.sort_values("YEAR").groupby(["AWLEVEL", "FIPS", "UNITID"])["ln_CTOTALT"].shift(-i)
            if "ln_AGE1824_TOT" in df.columns:
                df["ln_AGE1824_TOT"] = np.log(df["AGE1824_TOT"])
            if "ln_AGE1824_FEM_SHARE" in df.columns:
                df["AGE1824_FEM_SHARE"] = df["AGE1824_FEM"] / df["AGE1824_TOT"]
                df["ln_AGE1824_FEM_SHARE"] = np.log(df["AGE1824_FEM_SHARE"])
            if "ln_NETMIG" in df.columns:
                df["ln_NETMIG"] = np.log(df["NETMIG"])
            # if "grad_rate_bachelor_6_years" in df.columns:
            #     for i in range(1, 7):
            #         df[f"grad_rate_bachelor_6_years_lead{i}"] = df.sort_values("YEAR").groupby(["UNITID"])["grad_rate_bachelor_6_years"].shift(-i)
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `data-source.R`: ###
        # leg_path <- "../../data/clean_data/lagalization_dummies.csv"
        # com_path <- "../../data/clean_data/completion.csv
        # grad_rate_path <- "../../data/clean_data/grad_rates.csv"

        ### relevant regression code from `table_2_A4_panel_a.R`: ###
        # df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
        # ...
        # df <- read_csv(com_path) %>%
        # filter(STABBR %in% c(medical_control, tr_st)) %>%
        # filter(!STABBR %in% c("CA", "MA", "NV", "OR"))
        # ...
        # rhs_law = c(
        # "adopt_law",
        # "adopt_MM_law",
        # "is_medical",
        # "is_large_inst",
        # "ln_STUFACR",
        # "ROTC",
        # "DIST",
        # "ln_AGE1824_TOT",
        # "ln_AGE1824_FEM_SHARE",
        # "ln_per_capita_income",
        # "ln_unemply_rate",
        # "ln_NETMIG"
        # )
        # ...
        #--- rml-compcol
        # file_name <- paste0("tab_2_med_completion_", "Associate's degree")
        # did_reg(df %>% filter(AWLEVEL %in% "Associate's degree"), rhs_law, file_name, TRUE) %>% print()
        # ...
        # model5 <- feols(.["ln_CTOTALT_lead5"] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
        # ...
        #--- rml-compasso
        # file_name <- paste0("tab_2_med_completion_", "Bachelor's degree")
        # did_reg(df %>% filter(AWLEVEL %in% "Bachelor's degree"), rhs_law, file_name, TRUE) %>% print()
        # ...
        # model4 <- feols(.["ln_CTOTALT_lead4"] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
        # ...
        
        ### relevant regression code from `table_2_A4_panel_b_c.R`: ###
        # df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
        # ...
        # df <- read_csv(main_data_path) %>%
        # filter(STABBR %in% c(medical_control, tr_st)) %>%
        # left_join(read_csv(grad_rate_path)) %>%
        # filter(!STABBR %in% c("CA", "MA", "NV", "OR"))
        # rhs_law <- c(
        # "adopt_store",
        # "adopt_MM_store",
        # "is_medical",
        # "is_large_inst",
        # "ln_STUFACR",
        # "ROTC",
        # "DIST",
        # "ln_AGE1824_TOT",
        # "ln_AGE1824_FEM_SHARE",
        # "ln_per_capita_income",
        # "ln_unemply_rate",
        # "ln_NETMIG"
        # )
        # ...
        #--- rml-gradcol
        # outcome_leads <- paste0("grad_rate_bachelor_6_years_lead", 1:6)
        # file_name <- paste0("tab_2_med_grad_rate_", "Graduation rate (Bachelor-150%)")
        # did_reg(df, rhs_law, file_name, outcome_leads, TRUE) %>% print()
        # ...
        # model3 <- feols(.[outcome_leads[3]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
        # ...
        #--- rml-gradasso
        # outcome_leads <- paste0("grad_rate_associate_4_years_lead", 1:6)
        # file_name <- paste0("tab_2_med_grad_rate_", "Graduation rate (Associate-100%)")
        # did_reg(df, rhs_law, file_name, outcome_leads, TRUE) %>% print()
        # ...
        # model6 <- feols(.[outcome_leads[6]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)

        sensitivities = {
            ### "ln_STUFACR": Log student to faculty ratio
            # ln_STUFACR = log(STUFACR)
            # NOTE: students or faculty not given, not noised

            ### "ln_per_capita_income": Log per capita income
            # NOTE: total population not given, not noised

            ### "ln_unemply_rate": log of unemployment rate,
            # NOTE: total labor force not given, not noised

            ### "is_large_inst": Aggregate enrollment over 20k dummy,
            # NOTE: total enrollment not given, not noised

            ### "ln_AGE1824_TOT": Log age 18 to 24 population,
            # NOTE reconstructing ln_AGE1824_TOT = log(AGE1824_TOT)
            "AGE1824_TOT": lambda state: 1,

            ### "ln_AGE1824_FEM_SHARE": female share of the 18–24-year-old population,
            # NOTE: created inter var AGE1824_FEM = AGE1824_FEM_SHARE * AGE1824_TOT
            # NOTE: reconstructing ln_AGE1824_FEM_SHARE = log(AGE1824_FEM / AGE1824_TOT)
            "AGE1824_FEM": lambda state: 1,
            # AGE1824_TOT already noised
            
            ### "ln_NETMIG": Log Net migration
            # NOTE: reconstructing ln_NETMIG = log(NETMIG)
            "NETMIG": lambda state: 1,

            #--- rml-compasso
            ### ln_CTOTALT_lead4
            # NOTE: reconstructing ln_CTOTALT = log(CTOTALT + 1), then shifting
            "CTOTALT": lambda state: 1,

            #--- rml-compcol
            ### ln_CTOTALT_lead5
            # NOTE: reconstructing ln_CTOTALT = log(CTOTALT + 1), then shifting
            # CTOTALT already noised

            #--- rml-gradcol
            ### grad_rate_bachelor_6_years_lead3: Bachelor degrees graduation rate 
            # NOTE: number of grads not given, can't noise

            #--- rml-gradasso
            ### grad_rate_associate_4_years_lead6: Associate degrees graduation rate
            # NOTE: number of grads not given, can't noise
            
            # [not personal] AWLEVEL: categorical for degree level of aggregation
            # [not personal]"adopt_store": did not find exact meaning, might be an indicator of recreational marijuana stores were open in the state in that year
            # [not personal]"adopt_MM_store": did not find exact meaning, might be an indicator of medical marijuana stores were open in the state in that year.
            # [not personal]"adopt_law": an indicator for the adoption of Recreational marijuan (RM) laws,
            # [not personal]"adopt_MM_law": an indicator for the adoption medical marijuana (MM) law,
            # [not personal]"is_medical": Offering medical degree dummy,
            # [not personal]"ROTC": Offering ROTC program dummy,
            # [not personal]"DIST": Offering distance programs dummy,
               
        }
        return sensitivities

    def extract_results(self) -> list:
        results = []
        for name, (table, col) in {
            "rml-compcol": ("tab_2_med_completion_Bachelor's degree.csv", "Lead 5"),
            "rml-compasso": ("tab_2_med_completion_Associate's degree.csv", "Lead 4"),
            "rml-gradcol": ("tab_2_med_grad_rate_Graduation rate (Bachelor-150%).csv", "Lead 3"),
            "rml-gradasso": ("tab_2_med_grad_rate_Graduation rate (Associate-100%).csv", "Lead 6"),
        }.items():
            table = pd.read_csv(f"{self.path()}/results/{table}")
            strip_non_numeric = lambda x: re.sub(r"[^\d\.]", "", str(x))
            results.append(Result(
                id=name,
                est=float(strip_non_numeric(table.loc[table["statistic"] == "estimate", col].iloc[0])),
                se=float(strip_non_numeric(table.loc[table["statistic"] == "std.error", col].iloc[0])),
                t=float(strip_non_numeric(table.loc[table["statistic"] == "statistic", col].iloc[0])),
                p=float(strip_non_numeric(table.loc[table["statistic"] == "p.value", col].iloc[0])),
                N=int(strip_non_numeric(table.loc[table["term"] == "N Obs.", col].iloc[0])),
                # df_m=float(row["df_m"]),
                # df_r=float(row["df_r"]),
                expected_range=(0, None)
            ))

        return results