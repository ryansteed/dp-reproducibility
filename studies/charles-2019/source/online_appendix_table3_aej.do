capture log close
log using online_appendix_table3_aej, replace text

// Project: Voting Paper
// Task: SEA and ESR level First Difference Models, 1969-2000, all states
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
// Merge on the SEAs
//------------------------------------------------------------------------------

sort fips
merge m:1 fips using data/sea_county_fips_reis.dta, keepusing(sea fipsst)
drop if _merge==2
drop _merge

preserve

//------------------------------------------------------------------------------
// Gubernatorial SEA regresssions
//------------------------------------------------------------------------------

// Exclude counties from SEA if election data is missing
foreach sea_var of varlist gov_total last_gov_year earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s {
	replace `sea_var' = . if gov_total ==.
	replace `sea_var' = . if earn ==.
	replace `sea_var' = . if emp ==.
	replace `sea_var' = . if pop ==.
	replace `sea_var' = . if nadults ==.
}

// Create SEA level variables
collapse (mean) last_gov_year (sum) gov_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s, by(fipsst sea year)
	
replace gov_total = . if gov_total==0

xtset sea year
sort sea year

// Generate Labor Market Outcomes variables
gen lper_earn = ln(earn/pop)
gen lper_emp = ln(emp/nadults)

// Generate Voter Turnout variables
gen gov_turnout = gov_total/nadults

// Generate control variables
gen lpop		= ln(pop)
gen shfemale	= numfemale_adults/nadults
gen shblack		= numblack_adults/nadults
gen shothrace	= numothrace_adults/nadults
gen sh30s		= num30s/nadults
gen sh40s		= num40s/nadults
gen sh50s		= num50s/nadults
gen sh60s		= num60s/nadults
gen sh7080s		= num7080s/nadults

// Generate first difference variables
global change_var lper_earn lper_emp gov_turnout ///
	lpop shfemale shblack shothrace sh30s sh40s sh50s sh60s sh7080s
foreach i of global change_var {
	gen gov_d_`i' = `i'-l4.`i' if (year-last_gov_year==4)
}

// FD regressions on earnings and employment
gen stateyr = year * 100 + fipsst
tab stateyr if (year>=1969 & year<=2000) & gov_d_gov_turnout!=., gen(stateyrv)

eststo sea_gov_fd_earn: reg gov_d_gov_turnout gov_d_lper_earn stateyrv* gov_d_lpop gov_d_sh* ///
	if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
eststo sea_gov_fd_emp: reg gov_d_gov_turnout gov_d_lper_emp stateyrv* gov_d_lpop gov_d_sh* ///
	if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)

drop stateyrv*

//------------------------------------------------------------------------------
// Presidential SEA regressions
//------------------------------------------------------------------------------

restore, preserve

// Exclude counties from SEA if election data is missing
foreach sea_var of varlist pres_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s {
	replace `sea_var' = . if pres_total ==.
	replace `sea_var' = . if earn ==.
	replace `sea_var' = . if emp ==.
	replace `sea_var' = . if pop ==.
	replace `sea_var' = . if nadults ==.
}

// Create SEA level variables
collapse (sum) pres_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s, by(fipsst sea year)
	
replace pres_total = . if pres_total==0

xtset sea year
sort sea year

// Generate Labor Market Outcomes variables
gen lper_earn = ln(earn/pop)
gen lper_emp = ln(emp/nadults)

// Generate Voter Turnout variables
gen pres_turnout = pres_total/nadults

// Generate control variables
gen lpop		= ln(pop)
gen shfemale	= numfemale_adults/nadults
gen shblack		= numblack_adults/nadults
gen shothrace	= numothrace_adults/nadults
gen sh30s		= num30s/nadults
gen sh40s		= num40s/nadults
gen sh50s		= num50s/nadults
gen sh60s		= num60s/nadults
gen sh7080s		= num7080s/nadults

// Generate first difference variables
global change_var lper_earn lper_emp pres_turnout ///
	lpop shfemale shblack shothrace sh30s sh40s sh50s sh60s sh7080s
	
foreach i of global change_var {
	gen pres_d_`i' = `i'-l4.`i' if pres_total!=.
}

// FD Regressions on earnings and employment
gen stateyr = year * 100 + fipsst
tab stateyr if (year>=1969 & year<=2000) & pres_d_pres_turnout!=., gen(stateyrv)

eststo sea_pres_fd_earn: reg pres_d_pres_turnout pres_d_lper_earn stateyrv* pres_d_lpop pres_d_sh* ///
	if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
eststo sea_pres_fd_emp: reg pres_d_pres_turnout pres_d_lper_emp stateyrv* pres_d_lpop pres_d_sh* ///
	if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)

drop stateyrv*
	

//------------------------------------------------------------------------------
// Senate SEA regresssions
//------------------------------------------------------------------------------

// Exclude counties from SEA if election data is missing
restore

