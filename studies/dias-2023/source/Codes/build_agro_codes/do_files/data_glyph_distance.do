********************************************************************************
*** Build: Glyphosate by distance dataset
********************************************************************************

** Obs: needs data_herb_subbasins.dta

forv y=2000/2010{
* Preamble and path to files (Mateus)
clear

* Prepare soy potential data
use "$pathfiles_data/Workfiles/data_glyph_pot_subbasins.dta", clear

* Choose which glyph variable to use
// replace glyph_soy_AMC4_km2=0 if year<=2003 // Only if using glyph_4=0 before 2004 
keep AMC year glyph_soy_AMC7_km2
keep if year==`y'
rename AMC amc_2
rename glyph_soy_AMC7_km2 glyph_amc

tempfile glyphdata`y'
save `glyphdata`y''

*
clear
import delimited using "$pathfiles_data/Originais/intersections.csv", varnames(1)

merge m:1 amc_2 using `glyphdata`y''
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

gen glyph_up = glyph_amc*ainterha*(basin==basin_2 & subbasin_2>subbasin & amc!=amc_2)
gen area_inter_ha = ainterha*(basin==basin_2 & subbasin_2>subbasin & amc!=amc_2)

gen glyph_down = glyph_amc*ainterha*(basin==basin_2 & subbasin_2<subbasin & amc!=amc_2)
gen area_inter_ha_down = ainterha*(basin==basin_2 & subbasin_2<subbasin & amc!=amc_2)

* Step 2:
collapse (sum) glyph_up a_radius_ha=area_inter_ha glyph_down a_radius_ha_down=area_inter_ha_down (firstnm) acrossha a_amc_ha, by(amc otto4 distance)

* Step 3:
replace glyph_up = acrossha * glyph_up/a_radius_ha
replace glyph_up = 0 if a_radius_ha==0

replace glyph_down = acrossha * glyph_down/a_radius_ha_down
replace glyph_down = 0 if a_radius_ha_down==0

* Step 4:
collapse (sum) glyph_up glyph_down aamcha=acrossha , by(amc distance)

replace glyph_up = glyph_up/aamcha
replace glyph_down = glyph_down/aamcha
drop aamcha

* Step 5:
reshape wide glyph_up glyph_down, i(amc) j(distance)
rename amc AMC
gen year = `y'

* Save data
tempfile dataglyph`y'
save `dataglyph`y''
}

clear
use `dataglyph2000'
forv y=2001/2010{
	append using `dataglyph`y''
}

save "$pathfiles_data/Workfiles/data_glyph_distance.dta", replace
