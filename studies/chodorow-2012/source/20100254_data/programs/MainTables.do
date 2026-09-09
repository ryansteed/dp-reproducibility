/*************************************************************************************************************
MainTables
Layout of code is:
1. Declare locals for period over which we are estimating employment change
2. Build dataset
3. Scale/Adjust Variables
4. Analysis: Production of Tables
	a. Table 1
	b. Table 2
	c. Table 3 and 4
	d. Table 5i
	e. Data for footnote X
	f. Appendix Tables
*************************************************************************************************************/
version 10.1
clear
set more off
cd "$dir"
set mem 300m
set matsize 800
capture estimates drop *

/*************************************************************************************************************
1.  Declare locals
*************************************************************************************************************/

* Set here for which months you want to analyze for the "baseline" case.  
*	We explore the timing of the result in TimingGraphs_Figures3_4.do
*		year_1, month_1 is the end of the period of interest.  In our case, it is July 2009, so we set year_1 = 2009 and month_1 = 7
*		year_0, month_0 is the end of the period of interest.  In our case, it is Dec 2008, so we set year_0 = 2008 and month_0 = 12 
local start 7
**Set dates for period 0 and period 1 employment
local year_0 2008
local month_0 12
local year_1 2009
local month_1 `start'

local period `year_0'`month_0'_`year_1'`month_1'

display("`period'")

**Set dates for lagged employment
*	This is formatted the same way as above.  We want lagged employment to be from May 2008 to December 2008
local l_year_0 2008
local l_month_0 5
local l_year_1 2008
local l_month_1 12
local l_period `l_year_0'`l_month_0'_`l_year_1'`l_month_1'

**Set vintage of employment. june82011 for new data
*	The employment data gets updated over time.  This setting controls the vintage of the data
local vintage june82011

**Set here for period for the endogenous variable
*local FMAP_period 31dec2010
local FMAP_period 30jun2010

display("")
display("")
display("")
display("`start_year' `start_month'")
display("`end_year' `end_month'")
display("`p_start_year' `p_start_month'")
display("`p_end_year' `p_end_month'")

**Seasonally adjusted or not seassonlay adjusted data?  Put "SA" or "NSA"
local adj "SA"

/*************************************************************************************************************
2. Build dataset
*************************************************************************************************************/

*** Edited by Ryan Steed
use data/pop16plus_cleaned
tempfile pop16plus_cleaned
sort state_abrev
save `pop16plus_cleaned'
***

*	First, get the instrument
use data/state_medicaid_spending_instrument, replace

*	Now, merge in state population
*		downloaded July 20, 2009
sort state_abrev
merge state_abrev using `pop16plus_cleaned', unique
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

