********************************************************************************
*** Build: Basic panel with municipalities' and AMCs' codes
********************************************************************************

clear
import excel using "$pathfiles_data/Originais/soy_area_1996_2010.xlsx", allstring cellrange(B6:R5570)

drop if B==""

rename B codmun7
rename C name_mun

keep codmun7 name_mun

gen code_mun=substr(codmun7,1,6) 
destring code_mun, replace
destring codmun7, replace


* Merge AMC codes
merge 1:1 code_mun using "$pathfiles_data/Originais/amcs_br.dta"
drop _merge


* Create State code from code_mun
gen code_uf=substr(string(code_mun),1,2)
destring code_uf, replace


* Transform into panel: 1996-2010
expand 15
bys code_mun: gen year = 1995+_n


* Merge with municipality area
merge m:1 codmun7 using "$pathfiles_data/Originais/area_mun_Ibge_2010.dta"
drop if _m==2
drop _m
