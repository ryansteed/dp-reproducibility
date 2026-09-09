from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Forman(Study):
    id = 'forman-2012'

    def data_paths(self) -> dict:
        return {
            "countygrowth": os.path.join(
                self.path(), "source/data_and_programs", "countygrowth.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            # "wagediff",
            "highinc2000",
            # "higheduc2000",
            "highpop2000",
            "allhigh2000",
            "educ_inc_ind_pop_dum_surv_deep00",
            "lnpop",
            "pctblk1990",
            "pctunivp1990",
            "pctHSp1990",
            "pctbelowPL1990",
            "medhhinc1990",
            "carnegie1_enr",
            "frac_in_eng_prog",
            # "frprof",
            "pct65p1990",
            "netmig95",
            "change_totalpop",
            "change_pctblk",
            "change_pctunivp",
            "change_pctHSp",
            "change_pct65",
            # "change_netmig",
        ]
    
    _pct_vars = [
        "blk",
        "univp",
        "HSp",
        "belowPL",
        "65p",
    ]
    _pc_vars = [
        "carnegie1_enr",
        "frac_in_eng_prog",
    ]

    def _pre_processing(self, data):
        for key in self.data_paths().keys():
            df = data[key]
            df["pop"] = np.exp(df["lnpop"].astype('float64'))
            df["pop1995"] = df["pop"] + df["netmig95"].astype('float64') * df["pop"]
            df["lnpop2000"] = df["lnpop"].astype("float64") + df["change_totalpop"].astype('float64') * df["lnpop"]
            df["pop2000"] = np.exp(df["lnpop2000"]).astype('float64')
            # pct vars
            df["change_pct65p"] = df["change_pct65"]
            for v in self._pct_vars:
                yrs = ["1990"]
                if v != "belowPL":
                    df[f"pct{v}2000"] = df[f"change_pct{v}"].astype('float64') + df[f"pct{v}1990"]
                    # df[f"pct{v}2000"] = df[f"change_pct{v}"].astype('float64') * df[f"pct{v}1990"] + df[f"pct{v}1990"]
                    yrs.append("2000")
                for yr in yrs:
                    df[f"n{v}{yr}"] = df[f"pct{v}{yr}"] * df["pop"]
            for v in self._pc_vars:
                df[f"n{v}"] = df[v] * df["pop"]
        return data
    
    def _post_processing(self, noised_data):
        for key in self.data_paths().keys():
            df = noised_data[key]
            df["lnpop"] = np.log(df["pop"])
            df["lnpop2000"] = np.log(df["pop2000"])
            df["change_totalpop"] = (df["lnpop2000"] - df["lnpop"]) / df["lnpop"]
            df["netmig95"] = np.where(
                df["netmig95"].isna(), np.nan,
                np.where(
                    df["pop"].isna(), 0,
                    (df["pop1995"] - df["pop"]) / df["pop"]
                )
            )
            # pct vars
            for v in self._pct_vars:
                yrs = ["1990"]
                if v != "belowPL":
                    yrs.append("2000")
                for yr in yrs:
                    df[f"pct{v}{yr}"] = df[f"n{v}{yr}"] / df["pop"]
                if v != "belowPL":
                    df[f"change_pct{v}"] = (
                        df[f"pct{v}2000"] - df[f"pct{v}1990"]
                    )
            df["change_pct65"] = df["change_pct65p"]
            # per captia vars
            for v in self._pc_vars:
                df[v] = np.where(
                    df[v].isna(), np.nan,
                    np.where(
                        df["pop"].isna(), 0,
                        df[f"n{v}"] / df["pop"]
                    )
                )
            df["highinc2000"] = np.where(
                df["medhhinc1990"].isna(),
                1,
                df["medhhinc1990"] > 27.467, # threshold used in paper
            ).astype(int)
            df["highpop2000"] = np.where(
                df["pop"].isna(),
                1,
                df["pop"] >= 150000 # threshold used in paper
            ).astype(int)
            df["allhigh2000"] = (
                df["highinc2000"] * 
                df["higheduc2000"] * 
                df["highind2000"] *
                df["highpop2000"]
            )
            df["educ_inc_ind_pop_dum_surv_deep00"] = np.where(
                df["educ_inc_ind_pop_dum_surv_deep00"].isna(),
                np.nan,
                df["surv_deeppost00"] * df["allhigh2000"]
            )
            noised_data[key] = df
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `tables.do`: ###
        # global controls lnpop pctblk1990 pctunivp1990 pctHSp1990 pctbelowPL1990 medhhinc1990 carnegie1_enr frac_in_eng_prog npatent1980s frprof pct65p1990 netmig95
        # global change change_totalpop change_pctblk change_pctunivp change_pctHSp change_pct65 change_netmig
        # ...
        # use countygrowth, clear
        # ...
        # *TABLE 3: HIGH INCOME, ETC--OLS/PANEL
        # ...
        # eststo: regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_surv_deep00  $controls $change , robust
        ###

        sensitivities = {
            ### lnpop: ln population in 1990
            # NOTE: reconstructed pop = exp(lnpop)
            "pop": lambda countyyear: 1,

            ### wagediff: change in logged wages from 1995 to 2000.
            # assuming wagediff = ln(wage2000) - ln(wage1995) = ln(wage2000/wage1995)
            # NOTE: not enough info to deconstruct, sensitivity undefined

            ### medhhinc1990: median hh inc 1990, Census, in $1000s
            "medhhinc1990": lambda countyyear: 500 / 2,

            ### highinc2000: dummy variable of high income in 2000 (based on top quartile in 1990)
            # NOTE assuming highinc2000 = medhhinc1990 > medhhinc1990.quantile(0.75)
            # medhhinc1990: median household income in 1990 in $1,000s
            # NOTE assuming income clipped at 500k
            # sensitivity of median is max / 2

            ### higheduc2000: dummy variable of high education in 2000 (top quartile)
            # no raw data on eduction, only dummy
            # NOTE not enough info to deconstruct

            ### highpop2000: dummy variable of high population in 2000 (top quartile)
            # NOTE assuming highpop2000 = pop >= 150000
            # pop already noised
            
            ### allhigh2000: highinc2000 * higheduc2000 * highind2000 * highpop2000
            # NOTE reconstructed allhigh2000 = highinc2000 * higheduc2000 * highind2000 * highpop2000
            # highinc2000, higheduc2000, highpop2000 already noised

            ### educ_inc_ind_pop_dum_surv_deep00: surv_deeppost00 * allhigh2000
            # NOTE reconstructed surv_deeppost00 = surv_deeppost00 * allhigh2000
            # allhigh2000 already noised

            ### pct*: percentage variables from Census 1990
            # assuming pct* = n* / pop
            # NOTE reconstructing n* = pct* * pop
            # pop already noised
            ## pctblk1990: pct black 1990, Census
            "nblk1990": lambda countyyear: 1,
            ## pctunivp1990: pct univ education or above 1990, Census 
            "nunivp1990": lambda countyyear: 1,
            ## pctHSp1990: pct HS eduation or above 1990, Census
            "nHSp1990": lambda countyyear: 1,
            ## pctbelowPL1990:  pct below poverty line 1990, Census
            "nbelowPL1990": lambda countyyear: 1,
            ## pct65p1990: percentage of persons over age 65
            "n65p1990": lambda countyyear: 1,

            ### per-capita vars
            # * = n* / pop
            # NOTE reconstructing n* = * x pop
            # pop already noised
            ## carnegie1_enr: Per capita number of students enrolled in local PhD-granting institutions
            "ncarnegie1_enr": lambda countyyear: 1,
            ## frac_in_eng_prog: Per capita number of students enrolled in engineering programs at local universities
            "nfrac_in_eng_prog": lambda countyyear: 1,
            
            ### frprof: The percentage of the county’s work force in professional occupations in 1990 
            # NOTE: work force not given, cannot deconstruct

            ### netmig95: net migration to the county (from 1995 data)
            # assuming netmig95 = (pop1995 - pop) / pop
            # NOTE reconstructing pop1995 = netmig95 * pop + pop
            # pop already noised
            "pop1995": lambda countyyear: 1,
            
            ### change_totalpop: change in log total population between 1990 and 2000
            # assuming change_totalpop = (lnpop2000 - lnpop) / lnpop
            # NOTE reconstructing lnpop2000 = change_totalpop * lnpop + lnpop
            # lnpop already noised
            "pop2000": lambda countyyear: 1,

            ### change_pct*: change in * between 1990 and 2000
            # assuming change_* = pct*2000 - pct*1990
            # NOTE reconstructing pct*2000 = change_* x pct*1990 + pct*1990
            # NOTE reconstructed n*2000 = pct*2000 * pop
            ### change_pctblk
            "nblk2000": lambda countyyear: 1,
            ### change_pctunivp 
            "nunivp2000": lambda countyyear: 1,
            ### change_pctHSp 
            "nHSp2000": lambda countyyear: 1,
            ### change_pct65 
            "n65p2000": lambda countyyear: 1,

            ### change_netmig
            # NOTE '05 data not provided, can't compute

            ### [not personal] highind2000: dummy variable of high IT-intensity in 2000 (top quartile)
            ### [not personal] npatent1980s: npatent1980s=sum(count) if appyear>=1980 & appyear<=1989
            ### [not personal] surv_deeppost00: dummy variable of Advanced Internet
            ### [not used] inc_dum_surv_deeppost00: Interact term of Advanced Internet and high income county
            ### [not used] educ_dum_surv_deeppost00: Interact term of Advanced Internet and high education county
            ### [not used] pop_dum_surv_deeppost00: Interact term of Advanced Internet and high population county
        }
        return sensitivities

    def _low_noise_expected(self) -> bool:
        return True

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="tech-highcounty",
            table=table,
            row="educ_inc_ind_pop_dum_surv_deep00",
            col="est1",
            expected_range=(0, None)
        ))
        results.append(Result.from_esttab(
            id="tech-other",
            table=table,
            row="surv_deeppost00",
            col="est1",
            expected_range=(0, 0)
        ))
        return results