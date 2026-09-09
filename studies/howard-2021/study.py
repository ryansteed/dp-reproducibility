from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import os


class Howard(Study):
    id = 'howard-2021' 

    def data_paths(self) -> dict:
        return {
            "combineddata": os.path.join(
                self.path(), "source/data", "combineddata.dta"
            ),
            "2000_msa_industry_shares": os.path.join(
                self.path(), "source/data/qcew", "2000_msa_industry_shares.dta"
            )
            # ...
        }
    
    def _post_processing(self, noised_data):
        df = noised_data["2000_msa_industry_shares"]

        df["industryshare"] = df["emp"] / df["totalemp"]

        noised_data["2000_msa_industry_shares"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return {
            "post_replication": [
                "manufshare",
                # "bartik_wage"
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `bootstrap_mu_alternatemeasures.do`: ###
        # use "../data/qcew/2000_msa_industry_shares", clear
        # ...
        # save `manuf'
        # ...
        # use "../data/combineddata"
        # ...
        # merge 1:1 msa using `manuf', nogen
        # ...
        #--- manu-raw
        # eststo manuraw: reg s18lognoi_adj c.manufshare##c.elasticity , r absorb(elasticitybin)
        #--- manu-rent
        # eststo manurent: reg rent_new c.manufshare##c.elasticity  , r absorb(elasticitybin)
        ###
        ### relevant regression code from `bootstrap_mu_bartik.do`: ###
        # use "../data/combineddata"
        # ...
        # merge 1:1 msa using `manuf', nogen
        # merge 1:1 msa using `pca', nogen
        # ...
        #--- shock-raw
        # eststo shockraw: reg s18lognoi_adj c.bartik_wage##c.elasticity , r absorb(elasticitybin)
        #--- shock-rent
        # eststo shockrent: reg rent_new c.bartik_wage##c.elasticity , r absorb(elasticitybin)
        ### 
        sensitivities = {
            #--- manu-raw, manu-rent
            ### manufshare: share manufacturing employment
            #> from bootstrap_mu_alternatemeasures.do (run):
            # use "../data/qcew/2000_msa_industry_shares", clear
            # keep if industry_code=="31-33" | industry_code=="1023"
            # keep industryshare msa industry_code
            # replace industry_code = "finance" if industry_code=="1023"
            # replace industry_code ="manufshare" if industry_code == "31-33"
            # reshape wide industryshare, i(msa) j(industry_code) string
            # rename industryshare* *
            # merge 1:1 msa using `bartik', nogen
            # tempfile manuf
            # save `manuf'
            #>
            # NOTE: reconstructed industryshare = emp / totalemp
            "emp": lambda msa: 1,
            "totalemp": lambda msa: 1,

            #--- shock-raw, shock-rent
            ### bartik_wage: Predicted Wage Change Based on Industry Composition
            # NOTE: not enough info for DP

            ### [not personal] elasticity: Housing Supply Elasticity
            ### [not personal] elasticitybin
            # xtile elasticitybin=elasticity, n(10)
            ### [not personal] rent_new: Change in Log Rent, using Empirical Bayes to Shrink to House Price Change
            ### [not personal] s18lognoi_adj
            # gen s18lognoi_adj = s18.lognoi_adj
            # [not personal] lognoi_adj: Log rent based on operating incomes of commercial properties
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")

        results.append(Result.from_esttab(
            id="manu-rent",
            table=table,
            row="manufshare",
            col="manurent",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="manu-raw",
            table=table,
            row="manufshare",
            col="manuraw",
            expected_range=(None, 0)
        ))
        table = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="shock-rent",
            table=table,
            row="bartik_wage",
            col="shockrent",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="shock-raw",
            table=table,
            row="bartik_wage",
            col="shockraw",
            expected_range=(0, None)
        ))
        return results