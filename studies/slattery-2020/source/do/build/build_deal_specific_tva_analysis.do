/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	01/02/2020
Modified by:	Dustin Swonder
Description:	This file builds an auxiliary analysis dataset containing 
				only subsidy winners which are in sample; it resembles 
				deal_specific_analysis.dtaby. It is built by merging various 
				state- and county-level outcomes onto a processed version of 
				Slattery (2019)'s subsidies dataset.
*******************************************************************************/

	/***************************************************************************
		1) Start by making county-level data on county-level average wages from 
			wide QCEW file
	***************************************************************************/

* clean up county characteristics
use $rawdir/qcew_1990_2017_naics1d.dta, clear

drop if fipscounty == 11000 | fipscounty == 11999 // Drop DC

correct_fipscounty // program

collapse (sum) annual_avg_emplvl total_annual_wages, by(year fipscounty statename fips state naics1)

gen avg_annual_pay = total_annual_wages / annual_avg_emplvl

* Rename vars
rename annual_avg_emp emp
rename total_annual_wages wages
rename avg_annual_pay avg_wages

* Adjust to 2017 USD
adjust_inflation wages avg_wages, year(2017)

keep if missing(naics) // only want to get aggregates at this stage
drop naics1d

* Fill in missing emp with 0
foreach var of varlist emp* wages* {
	replace `var' = 0 if missing(`var')
}

/* lab var wages_tot "Total wages by county" */
lab var avg_wages "Avg wages by county"

drop emp wages*

order year fipscounty avg_wages*

rename state stateabbrev 
drop statename

* get county names
merge m:1 fipscounty using "$rawdir/alt_xwalk_countyfips_190305.dta", ///
	keepusing(county) assert(2 3) keep(3) nogen

order year fipscounty stateab county avg_wages*

	/***************************************************************************
		2) Merge other county economic characteristics and save as long file 
			with county-level data
	***************************************************************************/

* UE and employment from BLS LAUS
merge 1:1 year fipscounty using $rawdir/county_unemp_1990_2017.dta, ///
	keep(1 3) nogen
lab var unemp "Unemployment rate (%)"
lab var emp "Total county employment"

/* BEA county dataset; not a perfect merge for some counties in VA, 
	whose estimates are coupled up and inseparable */
merge 1:1 fipscounty year using $processeddir/bea_countyinc.dta, /*
	*/ assert(2 3) keep(3) nogen keepusing(stateabbrev personal_inc* pop)

* Adjust personal income for inflation
adjust_inflation personal_inc*, year(2017)

lab var personal_inc "Personal income (1000s 2017 USD)"
lab var personal_inc_pc "Personal income per capita (2017 USD)"

sort fipscounty year

* Merge county identifiers
merge m:1 fipscounty using $rawdir/alt_xwalk_countyfips_190305.dta, ///
	assert(2 3) keep(3) nogen

* Compute logs of variables
foreach var of varlist pop* emp* avg_wages* personal_inc* {
	gen ln_`var' = log(`var')
}
	/***************************************************************************
		3) Label and save as tempfile to be merged to deals dataset
	***************************************************************************/

lab var avg_wages "Average wages (2017 USD)"
lab var ln_avg_wages "log average wages"
lab var ln_pop "log population"
lab var ln_personal_inc_pc "log personal income per capita"
lab var ln_personal_inc "log personal income"

tempfile longfips 
save `longfips'

	/***************************************************************************
		4) Prepare deals dataset to merge
	***************************************************************************/
	
use $processeddir/firm_level_subsidy_runnerup.dta, clear
drop if hasthreat == 0

correct_fipscounty // program

/* Keep deals balanced on both sides; want to be able to have five years before 
	and after deal */
keep if inrange(deal_year, 1995, 2012)

/* Need to stack years so we can get pre-deal and post-deal outcomes for winner 
	and runner-up counties */
tempfile main
save `main'

g year = 1990

forv yr = 1991 / 2017 {
	append using `main'
	replace year = `yr' if missing(year)
}

order year id runnerup_id fipscounty 

	/***************************************************************************
		5) Merge big county-level data we made in 1)-2), plus housing data
	***************************************************************************/

capture drop __000000 // get rid of tempvar residue if present

