/*************************************************************************************************************
QCEW_Table5ii
Layout of code is:
1. Declare locals for period over which we are estimating employment change
2. Build dataset (including QCEW data)
3. Scale/Adjust Variables
4. Analysis: Production of Tables
	a. Table 5ii
*************************************************************************************************************/
version 10.1
clear
set more off
set mem 300m
set matsize 800
capture estimates drop *

cd "$dir"

/*************************************************************************************************************
1. Declare locals
*************************************************************************************************************/

*	Some of these parameters are redundant.
*		parameters used for the Bartik control
local timeend = ym(2009,12)
local placebostart = ym(2000,1)

*		parameters used for the QCEW outcome variable
local time = "2009m12"
local lag = "2008m12"

**Set vintage of employment. july20 for old data; june82011 for new data
local vintage june82011

**Set here for period for the endogenous variable
*local FMAP_period 31dec2010
local FMAP_period 30jun2010

//Given when you want placebos to start, the data needs to be drawn in from two years earlier (for lag):
local timestartyear = year(dofm(`placebostart'))-2 //Should be two years before "placebostart"
local timestartmonth = month(dofm(`placebostart'))
local timestart = ym(`timestartyear',`timestartmonth') 

**SA or NSA data?
local adj "SA"

/*************************************************************************************************************
2. Build dataset
*************************************************************************************************************/

*	First, get the instrument
use data/state_medicaid_spending_instrument, replace

*	Now, merge in state population
sort state_abrev
merge state_abrev using data/pop16plus_cleaned, unique
replace pop16plus = pop16plus*1000
tab _merge
drop _merge
rename pop16plus popestimate2008

*	Merge other state controls
sort state_abrev
merge state_abrev using data/state_controls
drop _m
sort state_abrev
*	Note: we rescale GDP so that it is not too large relative to the other variables
rename gdp_2008 gdp_2008_old
gen gdp_2008 = gdp_2008_old/1000000
label variable gdp_2008 "GDP divided by 1,000,000"
drop gdp_2008_old

forvalues i=1/9 {
	qui gen region_`i' = cond(__region_dummies==`i',1,0)
	label variable region_`i' "Region `i'"
}

local regions "region_1 region_2 region_3 region_4 region_5 region_6 region_7 region_8 region_9"

* 	Merge in CES data for 2009m12
foreach level in totalemp totalgov edhealth education health {
	preserve
	use data/CES/`level'`vintage', replace
	qui drop if state_abrev==""
	qui gen sachange_`level' = 1000*(_200912 - _200812) 
	gen sachange_`level'_lag = 1000*(_200812 - _20085) 
	qui keep state_abrev  sachange_`level'  sachange_`level'_lag
	tempfile `level'
	qui save ``level''
	restore
	merge state_abrev using ``level'', sort
	qui keep if _merge==3
	drop _merge
}	
	
*****	Merge in the state categories of spending
preserve
use data/ARRASpending, clear
keep if date==td(`FMAP_period')
rename  state_acronym state_abrev
drop if state_abrev==""
gen outlays_total = outlaysFMAP + outlaysOther + outlaysSFSF
ren obligationsFMAP oblig_med 
label variable outlays_total "total ARRA outlays as of `spending_date'"
gen medsfsf= outlaysFMAP + outlaysSFSF 
gen paidout = outlaysOther + outlaysSFSF + outlaysFMAP
qui gen fmap = outlaysFMAP
label variable medsfsf "total FMAP + SFSF outlays as of `spending_date'"
foreach s in FM AS MH VI MP GU PR PW N/ [Other] - 14 A UM {
	drop if state_abrev=="`s'"
	}
sort state_abrev
tempfile arrabystate
save `arrabystate'
restore
sort state_abrev
merge state_abrev using `arrabystate'
assert _merge==3
drop _merge

* Merge in QCEW employment 
foreach level in stategov localgov edhealth education health totalemp totgov {
	preserve
	use "data\Haver Data July 13 2010\Cleaned Version\qcew_temp_file", clear

	if "`level'" == "stategov" keep if data_type == "state govt, QCEW"
	if "`level'" == "localgov" keep if data_type == "local govt, QCEW"

	if "`level'" == "edhealth" keep if data_type == "private Ind: Education & Health Services, QCEW"
	if "`level'" == "education" keep if data_type == "private ind: educ services, QCEW"
	if "`level'" == "health" keep if data_type == "private Ind: Health Care & Social Assistance, QCEW"
	if "`level'" == "totalemp" keep if data_type == "private Ind: Total, All Industries, QCEW"
	if "`level'" == "totgov" keep if data_type == "total govt, QCEW"
	
	qui drop if state_abrev==""
	
	local timechangestart = `timestart'+12
	forvalues t = `timechangestart'/`timeend' { 
		qui local year = year(dofm(`t'))
		qui local month = month(dofm(`t'))
		qui local yearlag = `year'-1
		qui gen `level'_ch`year'm`month' = 1000*(_`year'`month' - _`yearlag'`month')
	}
	qui keep state_abrev `level'_ch*
	tempfile `level'
	qui save ``level'', replace
	restore
	merge state_abrev using ``level'', sort
	qui keep if _merge==3
	drop _merge
}

forvalues t = `timechangestart'/`timeend' { 
	qui local year = year(dofm(`t'))
	qui local month = month(dofm(`t'))
	gen gov_broad_ch`year'm`month' = localgov_ch`year'm`month' + stategov_ch`year'm`month' + edhealth_ch`year'm`month'
	gen sandlgov_ch`year'm`month' = localgov_ch`year'm`month' + stategov_ch`year'm`month'
}

* Merge in QCEW Imputed Employment (have for 2007 to 2008, and then 2008 to 2009)
preserve
use data/ImputedEmployment2007-2008.dta, clear
rename state state_abrev
rename d_employment qcew_act_2007_2008
rename d_employment_hat qcew_impute_2007_2008
keep state_abrev qcew_act_2007_2008 qcew_impute_2007_2008
sort state_abrev
tempfile impute_78
save `impute_78'

use data/ImputedEmployment2008-2009.dta, clear
rename state state_abrev
rename d_employment qcew_act_2008_2009
rename d_employment_hat qcew_impute_2008_2009
keep state_abrev qcew_act_2008_2009 qcew_impute_2008_2009
sort state_abrev
tempfile impute_89
save `impute_89'

restore
sort state_abrev
merge state_abrev using `impute_78'
drop _merge
sort state_abrev
merge state_abrev using `impute_89'
drop _merge

/*************************************************************************************************************
3. Rescale variables
*************************************************************************************************************/
replace pop_density = pop_density/10000
label variable pop_density "pop density/10000"

gen share_kerry_10000 = share_kerry/10000
label variable share_kerry_10000 "share kerry / 10000"

gen union_share_10000 = union_share/10000
label variable union_share_10000 "union share/ 10000"

gen per_empl_manu_10000 = per_empl_manu/10000
label variable per_empl_manu_10000 "per_empl_manu/10000"

gen popestimate2008_bil = popestimate2008/1000000000
label variable popestimate2008_bil "population estimate 2008 in billions

*	Divides these ones by 100000
foreach var in instrument paidout fmap oblig_med outlaysFMAP medsfsf {
	capture qui gen `var'_pc = `var'/popestimate2008
	capture qui replace `var'_pc = `var'_pc/100000
}

foreach level in totalemp totalgov edhealth education health {
	gen sachange_`level'_pc = sachange_`level'/popestimate2008 
	gen sachange_`level'_lag_pc = sachange_`level'_lag/popestimate2008
	}

qui gen sachange_gov_broad_pc = sachange_totalgov_pc + sachange_edhealth_pc
qui gen sachange_gov_broad_lag_pc = sachange_totalgov_lag_pc + sachange_edhealth_lag_pc

qui gen gdp_pc = 1000000*gdp_2008/popestimate2008

gen qcew_impute_2007_2008_pc = qcew_impute_2007_2008/popestimate2008
gen qcew_impute_2008_2009_pc = qcew_impute_2008_2009/popestimate2008

foreach level of varlist gov_broad_ch* edhealth_ch*  stategov_ch* localgov_ch* education_ch* health_ch* totalemp_ch* sandlgov_ch* {
	gen `level'_pc = `level'/popestimate2008 
}

label variable paidout_pc "Total ARRA Payouts per capita ($100k)"
label variable fmap_pc "ARRA FMAP Payouts per capita ($100k)"
label variable oblig_med_pc "ARRA FMAP Obligations per capita($100k)"
label variable instrument_pc "FMAP Instrument (100k)"
label variable per_empl_manu "Employment manufacturing share"
label variable share_kerry "2004 Kerry share"
label variable union_share "Union share"
label variable gdp_pc "GDP per capita divided by 10000"
capture label variable qcew_ch_employ_pc "ch per capita employment, QCEW"

/*************************************************************************************************************
4.  Analysis
*************************************************************************************************************/

local controlQCEW1 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil sachange_totalemp_lag_pc  qcew_impute_2008_2009_pc"
local controlCES1 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil  sachange_totalemp_lag_pc"
local endog = "fmap_pc"

*       TABLE 5, PART II.  
*               One CES with standard set of controls
*               One CES with the standard set of controls + imputed employment
*               One QCEW with the standard set + imputed
capture estimates drop *

ivregress 2sls sachange_totalemp_pc `controlCES1' (`endog' = instrument_pc), robust
qui sum `e(depvar)' if e(sample)==1, meanonly
qui estadd scalar mean=`r(mean)' *1000
estimates store CES`endog'_`time'_1

ivregress 2sls sachange_totalemp_pc `controlQCEW1' (`endog' = instrument_pc), robust
qui sum `e(depvar)' if e(sample)==1, meanonly
qui estadd scalar mean=`r(mean)'*1000 
estimates store CES`endog'_`time'_2

ivregress 2sls totalemp_ch`time'_pc `controlQCEW1' (`endog' = instrument_pc), robust
qui sum `e(depvar)' if e(sample)==1, meanonly
qui estadd scalar mean=`r(mean)'*1000
estimates store CES`endog'_`time'_3

estout * using output/table5ii_robust.txt, replace cells(b(star fmt(%9.2f)) se(fmt(%9.2f))) varwidth(30) label varlabel(_cons "Constant") stats(N r2 mean, labels("Observations" "R-squared" "Mean Dep Var")) starlevels(* .10 ** .05 *** .01)
