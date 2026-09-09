capture log close
log using table4_aej, replace text

// Project: Voting Paper
// Task: Gobernatorial, Senate, and Presidential Elections
// first difference models, OLS and 2SLS; 1969-1990, oil and coal states
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
// Gubernatorial Elections: OLS and 2SLS
//------------------------------------------------------------------------------
gen sampleGov = (year>=1969 & year<=1990) & gov_d_gov_turnout!=. ///
	& (coalstate==1 | oilstate==1) & (gov_d_lper_earn!=. & gov_d_lper_emp!=.)

// Generate state*year dummies
tab stateyr if sampleGov==1, gen(stateyrv)

foreach i in "earn" "emp" {
	// OLS
	eststo: reg gov_d_gov_turnout gov_d_lper_`i' ///
		stateyrv* gov_d_lpop gov_d_sh* ///
		if sampleGov==1 [aw=nadults], cluster(fipsst)

	// 2SLS
	eststo: ivregress 2sls gov_d_gov_turnout ///
		stateyrv* gov_d_lpop gov_d_sh* (gov_d_lper_`i'=gov_d_*1974_empiv) ///
		if sampleGov==1 [aw=nadults], cluster(fipsst)
	estat firststage
}

drop stateyrv*

//------------------------------------------------------------------------------
// Presidential Elections: OLS and 2SLS
//------------------------------------------------------------------------------
gen samplePres = (year>=1969 & year<=1990) & pres_d_pres_turnout!=. ///
	& (coalstate==1 | oilstate==1) & (pres_d_lper_earn!=. & pres_d_lper_emp!=.)

// Generate state*year dummies
tab stateyr if samplePres==1, gen(stateyrv)

foreach i in "earn" "emp" {
	// OLS
	eststo: reg pres_d_pres_turnout pres_d_lper_`i' ///
		stateyrv* pres_d_lpop pres_d_sh* ///
		if samplePres==1 [aw=nadults], cluster(fipsst)

	// 2SLS
	eststo: ivregress 2sls pres_d_pres_turnout ///
		stateyrv* pres_d_lpop pres_d_sh* (pres_d_lper_`i'=pres_d_*1974_empiv) ///
		if samplePres==1 [aw=nadults], cluster(fipsst)
	estat firststage
}

drop stateyrv*

//------------------------------------------------------------------------------
// Senate Elections: OLS and 2SLS
//------------------------------------------------------------------------------
gen sampleSen = (year>=1969 & year<=1990) & sen6_d_senate_turnout!=. ///
	& (coalstate==1 | oilstate==1) & (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.)

// Generate state*year dummies
tab stateyr if sampleSen==1, gen(stateyrv)

foreach i in "earn" "emp" {
	// OLS
	eststo: reg sen6_d_senate_turnout sen6_d_lper_`i' ///
		stateyrv* sen6_d_lpop sen6_d_sh* ///
		if sampleSen==1 [aw=nadults], cluster(fipsst)

	// 2SLS
	eststo: ivregress 2sls sen6_d_senate_turnout ///
		stateyrv* sen6_d_lpop sen6_d_sh* (sen6_d_lper_`i'=sen6_d*1974_empiv) ///
		if sampleSen==1 [aw=nadults], cluster(fipsst)
	estat firststage
}

drop stateyrv*

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------
#delimit ;

esttab using "table4_aej.html", 
	keep(*d_lper_*) b(3) se(3) nostar nolz alignment(center) width(50%)	replace
	;

#delimit cr

*** EDITED by Ryan Steed
#delimit ;
estout using "../results/table4.csv", 
	keep(*d_lper_*) cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
	;
#delimit cr
**

log close
