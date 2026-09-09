/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	01/03/2020
Modified by:	Dustin Swonder
Description:	This do-file builds the core analysis dataset, which is used
				directly in some exhibits and all other analysis datasets. It 
				takes the most recently updated version of Slattery (2019) 
				subsidy data.
*******************************************************************************/

	/***************************************************************************
		Import raw data (need access to internal data in order to run commented 
			section here)
	***************************************************************************/

/* import excel using $internaldir/data/raw/subsidy_deal_raw_JEP.xlsx, ///
	clear firstrow

keep firm year state county sub_M jobs_direct jobs_retain invest_M threat_clean ///
	threat_county naics4

rename (sub_M threat_clean jobs_direct jobs_retain) (subsidy threat_state new_jobs retain_jobs)

adjust_inflation subsidy invest_M, year(2017)

ds, has(type string) // trim all the string variables
foreach variable in `r(varlist)' {
	replace `variable' = ltrim(rtrim(`variable'))
}

destring retain_jobs invest_M, replace
gen jobs = cond(!missing(retain_jobs), new_jobs + retain_jobs, new_jobs)

* create an id for each deal and year
egen id = group(firm year subsidy jobs naics4)

order id
sort id

gen naics3d = floor(naics4 / 10)

keep id year state county threat_state threat_county naics3d

save $rawdir/subsidy_deal_raw_JEP_external.dta, replace */

use $rawdir/subsidy_deal_raw_JEP_external.dta, replace

* rename year
rename year deal_year

* For VW deal (deal 512), want to count both Limestone & Madison counties
replace threat_county = "Limestone, Madison" if id == 518 /* VW deal ID */ & threat_county == "Limestone"

	/***************************************************************************
		Clean up county, state names and get the right correspondencies between 
			county and state
	***************************************************************************/

* Identify winner state and county
rename (state county) (winner_state winner_county)

* Clean up county names
foreach tt in threat winner {
	replace `tt'_county = subinstr(`tt'_county, " Parish", "", .)
	replace `tt'_county = subinstr(`tt'_county, " and ", ", ", .)
}

* Correct a few errors

* Only want one winner county
replace winner_county = "Wayne" if id == 3 & winner_county == "Wayne, Washtenaw"
replace winner_county = "Oconee" if id == 103 & winner_county == "Oconee,  Clarke"
replace winner_county = "Sumter" if id == 131 & winner_county == "Sumter, Lancaster"
replace winner_county = "St Lucie" if id == 154 & winner_county == "St. Lucie, Palm Beach"
replace winner_county = "Whitfield" if id == 178 & winner_county == "Whitfield, Murray"
replace winner_county = "Wake" if id == 326 & winner_county == "Wake, Mecklenburg"
replace winner_county = "Lexington" if id == 329 & winner_county == "Lexington, Anderson"
replace winner_county = "Morris" if id == 400 & winner_county == "Morris, Burlington"
replace winner_county = "Union" if id == 484 & winner_county == "Pontotoc, Union, Lee"

* Need to have comma + space in state names
replace threat_state = "AL, TX, KY, AR" if threat_state == "AL,TX, KY, AR"

replace threat_state = "SC, " + threat_state if regexm(threat_county, "Lancaster \+ York, Palm Beach, Fairfax")
replace threat_county = subinstr(threat_county, " + ", ", ", .)

replace threat_state = "GA, GA, AR, OK "  if threat_county == "Dougherty, Hancock, Miller"
replace threat_county = subinstr(threat_county, " + ", ", ", .)

foreach var in winner threat { // No such county as Winnebago, AL
	replace `var'_state = "IL" if `var'_state == "AL" & `var'_county == "Winnebago"
}

* Finish clean up county
foreach tt in threat winner {
	replace `tt'_county = rtrim(ltrim(subinstr(`tt'_county, ", ", ",", .)))
}

* Identify runner up states and counties
split threat_state, parse(", ")
split threat_county, parse(",")
drop threat_state threat_county

/* Deal with records with more threat counties than threat states for which state
	name is given in county name */