foreach sea_var of varlist senate_total last_senate_year earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s {
	replace `sea_var' = . if senate_total==.
	replace `sea_var' = . if earn ==.
	replace `sea_var' = . if emp ==.
	replace `sea_var' = . if pop ==.
	replace `sea_var' = . if nadults ==.
}

// Create SEA level variables
collapse (mean) last_senate_year (sum) senate_total pres_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s, by(fipsst sea year)

replace senate_total = . if senate_total==0
replace pres_total = . if pres_total==0
xtset sea year
sort sea year

// Generate Labor Market Outcomes variables
gen lper_earn = ln(earn/pop)
gen lper_emp = ln(emp/nadults)

// Generate Voter Turnout variables
gen senate_turnout = senate_total/nadults

// Generate control variables
gen lpop		= ln(pop)
gen shfemale	= numfemale_adults/nadults
gen shblack		= numblack_adults/nadults
gen shothrace	= numothrace_adults/nadults
gen sh30s		= num30s/nadults
gen sh40s		= num40s/nadults
gen sh50s		= num50s/nadults
gen sh60s		= num60s/nadults
gen sh7080s		= num7080s/nadults

// Generate Presidential year indicator
gen presobs = (pres_total!=.)

// Generate Senate observation indicators for 6 year intervals
gen senateobs_6yr = (year - last_senate_year == 6 & senate_total!=.)
replace senateobs_6yr = 1 if (f6.year - f6.last_senate_year == 6) & senate_total!=.

// Generate first difference variables
global change_var lper_earn lper_emp senate_turnout ///
	lpop shfemale shblack shothrace sh30s sh40s sh50s sh60s sh7080s
	
foreach i of global change_var {
	gen senate_d_`i'_6yr = `i' - l6.`i' if year - last_senate_year == 6
}

// FD regressions on earnings and employment measures

gen stateyr = year * 100 + fipsst

foreach j in "earn" "emp" {
	// First Difference w/ state*year fixed effects
	tab stateyr if (year>=1969 & year<=2000) & senate_d_senate_turnout_6yr!=., gen(stateyrv)

	eststo sea_senate_fd2_`j'_6yr: reg senate_d_senate_turnout_6yr senate_d_lper_`j'_6yr stateyrv* ///
		senate_d_lpop_6yr senate_d_sh*_6yr ///
		if (senate_d_lper_earn_6yr!=. & senate_d_lper_emp_6yr!=.) ///
		[aw=nadults], cluster(fipsst)

	drop stateyrv*
}

//------------------------------------------------------------------------------
// Merge on the ESRs
//------------------------------------------------------------------------------

use data/voting_paper_cleaned.dta, clear

sort fips
merge m:1 fips using data/esr_county_fips_reis.dta, keepusing(esr_new fipsst)
drop if _merge==2
replace gov_total = . if _merge==1
replace pres_total = . if _merge==1
replace senate_total = . if _merge==1
drop _merge

preserve

//------------------------------------------------------------------------------
// Gubernatorial ESR regressions
//------------------------------------------------------------------------------

// Exclude counties from ESR if election data is missing
foreach esr_var of varlist gov_total last_gov_year earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s {
	replace `esr_var' = . if gov_total ==.
	replace `esr_var' = . if earn ==.
	replace `esr_var' = . if emp ==.
	replace `esr_var' = . if pop ==.
	replace `esr_var' = . if nadults ==.
}

// Create ESR level variables
collapse (mean) last_gov_year (sum) gov_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s, by(fipsst esr_new year)
	
replace gov_total = . if gov_total==0
xtset esr_new year
sort esr_new year

// Generate Labor Market Outcomes variables
gen lper_earn = ln(earn/pop)
gen lper_emp = ln(emp/nadults)

// Generate Voter Turnout variables
gen gov_turnout = gov_total/nadults

// Generate control variables
gen lpop		= ln(pop)
gen shfemale	= numfemale_adults/nadults
gen shblack		= numblack_adults/nadults
gen shothrace	= numothrace_adults/nadults
gen sh30s		= num30s/nadults
gen sh40s		= num40s/nadults
gen sh50s		= num50s/nadults
gen sh60s		= num60s/nadults
gen sh7080s		= num7080s/nadults

// Generate first difference variables
global change_var lper_earn lper_emp gov_turnout ///
	lpop shfemale shblack shothrace sh30s sh40s sh50s sh60s sh7080s

foreach i of global change_var {
	gen gov_d_`i' = `i'-l4.`i' if (year-last_gov_year==4)
}

// FD regressions on earnings and employment measures
gen stateyr = year * 100 + fipsst
tab stateyr if (year>=1969 & year<=2000) & gov_d_gov_turnout!=., gen(stateyrv)

eststo esr_gov_fd_earn: reg gov_d_gov_turnout gov_d_lper_earn stateyrv* gov_d_lpop gov_d_sh* ///
	if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
eststo esr_gov_fd_emp: reg gov_d_gov_turnout gov_d_lper_emp stateyrv* gov_d_lpop gov_d_sh* ///
	if (gov_d_lper_earn!=. & gov_d_lper_emp!=.) [aw=nadults], cluster(fipsst)

drop stateyrv*

//------------------------------------------------------------------------------
// Presidential ESR regressions
//------------------------------------------------------------------------------

restore, preserve

// Exclude counties from ESR if election data is missing
foreach esr_var of varlist pres_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s {
	replace `esr_var' = . if pres_total ==.
	replace `esr_var' = . if earn ==.
	replace `esr_var' = . if emp ==.
	replace `esr_var' = . if pop ==.
	replace `esr_var' = . if nadults ==.
}

