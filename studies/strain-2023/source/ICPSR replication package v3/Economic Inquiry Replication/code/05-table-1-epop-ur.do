
*** This do file produces the following results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

* Table 1: Unadjusted Differences in EPOP and UR Across Sets of States Ages 25-54, Ages 16-64, and Ages 16 and Over


*** Last updated 8/16/2023

set more off
capture log close
clear results

* Load data
use "$wrkdir/aggregate-analysis.dta", clear

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




*** Table 1: Panel A: EPOP Ages 25-54

preserve 
collapse epop_cps_2554 if inrange(date,733,739) [aw=statepop_2554], by(post stategroup)

reshape wide epop_cps_2554, i(stategroup) j(post)

rename epop_cps_25540 epop_pre
rename epop_cps_25541 epop_post

foreach var of varlist epop_pre-epop_post {
	replace `var' = round(`var', .01)
}

* Column 3
gen epop_change_prepost = epop_post - epop_pre

gen change_noend = epop_change_prepost if stategroup == 1 
egen epop_change_nonending = max(change_noend)

* Column 4
gen epop_change_rel_nonending = epop_change_prepost - epop_change_nonending
replace epop_change_rel_nonending =. if epop_change_rel_nonending == 0

* Column 5
gen epop_change_rel_baseline = epop_change_prepost / epop_pre * 100

drop change_noend epop_change_nonending

foreach var of varlist epop_pre-epop_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var epop_pre "Feb-Jun 2021"
label var epop_post "Jul-Aug 2021"
label var epop_change_prepost "Change"
label var epop_change_rel_nonending "Change Relative to Non-ending States"
label var epop_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-A-epop.csv", replace
restore


*** Table 1 Panel A: Unemployment Rate Ages 25-54

preserve 
collapse ur_cps_2554 if inrange(date,733,739) [aw=statepop_2554], by(post stategroup)

reshape wide ur_cps_2554, i(stategroup) j(post)

rename ur_cps_25540 ur_pre
rename ur_cps_25541 ur_post

foreach var of varlist ur_pre-ur_post {
	replace `var' = round(`var', .001)
}

* Column 3
gen ur_change_prepost = ur_post - ur_pre

gen change_noend = ur_change_prepost if stategroup == 1 
egen ur_change_nonending = max(change_noend)

* Column 4
gen ur_change_rel_nonending = ur_change_prepost - ur_change_nonending
replace ur_change_rel_nonending =. if ur_change_rel_nonending == 0

* Column 5
gen ur_change_rel_baseline = ur_change_prepost / ur_pre * 100

drop change_noend ur_change_nonending

foreach var of varlist ur_pre-ur_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var ur_pre "Feb-Jun 2021"
label var ur_post "Jul-Aug 2021"
label var ur_change_prepost "Change"
label var ur_change_rel_nonending "Change Relative to Non-ending States"
label var ur_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-A-ur.csv", replace
restore








*** Table 1: Panel B: EPOP Ages 16-64

preserve 
collapse epop_cps_1664 if inrange(date,733,739) [aw=statepop_1664], by(post stategroup)

reshape wide epop_cps_1664, i(stategroup) j(post)

rename epop_cps_16640 epop_pre
rename epop_cps_16641 epop_post

foreach var of varlist epop_pre-epop_post {
	replace `var' = round(`var', .01)
}

* Column 3
gen epop_change_prepost = epop_post - epop_pre

gen change_noend = epop_change_prepost if stategroup == 1 
egen epop_change_nonending = max(change_noend)

* Column 4
gen epop_change_rel_nonending = epop_change_prepost - epop_change_nonending
replace epop_change_rel_nonending =. if epop_change_rel_nonending == 0

* Column 5
gen epop_change_rel_baseline = epop_change_prepost / epop_pre * 100

drop change_noend epop_change_nonending

foreach var of varlist epop_pre-epop_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var epop_pre "Feb-Jun 2021"
label var epop_post "Jul-Aug 2021"
label var epop_change_prepost "Change"
label var epop_change_rel_nonending "Change Relative to Non-ending States"
label var epop_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-B-epop.csv", replace
restore