forv i = 1/4 {
	replace threat_state`i' = substr(threat_county`i', strpos(threat_county`i', "(") + 1, 2) if strpos(threat_county`i', "(") > 0
	
	* Get rid of state abbrev in threat_county; no longer needed
	replace threat_county`i' = substr(threat_county`i', 1, strpos(threat_county`i', " (") - 1) if strpos(threat_county`i', "(") > 0
}

* For states with multiple threat counties, but only one threat state, fill down
forv i = 2 / 4 {
	local n1 = `i' - 1

	g temp`i' = (threat_state`i'=="" & threat_county`i' != "")

	replace threat_state`i' = threat_state`n1' if temp`i'==1

	drop temp`i'
}

* Create variables so that we can include winners in the same var
gen threat_state0 = winner_state
gen threat_county0 = winner_county

* reshape
reshape long threat_state threat_county, i(id) j(threat_num)

* winner indicator
gen winner = (threat_num == 0)

* merge winner fips
rename winner_state stateabbrev
merge m:1 stateabbrev using "$rawdir/fips_statenames_xwalk.dta", assert(2 3) keep(3) nogen keepusing(fips)
rename (stateabbrev fips) (winner_state winner_fips)

* merge threat fips; only non-matches should be outside US 
rename threat_state stateabbrev
merge m:1 stateabbrev using "$rawdir/fips_statenames_xwalk.dta", keep(1 3) keepusing(fips)
assert stateabbrev == "outside US" | stateabbrev == "" if _merge == 1
drop _merge
rename (stateabbrev fips) (threat_state threat_fips)

* Clean up state and counties
replace threat_state = "Foreign" if threat_state=="outside US"
foreach tt in winner threat{
	replace `tt'_county = subinstr(`tt'_county, "St. ", "St ", .)
	replace `tt'_county = "DeSoto" if `tt'_county=="Desoto" & `tt'_fips==22 //to ensure matches
	replace `tt'_county = "DuPage" if `tt'_county=="Dupage" & `tt'_fips==17 //to ensure matches
	replace `tt'_county = "Isle Of Wight" if `tt'_county == "Isle of Wight" // to ensure matches
	replace `tt'_county = "Dekalb" if `tt'_county == "DeKalb" // to ensure matches
	replace `tt'_county = "Prince William" if `tt'_county == "Price William" // misspelled
	replace `tt'_county = "Miami-Dade" if `tt'_county=="Dade" & `tt'_fips==12 
	replace `tt'_county = "New York City" if `tt'_county=="New York" & `tt'_fips==36
	replace `tt'_county = "Mecklenburg" if `tt'_county=="Mecklenberg" & `tt'_fips==37
	replace `tt'_county  = subinstr(`tt'_county, "Mcc", "McC", .) if inlist(`tt'_fips, 21, 30, 40, 45, 46, 48)
	replace `tt'_county  = "Charlottesville City" if `tt'_county=="Charlottesville" & `tt'_fips==51

	replace `tt'_county = ltrim(rtrim(`tt'_county))
}

* merge county fips, winner
rename (winner_county winner_fips) (county fips)
merge m:1 fips county using "$rawdir/alt_xwalk_countyfips_190305.dta", keep(1 3) keepusing(fipscounty) nogen
rename (county fips fipscounty) (winner_county winner_fips winner_fipscounty)

* merge county fips, threat
rename (threat_county threat_fips) (county fips)
merge m:1 fips county using "$rawdir/alt_xwalk_countyfips_190305.dta", keep(1 3) keepusing(fipscounty)
assert county == "" if _merge == 1
drop _merge
rename (county fips fipscounty) (threat_county threat_fips threat_fipscounty)

* compress
compress

* Sort
gsort id -winner
sort id threat_num

* Drop empty rows 
drop if threat_state == ""

* number of contenders
tempvar threat_num_tmp 
gen `threat_num_tmp' = cond(threat_county == "", ., threat_num)
egen num_contenders = max(`threat_num_tmp'), by(id)
replace num_contenders = num_contenders + 1

* has county threat
g hasthreat = (num_contenders > 1 & threat_county != "")

unique id // should have 543
preserve

keep if hasthreat == 1
unique id // should have 278

restore

rename threat_num runnerup_id

* Drop the winner variables and rename
drop winner_*

* rename threat variables to streamline
foreach var of varlist threat_* {
	local varname  = subinstr("`var'", "threat_", "", .)
	rename `var' `varname'
}

rename state stateabbrev

* Label
lab var runnerup_id "= 0 for the winning county, 1 for the runner up, and 2, 3, ... for each additional runner-up"
lab var winner "= 1 for the winning county, 0 otherwise"

lab var num_contenders "Number of runner-up counties + winner"
lab var hasthreat "=1 if has runnerup county listed in the data"

	/***************************************************************************
		Sort and save
	***************************************************************************/

capture drop __000* // Get rid of tempvar residue if present
sort id runnerup_id
compress

save $processeddir/firm_level_subsidy_runnerup.dta, replace