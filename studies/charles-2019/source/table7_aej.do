capture log close
log using table7_aej, replace text

// Project: Voting Paper
// Task: Individual level regressions, pooled OLS and within estimators
// Author and Date: Yiming Li (Paul), 2012-11-13

version 12.1
clear all
macro drop _all
set matsize 2000
set more off
ssc install estout, replace
ssc install carryforward

use "data/voting_paper_anes_extract.dta", clear

//------------------------------------------------------------------------------
// cleaning up
//------------------------------------------------------------------------------

// Rename variables
rename VCF0118	empstatus
rename VCF0104	gender
rename VCF0101	age
rename VCF0006a	hhid
rename VCF0004	year
rename VCF0901a	state
rename VCF0050a	poli_info
rename VCF0727	newspaper
rename VCF0726	magazine
rename VCF0725	radio
rename VCF0724	tv
rename VCF0009a	weight

// Replace 0 with missing value
foreach i of varlist state age gender newspaper magazine tv radio {	
	replace `i' = . if `i'==0
}

// Generate dependent and independent variables
gen informed = (poli_info==1 | poli_info==2) if inlist(poli_info, 1,2,3,4,5)
gen emp = (empstatus==1) if inlist(empstatus,1,2,3,4,5)
gen agesq = age^2
gen male = (gender==1) if gender!=.

gen valid_expo = (newspaper!=. & magazine!=. & tv!=. & radio!=.)
egen total_expo = rowtotal(newspaper magazine tv radio) if valid_expo==1
gen exposed = (total_expo >= 7) if valid_expo==1

gen pres = 0
forvalues i = 1948(4)2008 {
	replace pres = 1 if year==`i'
}

drop if emp==. | age==. | male==. | state==.

global depv informed exposed

//------------------------------------------------------------------------------
// Full sample pooled OLS regressions
//------------------------------------------------------------------------------

gen stateyr = year * 100 + state

foreach i of global depv {
	sum `i' if (year>=1952 & year<=2004) & pres==1 & `i'!=.
	tab stateyr if (year>=1952 & year<=2004) & pres==1 & `i'!=., gen(stateyrv)
	eststo: reg `i' emp age agesq male stateyrv* [aw=weight], cluster(hhid)
	drop stateyrv*
}

drop stateyr
preserve

//------------------------------------------------------------------------------
// Panel sample regressions
//------------------------------------------------------------------------------

// Panels from 1956
foreach i of varlist exposed {
	keep hhid state year `i' emp age agesq male weight
	keep if inlist(year, 1956, 1960, 1972, 1976, 1992, 1996)
	drop if `i'==.

	reshape wide state `i' emp age agesq male weight, i(hhid) j(year)
	keep if ///
		(male1956==male1960 & (age1960-age1956>=2 & age1960-age1956<=6)) | ///
		(male1972==male1976 & (age1976-age1972>=2 & age1976-age1972<=6)) | ///
		(male1992==male1996 & (age1996-age1992>=2 & age1996-age1992<=6))

	reshape long

	drop if weight==.

	gsort +hhid -year
	replace weight = . if year==1956 | year==1972 | year==1992
	by hhid: carryforward weight, gen(weight4yr)

	xtset hhid year

	sum `i'

	gen stateyr = year*100 + state
	tab stateyr, gen(stateyrv)

	// Pooled OLS
	eststo `i'_ols_panel: reg `i' emp age agesq male stateyrv* [aw=weight4yr], cluster(hhid)

	// Within estimator
	eststo `i'_within_panel: xtreg `i' emp age agesq stateyrv* [aw=weight4yr], cluster(hhid) fe

	drop stateyr stateyrv*
}


// Panels from 1972
restore, preserve

foreach i of varlist informed {
	keep hhid state year `i' emp age agesq male weight
	keep if inlist(year, 1972, 1976, 1992, 1996)
	drop if `i'==.

	reshape wide state `i' emp age agesq male weight, i(hhid) j(year)
	keep if ///
		(male1972==male1976 & (age1976-age1972>=2 & age1976-age1972<=6)) | ///
		(male1992==male1996 & (age1996-age1992>=2 & age1996-age1992<=6))

	reshape long

	drop if weight==.

	gsort +hhid -year
	replace weight = . if year==1972 | year==1992
	by hhid: carryforward weight, gen(weight4yr)

	xtset hhid year

	sum `i'

	gen stateyr = year*100 + state
	tab stateyr, gen(stateyrv)

	// Pooled OLS
	eststo `i'_ols_panel: reg `i' emp age agesq male stateyrv* [aw=weight4yr], cluster(hhid)

	// Within estimator
	eststo `i'_within_panel: xtreg `i' emp age agesq stateyrv* [aw=weight4yr], cluster(hhid) fe

	drop stateyr stateyrv*
}

//------------------------------------------------------------------------------
// Export results
//------------------------------------------------------------------------------

esttab using "table7_aej.html",replace keep(emp) b(3) se(3) nostar ///
	alignment(center) width(60%) nolz

log close