*	Now merge in the actual and lagged employment change
foreach level in totalemp totalgov edhealth education health {
	preserve
	use data/CES/`level'`vintage', replace
	qui drop if state_abrev==""
	qui gen sachange_`level' = 1000*(_`year_1'`month_1' - _`year_0'`month_0') 
	gen sachange_`level'_lag = 1000*(_`l_year_1'`l_month_1' - _`l_year_0'`l_month_0') 
	qui keep state_abrev  sachange_`level'  sachange_`level'_lag
	tempfile `level'
	qui save ``level''
	restore
	merge state_abrev using ``level'', sort

	qui keep if _merge==3
	drop _merge
}

global end = "_`year_1'm`month_1'"
* Merge in baseline state predictions	
if `year_0' == 2008 & `month_0'==12 {
	foreach type in totalgov totalemp health education edhealth {
		preserve
		use data/StatePredictions/baseline`type'12_08_time, clear
		gen baseline`type' = $end - _2008m12
		keep state_abrev baseline`type'
		sort state_abrev
		tempfile `type'file
		save ``type'file', replace
		restore
		sort state_abrev
		merge state_abrev using ``type'file', unique
		tab _merge
		drop _merge
	}
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

	
/*************************************************************************************************************
3. Rescale variables
*************************************************************************************************************/

*	Divides these ones by 100000 to make the interpretation easier
foreach var in instrument paidout fmap oblig_med outlaysFMAP medsfsf {
	capture qui gen `var'_pc = `var'/popestimate2008
	capture qui replace `var'_pc = `var'_pc/100000
}

*	Does not divide these by 1000
foreach var in qcew_ch_employ ch_eoy_balance_fy_09_08 fy09bc_june_mil uniq_elgbls_count delta_rainy   {
	capture qui gen `var'_pc = `var'/popestimate2008
}

qui gen gdp_pc = 1000000*gdp_2008/popestimate2008

foreach level in totalemp totalgov edhealth education health {
	gen sachange_`level'_pc = sachange_`level'/popestimate2008 
	gen sachange_`level'_lag_pc = sachange_`level'_lag/popestimate2008
	gen `level'_baseline_pc = baseline`level'/popestimate2008
	}

qui gen sachange_gov_broad_pc = sachange_totalgov_pc + sachange_edhealth_pc
qui gen sachange_gov_broad_lag_pc = sachange_totalgov_lag_pc + sachange_edhealth_lag_pc
qui gen gov_broad_baseline_pc = totalgov_baseline_pc + edhealth_baseline_pc

foreach level in totalemp gov_broad {
	gen sachange_`level'_lag_pc_2 = sachange_`level'_lag_pc^2*1000
	gen sachange_`level'_lag_pc_3 = sachange_`level'_lag_pc^3*100000
	gen sachange_`level'_lag_pc_4 = sachange_`level'_lag_pc^4*10000000
	gen sachange_`level'_lag_pc_5 = sachange_`level'_lag_pc^5*100000000000
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

gen share_kerry_10000 = share_kerry/10000
label variable share_kerry_10000 "share kerry / 10000"

gen union_share_10000 = union_share/10000
label variable union_share_10000 "union share/ 10000"

gen per_empl_manu_10000 = per_empl_manu/10000
label variable per_empl_manu_10000 "per_empl_manu/10000"

gen popestimate2008_bil = popestimate2008/1000000000
label variable popestimate2008_bil "population estimate 2008 in billions"

**************************************************************************************************************
/*************************************************************************************************************
4. Analysis 
*************************************************************************************************************/
**************************************************************************************************************

local level "totalemp"
*	GENERAL PARAMETERS	
*	Note: control3 must be defined after defining the level, or else the predicted employment won't be correct
	local control1 ""
	local control2 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil"

	local rhs_iterations 3

**************
****	SUMMARY STATS RAW : TABLE 1
**************
*	Correlation b/n outcome variable and instrument
*		Used to verify the following footnote: The correlation between the change in per capita total nonfarm employment between May and December 2008 and the instrument is 0.235 (p-value 0.097). The correlation between the change in per capita government, health, and education employment between May and December 2008 and the instrument is -0.195 (p-value 0.170). By comparison, during the main period of interest (December 2008 to July 2009), the correlation between the instrument and the change in employment is 0.5451 for total nonfarm and is 0.3982 for government, health, and education. In both cases, the associated p-values for these correlations are significant (p<0.05).
foreach level in totalemp gov_broad {
	pwcorr instrument_pc sachange_`level'_pc    , sig
	pwcorr instrument_pc sachange_`level'_lag_pc, sig	
	*sum sachange_`level'_pc sachange_`level'_lag_pc
	display("")
	display("")
	display("")
	}

gen popestimate2008_mil = popestimate2008/1000000
label variable popestimate2008_mil "population estimate 2008 in millions"

foreach v in sachange_gov_broad_pc sachange_totalemp_pc sachange_gov_broad_lag_pc  sachange_totalemp_lag_pc {
	gen `v'_1k = `v'*1000
	label variable `v'_1k "`v'*1000"
	}

foreach v in fmap_pc paidout_pc medsfsf_pc instrument_pc {
	gen `v'_100000 = `v'*100000
	label variable `v'_100000 "`v'*100,000"
	}

gen gdp_pc_thousands = gdp_pc*1000
label variable gdp_pc_thousands "GDP pc, $1000"

*	First, makes the raw files
foreach stat in mean sd min median  max{
	preserve
	collapse (`stat') per_empl_manu share_kerry union_share gdp_pc_thousands popestimate2008_mil  sachange_gov_broad_pc_1k sachange_totalemp_pc_1k sachange_gov_broad_lag_pc_1k  sachange_totalemp_lag_pc_1k     paidout_pc_100000 fmap_pc_100000 medsfsf_pc_100000 instrument_pc_100000 
	gen stat = "`stat'"
	tempfile `stat'_del
	save ``stat'_del'
	restore
	}

*	Then, merges them together
preserve
use `mean_del', replace
foreach stat in sd min median  max{
	append using ``stat'_del'
	}
order stat
outsheet using output/table1_sumstat.txt, comma replace
restore

*************************************
**********	First stage regressions : TABLE 2
*************************************
gen arralessfmap_pc = paidout_pc - fmap_pc

capture estimates drop *
qui {
reg fmap_pc instrument_pc, robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000 
estimates store uw1

reg fmap_pc instrument_pc `regions' share_kerry union_share gdp_pc per_empl_manu popestimate2008, robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store uw2

*reg fmap_pc instrument_pc `regions' share_kerry union_share gdp_pc per_empl_manu popestimate2008 totalemp_baseline_pc, robust
reg fmap_pc instrument_pc `regions' share_kerry union_share gdp_pc per_empl_manu popestimate2008 sachange_totalemp_lag_pc, robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store uw3

*reg fmap_pc instrument_pc `regions' share_kerry union_share gdp_pc per_empl_manu popestimate2008 gov_broad_baseline_pc, robust
reg fmap_pc instrument_pc `regions' share_kerry union_share gdp_pc per_empl_manu popestimate2008 sachange_gov_broad_lag_pc, robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store uw4
}
local level totalemp
estout * using output/table2_first_stage.txt, replace cells(b(star fmt(%9.2f)) se(fmt(%9.2f))) varwidth(30) label varlabel(_cons "Constant") stats(N r2 mean, labels("Observations" "R-squared" "Mean Dep Var")) order(instrument_pc _cons) starlevels(* .10 ** .05 *** .01)


*************************************
**********	Baseline OLS/IV : TABLE 3 AND TABLE 4
*************************************
local endog "fmap_pc"


foreach level in totalemp gov_broad {
	capture estimates drop *
	*local control3 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil `level'_baseline_pc"
	local control3 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil sachange_`level'_lag_pc"


	foreach X in `endog' {
		*	First OLS
		forvalues i=1/`rhs_iterations' {
			qui reg sachange_`level'_pc `endog' `control`i'', robust
			qui sum `e(depvar)' if e(sample)==1, meanonly
			qui estadd scalar mean=`r(mean)'*1000
			qui estimates store ols_`i'_`level'_`X'
			}
		
		*	Then IV	
		forvalues i=1/`rhs_iterations' {
			ivregress 2sls sachange_`level'_pc `control`i'' (`X' = instrument_pc) , robust
			qui sum `e(depvar)' if e(sample)==1, meanonly
			qui estadd scalar mean=`r(mean)' *1000
			qui estimates store iv_`i'_`level'_`X'
			}
		}
	estout * using output/table3_or_4_`level'.txt, replace cells(b(star fmt(%9.2f)) se(fmt(%9.2f))) varwidth(30) label varlabel(_cons "Constant") stats(N r2 mean, labels("Observations" "R-squared" "Mean Dep Var")) order(`endog'  _cons) starlevels(* .10 ** .05 *** .01)
	estout * using "../../results/table_`level'.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
	}

