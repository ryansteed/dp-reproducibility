********************************************************************************
*** Build: Rain Dataset
********************************************************************************

** Build basic rain dataset
do "$pathfiles_do/data_rain.do"

** Basic panel
do "$pathfiles_do/build_panel.do"

** Merge rain data
merge 1:1 code_mun year using "$pathfiles_data/Originais/rain.dta"
drop _merge

** Colapse by AMC-year
sort AMC year
collapse (mean) rain_year rain_oct_dec rain_oct_mar rain_apr_sep [w=area_ibge_km2], by(AMC year)


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




********************************************************************************
* Create rain exposure variable at the AMC level


* First, we estimate rain in each AMC-subbasin
foreach i in rain_year rain_oct_dec rain_oct_mar rain_apr_sep {
gen `i'_AMC_subbasin = `i'
}
*

* Now, create the variable of rain exposure for each AMC 
foreach i in rain_year rain_oct_dec rain_oct_mar rain_apr_sep {
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


foreach k in rain_year rain_oct_dec rain_oct_mar rain_apr_sep {
quietly su `k'_AMC_subbasin [w=`wgt1'] if (basin==`aux_basin' & position>`aux_position' & year==`aux_year' & AMC!=`aux_amc')
quietly replace `k'_subbasin = r(mean) * (a_amc_subbasin_ha/a_amc_ha) if aux_group==`i'
*quietly replace `k'_subbasin = r(mean) if aux_group==`i'
quietly replace `k'_subbasin = 0 if (aux_group==`i' & `area1'==0)
}


* Downstream:
quietly su a_amc_subbasin_ha if (basin==`aux_basin' & position<`aux_position' & year==`aux_year' & AMC!=`aux_amc')
local area2=r(sum)/100
local wgt2 = a_amc_subbasin_ha / `area2' 


foreach w in rain_year rain_oct_dec rain_oct_mar rain_apr_sep {
quietly su `w'_AMC_subbasin [w=`wgt2'] if (basin==`aux_basin' & position<`aux_position' & year==`aux_year' & AMC!=`aux_amc')
quietly replace `w'_downstream = r(mean) * (a_amc_subbasin_ha/a_amc_ha) if aux_group==`i'
quietly replace `w'_downstream = 0 if (aux_group==`i' & `area2'==0)
}
*/

}
*


foreach i in rain_year rain_oct_dec rain_oct_mar rain_apr_sep {
replace `i'_AMC_subbasin = `i'*(a_amc_subbasin_ha/a_amc_ha)
}



* Collapse by AMC-year
sort year AMC
collapse (sum) rain_year_AMC_subbasin rain_oct_dec_AMC_subbasin rain_oct_mar_AMC_subbasin rain_apr_sep_AMC_subbasin rain_year_subbasin rain_year_downstream rain_oct_dec_subbasin rain_oct_dec_downstream rain_oct_mar_subbasin rain_oct_mar_downstream rain_apr_sep_subbasin rain_apr_sep_downstream, by(AMC year)

compress
save "$pathfiles_data/Workfiles/data_rain_subbasins.dta", replace


