/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	01/06/2020
Modified by:	Dustin Swonder
Description:	This file replicates the figures in Slattery and Zidar's 
				"Evaluating State and Local Business Tax Incentives."
*******************************************************************************/

/*******************************************************************************
***	0. SET OUT-DIRECTORY AND DEFINE ES PROGRAMS WITH GRAPHDIR AS SPECIFIED *****
*******************************************************************************/

* For now, put all figures in my own graph directory
global graphdir "$outdir/figures"

do $dodir/programs/ES_programs.do

/*******************************************************************************
***	1. MAKE FIGURES ************************************************************
*******************************************************************************/

/*******************************************************************************
	FIGURE 1: CORPORATE TAX RATES AND TAX EXPENDITURES
*******************************************************************************/

/* Make a little dataset whose predicted values will form a line of best fit 
	spanning the entire graph when we make hybrid binscatters below */	
clear
set obs 9
qui gen line_point = 1
qui gen credits_percap = (_n - 1) * 10

tempfile line_points
save `line_points'

	/***************************************************************************
		LOAD IN AND PREP DATA
	***************************************************************************/

/* use $internaldir/data/raw/state_year_spending_incentives.dta, clear

keep year fips stateabbrev GDP corprate corptaxrev pop total_budget total_credits ///
	total_incentive grev_own_tax tot_exp genexp_direct 

save $processeddir/exhibit_collapses/state_year_spending_incentives_external.dta, replace */

use $processeddir/exhibit_collapses/state_year_spending_incentives_external.dta, clear

keep if year == 2014
drop if inlist(stateabbrev, "HI", "AK")

qui replace total_incentive = total_credits if total_incentive==.
qui replace total_incentive = total_budget if total_incentive==.

recode total_* (.=0)

qui gen gdp_percap  = (GDP * 1e6) / pop
qui gen corptaxrev_percap = (corptaxrev * 1000) / pop
	
foreach v in incentive budget credits {
	qui gen `v'_percap = total_`v' / pop
}

foreach v in incentive credits {
	qui gen `v'_percorp = `v'_percap / corptaxrev_percap
	qui gen `v'_pergdp = `v'_percap / gdp_percap
}

tabstat incentive_percorp credits_percorp ///
	incentive_pergdp *_percap, stats(mean p50) col(stats)

qui reg corprate credits_percap, r
local b = round(_b[credits_percap], .001)
local r2 = round(e(r2), .001)

	/***************************************************************************
		MAKE GRAPHS: BINSCATTERS OF FULL SAMPLE OF FIRMS RECEIVING SUBSIDIES
	***************************************************************************/

qui binscatter corprate credits_percap, savedata($dumpdir/bindata) replace

preserve

import delim using $dumpdir/bindata.csv, clear

qui gen bindata = 1 // indicator for whether points are binned