collapse (sum) pres_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s, by(fipsst esr_new year)
	
replace pres_total = . if pres_total==0

xtset esr_new year
sort esr_new year

// Generate Labor Market Outcomes variables
gen lper_earn = ln(earn/pop)
gen lper_emp = ln(emp/nadults)

// Generate Voter Turnout variables
gen pres_turnout = pres_total/nadults

// Generate control variables
gen lpop		= ln(pop)
gen shfemale	= numfemale_adults/nadults
gen shblack		= numblack_adults/nadults
gen shothrace	= numothrace_adults/nadults
gen sh30s		= num30s/nadults
gen sh40s		= num40s/nadults
gen sh50s		= num50s/nadults
gen sh60s		= num60s/nadults
gen sh7080s		= num7080s/nadults

// Generate first difference variables
global change_var lper_earn lper_emp pres_turnout ///
	lpop shfemale shblack shothrace sh30s sh40s sh50s sh60s sh7080s

foreach i of global change_var {
	gen pres_d_`i' = `i'-l4.`i' if pres_total!=.
}

// FD regressions on earnings and employment measures
gen stateyr = year * 100 + fipsst
tab stateyr if (year>=1969 & year<=2000) & pres_d_pres_turnout!=., gen(stateyrv)

eststo esr_pres_fd_earn: reg pres_d_pres_turnout pres_d_lper_earn stateyrv* pres_d_lpop pres_d_sh* ///
	if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)
eststo esr_pres_fd_emp: reg pres_d_pres_turnout pres_d_lper_emp stateyrv* pres_d_lpop pres_d_sh* ///
	if (pres_d_lper_earn!=. & pres_d_lper_emp!=.) [aw=nadults], cluster(fipsst)

drop stateyrv*


//------------------------------------------------------------------------------
// Senate ESR regressions
//------------------------------------------------------------------------------

// Exclude counties from ESR if election data is missing
restore

foreach esr_var of varlist senate_total last_senate_year earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s {
	replace `esr_var' = . if senate_total ==.
	replace `esr_var' = . if earn ==.
	replace `esr_var' = . if emp ==.
	replace `esr_var' = . if pop ==.
	replace `esr_var' = . if nadults ==.
}

collapse (mean) last_senate_year (sum) senate_total pres_total earn emp ///
	pop nadults numfemale_adults numblack_adults numothrace_adults ///
	num30s num40s num50s num60s num7080s, by(fipsst esr_new year)

replace senate_total = . if senate_total==0
replace pres_total = . if pres_total==0

xtset esr_new year
sort esr_new year

// Generate Labor Market Outcomes variables
gen lper_earn = ln(earn/pop)
gen lper_emp = ln(emp/nadults)

// Generate Voter Turnout variables
gen senate_turnout = senate_total/nadults

// Generate control variables
gen lpop		= ln(pop)
gen shfemale	= numfemale_adults/nadults
gen shblack		= numblack_adults/nadults
gen shothrace	= numothrace_adults/nadults
gen sh30s		= num30s/nadults
gen sh40s		= num40s/nadults
gen sh50s		= num50s/nadults
gen sh60s		= num60s/nadults
gen sh7080s		= num7080s/nadults

// Generate Presidential year indicator
gen presobs = (pres_total!=.)

// Generate Senate observation indicators for 6 year intervals
gen senateobs_6yr = (year - last_senate_year == 6 & senate_total!=.)
replace senateobs_6yr = 1 if (f6.year - f6.last_senate_year == 6) & senate_total!=.

// Generate first difference variables
global change_var lper_earn lper_emp senate_turnout ///
	lpop shfemale shblack shothrace sh30s sh40s sh50s sh60s sh7080s

foreach i of global change_var {
	gen senate_d_`i'_6yr = `i' - l6.`i' if year-last_senate_year==6
}

// FD regressions on earnings and employment measures

gen stateyr = year*100+fipsst

foreach j in "earn" "emp" {
	// First Difference w/ state*year fixed effects
	tab stateyr if (year>=1969 & year<=2000) & senate_d_senate_turnout_6yr!=., gen(stateyrv)
	eststo esr_senate_fd2_`j'_6yr: reg senate_d_senate_turnout_6yr senate_d_lper_`j'_6yr stateyrv* ///
		senate_d_lpop_6yr senate_d_sh*_6yr ///
		if (senate_d_lper_earn_6yr!=. & senate_d_lper_emp_6yr!=.) ///
		[aw=nadults], cluster(fipsst)
	drop stateyrv*
}

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------

esttab using "online_appendix_table3_aej.html", ///
	replace keep(*earn *emp *earn_6yr *emp_6yr) b(3) se(3) nostar nolz alignment(center) width(50%)

log close
