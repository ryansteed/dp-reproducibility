/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	01/02/2020
Modified by:	Dustin Swonder
Description:	This do-file builds an auxiliary analysis dataset which is 
				location-based rather than deal-based (e.g. each row is a 
				location-year, not a deal). It is built by merging various 
				state- and county-level outcomes onto a processed version of 
				Slattery (2019)'s subsidies dataset.
*******************************************************************************/

	/***************************************************************************
		1) Start with county-level data on industry shares of employment and 
			wages from wide QCEW files
	***************************************************************************/

* Clean up county characteristics
use $rawdir/qcew_1990_2017_naics1d.dta, clear

* drop DC state
drop if fipscounty == 11000 | fipscounty == 11999

correct_fipscounty // program

drop if county == "Unknown Or Undefined"

collapse (sum) annual_avg_estabs_count annual_avg_emplvl total_annual_wages, ///
	by(year fipscounty statename fips state naics1)

g avg_annual_pay = total_annual_wages/annual_avg_emplvl

* Rename vars
rename annual_avg_estabs_count est
rename annual_avg_emp emp
rename total_annual_wages wages
rename avg_annual_pay avg_wages

* Adjust to 2017 USD
adjust_inflation wages avg_wages, year(2017)

* Clean naics var
tostring naics, replace
replace naics = "_ind"+naics
replace naics = "_tot" if naics=="_ind."

drop wages // don't need 'em

* reshape wide
reshape wide est emp avg_wages, ///
	i(year fipscounty statename fips state) j(naics1, string)

drop est* 

* Fill in missing emp with 0
foreach var of varlist emp* { 
	replace `var' = 0 if missing(`var')
}

* gen total
lab var emp_tot "Total employment"
lab var avg_wages_tot "Avg wages by county"

egen emp_tmp = rowtotal(emp_ind*) 
replace emp_tot = emp_tmp if emp_tot==0
drop emp_tmp

* gen share of emp by industry
forv i=1/8{
	g sh_emp_ind`i' = emp_ind`i'/emp_tot*100

	lab var sh_emp_ind`i' "Share of this county's emp in NAICS `i'"
}

drop emp_tot // don't want total employment from QCEW as main emp measure; will undercount gov, ag workers

* label
forv i=1/8 {
	lab var emp_ind`i' "Emp in NAICS `i'"
	lab var avg_wages_ind`i' "Avg wages in NAICS `i'"
}

rename avg_wages_tot avg_wages

order year fipscounty emp* avg_wages*

	/***************************************************************************
		2) Merge other county economic characteristics
	***************************************************************************/

* Merge UE rate
merge 1:1 year fipscounty using $rawdir/county_unemp_1990_2017.dta, keep(1 3) nogen
lab var unemp "Unemployment rate (%)"
lab var emp "Employment in county"

/* BEA county dataset; not a perfect merge for some counties in VA, 
	whose estimates are coupled up and inseparable */
merge 1:1  fipscounty year using $processeddir/bea_countyinc.dta, ///
	assert(2 3) keep(3) nogen keepusing(stateabbrev personal_inc* pop)

* adjust personal income for inflation
adjust_inflation personal_inc*, year(2017)

lab var personal_inc "Personal income (1000s 2017 USD)"
lab var personal_inc_pc "Personal income per capita (2017 USD)"

sort fipscounty year

* Merge county identifiers
merge m:1 fipscounty using $rawdir/alt_xwalk_countyfips_190305.dta, assert(2 3) keep(3) nogen

* Take logs of appropriate variables and label
foreach var of varlist pop* emp* avg_wages* personal_inc* {
	g ln_`var' = log(`var')
}

forv i = 1 / 8 {
	lab var ln_emp_ind`i' "log emp in NAICS `i'"
	lab var ln_avg_wages_ind`i' "log avg wages in NAICS `i'"
}

	/***************************************************************************
		3) Use subset of data (from 1990, 2000, 2010, 2017) to form differences
			variables in long format
	***************************************************************************/
	
keep if inlist(year, 1990, 2000, 2010, 2017)

tostring year, replace
replace year = "_" + year

