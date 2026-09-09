********************************************************************************
*** Build: Census spillovers dataset (not included in main datasets)  
********************************************************************************

clear*
use "$pathfiles_data/Workfiles/data_final.dta", clear


gen pop_d = population / a_amc_ha if year==2000
egen tag = mean(pop_d), by(AMC)
gen baseline_lpopdensity = ln(tag)
label var baseline_lpopdensity "Baseline Lop Pop Density (in 2000)"
gen hospital = (hosp_beds>0)
gen share_gdp_agri =  PIB_agropc / PIB_totalpc



keep year AMC basin IMR l_births s_areasoy s_areacorn population potentialAMC potentialUpstream potentialDownstream sum_pot glyph_soy_AMC glyph_soy_upstream glyph_soy_downstream baseline_IMR baseline_share_poprural baseline_theil baseline_share_analf baseline_incomepc baseline_share_poor baseline_share_agri baseline_share_manuf coverage_psf coverage_pbf l_gdppc l_hospbedspc position hospital share_gdp_agri baseline_lpopdensity
keep if year==2000 | year==2010
replace year=2009 if year==2000


gen log_pop=log(population)
 

xtset AMC year

foreach x in potentialUpstream potentialAMC potentialDownstream sum_pot{
replace `x'=`x'*100
} // rescale potentials to make them comparable to Bustos et al.
 
 
foreach i in IMR l_births log_pop s_areasoy s_areacorn sum_pot potentialAMC potentialUpstream potentialDownstream glyph_soy_AMC glyph_soy_upstream glyph_soy_downstream coverage_psf coverage_pbf l_gdppc l_hospbedspc hospital share_gdp_agri {
gen d`i' = d.`i'
}


keep if year==2010
tempfile tempspillovers
save `tempspillovers'
clear



use "$pathfiles_data/Originais/Bustos et al/APST_AMC.dta"
merge 1:1 year AMC using `tempspillovers'
drop _m


keep if year==2000 | year==2010
replace year=2009 if year==2000
xtset AMC year

foreach i in migration_rate log_pop_area {
gen d`i' = d.`i'
}

foreach i in  dpotentialAMC dpotentialUpstream dpotentialDownstream dsum_pot{
*egen m_`i'=mean(`i'), by(AMC)
replace `i' = `i'/100
}


label var dglyph_soy_upstream "Glyphosate Upstream"
label var dglyph_soy_downstream "Glyphosate Downstream"
label var dglyph_soy_AMC "Glyphosate in AMC"
label var dpotentialAMC "Potential in AMC"
label var dpotentialUpstream "Potential Upstream" 
label var dpotentialDownstream "Potential Downstream"
label var dsum_pot "Potential Sum Up-Down"

label var dLa_L "Change in Agri Employment"
label var dLm_L  "Change in Manuf Employment"
label var dlog_y  "Change in Income pc"
label var dmigration_rate  "Change in Migration Rate"
label var dlog_pop  "Change in Popupation"
label var ds_areasoy "Change in Soy Area"
label var ds_areacorn "Change in Corn Area"



save "$pathfiles_data/Workfiles/data_spillovers_censo.dta", replace
clear


