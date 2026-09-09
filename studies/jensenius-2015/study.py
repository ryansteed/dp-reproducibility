from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Jensenius(Study):
    id = 'jensenius-2015'

    def data_paths(self) -> dict:
        return {
            "devDTA": os.path.join(
                self.path(), "source", "AEJApp-2014-0201_Dataset","devDTA.Rdata"
            )
        }

    # def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict[str, pd.DataFrame]:
    #     df = data["devDTA"]
    #     # df["count_lit"] = df["Plit_SC_7"] * df["SC_pop71_true"] 
    #     # df["count_emp"] = df["P_W_SC"] * df["SC_pop71_true"]
    #     # df["count_agr"] = df["P_al_SC"] * df["SC_pop71_true"]
    #     return data
    
    def _post_processing(self, noised_data):
        df = noised_data["devDTA"]

        # df["Plit_SC_7"] = df["count_lit"] / df["SC_pop71_true"] 
        # df["P_W_SC"] = df["count_emp"] / df["SC_pop71_true"]
        # df["P_al_SC"] = df["count_agr"] / df["SC_pop71_true"]

        df["SC_percent71_true"] = df["SC_pop71_true"] / df["tot_pop71_true"] * 100

        return noised_data
    
    def vars_to_noise(self) -> dict:
        return {
            "post_replication": [
                "PropSC",
                # "Plit_SC_7",
                # "educ_lag",
                # "P_W_SC",
                # "worker_lag",
                # "P_al_SC",
                # "agr_lag"
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Code_replication.R`: ###
        # load("devDTA.Rdata")
        # ...
        # matchdta <- devDTA[complete.cases(devDTA$SC_percent71_true, devDTA$State_no_2001_old, devDTA$AC_type_noST, devDTA$Plit71_SC, devDTA$Plit_SC), ]
        # ...
        # treatedDTA <- matchdta[Matched_norep$index.treated, ]
        # controlDTA <- matchdta[Matched_norep$index.control, ]
        # ...
        # matched2 <- rbind(treatedDTA, controlDTA)
        # ...
        # PropSC <- matched2$SC_percent71_true
        # educ_lag <- matched2$Plit71_SC
        # worker_lag <- matched2$P_W71_SC
        # agr_lag <- matched2$P_al71_SC
        # stateFE <- as.factor(matched2$State_no_2001_old)
        # ...
        #--- lit-sc
        # model3lm <- lm(matched2$Plit_SC_7 ~ educ_lag + matched2$AC_type_noST * PropSC + stateFE)
        # ...
        #--- emp-sc
        # model6lm <- lm(matched2$P_W_SC ~ worker_lag + matched2$AC_type_noST * PropSC + stateFE)
        # ...
        #--- agr-sc
        # model9lm <- lm(matched2$P_al_SC ~ agr_lag + matched2$AC_type_noST * PropSC + stateFE)
        ###
        sensitivities = {
            ### PropSC: percentage of SCs in the constituencies in 1971
            #> PropSC <- matched2$SC_percent71_true
            # SC_percent71_true: percent of SC in '71, in 100s
            # NOTE reconstructing SC_percent71_true = SC_pop71_true / tot_pop71_true
            "tot_pop71_true": {
                "sensitivity": lambda constituency: 1,
                "lb": 1
            },
            "SC_pop71_true": {
                "sensitivity": lambda constituency: 1,
                "lb": 0
            },

            #--- lit-sc
            ### Plit_SC_7: Literacy rate among SCs in 2001, in 100s
            # Literacy rate among SCs in AC estimated from block-level
            # 2001 census data and calculated as the number of literate 
            # divided by entire SC population (official calculation is by
            # population over the age of 7 as given by variable Plit_SC_7).
            # NOTE: 2001 pops not given, can't noise

            ### educ_lag: Plit71_SC, lagged
            # educ_lag <- matched2$Plit71_SC
            # NOTE: 2001 pops not given, can't noise

            #--- emp-sc
            ### P_W_SC: Employment rate among SCs in AC estimated from block-level 2001 census data
            # NOTE: # workers not given, can't noise

            ### worker_lag: P_W71_SC, lagged
            #> worker_lag <- matched2$P_W71_SC
            # NOTE: # workers not given, can't noise

            #--- agr-sc
            ### P_al_SC: Percentage of agricultural laborers among SCs in AC estimated from block-level 2001 census data
            # NOTE: # laborers not given, can't noise

            ### agr_lag: P_al71_SC, lagged
            #> agr_lag <- matched2$P_al71_SC
            # NOTE: # laborers not given, can't noise


            ### [not personal] AC_type_noST: reservation Status of constituencies
        }
        return sensitivities

    def extract_results(self) -> pd.DataFrame:
        results = []
        for id, (tablename, rowname, expected_range) in {
            "lit-sc": ("model3lm_summary", "PropSC", (0, 0)),
            "emp-sc": ("model6lm", "PropSC", (0, 0)),
            "agr-sc": ("model9lm", "PropSC", (0, 0))
        }.items():
            table = pd.read_csv(f"{self.path()}/results/{tablename}.csv", index_col=0)
            row=table.loc[rowname]
            results.append(Result(
                id=id,
                est=float(row["Estimate"]),
                se=float(row["Std. Error"]),
                t=float(row["t value"]),
                p=float(row["Pr(>|t|)"]),
                expected_range=expected_range
            ))
        
        return results