********************************************************************************
* Build: Births
********************************************************************************


clear*
set more off , permanently


use "${datasus}/SINASC_micro.dta", clear
count // 54,095,594


* Restrict sample and variables
drop if ano<1998 | ano>2010

tostring anomes, gen(month)
replace month=substr(month,5,2)
destring month, replace
drop if month==0|month==.


********************************************************************************
* Handling birth outcomes
gen births=1

********************************************************************************
* Save and collapse


rename mun_res code_mun
rename ano year

collapse (sum) births, by(year month code_mun)
reshape wide births, i(code_mun year) j(month)
compress
save "$pathfiles_data/SINASC_yearmonth_onlybirths.dta", replace
