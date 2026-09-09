
*** This do file produces the following results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 


* Table 1: Unadjusted Differences in Robust U-E Transitions Across Sets of States Ages 25-54, Ages 16-64, and Ages 16 and Over			


* Last updated: 8/16/2023

clear all 
capture log close 
set more off

* Load data
use "$wrkdir/individual-analysis.dta", replace

* Generate post variable after June
cap drop post
gen post =.
replace post = 0 if inrange(month,2,6)
replace post = 1 if inrange(month,7,8)

* Generate state categories for unadjusted differences table 
gen stategroup =.
replace stategroup = 1 if endallstate == 0
replace stategroup = 2 if endonlyfpuc == 1
replace stategroup = 3 if endallstate == 1

drop if post ==.
drop if stategroup ==.

label define statelabel 1 "Ending Neither PUA nor FPUC" 2 "Ending FPUC but not PUA" 3 "Ending Both PUA and FPUC"
label values stategroup statelabel 

*** Table 1: Panel A: UE-E Transitions Ages 25-54

preserve 
collapse UEtoE_2m if age2554 == 1 & inrange(date,733,739) [aw=panlwt], by(post stategroup)

reshape wide UEtoE_2m, i(stategroup) j(post)

rename UEtoE_2m0 UEtoE_pre
rename UEtoE_2m1 UEtoE_post

foreach var of varlist UEtoE_pre-UEtoE_post {
	replace `var' = round(`var', .01)
}

* Column 3
gen UEtoE_change_prepost = UEtoE_post - UEtoE_pre

gen change_noend = UEtoE_change_prepost if stategroup == 1 
egen UEtoE_change_nonending = max(change_noend)

* Column 4
gen UEtoE_change_rel_nonending = UEtoE_change_prepost - UEtoE_change_nonending
replace UEtoE_change_rel_nonending =. if UEtoE_change_rel_nonending == 0

* Column 5
gen UEtoE_change_rel_baseline = UEtoE_change_prepost / UEtoE_pre * 100

drop change_noend UEtoE_change_nonending

foreach var of varlist UEtoE_pre-UEtoE_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var UEtoE_pre "Feb-Jun 2021"
label var UEtoE_post "Jul-Aug 2021"
label var UEtoE_change_prepost "Change"
label var UEtoE_change_rel_nonending "Change Relative to Non-ending States"
label var UEtoE_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-A-ue-transitions.csv", replace
restore





*** Table 1 Panel B: UE-E Transitions Ages 16-64

preserve 
collapse UEtoE_2m if age1664 == 1 & inrange(date,733,739) [aw=panlwt], by(post stategroup)

reshape wide UEtoE_2m, i(stategroup) j(post)

rename UEtoE_2m0 UEtoE_pre
rename UEtoE_2m1 UEtoE_post

foreach var of varlist UEtoE_pre-UEtoE_post {
	replace `var' = round(`var', .01)
}

* Column 3
gen UEtoE_change_prepost = UEtoE_post - UEtoE_pre

gen change_noend = UEtoE_change_prepost if stategroup == 1 
egen UEtoE_change_nonending = max(change_noend)

* Column 4
gen UEtoE_change_rel_nonending = UEtoE_change_prepost - UEtoE_change_nonending
replace UEtoE_change_rel_nonending =. if UEtoE_change_rel_nonending == 0

* Column 5
gen UEtoE_change_rel_baseline = UEtoE_change_prepost / UEtoE_pre * 100

drop change_noend UEtoE_change_nonending

foreach var of varlist UEtoE_pre-UEtoE_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var UEtoE_pre "Feb-Jun 2021"
label var UEtoE_post "Jul-Aug 2021"
label var UEtoE_change_prepost "Change"
label var UEtoE_change_rel_nonending "Change Relative to Non-ending States"
label var UEtoE_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-B-ue-transitions.csv", replace
restore








*** Table 1 Panel C: UE-E Transitions Ages 16 plus

preserve 
collapse UEtoE_2m if age16plus == 1 & inrange(date,733,739) [aw=panlwt], by(post stategroup)

reshape wide UEtoE_2m, i(stategroup) j(post)

rename UEtoE_2m0 UEtoE_pre
rename UEtoE_2m1 UEtoE_post

foreach var of varlist UEtoE_pre-UEtoE_post {
	replace `var' = round(`var', .01)
}

* Column 3
gen UEtoE_change_prepost = UEtoE_post - UEtoE_pre

gen change_noend = UEtoE_change_prepost if stategroup == 1 
egen UEtoE_change_nonending = max(change_noend)

* Column 4
gen UEtoE_change_rel_nonending = UEtoE_change_prepost - UEtoE_change_nonending
replace UEtoE_change_rel_nonending =. if UEtoE_change_rel_nonending == 0

* Column 5
gen UEtoE_change_rel_baseline = UEtoE_change_prepost / UEtoE_pre * 100

drop change_noend UEtoE_change_nonending

foreach var of varlist UEtoE_pre-UEtoE_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var UEtoE_pre "Feb-Jun 2021"
label var UEtoE_post "Jul-Aug 2021"
label var UEtoE_change_prepost "Change"
label var UEtoE_change_rel_nonending "Change Relative to Non-ending States"
label var UEtoE_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-C-ue-transitions.csv", replace
restore

est clear