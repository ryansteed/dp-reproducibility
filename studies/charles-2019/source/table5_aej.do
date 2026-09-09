capture log close
log using table5_aej, replace text

// Project: Voting Paper
// Task: U.S. House and State House regressions, OLS and TSLS
// Author and Date: Yiming Li (Paul), 2012-11-13

version 12.1
clear all
macro drop _all
set matsize 2000
set more off
*** EDITED BY RYAN STEED
/* ssc install estout
ssc install ivreg2 */
***

use data/voting_paper_cleaned.dta, clear
xtset fips year

//------------------------------------------------------------------------------
// U.S. House regressions
//------------------------------------------------------------------------------

gen sampleA = (year>=1969 & year<=2000) & congr_turnout!=. ///
	& (lper_earn!=. & lper_emp!=.)

// OLS level regression
foreach j in "earn" "emp" {
	tab year if sampleA==1, gen(yeardummy)
	tab fipsst if sampleA==1, gen(statedummy)
	eststo: reg congr_turnout lper_`j' ///
		statedummy* yeardummy* lpop sh* ///
		if sampleA==1 [aw=nadults], cluster(fipsst)

	drop statedummy* yeardummy*
}

// OLS first diffs regression
gen sampleB = (year>=1969 & year<=2000) & congr4_d_congr_turnout!=. ///
	& (congr4_d_lper_earn!=. & congr4_d_lper_emp!=.)

foreach j in "earn" "emp" {
	tab stateyr if sampleB==1, gen(stateyrv)
	eststo: reg congr4_d_congr_turnout congr4_d_lper_`j' ///
		stateyrv* congr4_d_lpop congr4_d_sh* ///
		if sampleB==1 [aw=nadults], cluster(fipsst)

	drop stateyrv*
}

// First diffs OLS and TSLS regressions
gen sampleC = sampleB==1 & year<=1990 & (oilstate==1 | coalstate==1)

foreach j in "earn" "emp" {
	// OLS
	tab stateyr if sampleC==1, gen(stateyrv)
	eststo: reg congr4_d_congr_turnout congr4_d_lper_`j' ///
		stateyrv* congr4_d_lpop congr4_d_sh* ///
		if sampleC==1 [aw=nadults], cluster(fipsst)

	// TSLS
	eststo: ivreg2 congr4_d_congr_turnout ///
		stateyrv* congr4_d_lpop congr4_d_sh* (congr4_d_lper_`j'=congr4_d*1974_empiv) ///
		if sampleC==1 [aw=nadults], first cluster(fipsst)

	drop stateyrv*
}

//------------------------------------------------------------------------------
// State House regressions
//------------------------------------------------------------------------------

// all-county all-year samples
gen sampleSt1 = year>=1969 & year<=2000 & sthouseobs==1 ///
	& (lper_earn!=. & lper_emp!=.)
gen sampleSt2 = sampleSt1 & st4_d_sthouse_turnout!=. ///
	& (st4_d_lper_earn!=. & st4_d_lper_emp!=.)

// coal/oil county boom/bust year samples
gen sampleSt3 = sampleSt2 & year<=1990 & (coalstate==1 | oilstate==1)

foreach i in "earn" "emp" {
	// All level OLS
	tab year if sampleSt1==1, gen(yeardummy)
	tab fipsst if sampleSt1==1, gen(statedummy)
	eststo: reg sthouse_turnout lper_`i' ///
		statedummy* yeardummy* lpop sh* ///
		if sampleSt1==1 [aw=nadults], cluster(fipsst)
	drop yeardummy* statedummy*

	// ALL FD OLS
	tab stateyr if sampleSt2==1, gen(stateyrv)
	eststo: reg st4_d_sthouse_turnout st4_d_lper_`i' ///
		stateyrv* st4_d_lpop st4_d_sh* ///
		if sampleSt2==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*

	// coal/oil FD OLS
	tab stateyr if sampleSt3==1, gen(stateyrv)
	eststo: reg st4_d_sthouse_turnout st4_d_lper_`i' ///
		stateyrv* st4_d_lpop st4_d_sh* ///
		if sampleSt3==1 [aw=nadults], cluster(fipsst)
	drop stateyrv*

	// coal/oil FD 2SLS
	tab stateyr if sampleSt3==1, gen(stateyrv)
	eststo: ivregress 2sls st4_d_sthouse_turnout ///
		stateyrv* st4_d_lpop st4_d_sh* (st4_d_lper_`i'=st4_d*og_1974_empiv) ///
		if sampleSt3==1 [aw=nadults], cluster(fipsst)
	estat firststage

	drop stateyrv*
}

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------
#delimit ;

esttab using "table5_aej.html", 
	keep(*lper*) b(3) se(3) nostar nolz alignment(center) width(50%) replace
	;

#delimit cr

*** EDITED by Ryan Steed
#delimit ;
estout using "../results/table5.csv", 
	keep(*lper*) cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
	;
#delimit cr
**

log close
