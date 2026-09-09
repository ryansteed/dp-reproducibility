from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd


class Cascio(Study):
    id = 'cascio-2010'

    def data_paths(self):
        return {
            "popbyschage": f"{self.path()}/source/data/popbyschage.dta"
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> Dict:
        df = data["popbyschage"]

        ## deconstruct arhisesl_sdf
        # hisp esl enrollment share 2000 = hisp esl enrollment share 1976 + change in hisp esl enrollment share 1976 to 2000
        df["arhisesl_s2000"] = df["arhisesl_s1976"] \
            + df["arhisesl_sdf"]
        # missing from data, but can reconstruct
        # his esl enrollment 1976 = his esl enrollment share 1976 * total enrollment 1976
        df["arDm_his_esl_good1976"] = df["arhisesl_s1976"] * df["arDm_tot2_good1976"]

        data["popbyschage"] = df
        return data
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        df = noised_data["popbyschage"].copy()
        ## reconstruct arhisesl_sdf
        df["arhisesl_s1976"] = \
            df["arDm_his_esl_good1976"] / df["arDm_tot2_good1976"]
        df["arhisesl_sdf"] = \
            df["arhisesl_s2000"] - df["arhisesl_s1976"]
        ## reconstruct inst_sca
        # instca = shr_mexca*ca
        df["shr_mexca"] = \
            df["for_mex1970"] / df["cafor_mex"]
        df["instca"] = \
            df["shr_mexca"] * df["ca"]
        df["inst_sca"] = (
            (df["arDm_his_esl_good1976"] + df["instca"]) /
            (df["arDm_tot2_good1976"] + df["instca"])
        ) - df["arhisesl_s1976"]
        # ((arDm_his_esl_good1976+instca)/(arDm_tot2_good1976+instca))-arhisesl_s1976

        noised_data["popbyschage"] = df
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "arDm_tot2_good1976",
            # "sch1ageshindnh_df2",
            # "ppexptot72",
            "arhisesl_sdf",
            "inst_sca",
            # "sch1ageshindnh1970",
            "arDm_his_esl1976",
            "hhkidsnh"
        ]
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `table4regs.do`, `analysis_all.do`: ###
        # global samp "landarea~=.&ccity~=.&ppexptot72~=.&nobaddata_area==1"
        # ...
        # global fes "_smhi1970*"
        # ...
        # program define caldr
        # /* calculates displacement rate, given coefficient estimate
        # ARGUMENTS
        # 1: where regression coefficient is stored (estimates restore `1')
        # 2: path and dataset
        # 3: subsetting if statement (optional)
        # 4: weighting command, including brackets (optional)

        # outputs: $hhdr1 = household disp rate; $mgeff - marginal effect (log odds only)
        # */
        # ... [`caldr` transforms coeff on arhisesl_sdf using sch1ageshindnh1970, arDm_tot2_good1976, arDm_his_esl1976, hhkidsnh]
        # 
        # ...
        # foreach var in sch1ageshindnh_df2 {
        #   * IV
        #   regs data/popbyschage `var' arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "" "iv${`var'}"
        #   * OLS
        #   regs data/popbyschage `var' arhisesl_sdf arhisesl_sdf  "$fes" "if $samp&schage==1" "" "ols${`var'}"
        # }
        # foreach var in sch1ageshindnh_df2 {
        # caldr iv${`var'}1 data/popbyschage "if $samp&schage==1" 
        # }
        ###
        vars_to_noise = {
            ## sch1ageshindnh_df2: delta share of MSA's non-Hispanic population in district, 1970-2000
            # `sch1ageshindnh_df (0-19 year olds) - sch1ageshindnh_df (20-49 year olds)`
            # sch1ageshindnh_df: sch1ageshindnh2000-sch1ageshindnh1970
            # sch1ageshindnh2000: district share of msa's non-hispanics in age group, 2000
            # can't make any approximation because derivative vars don't exist

            ## [not personal var] schage — just a dummy var for if stat is about school age vs. not school age

            ## ppexptot72 — per pupil expenditure, 1972
            # can't make any approximation since neither component avail

            ## arDm_tot2_good1976 - total enrollment in secondary boundary, 1976
            "arDm_tot2_good1976": lambda msa: 1,

            ## arDm_his_esl1976 - hispanic esl enrollment in secondary boundary, 1976
            "arDm_his_esl1976": lambda msa: 1,

            ## arhisesl_sdf - change in hispanic esl enrollment share, 1976 to 2000
            # arhisesl_sdf = arhisesl_s2000 - arhisesl_s1976
            # arhisesl_s1976: hispanic esl enrollment share, 1976
            # arhisesl_s1976 = arDm_his_esl_good1976 / arDm_tot2_good1976
            # arDm_tot2_good1976: total enrollment in secondary boundary, 1976
            # CREATED INTER VAR arDm_his_esl_good1976 = arhisesl_s1976 * arDm_tot2_good1976
            # NOTE ASSUMPTION: 2000 share is invariant, arDm_tot2_good2000 does not exist to reconstruct
            "arDm_his_esl_good1976": lambda msa: 1,

            ## inst_sca: ((arDm_his_esl_good1976+instca)/(arDm_tot2_good1976+instca))-arhisesl_s1976
            # arDm_his_esl_good1976 done above
            # instca = shr_mexca*ca
            # shr_mexca = for_mex1970/cafor_mex
            # for_mex1970: mexican-born population, 1970
            "for_mex1970": lambda msa: 1,
            # cafor_mex: total CA mexican-born population, 1979
            "cafor_mex": lambda msa: 1,
            # arhisesl_s1976: hispanic esl enrollment share, 1976, see above

            ## [not personal data] _smhi1970* - some sort of fixed effects?
            
            ## sch1ageshindnh1970 — district share of msa's non-hispanics in age group, 1970
            # can't make any approximation because derivative vars don't exist

            ## hhkidsnh - non-hispanic families with kids, 1970
            "hhkidsnh": lambda msa: 1
        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table4 = self._load_esttab(f"{self.path()}/results/tab4iv.csv")
        results.append(Result.from_esttab(
            id="arhisesl_sdf-ivvar3a1_b",
            table=table4,
            row="arhisesl_sdf",
            col="ivvar3a1",
            expected_range=(None, 0)  # should be negative
        ))
        return results