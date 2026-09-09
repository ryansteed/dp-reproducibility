********************************************************************************
*** Build: Merge intermediary and original datasets into final dataset
********************************************************************************


* Build basic municipality-year panel
do "$pathfiles_do/build_panel.do"


********************************************************************************
* Population, GDP, and other controls
*
* Obs: We ignore some locations that were created and extinguished before 1996
* or after 2010. We also ignore one small municipality called Pinto Bandeira, 
* which only existed for two years as a separate municipality and does not affect
* our analysis.

** Population 0-1 yo
quietly merge 1:1 code_mun year using "$pathfiles_data/Originais/pop0to1.dta"
quietly drop if _merge==2 // drop if year <1996 | year >2010 + Pinto Bandeira
quietly drop _merge


** Population - 1991-2012
merge 1:1 code_mun year using "$pathfiles_data/Originais/pop_br_91to12.dta"
rename pop population
quietly drop _merge


** Fem pop data
quietly merge 1:1 code_mun year using "$pathfiles_data/Originais/POPBRFEM_1049_9610.dta"
quietly drop _merge


** Merge pop per age data
quietly merge 1:1 code_mun year using "$pathfiles_data/Originais/pop_per_age.dta"
quietly drop _merge


drop if year<1998 | year>2010


** Baseline vars from Censo 2000
merge m:1 codmun7 using "$pathfiles_data/Workfiles/data_censo2000.dta"
drop if _m==2
drop _m

** Merge Immunization Coverage Data - 1996-2010
merge 1:1 code_mun year using "$pathfiles_data/Originais/immunization_coverage.dta"
drop if _m==2 // drop Pinto Bandeira and year<1998
drop _merge
* Immunization coverage by AMC: we take the weighted average, weights = pop of each municipality;
* Then multiply coverage for each municipality by population, collapse summing these quantities and, divide by AMCs population
gen mult_coverage_population=(immun_cov*population)/100


** Merge PSF data - 1998-2010
merge 1:1 code_mun year using "$pathfiles_data/Originais/psf.dta"
drop _merge


** Merge Hospital beds data - 1996-2013
merge 1:1 code_mun year using "$pathfiles_data/Originais/hospital_beds.dta"
drop if _merge==2 // drops if year <1998 or >2010
drop _merge


** Merge data from Bolsa Familia - data from IPEADATA - 1996-2013, 2016
merge 1:1 code_mun year using "$pathfiles_data/Originais/pbf.dta", keepusing(pbf)
drop if _merge==2 // drop ignored municipalities
drop _merge


** Merge municipalities' gdp data - 1996, 1999-2010
merge 1:1 code_mun year using "$pathfiles_data/Originais/gdp_mun.dta"
drop if _merge==2 // drop ignored municipalities
drop _merge

drop if year<1998 | year>2010
drop if code_mun==431453 // Pinto Bandeira
tab year
drop uf


** Merge with % GDP Agro (original data from controles.dta, ATFP project) 
merge 1:1 code_mun year using "$pathfiles_data/Originais/controles.dta"
drop if _merge==2 
drop _merge


********************************************************************************
* Health

** SIM
merge 1:1 code_mun year using "$pathfiles_data/Workfiles/SIM_year.dta"
quietly drop if _merge==2 // drop ignored municipalities
foreach i in baby_death baby_death_fetal baby_death_girl baby_death_boy baby_death_24hs baby_death_27days baby_death_year baby_death_infectious baby_death_respiratory baby_death_perinatal baby_death_congenital baby_death_external baby_death_endocrine baby_death_nutrition baby_death_genito baby_death_illdef baby_death_others baby_death_perlenght baby_death_perrespcard baby_death_perinfct baby_death_perhaemor baby_death_perothers baby_death_endoc_nut baby_death_affected { //mat_death_all mat_death_mat
replace `i'=0 if `i'==.
}
drop _m

