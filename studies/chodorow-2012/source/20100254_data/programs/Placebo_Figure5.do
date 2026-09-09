/*************************************************************************************************************
Placebo_Figure5
Layout of code is:
1. Declare initial settings 
2. Loop over time
	a. Declare locals
	b. Build dataset
	c. Rescale variables
	d. IV regressions
3. Generate Figure 5
*************************************************************************************************************/
version 10.1
clear
set more off
set mem 300m
set matsize 800
cd "$dir"	

/*************************************************************************************************************
1. Declare initial settings
*************************************************************************************************************/

capture estimates drop *

local loop_start = ym(2000,1)
local loop_number = ym(2008,5)-`loop_start'

local adj "SA"
**Set vintage of employment. july20 for old data; june82011 for new data
local vintage june82011

**Set here for period for the endogenous variable
*local FMAP_period 31dec2010
local FMAP_period 30jun2010

*	Note: update the baseline coefficients by hand here
local totalemp_baseline 2.83
local gov_broad_baseline 1.17

* make results matrix for placebo coefficient
matrix totalempcoeff = J(`loop_number'+1,1,0)
matrix gov_broadcoeff = J(`loop_number'+1,1,0)

/*************************************************************************************************************
2. Loop over time
*************************************************************************************************************/

forvalues ticker = 0/`loop_number' {

	/********************************************************************************************************
	a. Declare locals
	*********************************************************************************************************/

	local date_0 = `loop_start' + `ticker'
	local date_1 = `date_0' + 7
	local lag_1 = `loop_start' - 1
	local lag_0 = `lag_1' - 7

	foreach per in 0 1 {
		local year_`per' = year(dofm(`date_`per''))
		local month_`per' = month(dofm(`date_`per''))
		local l_year_`per' = year(dofm(`lag_`per''))
		local l_month_`per' = month(dofm(`lag_`per''))
	}

	local period `year_0'`month_0'_`year_1'`month_1'
	
	display("Period for this run is `period'")

	clear

	/********************************************************************************************************
	b. Build dataset
	*********************************************************************************************************/

	*	First, get the instrument
	use data/state_medicaid_spending_instrument, replace

	*	Now, merge in state population
	*		downloaded from Haver, July 20
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


	*	Now merge in the actual and lagged employment change

	foreach level in totalemp totalgov edhealth {
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
	c. Rescale variables
	*************************************************************************************************************/
	gen share_kerry_10000 = share_kerry/10000
	label variable share_kerry_10000 "share kerry / 10000"

	gen union_share_10000 = union_share/10000
	label variable union_share_10000 "union share/ 10000"

	gen per_empl_manu_10000 = per_empl_manu/10000
	label variable per_empl_manu_10000 "per_empl_manu/10000"

	gen popestimate2008_bil = popestimate2008/1000000000
	label variable popestimate2008_bil "population estimate 2008 in billionsreplace pop_density = pop_density/10000
	label variable pop_density "pop density/10000"

	*	Divides these ones by 100000
	foreach var in instrument paidout fmap oblig_med outlaysFMAP medsfsf {
		capture qui gen `var'_pc = `var'/popestimate2008
		capture qui replace `var'_pc = `var'_pc/100000
	}

	qui gen gdp_pc = 1000000*gdp_2008/popestimate2008

	foreach level in totalemp totalgov edhealth {
		gen sachange_`level'_pc = sachange_`level'/popestimate2008 
		gen sachange_`level'_lag_pc = sachange_`level'_lag/popestimate2008
		*gen `level'_baseline_pc = baseline`level'/popestimate2008
		}

	qui gen sachange_gov_broad_pc = sachange_totalgov_pc + sachange_edhealth_pc
	qui gen sachange_gov_broad_lag_pc = sachange_totalgov_lag_pc + sachange_edhealth_lag_pc
	*qui gen gov_broad_baseline_pc = totalgov_baseline_pc + edhealth_baseline_pc

	label variable paidout_pc "Total ARRA Payouts per capita ($100k)"
	label variable fmap_pc "ARRA FMAP Payouts per capita ($100k)"
	label variable oblig_med_pc "ARRA FMAP Obligations per capita($100k)"
	label variable instrument_pc "FMAP Instrument (100k)"
	label variable per_empl_manu "Employment manufacturing share"
	label variable share_kerry "2004 Kerry share"
	label variable union_share "Union share"
	label variable gdp_pc "GDP per capita divided by 10000"
	capture label variable qcew_ch_employ_pc "ch per capita employment, QCEW

	/********************************************************************************************************
	d. IV regressions
	*********************************************************************************************************/

	*	GENERAL PARAMETERS	
	*	Note: control3 must be defined after defining the level, or else the predicted employment won't be correct
		local control1 ""
		local control2 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil"

	foreach level in totalemp gov_broad {

		local control3 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil sachange_`level'_lag_pc"

		local endog "fmap_pc"
			
		qui ivregress 2sls sachange_`level'_pc `control3' (`endog' = instrument_pc), robust
		estimates store `level'_`endog'_`year_0'`month_0'

		matrix results = e(b)
		matrix `level'coeff[`ticker'+1,1] = results[1,"`endog'"]
	}	
}

/*************************************************************************************************************
3. Generate Figure 5
*************************************************************************************************************/

*********************
* make the cdf of the placebo coefficient distribution
*********************
*	Total employment
clear
svmat totalempcoeff
sum totalempcoeff1, detail
sort totalempcoeff1
gen frequency = 1/_N
gen cdf = sum(frequency)
gen totalemp_baseline = `totalemp_baseline'
gen y = .
replace y = 0 if _n==1
replace y = 1 if _n==2

twoway (scatter cdf totalempcoeff1, mcolor("205 215 245") mlcolor(black) ) (line y totalemp_baseline , lwidth(thick)), ///
title("Total Nonfarm") xtitle("Second stage coefficient") ytitle("CDF") ///
legend(off) scheme(s2mono) graphregion(color(white)) ylabel(,nogrid tposition(inside) angle(horizontal)) xlabel(,tposition(inside)) ///
plotregion(style(outline))  ysize(5) xsize(6)

graph save placebo_total, replace

*	Government, health, and education
clear
svmat gov_broadcoeff
sum gov_broadcoeff1, detail
sort gov_broadcoeff
gen frequency = 1/_N
gen cdf = sum(frequency)
gen gov_broad_baseline = `gov_broad_baseline'
gen y = .
replace y = 0 if _n==1
replace y = 1 if _n==2

twoway (scatter cdf gov_broadcoeff1, mcolor("205 215 245") mlcolor(black) ) (line y gov_broad_baseline , lwidth(thick)) , ///
title("Govt, Health, & Education") xtitle("Second stage coefficient") ytitle("CDF") ///
legend(off) scheme(s2mono) graphregion(color(white)) ylabel(,nogrid tposition(inside) angle(horizontal)) xlabel(,tposition(inside)) ///
plotregion(style(outline))  ysize(5) xsize(6) 

graph save placebo_gov_broad, replace

*	Combines the graphs
graph combine "placebo_total.gph" "placebo_gov_broad.gph", ///
ycommon xcommon title("Figure 5: Placebo Results", size(4)) ///
note("Note: Plots results of second stage regressions, where the outcome variable is seasonally" "adjusted change in employment for each overlapping 7 month period, starting in Jan" "2000 and ending in Dec 2008.  All regressions include the full set of control" "variables.  Coefficient from Dec 2008 to July 2009 is indicated with the vertical line." "Note that government excludes federal government employment.") ///
scheme(s2mono) graphregion(color(white)) plotregion(style(outline))  ysize(5) xsize(6)

graph save output/figure5_placebo, replace

erase placebo_total.gph
erase placebo_gov_broad.gph
