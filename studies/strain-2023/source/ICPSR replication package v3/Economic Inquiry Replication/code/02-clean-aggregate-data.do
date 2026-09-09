

*** This do file generates the main state-level dataset used to 
*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain


*** Inputs:
* FPUC_and_work_search_full.xlsx
* oxford-government-response-11-24-2021.xlsx
* cps-data.dta
* state_fips_master.dta

*** Outputs:
* aggregate-analysis.dta

*** Last updated 8/15/2023



set more off
capture log close
clear all

* Set tempfiles for merging

tempfile cpslevels_16plus
tempfile cpstransitions_16plus
tempfile cpslevels_1664
tempfile cpstransitions_1664
tempfile cpslevels_2554
tempfile cpstransitions_2554


tempfile restrictions
tempfile fpuc


* Load FPUC data
import excel "$dtadir/FPUC_and_work_search_full.xlsx", sheet("Sheet1") firstrow case(lower) clear

* Generate duimmies for which states ended which programs
gen end_both_fpuc_pua = 0
replace end_both_fpuc_pua = 1 if fpuc_opt_out == 1 & pua_opt_out == 1

label var end_both_fpuc_pua "Ended Both FPUC and PUA Before September 2021"

gen end_only_fpuc = 0
replace end_only_fpuc = 1 if fpuc_opt_out == 1 & pua_opt_out == 0

label var end_only_fpuc "Ended Only FPUC Before September 2021"

gen end_only_pua = 0
replace end_only_pua = 1 if fpuc_opt_out == 0 & pua_opt_out == 1

label var end_only_pua "Ended Only PUA Before September 2021"

gen end_neither_fpuc_pua = 0
replace end_neither_fpuc_pua = 1 if fpuc_opt_out == 0 & pua_opt_out == 0

label var end_neither_fpuc_pua "Ended Neither FPUC and PUA Before September 2021"

gen reinstated_fpuc_pua = 0
replace reinstated_fpuc_pua = 1 if inlist(statefip,18,24)

label var reinstated_fpuc_pua "Ended FPUC or PUA and later reinstated by court order" 

gen policygroup = 1
replace policygroup = 2 if end_only_fpuc == 1
replace policygroup = 3 if end_only_pua == 1
replace policygroup = 4 if end_neither_fpuc_pua == 1
replace policygroup = 5 if reinstated_fpuc_pua == 1

label define policylabel 1 "FPUC & PUA" 2 "Only FPUC" 3 "Only PUA" 4 "Neither" 5 "Challenged"
label values policygroup policylabel

*** Generate variables for ending PUA and/or FPUC

* Generate treatment variable
* Drop Indiana, Maryland, Louisiana, and Tennessee from the sample
* Drop Arizona Indiana, Maryland, Louisiana, and Tennessee from the sample since they did not formally end until July 2021
gen endallstate =.
replace endallstate = 0 if policygroup == 4
replace endallstate = 1 if policygroup == 1
replace endallstate =. if inlist(statefip,4,18,22,24,47)

label var endallstate "Ending Both FPUC and PUA in June 2021"

* Generate separate variable for states that only end FPUC. States that end both or neither are coded as 0.
gen endonlyfpuc =.
replace endonlyfpuc = 0 if policygroup == 1 | policygroup == 4
replace endonlyfpuc = 1 if inlist(statefip,2,12,39)
replace endonlyfpuc =. if inlist(statefip,4,18,22,24,47)

label var endonlyfpuc "Ending Only FPUC in June 2021"

* Generate separate treatment variable for states that end both FPUC and PUA. States ending only FPUC coded as 0.
* Drop Arizona Indiana, Maryland, Louisiana, and Tennessee from the sample since they did not formally end until July 2021
gen endfpucandpua =.
replace endfpucandpua = 0 if inlist(statefip,2,12,39) | policygroup == 4
replace endfpucandpua = 1 if policygroup == 1
replace endfpucandpua =. if inlist(statefip,4,18,22,24,47)

label var endfpucandpua "Ending Both FPUC and PUA in June 2021 (Code states only ending FPUC as 0)"