merge 1:1 code_mun year using "$pathfiles_data/Workfiles/SIM_yearmonth.dta"
quietly drop if _merge==2 // drop ignored municipalities
foreach i in baby_death baby_death_fetal baby_death_girl baby_death_boy baby_death_24hs baby_death_27days baby_death_year baby_death_infectious baby_death_respiratory baby_death_perinatal baby_death_congenital baby_death_external baby_death_endocrine baby_death_nutrition baby_death_genito baby_death_illdef baby_death_others baby_death_perlenght baby_death_perrespcard baby_death_perinfct baby_death_perhaemor baby_death_perothers baby_death_endoc_nut baby_death_affected { //mat_death_all mat_death_mat
	forv m=1/12{
		replace `i'`m'=0 if `i'`m'==.
	}
}
drop _m


** SINASC
merge 1:1 code_mun year using "$pathfiles_data/Workfiles/SINASC_year.dta"
quietly drop if _merge==2 // drop ignored municipalities
replace births=0 if births==.
drop _m

merge 1:1 code_mun year using "$pathfiles_data/Workfiles/SINASC_yearmonth_onlybirths.dta"
quietly drop if _merge==2 // drop ignored municipalities
forv m=1/12{
	replace births`m'=0 if births`m'==.
}
drop _m



********************************************************************************
* Collapse by AMC-year and add more variables

* Drop Pinto Bandeira
drop if code_mun==431453 // Pinto Bandeira

preserve
sort AMC
collapse (sum) pop* baby_d* ///
births* birth_csection birth_female birth_lowbirthw birth_vlowbirthw birth_weekspreg_37plus birth_prenatal_0to6 birth_prenatal_7plus ///
birth_motherage_17below birth_motherage_1019 birth_motherage_18_24 birth_motherage_25_34 birth_motherage_35_44  ///
lowapgar1 lowapgar5 vlowapgar1 vlowapgar5 mat_d* mult_coverage_population pbf psf hosp_beds gdp area ///
(first) code_uf, by(AMC year)
save "$pathfiles_data/temp1.dta", replace
clear
restore


preserve
collapse (mean) birth_motheredclow_mean birth_motheredcvlow_mean birth_motheredcmid_mean birth_motheredchigh_mean birth_motheredcvhigh_mean birth_motherage_mean apgar1_mean apgar5_mean peso_mean gesta_below22 gesta_22_27 gesta_28_36 gesta_37_41 gesta_above42 gesta_missing [w=births], by(AMC year)
save "$pathfiles_data/temp2.dta", replace
clear
restore

preserve
collapse (mean) Theil2000 agua_encanada2000 analfabetos15anos2000 rendapc2000 share_pobres2000 PIB_totalpc PIB_agropc [w=population], by(AMC year)
save "$pathfiles_data/temp3.dta", replace
clear
restore

preserve
collapse (mean) Theil2000 agua_encanada2000 analfabetos15anos2000 rendapc2000 share_pobres2000 longitude latitude [w=area], by(AMC year)
save "$pathfiles_data/temp4.dta", replace
clear
restore


use "$pathfiles_data/temp1.dta", clear
merge 1:1 AMC year using "$pathfiles_data/temp2.dta"
drop _m

merge 1:1 AMC year using "$pathfiles_data/temp3.dta"
drop _m

merge 1:1 AMC year using "$pathfiles_data/temp4.dta"
drop _m


** Merge Census info
merge 1:1 AMC year using "$pathfiles_data/Workfiles/data_census.dta"
drop _merge


** Merge sub-basins information
merge 1:1 AMC year using "$pathfiles_data/Workfiles/data_glyph_pot_subbasins.dta"
drop if _merge==2 // 1996 and 1997 in using dataset
drop _merge

** Merge glyph and potential by distance information
merge 1:1 AMC year using "$pathfiles_data/Workfiles/data_glyph_distance.dta" // many _m==1 are years pre-2000; others are the same as in other merges
drop _merge 
merge m:1 AMC using "$pathfiles_data/Workfiles/data_potential_distance.dta"
drop _merge 

** Merge rain
merge 1:1 AMC year using "$pathfiles_data/Workfiles/data_rain_subbasins.dta"
drop if _merge==2 // again, 1996 and 1997
drop _merge 

** Merge soil
merge 1:1 AMC year using "$pathfiles_data/Workfiles/data_soil_subbasins.dta" // using data doesn't have 1998 and 1999, thus the high number of _m==1
drop _merge 

** Merge soil coverage data - Mapbiomas (2000-2010)
merge 1:1 AMC year using "$pathfiles_data/Workfiles/data_soil_coverage_mapbiomas_v3.dta"
drop _merge // Most _merge==1 are years before 2000; the others correspond to the island of Fernando de Noronha (not in Mapbiomas database and not relevant for our analysis)

** Merge water sources data
merge m:1 AMC using "$pathfiles_data/Workfiles/data_watersources.dta"
drop _merge // data only for relevant states, i.e., in South and Center-West regions


** Merge water quality data
merge 1:1 AMC year using "$pathfiles_data/Workfiles/data_water_quality.dta" // _m==2: 1996 and 1997
drop _merge

* Restrict to relevant years (2000-2010)
drop if year<2000 


********************************************************************************
* Create POTENTIAL BY DISTANCE instruments

forv x=1/4{
	local v=50000*`x'
	gen potentialDist`v' = potential_l`v'
	replace potentialDist`v' = potential_h`v' if year>=2004
	
	gen potentialDistUnnorm`v' = potential_l_unnorm`v'
	replace potentialDistUnnorm`v' = potential_h_unnorm`v' if year>=2004
	
	gen d_potentialDist`v' = potential_l`v' - potential_l_down`v'
	replace d_potentialDist`v' = potential_h`v' - potential_h_down`v' if year>=2004
	
	gen potentialDistDown`v' = potential_l_down`v'
	replace potentialDistDown`v' = potential_h_down`v' if year>=2004
}

********************************************************************************
* Create HEALTH variables after collapsing

** Infant Mortality
foreach i in baby_death_24hs baby_death_27days baby_death_year baby_death_infectious baby_death_respiratory baby_death_perinatal baby_death_congenital baby_death_external baby_death_endocrine baby_death_nutrition baby_death_genito baby_death_illdef baby_death_others baby_death_perlenght baby_death_perrespcard baby_death_perinfct baby_death_perhaemor baby_death_perothers baby_death_endoc_nut baby_death_affected {
gen r_`i' = (`i'/births)*1000
}
gen IMR = 1000 * (baby_death/births)
gen IMR_fem=1000 * (baby_death_girl/birth_female)
gen IMR_masc=1000 * (baby_death_boy/(births - birth_female))
gen FMR = 1000 * baby_death_fetal/(births + baby_death_fetal)
gen sex_ratio=birth_female/(births - birth_female)

gen IMR_highexp=1000 * (baby_death3+baby_death4+baby_death5+baby_death6)/(births3+births4+births5+births6)
gen IMR_lowexp=1000 * (baby_death1+baby_death2+baby_death7+baby_death8+baby_death9+baby_death10+baby_death11+baby_death12)/(births1+births2+births7+births8+births9+births10+births11+births12)


/** Maternal Mortality
foreach i in mat_death_all mat_death_mat {
gen r_`i' = (`i'/pop_fem)*1000
}*/

** Births
gen birth_rate = births/pop_fem
gen l_births=log(births + 0.01)
foreach i in birth_prenatal_0to6 birth_prenatal_7plus birth_csection birth_female birth_lowbirthw birth_vlowbirthw birth_weekspreg_37plus lowapgar1 lowapgar5 birth_motheredclow {
gen s_`i' = `i' / births
}


********************************************************************************
* Create CONTROL variables after collapsing


** PSF
gen coverage_psf = psf/population
replace coverage_psf = 1 if coverage_psf>1
gen d_psf=.
replace d_psf=1 if psf>0
replace d_psf=0 if psf==0
label variable d_psf "Dummy for Family Health Program presence"


** PBF
gen coverage_pbf = pbf/population
replace coverage_pbf = 1 if coverage_pbf>1
gen d_pbf=.
replace d_pbf=1 if pbf>0
replace d_pbf=0 if pbf==0
label variable d_pbf "Dummy for Family Allowance Program presence"


** Immunization
gen coverage_vaccination = mult_coverage_population/population
replace coverage_vaccination = 1 if coverage_vaccination>1


** Log GDP per capita and % agro
gen l_gdppc=log(gdp/population)
label variable l_gdppc "Log of GDP per capita"

gen share_GDPagro = PIB_agropc/ PIB_totalpc
label var share_GDPagro "Share of GDP Agro" 


** Hospital beds
gen hospital_beds_pc = (hosp_beds/population)*1000
gen l_hospbedspc=log((hosp_beds/population)+1)


* Dummy for hospital
gen d_hosp=(hosp_beds>0)


** Census: net migration rates for 2000-2010
gen net_migration_rate = net_migrants / population if year==2010


** Baseline vars
gen tag = IMR if year==2000
egen baseline_IMR = mean(tag), by(AMC)
label var baseline_IMR "Baseline IMR (/births in 2000)"
drop tag

gen tag = poprural2000 / population if year == 2000
egen baseline_share_poprural = mean(tag), by(AMC)
label var baseline_share_poprural "Baseline % Rural Pop (in 2000)"
drop tag

gen tag = Theil2000 if year==2000
egen baseline_theil = mean(tag), by(AMC)
drop Theil2000 tag
label var baseline_theil "Baseline Theil Index (in 2000)"

gen tag = agua_encanada2000 if year==2000
egen baseline_share_piped = mean(tag), by(AMC)
drop agua_encanada2000 tag
label var baseline_share_piped "Baseline % People in HH w/ Piped Water (in 2000)"

gen tag = analfabetos15anos2000 if year==2000
egen baseline_share_analf = mean(tag), by(AMC) 
drop analfabetos15anos2000 tag   
label var baseline_share_analf "Baseline % Illiterate (15yo+, in 2000)"

gen tag = rendapc2000 if year==2000
egen baseline_incomepc = mean(tag), by(AMC)  
drop rendapc2000 tag
label var baseline_incomepc "Baseline Income Per Capita (in 2000)" 

gen tag = share_pobres2000 if year==2000
egen baseline_share_poor = mean(tag), by(AMC) 
drop share_pobres2000 tag 
label var baseline_share_poor "Baseline Poverty Rate (in 2000)"

gen tag = empl_share_agr if year==2000
egen baseline_share_agri = mean(tag), by(AMC)
drop tag
label var baseline_share_agri "Baseline Share Agri Employment (in 2000)"

gen tag = empl_share_manuf if year==2000
egen baseline_share_manuf = mean(tag), by(AMC)
drop tag
label var baseline_share_manuf "Baseline Share Manuf Employment (in 2000)"


* Soil Coverage Variables
gen totalAreaAMCha = areaForest+areaNatNonForest+areaFarming+areaNonVeg+areaTotalWater+areaNonObs
foreach var in areaForest areaNatNonForest areaFarming areaAgriculture areaPasture areaAgricOrPast areaNonVeg areaUrban areaOtherNonVeg areaTotalWater areaWater areaAquiculture areaNonObs{
	* Replace missings in these variables, correspondent to non-observation of some class
	replace `var'=0 if `var'==.
	* Generate proportions
	gen share_`var'=`var'/totalAreaAMCha
}

********************************************************************************
* Final coding

** Weights
sort AMC
by AMC: egen weight=mean(births)

** Rename state variable
rename code_uf uf

** Generate and adjust some variables
* Adjust scale of potential variables
foreach x in potentialSubotto2004 potentialAMC2004 potentialDownstream2004 potentialMze2004 ///
potentialMzeAMC2004 potentialSubottoUnnorm2004 potentialAMCUnnorm2004 ///
potentialDist50000 potentialDist100000 potentialDist150000 potentialDist200000 ///
potentialDistDown50000 potentialDistDown100000 potentialDistDown150000 potentialDistDown200000 {
replace `x'=`x'/10
}

* Guarantee that the glyph variables that we want to be zero until 2003 are really zero
replace glyph_soy_subbasin8_km2=0 if year<=2003
replace glyph_soy_subbasin4_km2=0 if year<=2003

* Generate sum variables
gen sum_glyph = glyph_soy_subbasin7_km2 + glyph_soy_downstream7_km2
gen sum_pot = potentialSubotto2004 + potentialDownstream2004


** Rename some variables
rename potentialSubotto2004 potentialUpstream
rename potentialAMC2004 potentialAMC
rename potentialDownstream2004 potentialDownstream

rename glyph_soy_subbasin7_km2 glyph_soy_upstream
rename glyph_soy_subbasin10_km2 glyph_soy_upstream_herbicides
rename glyph_soy_subbasin8_km2 glyph_soy_upstream_0until2003
rename glyph_soy_subbasin5_km2 glyph_soy_upstream_distrsoy
rename glyph_soy_subbasin4_km2 glyph_soy_upstream_0til03distsoy

rename glyph_soy_AMC7_km2 glyph_soy_AMC

rename glyph_soy_downstream7_km2 glyph_soy_downstream

rename area_mze_upstream area_corn_upstream
rename area_mze_AMC area_corn_AMC
rename potentialMze2004 potentialCornUpstream
rename potentialMzeAMC2004 potentialCornAMC

rename a_radius_ha50000 a_up_radius_50km
rename a_radius_ha100000 a_up_radius_100km
rename a_radius_ha150000 a_up_radius_150km
rename a_radius_ha200000 a_up_radius_200km

rename potentialDist50000 potentialUpstream50km
rename potentialDist100000 potentialUpstream100km
rename potentialDist150000 potentialUpstream150km
rename potentialDist200000 potentialUpstream200km

rename potentialDistDown50000 potentialDownstream50km
rename potentialDistDown100000 potentialDownstream100km
rename potentialDistDown150000 potentialDownstream150km
rename potentialDistDown200000 potentialDownstream200km

rename glyph_up50000 glyph_up50km
rename glyph_up100000 glyph_up100km
rename glyph_up150000 glyph_up150km
rename glyph_up200000 glyph_up200km

rename d_man_sup d_source_surface
rename d_man_sub d_source_undergr
rename d_man_mixed d_source_mixed


* Exclude glyph variables we are not going to use
drop glyph_soy_subbasin*_km2 glyph_soy_downstream*_km2 glyph_soy_AMC*_km2 mult_coverage_population longitude latitude potentialMzeDownstream2004 potentialSubottoUnnorm2004 A_soy_h A_soy_l A_mze_h A_mze_l potentialAMCUnnorm2004 glyph_down50000 glyph_down100000 glyph_down150000 glyph_down200000 potential_l50000 potential_h50000 potential_l_unnorm50000 potential_h_unnorm50000 potential_l_down50000 potential_h_down50000 a_radius_ha_down50000 potential_l100000 potential_h100000 potential_l_unnorm100000 potential_h_unnorm100000 potential_l_down100000 potential_h_down100000 a_radius_ha_down100000 potential_l150000 potential_h150000 potential_l_unnorm150000 potential_h_unnorm150000 potential_l_down150000 potential_h_down150000 a_radius_ha_down150000 potential_l200000 potential_h200000 potential_l_unnorm200000 potential_h_unnorm200000 potential_l_down200000 potential_h_down200000 a_radius_ha_down200000 MunicipioResultadoFinal potentialDistUnnorm50000 potentialDistUnnorm100000 potentialDistUnnorm150000 potentialDistUnnorm200000 d_potentialDist50000 d_potentialDist100000 d_potentialDist150000 d_potentialDist200000

* Labels
label var a_up_radius_50km "Area: Upstream, dist<=50km"
label var a_up_radius_100km "Area: Upstream, 50km<dist<=100km"
label var a_up_radius_150km "Area: Upstream, 100km<dist<=150km"
label var a_up_radius_200km "Area: Upstream, 150km<dist<=200km"

label var potentialUpstream "Instrument: Upstream"
label var potentialAMC "Instrument: Direct Effect"
label var potentialDownstream "Instrument: Downstream"
label var potentialUpstream50km "Instrument: Upstream, dist<=50km"
label var potentialUpstream100km "Instrument: Upstream, 50km<dist<=100km"
label var potentialUpstream150km "Instrument: Upstream, 100km<dist<=150km"
label var potentialUpstream200km "Instrument: Upstream, 150km<dist<=200km"
label var potentialDownstream50km "Instrument: Downstream, dist<=50km"
label var potentialDownstream100km "Instrument: Downstream, 50km<dist<=100km"
label var potentialDownstream150km "Instrument: Downstream, 100km<dist<=150km"
label var potentialDownstream200km "Instrument: Downstream, 150km<dist<=200km"

label var glyph_soy_upstream "Glyphosate Upstream"
label var glyph_soy_upstream_herbicides "Glyph Up: Imputation using herbicides"
label var glyph_soy_upstream_0until2003 "Glyph Up: 0 until 2003, marginal glyph allocated using soy"
label var glyph_soy_upstream_distrsoy "Glyph Up: total glyph allocated using soy"
rename glyph_soy_upstream_0til03distsoy glyph_soy_up_0til03distsoy  // Name is ok here, but we run into problems later due to the size of the name string
label var glyph_soy_up_0til03distsoy "Glyph Up: 0 until 2003, total glyph allocated using soy"

label var glyph_up50km "Glyphosate: Upstream, dist<=50km"
label var glyph_up100km "Glyphosate: Upstream, 50km<dist<=100km"
label var glyph_up150km "Glyphosate: Upstream, 100km<dist<=150km"
label var glyph_up200km "Glyphosate: Upstream, 150km<dist<=200km"

label var glyph_soy_AMC "Glyphosate: AMC"

label var glyph_soy_downstream "Glyphosate Downstream"

label var sum_glyph "Glyphosate Sum Up-Down"
label var sum_pot "Potential Sum Up-Down"

label var area_corn_upstream "Area Corn Upstream"
label var area_corn_AMC "Area Corn in AMC"
label var potentialCornUpstream "Potential Corn Upstream"
label var potentialCornAMC "Potential Corn in AMC"

label var d_source_surface "Dummy, Water Source: Surface Water"
label var d_source_undergr "Dummy, Water Source: Underground Water"
label var d_source_mixed "Dummy, Water Source: Mixed"

label var IMR "IMR"
label var r_baby_death_24hs "IMR: 24h"
label var r_baby_death_27days "IMR: 24h to 27 days" 
label var r_baby_death_year "IMR: 27 days to 1 year" 
label var r_baby_death_infectious "IMR: Infectious"
label var r_baby_death_respiratory "IMR: Respiratory" 
label var r_baby_death_perinatal "IMR: Perinatal"
label var r_baby_death_congenital "IMR: Congenital"
label var r_baby_death_external "IMR: External"
label var r_baby_death_endoc_nut "IMR: Endocrine-Nutritional"
label var r_baby_death_genito "IMR: Genito-Urinary"
label var r_baby_death_illdef "IMR: Ill-defined"
label var r_baby_death_others "IMR: Others"
label var FMR "FMR"
label var s_birth_lowbirthw "Share Low Birth Weight"
label var s_birth_weekspreg_37plus "Share Birth 37+ Weeks"
label var birth_motheredcvlow_mean "Mother Education: No education"
label var birth_motheredclow_mean "Mother Education: 0-3 years"
label var birth_motheredcmid_mean "Mother Education: 4-7 years"
label var birth_motheredchigh_mean "Mother Education: 8+ years"
label var birth_motheredcvhigh_mean "Mother Education: 12+ years"


** Save
compress
xtset AMC year
save "$pathfiles_data/Workfiles/data_final.dta", replace


erase "$pathfiles_data/temp1.dta"
erase "$pathfiles_data/temp2.dta"
erase "$pathfiles_data/temp3.dta"
erase "$pathfiles_data/temp4.dta"

