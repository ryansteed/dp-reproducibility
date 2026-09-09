from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Slattery(Study):
    id = 'slattery-2020'

    def data_paths(self) -> dict:
        return {
            # "dtaFile1": os.path.join(
            #     self.path(), "source/data/processed", "firm_level_subsidy_runnerup.dta"
            # ),
            # "dtaFile2": os.path.join(
            #     self.path(), "source/data/processed/exhibit_collapses", "firm_subs_statelevel.dta"
            # ),
            # "dtaFile3": os.path.join(
            #     self.path(), "source/data/raw", "taxrates_stateyear_1950_2017.dta"
            # ),
            "deal_specific_tva_analysis": os.path.join(
                self.path(), "source/data/processed", "deal_specific_tva_analysis.dta"
            ),
            # "dtaFile5": os.path.join(
            #     self.path(), "source/data/processed/exhibit_collapses", "topind_full.dta"
            # ),
            "state_year_chars": os.path.join(
                self.path(), "source/data/raw", "state_year_chars.dta"
            ),
            # "dtaFile7": os.path.join(
            #     self.path(), "source/data/processed", "deal_specific_tva_analysis.dta"
            # )
            "qcew_3d_long": os.path.join(
                self.path(), "source/data/raw", "qcew_3d_long.dta"
            ),
            # "qcew_2d_long": os.path.join(
            #     self.path(), "source/data/raw", "qcew_2d_long.dta"
            # ),
            # "qcew_1d_long": os.path.join(
            #     self.path(), "source/data/raw", "qcew_1d_long.dta"
            # ),
            "county_unemp_1990_2017": os.path.join(
                self.path(), "source/data/raw", "county_unemp_1990_2017.dta"
            ),
            "qcew_1990_2017_naics1d": os.path.join(
                self.path(), "source/data/raw", "qcew_1990_2017_naics1d.dta"
            ),
            "bea_countyinc": os.path.join(
                self.path(), "source/data/processed", "bea_countyinc.dta"
            ),
            # ...
        }
    
    def _post_processing(self, noised_data):
        df = noised_data["bea_countyinc"]

        df["personal_inc_pc"] = np.round(df["personal_inc"] * 1000 / df["pop"])
        # strange off-by-one rounding discrepancy for 10 rows
        errs_low = [3567, 43673, 80551, 90615, 127416, 128114,147775]
        errs_high = [81137, 98626, 119158]
        df.loc[errs_low, "personal_inc_pc"] += 1
        df.loc[errs_high, "personal_inc_pc"] -= 1


        noised_data["bea_countyinc"] = df
        return noised_data
    
    def vars_to_noise(self) -> dict:
        return {
            "post_replication": [
                "increase",
                "GDP_percapt1",
                "epopt1",
                "naics3d_emp",
                "ln_pop_90",
                "ln_emp_90",
                "ln_avg_wages_90",
            ]
        }
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `tables.do`: ###
        #-- emp-incentive, governor-incentive
        # use "$rawdir/state_year_chars.dta", clear
        # [some vars created]
        # ...
        # eststo: reghdfe increase incumbent eyear eyearXincumbent GDP_percapt1 epopt1, absorb(year fips)
        #--
        #-- win-emp
        # [build_deal_specific_tva_analysis creates deal_specific_tva_analysis.dta]
        # global X_10pre "ln_pop_90 ln_emp_90 ln_avg_wages_90" // controls
        # gl countyleveloutcomes "naics3d_emp naics2d_emp_res naics1d_emp_res emp_res personal_inc_pc HPI epop"
        # ...
        # use $processeddir/deal_specific_tva_analysis.dta, clear
        # ...
        # foreach outcome in $countyleveloutcomes {
        # ...
        # if "`outcome'" != "HPI" {
        #     eststo: qui reg `outcome' winner post postXwinner $X_10pre i.deal_year, vce(cluster fips)
        #     ...
        # }
        # ...
        # }
        #--
        ###
        sensitivities = {
            #--- state_year_chars.dta
            ### increase: per-capita incentive spending increase >= .20
            #> from `tables.do` (run):
            # foreach v in GDP GOS bc_gov bc_all emp_CBP educ_expend grev_own_tax corptaxrev /// Convert to per capita
            #     total_incentives {
            #     qui gen `v'_percap = `v' / pop
            # }
            # ...
            # rename total_incentives_percap incentive_percap
            # ...
            # qui by fips: gen d_incentive = incentive_percap-incentive_percap[_n-1] // get change in incentive
            # qui by fips: gen pc_incentive = d_incentive/incentive_percap[_n-1] // get change in incentive (pct)
            # qui gen increase = cond(missing(pc_incentive), ., pc_incentive >= .20)
            #>
            # [not personal] total_incentives: Tax credit expend + econ dev budget, 2017 USD
            # pop: state population
            "pop": {
                "sensitivity": lambda stateyear: 1,
                "lb": 1
            },

            ### GDP_percapt1: GDP per capita (\textdollar1000) in $ t-1$
            #> from `tables.do` (run):
            # foreach v in GDP GOS bc_gov bc_all emp_CBP educ_expend grev_own_tax corptaxrev /// Convert to per capita
            #     total_incentives {
            #     qui gen `v'_percap = `v' / pop
            # }
            # qui replace GDP_percap=GDP_percap * 1000 // Rescale gdp per cap in 1000s
            # ...
            # local vlist "bc_all_percap incumbent new GDP_percap epop"
            # sort fips year
            # foreach v in `vlist' {
            #     qui by fips: gen `v't1 = `v'[_n-1] // Make lag variables
            # }
            #>
            # pop already noised

            ### epopt1: \% of population employed in $ t-1$
            #> from `tables.do` (run):
            # rename emp_CBP_percap epop 
            #>
            #> from `tables.do` (run):
            # foreach v in GDP GOS bc_gov bc_all emp_CBP educ_expend grev_own_tax corptaxrev /// Convert to per capita
            #     total_incentives {
            #     qui gen `v'_percap = `v' / pop
            # }
            # ...
            # rename emp_CBP_percap epop 
            # ...
            # qui replace epop = epop * 100 // epop in %
            # ...
            # local vlist "bc_all_percap incumbent new GDP_percap epop"
            # sort fips year
            # foreach v in `vlist' {
            #     qui by fips: gen `v't1 = `v'[_n-1] // Make lag variables
            # }
            #>
            # pop already noised
            # emp_CBP: Total Mid-March Employees with Noise
            "emp_CBP": lambda stateyear: 1,
            # pop already noised

            ### [not personal] incumbent: governor will run as incumbent next election
            ### [not personal] eyear: election year dummy
            ### [not personal] eyearXincumbent: eyear * incumbent
            #---

            #--- qcew_3d_long.dta
            ### naics3d_emp: (sum) annual_avg_emplvl
            # comes from qcew_1d_long
            "naics3d_emp": lambda stateyearnaics: 1,
            #---

            #--- bea_countyinc.dta
            ### ln_pop_90
            #> from `build_deal_specific_tva_analysis.do` (run):
            # merge 1:1 fipscounty year using $processeddir/bea_countyinc.dta, /*
	        #     */ assert(2 3) keep(3) nogen keepusing(stateabbrev personal_inc* pop)
            # ...
            # * Compute logs of variables
            # foreach var of varlist pop* emp* avg_wages* personal_inc* {
            #     gen ln_`var' = log(`var')
            # }
            # ...
            # reshape wide emp emp_res pop personal_inc personal_inc_pc avg_wages unemp ln_* ///
            #     naics1d_* naics2d_* naics3d_*, i(fipscounty id runnerup_id) j(eventyr, string)
            #>
            #> from build_bea_countyinc.do (NOT run):
            # import delimited using $rawdir/CAINC1__ALL_STATES_1969_2017.csv, ///
	            # stripquotes(yes) clear
            # ...
            # * Prep for Reshape wide
            # g lab = ""
            # replace lab = "_personal_inc" if linecode==1
            # replace lab = "_pop" if linecode==2
            # replace lab = "_personal_inc_pc" if linecode==3
            # ...
            # reshape wide var, i(fipscounty year) j(lab, string)
            # ...
            # rename (var_personal_inc var_pop var_personal_inc_pc) (personal_inc pop personal_inc_pc)
            #>
            # not running build_bea_countyinc, can just modify this file
            # pop already noised
            #---

            #--- county_unemp_1990_2017
            ### ln_emp_90
            #> from `build_deal_specific_tva_analysis.do` (run):
            # * UE and employment from BLS LAUS
            # merge 1:1 year fipscounty using $rawdir/county_unemp_1990_2017.dta, ///
            #     keep(1 3) nogen
            # lab var unemp "Unemployment rate (%)"
            # lab var emp "Total county employment"
            # ...
            # [same log transform, reshaping as above]
            #>
            "emp": lambda countyyear: 1,
            "unemp": lambda countyyear: 1,  # just for safety
            #---

            #--- qcew_1990_2017_naics1d
            ### ln_avg_wages_90
            #> from `build_deal_specific_tva_analysis.do` (run):
            #> use $rawdir/qcew_1990_2017_naics1d.dta, clear
            # ...
            # collapse (sum) annual_avg_emplvl total_annual_wages, by(year fipscounty statename fips state naics1)
            # gen avg_annual_pay = total_annual_wages / annual_avg_emplvl
            # rename annual_avg_emp emp
            # ...
            # [same log transform, reshaping as above]
            #>
            # total_annual_wages: Sum of the four quarterly total wage levels for a given year
            # NOTE: assuming wages cannot exceed $500k
            "total_annual_wages": lambda countyyear: 500000,
            # annual_avg_emplvl: Annual average of monthly employment levels for a given year
            "annual_avg_emplvl": lambda countyyear: 1,
            #---

            ### [not personal] winner: = 1 for the winning county, 0 otherwise
            ### [not personal] post
            ### [not personal] postXwinner

            ##### NOT USED --- other outcomes
            # ### personal_inc_pc: Per capita personal income (dollars)
            # #> from `build_deal_specific_tva_analysis.do` (run):
            # # merge 1:1 fipscounty year using $processeddir/bea_countyinc.dta, /*
	        # #     */ assert(2 3) keep(3) nogen keepusing(stateabbrev personal_inc* pop)
            # # ...
            # # lab var personal_inc_pc "Personal income per capita (2017 USD)"
            # #>
            # # personal_income: Personal income (thousands of dollars)
            # # pop: Population (persons)
            # # NOTE: reconstructing personal_inc_pc = personal_inc * 1000 / pop
            # # NOTE: assuming personal income clipped at 500,000
            # "personal_inc": lambda countyyear: 500,
            # # pop already noised

            # #--- qcew_2d_long.dta
            # ### naics2d_emp_res
            # #> from `build_deal_specific_tva_analysis.do` (run):
            # # forv i = 1/3 {
            # #     gen naics`i'd_ln_emp = log(naics`i'd_emp)
            # #     if `i' != 3 { 
            # #         gen naics`i'd_emp_res = naics`i'd_emp - naics3d_emp
            # #         gen naics`i'd_ln_emp_res = log(naics`i'd_emp - naics3d_emp)
            # #     }
            # # }
            # #>
            # # naics3d_emp already noised
            # "naics2d_emp": lambda stateyearnaics: 1,
            # #--- 
            # #--- qcew_1d_long.dta
            # ### naics1d_emp_res
            # # same as naics2d_emp_res
            # "naics1d_emp": lambda stateyearnaics: 1,
            # #--- 
            # #--- county_unemp_1990_2017.dta
            # ### emp_res
            # #> from `build_deal_specific_tva_analysis.do` (run):
            # # use $rawdir/qcew_1990_2017_naics1d.dta, clear
            # # ...
            # # rename annual_avg_emp emp
            # # ...
            # # drop emp wages*
            # # ...
            # # merge 1:1 year fipscounty using $rawdir/county_unemp_1990_2017.dta, ///
            # #     keep(1 3) nogen
            # # lab var unemp "Unemployment rate (%)"
            # # lab var emp "Total county employment"
            # # ...
            # # gen emp_res = emp - naics3d_emp
            # #>
            # # emp: (sum) emp
            # # naics3d_emp already noised
            # "emp": lambda countyyear: 1,
            # #---
            #####
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="emp-incentive",
            table=table,
            row="epopt1",
            col="est6",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="governor-incentive",
            table=table,
            row="eyearXincumbent",
            col="est6",
            expected_range=(0, None)
        ))
        table = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="win-emp",
            table=table,
            row="postXwinner",
            col="est1",
            expected_range=(0, None)
            # expected_range=Result.relative_range(1100, 0.2, lb=0)
        ))
        return results