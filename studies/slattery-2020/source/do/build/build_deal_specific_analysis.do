/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	03/02/2020
Modified by:	Dustin Swonder
Description:	This file builds the main analysis dataset by merging various 
				state- and county-level outcomes onto a processed version of 
				Slattery (2019)'s subsidies dataset.
*******************************************************************************/
	
	/***************************************************************************
		1) Start with county-level data on industry shares of employment and 
			wages from wide QCEW files
	***************************************************************************/

* clean up county characteristics
use $rawdir/qcew_1990_2017_naics1d.dta, clear

* drop DC state
drop if fipscounty == 11000 | fipscounty == 11999

correct_fipscounty // program

drop if county == "Unknown Or Undefined"

collapse (sum) annual_avg_emplvl total_annual_wages, /*
	*/ by(year fipscounty statename fips state naics1)

gen avg_annual_pay = total_annual_wages/annual_avg_emplvl

* Rename vars
rename annual_avg_emp emp
rename total_annual_wages wages
rename avg_annual_pay avg_wages

* Adjust to 2017 USD
adjust_inflation wages avg_wages, year(2017)

* Clean naics var
tostring naics, replace
replace naics = "_ind" + naics
replace naics = "_tot" if naics=="_ind."

* reshape wide
reshape wide emp wages avg_wages, /*
	*/ i(year fipscounty statename fips state) j(naics1, string)

* Fill in missing emp with 0
foreach var of varlist emp* wages* {
	replace `var' = 0 if missing(`var')
}

* Generate total variables
lab var wages_tot "Total wages by county"
lab var avg_wages_tot "Avg wages by county"

* gen share of emp by industry
forv i=1/8{
	gen sh_emp_ind`i' = (emp_ind`i' / emp_tot)*100
	lab var sh_emp_ind`i' "Share of this county's emp in NAICS `i'"
}

drop emp_tot // don't want total employment from QCEW as main emp measure; will undercount gov, ag workers

* label
forv i = 1/8 {
	lab var emp_ind`i' "Emp in NAICS `i'"
	lab var wages_ind`i' "Wages in NAICS `i'"
	lab var avg_wages_ind`i' "Avg wages in NAICS `i'"
}

drop wages*

rename avg_wages_tot avg_wages

order year fipscounty emp* avg_wages*

rename state stateabbrev 
drop statename

* get county name
merge m:1 fipscounty using $rawdir/alt_xwalk_countyfips_190305.dta, keepusing(county) assert(2 3) keep(3) nogen

order year fipscounty stateab county emp* avg_wages*

	/***************************************************************************
		2) Merge other county economic characteristics and save as long file 
			with county-level data
	***************************************************************************/

* UE and employment from BLS LAUS
merge 1:1 year fipscounty using $rawdir/county_unemp_1990_2017.dta, keep(1 3) nogen
lab var unemp "Unemployment rate (%)"
lab var emp "Total county employment"

/* BEA county dataset; not a perfect merge for some counties in VA, 
	whose estimates are coupled up and inseparable */
merge 1:1  fipscounty year using $processeddir/bea_countyinc.dta, ///
	assert(2 3) keep(3) nogen keepusing(stateabbrev personal_inc* pop)

* Adjust personal income for inflation
adjust_inflation personal_inc*, year(2017) // program

lab var personal_inc "Personal income (1000s 2017 USD)"
lab var personal_inc_pc "Personal income per capita (2017 USD)"

sort fipscounty year

* Gen log versions of key variables and label them
foreach var of varlist pop* emp* avg_wages* personal_inc* {
	g ln_`var' = log(`var')
}

* Clean up a big and label
forv i=1/8 {
	lab var ln_emp_ind`i' "log emp in NAICS `i'"
	lab var ln_avg_wages_ind`i' "log avg wages in NAICS `i'"
}

lab var emp "Employment"
lab var avg_wages "Average wages (2017 USD)"
lab var ln_emp "log employment"
lab var ln_avg_wages "log average wages"
lab var ln_pop "log population"
lab var ln_personal_inc_pc "log personal income per capita"
lab var ln_personal_inc "log personal income"

tempfile longfips
save `longfips'

	/***************************************************************************
		3) Use subset of data (from 1990, 2000, 2010, 2017) to form differences
			variables which we'll merge onto main dataset later; want them in
			a wide format
	***************************************************************************/

keep if inlist(year, 1990, 2000, 2010, 2017)

tostring year, replace
replace year = "_" + year

qui ds year fipscounty county fips stateabbrev county, not
reshape wide `r(varlist)', i(fipscounty fips stateabbrev county) j(year, string)

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

