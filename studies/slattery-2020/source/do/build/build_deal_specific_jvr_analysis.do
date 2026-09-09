/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
File created:	12/29/2019
Last modified: 	12/29/2019
Modified by:	Dustin Swonder
Description:	This do-file builds an analysis dataset resembling our
				deal_specific_analysis.dta using the deals dataset from 
				Bloom, Nicholas, Erik Brynjolfsson, Lucia Foster, Ron Jarmin, 
				Megha Patnaik, Itay Saporta-Eksten, and John Van Reenen. 2019. 
				"What Drives Differences in Management Practices?" 
				American Economic Review, 109 (5): 1648-83.
*******************************************************************************/

/*******************************************************************************
	(1) Load in data and clean up a bit
*******************************************************************************/

use $rawdir/JVR_deals.dta, clear

rename (decisionyear pair state) (deal_year id stateabbrev)

keep company county state fips winner id deal_year sizemillion sizeemp naics

gsort id -winner
bysort id: gen runnerup_id = _n - 1

order id deal_year winner runnerup_id

/* Performing county-level analysis so only interested in obs where we have 
	county-specific runnerup */
drop if county == ""
rename fips fipscounty

* Manually fix a couple of fips codes
replace fipscounty = 47065 if fips == 47 & county == "Hamilton" & state == "TN"
replace fipscounty = 51143 if fipscounty==51590 // Pittsylvania + Danville, VA
replace fipscounty = 51059 if fipscounty==51600 //Fairfax, Fairfax City + Falls Church, VA

/*******************************************************************************
	(2) Stack data so that we can merge on economic outcomes/controls before and 
		after actual deal year
*******************************************************************************/

tempfile base
save `base'

/* Want to have pulled enough data so that we can control for outcomes 10 yrs 
	in advance and five years after */
qui summ deal_year, detail
local minyr = `r(min)'
gen year = `r(min)' - 10

local startyr = `minyr' - 10 + 1 // already have data in memory for the min year - 10
drop if deal_year > 2012 // want to have five years of data after

forv year = `startyr' / 2017 {
	append using `base'
	qui replace year = `year' if missing(year)
}

/*******************************************************************************
	(3) Get county aggregate employment, average wages, and population
*******************************************************************************/

	/***************************************************************************
		(3.1) Get county aggregate employment from BLS
	***************************************************************************/

merge m:1 year fipscounty using $rawdir/county_unemp_1990_2017.dta, keep(1 3) ///
	nogen keepusing(emp)

lab var emp "Total county employment"

	/***************************************************************************
		(3.2) Get county aggregate average wages from QCEW
	***************************************************************************/

preserve

use $rawdir/qcew_1990_2017_naics1d.dta, clear

drop if fipscounty == 11000 | fipscounty == 11999

correct_fipscounty // program

drop if county == "Unknown Or Undefined"

collapse (sum) annual_avg_emplvl total_annual_wages, by(year fipscounty)

g avg_wages = total_annual_wages/annual_avg_emplvl

keep year fipscounty avg_wages

tempfile avg_wages
save `avg_wages'

restore

