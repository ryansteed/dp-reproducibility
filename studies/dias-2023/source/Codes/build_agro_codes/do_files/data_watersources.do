********************************************************************************
*** Build: Water sources
********************************************************************************

use "$pathfiles_data/Originais/Captação ANA/watersources.dta", clear

gen code_mun = substr(CódigoIBGE, 1, 6)
destring code_mun, replace

merge m:1 code_mun using "$pathfiles_data/Originais/amcs_br.dta"
drop if _merge==2 // keep only original municipalities
drop _merge

gen d_man_sub=0
replace d_man_sub=1 if TipoManancial=="Subterrâneo"
gen d_man_sup=0
replace d_man_sup=1 if TipoManancial=="Superficial"

gen d_sist_int=0
replace d_sist_int=1 if TipoSistema=="Integrado"
gen d_sist_iso=0
replace d_sist_iso=1 if TipoSistema=="Isolado"

keep AMC d_* MunicipioResultadoFinal // MunicipioResultadoFinal is constant by municipality
collapse (first) MunicipioResultadoFinal (max) d_*, by(AMC)

gen d_man_mixed=0
replace d_man_mixed=1 if(d_man_sub==1 & d_man_sup==1)
replace d_man_sub=0 if d_man_mixed==1
replace d_man_sup=0 if d_man_mixed==1

gen d_sist_mixed=0
replace d_sist_mixed=1 if(d_sist_int==1 & d_sist_iso==1)
replace d_sist_int=0 if d_sist_mixed==1
replace d_sist_iso=0 if d_sist_mixed==1

save "$pathfiles_data/Workfiles/data_watersources.dta", replace
