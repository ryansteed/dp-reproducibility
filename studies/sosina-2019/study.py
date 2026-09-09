from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Sosina(Study):
    id = 'sosina-2019'

    def data_paths(self) -> dict:
        return {
            "15_year_sample_state_190625": os.path.join(
                self.path(), "source", "data-files","15_year_sample_state_190625.dta"
            )
            # ...
        }
    
    def _post_processing(self, noised_data):
        df = noised_data["15_year_sample_state_190625"]

        # reconstructing prop_pov
        df["prop_pov"] = df["rut_pov517"] / df["rut_pop517"]

        # reconstructing prop_* race/eth
        for v in ["black", "hisp", "asian", "ind"]:
            df[f"prop_{v}"] = df[f"imp_tot{v}"] / df["imp_member"]
        
        # reconstructing bwddexp_totexp_std
        # df["bwddexp_totexp_std"] = (((df["exp_totexpblk"] - df["exp_totexpwht"]) * 1000)/(df["midexp_totexp"]*1000))*10000
        # df["bwddexp_totexp"] = (df["exp_totexpblk"] - df["exp_totexpwht"]) * 1000

        # reconstructing bwdifblk
        # df = df.drop(columns="imp_per_black")
        # df["bwdifblk"] = df["blkinblk"] - df["blkinwht"]

        noised_data["15_year_sample_state_190625"] = df
        return noised_data
    
    def vars_to_noise(self):
        return [
            "prop_pov",
            "prop_black",
            "prop_hisp",
            "prop_asian",
            "prop_ind"
        ]
    
    def other_vars(self):
        return [
            "bwddexp_totexp_std",
            "bwdifblk",
            "bwdifpov",
            "bwdifhsp",
            "bwdifpsch",
            "bwdifspec",
            "bwdifell",
            "bwdifcity",
            "bwdifothgeo",
            "hwddexp_totexp_std",
            "hwddexp_infra_std",
            "hwdifhsp",
            "hwdifpov",
            "hwdifblk",
            "hwdifpsch",
            "hwdifspec",
            "hwdifell",
            "hwdifcity",
            "hwdifothgeo"
        ]
    
    def time_index(self):
        return "year"
    
    def subset_index(self):
        return "imp_fips"
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `sosina-weathers_main.do`: ###
        # global date "190625"
        # ...
        # global g "bw"
        # global controls ""
        # global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
        # global controls "${controls} ${g}difcity ${g}difothgeo"
        # global state ""
        # global state "prop_black prop_hisp prop_asian prop_ind i.year"
        # global options ""
        # global options "i(imp_fips) fe vce(cluster imp_fips)"
        # ...
        # use "../data-files/15_year_sample_state_${date}", clear
        # ...
        #-- Table 1
        # local outcomes ""
		# local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		# local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		# local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
        # foreach o of local outcomes {
		# 	eststo: xtreg `o' bwdifblk bwdifpov bwdifhsp ${controls} prop_pov ${state}, ///
		# 		${options}
		# 	...
		# }
        # ...
        #-- Table 2
        # global g "hw"
        # global controls ""
        # global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
        # global controls "${controls} ${g}difcity ${g}difothgeo"
        # global state ""
        # global state "prop_black prop_hisp prop_asian prop_ind i.year"
        # global options ""
        # global options "i(imp_fips) fe vce(cluster imp_fips)"
        # ...
        # use "../data-files/15_year_sample_state_${date}", clear
        # ...
        # local outcomes ""
		# local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		# local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		# local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		# ...
		# foreach o of local outcomes {
		# 	eststo: xtreg `o' hwdifhsp hwdifpov hwdifblk ${controls} prop_pov ${state}, ///
		# 		${options}
        #   ...
		# }
        ###
        vars_to_noise = {
            ### prop_pov: state proportion poor (saipe)
            # NOTE: reconstructed prop_pov = rut_pov517 / rut_pop517
            "rut_pov517": lambda stateyear: 1,
            "rut_pop517": lambda stateyear: 1,

            ### prop*
            # NOTE: reconstructed prop_* = imp_tot* / imp_member
            # imp_member: total students, all grades (ccd imputed)
            "imp_member": lambda stateyear: 1,
            ## prop_black: state proportion black
            "imp_totblack": lambda stateyear: 1,
            ## prop_hisp: state proportion hispanic
            "imp_tothisp": lambda stateyear: 1,
            ## prop_asian: state proportion asian
            "imp_totasian": lambda stateyear: 1,
            ## prop_ind: state proportion native american
            "imp_totind": lambda stateyear: 1,

            #-- segragation-bw, racial-bw
            ### bwddexp_totexp_std: black-white total exp dollar difference (standardized)
            # from 7-construct-measures-state_190625.do (not run):
            # midexp_totexp = exp_totexptot if year == 2006
            # bwddexp_totexp_std = (((exp_totexpblk - exp_totexpwht) * 1000)/(midrev_totalrev*1000))*10000
            # bwddexp_totexp = (exp_totexpblk - exp_totexpwht) * 1000
            # exp_totexp* = 
            # NOTE: district-level files not provided, not enough info for DP
            # exp_totexp`g' is avg of cwippexp_totexp weighted by `g' at district level
            
            ### bwdifblk: black-white black enroll disparity
            # from 7-construct-measures-state_190625.do (not run): 
            # collapse
            # ...
            # blkin`g' 		= 	imp_perblack ///
            # ...
            # [fw = n`g'], by(imp_fips year)
            # ...
            # gen bwdifblk = blkinblk - blkinwht
            # (weighted mean of imp_perblack by imp_fips and year)
            # NOTE: district-level files not provided, not enough info for DP

            ### bwdifpov: black-white poverty disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### bwdifhsp: black-white hispanic enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### bwdifpsch: black-white p school enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### bwdifspec: black-white spec ed enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### bwdifell: black-white ell enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### bwdifcity: black-white city district disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### bwdifothgeo: black-white oth geo district disparity
            # NOTE: district-level files not provided, not enough info for DP

            #-- segragation-hw, racial-hw-infra
            ### hwddexp_totexp_std: hispanic-white total exp dollar difference (standardized)
            # NOTE: district-level files not provided, not enough info for DP
            ### hwddexp_infra_std: hispanic-white infrastructure exp dollar difference (standardized)
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifhsp: hispanic-white hispanic enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifpov: hispanic-white poverty disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifblk: hispanic-white black enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifpsch: hispanic-white p school enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifspec: hispanic-white spec ed enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifell: hispanic-white ell enroll disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifcity: hispanic-white city district disparity
            # NOTE: district-level files not provided, not enough info for DP
            ### hwdifothgeo: hispanic-white oth geo district disparity
            # NOTE: district-level files not provided, not enough info for DP

        }
        return vars_to_noise

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="segragation-bw",
            table=table,
            row="bwdifpov",
            col="est1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="racial-bw",
            table=table,
            row="bwdifblk",
            col="est1",
            expected_range=(None, 0)
        ))
        table2 = self._load_esttab(f"{self.path()}/results/table2.csv")
        results.append(Result.from_esttab(
            id="segragation-hw",
            table=table2,
            row="hwdifpov",
            col="est1",
            expected_range=(0, 0)
        ))
        results.append(Result.from_esttab(
            id="racial-hw-infra",
            table=table2,
            row="hwdifhsp",
            col="est3",
            expected_range=(None, 0)
        ))
        return results