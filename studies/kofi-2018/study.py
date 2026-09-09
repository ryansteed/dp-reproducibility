from typing import Dict
from simulate_privacy.studies import Study, Result
from simulate_privacy.config import logger

import pandas as pd
import numpy as np
import os


class Kofi(Study):
    id = 'kofi-2018'

    def data_paths(self) -> dict:
        return {
            "county_year_cleaned": os.path.join(
                self.path(), "source", "REStat_data_code", "cleaned_data", "county_year_cleaned.dta"
            )
            # ...
        }
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        cpi = pd.read_csv(f"{self.path()}/source/REStat_data_code/raw_data/nation_year_raw.csv")[
            ["year", "cpi"]
        ]
        df = noised_data["county_year_cleaned"]
        df = df.join(cpi.set_index('year'), on="year")
        # reconstruct log_real_ssdi
        df["log_real_ssdi"] = np.where(
            df["ssdisab"] == 0,
            np.nan,
            np.log(df["ssdisab"] / df["cpi"] * 100)
        )
        # reconstruct log_real_ssi
        # log_real_ssi = ifelse(ssi == 0, NA, log(ssi / cpi * 100)),
        df["log_real_ssi"] = np.where(
            df["ssi"] == 0,
            np.nan,
            np.log(df["ssi"] / df["cpi"] * 100)
        )
        # reconstruct log_real_earn
        # log_real_earn = ifelse(earn == 0, NA, log(earn / cpi * 100))
        df["log_real_earn"] = np.where(
            df["earn"] == 0,
            np.nan,
            np.log(df["earn"] / df["cpi"] * 100)
        )
        # reconstruct log_emp
        # log_emp = ifelse(emp == 0, NA, log(emp))
        df["log_emp"] = np.where(
            df["emp"] == 0,
            np.nan,
            np.log(df["emp"])
        )
        # reconstruct log_pop
        # log_pop = log(pop)
        df["log_pop"] = np.where(
            df["pop"] == 0,
            np.nan,
            np.log(df["pop"])
        )
        
        # manufact_earn_share_1969
        manufact_earn_share_1969_orig = df["manufact_earn_share_1969"].copy()
        df["manufact_earn_share"] = df["manearn"] / df["earn"]
        special_years = {
            21159: 1970,
            21119: 1971,
            21223: 1972,
            21237: 1982,
            21215: 1984
        }
        for y in [1969] + list(special_years.values()):
            df[f"manufact_earn_share_{y}"] = df[
                df["year"] == y
            ]["manufact_earn_share"]
            # apply to all years for each fips
            df[f"manufact_earn_share_{y}"] = df.groupby("fips")[f"manufact_earn_share_{y}"].transform('max')
        # special cases from `prepare_data.R`
        for fips, y in special_years.items():
            df.loc[df["fips"] == fips, "manufact_earn_share_1969"] = df[f"manufact_earn_share_{y}"]
        df["manufact_earn_share_1969"] = np.where(
            df["manufact_earn_share_1969"].isna(),
            manufact_earn_share_1969_orig,
            df["manufact_earn_share_1969"]
        )

        noised_data["county_year_cleaned"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "pop",
            "log_real_ssdi",
            "log_real_ssi",
            "log_real_earn",
            "log_emp",
            "log_pop",
            "manufact_earn_share_1969"
        ]
    
    def other_vars(self):
        return [
            "d_oilprice_by_emp1967",
            "msa1990"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "fips"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table1.do`: ###
        # use "cleaned_data/county_year_cleaned.dta", clear
        # xtset fips year
        # ...
        # global controls "msa1990 log_pop D.log_pop manufact_earn_share_1969"
        # ...
        # global og_oilprice_cont_67 "L(0/2).d_oilprice_by_emp1967";
        # ...
        # global regWeight "[aw=L.pop]"
        # ...
        # foreach depv in ssdi ssi {
        #     tab stateyr if og_state==1 & tin(1970, 2011) & ${`depv'_bal}, gen(stateyrv)

        #     foreach econ in real_earn emp {
        #         // 2SLS: columns 2 and 4
        #         eststo: ivreg2 D.log_real_`depv' (D.log_`econ' = $og_oilprice_cont_67) ///
        #             $controls stateyrv* $regWeight, cluster(fips) savefirst
        #             // add F stat for excluded instruments to the results
        #             tsunab ivs: $og_oilprice_cont_67
        #             local ivreg2result = e(firsteqs)
        #             foreach model of local ivreg2result {
        #                 estimates restore `model'
        #                 test `ivs'
        #                 estadd scalar F_stat = r(F)
        #             }
        #         *** Line below commented by Eduardo Schnadower ***
        #         *export_results
        #     }
        #     drop stateyrv*
        # }
        ###
        ### vars
        # log_real_ssdi: social security disability benefits payments
        # log_real_ssi: supplemental security income payments
        # log_real_earn
        # log_emp
        # log_pop: log population; defined in R script
        # manufact_earn_share_1969: fraction of earnings from manufacturing
        # pop
        # [not personal] og_oilprice_cont_67: L(0/2).d_oilprice_by_emp1967: int'l oil prices
        # [not personal] msa1990: MSA indicator
        # [not personal] stateyrv*
        ###
        vars_to_noise = {
            ### pop: population
            "pop": {
                "sensitivity": lambda cnty: 1,
                "lb": 0
            },

            ### log_real_ssdi: social security disability benefits payments (in thousands?)
            # [R, not run] log_real_ssdi = ifelse(ssdisab == 0, NA, log(ssdisab / cpi * 100)
            # cpi is invariant
            # NOTE: assuming ssdi payments per person capped at 10970 annually https://evansdisability.com/blog/social-security-disability-benefits-pay-chart/
            "ssdisab": lambda cnty: 10.970,
            
            ### log_real_ssi: supplemental security income payments (in thousands?)
            # [R, not run] log_real_ssi = ifelse(ssi == 0, NA, log(ssi / cpi * 100)),
            # NOTE: assuming max monthly ssi payment was 750 for an individual, times 12 months https://www.ssa.gov/oact/cola/SSIamts.html
            "ssi": lambda cnty: 9.000,

            ### log_real_earn - total county earnings in thousands of dollars?
            # [R, not run] log_real_earn = ifelse(earn == 0, NA, log(earn / cpi * 100))
            # NOTE: assuming units of thousands of dollars (usually what BEA uses); assuming earnings capped at 500,000
            "earn": {
                "sensitivity": lambda cnty: 500,
                "lb": 1
            },

            ### log_emp - count of employees?
            # [R, not run] log_emp = ifelse(emp == 0, NA, log(emp)),
            "emp": lambda cnty: 1,
            
            ### log_pop: log population; defined in R script
            # [R, not run] log_pop = log(pop)
            # covered by `pop`
            
            ### manufact_earn_share_1969: fraction of earnings from manufacturing
            # [R, not run] manufact_earn_share_1969 =
            #    ifelse(fips == 21159, manufact_earn_share_1970,
            #    ifelse(fips == 21119, manufact_earn_share_1971,
            #    ifelse(fips == 21223, manufact_earn_share_1972,
            #    ifelse(fips == 21237, manufact_earn_share_1982,
            #    ifelse(fips == 21215, manufact_earn_share_1984,
            #           manufact_earn_share_1969)))))
            # NOTE: assuming units of thousands of dollars (usually what BEA uses); assuming earnings capped at 500,000
            "manearn": {
                "sensitivity": lambda cnty: 500,
                "lb": 1
            },
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")

        earnings_SSDI = Result.from_esttab(
            id="earnings-SSDI",
            table=table,
            row="D.log_real_earn",
            col="est2",
            expected_range=(None, 0)
        )
        results.append(earnings_SSDI)
        results.append(Result.from_esttab(
            id="employment-SSDI",
            table=table,
            row="D.log_emp",
            col="est4",
            expected_range=(None, earnings_SSDI.est)
        ))

        earnings_SSI = Result.from_esttab(
            id="earnings-SSI",
            table=table,
            row="D.log_real_earn",
            col="est6",
            expected_range=(None, 0)
        )
        results.append(earnings_SSI)
        results.append(Result.from_esttab(
            id="employment-SSI",
            table=table,
            row="D.log_emp",
            col="est8",
            expected_range=(None, earnings_SSI.est)
        ))

        return results