*** Edited by Ryan Steed
exit
***
	
*************************************
**********	Robustness Table - July 2011: TABLE 5i
*************************************
capture estimates drop *
*	This table has two parts.  One is Dec 2008 - July 2009 from the CES.   The other ins Dec 2008 - Dec 2009 from the QCEW.  This code will generate the first part.  Both are total only
*	CES Total employment - total 
	qui ivregress 2sls sachange_totalemp_pc `control2' totalemp_baseline_pc  (fmap_pc = instrument_pc), robust
	qui sum `e(depvar)' if e(sample)==1, meanonly
	qui estadd scalar mean=`r(mean)'*1000
	qui estimates store new_rob_1
	
*	CES with lag, squared
	qui ivregress 2sls sachange_totalemp_pc `control2' sachange_totalemp_lag_pc sachange_totalemp_lag_pc_2 (fmap_pc = instrument_pc), robust
	qui sum `e(depvar)' if e(sample)==1, meanonly
	qui estadd scalar mean=`r(mean)'*1000
	qui estimates store new_rob_2

*	CES with lag, cubed
	ivregress 2sls sachange_totalemp_pc `control2' sachange_totalemp_lag_pc sachange_totalemp_lag_pc_2 sachange_totalemp_lag_pc_3 (fmap_pc = instrument_pc), robust
	qui sum `e(depvar)' if e(sample)==1, meanonly
	qui estadd scalar mean=`r(mean)'*1000
	qui estimates store new_rob_3
estout * using output/table5i_robust.txt, replace cells(b(star fmt(%9.2f)) se(fmt(%9.2f))) varwidth(30) label varlabel(_cons "Constant") stats(N r2 mean, labels("Observations" "R-squared" "Mean Dep Var")) order(`endog'  _cons) starlevels(* .10 ** .05 *** .01)


*************************************
**********	Splitting up government employment: 
*	IN TEXT, FOOTNOTE "When using the change from December 2008 to July 2009 in state and local government employment as the dependent variable in our baseline regression we estimate a coefficient of 0.65 (SE = 0.26) on the FMAP transfers, while changes in health and education employment yield coefficients of 0.21 (SE = 0.10) and 0.29 (SE = 0.11) respectively."
*************************************
capture estimates drop *

