from simulate_privacy.studies import Study, Result
import pandas as pd
import numpy as np
import os


class Dorn(Study):
    id = 'dorn-2013'

    def data_paths(self) -> dict:
        return {
            "workfile2012": os.path.join(
                self.path(), "source","Autor-Dorn-LowSkillServices-FileArchive","dta", "workfile2012.dta"
            )
            # ...
        }
    
    def vars_to_noise(self) -> list:
        # list all personal vars used in the regression
        return [
            "l_shage_65up",
            "timepwt48",
            "l_relsup_highlow",
            "l_popfborn_shof_edulow",
            ## personal but not noised
            # "l_shind_manuf",
            # "l_unempl",
            # "l_sh_empl_f",
            # "l_sh_minw",
            # l_sh_routine33a
            # d_shocc1_service_nc
            # d_shocc1_transconstr_nc
            # d_shocc1_clericretail_nc
            # d_shocc1_product_nc
            # d_shocc1_operator_nc
            # R33a_50_1980
            # R33a_50_1990
            # R33a_50_2000
        ]
    
    def _pre_processing(self, data):
        df = data["workfile2012"]

        for var in [
            "l_shage_65up"
        ]:
            df[f"count_{var}"] = df[var] * df["l_popcount"]
        df["l_pop_national"] = df["l_popcount"] / df["timepwt48"]
        df["l_college_pop"] = df["l_relsup_highlow"] * df["l_popcount"] / (1 + df["l_relsup_highlow"])
        df["l_noncollege_pop"] = df["l_popcount"] - df["l_college_pop"]
        df["l_immigr_pop"] = df["l_popfborn_shof_edulow"] * df["l_noncollege_pop"]

        data["workfile2012"] = df
        return data
    
    def _post_processing(self, noised_data):
        df = noised_data["workfile2012"]

        for var in [
            "l_shage_65up"
        ]:
            df[var] = df[f"count_{var}"] / df["l_popcount"]
        df["timepwt48"] = df["l_popcount"] / df["l_pop_national"]
        df["l_noncollege_pop"] = df["l_popcount"] - df["l_college_pop"]
        df["l_relsup_highlow"] = df["l_college_pop"] / df["l_noncollege_pop"]
        df["l_popfborn_shof_edulow"] = df["l_immigr_pop"] / df["l_noncollege_pop"]

        noised_data["workfile2012"] = df
        return noised_data

    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `czone_analysis.do`: ###
        # use ../dta/workfile2012.dta, clear
        # xi i.statefip
        ## routine-emp
        # eststo: ivregress 2sls d_shocc1_service_nc (l_sh_routine33a=R33a_50_1980 R33a_50_1990 R33a_50_2000) l_relsup_highlow l_popfborn_shof_edulow l_shind_manuf l_unempl l_sh_empl_f l_shage_65up l_sh_minw t2 t3 _Istatefip* [aw=timepwt48] if yr>=1980, cluster(statefip)
        # ...
        ## routine-serviceemp
        # eststo service: ivregress 2sls d_shocc1_service_nc (l_sh_routine33a=R33a_50_1980 R33a_50_1990 R33a_50_2000) t2 t3 _Istatefip* [aw=timepwt48] if yr>=1980, cluster(statefip)
        ## routine-transconstremp
        # eststo transconstr: ivregress 2sls d_shocc1_transconstr_nc (l_sh_routine33a=R33a_50_1980 R33a_50_1990 R33a_50_2000) t2 t3 _Istatefip* [aw=timepwt48] if yr>=1980, cluster(statefip)
        ## routine-clericretailemp
        # eststo clericretail: ivregress 2sls d_shocc1_clericretail_nc (l_sh_routine33a=R33a_50_1980 R33a_50_1990 R33a_50_2000) t2 t3 _Istatefip* [aw=timepwt48] if yr>=1980, cluster(statefip)
        ## routine-productemp
        # eststo product: ivregress 2sls d_shocc1_product_nc (l_sh_routine33a=R33a_50_1980 R33a_50_1990 R33a_50_2000) t2 t3 _Istatefip* [aw=timepwt48] if yr>=1980, cluster(statefip)
        ## routine-operatoremp
        # eststo operator: ivregress 2sls d_shocc1_operator_nc (l_sh_routine33a=R33a_50_1980 R33a_50_1990 R33a_50_2000) t2 t3 _Istatefip* [aw=timepwt48] if yr>=1980, cluster(statefip)
        ###
        sensitivities = {
            # relevant code:
            # CREATED INTER VARS count_* = * x l_popcount / 
            ### d_shocc1_*_nc: 10 x annual change in share of noncollege employment by occupation
            # d_shocc1_*_nc = 10 * (emp_occ_1 / emp_1) - 10 * (emp_occ_0 / emp_0)
            # NOTE: missing raw occ data / rates, can't reconstruct. not noised
            ## d_shocc1_service_nc
            ## d_shocc1_transconstr_nc
            ## d_shocc1_clericretail_nc
            ## d_shocc1_product_nc
            ## d_shocc1_operator_nc

            ### l_sh_routine33a: share of routine occupations lagged [paper]
            # assuming l_sh_routine33a = emp_routine / emp_total
            # NOTE: missing employment count, can't reconstruct

            ### l_relsup_highlow: college / noncollege population lagged [paper]
            # assuming l_population = l_college_pop + l_noncollege_pop
            # then l_relsup_highlow = l_college_pop / (l_population - l_college_pop)
            # reconstructing l_college_pop = l_relsup_highlow * l_popcount / (1 + l_relsup_highlow)
            "l_college_pop": lambda state: 1,

            ### l_popfborn_shof_edulow: immigr/noncollege population lagged [paper]
            # reconstructing l_noncollege_pop = l_popcount - l_college_pop
            # l_college_pop already noised
            # l_popcount already noised
            # reconstructing l_immigr_pop = l_popfborn_shof_edulow * l_noncollege_pop
            "l_immigr_pop": lambda state: 1,

            ### l_shind_manuf: manufact/empl lagged [paper]
            # NOTE: missing employment count, can't reconstruct

            ### l_unempl: unemployment rate lagged [paper]
            # NOTE: missing employment count / labor force, can't reconstruct

            ### l_sh_empl_f: female empl/pop lagged [paper]
            # assuming l_sh_empl_f = l_empl_f / l_popcount_f
            # NOTE: missing female population or pop share, can't reconstruct

            ### l_shage_65up: age 65+/pop lagged [paper]
            # assuming l_shage_65up = count_l_shage_65up / l_popcount
            # reconstructing count_l_shage_65up = l_shage_65up * l_popcount
            "count_l_shage_65up": lambda state: 1,
            "l_popcount": {
                "sensitivity": lambda state: 1,
                "lb": 1,
                "integer": True
            },

            ### l_sh_minw: share workers with wage < min wage lagged [paper]
            # NOTE: missing employment count, can't reconstruct

            ### R33a_50_*
            # Our approach is as follows: let Eij, 1950 equal the employment share of industry i ∈ 1, ..., I in commuting zone j in 1950, and let Ri,−j, 1950 equal the routine occupation share among workers in industry i in 1950 in all US states except the state that includes commuting zone j.42
            # NOTE: missing raw data, can't reconstruct

            ### timepwt48: Models are weighted by start of period commuting zone share of national population [paper]
            # assuming timepwt48 = l_popcount / l_pop_national
            # reconstructing l_pop_national = l_popcount / timepwt48
            "l_pop_national": lambda state: 1,
            # l_popcount already noised

            ### [not personal] t*: time dummy
            ### [not personal] statefip*: state fixed effects
            ### [not personal] yr: year

        }
        return sensitivities

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table.csv")
        results.append(Result.from_esttab(
            id="routine-emp",
            table=table,
            row="l_sh_routine33a",
            col="est1",
            expected_range=(0, None)
        ))
        table1 = self._load_esttab(f"{self.path()}/results/table1.csv")
        for lowroutine in [
            "service", "transconstr"
        ]:
            results.append(Result.from_esttab(
                id=f"routine-{lowroutine}emp",
                table=table1,
                row="l_sh_routine33a",
                col=lowroutine,
                expected_range=(0, None)
            ))
        for highroutine in [
            "clericretail", "product", "operator"
        ]:
            results.append(Result.from_esttab(
                id=f"routine-{highroutine}emp",
                table=table1,
                row="l_sh_routine33a",
                col=highroutine,
                expected_range=(None, 0)
            ))
        return results