* Calculate changes from 1990 to 2000, 2000 to 2010 and 2000-2017, and label a lot of variables
foreach var in ln_pop ln_personal_inc ln_personal_inc_pc ln_emp ln_avg_wages unemp {
	
	if "`var'"=="ln_pop"{
		local lab = "log population"
	}
	else if "`var'"=="ln_emp"{
		local lab = "log employment"
	}
	else if "`var'"=="ln_avg_wages"{
		local lab = "log average wages"
	}
	else if "`var'"=="unemp"{
		local lab = "unemployment rate (pp)"
	}

	qui gen D_`var'_90_00 =`var'_2000-`var'_1990
	lab var D_`var'_90_00 "Change in `lab' 1990-2000"


	qui gen D_`var'_00_10 =`var'_2010-`var'_2000
	lab var D_`var'_00_10 "Change in `lab' 2000-2010"

	qui gen D_`var'_00_17 =`var'_2017-`var'_2000
	lab var D_`var'_00_17 "Change in `lab' 2000-2017"
}

drop *_1990 *_2010 *_2017

tempfile fipschars
save `fipschars'

	/***************************************************************************
		4) Prepare deals dataset to merge with the county data we've made
			above
	***************************************************************************/
		
use $processeddir/firm_level_subsidy_runnerup.dta, clear

drop stateab // unnecessary variables

correct_fipscounty // program

* keep deals balanced on both sides
gen balanced = (inrange(deal_year, 1995, 2012))

* Ensure no counties are blank after correcting
drop if county == ""
drop county

/* Need to stack years so we can get pre-deal and post-deal outcomes for winner 
	and runner-up counties */
tempfile main
save `main'

g year = 1990

forv yr=1991/2017 {
	append using `main'
	replace year = `yr' if missing(year)
}

order year id runnerup_id fipscounty 

label var hasthreat "=1 for winners and runnerups whose deal has runnerup county listed"

	/***************************************************************************
		5) Merge big county-level data we made in 1)-2), plus housing data and 
			property tax revenues
	***************************************************************************/

merge m:1 year fipscounty using `longfips' , assert(2 3) keep(3) nogen 
sort year id runnerup_id

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

forv i = 1/3 {
	lab var naics`i'd "`i'-digit NAICS"
}

replace naics2d = "31-33" if inlist(naics2d, "31", "32", "33")
replace naics2d = "44-45" if inlist(naics2d, "44", "45")
replace naics2d = "48-49" if inlist(naics2d, "48", "49")

merge m:1 year fipscounty naics1d using $rawdir/qcew_1d_long.dta, keep(1 3) nogen // Hancock GA missing MFG data in 2005, 2006
merge m:1 year fipscounty naics2d using $rawdir/qcew_2d_long.dta, keep(1 3) nogen // Hancock GA missing MFG data in 2005, 2006, and 
	* Clinton County OH is missing 492 (Couriers and Messengers) in 1999 and 2000. We can input 2000 from the QWI

* Manually input one industry in one county and year
replace naics2d_emp = 9257 if fipscounty == 39027 & year == 2000 & naics2d == "48-49"
replace naics2d_wages = 141641458 if fipscounty == 39027 & year == 2000 & naics2d == "48-49"
replace naics2d_avg_wages = naics2d_wages / naics2d_emp if fipscounty==39027 & year==2000 & naics2d=="48-49"

merge m:1 year fipscounty naics3d using $rawdir/qcew_3d_long.dta, keep(1 3) 

rename _merge merge_qcew3d

		/***********************************************************************
			6.2) Supplement QCEW variables with QWI data if QCEW data missing
		***********************************************************************/

rename naics3d industry // for merge
rename emp emp_full // for merge, so emp we have (from BLS) doesn't conflict w/ QWI emp var
merge m:1 year fipscounty industry using $rawdir/qwi_avgs.dta, keepusing(emp semp payroll) keep(1 3)
rename emp emp_qwi
rename emp_full emp
rename industry naics3d

* Check that these corrections are fine
egen minmerge = min(merge_qcew3d), by(fipscounty naics3d)

adjust_inflation payroll, year(2017)

rename payroll wages_qwi // label variables from QWI so their equivalent in QCEW is clear
replace emp_qwi = round(emp_qwi)