qui {
*	Gov Broad
*ivregress 2sls sachange_gov_broad_pc `control2'  gov_broad_baseline_pc (`endog' = instrument_pc) if sachange_education_pc !=. & sachange_health_pc !=., robust
ivregress 2sls sachange_gov_broad_pc `control2' sachange_gov_broad_lag_pc  (`endog' = instrument_pc) if sachange_education_pc !=. & sachange_health_pc !=., robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)' *1000
estimates store gov_broad

*	Just education
*ivregress 2sls sachange_education_pc `control2' education_baseline_pc (`endog' = instrument_pc) if sachange_education_pc !=. & sachange_health_pc !=., robust
ivregress 2sls sachange_education_pc `control2' sachange_education_lag_pc (`endog' = instrument_pc) if sachange_education_pc !=. & sachange_health_pc !=., robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)' *1000
estimates store ed

*	Just health
*ivregress 2sls sachange_health_pc `control2' health_baseline_pc (`endog' = instrument_pc) if sachange_education_pc !=. & sachange_health_pc !=., robust
ivregress 2sls sachange_health_pc `control2' sachange_health_lag_pc (`endog' = instrument_pc) if sachange_education_pc !=. & sachange_health_pc !=., robust
sum `e(depvar)' if e(sample)==1, meanonly 
estadd scalar mean=`r(mean)' *1000
estimates store health

*	Just educ and health
*ivregress 2sls sachange_edhealth_pc `control2' edhealth_baseline_pc (`endog' = instrument_pc), robust
ivregress 2sls sachange_edhealth_pc `control2' sachange_edhealth_lag_pc (`endog' = instrument_pc), robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)' *1000
estimates store ed_health

*	total govt
ivregress 2sls sachange_totalgov_pc  `control2'  sachange_totalgov_lag_pc  (fmap_pc = instrument_pc), robust
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)' *1000
estimates store total_govt
}
estout * using output/split_govt.txt, replace cells(b(star fmt(%9.2f)) se(fmt(%9.2f))) varwidth(30) label varlabel(_cons "Constant") stats(N r2 mean, labels("Observations" "R-squared" "Mean Dep Var")) order(`endog'  _cons) starlevels(* .10 ** .05 *** .01)

*************************************
**********	Online Appendix: ONLINE APPENDIX
*************************************

* 	OTHER CONTROLS: APPENDIX TABLES 2 & 3
estimates clear

*	Merge in housing data
merge state_abrev using data/FHFA, sort
drop _merge
sort state_abrev

*	Include max state weekly UI benefits as a control variable
merge state_abrev using data/State_UI_Laws/state_UI_laws.dta, sort
assert _merge==3
drop _merge

*	Input Democratic governor
merge state_abrev using data/Dem_Gov/dem_gov, sort
assert _merge==3
drop _merge

* 	Input State Budget Balance Rules
merge state_abrev using data/State_Budget_Rule/state_budget_rule, sort
assert _merge==3
drop _merge
gen byte poterba_rule_missing = (state_budget_rule_poterba==-9)
label variable poterba_rule_missing "dummy for having a missing budget rule, Poterba"

gen byte poterba_rule_strict = (state_budget_rule_poterba<6)
label variable poterba_rule_strict "dummy for state_budget_rule_poterba<6"

gen byte poterba_rule_strict_v2 = (state_budget_rule_poterba<8)
label variable poterba_rule_strict_v2 "dummy for state_budget_rule_poterba<8"

gen byte poterba_rule_strict_v2_dc = poterba_rule_strict_v2
replace poterba_rule_strict_v2_dc = 0 if state_abrev=="DC"
label variable poterba_rule_strict_v2_dc "dummy for state_budget_rule_poterba<8, DC = 0"

* Do the regressions
foreach level in totalemp gov_broad {
	estimates clear
	local control3 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil sachange_`level'_lag_pc"	

	ivregress 2sls sachange_`level'_pc `control3' (fmap_pc= instrument_pc), robust
	estimates store `level'_base
	ivregress 2sls sachange_`level'_pc `control3'  max_ui_week (fmap_pc= instrument_pc), robust
	estimates store `level'_ui
	ivregress 2sls sachange_`level'_pc `control3' d_FHFA (fmap_pc= instrument_pc), robust
	estimates store `level'_house
	ivregress 2sls sachange_`level'_pc `control3' dem_gov_feb1_2009 (fmap_pc= instrument_pc), robust
	estimates store `level'_dem
	xi: ivregress 2sls sachange_`level'_pc `control3'  i.state_budget_rule (fmap_pc= instrument_pc), robust // Clemens and Miron (Aug 30 2010) def.
	estimates store `level'_budget

	estout * using output/onlineappendix2and3`level'.txt, replace cells(b(star fmt(%9.2f)) se(fmt(%9.2f))) varwidth(30) label varlabel(_cons "Constant") stats(N r2 mean, labels("Observations" "R-squared" "Mean Dep Var")) order(fmap_pc  _cons) starlevels(* .10 ** .05 *** .01)
}