tempfile bindata_with_indicator
save `bindata_with_indicator'

restore

append using `line_points'
append using `bindata_with_indicator'

qui reg corprate credits_percap if bindata == 1
predict fitted_corprate if line_point == 1

graph twoway (lfit fitted_corprate credits_percap if line_point == 1, lcolor(red)) ///
	(scatter corprate credits_percap if bindata == 1, mlabsize(vsmall) ///
		mlabposition(12) ms(o) mc(navy)) ///
	(scatter corprate credits_percap if stateabbrev == "IN", mlab(stateabbrev) ///
		ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) mlabsize(medsmall) mlabposition(1)) ///
	(scatter corprate credits_percap if stateabbrev == "VA", mlab(stateabbrev) ///
		ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) mlabsize(medsmall) mlabposition(1)) ///
	(scatter corprate credits_percap if stateabbrev == "NY", mlab(stateabbrev) ///
		ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) mlabsize(medsmall) mlabposition(1)) ///
	(scatter corprate credits_percap if stateabbrev == "NC", mlab(stateabbrev) ///
		ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) mlabsize(medsmall) mlabposition(1)) ///
	(scatter corprate credits_percap if stateabbrev == "CA", mlab(stateabbrev) ///
		ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) mlabsize(medsmall) mlabposition(1)), ///
	$gpr xtitle("Per capita tax expenditures ({c $|})") ytitle("Corporate tax rate (%)") ///
	legend(off)
graph export $graphdir/fig1.pdf, replace

/*******************************************************************************
	FIGURE 2: COMPARING WINNER (HAMILTON, TN) AND LOSER (HUNTSVILLE, AL) 
				EMPLOYMENT IN WAKE OF VW DEAL
*******************************************************************************/

	/***************************************************************************
			LOAD IN AND PREP DATA
	***************************************************************************/

/* Load in dataset of deals (winners and runners-up); each deal identified by 
	variable "id" */
use $processeddir/deal_specific_analysis.dta, clear
	
* Drop unnecessary industry characteristics variables
drop *ind* *_2000 *_1990 *_res*

keep countyname naics3d_emp* naics3d_ln_emp* id deal_year winner /* sub jobs */

* Only interested in winner and runner-up for VW deal, so drop all other deals
keep if id == 518

* Reshape
reshape long naics3d_emp naics3d_ln_emp naics2d_emp naics2d_ln_emp ///
		naics1d_emp naics1d_ln_emp emp ln_emp ///
		naics3d_avg_wages avg_wages, i(county winner) j(eventyr, string)
destring eventyr, ignore(_) replace

/* Original data is coded in eventtime (E.g. eventyr == 100 is year of deal, 
	90 is 10 years before, 110 is 10 years after, etc.), so need to reverse
	engineer to get actual years */
gen year = deal_year + eventyr - 100

* Keep only 2000-2017
drop if year > 2017 | year < 2003

sort county year

	/***************************************************************************
			MAKE PLOT
	***************************************************************************/

* graph 3D employment
#delimit ;
twoway (scatter naics3d_emp year if county == "Hamilton", c(l))
	(scatter naics3d_emp  year if county == "Limestone, Madison", c(l) ms(dh)),
	xline(2008, lcolor(red) lpattern(shortdash))
	graphregion(lcolor(white) fcolor(white)) plotregion(color(white))
	xtitle(" ") ytitle("Employment in NAICS 336")
	legend(label(1 "Hamilton, TN") label(2 "Huntsville, AL") region(lcolor(white)))
	xlab(2003(1)2017, angle(315) labsize(small))
	;
graph export "$graphdir/fig2.pdf", replace;
#delimit cr

/*******************************************************************************
	FIGURE 3: SUBSIDIES RELATIVE TO AVERAGE WAGES AND SUBSIDY PER JOB
					RELATIVE TO AVERAGE WAGES
*******************************************************************************/

/* Make a little dataset whose predicted values will form a line of best fit 
	spanning the entire graph when we make hybrid binscatters below */
clear
set obs 12
qui gen line_point = 1
qui gen avg_wages_100 = _n * 10
drop if _n < 3

tempfile line_points
save `line_points'

	/***************************************************************************
		LOAD IN AND PREP DATA (need access to internal data to run this 
			commented-out section)
	***************************************************************************/

/* use $internaldir/data/processed/deal_specific_analysis.dta, clear

* Drop unnecessary variables
drop emp_74-avg_wages_res_89 emp_106-avg_wages_res_115	

* Get rid of runners-up
keep if winner == 1

* Rescale
replace avg_wages_100 = avg_wages_100/1000
replace cost_per_job = cost_per_job/1000

gen labelvar = countyname + ", " + stateabbrev + " (" + string(deal_year) + ")" // to make labels for specific dots

	/***************************************************************************
		MAKE GRAPHS: BINSCATTERS OF FULL SAMPLE OF FIRMS RECEIVING SUBSIDIES
	***************************************************************************/

qui binscatter cost_per_job avg_wages_100 [aw = pop_100], reportreg ///
	savedata("$dumpdir/cost_per_job_avgpay_bindata") replace
	
preserve

import delimited "$dumpdir/cost_per_job_avgpay_bindata.csv", clear