merge m:1 year fipscounty using `avg_wages', assert(2 3) keep(3) nogen

	/***************************************************************************
		(3.3) Get population from BEA
	***************************************************************************/

merge m:1 year fipscounty using $processeddir/bea_countyinc.dta, ///
	assert(2 3) keep(3) keepusing(pop) nogen

/*******************************************************************************
	(4) Merge on employment data in industry of deal from QCEW and QWI
*******************************************************************************/

	/***************************************************************************
		(4.1) Make 1, 2, and 3-digit NAICS codes for each observation 
	***************************************************************************/

/* Want to know FX on employment in 3-D industry of deal so only keep obs for
	which we have industry */
drop if missing(naics)

/* Get three-digit NAICS from JVR naics variable, which varies in fineness but can 
	be as fine as 6D */
gen naics3d = real(substr(string(naics), 1, 3))
gen naics2d = floor(naics3d / 10)
gen naics1d = floor(naics2d / 10)

* Make some naics2 codes into range
gen naics2dnum = naics2d
tostring naics2d, replace

replace naics2d = "31-33" if inlist(naics2d, "31", "32", "33")
replace naics2d = "44-45" if inlist(naics2d, "44", "45")
replace naics2d = "48-49" if inlist(naics2d, "48", "49")

	/***************************************************************************
		(4.2) Merge in QCEW outcomes and adjust wage measures for inflation
	***************************************************************************/

* Merge in 1-D and 2-D outcomes
merge m:1 year fipscounty naics1d using $rawdir/qcew_1d_long.dta, ///
	keep(1 3) nogen keepusing(naics*)
merge m:1 year fipscounty naics2d using $rawdir/qcew_2d_long.dta, ///
	keep(1 3) nogen keepusing(naics*)

* Manually fix a few numbers
replace naics2d_emp = 9257 if fipscounty==39027 & year==2000 & naics2d=="48-49"
replace naics2d_wages = 141641458 if fipscounty==39027 & year==2000 & naics2d=="48-49"
replace naics2d_avg_wages = naics2d_wages / naics2d_emp if fipscounty==39027 ///
	& year==2000 & naics2d=="48-49"

* Merge in 3-D outcomes
merge m:1 year fipscounty naics3d using $rawdir/qcew_3d_long.dta, keep(1 3) keepusing(naics*)

adjust_inflation naics?d_wages naics?d_avg_wages, year(2017)

rename _merge merge_qcew3d

	/***************************************************************************
		(4.3) Supplement QCEW data with QWI data if we're missing QCEW data
	***************************************************************************/

rename naics3d industry // for merge
rename emp emp_bls
merge m:1 year fipscounty industry using $rawdir/qwi_avgs.dta, keep(1 3) ///
	keepusing(emp semp payroll firm_count)
rename emp emp_qwi
rename emp_bls emp
rename industry naics3d

adjust_inflation payroll, year(2017)

* Label variables from QWI so their equivalent in QCEW is clear
rename (firm_count payroll) (est_qwi wages_qwi)
replace emp_qwi = round(emp_qwi)

foreach var in emp wages est { // Cycle through emp, wages, est, where there are exact analogs in QWI
	replace naics3d_`var' = `var'_qwi if _merge == 3 & /// replace w/ QWI value if missing data
							merge_qcew3d == 1 & !missing(`var'_qwi)
	replace naics3d_`var' = `var'_qwi if _merge == 3 & /// replace w/ QWI value if emp = 0 in QCEW
							merge_qcew3d == 3 & `var'_qwi & naics3d_`var' == 0 
	replace naics3d_`var' = . if _merge==3 & merge_qcew3d == 3 & semp == 5 & /// missing otherwise
							missing(`var'_qwi) & naics3d_emp == 0 
}

* Do the same for avg_wages, where QWI equiv. has to be constructed
replace naics3d_avg_wages = naics3d_wages / naics3d_emp if _merge==3 & ///
	merge_qcew3d == 1 & !missing(wages_qwi) & emp_qwi != 0
replace naics3d_avg_wages = naics3d_wages/naics3d_emp if _merge==3 & ///
	merge_qcew3d == 3 & !missing(wages_qwi) 
replace naics3d_avg_wages = . if _merge == 3 & merge_qcew3d == 3 & ///
	semp == 5  & missing(emp_qwi) & missing(naics3d_emp)

drop *_qwi semp _merge merge_qcew3d // drop variables we needed for QWI imputing

replace naics3d_est = . if missing(naics3d_emp) // # establishments missing if # employees missing

/*******************************************************************************
	(5) Put data in event-time format
*******************************************************************************/

gen eventyr = year - deal_year + 100

*prepare to reshape
tostring eventyr, replace 
replace eventyr = "_" + eventyr
drop year state 

reshape wide emp avg_wages* pop naics?d_*, ///
	i(fipscounty id runnerup_id) j(eventyr, string)

order emp* avg_wages* naics?d_*, alphabetic last

/*******************************************************************************
	(6) Make control variables for regressions
*******************************************************************************/

foreach control in pop_90 emp_90 avg_wages_90 {
	gen ln_`control' = log(`control')
}

/*******************************************************************************
	(7) Sort'n'save
*******************************************************************************/

sort id fipscounty

save $processeddir/deal_specific_jvr_analysis.dta, replace