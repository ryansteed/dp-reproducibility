/* wd turnout */
capture log close
log using table3_aej, replace text

// Project: Voting Paper
// Task: First Stage Regressions, 1969-1990, oil and coal states
// Author and Date: Yiming Li (Paul), 2012-11-09

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

tab stateyr if (year>=1969 & year<=1990) & gov_d_gov_turnout!=. ///
	& (coalstate==1 | oilstate==1), gen(stateyrv)
	
eststo: reg gov_d_lper_earn gov_d_*1974_empiv stateyrv* gov_d_lpop gov_d_sh* ///
	if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
test gov_d_medium_coal_1974_empiv gov_d_large_coal_1974_empiv ///
	gov_d_medium_og_1974_empiv gov_d_large_og_1974_empiv
eststo: reg gov_d_lper_emp gov_d_*1974_empiv stateyrv* gov_d_lpop gov_d_sh* ///
	if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
test gov_d_medium_coal_1974_empiv gov_d_large_coal_1974_empiv ///
	gov_d_medium_og_1974_empiv gov_d_large_og_1974_empiv
eststo: reg gov_d_gov_turnout gov_d_*1974_empiv stateyrv* gov_d_lpop gov_d_sh* ///
	if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
	
drop stateyrv*

//------------------------------------------------------------------------------
// Presidential regressions
//------------------------------------------------------------------------------

tab stateyr if (year>=1969 & year<=1990) & pres_d_pres_turnout!=. ///
	& (coalstate==1 | oilstate==1), gen(stateyrv)
	
eststo: reg pres_d_lper_earn pres_d_*1974_empiv stateyrv* pres_d_lpop pres_d_sh* ///
	if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
test pres_d_medium_coal_1974_empiv pres_d_large_coal_1974_empiv ///
	pres_d_medium_og_1974_empiv pres_d_large_og_1974_empiv
eststo: reg pres_d_lper_emp pres_d_*1974_empiv stateyrv* pres_d_lpop pres_d_sh* ///
	if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
test pres_d_large_coal_1974_empiv ///
	pres_d_medium_og_1974_empiv pres_d_large_og_1974_empiv
eststo: reg pres_d_pres_turnout pres_d_*1974_empiv stateyrv* pres_d_lpop pres_d_sh* ///
	if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
	
drop stateyrv*

//------------------------------------------------------------------------------
// Senate regressions
//------------------------------------------------------------------------------

tab stateyr if (year>=1969 & year<=1990) & sen6_d_senate_turnout!=. ///
	& (coalstate==1 | oilstate==1), gen(stateyrv)
		
eststo: reg sen6_d_lper_earn sen6_d_*1974_empiv stateyrv* sen6_d_lpop sen6_d_sh* ///
	if (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
test sen6_d_medium_coal_1974_empiv sen6_d_large_coal_1974_empiv ///
	sen6_d_medium_og_1974_empiv sen6_d_large_og_1974_empiv
		
eststo: reg sen6_d_lper_emp sen6_d_*1974_empiv stateyrv* sen6_d_lpop sen6_d_sh* ///
	if (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
test sen6_d_medium_coal_1974_empiv sen6_d_large_coal_1974_empiv ///
	sen6_d_medium_og_1974_empiv sen6_d_large_og_1974_empiv
		
eststo: reg sen6_d_senate_turnout sen6_d_*1974_empiv stateyrv* sen6_d_lpop sen6_d_sh* ///
	if (sen6_d_lper_earn!=. & sen6_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
		
drop stateyrv*

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------

esttab using "table3_aej.html", replace keep(*empiv) ///
	b(3) se(3) nostar nolz alignment(center) width(50%)

log close
