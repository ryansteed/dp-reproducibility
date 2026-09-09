
clear*
set matsize 11000

use "$pathdata/data_final.dta", clear

xtset AMC year
keep if uf>40
drop if uf==53
gen s_preterm = 1-s_birth_weekspreg_37plus
replace baseline_share_analf = baseline_share_analf/100
replace baseline_share_poor = baseline_share_poor/100

* Gerar delta potencial
gen temp = potentialUpstream if year==2005
	egen potential_high = mean(temp), by(AMC)
	drop temp
gen temp = potentialUpstream if year==2000
	egen potential_low = mean(temp), by(AMC)
	drop temp
gen d_potentialUpstream = potential_high-potential_low
drop potential_high potential_low

* Labels
label var glyph_soy_upstream "Glyphosate Upstream"
label var glyph_soy_downstream "Glyphosate Downstream"
label var glyph_soy_AMC "Glyphosate in AMC"
label var potentialAMC "Potential in AMC"
label var potentialUpstream "Potential Upstream" 
label var potentialDownstream "Potential Downstream"
label var s_areasoy "% Soy Area"
label var  s_lowapgar1 "% Low Apgar 1"
label var  s_lowapgar5 "% Low Apgar 5"
label var s_preterm "% Preterm"
label var s_birth_lowbirthw "% Low Birth Weight"
label var coverage_psf "Coverage PSF"
label var coverage_pbf "Coverage PBF"
label var coverage_vaccination "Coverage Vaccination"
label var IMR "Infant Mortality Rate - IMR"
label var hospital_beds_pc "Hospital Beds per Capita*1000"
label var FMR "Fetal Mortality Rate - FMR"
label var position "Position in Basin"
label var share_GDPagro "Share GDP Agro"
label var d_hosp "Hospital Presence"
label var birth_rate "Birth Rate"

label var r_baby_death_infectious "IMR - Infectious"
label var r_baby_death_respiratory "IMR - Respiratory"
label var r_baby_death_perinatal "IMR - Perinatal"
label var r_baby_death_congenital "IMR - Congenital"
label var r_baby_death_external "IMR - External"
label var r_baby_death_endoc_nut "IMR - Endocrine and Nutritional"
label var r_baby_death_others "IMR - Others"



* Basic descriptives (all years)
order position potentialAMC potentialUpstream potentialDownstream glyph_soy_AMC glyph_soy_upstream glyph_soy_downstream s_areasoy IMR FMR r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_others s_lowapgar1 s_lowapgar5 s_preterm s_birth_lowbirthw coverage_psf coverage_pbf coverage_vaccination l_gdppc d_hosp hospital_beds_pc baseline_share_poprural baseline_theil baseline_share_analf baseline_incomepc baseline_share_poor baseline_share_agri baseline_share_manuf share_GDPagro birth_rate
sum if potentialAMC!=.
outreg2 using "$pathresults/descriptives1.xls", replace sum(log) eqkeep(mean sd min max) label dec(3) keep(position potentialAMC potentialUpstream potentialDownstream glyph_soy_AMC glyph_soy_upstream glyph_soy_downstream s_areasoy IMR FMR r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_others s_lowapgar1 s_lowapgar5 s_preterm s_birth_lowbirthw coverage_psf coverage_pbf coverage_vaccination l_gdppc d_hosp hospital_beds_pc baseline_share_poprural baseline_theil baseline_share_analf baseline_incomepc baseline_share_poor baseline_share_agri baseline_share_manuf share_GDPagro birth_rate)



* Descriptives comparing high vs low position within basins at baseline (2000)

keep if year==2000
keep if potentialAMC!=.
gen position_low =.
replace position_low=1 if  position<=4
replace position_low=0 if  position>=6
label define position_low 1 "Low Position" 0 "High Position"
drop if position_low ==.


outreg2 using "$pathresults/descriptives2.xls", replace sum(log) eqkeep(mean sd min max) label dec(3) keep(position potentialAMC potentialUpstream potentialDownstream glyph_soy_AMC glyph_soy_upstream glyph_soy_downstream s_areasoy IMR FMR r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_others s_lowapgar1 s_lowapgar5 s_preterm s_birth_lowbirthw coverage_psf coverage_pbf coverage_vaccination l_gdppc d_hosp hospital_beds_pc baseline_share_poprural baseline_theil baseline_share_analf baseline_incomepc baseline_share_poor baseline_share_agri baseline_share_manuf share_GDPagro birth_rate)

bysort position_low: outreg2 using "$pathresults/descriptives3.xls", replace sum(log) eqkeep(mean sd) label dec(3) keep(position potentialAMC potentialUpstream potentialDownstream glyph_soy_AMC glyph_soy_upstream glyph_soy_downstream s_areasoy IMR FMR r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_others s_lowapgar1 s_lowapgar5 s_preterm s_birth_lowbirthw coverage_psf coverage_pbf coverage_vaccination l_gdppc d_hosp hospital_beds_pc baseline_share_poprural baseline_theil baseline_share_analf baseline_incomepc baseline_share_poor baseline_share_agri baseline_share_manuf share_GDPagro birth_rate)

foreach i in position potentialAMC potentialUpstream potentialDownstream glyph_soy_AMC glyph_soy_upstream glyph_soy_downstream s_areasoy IMR FMR r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_others s_lowapgar1 s_lowapgar5 s_preterm s_birth_lowbirthw coverage_psf coverage_pbf coverage_vaccination l_gdppc d_hosp hospital_beds_pc baseline_share_poprural baseline_theil baseline_share_analf baseline_incomepc baseline_share_poor baseline_share_agri baseline_share_manuf share_GDPagro birth_rate {
reg `i' position_low, cluster(basin)
outreg2 using "$pathresults/descriptives4.xls",  aster(coef) dec(3) label nocons keep(position_low) addtext(Controls, No, FE, None) 
}
