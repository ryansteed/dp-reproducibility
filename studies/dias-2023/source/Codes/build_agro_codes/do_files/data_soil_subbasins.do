********************************************************************************
*** Build: Soil Dataset
********************************************************************************

* Build basic panel
do "$pathfiles_do/build_panel.do"

* Prepare soil data to be merged
preserve
clear
use "$pathfiles_data/Originais/PNE/pne.dta"
rename muni_code code_mun
drop muni_n
save "$pathfiles_data/Originais/PNE/tempS.dta", replace
clear
restore

** Merge soil data
merge m:1 code_mun using "$pathfiles_data/Originais/PNE/tempS.dta"
drop if _merge==2 // dropa code_mun 431453
drop _m
drop name_mun

** Colapse by AMC-year
sort AMC 
collapse (sum) npixels (mean) pneP_c1 pneP_c5 pne_mean pne_std pne_median [w=npixels], by(AMC year)


********************************************************************************
* Merge with Basins 


** Merge with ottobasin lvl 4 information - each observation in the resulting database is a pair AMC-ottobasin
** Ottobasins information is obtained from ANA and combined with AMC data using a GIS software
merge 1:m AMC year using "$pathfiles_data/Originais/amcs_subbasins.dta"
drop if _merge==1 // Islands of Ilhabela and Fernando de Noronha are discarded
drop _merge

** Destring area variables - areas in ha
destring a_amc_subbasin_ha, force replace
destring a_amc_ha, force replace



********************************************************************************
* Info about basin and position
gen aux_basin=string(subbasin)
gen basin=substr(aux_basin,1,3)
gen position=substr(aux_basin,4,1)
drop aux_basin
replace position="0" if position=="" // Some ottobasins lvl 3 cannot be subdivided
destring basin position, replace

keep if year>=2000


********************************************************************************
* Create rain exposure variable at the AMC level


* First, we estimate pne (rain) in each AMC-subbasin
foreach i in pneP_c1 pneP_c5 pne_mean pne_median {
*gen `i'_AMC_subbasin = `i'*(a_amc_subbasin_ha/a_amc_ha)
gen `i'_AMC_subbasin = `i'
}
*

* Now, create the variable of pne for each AMC 
foreach i in  pneP_c1 pneP_c5 pne_mean pne_median {
gen `i'_subbasin =.
gen `i'_downstream =.
}
*


* Now, create auxiliar variable, identifying year-subbasin, and local variables (minimum and maximum) which allows us to know 
* cover all the possible values of the auxiliar variables.
egen aux_group=group(AMC subbasin year)
quietly su aux_group
local minimum=r(min)
local maximum=r(max)



* Loop:
forvalues i=`minimum'/`maximum'{


* First, we identify basin (ottobasin lvl 3), position, year, and AMC for the AMC-subbasin-year==i
quietly su basin if aux_group==`i'
local aux_basin=r(min)
quietly su position if aux_group==`i'
local aux_position=r(min)
quietly su year if aux_group==`i'
local aux_year=r(min)
quietly su AMC if aux_group==`i'
local aux_amc=r(min)


* Upstream:
quietly su a_amc_subbasin_ha if (basin==`aux_basin' & position>`aux_position' & year==`aux_year' & AMC!=`aux_amc')
local area1=r(sum)
local wgt1 = a_amc_subbasin_ha / `area1' 


foreach k in  pneP_c1 pneP_c5 pne_mean pne_median {
quietly su `k'_AMC_subbasin [w=`wgt1'] if (basin==`aux_basin' & position>`aux_position' & year==`aux_year' & AMC!=`aux_amc')
quietly replace `k'_subbasin = r(mean) * (a_amc_subbasin_ha/a_amc_ha) if aux_group==`i'
*quietly replace `k'_subbasin = r(mean) if aux_group==`i'
quietly replace `k'_subbasin = 0 if (aux_group==`i' & `area1'==0)
}


* Downstream:
quietly su a_amc_subbasin_ha if (basin==`aux_basin' & position<`aux_position' & year==`aux_year' & AMC!=`aux_amc')
local area2=r(sum)/100
local wgt2 = a_amc_subbasin_ha / `area2' 


foreach w in  pneP_c1 pneP_c5 pne_mean pne_median {
quietly su `w'_AMC_subbasin [w=`wgt2'] if (basin==`aux_basin' & position<`aux_position' & year==`aux_year' & AMC!=`aux_amc')
quietly replace `w'_downstream = r(mean) * (a_amc_subbasin_ha/a_amc_ha) if aux_group==`i'
*quietly replace `w'_downstream = r(mean) if aux_group==`i'
quietly replace `w'_downstream = 0 if (aux_group==`i' & `area2'==0)
}
*/

}
*


foreach i in  pneP_c1 pneP_c5 pne_mean pne_median {
replace `i'_AMC_subbasin = `i'*(a_amc_subbasin_ha/a_amc_ha)
}




* Collapse by AMC-year
sort year AMC
collapse (sum) pneP_c1_AMC_subbasin pneP_c5_AMC_subbasin pne_mean_AMC_subbasin pne_median_AMC_subbasin pneP_c1_subbasin pneP_c1_downstream pneP_c5_subbasin pneP_c5_downstream pne_mean_subbasin pne_mean_downstream pne_median_subbasin pne_median_downstream, by(AMC year)

compress
save "$pathfiles_data/Workfiles/data_soil_subbasins.dta", replace