foreach var in emp wages /* est */ { // Cycle through emp, wages, est, where there are exact analogs in QWI
	replace naics3d_`var' = `var'_qwi if _merge == 3 & /// replace w/ QWI value if missing data
							merge_qcew3d == 1 & !missing(`var'_qwi)
	replace naics3d_`var' = `var'_qwi if _merge == 3 & /// replace w/ QWI value if emp = 0 in QCEW
							merge_qcew3d == 3 & `var'_qwi & naics3d_`var' == 0 
	replace naics3d_`var' = . if _merge==3 & merge_qcew3d == 3 & semp == 5 & /// missing otherwise
							missing(`var'_qwi) & naics3d_emp == 0 
}

* Do the same for avg_wages, where QWI equiv. has to be constructed
replace naics3d_avg_wages = naics3d_wages / naics3d_emp if _merge == 3 ///
	& merge_qcew3d==1 & !missing(wages_qwi) & emp_qwi!=0

replace naics3d_avg_wages = naics3d_wages / naics3d_emp if _merge == 3 ///
	& merge_qcew3d==3 & !missing(wages_qwi) 

replace naics3d_avg_wages = . if _merge==3 & merge_qcew3d==3 & semp == 5 ///
	& missing(emp_qwi) & missing(naics3d_emp)

drop *_qwi semp _merge minmerge merge_qcew3d // drop variables we needed for QWI imputing

			/*******************************************************************
				6.3) Create residuals and logs of local economic economic 
						variables; label all of these
			*******************************************************************/

* Before creating residual category, replace missing with 0
foreach var of varlist *_emp *_wages {
	replace `var' = 0 if missing(`var')
}

* Get logs and residuals for employment and establishment variables at industry levels
gen emp_res = emp - naics3d_emp
gen ln_emp_res = log(emp-naics3d_emp)

forv i = 1 / 3 {
	gen naics`i'd_ln_emp = log(naics`i'd_emp)
	if `i' != 3 { 
		gen naics`i'd_emp_res = naics`i'd_emp - naics3d_emp
		gen naics`i'd_ln_emp_res = log(naics`i'd_emp - naics3d_emp)
	}
}

* Get logs and residuals for average wages at industry levels
g ln_avg_wages_res = log((avg_wages*emp - naics3d_wages)/(emp - naics3d_emp))
g avg_wages_res = (avg_wages*emp - naics3d_wages)/(emp - naics3d_emp)

forv i = 1/3 {
	gen naics`i'd_ln_avg_wages = log(naics`i'd_avg_wages)
	if `i' != 3 {
		gen naics`i'd_avg_wages_res = (naics`i'd_wages - naics3d_wages)/(naics`i'd_emp - naics3d_emp)
		gen naics`i'd_ln_avg_wages_res = log(naics`i'd_avg_wages_res)
	}
}

drop naics?d_wages

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
replace year = "_"+year

reshape wide naics1d_* naics2d_* naics3d_*, i(id runnerup_id) j(year, string)

foreach var in ln_emp ln_avg_wages {
	if "`var'" == "ln_emp" {
		local lab = "log emp"
	}
	else if "`var'" == "ln_avg_wages" {
		local lab = "log avg wages"
	}
	forv i=1/3 {
		lab var naics`i'd_`var'_2000 "`i'-D `lab' (2000)"

		qui gen D_naics`i'd_`var'_90_00 =naics`i'd_`var'_2000-naics`i'd_`var'_1990
		lab var D_naics`i'd_`var'_90_00 "Change in `i'-D `lab' 1990-2000"

		qui gen D_naics`i'd_`var'_00_10 =naics`i'd_`var'_2010-naics`i'd_`var'_2000
		lab var D_naics`i'd_`var'_00_10 "Change in `i'-D `lab' 2000-2010"

		qui gen D_naics`i'd_`var'_00_17 =naics`i'd_`var'_2017-naics`i'd_`var'_2000
		lab var D_naics`i'd_`var'_00_17 "Change in `i'-D `lab' 2000-2017"
	}
}

drop *_2010 *_2017

