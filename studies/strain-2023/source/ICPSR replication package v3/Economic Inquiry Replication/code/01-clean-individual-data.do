
*** This do file generates the main individual-level dataset used to 
*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain


*** Inputs:

* FPUC_and_work_search_full.xlsx
* oxford-government-response-11-24-2021.xlsx"
* cps-data.dta
* state_fips_master.dta

*** Outputs:

* individual-analysis.dta

*** Last updated 8/15/2023

set more off
capture log close
clear all

* Set tempfiles for merging
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

label var endfpucstate "Ending FPUC in June 2021"

* Generate treatment variable for states that end either FPUC or PUA.
gen endanystate =.
replace endanystate = 0 if policygroup == 4
replace endanystate = 1 if inlist(policygroup,1,2,3)
replace endanystate =. if inlist(statefip,4,18,22,24,47)

label var endallstate "Ending Either FPUC or PUA in June 2021"

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

label var endfpucandpua "Ending Both FPUC and PUA in June 2021"

compress

drop if statefip ==.

save `fpuc', replace


* Load oxford government response data as of November 24, 2021
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

keep confirmedcases confirmeddeaths stringencyindex date state_abbr year month

* Merge with state crosswalk
merge m:1 state_abbr using "$dtadir/state_fips_master.dta"
tab state_abbr if _merge !=3
drop if _merge != 3
drop _merge

* Collapse to state-month data
collapse (max) confirmedcases confirmeddeaths (mean) stringencyindex, by(statefip year month date)

* Generate monthly change in cases by state 
tsset statefip date, monthly delta(1)

gen newcases = D.confirmedcases
gen newdeaths = D.confirmeddeaths

* Generate ln of new cases and deaths each month
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

label var employed "Employed"

* Drop if empstat = niu or armed forces
drop if empstat == 0 | empstat == 1

* Drop people under 16
drop if age < 16

* Generate labor force indicator
gen inlabforce = 0
replace inlabforce = 100 if labforce == 2

label var inlabforce "In Labor Force"

* Generate unemployment indicator
gen unemployed =.
replace unemployed = 0 if inlabforce == 100 & employed == 100
replace unemployed = 100 if inlabforce == 100 & employed == 0

label var unemployed "Unemployed"

* Generate NILF indicator
gen nilf = 0 
replace nilf = 100 if inlabforce == 0 & employed == 0

label var nilf "Not in Labor Force"

xtset cpsidp date, monthly

rename wtfinl perwt

* Generate "backward" transition indicators. For a transition from unemployment to employment in June 2021 for example,
* we look back at labor market status in May 2021 to see if things change
gen EtoE = 0 if L.employed == 100
gen EtoNE = 0 if L.employed == 100
gen EtoUE = 0 if L.employed == 100

gen NEtoE = 0 if L.employed == 0 & L.inlabforce == 0
gen NEtoNE = 0 if L.employed == 0 & L.inlabforce == 0
gen NEtoUE = 0 if L.employed == 0 & L.inlabforce == 0

gen UEtoNE = 0 if L.unemployed == 100

gen UEtoE = 0 if L.unemployed == 100
gen UEtoUE = 0 if L.unemployed == 100

bysort cpsidp: replace EtoE = 100 if L.employed == 100 & employed == 100
bysort cpsidp: replace EtoNE = 100 if L.employed == 100 & employed == 0 & inlabforce == 0
bysort cpsidp: replace NEtoE = 100 if L.employed == 0 & L.inlabforce == 0 & employed == 100
bysort cpsidp: replace NEtoNE = 100 if L.employed == 0 & L.inlabforce == 0 & employed == 0 & inlabforce == 0

bysort cpsidp: replace EtoUE = 100 if L.employed == 100 & unemployed == 100 
bysort cpsidp: replace UEtoNE = 100 if L.unemployed == 100 & employed == 0 & inlabforce == 0 
bysort cpsidp: replace NEtoUE = 100 if L.employed == 0 & L.inlabforce == 0 & unemployed == 100
bysort cpsidp: replace UEtoE = 100 if L.unemployed == 100 & employed == 100
bysort cpsidp: replace UEtoUE = 100 if L.unemployed == 100 & unemployed == 100

* Robust transition indicators 
* for individuals identified as leaving unemployment one month, either through job finding or labor force exit, and then
* returning to unemployment the next month, their records are recoded to show no transition (and
* the newly created observations are retained)

gen NEtoE_2m = NEtoE
gen UEtoNE_2m = UEtoNE 
gen NEtoUE_2m = NEtoUE
gen UEtoE_2m = UEtoE
gen EtoUE_2m = EtoUE
gen EtoNE_2m = EtoNE

bysort cpsidp: replace UEtoNE_2m = 0 if L.unemployed == 100 & employed == 0 & inlabforce == 0 & F.unemployed == 100
bysort cpsidp: replace UEtoE_2m = 0 if L.unemployed == 100 & employed == 100 & F.employed == 0 & F.unemployed == 100


* Set to missing if not observed because first month is in rotation 4 or 8 
bysort cpsidp: replace NEtoE_2m =. if inlist(mish,4,8)
bysort cpsidp: replace NEtoUE_2m =. if inlist(mish,4,8)
bysort cpsidp: replace UEtoNE_2m =. if inlist(mish,4,8)
bysort cpsidp: replace UEtoE_2m =. if inlist(mish,4,8)
bysort cpsidp: replace EtoUE_2m =. if inlist(mish,4,8)
bysort cpsidp: replace EtoNE_2m =. if inlist(mish,4,8)

* Do this so we are working from the same sample months for all transitions

* Label variables
label var EtoE "E-E"
label var EtoNE "E-NILF"
label var EtoUE "E-UE"

label var UEtoUE "UE-UE"
label var UEtoE "UE-E"
label var UEtoNE "UE-NILF"

label var NEtoNE "NILF-NILF"
label var NEtoE "NILF-E"
label var NEtoUE "NILF-UE"

label var EtoNE_2m "E-NILF Robust"
label var EtoUE_2m "E-UE Robust"

label var UEtoE_2m "UE-E Robust"
label var UEtoNE_2m "UE-NILF Robust"

label var NEtoE_2m "NILF-E Robust"
label var NEtoUE_2m "NILF-UE Robust"


* Flag the cases that don't appear to match sex or age when they should
capture gen dsex =.
capture gen dage =.
capture gen drace =.
capture drop dfemale dfemalef dagef
bysort cpsidp (mish): replace dsex = abs(sex-sex[_n-1])
bysort cpsidp (mish): replace drace = abs(race-race[_n-1])
bysort cpsidp (mish): replace dage = abs(age-age[_n-1])

gen byte dage2 = (dage<0 | dage>1) if dage<.
gen byte drace2 = drace !=0 & !missing(drace)

label var dsex "Diff with lagged sex"
label var drace "Diff with lagged race"
label var dage "Diff with lagged age"
label var dage2 "Out of range lagged age"
tab dsex dage2
tab dsex drace2

capture gen dsexf =.
capture gen dagef =.
capture gen dracef =.

bysort cpsidp (mish): replace dsex = abs(sex[_n+1]-sex)
bysort cpsidp (mish): replace drace = abs(race[_n+1]-race)
bysort cpsidp (mish): replace dage = abs(age[_n+1]-age)

gen byte dage2f = (dage<0 | dagef>1) if dagef<.
gen byte drace2f = drace !=0 & !missing(drace)

label var dsexf "Diff with forward sex"
label var dracef "Diff with forward race"
label var dagef "Diff with forward age"
label var dage2f "Out of range forward age"

tab dsex dsexf
tab drace2 drace2f
tab dage2 dage2f

* Set transition variables to missing where race sex or age changes for individuals between survey rounds
foreach var of varlist NE* UE* E* {
	replace `var' =. if dsex == 1 | dage2 == 1 | drace2 == 1
}

