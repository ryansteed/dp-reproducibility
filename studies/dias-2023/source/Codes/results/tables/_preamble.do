*
*
clear

use "$pathdata/data_final.dta", clear
*** EDITED by Ryan Steed
xtset AMC year
***

rename coverage_vaccination vaccination_coverage
set matsize 11000
set more off, perm


*
global glyph_up "glyph_soy_upstream"
global glyph_down "glyph_soy_downstream"
global glyph_amc "glyph_soy_AMC"
global instr "potentialUpstream" 
global no_control "int_uf* [w=weight]"
global control_no_potential "l_gdppc hospital_beds_pc d_hosp coverage_psf coverage_pbf share_GDPagro int_uf* [w=weight]"
global control "potentialAMC l_gdppc hospital_beds_pc d_hosp coverage_psf coverage_pbf share_GDPagro int_uf* [w=weight]"
global control_trendSocioecon "potentialAMC i.year*baseline_share_poprural i.year*baseline_share_poor i.year*baseline_theil i.year*ln_baseline_incomepc l_gdppc hospital_beds_pc d_hosp coverage_psf coverage_pbf share_GDPagro int_uf_* [w=weight]"
global control_trendSocioeconBirth "potentialAMC i.year*baseline_birth_rate i.year*baseline_share_poprural i.year*baseline_share_poor i.year*baseline_theil i.year*ln_baseline_incomepc l_gdppc hospital_beds_pc d_hosp coverage_psf coverage_pbf share_GDPagro int_uf_* [w=weight]"
global controls_landuse "coverage_psf coverage_pbf l_gdppc l_hospbedspc baseline_IMR baseline_share_poprural baseline_theil baseline_share_analf ln_baseline_incomepc baseline_share_poor baseline_share_agri baseline_share_manuf"	
*
 
*
global table_main "tab2_main_spec.xls"
global table_first "tab3_first_stage_S&CO.xls"
global table_other_outcomes "tab4_other_outcomes_S&CO.xls"
global table_trends "tab5_trends_S&CO.xls"
global table_other_trends "tab5_other_outcomes_S&CO_baseline_trends.xls"
global table_placebo_main "tab6_placebo_main_S&CO.xls"
global table_heterogeneities "tab7_heterogeneities_rain_erosion_source.xls"
global table_did_exposure "tab8_results_DiD_exposure.xls"
global table_soil_use "tab9_soil_use_reduced.xls"
global table_sum "tabC1_robustness_sum_RF&OLS&IV.xls"
global table_sum_other "tabC2_robustness_sum_other_outcomes_RF.xls"
global table_alt_glyph "tabE1_main_spec_alt_glyph.xls"
global table_no_top "tabE2_no_top_munics_S&CO.xls"
global table_placebo_other "tabE3_placebo_other_outcomes.xls"
global table_area_inter "tabE4_results_area_interaction.xls"
global table_distance "tabE5_results_by_distance.xls"
global table_distance_iv "tabE5_results_by_distance_IV.xls"
global table_maize_first "tabE7_robustness_maize_first_stage.xls"
global table_bod_balanced "tabE9_bod_balanced_2003.xls"
global table_main_bodsample "tabE9_main_BODsample_balanced_2003.xls"
*



* Restrict sample to soy-producing regions
keep if uf==41|uf==42|uf==43|uf==50|uf==51|uf==52

*
gen ln_baseline_incomepc = ln(baseline_incomepc)
drop baseline_incomepc

*
egen temp = group(year uf)
	tab temp, gen(int_uf_)
	drop temp

*
gen temp = potentialUpstream if year==2005
	egen potential_high = mean(temp), by(AMC)
	drop temp
gen temp = potentialUpstream if year==2000
	egen potential_low = mean(temp), by(AMC)
	drop temp
gen dpotentialUpstream = potential_high-potential_low
drop potential_high potential_low
label var dpotentialUpstream "{&Delta}Potential Upstream"

gen temp = potentialAMC if year==2005
	egen potentialAMCAll = mean(temp), by(AMC)
	drop temp
gen temp = potentialDownstream if year==2005
	egen potentialDowsntreamAll = mean(temp), by(AMC)
	drop temp
