*** This do file cleans the Household Pulse Survey data for for the Holzer Hubbard Strain UI paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

*** Inputs:
* FPUC_and_work_search_full.xlsx
* oxford-government-response-11-24-2021.xlsx
* cps-data.dta
* state_fips_master.dta

*** Outputs:
* hps-analysis.dta

*** Last updated: 8/16/2023

set more off
capture log close 
clear all


* Set tempfiles for merging
tempfile restrictions
tempfile fpuc





* Load FPUC data
import excel "$dtadir/FPUC_and_work_search_full.xlsx", sheet("Sheet1") firstrow case(lower) cellrange(A1:T52) clear

* Generate duimmies for which states ended which programs
gen both_fpuc_pua = 0
replace both_fpuc_pua = 1 if fpuc_opt_out == 1 & pua_opt_out == 1

gen only_fpuc = 0
replace only_fpuc = 1 if fpuc_opt_out == 1 & pua_opt_out == 0

gen only_pua = 0
replace only_pua = 1 if fpuc_opt_out == 0 & pua_opt_out == 1

gen neither_fpuc_pua = 0
replace neither_fpuc_pua = 1 if fpuc_opt_out == 0 & pua_opt_out == 0

gen reinstated_fpuc_pua = 0
replace reinstated_fpuc_pua = 1 if inlist(statefip,18,24)

gen policygroup = 1
replace policygroup = 2 if only_fpuc == 1
replace policygroup = 3 if only_pua == 1
replace policygroup = 4 if neither_fpuc_pua == 1
replace policygroup = 5 if reinstated_fpuc_pua == 1

label define policylabel 1 "FPUC & PUA" 2 "Only FPUC" 3 "Only PUA" 4 "Neither" 5 "Challenged"
label values policygroup policylabel

* Generate treatment variable
* Drop Indiana, Maryland, Louisiana, and Tennessee from the sample
gen endallstate =.
replace endallstate = 0 if policygroup == 4
replace endallstate = 1 if policygroup == 1
replace endallstate =. if inlist(statefip,4,18,22,24,47)

* Generate treatment variable for states that only end PUA
gen endpuastate =.
replace endpuastate = 0 if policygroup == 4
replace endpuastate = 1 if policygroup == 3
replace endpuastate =. if inlist(statefip,4,18,22,24,47)

* Generate treatment variable for states that only end FPUC. States that end both are coded as missing
* Drop Arizona Indiana, Maryland, Louisiana, and Tennessee from the sample since they did not formally end until July 2021
gen endfpucstate =.
replace endfpucstate = 0 if policygroup == 4
replace endfpucstate = 1 if policygroup == 2
replace endfpucstate =. if inlist(statefip,4,18,22,24,47)

* Generate treatment variable for states that end either FPUC or PUA.
gen endanystate =.
replace endanystate = 0 if policygroup == 4 | policygroup == 5
replace endanystate = 1 if inlist(policygroup,1,2,3)
replace endanystate =. if inlist(statefip,4,18,22,24,47)

* Generate sepaate variable for states that only end FPUC. States that end both or neither are coded as 0.
gen endonlyfpuc =.
replace endonlyfpuc = 0 if policygroup == 1 | policygroup == 4
replace endonlyfpuc = 1 if inlist(statefip,2,12,39)
replace endonlyfpuc =. if inlist(statefip,4,18,22,24,47)

* Generate separate treatment variable for states that end both FPUC and PUA. States ending only FPUC coded as 0.
gen endfpucandpua =.
replace endfpucandpua = 0 if inlist(statefip,2,12,39) | policygroup == 4
replace endfpucandpua = 1 if policygroup == 1 
replace endfpucandpua =. if inlist(statefip,4,18,22,24,47)


save `fpuc', replace

* Load government response data
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

keep confirmedcases confirmeddeaths stringencyindex governmentresponseindex containmenthealthindex economicsupportindex date state_abbr

* Merge with state crosswalk
merge m:1 state_abbr using "$dtadir/state_fips_master.dta"
tab state_abbr if _merge !=3
drop if _merge != 3
drop _merge

* Collapse to state-month data
collapse (max) confirmedcases confirmeddeaths (mean) stringencyindex governmentresponseindex containmenthealthindex economicsupportindex, by(statefip date)

* Generate 1, 3 and 6 month lags of the stringency and other restrictions indicies
tsset statefip date, monthly delta(1)

gen newcases = D.confirmedcases
gen newdeaths = D.confirmeddeaths

* Generate log of cases and deaths
gen lnnewcases = ln(newcases)
gen lnnewdeaths = ln(newdeaths)

save `restrictions', replace



















**** NOW LOAD AND CLEAN HPS DATA


display td(19aug2020)
display td(18jan2021)
display td(14apr2021)
display td(21jul2021)


tempfile building
clear    // START WITH NO DATA IN MEMORY
save `building', emptyok

*** Import and clean available weeks
forvalues i = 22/39 {
    
	import delimited "$dtadir/hps/pulse_puf_`i'.csv", clear
	gen time = `i'
	
	append using `building', force
    qui save `building', replace
}

*** Keep only needed variables
keep scram tbirth_year egender ///
pweight est_st eeduc time week expns_dif

* Set -99, -88 codes to missing for all numeric variables
foreach var of varlist * {
	capture confirm numeric var `var'
	if _rc==0 {
		replace `var' =. if `var' == -99
		replace `var' =. if `var' == -88
	}
}

