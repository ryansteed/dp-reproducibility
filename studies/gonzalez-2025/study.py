from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Gonzalez(Study):
    id = 'gonzalez-2025'

    def data_paths(self) -> dict:
        return {
            "final_penalties_dataset": os.path.join(
                self.path(), "source/Replication_Files/datasets", "final_penalties_dataset.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "drug_AM",
        ]

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table1.do`: ###
        # use "../datasets/final_penalties_dataset.dta", clear
        # ...
        # foreach var in drug_AM {
        #     ...
        #     * Fines interacted with monitoring intensity
        #     * Police district by Year trends
        #     eststo: reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length], ///
        #         absorb(block_id year police_district#year) ///
        #         cluster(neighborhood) 
        # ...
        # }

        ###
        sensitivities = {
            ### drug_AM: Outcome variable is the total number of drug-related crimes at the block-year level occurring during school days and school hours. 
            "drug_AM": {
                "sensitivity": lambda blockyear: 1,
                "lb": 0,
            }

            ### [not personal] drug_free: Drug-free is an indicator for whether a block is within a drug-free school zone area
            ### [not personal]temp: gen temp=1 //use variable to get name right when exporting to table
            ### [not personal]dist_drug: control for distance to the drug-free school zone boundary
            ### [not personal]block_length: Block length (ft)
            ### [not personal]med_p: indicator for SPP adjacent block
            #> gen med_p = t_adj 
            ### [not personal]high_p: SPP is an indicator for whether a block is a Safe Passage block (high probability of detection).
            #> gen high_p = spp
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="punish-drugcrime",
            table=table,
            row="1.drug_free#1.med_p",
            col="est1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="punishspp-drugcrime",
            table=table,
            row="1.drug_free#1.high_p",
            col="est1",
            expected_range=(0, 0)
        ))
        return results