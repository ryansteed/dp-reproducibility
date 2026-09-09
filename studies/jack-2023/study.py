from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Jack(Study):
    id = 'jack-2023'

    def data_paths(self) -> dict:
        paths = {
            "state_score_data": os.path.join(
                self.path(), "source", "Data", "Clean", "state_score_data.dta"
            ),
            # ...
        }
        # paths.update({
        #     f"{state}_scores": os.path.join(
        #         self.path(), "source", "Data", "Clean", f"{state}_scores.dta"
        #     )
        #     for state in [
        #         "colorado",
        #         "connecticut",
        #         "massachusetts",
        #         "minnesota",
        #         "mississippi",
        #         "ohio",
        #         "rhode_island",
        #         "virginia",
        #         "west_virginia",
        #         "wisconsin",
        #         "wyoming"
        #     ]
        # })
        return paths
    
    def _pre_processing(self, data: pd.DataFrame) -> pd.DataFrame:
        data_name = "state_score_data"
        
        # participation rate scaled to 0 to 100
        data[data_name]["participation_num"] = data[data_name]["participation"] / 100 * data[data_name]["participate_denom"]
        # NOTE: assuming pass = passed / participated
        data[data_name]["pass_num"] = data[data_name]["pass"] * data[data_name]["participation_num"]

        for group in ["white", "black", "hisp", "lunch_updated", "ELL_updated"]:
            # enrollment total is NCES # students; shares are also from NCES, so assuming the following relation:
            data[data_name][group] = np.where(
                data[data_name][f"share_{group}"] == 99, # 99 means NA
                np.nan,
                data[data_name][f"share_{group}"] * data[data_name]["EnrollmentTotal"]
            )

        return data
    
    def _post_processing(self, data: pd.DataFrame) -> pd.DataFrame:
        data_name = "state_score_data"
        
        data[data_name]["participation"] = np.where(
            data[data_name]["participation_num"] == 0,
            data[data_name]["participation"],
            data[data_name]["participation_num"] / data[data_name]["participate_denom"] * 100
        )
        
        data[data_name]["pass"] = np.where(
            data[data_name]["participation_num"] == 0,
            data[data_name]["pass"],
            data[data_name]["pass_num"] / data[data_name]["participation_num"]
        )

        for group in ["white", "black", "hisp", "lunch_updated", "ELL_updated"]:
            # enrollment total is NCES # students; shares are also from NCES, so assuming the following relation:
            data[data_name][f"share_{group}"] = np.where(
                data[data_name][group].isna(),
                data[data_name][f"share_{group}"], # set to original NA value
                data[data_name][group] / data[data_name]["EnrollmentTotal"]
            )
        
        return data
    
    def vars_to_noise(self) -> list:
        return [
            "participate_denom",
            "participation",
            "pass",
            "share_white",
            "share_black",
            "share_hisp",
            "share_lunch_updated",
            "share_ELL_updated",
            "EnrollmentTotal",
            # "unemployment", # could not noise
            "c_black_yr_ip",
            "c_black_yr_hybrid",
            "c_black_ip",
            "c_black_hybrid",
            "c_hisp_yr_ip",
            "c_hisp_yr_hybrid",
            "c_hisp_ip",
            "c_hisp_hybrid"
        ]
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `analysis.do`:
        # * Panel A
        #     foreach subject in math ela {
        #         quietly xi: areg pass share_inperson share_hybrid i.year share_white share_black share_hisp missing_lunch share_lunch_updated  missing_ELL share_ELL_updated unemployment participation participate_denom i.year*i.commute_zone i.year*i.state_gr [aw = EnrollmentTotal] if subject=="`subject'", absorb(district_unique) cluster(district_unique)
        #         ...
        #     }
        #         ...

        # *Panel B: Interactions
        #         foreach subject in math ela {
        #         quietly xi: areg pass inperson_2021 hybrid_2021 c_black* i.year*share_black share_white share_black share_hisp missing_lunch share_lunch_updated missing_ELL share_ELL_updated unemployment  participation participate_denom i.year*i.commute_zone i.year*i.state_gr  [aw = EnrollmentTotal] if subject=="`subject'", absorb(district_unique) cluster(district_unique)	
        #         ...
        #         quietly xi: areg pass inperson_2021 hybrid_2021 c_hisp* i.year*share_hisp share_white share_black share_hisp missing_lunch share_lunch_updated missing_ELL share_ELL_updated unemployment  participation participate_denom i.year*i.commute_zone i.year*i.state_gr  [aw = EnrollmentTotal] if subject=="`subject'", absorb(district_unique) cluster(district_unique)
        #         ...
        #         }
        ###
        vars_to_noise = {
            ## participate_denom: denominator used to calculate participation rate (Grades 3-8 enrollment counts)
            "participate_denom": lambda county: 1,

            ## participation: test participation rate
            # participation = participation_num / participate_denom * 100
            # CREATED INTERMEDIATE VAR participation_num = participation / 100 * participation_denom
            "participation_num": lambda county: 1,

            ## pass: average pass rate across grades weighted by enrollment
            # CREATED INTERMEDIATE VAR pass_num = pass * participation_num
            # participation_num already noised
            "pass_num": lambda county: 1,
            
            ### share_*
            # CREATED INTERMEDIATE VARS * = share_* x EnrollmentTotal
            ## share_white: share of students who are white calculated from NCES data
            "white": lambda county: 1,
            ## share_black: share of students who are Black calculated from NCES data
            "black": lambda county: 1,
            ## share_hisp: share of students who are Hispanic calculated from NCES data
            "hisp": lambda county: 1,
            ## share_lunch_updated: share of students who received free and reduced price lunch (FRPL)
            "lunch_updated": lambda county: 1,
            ## share_ELL_updated: share of students who are english language learners (ELL) calculated from NCES
            "ELL_updated": lambda county: 1,

            ## EnrollmentTotal: student enrollment counts from the NCES data
            # NOTE: used as weights in regression
            "EnrollmentTotal": {
                "sensitivity": lambda county: 1,
                "lb": 1
            },
            
            ## unemployment: county-level unemployment rates from the Bureau of Labor Statistics
            # NOTE: missing county pop, so can't do sensitivity analysis
            # NOTE: Assuming public data

            ### c_*
            # code from `analysis.do`:
            # gen c_`var'_yr_ip = share_`var'*inperson_2021
            # gen c_`var'_yr_hybrid = share_`var'*hybrid_2021
            # gen c_`var'_ip = share_`var' * share_inperson
            # gen c_`var'_hybrid = share_`var'*share_hybrid
            ## c_black*
            # done — share_black, share_inperson, share_hybrid
            ## c_hisp*
            # done — share_hisp, share_inperson, share_hybrid

            ## [not personal data] missing_lunch: dummy for missing free and reduced price lunch data in NCES
            ## [not personal data] missing_ELL: dummy for missing ELL data in NCES
            ## [not personal data] share_inperson: share of school days in-person during 2020-2021 school year
            ## [not personal data] inperson_2021=share_inperson*treat_year
            ## [not personal data] share_hybrid: share of school days hybrid during 2020-2021 school year calculated from the CSD
            ## [not personal data] hybrid_2021=share_hybrid*treat_year
            
            # ...
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        tableA = self._load_esttab(f"{self.path()}/results/main_regressions_panelA.csv")
        results.append(Result.from_esttab(
            id="share_inperson-math",
            table=tableA,
            row="share_inperson",
            col="m2_math",
            expected_range=Result.relative_range(0.134, 0.2)
        ))
        results.append(Result.from_esttab(
            id="share_inperson-ela",
            table=tableA,
            row="share_inperson",
            col="m2_ela",
            expected_range=Result.relative_range(0.083, 0.2)
        ))
        results.append(Result.from_esttab(
            id="share_hybrid-math",
            table=tableA,
            row="share_hybrid",
            col="m2_math",
            expected_range=Result.relative_range(0.072, 0.2)
        ))
        results.append(Result.from_esttab(
            id="share_hybrid-ela",
            table=tableA,
            row="share_hybrid",
            col="m2_ela",
            expected_range=Result.relative_range(0.054, 0.2)
        ))

        tableB = self._load_esttab(f"{self.path()}/results/main_regressions_panelB.csv")
        results.append(Result.from_esttab(
            id="black_yr_ip-math",
            table=tableB,
            row="c_black_yr_ip",
            col="m1_math",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="hisp_yr_ip-math",
            table=tableB,
            row="c_hisp_yr_ip",
            col="m2_math",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="black_yr_ip-ela",
            table=tableB,
            row="c_black_yr_ip",
            col="m1_ela",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="hisp_yr_ip-ela",
            table=tableB,
            row="c_hisp_yr_ip",
            col="m2_ela",
            expected_range=(0, 0)
        ))
        return results