gen temp = IMR if year==2000
	drop baseline_IMR
	egen baseline_IMR = mean(temp), by(AMC)
	drop temp
gen temp = birth_rate if year==2000
	egen baseline_birth_rate = mean(temp), by(AMC)
	drop temp


*	
xtile rainOctMar_quart = rain_oct_mar_subbasin, n(4)

tab rainOctMar_quart, gen(rainOctMar_quartile_)
foreach i in 2 3 4{
	gen rainOctMar_quartile`i'_instr = rainOctMar_quartile_`i'*$instr
	label var rainOctMar_quartile`i'_instr "Rain OctMar Quartile `i' * Instrument"
}


gen inter_rainAMC = rain_year_AMC_subbasin*potentialAMC
gen inter_rainSubotto = rain_year_subbasin*$instr
gen inter_rain_OctMarchSubotto = rain_oct_mar_subbasin*$instr


*	
gen pneP_c3_AMC_subbasin = 1 - pneP_c1_AMC_subbasin - pneP_c5_AMC_subbasin
foreach i in pneP_c1_AMC_subbasin pneP_c3_AMC_subbasin pneP_c5_AMC_subbasin {
gen int_`i' = `i'*potentialAMC
}

foreach i in  pne_mean_AMC_subbasin {
gen int_`i' = `i'*potentialAMC
}

gen pneP_c3_subbasin = 1 - pneP_c1_subbasin - pneP_c5_subbasin
foreach i in pneP_c1_subbasin pneP_c3_subbasin pneP_c5_subbasin  {
gen int_`i' = `i'*$instr
}
foreach i in  pne_mean_subbasin {
gen int_`i' = `i'*$instr
}

label var int_pneP_c1_AMC_subbasin "% PNE<200 in AMC * Potential"
label var int_pneP_c3_AMC_subbasin "% 200<PNE<1600 in AMC * Potential"
label var int_pneP_c5_AMC_subbasin "% PNE>1600 in AMC * Potential"
label var int_pne_mean_AMC_subbasin "% Average PNE in AMC * Potential"

label var int_pneP_c1_subbasin "% PNE<200 Upstream * Instrument"
label var int_pneP_c3_subbasin "% 200<PNE<1600 Upstream * Instrument"
label var int_pneP_c5_subbasin "% PNE>1600 Upstream * Instrument"
label var int_pne_mean_subbasin "Average PNE Upstream * Instrument"

*
foreach source in surface undergr{
	gen `source'_instr = d_source_`source' * $instr
	gen `source'_glyph = d_source_`source' * $glyph_up
}
label var surface_instr "Surface water * instrument"
label var undergr_instr "Underground water * instrument"
label var surface_glyph "Surface water * glyphosate"
label var undergr_glyph "Underground water * glyphosate"
* 


* Adjust names and labels of gestational length variables
gen s_gesta_preterm = gesta_below22+gesta_22_27+gesta_28_36
foreach x in below22 22_27 28_36 37_41 above42{
	rename gesta_`x' s_gesta_`x'
}


label var s_gesta_preterm "Share Preterm"
label var s_gesta_below22 "Share Births: <22w"
label var s_gesta_22_27 "Share Births: 22-27w"
label var s_gesta_28_36 "Share Births: 28-36w"
label var s_gesta_37_41 "Share Births: 37-41w"
label var s_gesta_above42 "Share Births: 42+w"


label var s_lowapgar1 "Share Low APGAR 1"
label var s_lowapgar5 "Share Low APGAR 5"
label var IMR_masc "IMR Males"
label var IMR_fem "IMR Females"
label var sex_ratio "Sex Ratio"
label var l_births "Log(Births)"
label var birth_rate "Birth Rate"
label var birth_motheredclow_mean "Mother Education: 0-3 years"
label var birth_motheredcmid_mean "Mother Education: 4-7 years"
label var birth_motheredchigh_mean "Mother Education: 8+ years"
label var birth_motherage_mean "Mean Age of Mother"

*
* Adjust normalization of area upstream
gen area_upstream = area_upstream_ha/1000000