tempfile indofdeal_2000
save `indofdeal_2000'

restore

	/***************************************************************************
		7) Transition into event-time, reshape, and relabel variables
	***************************************************************************/

g eventyr = year - deal_year + 100 // transition things into event time

* identify event years, min and max
qui summ eventyr
local min = r(min)
local max = r(max)

*prepare to reshape
tostring eventyr, replace 
replace eventyr = "_" + eventyr
drop year state statename 

reshape wide emp* pop personal_inc personal_inc_pc avg_wages* unemp ln_* sh_* ///
	naics1d_* naics2d_* naics3d_*, i(fipscounty id runnerup_id) j(eventyr, string)
	
* Label all of these variables
forv yr = `min'/`max'{
	local y = `yr' -100
	if `yr'>100{
		local y = "+`y'"
	}
	else if `yr'==100{
		local y = ""
	}
	forv i=1/8{
		lab var ln_emp_ind`i'_`yr' "log emp in NAICS `i' (t`y')"
		lab var ln_avg_wages_ind`i'_`yr' "log avg wages in NAICS `i' (t`y')"
		lab var sh_emp_ind`i'_`yr' "% emp in NAICS `i' (t`y')"
	}

	lab var emp_`yr' "Employment (t`y')"
	lab var avg_wages_`yr' "Average wages (2017 USD) (t`y')"
	lab var ln_emp_`yr' "log employment (t`y')"
	lab var ln_avg_wages_`yr' "log average wages (t`y')"
	lab var pop_`yr' "Population (t`y')"
	lab var ln_pop_`yr' "log population (t`y')"
	lab var unemp_`yr' "Unemployment rate (t`y')"
	lab var personal_inc_pc_`yr' "Personal income per capita (t`y')"
	lab var ln_personal_inc_pc_`yr' "Log personal income per capita (t`y')"
	lab var personal_inc_`yr' "Personal income  (t`y')"
	lab var ln_personal_inc_`yr' "Log personal income (t`y')"

	forv i=1/3 {
		lab var naics`i'd_ln_emp_`yr' "log employment in `i' digit industry of deal (t`y')"
		lab var naics`i'd_ln_avg_wages_`yr' "log average wages in `i' digit industry of deal (t`y')"

		lab var naics`i'd_emp_`yr' "employment in `i' digit industry of deal (t`y')"
		lab var naics`i'd_avg_wages_`yr' "average wages in `i' digit industry of deal (t`y')"

		capture lab var naics`i'd_ln_emp_res_`yr' "log residual employment in `i' digit industry of deal (t`y')"
		capture lab var naics`i'd_ln_avg_wages_res_`yr' "log residual average wages in `i' digit industry of deal (t`y')"

		capture lab var naics`i'd_emp_res_`yr' "residual employment in `i' digit industry of deal (t`y')"
		capture lab var naics`i'd_avg_wages_res_`yr' "residual average wages in `i' digit industry of deal (t`y')"
	}
	
	lab var ln_emp_res_`yr' "log residual emp (t`y')"
	lab var ln_avg_wages_res_`yr' "log residual avg wages (t`y')"

	lab var emp_res_`yr' "residual emp (t`y')"
	lab var avg_wages_res_`yr' "residual avg wages (t`y')"
}

order id runnerup_id winner hasthreat fipscounty county stateab naics3d *_7* *_8* *_9* *_10*

	/***************************************************************************
		8) Merge back in the differences variables we made in 3) and 6.5)
	***************************************************************************/

merge m:1 fipscounty using `fipschars', assert(2 3) keep(3) nogen

merge 1:1 id runnerup_id using `indofdeal_2000', assert(3) nogen

	/***************************************************************************
		9) Merge 2000, 2010 census data for demographics
	***************************************************************************/

preserve // Need to correct two counties before we can merge

use  $processeddir/demographics_census_2000_2010_bycounty.dta, clear

replace fipscounty = 46102 if fipscounty == 46113 //Shannon SD becomes Oglala Lakota SD
replace fipscounty = 02158 if fipscounty == 02270 // Wade Hampton Census Area, AK becomes Kusilvak Census Area, AK 

tempfile census
save `census'

restore

merge m:1 fipscounty using  `census', nogen assert(2 3) keep(3)

 	/***************************************************************************
		10) Merge county area
	***************************************************************************/
		
preserve

import delimited using $rawdir/DEC_10_SF1_GCTPH1.US05PR.csv, clear

rename (v5 v10 v12) (fipscounty totalarea landarea)

drop in 1/2

keep fipscounty totalarea landarea

destring *, replace

drop if fipscounty < 1000 | missing(fipscounty)

correct_fipscounty

collapse (sum) totalarea landarea, by(fipscounty)

tempfile area
save `area'

restore

drop if inlist(fipscounty, 2201, 2232, 2280)
merge m:1 fipscounty using `area', nogen assert(2 3) keep(3)

foreach yr in 2000 {
	gen pop_density_`yr' = pop_`yr' / landarea
	lab var pop_density_`yr' "Population density (per sq mile of land area) (`yr')"
}

drop landarea totalarea 

	/***************************************************************************
		11) Reformat and label some Census variables
	***************************************************************************/

* log
foreach var of varlist median_grossrent_* median_houvalue_* hou_units* {
	qui g ln_`var' = log(`var')
}

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

drop *_2010

	/***************************************************************************
		12) For VW deal, want to combine Madison & Limestone county numbers to 
			form a "Huntsville, AL" entry
	***************************************************************************/

preserve

keep if id == 518 & winner == 0 // Keep only runners-up in competition for VW 2008

tempfile mainVW
save `mainVW'

		/***********************************************************************
			12.1) Make combined data for variables we only have in the year 
				2000
		***********************************************************************/

keep id *_2000 // Get combined data from 2000

qui ds naics?d_avg_wages* avg_wages_ind*
local avgwages = "`r(varlist)'" // List of avg wages variables

qui ds emp* naics?d_emp*
local emp_ind = "`r(varlist)'" // List of employment variables

collapse (firstnm) id (mean) ba_over25 foreign hispanic ///
			median_grossrent median_houvalue `avgwages' pop_density ///
		(rawsum) hou_units /* est */ `emp_ind' pop_2000 [aw = pop_2000]

qui ds hou_units naics?d_emp* median_houvalue median_grossrent avg_wages* ///
	naics?d_avg_wages* emp* pop_2000

foreach variable in `r(varlist)'{ // Get logs of variables which we summed over to get
	if regexm("`variable'", "naics") & !regexm("`variable'", "4") {
		local firstpart = substr("`variable'", 1, 7)
		local secondpart = substr("`variable'", 9, .)
		gen `firstpart'_ln_`secondpart' = log(`variable')
	}
	else {
		gen ln_`variable' = log(`variable')
	}
}

