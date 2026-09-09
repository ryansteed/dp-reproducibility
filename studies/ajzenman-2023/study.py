from typing import Dict
from simulate_privacy.studies import Study, Result
import pandas as pd 
import numpy as np
import os


class Ajzenman(Study):
    id = 'ajzenman-2023'
    def data_paths(self) -> dict:
        return {
            "enusc_IV": os.path.join(
                self.path(), "source","Replication","data","analysis","enusc_IV.dta"
            ),
            "channels_OLS": os.path.join(
                self.path(), "source","Replication","data","analysis","channels_OLS.dta"
            )
            # ...
        }
    
    def stata_version(self):
        return 119
    
    def _pre_processing(self, data):
        for name in data.keys():
            df = data[name]
            # deconstructing hombre
            df["n_hombre"] = df["hombre"] * df["expc"]
            # deconstructing age
            df["agetotal"] = df["age"] * df["expc"]
            data[name] = df
        return data
    
    def _post_processing(self, noised_data):
        for name in noised_data.keys():
            df = noised_data[name]
            # reconstructing hombre
            df["hombre"] = np.where(
                (name == "channels_OLS") & (df["n_hombre"] / df["expc"]).isna(),
                df["hombre"], # only impute for channels_OLS, where var is not used
                df["n_hombre"] / df["expc"]
            )
            # reconstructing age
            df["age"] = np.where(
                (name == "channels_OLS") & (df["agetotal"] / df["expc"]).isna(),
                df["age"], # only impute for channels_OLS, where var is not used
                df["agetotal"] / df["expc"]
            )
            if name == "channels_OLS":
                # reconstructing lnrate_stock_imm
                df["lnrate_stock_imm"] = np.log(10000 * df["stock_imm"] / df["population"] + 1)
            noised_data[name] = df
        return noised_data
    
    def sensitivity_matrix(self) -> dict:
        ### relevant regression code from `Tables_VI_VII_VIII_IX.do`: ###
        # use enusc_IV, clear
        # ...
        #-- dmigr-concern
        # foreach outcome in del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict pc_19{
        # ...
	    # replace `outcome' = 100*`outcome'
        # eststo: ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
        # eststo clear
        # ...
        # }
        # ...
        #-- dmigr-crime
        # foreach outcome in Index_Vivienda Index_Vecinos del_arma pc_20{
	    # replace `outcome' = 100*`outcome'
        # ...
        # eststo: ivreg2 `outcome' age hombre (deltaimm=deltaimm_instr), robust savefirst
        # eststo clear
        # ...
        # }
        ###
        ### relevant regression code from `Tables_XI_XII_XIII_A16.do`: ###
        # use channels_OLS, clear
        # * Genero la matriz
        # foreach outcome in vict_agreg pc_19 pc_20{
        #     replace `outcome'=100*`outcome'
        #     ...
        #     eststo: areg `outcome' lnrate_stock_imm i.year edad ismale i.year#c.bas_`outcome' if above_medianMED==1, absorb(cod_com) vce(cluster cod_com)
        #     ...
        # }
        ###
        vars_to_noise = {
            ##--- enusc_IV
            # constructed in `IV_1.do`

            ### hombre: (sum) hombre
            # from IV_1.do (not active):
            # gen hombre=(sexo==1)
            # ...
            # * El factor de expansion es expc
            # foreach var in hombre age ypc esc{
            #     replace `var'=`var'*expc
            # }
            # * Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
            # collapse (sum) hombre age ypc expc, by(cod_com)
            # * Genero las tasas:
            # foreach var in hombre age ypc{
            #     replace `var'=`var'/expc
            # }
            # so it seems like expc is the denominator
            # NOTE: created var n_hombre = hombre * expc
            "n_hombre": lambda municipality: 1,
            # NOTE: not noising denominator, since this is some sort of expansion factor, leaving invariant

            ### deltaimm: Log change of immigrants divided by population
            # from IV_1.do:
            # use population, clear
            # merge 1:m cod_com using FinalBase_permisos
            # ...
            # * Ahora solo pongo la inmigracion dividida en permisos y visas en logaritmos, la otra va sin logs
            # foreach j in "" "_permiso" "_visa"{
            #     replace imm`j'=imm`j'*100000/population
            # }
            # # sort cod_com year
            # foreach j in "" "_permiso" "_visa"{
            #     gen lndelta_imm`j'=ln(imm`j'*1000+1)
            #     bysort cod_com (year) : gen deltaimm`j' = lndelta_imm`j' - lndelta_imm`j'[_n-1]
            #     bysort cod_com (year) : gen deltalevel`j' = imm`j' - imm`j'[_n-1]
            # }
            # NOTE: imm* not included, not enough info for DP

            ### deltaimm_instr: predicted log change in the immigrant-to-population ratio in each municipality
            # foreach j in "_permiso" "_visa"{
            #     egen deltaimm_instr`j'=rowtotal(imm_com_*`j')
            # }
            # NOTE: imm* not included, not enough info for DP
            
            #-- dmigr-concern
            ### pc_19: principal component of crime beliefs
            # from ENUSC.do:
            # cd "$rawdata/ENUSC"
            # forvalues i=2008/2017 {
            #     use `i', clear
            #     cap drop year
            #     gen year=`i'
            #     save "`i'_updated.dta", replace
            #     clear
            # }
            # from IV_1.do:
            # use base_final_2008_2017, clear
            # ...
            # gen del_problema3=(pe1_1_1==8 | pe1_1_2==8) if kish==1 & (pe1_1_1<80 & pe1_1_2<80)
            # gen del_afecta3=(pe2_1_1==8 | pe2_1_2==8) if kish==1 & (pe2_1_1<80 & pe2_1_2<80)
            # gen del_calvida3=(pe6_1_1==1 | pe6_1_1==2) if kish==1 & (pe6_1_1<80 & pe6_1_1<80)
            # gen del_inseg5=(del_inseg1==1 &  del_inseg2==1 & del_inseg3==1) if kish==1 & (pe10_1_1<80 & pe10_2_1<80 & pe10_3_1<80 )
            # gen del_vict=(pe13_1_1==1) if kish==1 & pe13_1_1 < 80
            # ...
            # pca del_problema3 del_afecta3 del_calvida3 del_inseg5 del_vict
            # predict pc_19, score
            # the pe* vars come directly from ENUSC/*.dta
            # they are categorical question answers, also microdata
            # NOTE: created from microdata, can't noise from Python

            ### age
            # from IV_1.do (not active):
            # gen age=edad
            # * El factor de expansion es expc
            # foreach var in hombre age ypc esc{
            #     replace `var'=`var'*expc
            # }
            # * Colapsando la suma de expc a nivel comuna voy a tener el denominador para calcular los % de cada variable
            # collapse (sum) hombre age ypc expc, by(cod_com)
            # * Genero las tasas:
            # foreach var in hombre age ypc{
            #     replace `var'=`var'/expc
            # }
            # so it seems age = agetotal / expc
            # NOTE: created var agetotal = age * expc
            # NOTE: assuming no one can be older than 120
            "agetotal": lambda municipality: 120,
            # not noising expc, since this is some sort of expansion factor, leaving invariant
            #--

            #-- dmigr-crime
            ### pc_20: same as pc_19
            # NOTE: created from microdata, can't noise from Python

            ### age: same as above
            ##---

            ##--- channels_OLS
            # this dataset is individual-level
            ### pc_19: microdata, not noised

            ### lnrate_stock_imm: log immigration rate
            # cd "$rawdata"
            # from OLS_2_homicides.do (not run):
            # use base_final_2008_2017, clear
            # cd "$conf_intermed"
            # ...
            # merge 1:m cod_com using immigration_collapse
            # gen lnrate_stock_imm = ln( 10000*stock_imm/ population+1)
            # stock_imm: appears to be # immigrants
            # population: appears to be total population
            # var appears to be per 10000
            # NOTE: reconstructed lnrate_stock_imm = ln( 10000*stock_imm/ population+1)
            "stock_imm": lambda municipality: 1,
            "population": lambda municipality: 1,

            ### edad: individual age control
            # NOTE: microdata, not noised

            ### ismale: is male
            # NOTE: microdata, not noised

            ### bas_pc_20
            # NOTE: microdata, not noised

            ### above_medianMED
            # NOTE: microdata, not noised
            ###
            ##---
        }
        return vars_to_noise
    
    def vars_to_noise(self):
        return [
            "hombre",
            "age"
        ]

    def extract_results(self) -> list[Result]:
        results = []
        table = self._load_esttab(f"{self.path()}/results/table1.csv")
        results.append(Result.from_esttab(
            id="dmigr-concern",
            table=table,
            row="deltaimm",
            col="est1",
            expected_range=(0, None)
        ))
        table2 = self._load_esttab(f"{self.path()}/results/table8.csv")
        results.append(Result.from_esttab(
            id="dmigr-crime",
            table=table2,
            row="deltaimm",
            col="est1",
            expected_range=(0, None)
        ))
        table3 = self._load_esttab(f"{self.path()}/results/table3.csv")
        results.append(Result.from_esttab(
            id="media-crime",
            table=table3,
            row="lnrate_stock_imm",
            col="est2",
            expected_range=(0, None)
        ))
        return results