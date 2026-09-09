from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os
from loguru import logger


class Crane(Study):
    id = 'crane-2024'

    def data_paths(self) -> dict:
        return {
            "merged_data": os.path.join(
                self.path(), "source", "Output", "merged_data.dta"
            )
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict:
        df = data["merged_data"]

        ## deconstructing ipc
        # ipc = income / pop
        df["income"] = df["ipc"] * df["pop"]
        df["income_l4"] = df["ipc_l4"] * df["pop_l4"]

        ## deconstructing wage*
        df["weekly_wage"] = df["average_weekly_wage"] * df["pop"]
        df["weekly_wage_l4"] = df["average_weekly_wage_l4"] * df["pop_l4"]

        ## deconstructing unemp_rate
        df["unemp"] = df["unemp_rate"] * df["pop"]
        df["unemp_l4"] = df["unemp_rate_l4"] * df["pop_l4"]

        ## deconstructing poppct_urban1990
        for yr in ["1990", "2010"]:
            df[f"pop_urban{yr}"] = np.where(
                df["year"] == (int(yr) + 2), # 1990 demographics from 1992 data
                df[f"poppct_urban{yr}"] / 100 * df["pop"],
                np.nan
            )
        # cs = ["st", "fips", "year", "pop", "pop_urban1990", "pop_urban2010", "poppct_urban1990", "poppct_urban2010"]
    
        data["merged_data"] = df
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df = noised_data["merged_data"]
        ## reconstructing ipc
        df["ipc"] = df["income"] / df["pop"]
        df["ipc_l4"] = df["income_l4"] / df["pop_l4"]
        df["ipc_l4_ln"] = np.log(df["ipc_l4"])

        ## reconstructing wage*
        df["average_weekly_wage"] = np.where(
            df["pop"].isna() | df["pop"] == 0,
            df["average_weekly_wage"],
            df["weekly_wage"] / df["pop"]
        )
        df["average_weekly_wage_l4"] = np.where(
            df["pop_l4"].isna(),
            df["average_weekly_wage_l4"],
            df["weekly_wage_l4"] / df["pop_l4"]
        )

        ## reconstructing unemp
        df["unemp_rate"] = df["unemp"] / df["pop"]
        df["unemp_rate_l4"] = df["unemp_l4"] / df["pop_l4"]

        ## reconstructing poppct_urban*
        for yr in ["1990", "2010"]:
            index = ["st", "fips"]
            # weird error where some counties don't have 2012 data, so filling in the original value manually. will not be noised
            has_yr = df.groupby(index)["year"].transform(lambda g: (int(yr) + 2) in g)
            df[f"poppct_urban{yr}"] = np.where(
                df["pop"].isna() | ~has_yr,
                df[f"poppct_urban{yr}"],
                100 * df[f"pop_urban{yr}"] / df["pop"]
            )
            df[f"poppct_urban{yr}"] = df.groupby(index)[f"poppct_urban{yr}"].transform('max')

        ## reocnstruction pop_l4_ln
        df["pop_l4_ln"] = np.log(df["pop_l4"])

        noised_data["merged_data"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "incum_d",
            "dividend_ratio",
            "ipc_d",
            "ipc_l4_ln",
            "wage_d",
            "wage_l4_ln",
            "unemp_rate_l4",
            "white_ratio_d",
            "white_ratio_l4",
            "hispanic_ratio_d",
            "hispanic_ratio_l4",
            "black_ratio_d",
            "black_ratio_l4",
            "under20_ratio_l4",
            "under20_ratio_d",
            "above65_ratio_l4",
            "above65_ratio_d",
            "poppct_urban1990",
            "poppct_urban2010",
            "pop_d",
            "pop_l4_ln"
        ]
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Paper_exhibits_BS_SEs.do`: ###
        # use merged_data.dta
        # ...
        # save sample, replace
        # ...
        # use "$output/sample", clear
        # eststo clear

        # eststo: reghdfe incum_d dividend_ratio div_ret, a(year) cluster(year)

        # /*Control, Control*Demincum*/
        # global cnty_controls ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum

        # eststo:  reghdfe incum_d dividend_ratio div_ret $cnty_controls, a(year) cluster(year)

        # /*Controls*return*/
        # foreach var of varlist white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
        # gen `var'_ret=`var'*ret
        # }

        # global var_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret

        # eststo:  reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret, a(year) cluster(year)

        # /*votes-weighted*/
        # eststo:  reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret [aw=totalvotes], a(year) cluster(year)

        # /*Trend*/
        # egen urban=rowmean(poppct_urban1990 poppct_urban2010)
        # xtile urban_group=urban,n(3)
        # egen urban_group_year=group(urban_group year)
        # egen education_mean=rowmean(bachelor_pct_1990 bachelor_pct_2010)
        # xtile edu_group=education_mean,n(3)
        # egen edu_group_year=group(edu_group year)

        # eststo: reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret [aw=totalvotes], a(urban_group_year edu_group_year) cluster(year)

        # gen dem_share=demvote/totalvotes
        # gen rep_share=repvote/totalvotes
        # forv i=1/3{
        #     reg dem_share year if urban_group==`i'
        #     predict res if e(sample), res
        #     replace dem_share=res if urban_group==`i'
        #     drop res
        #     reg rep_share year if urban_group==`i'
        #     predict res if e(sample), res
        #     replace rep_share=res if urban_group==`i'
        #     drop res
        # }

        # /*county by  year FE*/
        # drop st
        # drop county_year
        # gen st=int(fips/1000)
        # egen county_year=group(st year)

        # eststo: reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret [aw=totalvotes], a(county_year) cluster(year)
        # /*win-lose*/
        # gen ltw=0
        # replace ltw=1 if incum_share_last<opp_share_last & incum_share>opp_share
        # replace ltw=-1 if incum_share_last>opp_share_last & incum_share<opp_share
        # eststo: reghdfe ltw dividend_ratio div_ret $cnty_controls $var_ret, a(year) cluster(year)
        ###
        vars_to_noise = {
            ### pop: population
            "pop": lambda county: 1,
            "pop_l4": lambda county: 1,

            ### incum_d = incum_share - incum_share_last
            # Regression code:
            # gen incum_share=demvote/totalvotes if dem_incum==1
            # gen incum_share_last=demvote_last/totalvotes_last if dem_incum==1
            # replace incum_share=repvote/totalvotes if dem_incum==0
            # replace incum_share_last=repvote_last/totalvotes_last if dem_incum==0
            "demvote": lambda county: 1,
            "demvote_last": lambda county: 1,
            "repvote": lambda county: 1,
            "repvote_last": lambda county: 1,
            "totalvotes": {
                "sensitivity": lambda county: 1,
                "lb": 0 # some regs weight by num adults
            },

            ### dividend_ratio=dividend/adjusted_gross_income
            # ASSUMPTION: 1,000,000 max adjusted_gross_income; could all be dividends
            # skipped these because units for gross income and dividend are unclear
            # "adjusted_gross_income": lambda county: 1000000,
            # "dividend": lambda county: 1000000,

            ### div_ret= dividend_ratio*ret
            # [not personal data] ret: cumulative stock market return from November of the previous election year to October before the current election

            ### *_d = * / *_l4 - 1
            ## ipc*: income per capita
            # CREATED INTER VARS income*
            # NOTE ASSUMPTION: clipping at 500,000
            "income": lambda county: 500000,
            "income_l4": lambda county: 500000,
            ## wage_d, wage_l4_ln
            # wage_d=average_weekly_wage/average_weekly_wage_l4-1
            # NOTE ASSUMPTION: max wage is 3 STD (228) above the mean (629)
            "weekly_wage": lambda county: 629+3*228,
            # NOTE ASSUMPTION: max wage is 3 STD (198) above the mean (553)
            "weekly_wage_l4": lambda county: 553+3*198,

            ## unemp_rate
            # CREATED INTER VARS unemp* = unemp_rate* * pop*
            # NOTE: ASSUMPTION labor force is the entire county pop
            # already noised pop*
            "unemp": lambda county: 1,
            "unemp_l4": lambda county: 1,
            
            "tot_pop": lambda county: 1,
            "tot_pop_l4": lambda county: 1,
            ## white_ratio=pop_white/tot_pop
            "pop_white": lambda county: 1,
            "pop_white_l4": lambda county: 1,
            ## hispanic_ratio=pop_hispanic/tot_pop
            "pop_hispanic": lambda county: 1,
            "pop_hispanic_l4": lambda county: 1,
            ## black_ratio=pop_black/tot_pop
            "pop_black": lambda county: 1,
            "pop_black_l4": lambda county: 1,
            ## under20_ratio
            "pop_under20": lambda county: 1,
            "pop_under20_l4": lambda county: 1,
            ## above65_ratio
            "pop_above65": lambda county: 1,
            "pop_above65_l4": lambda county: 1,

            ### *_d_demIncum = *_d * dem_incum
            # [not personal data] dem_incum: incumbent party is Democratic

            ### poppct_urban1990
            # CREATED INTER VAR pop_urban1990
            "pop_urban1990": lambda county: 1,

            ### poppct_urban_2010
            # CREATED INTER VAR pop_urban2010
            "pop_urban2010": lambda county: 1,

        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table2 = self._load_esttab(f"{self.path()}/results/Table2.csv")
        for col in [3, 4, 5, 6]:
            results.append(Result.from_esttab(
                id=f"div_ret-incum_d-{col}",
                table=table2,
                row="div_ret",
                col=f"est{col}",
                expected_range=(
                    Result.relative_range(1.6, tolerance=0.2)[0],
                    Result.relative_range(2.2, tolerance=0.2)[1]
                )  # should be between around 1.6 and around 2.2
            ))
        results.append(Result.from_esttab(
            id=f"div_ret-ltw",
            table=table2,
            row="div_ret",
            col="est7",
            expected_range=(0, None)  # should be positive
        ))
        return results