rename est_st statefip

* Merge statefip codes
merge m:1 statefip using "$dtadir/state_fips_master.dta"
drop _merge

gen begin_date = .
gen end_date = .

* Week 1 starts on May 5
forvalues i = 1/12 {
	replace begin_date = 22033 + 7 * `i' if time == `i'
	replace end_date = 22040 + 7 * `i' if time == `i'
}

* There is a gap between weeks 12 and 13 and the periodicity changes so we need to adjust the date
* Week 13 starts on August 19 and ends on August 31
forvalues i = 13/21 {
	replace begin_date = 22146 - 182 + 14 * `i' if time == `i'
	replace end_date = 22158 - 182 + 14 * `i' if time == `i'
}
*/
* Week 22 starts on January 6 and ends on January 18
forvalues i = 22/27 {
	replace begin_date = 22286 - 308 + 14 * `i' if time == `i'
	replace end_date = 22298 - 308 + 14 * `i' if time == `i'
}


* Week 28 starts on April 14 and ends on April 26
forvalues i = 28/33 {
	replace begin_date = 22384 - 392 + 14 * `i' if time == `i'
	replace end_date = 22396 - 392 + 14 * `i' if time == `i'
}

* Week 34 starts on July 21 and ends on August 2
forvalues i = 34/39 {
	replace begin_date = 22482 - 476 + 14 * `i' if time == `i'
	replace end_date = 22494 - 476 + 14 * `i' if time == `i'
}

format begin_date %td
format end_date %td

gen year = year(end_date)
gen month = month(end_date)

gen age = year - tbirth_year

tab age

* Difficulty meeting expenses if not at all difficult
gen expens_not_difficult =.  
replace expens_not_difficult = 0 if inlist(expns_dif,2,3,4)
replace expens_not_difficult = 1 if inlist(expns_dif,1)

* Assign HPS dates to CPS months and years when merging

cap drop month year

gen month =.
replace month = 1 if inlist(week,22,23)
replace month = 2 if inlist(week,24,25)
replace month = 3 if inlist(week,26,27)
replace month = 4 if inlist(week,1,28)
replace month = 5 if inlist(week,2,3,4,5,29,30,31)
replace month = 6 if inlist(week,6,7,8,9,32,33)

replace month = 7 if inlist(week,10,11,12,34)
replace month = 8 if inlist(week,13,35,36)
replace month = 9 if inlist(week,14,15,37,38)
replace month = 10 if inlist(week,16,17,18,39)
replace month = 11 if inlist(week,19,20)
replace month = 12 if inlist(week,21)

gen year = 2020 if inrange(week,1,21)
replace year = 2021 if inrange(week,22,39)

* Generate share of households that had no difficulty meeting expenses ages 25-54
egen share_expens_not_diff_2554 = wtmean(expens_not_difficult) if inrange(age,25,54), by(statefip end_date) weight(pweight)

* Generate share of households that had no difficulty meeting expenses ages 18-64
egen share_expens_not_diff_1864 = wtmean(expens_not_difficult) if inrange(age,18,64), by(statefip end_date) weight(pweight)

* Generate share of households that had no difficulty meeting expenses ages 18 and over
egen share_expens_not_diff_18plus = wtmean(expens_not_difficult) if inrange(age,18,90), by(statefip end_date) weight(pweight)

label var share_expens_not_diff_2554 "Share no difficulty meeting expenses ages 25-54"
label var share_expens_not_diff_1864 "Share no difficulty meeting expenses ages 18-64"
label var share_expens_not_diff_18plus "Share no difficulty meeting expenses ages 18 and over"

* Multiply shares by 100
replace share_expens_not_diff_1864 = 100 * share_expens_not_diff_1864 
replace share_expens_not_diff_2554 = 100 * share_expens_not_diff_2554 
replace share_expens_not_diff_18plus = 100 * share_expens_not_diff_18plus


gen statepop_2554 = pweight if inrange(age,25,54)
gen statepop_1864 = pweight if inrange(age,18,64)
gen statepop_18plus = pweight if inrange(age,18,90)

drop if year < 2021

keep statefip share* year month

collapse (mean) share*, by(statefip month year)

gen date = ym(year, month)

xtset statefip date, monthly

* Merge data on COVID cases and deaths and economic restrictions
merge 1:1 statefip date using `restrictions'
drop if _merge == 2
drop _merge

* Merge data on ending FPUC and PUA by state
merge m:1 statefip using `fpuc'
drop if _merge == 2
drop _merge


keep statefip month year share_expens_not_diff_2554 share_expens_not_diff_1864 share_expens_not_diff_18plus date stringencyindex lnnewcases endonlyfpuc endfpucandpua

label var statefip "State FIPS code"
label var month "Month"
label var stringencyindex "Mean Monthly Stringency Index"
label var lnnewcases "Ln New Monthly Covid 19 Cases"
label var endonlyfpuc "State Ended Only FPUC in June 2021"
label var endfpucandpua "State Ended Both FPUC and PUA in June 2021"

compress

* Save data
save "$wrkdir/hps-analysis.dta", replace