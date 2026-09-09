********************************************************************************
*** Build: Potential by distance dataset
********************************************************************************

* Prepare soy potential data
use "$pathfiles_data/Originais/potential_soy_amc.dta", clear

keep if year==2000
drop year dA_soy
rename AMC amc_2

tempfile potdata
save `potdata'

*
clear
import delimited using "$pathfiles_data/Originais/intersections.csv", varnames(1)

merge m:1 amc_2 using `potdata'
keep if _merge==3
drop _merge


* Calculate potentials by radius
* 	Potentials for each AMC-subbasin are going to be weighted (by area) averages of potentials for each intersected area.
*	We are going to do everything for low and high potential separately and create the unique potential variable in the end.
*	Steps:
*		1) Calculate potential*area of intersected area for each intersection IF in the same basin and upstream
*		2) Collapse by AMC-subbasin-radius, summing the (potential*area) variable and calculating the total area in the process
*		3) Divide sum(potential*area) by total area for each AMC-subbasin-radius
*		4) Collapse by AMC-radius, using proportion of AMC area in the subbasin as weight
*		5) Reshape long -> wide

* Step 1:
gen aux = string(otto4)
gen basin = substr(aux,1,3)
gen subbasin = substr(aux,4,1)
replace subbasin = "0" if length(aux)==3
drop aux
destring basin, replace
destring subbasin, replace

gen aux = string(otto4_2)
gen basin_2 = substr(aux,1,3)
gen subbasin_2 = substr(aux,4,1)
replace subbasin_2 = "0" if length(aux)==3
drop aux
destring basin_2, replace
destring subbasin_2, replace

gen potential_l = A_soy_l*ainterha*(basin==basin_2 & subbasin_2>subbasin & amc!=amc_2)
gen potential_h = A_soy_h*ainterha*(basin==basin_2 & subbasin_2>subbasin & amc!=amc_2)
gen area_inter_ha = ainterha*(basin==basin_2 & subbasin_2>subbasin & amc!=amc_2)

gen potential_l_down = A_soy_l*ainterha*(basin==basin_2 & subbasin_2<subbasin & amc!=amc_2)
gen potential_h_down = A_soy_h*ainterha*(basin==basin_2 & subbasin_2<subbasin & amc!=amc_2)
gen area_inter_ha_down = ainterha*(basin==basin_2 & subbasin_2<subbasin & amc!=amc_2)

* Step 2:
collapse (sum) potential_l potential_h a_radius_ha=area_inter_ha potential_l_down potential_h_down a_radius_ha_down=area_inter_ha_down (firstnm) acrossha a_amc_ha, by(amc otto4 distance)

* Step 3:
gen potential_l_unnorm = potential_l
gen potential_h_unnorm = potential_h

replace potential_l = acrossha * potential_l/a_radius_ha
replace potential_h = acrossha * potential_h/a_radius_ha

replace potential_l=0 if a_radius_ha==0
replace potential_h=0 if a_radius_ha==0

replace potential_l_down = acrossha * potential_l_down/a_radius_ha_down
replace potential_h_down = acrossha * potential_h_down/a_radius_ha_down

replace potential_l_down=0 if a_radius_ha_down==0
replace potential_h_down=0 if a_radius_ha_down==0

* Step 4:
collapse (sum) potential_l potential_h potential_l_unnorm potential_h_unnorm aamcha=acrossha potential_l_down potential_h_down (max) a_radius_ha a_radius_ha_down, by(amc distance)

replace potential_l = potential_l/aamcha
replace potential_h = potential_h/aamcha

replace potential_l_down = potential_l_down/aamcha
replace potential_h_down = potential_h_down/aamcha

drop aamcha

* Step 5:
reshape wide potential_h potential_l potential_l_unnorm potential_h_unnorm a_radius_ha potential_h_down potential_l_down a_radius_ha_down, i(amc) j(distance)
rename amc AMC

* Save data
save "$pathfiles_data/Workfiles/data_potential_distance.dta", replace