compress

drop if statefip ==.

save `fpuc', replace




* Load government response data as of November 24, 2021
import excel "$dtadir/oxford-government-response-11-24-2021.xlsx", sheet("Sheet1") firstrow case(lower) clear

tostring(date), replace
gen Date = date(date, "YMD")

gen year = year(Date)
gen month = month(Date)

drop date

* Generate US state
split regioncode, parse("_") gen(geo)

keep if geo1 == "US" & !missing(geo2)
rename geo2 state_abbr

gen date = ym(year, month)

egen numstates = nvals(state_abbr)
tab numstates

keep confirmedcases confirmeddeaths stringencyindex  date state_abbr year month

* Merge with state crosswalk
merge m:1 state_abbr using "$dtadir/state_fips_master.dta"
tab state_abbr if _merge !=3
drop if _merge != 3
drop _merge

* Collapse to state-month data
collapse (max) confirmedcases confirmeddeaths (mean) stringencyindex, by(statefip year month date)

* Generate monthly changes in case numbers
tsset statefip date, monthly delta(1)

gen newcases = D.confirmedcases
gen newdeaths = D.confirmeddeaths

* Generate ln of new monthly cases and deaths

gen lnnewcases = ln(newcases)
gen lnnewdeaths = ln(newdeaths)


save `restrictions', replace

* Load CPS data
use "$dtadir/cps-data.dta", clear

gen date = ym(year, month)
format date %tm

* Generate employment indicator for epop ratio
gen employed = 0
replace employed = 100 if inlist(empstat, 10, 12)

* Generate employment indicator for total employment
gen emp = 0
replace emp = 1 if inlist(empstat, 10, 12)

* Drop if empstat = niu or armed forces
drop if empstat == 0 | empstat == 1

* Drop people under 16
drop if age < 16

* Drop if ineligible for the labor force
*drop if labforce == 0

* Generate labor force indicator for LFPR
gen inlabforce = 0
replace inlabforce = 100 if labforce == 2

* Generate labor force indicator for Total Labor Force
gen laborforce = 0
replace laborforce = 1 if labforce == 2

* Generate unemployment indicator
gen unemployed =.
replace unemployed = 0 if inlabforce == 100 & employed == 100
replace unemployed = 100 if inlabforce == 100 & employed == 0

* Generate unemployment indicator for Total Unemployed
gen unemp =.
replace unemp = 0 if inlabforce == 100 & employed == 100
replace unemp = 1 if inlabforce == 100 & employed == 0

* Generate NILF indicator
gen nilf = 0 
replace nilf = 100 if inlabforce == 0 & employed == 0

* Generate employment as a share of labor force
gen employedlabforce =.
replace employedlabforce = 0 if inlabforce == 100 & employed == 0
replace employedlabforce = 100 if inlabforce == 100 & employed == 100

gen val = 1

bysort cpsidp: egen nvals = sum(val)

tab nvals

xtset cpsidp date, monthly

rename wtfinl perwt

gen population = 1

foreach v in employed inlabforce unemployed nilf {
	local levelslab  "`levelslab' (mean) mean_`v'=`v' (max) max`v'=`v'"
}


*** Employment Levels Ages 16 and Over
preserve
collapse (mean) employed inlabforce unemployed nilf (sum) totemp_16plus=emp totlabforce_16plus=laborforce totunemp_16plus=unemp statepop_16plus=population if age >= 16 [pw=perwt], by(statefip year month)

rename employed epop_cps_16plus
rename inlabforce lfpr_cps_16plus
rename unemployed ur_cps_16plus
rename nilf nilf_cps_16plus

label var epop_cps_16plus "EPOP CPS Ages 16 and Over"
label var lfpr_cps_16plus "LFPR CPS Ages 16 and Over"
label var ur_cps_16plus "UR CPS Ages 16 and Over"
label var nilf_cps_16plus "NILF CPS Ages 16 and Over"
label var statepop_16plus "State Population Ages 16 and Over"