merge m:1 year fipscounty using `longfips', assert(2 3) keep(3) nogen

merge m:1 year fipscounty using $processeddir/HPI_AT_BDL_county.dta, ///
	keepusing(ln_HPI) keep(1 3) nogen

	/***************************************************************************
		6) Merge county data on emp, wages, establishments, etc. in 
			industry of deal
	***************************************************************************/
	
		/***********************************************************************
			6.1) Sort out NAICS codes and prepare to merge to both QCEW
					and QWI
		***********************************************************************/

gen naics2d = floor(naics3d / 10)
gen naics1d = floor(naics2d / 10)

tostring naics2d, replace 

replace naics2d = "31-33" if inlist(naics2d, "31", "32", "33")
replace naics2d = "44-45" if inlist(naics2d, "44", "45")
replace naics2d = "48-49" if inlist(naics2d, "48", "49")

merge m:1 year fipscounty naics1d using $rawdir/qcew_1d_long.dta, keep(1 3) nogen //Hancock GA missing MFG data in 2005, 2006
merge m:1 year fipscounty naics2d using $rawdir/qcew_2d_long.dta, keep(1 3) nogen //Hancok GA missing MFG data in 2005, 2006, and 
	* Clinton County OH is missing 492 (Couriers and Messengers) in 1999 and 2000. We can input 2000 from the QWI

* manually input one industry in one county and year
replace naics2d_emp = 9257 if fipscounty==39027 & year==2000 & naics2d=="48-49"
replace naics2d_wages = 141641458 if fipscounty==39027 & year==2000 & naics2d=="48-49"
replace naics2d_avg_wages = naics2d_wages / naics2d_emp if fipscounty==39027 & year==2000 & naics2d=="48-49"

merge m:1 year fipscounty naics3d using $rawdir/qcew_3d_long.dta, keep(1 3) 

rename _merge merge_qcew3d

		/***********************************************************************
			6.2) Supplement QCEW variables with QWI data if QCEW data missing
		***********************************************************************/

rename naics3d industry
rename emp emp_full

merge m:1 year fipscounty industry using $rawdir/qwi_avgs.dta, ///
	keepusing(emp semp payroll) keep(1 3)

rename emp emp_qwi
rename emp_full emp
rename industry naics3d

* Check that these corrections are fine
egen minmerge = min(merge_qcew3d), by(fipscounty naics3d)

adjust_inflation payroll, year(2017)

rename payroll wages_qwi // label variables from QWI so their equivalent in QCEW is clear
replace emp_qwi = round(emp_qwi)

// Cycle through emp, wages, est, where there are exact analogs in QWI
foreach var in emp wages /* est */ {
	replace naics3d_`var' = `var'_qwi if _merge == 3 & /// replace w/ QWI value if missing data
							merge_qcew3d == 1 & !missing(`var'_qwi)
	replace naics3d_`var' = `var'_qwi if _merge == 3 & /// replace w/ QWI value if emp = 0 in QCEW
							merge_qcew3d == 3 & `var'_qwi & naics3d_`var' == 0 
	replace naics3d_`var' = . if _merge==3 & merge_qcew3d == 3 & semp == 5 & /// missing otherwise
							missing(`var'_qwi) & naics3d_emp == 0 
}

replace naics3d_avg_wages = naics3d_wages / naics3d_emp if _merge == 3 & merge_qcew3d == 1 ///
							& !missing(wages_qwi) & emp_qwi != 0

replace naics3d_avg_wages = naics3d_wages / naics3d_emp if _merge == 3 & merge_qcew3d == 3 ///
							& !missing(wages_qwi) 

replace naics3d_avg_wages = . if _merge == 3 & merge_qcew3d==3 & semp==5  & missing(emp_qwi) ///
							& missing(naics3d_emp)

drop *_qwi semp _merge minmerge merge_qcew3d // drop variables we needed for QWI imputing

			/*******************************************************************
				6.3) Create residuals and logs of local economic economic 
						variables; label all of these
			*******************************************************************/

* Before creating residual category, replace missing with 0
foreach var of varlist *_emp *_wages {
	replace `var' = 0 if missing(`var')
}
			
* Get logs and residuals for employment variables at industry levels
gen emp_res = emp - naics3d_emp
gen ln_emp_res = log(emp - naics3d_emp)