qui ds year fipscounty  statename fips state stateabbrev county, not
reshape wide `r(varlist)', i(fipscounty  statename fips state stateabbrev county) j(year, string)

drop state statename

order fipscounty county stateab 

compress

* label
foreach yr in 1990 2000 2010 2017{
	forv i=1/8{
		lab var emp_ind`i'_`yr' "Emp in NAICS `i' (`yr')"
		lab var ln_emp_ind`i'_`yr' "log emp in NAICS `i' (`yr')"
		lab var avg_wages_ind`i'_`yr' "Avg wages in NAICS `i' (2017 USD) (`yr')"
		lab var ln_avg_wages_ind`i'_`yr' "log avg wages in NAICS `i' (`yr')"

		lab var sh_emp_ind`i'_`yr' "% emp in NAICS `i' (`yr')"
	}

	lab var emp_`yr' "Employment (`yr')"
	lab var avg_wages_`yr' "Average wages (2017 USD) (`yr')"
	lab var ln_emp_`yr' "log employment (`yr')"
	lab var ln_avg_wages_`yr' "log average wages (`yr')"
	lab var pop_`yr' "Population (`yr')"
	lab var ln_pop_`yr' "log population (`yr')"
	lab var personal_inc_`yr' "Personal income (1000s 2017 USD) (`yr')"
	lab var ln_personal_inc_`yr' "log personal income  (`yr')"

	lab var personal_inc_pc_`yr' "Personal income per capita (2017 USD) (`yr')"
	lab var ln_personal_inc_pc_`yr' "log Personal income per capita (`yr')"

	lab var unemp_`yr' "Unemployment rate (`yr')"
}