tempfile VW2000
save `VW2000'

		/***********************************************************************
			12.2) Make combined data for variables we have for each event year
		***********************************************************************/

forv i = 82 / 109 { // Get combined data from event years 82-109
	use `mainVW', clear
	
	* Only keep variables in the event year in question
	keep id deal_year runnerup_id winner hasthreat stateabbrev naics3d ///
		balanced *_`i'
	
	qui ds naics?d_emp* emp* pop* personal_inc_`i'
	local sumlist = "`r(varlist)'" // List of variables we need to sum over two counties when we collapse
	
	qui ds naics?d_avg_wages_* avg_wages* unemp* sh_emp* ln_HPI* personal_inc_pc*
	local avglist = "`r(varlist)'" // List of variables we need to average (pop-weighted) over two counties when we collapse
	
	collapse (firstnm) id winner hasthreat stateabbrev naics3d deal_year balanced ///
		(rawsum) `sumlist' (mean) `avglist' (min) runnerup_id [aw = pop]

	gen countyname = "Limestone, Madison"
	
	qui ds avg_wages* emp* personal_inc* pop* naics* 
	
	foreach variable in `r(varlist)' { // Get logs of variables which we summed to get
		if regexm("`variable'", "naics") & !regexm("`variable'", "4") {
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
			12.3) Put together combined data from 13.1 and 13.2 as single ob
					for Huntsville; drop separate Limestone and Madison county
					observations
		***********************************************************************/

use `VW82'
forv i = 83/109 {
	merge 1:1 id using `VW`i'', assert(3) nogen
}

merge 1:1 id using `VW2000', assert(3) nogen

gen fips = 0 // need nonmissing fips to cluster by fips; arbitrarily choose 0

tempfile VW_runnerup
save `VW_runnerup'

restore 

append using `VW_runnerup'
drop if id == 518 & inlist(countyname, "Limestone", "Madison")

drop median* hou_units*

	/***************************************************************************
		13) Clean up and save
	***************************************************************************/

* FLAG ANALYSIS SAMPLE
forv i=95/105 {
	reg naics3d_ln_emp_`i' winner ln_pop_90 ln_emp_90 ln_avg_wages_90 i.deal_year ///
		if hasthreat==1 & balanced==1
	
	g sample`i' = e(sample)
}

* drop if never in sample
egen sample_tmp = rowtotal(sample*)
drop sample95-sample105
g sample = (sample_tmp!=0)
lab var sample "=1 if analysis sample"

drop sample_tmp

sort id runnerup_id
order id runnerup_id winner hasthreat balanced sample

save $processeddir/deal_specific_analysis.dta, replace