label var totemp_16plus "Total Employed Ages 16 and Over"
label var totlabforce_16plus "Total Labor Force Ages 16 and Over"
label var totunemp_16plus "Total Unemployed Ages 16 and Over"

save `cpslevels_16plus', replace

restore

* Employment Levels Ages 16-64
preserve
collapse (mean) employed inlabforce unemployed nilf (sum) totemp_1664=emp totlabforce_1664=laborforce totunemp_1664=unemp population if inrange(age,16,64) [pw=perwt], by(statefip year month)

rename employed epop_cps_1664
rename inlabforce lfpr_cps_1664
rename unemployed ur_cps_1664
rename nilf nilf_cps_1664
rename population statepop_1664

label var epop_cps_1664 "EPOP CPS Ages 16-64"
label var lfpr_cps_1664 "LFPR CPS Ages 16-64"
label var ur_cps_1664 "UR CPS Ages 16-64"
label var nilf_cps_1664 "NILF CPS Ages 16-64"
label var statepop_1664 "State Population Ages 16-64"

label var totemp_1664 "Total Employed Ages 16-64"
label var totlabforce_1664 "Total Labor Force Ages 16-64"
label var totunemp_1664 "Total Unemployed Ages 16-64"

save `cpslevels_1664', replace

restore

*** Employment Levels Ages 25-54
preserve
collapse (mean) employed inlabforce unemployed nilf (sum) totemp_2554=emp totlabforce_2554=laborforce totunemp_2554=unemp population if inrange(age,25,54) [pw=perwt], by(statefip year month)

rename employed epop_cps_2554
rename inlabforce lfpr_cps_2554
rename unemployed ur_cps_2554
rename nilf nilf_cps_2554
rename population statepop_2554

label var epop_cps_2554 "EPOP CPS Ages 25-54"
label var lfpr_cps_2554 "LFPR CPS Ages 25-54"
label var ur_cps_2554 "UR CPS Ages 25-54"
label var nilf_cps_2554 "NILF CPS Ages 25-54"
label var statepop_2554 "State Population Ages 25-54"

label var totemp_2554 "Total Employed Ages 25-54"
label var totlabforce_2554 "Total Labor Force Ages 25-54"
label var totunemp_2554 "Total Unemployed Ages 25-54"

save `cpslevels_2554', replace

restore

* Merge datasets together
use `cpslevels_2554', clear

* Merge CPS Data on aggregate employment, LFP and unemployment and transition rates ages 16-64
merge 1:1 statefip year month using `cpslevels_1664'

tab month year if _merge == 1
tab month year if _merge == 2

drop if _merge == 2
drop _merge

* Merge CPS Data on aggregate employment, LFP and unemployment and transition rates ages 16 and over
merge 1:1 statefip year month using `cpslevels_16plus'

tab month year if _merge == 1
tab month year if _merge == 2

drop if _merge == 2
drop _merge

* Merge data on COVID cases and restrictions
merge 1:1 statefip year month using `restrictions'

tab month year if _merge == 1
tab month year if _merge == 2

drop if _merge == 2
drop _merge

* For observations in 2019 and before, set all COVID variables to 0
foreach var of varlist newcases newdeaths stringencyindex {
	replace `var' = 0 if `var' ==. 
}

* Redefine date variable
drop date
gen date = ym(year, month)

* Merge data on ending FPUC and PUA
merge m:1 statefip using `fpuc'
drop if _merge == 2
drop _merge

keep if inrange(year,2019,2021)

keep if date <= 740

sort statefip year month

* Keep needed variables
drop fpuc_opt_out-policygroup confirmedcases confirmeddeaths newcases newdeaths

label var lnnewcases "Ln New Monthly State Covid-19 Cases"
label var lnnewdeaths "Ln New Monthly State Covid-19 Deaths"
label var stringencyindex "Mean Monthly Stringency Index"
label var endonlyfpuc "State Ended Only FPUC in June 2021"
label var endfpucandpua "State Ended Both FPUC and PUA in June 2021"


* Save data for futher analysis
save "$wrkdir/aggregate-analysis.dta", replace