tempfile fipschars
save `fipschars'

	/***************************************************************************
		4) Prepare dataset of winning counties to merge with wide dataset of
			county characteristics we've made above
	***************************************************************************/

use $processeddir/firm_level_subsidy_runnerup.dta, clear

correct_fipscounty // program

keep if winner == 1

keep if deal_year <= 2012

keep fipscounty winner naics3d hasthreat

unique fipscounty // 200 unique values, 352 records

duplicates tag fipscounty, gen(tag)
/* gen naics_random = naics4 if tag == 0 */ // for counties w/ > one deal won, set ind. = ind. of one deal
gen naics_random = naics3d if tag == 0 // for counties w/ > one deal won, set ind. = ind. of one deal

/* For counties with more than one deal won, assign county a random industry from 
	among the industries of deals they won */
qui levelsof fipscounty if tag > 0, local(fips)

foreach ff in `fips' {
	qui g order = (fipscounty == `ff')
	gsort -order
	qui g p = runiform() if fipscounty == `ff'

	local q = tag[1] + 1
	qui xtile group = p, nq(`q')
	/* qui replace naics_random = naics4 if group == 1 & fipscounty == `ff' */
	qui replace naics_random = naics3d if group == 1 & fipscounty == `ff'

	drop order p group
}

drop if missing(naics_random)
drop naics_random 

rename (tag naics3d hasthreat) (numdeals_win naics3d_winner hasthreat_winner)
replace numdeals_win = numdeals_win+1

lab var naics3d_winner "Industry of deal (randomly selected if mutiple wins)"
lab var numdeals_win "Number of deals won between 2002 and 2012"
lab var hasthreat_winner "Whether this deal has a runner-up county"

tempfile winners
save `winners'

	/***************************************************************************
		5) Merge winners dataset to wide county characteristics dataset
	***************************************************************************/

use `fipschars', clear
merge 1:1 fipscounty using `winners', assert(1 3)

replace winner = (_merge==3)
drop _merge
replace numdeals_win = 0 if missing(numdeals_win)

save `fipschars', replace

	/***************************************************************************
		6) Prep runners-up to be merge onto wide county characteristics dataset 
			as well
	***************************************************************************/
		
*Clean up a bit
use $processeddir/firm_level_subsidy_runnerup.dta, clear

capture drop __000* // get rid of tempvar residue

correct_fipscounty //program

keep if winner == 0 & hasthreat == 1
unique id // assert 273 unique ids; 373 total records

rename winner runnerup

keep if deal_year <= 2012 // ensure data set balanced

keep fipscounty runnerup naics3d

duplicates tag fipscounty, gen(tag)
gen naics_random = naics3d if tag == 0 // for counties w/ one deal won, set ind. = ind. of one deal

qui levelsof fipscounty if tag>0, local(fips)

/* For counties in which winning county had more than one deal, assign county a 
	random industry from among the industries of deals the winning county won; 
	will be same random industry as the random industry in section 5 */
foreach ff in `fips'{
	qui g order = (fipscounty==`ff')
	gsort -order
	qui g p = runiform() if fipscounty==`ff'

	local q = tag[1]+1
	qui xtile group = p, nq(`q')
	qui replace naics_random = naics3d if group==1 & fipscounty==`ff'

	drop order p group
}

drop if missing(naics_random)
drop naics_random 

rename (tag naics3d) (numdeals_runnerup naics3d_runnerup)
replace numdeals_runnerup = numdeals_runnerup+1

lab var naics3d_runnerup "Industry of deal (randomly selected if runnerup mutiple times)"
lab var numdeals_runnerup "Number of deals in which runnerup between 2002 and 2012"

tempfile runnerup
save `runnerup'

	/***************************************************************************
		7) Merge runners-up dataset to wide county characteristics dataset
	***************************************************************************/

use `fipschars', clear
merge 1:1 fipscounty using `runnerup', assert(1 3)

replace runnerup = (_merge==3)
drop _merge

replace numdeals_runnerup = 0 if missing(numdeals_runnerup)

order fipscounty winner runnerup hasthreat

qui compress

lab var winner "=1 if county wins any deals between 2002 and 2012"
lab var runnerup "=1 if county is listed as the runnerup in any deals between 2002 and 2012"

	/***************************************************************************
		8) Merge demographic data from Census
	***************************************************************************/
	
preserve
use  $processeddir/demographics_census_2000_2010_bycounty.dta, clear

replace fipscounty = 46102 if fipscounty == 46113 //Shannon SD becomes Oglala Lakota SD
replace fipscounty = 02158 if fipscounty == 02270 // Wade Hampton Census Area, AK becomes Kusilvak Census Area, AK 

tempfile census
save `census'
restore

merge m:1 fipscounty using  `census', nogen assert(2 3) keep(3)

	/***************************************************************************
		8) Merge land area
	***************************************************************************/
		
preserve
import delimited using $rawdir/DEC_10_SF1_GCTPH1.US05PR.csv, clear

rename (v5 v10 v12) (fipscounty totalarea landarea)

drop in 1/2

keep fipscounty totalarea landarea

destring *, replace

drop if fipscounty<1000 | fipscounty==.

correct_fipscounty

collapse (sum) totalarea  landarea, by(fipscounty)

tempfile area
save `area'
restore

drop if inlist(fipscounty, 2201, 2232, 2280)
merge 1:1 fipscounty using `area', nogen assert(2 3) keep(3)

foreach yr in 1990 2000 2010 2017 {
	g pop_density_`yr' = pop_`yr' / landarea
	lab var pop_density_`yr' "Population density (per sq mile of land area) (`yr')"
}

drop landarea totalarea

	/***************************************************************************
		9) Clean census data
	***************************************************************************/

* log
foreach var of varlist median_grossrent_* median_houvalue_* hou_units* {
	qui g ln_`var' = log(`var')
}

drop median_grossrent_* median_houvalue_* hou_units*

rename county countyname
g county = fipscounty

foreach yr in 2000 2010 {
	lab var ln_hou_units_`yr' "log housing units (`yr')"
	lab var ln_median_houvalue_`yr' "log median house value (2017 USD) (`yr')"
	lab var ln_median_grossrent_`yr' "log median gross rent (2017 USD) (`yr')"
	lab var urban_`yr' "% urban (`yr')"
	lab var white_`yr' "% white (`yr')"
	lab var foreign_`yr' "% foreign (`yr')"
	lab var hispanic_`yr' "% hispanic (`yr')"
	lab var ba_over25_`yr' "% Bachelor's or more (`yr')"
}

lab var hasthreat_winner "=1 if the deal had a runnerup, =0 if not, =. if not a winner county"

	/***************************************************************************
		10) Sort'n'save
	***************************************************************************/

sort fipscounty 

save $processeddir/firm_location_analysis.dta, replace