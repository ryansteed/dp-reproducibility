capture log close
log using table6_aej, replace text

// Project: voting paper
// Task: Roll-off analysis
// Author and Date: Yiming Li (Paul), 2012-11-13

version 12.1
clear all
set matsize 2000
macro drop _all
set more off

use "data/voting_paper_cleaned.dta", clear
xtset fips year

//------------------------------------------------------------------------------
// "President - Congress" roll-off analysis
//------------------------------------------------------------------------------

gen samplePres1 = year>=1969 & year<=2000 & rf_pres_congr!=. ///
		& lper_earn!=. & lper_emp!=.
gen samplePres2 = samplePres1 & (oilstate==1 | coalstate==1) & year<=1990
gen samplePres3 = year>=1969 & year<=2000 & pres_d_rf_pres_congr!=. ///
		& pres_d_lper_earn!=. & pres_d_lper_emp!=.
gen samplePres4 = samplePres3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_pres_congr [aw=nadults] if samplePres1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if samplePres3==1, gen(stateyrv)
	eststo: ///
		reg pres_d_rf_pres_congr pres_d_lper_`j' ///
			pres_d_lpop pres_d_sh* stateyrv* ///
			if samplePres3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*

//------------------------------------------------------------------------------
// "President - State House" roll-off analysis
//------------------------------------------------------------------------------

gen samplePres1 = year>=1969 & year<=2000 & rf_pres_st!=. & presobs==1 ///
	& lper_earn!=. & lper_emp!=.
gen samplePres2 = samplePres1 & (oilstate==1 | coalstate==1) & year<=1990
gen samplePres3 = year>=1969 & year<=2000 & pres_d_rf_pres_st!=. & presobs==1 ///
	& pres_d_lper_earn!=. & pres_d_lper_emp!=.
gen samplePres4 = samplePres3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_pres_st [aw=nadults] if samplePres1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if samplePres3==1, gen(stateyrv)
	eststo: ///
		reg pres_d_rf_pres_st pres_d_lper_`j' pres_d_lpop pres_d_sh* stateyrv* ///
			if samplePres3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*

//------------------------------------------------------------------------------
// "Governor - State House" roll-off analysis
//------------------------------------------------------------------------------

gen sampleGov1 = year>=1969 & year<=2000 & rf_gov_st!=. & govobs==1 ///
	& lper_earn!=. & lper_emp!=.
gen sampleGov2 = sampleGov1 & (oilstate==1 | coalstate==1) & year<=1990
gen sampleGov3 = year>=1969 & year<=2000 & gov_d_rf_gov_st!=. & govobs==1 ///
	& gov_d_lper_earn!=. & gov_d_lper_emp!=.
gen sampleGov4 = sampleGov3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_gov_st [aw=nadults] if sampleGov1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if sampleGov3==1, gen(stateyrv)
	eststo: ///
		reg gov_d_rf_gov_st gov_d_lper_`j' gov_d_lpop gov_d_sh* stateyrv* ///
		if sampleGov3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*

//------------------------------------------------------------------------------
// #4
// "Senate - State House" roll-off analysis, 6-yr diffs
//------------------------------------------------------------------------------

gen sampleSen1 = (year>=1969 & year<=2000) & rf_sen_st!=. ///
	& (lper_earn!=. & lper_emp!=.)
gen sampleSen2 = sampleSen1 & (oilstate==1 | coalstate==1) & year<=1990
gen sampleSen3 = (year>=1969 & year<=2000) & sen6_d_rf_sen_st!=. ///
	& (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.)
gen sampleSen4 = sampleSen3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_sen_st [aw=nadults] if sampleSen1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if sampleSen3==1, gen(stateyrv)
	eststo: ///
		reg sen6_d_rf_sen_st sen6_d_lper_`j' sen6_d_lpop sen6_d_sh* stateyrv* ///
		if sampleSen3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*

//------------------------------------------------------------------------------
// #5
// "President - Governor" roll-off analysis
//------------------------------------------------------------------------------

