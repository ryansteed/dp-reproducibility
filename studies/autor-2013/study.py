from typing import Dict
from simulate_privacy.studies import Study, Result
from simulate_privacy.config import logger

import pandas as pd

class Autor(Study):
    id = 'autor-2013'

    def data_paths(self):
        return {
            "workfile_china": f"{self.path()}/source/dta/workfile_china.dta"
        }
    
    def _pre_processing(self, data: Dict[str, pd.DataFrame]) -> dict:
        for var in [
            "l_sh_popedu_c",
            "l_sh_popfborn"
        ]:
            data["workfile_china"][f"count_{var}"] = data["workfile_china"][var] / 100 * data["workfile_china"]["l_popcount"]
        for var in [
            "l_shind_manuf_cbp",
            "l_sh_routine33",
            "d_tradeusch_pw",
            "d_tradeotch_pw_lag"
        ]:
            data["workfile_china"][f"count_{var}"] = data["workfile_china"][var] / 100 * data["workfile_china"]["l_no_workers_totcbp"]
        return super()._pre_processing(data)
    
    def _post_processing(self, noised_data) -> pd.DataFrame:
        for var in [
            "l_sh_popedu_c",
            "l_sh_popfborn"
        ]:
            noised_data["workfile_china"][var] = 100 * noised_data["workfile_china"][f"count_{var}"] / noised_data["workfile_china"]["l_popcount"]
        for var in [
            "l_shind_manuf_cbp",
            "l_sh_routine33",
            "d_tradeusch_pw",
            "d_tradeotch_pw_lag"
        ]:
            noised_data["workfile_china"][var] = 100 * noised_data["workfile_china"][f"count_{var}"] / noised_data["workfile_china"]["l_no_workers_totcbp"]
        return noised_data
    
    def vars_to_noise(self) -> list:
        return [
            "l_shind_manuf_cbp",
            "l_sh_popedu_c",
            "l_sh_popfborn",
            # "l_sh_empl_f",
            "l_sh_routine33",
            "d_tradeusch_pw",
            "d_tradeotch_pw_lag",
            "l_popcount",
            "l_no_workers_totcbp"
        ]
    
    def other_vars(self) -> list:
        return [
            "d_sh_empl_mfg", "reg_midatl", "reg_encen", "reg_wncen",
            "reg_satl", "reg_escen", "reg_wscen", "reg_mount", "reg_pacif",
            "l_task_outsource", "timepwt48",
            # "t2"
        ]
    
    def time_index(self) -> str:
        return "yr"
    
    def subset_index(self):
        return "czone"

    def sensitivity_matrix(self) -> dict:
        ### regression code:
        # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip) first
        # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp t2 [aw=timepwt48], cluster(statefip) first
        # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48], cluster(statefip) first
        # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* l_sh_popedu_c l_sh_popfborn l_sh_empl_f t2 [aw=timepwt48], cluster(statefip) first
        # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip) first
        # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip) first
        ###
        sensitivity_cz = {
            # first differences in 10 × annual change in manufacturing emp/working-age pop (in % pts)
            # = 10* (e_0 / n_0 - e_1 / n_1) / (e_0 / n_0)
            # if e_0 changes by 1,
            # "d_sh_empl_mfg": lambda cz: 10 * 1 / cz["l_no_workers_totcbp"] / cz["l_sh_empl_mfg"], 
            # NOTE: ASSUMPTION: cannot noise, infinite sensitivity, components not available

            ### l_sh*
            # CREATED INTER VARS count_l_sh_* = l_sh* x l_popcount
            ## l_shind_manuf_cbp: % employment in manufacturing, lagged
            "count_l_shind_manuf_cbp": lambda cz: 1,
            ## l_sh_popedu_c: % pop with college degree, lagged
            "count_l_sh_popedu_c": lambda cz: 1,
            ## l_sh_popfborn: % foreign born, lagged
            "count_l_sh_popfborn": lambda cz: 1,
            ## l_sh_routine33: % employment in routine occupation, lagged (* 100)
            "count_l_sh_routine33": lambda cz: 1,

            ### l_sh_empl_f: % employment among women, lagged
            # NOTE: can't noise, # women not available

            ### d_trade*: change in imports from china to US/other per worker
            # both noised by l_no_workers_totcbp
            # no need to add noise to count_d_trade* vars, these aren't personal data
            ## d_tradeusch_pw: change in imports from china to US per worker
            ## d_tradeotch_pw_lag: change in imports from china to other per worker, lagged

            ## l_popcount: CZ population (from `summ`, appears that l_ is for lagged, not log)
            "l_popcount": {
                "sensitivity": lambda cz: 1,
                "lb": 1
            },
            ## l_no_workers_totcbp: No workers total in CZ
            "l_no_workers_totcbp": lambda cz: 1

            # [not personal data] l_task_outsource: avg offshoreability of occupations, lagged
            # [not personal data] change in imports from china to US worker - not private
            # # change in imports from china to other worker, lagged - not private
        }
        return sensitivity_cz
    
    def extract_results(self) -> list[Result]:
        results = []
        table3 = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="d_tradeusch_pw-empl",
            table=table3,
            row="d_tradeusch_pw",
            col="est6",
            expected_range=(None, 0)  # should be negative, significant
        ))
        return results