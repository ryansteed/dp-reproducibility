/*************************************************************************************************************
TimingGraphs_Figures3_4
Layout of code is:
1. Declare locals
2. Build dataset
3. Loop over months
	a. Rescale variables
	b. IV regressions
4. Generate Figures 3 and 4
*************************************************************************************************************/
version 10.1
clear
set more off
set mem 300m
set matsize 800

cd "$dir"

/*************************************************************************************************************
1. Declare locals
*************************************************************************************************************/
**Set dates for period 0 and period 1 employment
local month0 = ym(2008,12)
local month1 = ym(2009,1)
local month_end = ym(2010,6)

**Set dates for lagged employment
local l_month0 = ym(2008,5)
local l_month1 = ym(2008,12)

**SA or NSA data?. SA is "" and NSA is NSA.
local adj ""

**Period for instrument
*local FMAP_period 31dec2010
local FMAP_period 30jun2010

**Data vintage
local vintage june82011

local year_0 = year(dofm(`month0'))
local month_0 = month(dofm(`month0'))
local l_year_0 = year(dofm(`l_month0'))
local l_month_0 = month(dofm(`l_month0'))
local l_year_1 = year(dofm(`l_month1'))
local l_month_1 = month(dofm(`l_month1'))
local no_periods = `month_end' - `month1' + 1

/*************************************************************************************************************
2. Build dataset
*************************************************************************************************************/

*First, get the instrument
use data/state_medicaid_spending_instrument, replace

*Now, merge in state population
*downloaded from Haver, July 20
sort state_abrev
merge state_abrev using data/pop16plus_cleaned, unique
replace pop16plus = pop16plus*1000
tab _merge
drop _merge
rename pop16plus popestimate2008

*Merge other state controls
sort state_abrev
merge state_abrev using data/state_controls
drop _m
sort state_abrev
*Note: we rescale GDP so that it is not too large relative to the other variables
rename gdp_2008 gdp_2008_old
gen gdp_2008 = gdp_2008_old/1000000
label variable gdp_2008 "GDP divided by 1,000,000"
drop gdp_2008_old

forvalues i=1/9 {
qui gen region_`i' = cond(__region_dummies==`i',1,0)
label variable region_`i' "Region `i'"
}

local regions "region_1 region_2 region_3 region_4 region_5 region_6 region_7 region_8 region_9"
local _regions "region_2 region_3 region_4 region_5 region_6 region_7 region_8 region_9"

*****Merge in the state categories of spending
preserve
use data/ARRASpending, clear
keep if date==td(`FMAP_period')
rename  state_acronym state_abrev
drop if state_abrev==""
gen outlays_total = outlaysFMAP + outlaysOther + outlaysSFSF
rename obligationsFMAP oblig_med 
label variable outlays_total "total ARRA outlays as of `spending_date'"
gen medsfsf = outlaysFMAP + outlaysSFSF 
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

*Employment data
foreach level in totalemp totalgov edhealth education health {
preserve
use data/CES/`level'`vintage'`adj', replace
qui drop if state_abrev==""
foreach var of varlist _* {
	rename `var' `var'`level'
}
tempfile `level'
qui save ``level''
restore
merge state_abrev using ``level'', sort

qui keep if _merge==3
drop _merge
}

/*************************************************************************************************************
3. Loop over months
*************************************************************************************************************/
forvalues start = `month1'/`month_end' {
	preserve

	local year_1 = year(dofm(`start'))
	local month_1 = month(dofm(`start'))

	local period `year_0'`month_0'_`year_1'`month_1'

	display("`period'")
	
	foreach level in totalemp totalgov edhealth education health {
		qui gen change_`level' = 1000*(_`year_1'`month_1'`level' - _`year_0'`month_0'`level') 
		qui gen change_`level'_lag = 1000*(_`l_year_1'`l_month_1'`level' - _`l_year_0'`l_month_0'`level') 
		qui gen initial_`level' = _`year_0'`month_0'`level'
	}

	/********************************************************************************************************
	a. Rescale variables
	*********************************************************************************************************/
	gen share_kerry_10000 = share_kerry/10000
	label variable share_kerry_10000 "share kerry / 10000"
	
	gen union_share_10000 = union_share/10000
	label variable union_share_10000 "union share/ 10000"
	
	gen per_empl_manu_10000 = per_empl_manu/10000
	label variable per_empl_manu_10000 "per_empl_manu/10000"
	
	gen popestimate2008_bil = popestimate2008/1000000000
	label variable popestimate2008_bil "population estimate 2008 in billionsqui replace pop_density = pop_density/10000
	
	*	Divides these ones by 100000
	foreach var in instrument paidout fmap oblig_med outlaysFMAP medsfsf {
		capture qui gen `var'_pc = `var'/popestimate2008
		capture qui replace `var'_pc = `var'_pc/100000
	}
	
	qui gen gdp_pc = 1000000*gdp_2008/popestimate2008
	
	foreach level in totalemp totalgov edhealth education health {
		qui gen change_`level'_pc = change_`level'/popestimate2008 
		qui gen change_`level'_lag_pc = change_`level'_lag/popestimate2008
		qui gen initial_`level'_pc = initial_`level'/popestimate2008 
		*gen `level'_baseline_pc = baseline`level'/popestimate2008
		}

	qui gen change_gov_broad_pc = change_totalgov_pc + change_edhealth_pc
	qui gen change_gov_broad_lag_pc = change_totalgov_lag_pc + change_edhealth_lag_pc
	qui gen initial_gov_broad_pc = initial_totalgov_pc + initial_edhealth_pc
	*qui gen gov_broad_baseline_pc = totalgov_baseline_pc + edhealth_baseline_pc
	
	label variable paidout_pc "Total ARRA Payouts per capita ($100k)"
	label variable fmap_pc "ARRA FMAP Payouts per capita ($100k)"
	label variable oblig_med_pc "ARRA FMAP Obligations per capita($100k)"
	label variable instrument_pc "FMAP Instrument (100k)"
	*label variable d_employment_hat_`period'_pc "Imputed employment change"
	* label variable change_`l_period'_pc "Lagged employment change per capita"
	label variable per_empl_manu "Employment manufacturing share"
	label variable share_kerry "2004 Kerry share"
	label variable union_share "Union share"
	label variable gdp_pc "GDP per capita divided by 10000"
	capture label variable qcew_ch_employ_pc "ch per capita employment, QCEW"
	
	/********************************************************************************************************
	b. IV regressions
	*********************************************************************************************************/
	local totalemp "Figure 3: Total Nonfarm"
	local gov_broad "Figure 4: Government, Health and Education"
	foreach level in totalemp gov_broad {

		local control "`_regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil  change_`level'_lag_pc"
		local endog "fmap_pc"

		qui ivregress 2sls change_`level'_pc `control' (`endog' = instrument_pc), robust
		local b`level'`year_1'`month_1' = _b[`endog']
		local se`level'`year_1'`month_1' = _se[`endog']
		estimates store `level'_`i'_`start'

	}
	restore
}

/*************************************************************************************************************
4. Generate Figures 3 and 4
*************************************************************************************************************/

*	Construct new dataset of coefficients and standard errors
clear
#delimit;
set obs `no_periods';
qui gen month = `month1';
qui replace month = month[_n-1]+1 if _n>1;
qui tsset month, monthly;
qui format month %tm;
foreach level in totalemp gov_broad {; 
	foreach param in b se {;
		qui gen `param'`level' = .;
		forvalues start = `month1'/`month_end' {;
			local year_1 = year(dofm(`start'));
			local month_1 = month(dofm(`start'));
			qui replace `param'`level' = ``param'`level'`year_1'`month_1'' if month==tm(`year_1'm`month_1');
		};
	};
	qui gen upper`level' = b`level' + 1.96* se`level';
	qui gen lower`level' = b`level' - 1.96* se`level';
	twoway (tsline b`level', lpattern(solid) lcolor(blue) lwidth(medthick)) (tsline upper`level', lpattern(dash) lcolor(blue) lwidth(medthick)) (tsline lower`level', lpattern(dash) lcolor(blue) lwidth(medthick)),
title("``level'' Second Stage Coefficients", position(12) span size(medlarge) color(black) margin(b=2)) 
subtitle("Value of coefficient on FMAP outlays", position(11) span margin(b=2) size(small)) 
note("Note: This chart displays the second stage coefficient for regressions where the outcome" "variable is the change in seasonally adjusted employment between December 2008 and" "the month indicated on the x-axis. The variable of interest is total FMAP outlays. Regressions" "include the full set of controls. The 95% confidence interval, derived from robust standard" "errors, is plotted in dashed lines.", size(small) span) 
legend(off) scheme(s2mono) graphregion(color(white)) plotregion(style(outline) lstyle(foreground) margin(tiny)) xlabel(#`no_periods',tposition(outside) angle(vertical) labsize(small) format(%tmMon-YY)) 
ylabel(,tposition(outside) angle(horizontal) labsize(small)) ytitle("") ttitle("") ysize(5) xsize(6);
qui graph export output/figures3_4_`level'.emf, replace;
graph save output/figures3_4_`level', replace;
};

