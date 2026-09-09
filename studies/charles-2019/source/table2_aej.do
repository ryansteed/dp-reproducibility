capture log close
log using table2_aej, replace text

// Project: Voting Paper
// Task: Pooled OLS and First Difference Models, 1969-2000, all states
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
// Gubernatorial regressions
//------------------------------------------------------------------------------

foreach j in "earn" "emp" {
	// Pooled OLS
	tab year if (year>=1969 & year<=2000) & govobs==1, gen(yeardummy)
	tab fipsst if govobs==1, gen(statedummy)
	eststo gov_ols_`j': reg gov_turnout lper_`j' statedummy* yeardummy* lpop sh* ///
		if (lper_earn!=. & lper_emp!=.) & govobs==1 [aw=nadults], cluster(fipsst)
	drop statedummy* yeardummy*
		
	// First Difference w/o state*year fixed effects
	tab year if (year>=1969 & year<=2000) & gov_d_gov_turnout!=., gen(yeardummy)
	eststo gov_fd1_`j': reg gov_d_gov_turnout gov_d_lper_`j' yeardummy* gov_d_lpop gov_d_sh* ///
		if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
	drop yeardummy*
		
	// First Difference w/ state*year fixed effects
	tab stateyr if (year>=1969 & year<=2000) & gov_d_gov_turnout!=., gen(stateyrv)
	eststo gov_fd2_`j': reg gov_d_gov_turnout gov_d_lper_`j' stateyrv* gov_d_lpop gov_d_sh* ///
		if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
	drop stateyrv*
}
 
//------------------------------------------------------------------------------
// Presidential regressions
//------------------------------------------------------------------------------

foreach j in "earn" "emp" {
	// Pooled OLS
	tab year if (year>=1969 & year<=2000) & presobs==1, gen(yeardummy)
	tab fipsst if presobs==1, gen(statedummy)
	eststo pres_ols_`j': reg pres_turnout lper_`j' statedummy* yeardummy* lpop sh* ///
		if (lper_earn!=. & lper_emp!=.) & presobs==1 [aw=nadults], cluster(fipsst)
	drop statedummy* yeardummy*
	
	// First Difference w/o state*year fixed effects
	tab year if (year>=1969 & year<=2000) & pres_d_pres_turnout!=., gen(yeardummy)
	eststo pres_fd1_`j': reg pres_d_pres_turnout pres_d_lper_`j' yeardummy* pres_d_lpop pres_d_sh* ///
		if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
	drop yeardummy*
		
	// First Difference w/ state*year fixed effects
	tab stateyr if (year>=1969 & year<=2000) & pres_d_pres_turnout!=., gen(stateyrv)
	eststo pres_fd2_`j': reg pres_d_pres_turnout pres_d_lper_`j' stateyrv* pres_d_lpop pres_d_sh* ///
		if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
	drop stateyrv*
}

//------------------------------------------------------------------------------
// Senate regressions
//------------------------------------------------------------------------------

foreach j in "earn" "emp" {
	// Pooled OLS
	tab year if (year>=1969 & year<=2000) & senobs==1, gen(yeardummy)
	tab fipsst if senobs==1, gen(statedummy)
	eststo sen_ols_`j': reg senate_turnout lper_`j' statedummy* yeardummy* lpop sh* ///
		if (lper_earn!=. & lper_emp!=.) & senobs==1 [aw=nadults], cluster(fipsst)
	drop statedummy* yeardummy*
			
	// First Difference w/o state*year fixed effects
	tab year if (year>=1969 & year<=2000) & sen6_d_senate_turnout!=., gen(yeardummy)
	eststo sen_fd1_`j': reg sen6_d_senate_turnout sen6_d_lper_`j' yeardummy* ///
		sen6_d_lpop sen6_d_sh* ///
		if (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.) ///
		[aw=nadults], cluster(fipsst)
	drop yeardummy*
		
	// First Difference w/ state*year fixed effects
	tab stateyr if (year>=1969 & year<=2000) & sen6_d_senate_turnout!=., gen(stateyrv)
	eststo sen_fd2_`j': reg sen6_d_senate_turnout sen6_d_lper_`j' stateyrv* ///
		sen6_d_lpop sen6_d_sh* ///
		if (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.) ///
		[aw=nadults], cluster(fipsst)
	drop stateyrv*
}

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------

#delimit ;
esttab gov* sen* pres* using table2_aej.html, replace keep(*earn *emp)
	b(3) se(3) nostar nolz alignment(center) width(50%)
	mtitles(
	"Gov Pooled OLS" "Gov Difference w/o state*year" "Gov Difference w/ state*year" 
	"Gov Pooled OLS" "Gov Difference w/o state*year" "Gov Difference w/ state*year" 
	"Senate Pooled OLS" "Senate Difference w/o state*year" "Senate Difference w/ state*year" 
	"Senate Pooled OLS" "Senate Difference w/o state*year" "Senate Difference w/ state*year" 
	"Pres Pooled OLS" "Pres Difference w/o state*year" "Pres Difference w/ state*year" 
	"Pres Pooled OLS" "Pres Difference w/o state*year" "Pres Difference w/ state*year"
	);
#delimit cr

log close