forv i = 1/3 {
	gen naics`i'd_ln_emp = log(naics`i'd_emp)
	if `i' != 3 { 
		gen naics`i'd_emp_res = naics`i'd_emp - naics3d_emp
		gen naics`i'd_ln_emp_res = log(naics`i'd_emp - naics3d_emp)
	}
}

* Replace zeros with missing
foreach var of varlist *_emp *_wages *_res {
	replace `var' = . if `var' == 0
}

			/*******************************************************************
				6.4) Create differences variables out of a subset of the 
					variables we've just merged in for years 1990, 2000, 2010, 
					and 2017. Merge these variables back in later.
			*******************************************************************/
			
preserve
keep id runnerup_id year naics1d_* naics2d_* naics3d_*

drop *_res *est* 

keep if inlist(year, 1990, 2000, 2010, 2017)
tostring year, replace
replace year = "_" + year

reshape wide naics1d_* naics2d_* naics3d_*, i(id runnerup_id) j(year, string)

drop *_2010 *_2017

tempfile indofdeal_2000
save `indofdeal_2000'

restore

	/***************************************************************************
		7) Transition into event-time, reshape, and relabel variables
	***************************************************************************/
	
gen eventyr = (year - deal_year) + 100
keep if inrange(eventyr, 90, 105)

* Prepare to reshape
tostring eventyr, replace 
replace eventyr = "_" + eventyr
drop year state statename 

reshape wide emp emp_res pop personal_inc personal_inc_pc avg_wages unemp ln_* ///
	naics1d_* naics2d_* naics3d_*, i(fipscounty id runnerup_id) j(eventyr, string)

order id runnerup_id winner fipscounty county stateab naics3d *_9* *_10*

	/***************************************************************************
		8) Merge back in the differences variables we made in step 6.4
	***************************************************************************/

merge 1:1 id runnerup_id using  `indofdeal_2000', assert(3) nogen

	/***************************************************************************
		9) For VW deal, want to combine Madison & Limestone county numbers to 
			form a "Huntsville, AL" entry
	***************************************************************************/

preserve

keep if id == 518 & winner == 0 // Keep only runners-up in competition for VW 2008

tempfile mainVW
save `mainVW'

		/***********************************************************************
			9.1) Make combined data for variables we have for each event year
		***********************************************************************/

forv i = 90/105 { // Get combined data from event years 90-105
	use `mainVW', clear
	
	* Only keep variables in the event year in question
	keep id deal_year runnerup_id winner hasthreat stateabbrev naics3d *_`i'
	
	qui ds naics?d_emp* naics?d_est* emp* pop* personal_inc_`i'
	local sumlist = "`r(varlist)'" // List of variables we need to sum over two counties when we collapse
	
	qui ds naics?d_avg_wages_* avg_wages* unemp* ln_HPI* personal_inc_pc*
	local avglist = "`r(varlist)'" // List of variables we need to average (pop-weighted) over two counties when we collapse
	
	collapse (firstnm) id winner hasthreat stateabbrev naics3d deal_year ///
		(rawsum) `sumlist' (mean) `avglist' (min) runnerup_id [aw = pop]

	gen countyname = "Limestone, Madison"
	
	qui ds avg_wages* emp* personal_inc* pop* naics* 
	
	foreach variable in `r(varlist)' { // Get logs of variables which we summed to get
		if regexm("`variable'", "naics") & !regexm("`variable'", "4"){
			local firstpart = substr("`variable'", 1, 7)
			local secondpart = substr("`variable'", 9, .)
			gen `firstpart'_ln_`secondpart' = log(`variable')
		}
		else {
			gen ln_`variable' = log(`variable')
		}
	}
	
	tempfile VW`i'
	save `VW`i''
}

		/***********************************************************************
			9.2) Put together combined data as single ob for Huntsville; drop 
				separate Limestone and Madison county observations
		***********************************************************************/

use `VW90'
forv i = 91 / 105 {
	merge 1:1 id using `VW`i'', assert(3) nogen
}

gen fips = 0 // need to have nonmissing fips for purpose of clustering by fips

tempfile VW_runnerup
save `VW_runnerup'

restore 

append using `VW_runnerup'
drop if id == 518 & inlist(county, "Limestone", "Madison")

	/***************************************************************************
		10) Sort'n'save
	***************************************************************************/

sort fipscounty 

save $processeddir/deal_specific_tva_analysis.dta, replace