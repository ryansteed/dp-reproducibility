capture log close
log using online_appendix_table4_aej, replace text

// Project: Voting Paper
// Task: Migration, OLS regressions
// Author and Date: Yiming Li (Paul), 2012-11-13

version 12.1
clear all
macro drop _all
set matsize 2000
set more off
ssc install estout, replace

use data/voting_paper_cleaned.dta, clear
xtset fips year

//------------------------------------------------------------------------------
// Merge migration data and generate share variables
//------------------------------------------------------------------------------

keep fips year coalstate oilstate fipsst *1974
drop if year!=1980 & year!=1990
drop if oilstate==0 & coalstate==0
collapse fipsst *1974, by(fips year)

sort fips
forvalues i = 1970(10)1990 {
	merge m:1 fips using data/mobility`i'.dta, keepusing(mobility*)
	drop if _merge==2
	drop _merge
	
	// Generate share of county's residents living outside county
	// and outside state five years before
	gen outcnty_share`i' = ///
		(mobility_same_state_5up_`i' + mobility_outstate_5up_`i')/ mobility_tot_pop_5up_`i'
	gen outstate_share`i' = mobility_outstate_5up_`i' / mobility_tot_pop_5up_`i'
}

gen d_outcnty_70to80 = outcnty_share1980 - outcnty_share1970 if year==1980
gen d_outcnty_80to90 = outcnty_share1990 - outcnty_share1980 if year==1990
gen d_outstate_70to80 = outstate_share1980 - outstate_share1970 if year==1980
gen d_outstate_80to90 = outstate_share1990 - outstate_share1980 if year==1990

//------------------------------------------------------------------------------
// OLS regressions
//------------------------------------------------------------------------------

foreach i in "outcnty" "outstate" {
	// 1970 to 1980
	tab fipsst if d_`i'_70to80 !=., gen(statev)
	eststo: reg d_`i'_70to80 medium_coal_1974 large_coal_1974 medium_og_1974 ///
		large_og_1974 statev* if year==1980 [aw=mobility_tot_pop_5up_1980], cluster(fipsst)
	test medium_coal_1974 large_coal_1974 medium_og_1974 large_og_1974
	drop statev*
	
	// 1980 to 1990
	tab fipsst if d_`i'_80to90 !=., gen(statev)
	eststo: reg d_`i'_80to90 medium_coal_1974 large_coal_1974 medium_og_1974 ///
		large_og_1974 statev* if year==1990 [aw=mobility_tot_pop_5up_1990], cluster(fipsst)
	test medium_coal_1974 large_coal_1974 medium_og_1974 large_og_1974
	drop statev*
}


//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------

esttab using "online_appendix_table4_aej.html", replace keep(*1974) nostar b(3) se(3) ///
	alignment(center) width(60%) nolz
	
log close