*** Table 1 Panel B: Unemployment Rate Ages 16-64

preserve 
collapse ur_cps_1664 if inrange(date,733,739) [aw=statepop_1664], by(post stategroup)

reshape wide ur_cps_1664, i(stategroup) j(post)

rename ur_cps_16640 ur_pre
rename ur_cps_16641 ur_post

foreach var of varlist ur_pre-ur_post {
	replace `var' = round(`var', .001)
}

* Column 3
gen ur_change_prepost = ur_post - ur_pre

gen change_noend = ur_change_prepost if stategroup == 1 
egen ur_change_nonending = max(change_noend)

* Column 4
gen ur_change_rel_nonending = ur_change_prepost - ur_change_nonending
replace ur_change_rel_nonending =. if ur_change_rel_nonending == 0

* Column 5
gen ur_change_rel_baseline = ur_change_prepost / ur_pre * 100

drop change_noend ur_change_nonending

foreach var of varlist ur_pre-ur_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var ur_pre "Feb-Jun 2021"
label var ur_post "Jul-Aug 2021"
label var ur_change_prepost "Change"
label var ur_change_rel_nonending "Change Relative to Non-ending States"
label var ur_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-B-ur.csv", replace
restore














*** Table 1: Panel C: EPOP Ages 16 and over

preserve 
collapse epop_cps_16plus if inrange(date,733,739) [aw=statepop_16plus], by(post stategroup)

reshape wide epop_cps_16plus, i(stategroup) j(post)

rename epop_cps_16plus0 epop_pre
rename epop_cps_16plus1 epop_post

foreach var of varlist epop_pre-epop_post {
	replace `var' = round(`var', .01)
}

* Column 3
gen epop_change_prepost = epop_post - epop_pre

gen change_noend = epop_change_prepost if stategroup == 1 
egen epop_change_nonending = max(change_noend)

* Column 4
gen epop_change_rel_nonending = epop_change_prepost - epop_change_nonending
replace epop_change_rel_nonending =. if epop_change_rel_nonending == 0

* Column 5
gen epop_change_rel_baseline = epop_change_prepost / epop_pre * 100

drop change_noend epop_change_nonending

foreach var of varlist epop_pre-epop_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var epop_pre "Feb-Jun 2021"
label var epop_post "Jul-Aug 2021"
label var epop_change_prepost "Change"
label var epop_change_rel_nonending "Change Relative to Non-ending States"
label var epop_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-C-epop.csv", replace
restore


*** Table 1 Panel C: Unemployment Rate Ages 16 and over

preserve 
collapse ur_cps_16plus if inrange(date,733,739) [aw=statepop_16plus], by(post stategroup)

reshape wide ur_cps_16plus, i(stategroup) j(post)

rename ur_cps_16plus0 ur_pre
rename ur_cps_16plus1 ur_post

foreach var of varlist ur_pre-ur_post {
	replace `var' = round(`var', .001)
}

* Column 3
gen ur_change_prepost = ur_post - ur_pre

gen change_noend = ur_change_prepost if stategroup == 1 
egen ur_change_nonending = max(change_noend)

* Column 4
gen ur_change_rel_nonending = ur_change_prepost - ur_change_nonending
replace ur_change_rel_nonending =. if ur_change_rel_nonending == 0

* Column 5
gen ur_change_rel_baseline = ur_change_prepost / ur_pre * 100

drop change_noend ur_change_nonending

foreach var of varlist ur_pre-ur_change_rel_baseline {
	replace `var' = round(`var', .01)
}

* Label variables
label var ur_pre "Feb-Jun 2021"
label var ur_post "Jul-Aug 2021"
label var ur_change_prepost "Change"
label var ur_change_rel_nonending "Change Relative to Non-ending States"
label var ur_change_rel_baseline "Percent Change Relative to Baseline"

* Export data to csv file
export delimited using "$tabdir/table-1-panel-C-ur.csv", replace
restore


