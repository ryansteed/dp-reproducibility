capture log close
log using online_appendix_table2_aej, replace text

// Project: Voting Paper
// Task: Robustness tests
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
// Gov TSLS regressions
//------------------------------------------------------------------------------

// Generate state*year dummies
tab stateyr if (year>=1969 & year<=1990) & gov_d_gov_turnout!=. ///
	& (coalstate==1 | oilstate==1) & gov_d_lper_earn!=. & gov_d_lper_emp!=., gen(stateyrv)

// IV specifications: National Coal/Oil Employment * I(medium, large coal/oil 1967)
foreach i in "earn" "emp" {
	eststo: ivreg2 gov_d_gov_turnout stateyrv* gov_d_lpop ///
	gov_d_sh* (gov_d_lper_`i' = gov_d_*1967_empiv) ///
	[aw=nadults], first cluster(fipsst)
}

// IV specifications: Coal/Oil price * I(medium, large coal/oil 1974)
foreach i in "earn" "emp" {
	eststo: ivreg2 gov_d_gov_turnout stateyrv* gov_d_lpop ///
	gov_d_sh* (gov_d_lper_`i' = gov_d_*1974_piv) [aw=nadults], first cluster(fipsst)
}

// IV specifications: Coal/Oil price * I(medium, large coal/oil 1967)
foreach i in "earn" "emp" {
	eststo: ivreg2 gov_d_gov_turnout stateyrv* gov_d_lpop ///
	gov_d_sh* (gov_d_lper_`i' = gov_d_*1967_piv) [aw=nadults], first cluster(fipsst)
}

// IV specifications: National Coal/Oil Employment * continuous employment share in 1974
foreach i in "earn" "emp" {
	eststo: ivreg2 gov_d_gov_turnout stateyrv* gov_d_lpop gov_d_sh* ///
	(gov_d_lper_`i'=gov_d_*contiv) [aw=nadults], first cluster(fipsst)
}

drop stateyrv*

//------------------------------------------------------------------------------
// Senate TSLS regressions
//------------------------------------------------------------------------------

// Generate state*year dummies
tab stateyr if (year>=1969 & year<=1990) & sen6_d_senate_turnout!=. ///
	& (coalstate==1 | oilstate==1) & sen6_d_lper_earn!=. & sen6_d_lper_emp!=., gen(stateyrv)

// IV specifications: National Coal/Oil Employment * I(medium, large coal/oil 1967)
foreach i in "earn" "emp" {
	eststo: ivreg2 sen6_d_senate_turnout stateyrv* sen6_d_lpop ///
	sen6_d_sh* (sen6_d_lper_`i' = sen6_d_*1967_empiv) ///
	[aw=nadults], first cluster(fipsst)
}

// IV specifications: Coal/Oil price * I(medium, large coal/oil 1974)
foreach i in "earn" "emp" {
	eststo: ivreg2 sen6_d_senate_turnout stateyrv* sen6_d_lpop ///
	sen6_d_sh* (sen6_d_lper_`i' = sen6_d_*1974_piv) [aw=nadults], first cluster(fipsst)
}

// IV specifications: Coal/Oil price * I(medium, large coal/oil 1967)
foreach i in "earn" "emp" {
	eststo: ivreg2 sen6_d_senate_turnout stateyrv* sen6_d_lpop ///
	sen6_d_sh* (sen6_d_lper_`i' = sen6_d_*1967_piv) [aw=nadults], first cluster(fipsst)
}

// IV specifications: National Coal/Oil Employment * continuous employment share in 1974
foreach i in "earn" "emp" {
	eststo: ivreg2 sen6_d_senate_turnout stateyrv* sen6_d_lpop sen6_d_sh* ///
	(sen6_d_lper_`i'=sen6_d_*contiv) [aw=nadults], first cluster(fipsst)
}

drop stateyrv*

//------------------------------------------------------------------------------
// Presidential TSLS regressions
//------------------------------------------------------------------------------

// Generate state*year dummies
tab stateyr if (year>=1969 & year<=1990) & pres_d_pres_turnout!=. ///
	& (coalstate==1 | oilstate==1) & pres_d_lper_earn!=. & pres_d_lper_emp!=., gen(stateyrv)

// IV specifications: National Coal/Oil Employment * I(medium, large coal/oil 1967)
foreach i in "earn" "emp" {
	eststo: ivreg2 pres_d_pres_turnout stateyrv* pres_d_lpop ///
	pres_d_sh* (pres_d_lper_`i' = pres_d_*1967_empiv) ///
	[aw=nadults], first cluster(fipsst)
}

// IV specifications: Coal/Oil price * I(medium, large coal/oil 1974)
foreach i in "earn" "emp" {
	eststo: ivreg2 pres_d_pres_turnout stateyrv* pres_d_lpop ///
	pres_d_sh* (pres_d_lper_`i' = pres_d_*1974_piv) [aw=nadults], first cluster(fipsst)
}

// IV specifications: Coal/Oil price * I(medium, large coal/oil 1967)
foreach i in "earn" "emp" {
	eststo: ivreg2 pres_d_pres_turnout stateyrv* pres_d_lpop ///
	pres_d_sh* (pres_d_lper_`i' = pres_d_*1967_piv) [aw=nadults], first cluster(fipsst)
}

// IV specifications: National Coal/Oil Employment * continuous employment share in 1974
foreach i in "earn" "emp" {
	eststo: ivreg2 pres_d_pres_turnout stateyrv* pres_d_lpop pres_d_sh* ///
	(pres_d_lper_`i'=pres_d_*contiv) [aw=nadults], first cluster(fipsst)
}

drop stateyrv*

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------

esttab using online_appendix_table2_aej.html, replace keep(*lper_earn *lper_emp) ///
	b(3) se(3) nostar nolz alignment(center) width(50%)
	
log close