* Set transition variables to missing where race sex or age changes for individuals between survey rounds
foreach var of varlist NE*_2m UE*_2m E*_2m {
	replace `var' =. if dsexf == 1 | dage2f == 1 | drace2f == 1
}

*** Construct education variables
gen dropout = 0 
replace dropout = 1 if educ < 73
gen highschool = 0 
replace highschool = 1 if educ == 73
gen somecollege = 0
replace somecollege = 1 if educ >= 81 & educ <= 92
gen collegeplus = 0
replace collegeplus = 1 if educ >= 111

label var dropout "< HS education"
label var highschool "= HS education"
label var somecollege "> HS & < BA education"
label var collegeplus ">= BA education"

* Redefine date variable
drop date
gen date = ym(year, month)

gen Date = date
format Date %tmnn/YY

* Generate sample indicators
gen age16plus = 1 if age >= 16 & !missing(age)
label var age16plus "Ages 16 and Over"

gen age1664 = 1 if inrange(age,16,64)
label var age1664 "Ages 16-64"

gen age2554 = 1 if inrange(age,25,54)
label var age2554 "Ages 25-54"

sort statefip year month

* Merge data on COVID cases and restrictions
merge m:1 statefip year month using `restrictions'

tab month year if _merge == 1
tab month year if _merge == 2

drop if _merge == 2
drop _merge

* Merge data on ending FPUC and PUA
merge m:1 statefip using `fpuc'
drop if _merge == 2
drop _merge

* Redefine date variable
drop date
gen date = ym(year, month)

label var date

keep if inrange(year,2019,2021)

keep if date <= 740

* Drop uneeded variables
drop serial hwtfinl cpsid asecflag pernum marst citizen hispan empstat labforce ///
absent whyunemp whyabsnt whyptlwk dsex dage drace dage2 drace2 dsexf dagef dracef dage2f drace2f

drop end_both_fpuc_pua-policygroup covidtelew-covidlook 

drop uhrsworkt ahrsworkt durunemp wkstat earnwt ///
hourwage paidhour earnweek eligorg dropout highschool somecollege collegeplus occ occ1990 ind1990 ind compwt lnkfw1mwt

drop fpuc_opt_out-min_contacts endpuastate endanystate

label var lnnewcases "Ln New Monthly Covid 19 Cases"
label var endonlyfpuc "State Ended Only FPUC in June 2021"
label var endfpucandpua "State Ended Both FPUC and PUA in June 2021"

compress

* Save data for futher analysis
save "$wrkdir/individual-analysis.dta", replace