gen bindata_cost_per_job = 1 // going to append to main data set for graphing, want to keep track of which data points are from binning
tempfile bindata_cost_per_job
save `bindata_cost_per_job'

restore

append using `bindata_cost_per_job'
append using `line_points'

reg cost_per_job avg_wages_100 if bindata_cost_per_job == 1
predict fitted_cost_per_job if line_point == 1

keep id fitted_cost_per_job cost_per_job avg_wages_100 line_point bindata_cost_per_job ///
	labelvar

drop if missing(line_point) & missing(bindata_cost_per_job) & !inlist(id, 286, 220, 228, 521)

save $processeddir/exhibit_collapses/costperjob_vs_avg_wages.dta, replace */

use $processeddir/exhibit_collapses/costperjob_vs_avg_wages.dta, clear

twoway (lfit fitted_cost_per_job avg_wages_100 if line_point == 1, lcolor(red)) ///
	(scatter cost_per_job avg_wages_100 if bindata_cost_per_job == 1, mlabsize(vsmall) ///
		mlabposition(12) ms(o) mc(navy)) ///
	(scatter cost_per_job avg_wages_100 if id == 286, /// Albany, NY
		mlab(labelvar) ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) ///
		mlabsize(medsmall) mlabposition(1)) ///
	(scatter cost_per_job avg_wages_100 if id == 220, /// Suffolk, MA 
		mlab(labelvar) ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) ///
		mlabsize(medsmall) mlabposition(1)) ///
	(scatter cost_per_job avg_wages_100 if id == 228, /// San Francisco, CA
		mlab(labelvar) ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) ///
		mlabsize(medsmall) mlabposition(8)) ///
	(scatter cost_per_job avg_wages_100 if id == 521, /// Charleston, SC
		mlab(labelvar) ms(T) msize(*0.8) mc(dknavy) mlabcolor(dknavy) ///
		mlabsize(medsmall) mlabposition(1)), ///
	graphregion(lcolor(white) fcolor(white)) legend(off) ///
		ytitle("Cost per job (1000s 2017 USD, binned)") ///
		xtitle("Average Wages (1000s USD, binned)") xlab(40(20)120)
graph export "$graphdir/fig3.pdf", replace

/*******************************************************************************
	FIGURE 4: EVENT STUDY GRAPHS FROM OUR DATA SHOWING THE EFFECT OF A FIRM-
				SPECIFIC DEAL ON EMPLOYMENT IN 3-D INDUSTRY OF DEAL AND LOG 
				HPI AT THE COUNTY LEVEL
*******************************************************************************/

	/***************************************************************************
		1) PREP DATA 
	***************************************************************************/
		
		/***********************************************************************
			1.1) Make lists of important variables
		***********************************************************************/
		
use $processeddir/deal_specific_analysis.dta, clear

drop emp_74-avg_wages_res_89 emp_106-avg_wages_res_115	

global X_10pre "ln_pop_90 ln_emp_90 ln_avg_wages_90"

keep if sample == 1

	/***************************************************************************
		2) MAKE PLOTS; PANELS A & B CREATED TOGETHER IN LOOP
	***************************************************************************/
		
foreach var in naics3d_emp ln_HPI {

	if regexm("`var'", "emp") {
		local lab = "County-level employment"
		local outname = "fig4a"
	} 
	else {
		local lab "Log county HPI"
		local outname = "fig4b"
	}

	qui gen b  = . // Capture event study coefficients and SEs; actually going to be 
	qui gen se = . // stored in variables

	qui gen eventtime = _n-6 /* To keep track of row-eventyr correspondency when 
							storing b and se; row 1 = 5 years before event, etc. */

	forv i=95/105 {
		qui reg `var'_`i' winner $X_10pre i.deal_year // Get event study regressions
		qui estimates store R`i'
	}

	qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105, vce(cluster fips)

	forv i=95/105{
		local row = `i' - 94

		qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

		qui replace b  =  r(estimate) if _n == `row' // Store event-study coefficients in corresponding rows
		qui replace se =  r(se) if _n == `row' // likewise for SEs
	}

	preserve // Make graph using stored coefficients and SEs

	keep in 1/11
	rename eventtime fig_t
	ES_graph, ci(1.96) xti("Years since deal") yti("`lab'") lab1(Impact) ///
		outname(`outname')
	
	restore
	
	capture drop b se eventtime
}