gen samplePres1 = year>=1969 & year<=2000 & rf_pres_gov!=. & presobs==1 ///
	& lper_earn!=. & lper_emp!=.
gen samplePres2 = samplePres1 & (oilstate==1 | coalstate==1) & year<=1990
gen samplePres3 = year>=1969 & year<=2000 & pres_d_rf_pres_gov!=. & presobs==1 ///
	& pres_d_lper_earn!=. & pres_d_lper_emp!=.
gen samplePres4 = samplePres3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_pres_gov [aw=nadults] if samplePres1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if samplePres3==1, gen(stateyrv)
	eststo: ///
		reg pres_d_rf_pres_gov pres_d_lper_`j' pres_d_lpop pres_d_sh* stateyrv* ///
			if samplePres3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*

//------------------------------------------------------------------------------
// #6
// "President - Senate" roll-off analysis, 4-yr diffs
//------------------------------------------------------------------------------

gen samplePres1 = year>=1969 & year<=2000 & rf_pres_sen!=. & presobs==1 ///
	& lper_earn!=. & lper_emp!=.
gen samplePres2 = samplePres1 & (oilstate==1 | coalstate==1) & year<=1990
gen samplePres3 = year>=1969 & year<=2000 & pres_d_rf_pres_sen!=. & presobs==1 ///
	& pres_d_lper_earn!=. & pres_d_lper_emp!=.
gen samplePres4 = samplePres3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_pres_sen [aw=nadults] if samplePres1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if samplePres3==1, gen(stateyrv)
	eststo: ///
		reg pres_d_rf_pres_sen pres_d_lper_`j' pres_d_lpop pres_d_sh* stateyrv* ///
			if samplePres3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*

//------------------------------------------------------------------------------
// #7
// "Governor - U.S. House" roll-off analysis
//------------------------------------------------------------------------------

gen sampleGov1 = year>=1969 & year<=2000 & rf_gov_congr!=. & govobs==1 ///
	& lper_earn!=. & lper_emp!=.
gen sampleGov2 = sampleGov1 & (oilstate==1 | coalstate==1) & year<=1990
gen sampleGov3 = year>=1969 & year<=2000 & gov_d_rf_gov_congr!=. & govobs==1 ///
	& gov_d_lper_earn!=. & gov_d_lper_emp!=.
gen sampleGov4 = sampleGov3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_gov_congr [aw=nadults] if sampleGov1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if sampleGov3==1, gen(stateyrv)
	eststo: ///
		reg gov_d_rf_gov_congr gov_d_lper_`j' gov_d_lpop gov_d_sh* stateyrv* ///
			if sampleGov3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*


//------------------------------------------------------------------------------
// #8
// "Senate - U.S. House" roll-off analysis, 6-yr diffs
//------------------------------------------------------------------------------

gen sampleSen1 = ((year>=1969 & year<=2000) & rf_sen_congr!=. ///
	& (lper_earn!=. & lper_emp!=.))
gen sampleSen2 = sampleSen1 & (oilstate==1 | coalstate==1) & year<=1990
gen sampleSen3 = ((year>=1969 & year<=2000) & sen6_d_rf_sen_congr!=. ///
	& (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.))
gen sampleSen4 = sampleSen3 & (oilstate==1 | coalstate==1) & year<=1990

sum rf_sen_congr [aw=nadults] if sampleSen1==1

foreach j in "earn" "emp" {
	// OLS first difference for all counties and all years, state*year dummies
	tab stateyr if sampleSen3==1, gen(stateyrv)
	eststo: ///
		reg sen6_d_rf_sen_congr sen6_d_lper_`j' sen6_d_lpop sen6_d_sh* stateyrv* ///
			if sampleSen3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

drop sample*

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------

#delimit ;

esttab using "table6_aej.html", 
	keep(*d_lper_*) b(3) se(3) nostar nolz alignment(center) width(50%) replace
	;

#delimit cr

log close
