from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Combs(Study):
    id = 'combs-2021'

    def data_paths(self) -> dict:
        return {
            "kyexemptreplicationdata": os.path.join(
                self.path(), "source", "kyexemptreplicationdata.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "lnrealtcurelscpp",
            "lntaxableratio1",
            "lntaxshare",
            "lnrealp50inc",
            "pctefrl2",
            "pctsped2",
            "pctlep2",
            "lnivtaxableratio1",
            "bachplus",
            "homeown",
            "black",
            "youthpct",
            "oldhosh",
            "disabhosh",
            "lnenrollment",
            "lnenrollmentsq",
            # "lntaxableratio1terc",
            # "ivaidshare1",
            # "aidsharestyinger1",
        ]
    
    student_shares = [
        "pctefrl2",
        "pctsped2",
        "pctlep2"
    ]

    pop_shares = [
        "black",
        "youthpct"
    ]

    def _pre_processing(self, data):
        df = data["kyexemptreplicationdata"]

        df["realtcurelsc"] = np.exp(df["lnrealtcurelscpp"]) * df["enrollment"]
        df["claimants"] = df["p50num"] / df["claimp50sh"]
        df["ivtakeup"] = (1 - np.exp(df["lnivtaxableratio1"].astype('float64')) * (1 - df["exemptrate"].astype('float64'))) / df["taxshare"].astype('float64') * df["claimants"].astype('float64')
        df["households"] = df["homeowntotimp"] / df["homeown"] * 100

        df["count_bachplus"] = df["bachplus"] / 100 * df["pop"] * (100 - df["youthpct"])

        for v in self.student_shares:
            df[f"count_{v}"] = df[v] / 100 * df["enrollment"]
        for v in self.pop_shares:
            df[f"count_{v}"] = df[v] / 100 * df["pop"]
        
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["kyexemptreplicationdata"]
        
        # realp50inc
        df["lnrealp50inc"] = np.log(df["realp50inc"])

        ## lntaxableratio1
        # inexplicable numeric errors in the original data
        df["nomassessaltpp"] = df["nomassessalt"].astype('float64') / df["enrollment"].astype('float64')
        df["taxshare"] = df["medval2"].astype('float64') / df["nomassessaltpp"]
        df["lntaxshare"] = np.log(df["taxshare"])
        # correct negligible numeric errors in original
        if np.isclose(df.loc[[1949, 2469], "lntaxshare"],[0.00458708, -0.00477176]).all():
            df.loc[[1949, 2469], "lntaxshare"] = [0.00458701, -0.00477169]
        df["claimp50sh"] = df["p50num"] / df["claimants"]
        errors = [
            85, 86, 87, 88, 89, 129, 579, 625, 626, 627, 628, 629,
            705, 706, 713, 715, 716, 717, 718, 719, 850, 851, 852, 853,
            854, 945, 946, 947, 955, 956, 957, 958, 959, 970, 971, 972,
            973, 974, 1015, 1016, 1017, 1018, 1019, 1125, 1126, 1129, 1130, 1193,
            1194, 1278, 1279, 1280, 1281, 1282, 1355, 1356, 1357, 1673, 1674, 1675,
            1676, 1677, 1803, 1804, 1805, 1806, 1807, 1838, 1839, 1847, 2024, 2025,
            2026, 2027, 2118, 2119, 2120, 2121, 2122
        ]
        errors_orig = df.loc[errors, "lntaxableratio1"].copy()
        df["lntaxableratio1"] = df["lntaxableratio1"].astype('float64')
        new_ratio = np.log(
            (1 - df["taxshare"].astype('float64') * (df["claimp50sh"] >= 0.5)) /
            (1 - df["exemptrate"].astype('float64'))
        )
        df["lntaxableratio1"] = np.where(
            new_ratio.isna() | df["claimp50sh"].isna(),
            df["lntaxableratio1"],
            new_ratio
        )
        if np.isclose(df.loc[errors, "lntaxableratio1"], [
            -0.26056306, -0.27264764, -0.23987616, -0.25912547, -0.23594681, -3.42419971,
            -0.43063757, -0.57496852, -0.5912819,  -0.59649314, -0.60606575, -0.63385004,
            -0.51885625, -0.49847551, -0.92759827, -0.49421817, -0.51690792, -0.51222002,
            -0.48657791, -0.4248965,  -0.43559144, -0.4094888,  -0.42361702, -0.42664525,
            -0.40874854, -0.19354999, -0.15624249, -0.19462378, -0.24190359, -0.26196348,
            -0.21984628, -0.22118705, -0.20510809, -0.1045668,  -0.08322094, -0.06059766,
            -0.07921804, -0.07255757, -0.21276207, -0.21948942, -0.19917894, -0.21102569,
            -0.20321785, -0.52320241, -0.4827375,  -0.85045777, -1.27932842, -0.4036226,
            -0.36229598, -0.43529373, -0.42253652, -0.46426845, -0.46961504, -0.50509939,
            -0.30396709, -0.30847323, -0.28636966, -0.22618023, -0.22704601, -0.23532049,
            -0.42476946, -0.55842037, -0.21604303, -0.23592359, -0.20727903, -0.20134506,
            -0.17991651, -0.86932116, -0.81240783, -2.20364229, -1.01029664, -0.84267954,
            -0.57403385, -0.39344233, -1.49817884, -1.45882593, -1.28363337, -1.49961087,
            -1.39944598
        ]).all():
            df.loc[errors, "lntaxableratio1"] = errors_orig
        df["lnivtaxableratio1"] = np.where(
            df["claimants"].isna(),
            df["lnivtaxableratio1"],
            np.log(
                (1 - df["taxshare"] * df["ivtakeup"] / df["claimants"]) /
                (1 - df["exemptrate"])
            )
        )

        # enrollment stats
        df["lnenrollment"] = np.log(df["enrollment"])
        df["lnenrollmentsq"] = df["lnenrollment"] ** 2
        
        # realtcurelsc stats
        df["realtcurelscpp"] = df["realtcurelsc"] / df["enrollment"]
        df["lnrealtcurelscpp"] = np.log(df["realtcurelscpp"])

        for v in self.student_shares:
            df[v] = df[f"count_{v}"] / df["enrollment"] * 100
        for v in self.pop_shares:
            df[v] = df[f"count_{v}"] / df["pop"] * 100

        # homeowntotimp
        df["homeown"] = df["homeowntotimp"] / df["households"] * 100
        df["disabhosh"] = df["disabhotot"] / df["homeowntotimp"] * 100
        df["oldhosh"] = df["oldhoimp"] / df["homeowntotimp"] * 100

        # bachplus
        adults = df["pop"] * (100 - df["youthpct"])
        df["bachplus"] = df["count_bachplus"] / adults * 100

        for c in df.columns:
            if df[c].isna().all():
                raise ValueError(
                    f"Column {c} in kyexemptreplicationdata is all NaN after post-processing."
                )
        
        return noised_data
    
    def time_index(self) -> str:
        return "year"
    
    def subset_index(self):
        return "district"

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Code-for-Replication.do`: ###
        # use kyexemptreplicationdata.dta, clear
        # ...
        # local iv1 lnivtaxableratio1 lntaxableratio1terc ivaidshare1
        # local iv2 lnivtaxableratio2 lntaxableratio2terc ivaidshare2
        # local iv3 lnivtaxableratio3 lntaxableratio3terc ivaidshare3
        # local controls lntaxshare lnrealp50inc pctefrl2 pctsped2 pctlep2 bachplus homeown black lnenrollment lnenrollmentsq youthpct oldhosh disabhosh
        # ...
        # # forval i=1... {
            # xtivreg2 lnrealtcurelscpp (lntaxableratio`i' aidsharestyinger`i'= `iv`i'') `controls' ///
                #  _Iyear_2000-_Iyear_2013, fe cluster(ncesid) endog(lntaxableratio`i' aidsharestyinger`i') first gmm2s
            # eststo m`i'
            # ...
        # }
        sensitivities = {
            ### lnenrollment: Enrollment
            # NOTE reconstructing lnenrollment = ln(enrollment)
            "enrollment": {
                "sensitivity": lambda districtyear: 1,
                "lb": 1
            },

            ### lnenrollmentsq: Enrollment squared
            # NOTE reconstructing lnenrollmentsq = lnenrollment^2
            # already noised lnenrollment

            ### lnrealtcurelscpp = ln(realtcurelscpp)
            # NOTE reconstructing lnrealtcurelscpp = ln(realtcurelscpp)
            # realtcurelscpp: Current operating expenditure per-pupil
            # assuming realtcurelscpp = realtcurelsc / enrollment
            # NOTE reconstructing realtcurelsc = exp(lnrealtcurelscpp) * enrollment
            # [not personal] realtcurelsc
            # enrollment already noised

            ### lntaxableratio1: ratio between taxable share of median voter's property and taxable share of district-wide property when threshold set to 50%
            # assume median voter takes exemption if % claimaints in median income bracket is <50%
            # NOTE reconstructing lntaxableratio1 = ln(
            # (1 - taxshare * (claimp50sh >= 0.5)) /
            # (1 - exemptrate)
            # )
            ## taxshare: district median voter's tax share
            # taxshare = median home value / district property value per pupil
            # NOTE reconstructing taxshare = medval2 / nomassessaltpp
            # [not personal] medval2: district median home value
            # nomassessaltpp: district gross property value per pupil, nominal
            # NOTE reconstructing nomassessaltpp = nomassessalt / enrollment
            # [not personal] nomassessalt: district gross property value
            # enrollment already noised
            ## [not personal] exemptrate: district fraction of property value exempt
            ## claimp50sh: Dist. share of homeowners in bracket containing med. inc. who claimed exemption
            # assuming claimp50sh = p50num / claimants
            # p50inc: district median income
            # p50loc: income bracket that contains district median income
            # p50num: district number of homeowners in the income bracket containing the median income
            # NOTE reconstructing claimants = p50num / claimp50sh
            "p50num": lambda districtyear: 1,
            "claimants": {
                "sensitivity": lambda districtyear: 1,
                "lb": 1
            },

            ### [failed] aidsharestyinger1: State aid share, 50% threshold
            # NOTE: probably private, but can't figure out how to reconstruct

            ### lntaxshare: Median voter's tax share
            # NOTE reconstructing lntaxshare = ln(taxshare)
            # taxshare already noised

            ### lnrealp50inc: Median household income
            # NOTE reconstructing lnrealp50inc = ln(realp50inc)
            # NOTE assuming income clipped at 500k
            # median sensitivity is max / 2
            "realp50inc": lambda districtyear: 500000 / 2,

            ### IV vars
            # "We construct instrumental variables (IVs) that are versions of the taxable share
            # ratio and the aid share for which we set the take-up rates among seniors and the
            # disabled equal to the average values across districts and time periods 
            # (i.e., the sample averages)."
            ## lnivtaxableratio1
            # assuming lnivtaxableratio1 = ln(
            # (1 - taxshare * ivtakeup / claimants) /
            # (1 - exemptrate)
            # )
            # => exp(lnivtaxableratio1) * (1-exemptrate) = (1 - taxshare * ivtakeup / claimants)
            # NOTE reconstructing ivtakeup = (1 - exp(lnivtaxableratio1) * (1-exemptrate)) / taxshare * claimants
            # taxshare, claimants already noised; exemprate not personal
            
            ## [failed] ivaidshare1
            # NOTE same as aidsharestyinger1; probably private, but can't figure out how to reconstruct

            ### [failed] lntaxableratio1terc: annual tercile rank of a school’s expenditure and the unweighted average district level, per pupil expenditure among districts in neighboring counties
            # NOTE cannot reconstruct, no geographic info

            ### student shares: % students *
            # NOTE: reconstructing count_* = * / 100 x enrollment
            # enrollment already noised
            ## pctefrl2:% Students FRPL
            "count_pctefrl2": lambda districtyear: 1,
            ## pctsped2:% Students IEP
            "count_pctsped2": lambda districtyear: 1,
            ## pctlep2:% Students LEP
            "count_pctlep2": lambda districtyear: 1,

            ### population shares: % pop *
            # NOTE: created inter var count_* = * x pop
            # pop:School district population
            "pop": {
                "sensitivity": lambda district: 1,
                "lb": 1
            },
            ## black:% African American
            "count_black": lambda districtyear: 1,
            ## youthpct:% Age 5-17
            "count_youthpct": lambda districtyear: 1,

            ### homeown:Homeownership rate
            # homeown = homeowntotimp / households * 100
            # NOTE reconstructed households = homeowntotimp / homeown * 100
            # homeowntotimp: district number of homeowners, imputed
            "homeowntotimp": {
                "sensitivity": lambda districtyear: 1,
                "lb": 1
            },
            "households": {
                "sensitivity": lambda districtyear: 1,
                "lb": 1
            },

            ### disabhosh:% of homeowners with a disability
            # NOTE reconstructing disabhosh = disabhotot / homeowntotimp * 100
            # homeowntotimp already noised
            "disabhotot": lambda districtyear: 1,

            ## oldhosh: % homeowners Age 65+
            # NOTE reconstructing oldhosh = oldhoimp / homeowntotimp * 100
            "oldhoimp": lambda districtyear: 1,

            ### bachplus:% Adults with B.A.+
            # bachplus = count_bachplus / (df["pop"] * (100 - df["youthpct"])) * 100
            # NOTE: reconstructing count_bachplus = bachplus / 100 * pop * (100 - youthpct)
            # pop, youthpct already noised
            "count_bachplus": lambda districtyear: 1,
        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="tax-50m1",
            table=table,
            row="lntaxableratio1",
            col="m1",
            expected_range=(None, 0)
        ))
        results.append(Result.from_esttab(
            id="taxshare-50m1",
            table=table,
            row="lntaxshare",
            col="m1",
            expected_range=(None, 0)
        ))
        return results