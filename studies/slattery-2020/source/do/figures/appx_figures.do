/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	02/27/2020
Modified by:	Dustin Swonder
Description:	This file replicates the appendix figures in Slattery and  
				Zidar's "Evaluating State and Local Business Tax Incentives."
*******************************************************************************/

/*******************************************************************************
***	SET OUT-DIRECTORY AND DEFINE ES PROGRAMS WITH GRAPHDIR AS SPECIFIED ********
*******************************************************************************/

global graphdir "$outdir/figures/appendix"

do $dodir/programs/ES_programs.do

/*******************************************************************************
	APPX FIGURES 1A-D: SCATTER, DiD EMPLOYMENT BY NUMBER OF JOBS PROMISED, 
		SIZE OF SUBSIDY (need access to internal data to run commented-out 
			section of code)
*******************************************************************************/
	
#delimit ;
di as error "Reproducing this figure requires our firm-specific incentive deal  " _newline
			"dataset from Slattery (2019), which we do not provide in external  " _newline
			"replication files. It includes some proprietary firm-specific deal " _newline
			"information (namely firm names,  subsidies awarded, jobs promised, " _newline
			"and investment promised at the deal level).";
#delimit cr
	
	/***************************************************************************
		1) LOAD AND PREP DATA 
	***************************************************************************/

		/***********************************************************************
			1.1) Prep main dataset
		***********************************************************************/

/* 
use $internaldir/data/processed/deal_specific_analysis.dta, clear
keep id runnerup_id winner sample naics3d_emp_* jobs cost_per_job subsidy ///
	stateabbrev naics4d deal_year

tempvar pairwise_comp sample_miss_runnerup runnersup_in_sample winner_in_sample

* Count number of runners-up for each winner in sample
gen `sample_miss_runnerup' = cond(sample == 1 & !winner, 1, .)
bysort id: egen `runnersup_in_sample' = count(`sample_miss_runnerup')

* Indicator for whether winner for winner/runner(s)-up set is in sample
bysort id: egen `winner_in_sample' = max(winner == 1 & sample == 1)

* Only keep if winner and at least one runner-up are in sample
bysort id: egen `pairwise_comp' = min(`winner_in_sample' & `runnersup_in_sample' > 0)
keep if `pairwise_comp'  == 1

*reshape long
reshape long naics3d_emp, i(id runnerup_id) ///
	j(eventyr _90 _95 _96 _97 _98 _99 _100 _101 _102 _103 _104 _105, string)

destring eventyr, ignore(_) replace

tempfile main_data
sort id runnerup_id
save `main_data'
	
		/***********************************************************************
			1.2) Store characteristics of runner-up counties in their own 
				dedicated variables with suffix 0; save in separate dataset.
		***********************************************************************/
		
use `main_data', clear

keep if winner == 0 
egen tag = tag(id eventyr) // Can only have one runner-up (why?)
keep if tag == 1 

keep id naics3d_emp eventyr

rename naics3d_emp naics3d_emp0

tempfile runnerup_data
save `runnerup_data'
 
		/***********************************************************************
			1.3) Store characteristics of winner counties in their own dedicated 
				variables with suffix 1; save in separate dataset.
		***********************************************************************/
		
use `main_data', clear

keep if winner == 1 

keep id naics3d_emp eventyr stateabbrev

rename naics3d_emp naics3d_emp1

tempfile winner_data
save `winner_data'

		/***********************************************************************
			1.4) Merge winner & runner-up information onto "spine"; gen diff 
				variables
		***********************************************************************/

use `main_data', clear

keep id eventyr sub *jobs cost_per* naics4
duplicates drop id eventyr, force // Keep one observation for each winner/runner-up pair in sample, forming sort of spine

sort id eventyr

* Merge winners variables onto "spine"
merge 1:1 id eventyr using `winner_data', assert(3) nogen

sort id eventyr

* Merge runner-up variables onto "spine"
merge 1:1 id eventyr using `runnerup_data', assert(3) nogen

* Gen variable giving difference b/w variables in winner, runner-up counties
g D_naics3d_emp = naics3d_emp1 - naics3d_emp0 

tempfile diffs_data
save `diffs_data'

		/***********************************************************************
			1.5) reshape wide so each place is a row, clean up a bit
		***********************************************************************/

rename naics3d_emp1 naics3d_emp1_
rename naics3d_emp0 naics3d_emp0_
rename D_naics3d_emp D_naics3d_emp_

reshape wide D_naics3d_emp_ naics3d_emp1_ naics3d_emp0_, i(id stateabbrev) j(eventyr)

egen naics3d_emp1_pre = rowmean(naics3d_emp1_95 naics3d_emp1_96 naics3d_emp1_97 ///
								naics3d_emp1_98 naics3d_emp1_99)

order id subsidy jobs cost_per_job

compress

g deallab = stateabbrev + string(naics4d) // Create labels for scatterplot

		/***********************************************************************
			1.6) Calc DD
		***********************************************************************/
		
*Calc DD for mean 95-99 and 100-105
egen D_naics3d_emp_pre = rowmean(D_naics3d_emp_9?)
egen D_naics3d_emp_post = rowmean(D_naics3d_emp_10?)

gen DD_naics3d_emp = cond(mi(D_naics3d_emp_post) | mi(D_naics3d_emp_pre), ., ///
							D_naics3d_emp_post-D_naics3d_emp_pre)

gen DD_naics3d_emp_pct = cond(mi(naics3d_emp1_pre), . , ///
								(D_naics3d_emp_post-D_naics3d_emp_pre)/naics3d_emp1_pre *100)

foreach variable in jobs sub { // Compute means of variables we're interested in
	if "`variable'" == "sub" {
		local var = "subsidy"
	}
	else {
		local var = "`variable'"
	}
	
	summ `var'
	gl mean`variable' = r(mean) 
	gl mean`variable'_str = round(r(mean))
}

*before plotting, "censor" the x var for the sake of visualization
replace jobs = 4000 if jobs > 4000 & !missing(jobs)
replace subsidy = 500 if subsidy > 500 & !missing(jobs)

*winzorize y var at 95% level
gen DD_naics3d_emp_nonwinz = DD_naics3d_emp
winzorize, var(DD_naics3d_emp) pct(5)
winzorize, var(DD_naics3d_emp_pct) pct(5)

	/***************************************************************************
		2) MAKE DD GRAPHS
	***************************************************************************/

gen firm = "Volkswagen" if id == 518

keep DD_naics3d_emp DD_naics3d_emp_pct firm jobs subsidy deallab meanjobs meansub

foreach var in jobs subsidy { // Cycle through jobs and subsidy to make graphs
	foreach lhs in DD_naics3d_emp DD_naics3d_emp_pct {

		qui summ `lhs', detail
		local meanimpact = r(mean) 
		local p0impact = r(min) 
		local meanimpact_str = string(round(r(mean)), "%9.0f")
		
		* Set a few parameters before making graph
		if "`var'" == "jobs" {
			local xtitle = "Number of jobs promised"
			if regexm("`lhs'", "pct") {
				local subfig = "b"
			}
			else {
				local subfig = "a"
			}
		}
		else {
			local xtitle = "Subsidy ({c $|}M 2017)"
			if regexm("`lhs'", "pct") {
				local subfig = "d"
			}
			else {
				local subfig = "c"
			}
		}
		
		if regexm("`lhs'", "pct") {
			local ytitle_tidbit = "% "
		}
		else {
			local ytitle_tidbit = ""
		}

		twoway (scatter `lhs' `var' if firm == "", mlab(deallab) mlabsize(vsmall) mlabposition(12) ms(o)) ///
			(scatter `lhs' `var' if firm == "Volkswagen", mlab(firm) ///
				ms(S) msize(*1.2) mc(black) mlabcolor(black) mlabsize(medsmall) mlabposition(8)), ///
			graphregion(lcolor(white) fcolor(white)) plotregion(color(white)) ///
			xline($meanjobs, lcolor(gs8) lpattern(dot)) legend(off) ///
			text(`=`p0impact'-1000' `=$meanjobs+50' "$meanjobs_str", size(small) color(gs8)) ///
			yline(`meanimpact', lcolor(red) lpattern(shortdash)) ///
			text(`=`meanimpact'' -190 "`meanimpact_str'", size(small) color(red)) ///
			ytitle("Pairwise D-i-D Estimate:" "`ytitle_tidbit'Chg in 3-D State Ind. Emp.") ///
			xtitle("`xtitle'")
		
		graph export "$graphdir/appxfig1`subfig'.pdf", replace
	}
} */

/*******************************************************************************
	APPX FIGURE 2: CORRELOGRAM, STATE-LEVEL CHARACTERISTICS AND PER CAPITA 
		INCENTIVE SPENDING
*******************************************************************************/

	/***************************************************************************
		1) LOAD IN AND PREP DATA 
	***************************************************************************/

use "$rawdir/state_year_chars.dta", clear

* calculate total business contribution to governor, house and senate
egen bc_all=rowtotal(bc_gov bc_house bc_senate)

* indicators for whether the governor is a democrat
qui gen dem_gov=(gov_party=="Democratic")

* indicators for whether the governor and the legislative body are controlled
* by democrats
qui gen dem_state=(party_control=="Dem")

foreach v in GDP GOS bc_gov bc_all emp_CBP educ_expend grev_own_tax corptaxrev ///
	total_incentives {
	qui gen `v'_percap = `v'/pop
}

* Convert everything to per-capita
qui gen avg_wage=avgpay_CBP/emp_CBP
qui gen avg_comp = comp/emp_CBP
rename emp_CBP_percap epop 
rename total_incentives_percap incentive_percap

* label variables
label var GDP_percap "GDP per-capita"
label var GOS_percap "GOS per-capita"
label var epop "Employment/Population"
label var avg_wage "Average Wages"
label var avg_comp "Average Compensation"
label var educ_expend_percap "Educ. Spend per-capita"
label var grev_own_tax_percap "Total Tax Rev. per-capita"
label var corptaxrev_percap "Corp. Tax Rev. per-capita"
label var bc_gov_percap "Biz Contrib. to Governor per-capita"
label var bc_all_percap "Biz Contrib. to Gov+Leg per-capita"
label var corprate "Top Corp. Tax Rate"
label var union_perc_member "Percent Union Members"
label var dem_gov "Democrat Governor"
label var dem_state "Democrat Gov + Legislature"

tempfile orig
save `orig'

* Make correlogram data: full sample and 2014 sample.
clear
tempfile correlogram correlogram2014
set obs 1
gen row = .
save `correlogram'
save `correlogram2014'

*CORRELATES
#delimit ; /* change delimiter*/
local lhs incentive_percap ; /* left-hand side variable */
local corrs
	GDP_percap 
	GOS_percap 
	epop 
	avg_wage 
	avg_comp 
	educ_expend_percap
	grev_own_tax_percap 
	corptaxrev_percap
	bc_gov_percap 
	bc_all_percap 
	corprate 
	union_perc_member 
	dem_gov 
	dem_state
	;
#delimit cr

* Calculate correlations in the full sample
local count = 1
use `orig', clear
foreach v of varlist `corrs' {
	di as error "`lhs'"
	sum `lhs' 
	replace `lhs'= `lhs'/`r(sd)' //standardize LHS variable

	sum `v' 
	qui replace `v' = `v'/`r(sd)' //standardize RHS variable
	qui reg `lhs' `v' //run regression of LHS on RHS
	local b = _b[`v'] //save local of correlation
	local se = _se[`v'] //save local of stadard error
	local varname = "`v'"
	clear
	set obs 2
	qui gen row = `count' //save to a new row and make sure each result gets a line
	qui gen xvar_b = `b'
	g varname = subinstr("`varname'", "", "", .) 
	qui gen ci = `b' + 1.96*`se' if _n == 1 //calculate confidence interval
	qui replace ci = `b' - 1.96*`se' if _n == 2
	g type = "full" //this step is only needed when running multiple samples
	append using `correlogram' //in each round of regressions, save 
			//the full sample file with the previous rounds and 
			// the newest correlation results
	save `correlogram', replace
	local count = `count' + 1
	use `orig', clear //reload data
}

* Calculate correlations in 2014 only (skip this if only one sample, e.g.)
local count = 1
use `orig', clear
foreach v of varlist `corrs' {
	keep if year==2014 //only keeping 2014 sample

	di as error "`lhs'"
	sum `lhs' 
	replace `lhs'= `lhs'/`r(sd)' //standardize LHS variable

	sum `v' 
	qui replace `v' = `v'/`r(sd)' //standardize RHS variable
	qui reg `lhs' `v' //run regression of LHS on RHS
	local b = _b[`v'] //save local of correlation
	local se = _se[`v'] //save local of stadard error
	local varname = "`v'"
	clear
	set obs 2
	qui gen row = `count' //save to a new row and make sure each result gets a line
	qui gen xvar_b = `b'
	g varname = subinstr("`varname'", "", "", .) 
	qui gen ci = `b' + 1.96*`se' if _n == 1 //calculate confidence interval
	qui replace ci = `b' - 1.96*`se' if _n == 2

	g type = "2014"
	append using `correlogram2014'
	save `correlogram2014', replace
	local count = `count' + 1
	use `orig', clear //reload data
}

* Append the results
use `correlogram', clear
append using `correlogram2014'

replace row = row-.5 if type=="2014" //change the row number ofr 2014 so
	// that we can offset the coefficients in the plot

gsort -row
* Add horizontal guide lines
global yline " "
forv i = 1 / 14 {
	global yline "$yline yline(`i', lcolor(gs15)) "
}

* Define row labels
#delimit ;
label define ylabels
	1 "GDP per capita"
	2 "GOS per capita"
	3 "Employment/Population"
	4 "Average Wages"
	5 "Average Compensation"
	6 "Educ. Spend per-capita"
	7 "Total Tax Rev. per-capita"
	8 "Corp. Tax Rev. per-capita"
	9 "Biz Contrib. to Governor per-capita"
	10 "Biz Contrib. to Gov+Leg per-capita"
	11 "Top Corp. Tax Rate"
	12 "Percent Union Members"
	13 "Democrat Governor"
	14 "Democrat Gov + Legislature"
	; 
#delimit cr
	
label values row ylabels

* Make correlogram graph
#delimit ;
sort row;
twoway /* Plot the full sample results in one color, using a given marker */
	(scatter row xvar_b if type=="full", mc(navy) m(s)) 
	(scatter row ci if row == 1 & type=="full", c(l) lc(navy) m(i))
	(scatter row ci if row == 2 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 3 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 4 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 5 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 6 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 7 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 8 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 9 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 10 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 11 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 12 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 13 & type=="full" , c(l) lc(navy) m(i))
	(scatter row ci if row == 14 & type=="full" , c(l) lc(navy) m(i))

		/* Plot the 2014 results in another color, using a different marker */
	(scatter row xvar_b if type=="2014", mc(maroon) m(dh)) 
	(scatter row ci if row == 1-.5 & type=="2014", c(l) lc(maroon) m(i))
	(scatter row ci if row == 2-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 3-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 4-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 5-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 6-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 7-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 8-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 9-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 10-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 11-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 12-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 13-.5 & type=="2014" , c(l) lc(maroon) m(i))
	(scatter row ci if row == 14-.5 & type=="2014" , c(l) lc(maroon) m(i))
	,
	plotregion(fcolor(white) lcolor(white)) graphregion(fcolor(white) lcolor(white))
	 legend(region(lcolor(white)) label(1 "Full Sample") label(16 "Only 2014") order(1 16))
		ylab(1(1)14, labsize(small) valuelabel angle(0) nogrid tlength(0)) 
		ytitle("") ysize(7) $yline 
		/* vertical guidelines*/
		xline(-.4, lcolor(gs15) lpattern(shortdash))
		xline(-.3, lcolor(gs15) lpattern(shortdash))
		xline(-.2, lcolor(gs15) lpattern(shortdash))
		xline(-.1, lcolor(gs15) lpattern(shortdash))
		xline(.1, lcolor(gs15) lpattern(shortdash))
		xline(.2, lcolor(gs15) lpattern(shortdash))
		xline(.3, lcolor(gs15) lpattern(shortdash))
		xline(.4, lcolor(gs15) lpattern(shortdash))
		xline(.5, lcolor(gs15) lpattern(shortdash))
		xline(.6, lcolor(gs15) lpattern(shortdash))
		xline(.7, lcolor(gs15) lpattern(shortdash))
		xlab(-.4(.2).6) xline(0, lc(black))  xsc(titlegap(2))
		xtitle("Correlation") ;
#delimit cr

* graph export "$graphdir_ds/xpds/stchar_correlogram_with_rtw.pdf", replace
graph export "$graphdir/appxfig2.pdf", replace

/*******************************************************************************
	APPX FIGURES 3A & B: EFFECT OF A FIRM-SPECIFIC DEAL ON EMPLOYMENT IN 3-D 
		INDUSTRY OF DEAL IN OUR DEALS DATASET AND IN JVR DEALS DATASET
*******************************************************************************/

		/***********************************************************************
			1) PREP DATA 
		***********************************************************************/
			
			/*******************************************************************
				1.1) Make lists of important variables
			*******************************************************************/
		
use "$processeddir/deal_specific_analysis.dta", clear

drop emp_74-avg_wages_res_89 emp_106-avg_wages_res_115	

global X_10pre "ln_pop_90 ln_emp_90 ln_avg_wages_90"

keep if sample == 1

		/***********************************************************************
			PANEL A: IN OUR DATASET
		***********************************************************************/

qui gen b  = . // Capture event study coefficients and SEs; actually going to be 
qui gen se = . // stored in variables

qui gen eventtime = _n-6 /* To keep track of row-eventyr correspondency when 
						storing b and se; row 1 = 5 years before event, etc. */

forv i=95/105 {
	qui reg naics3d_emp_`i' winner $X_10pre i.deal_year // Get event study regressions
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105, vce(cluster fips)

disp "Simple event study"
forv i=95/105 {
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b  =  r(estimate) if _n == `row' // Store event-study coefficients in corresponding rows
	qui replace se =  r(se) if _n == `row' // likewise for SEs
}

preserve // Actually make graph using stored coefficients and SEs

keep in 1/11
rename eventtime fig_t
ES_graph, ci(1.96) xti("Years since deal") ///
	yti("Employment in 3-D industry of deal") lab1(Impact) outname(appxfig3a)

restore

capture drop b se eventtime

	/***************************************************************************
		PANEL B: EFFECT OF A FIRM-SPECIFIC DEAL ON EMPLOYMENT IN 3-D INDUSTRY 
			OF DEAL IN JVR DEALS DATASET
	***************************************************************************/

use $processeddir/deal_specific_jvr_analysis.dta, clear

qui gen b  = . // Capture event study coefficients and SEs; actually going to be 
qui gen se = . // stored in variables

qui gen eventtime = _n-6 /* To keep track of row-eventyr correspondency when 
						storing b and se; row 1 = 5 years before event, etc. */

forv i=95/105 {
	qui reg naics3d_emp_`i' winner `X_10pre' i.deal_year // Get event study regressions
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105, vce(cluster fips)

disp "Simple event study"
forv i=95/105{
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b  =  r(estimate) if _n == `row' // Store event-study coefficients in corresponding rows
	qui replace se =  r(se) if _n == `row' // likewise for SEs
}

preserve // Actually make graph using stored coefficients and SEs

keep in 1/11
rename eventtime fig_t
ES_graph, ci(1.96) xti("Years since deal") yti("Employment in 3-D industry of deal") ///
	lab1(Impact) outname(appxfig3b)

restore

capture drop b se eventtime

/*******************************************************************************
	APPENDIX FIGURE 4: EVENT STUDY GRAPHS WITH SPILLOVERS, OUR DATASET AND JVR
		DATASET
*******************************************************************************/

	/***************************************************************************
		PANEL A: EFFECT OF A FIRM-SPECIFIC DEAL ON EMPLOYMENT IN 3-D INDUSTRY 
			OF DEAL IN OUR DEALS DATASET
	***************************************************************************/

		/***********************************************************************
			1) PREP DATA 
		***********************************************************************/
			
			/*******************************************************************
				1.1) Make lists of important variables
			*******************************************************************/
		
use "$processeddir/deal_specific_analysis.dta", clear

drop emp_74-avg_wages_res_89 emp_106-avg_wages_res_115	

global X_10pre "ln_pop_90 ln_emp_90 ln_avg_wages_90"

keep if sample == 1

	/***************************************************************************
		PANEL A: EFFECT OF A FIRM-SPECIFIC DEAL ON EMPLOYMENT IN 3-D INDUSTRY 
			OF DEAL IN OUR DEALS DATASET WITH SPILLOVERS ONTO 1-D INDUSTRY, 2-D
			INDUSTRY, AND COUNTY-WIDE EMPLOYMENT
	***************************************************************************/

* Capture the values, naics 3d
qui gen b1  = .
qui gen se1 = .

qui gen eventtime1 = _n-6

forv i=95 / 105 {
	qui reg naics3d_emp_`i' winner $X_10pre i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105 {
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b1  = r(estimate) if _n==`row'
	qui replace se1 =  r(se) if _n==`row'
}

* Capture the values, naics 2d, residual
qui gen b2  = .
qui gen se2 = .

qui gen eventtime2 = _n-6

forv i=95/105 {
	qui reg naics2d_emp_res_`i' winner $X_10pre i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105 {
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b2  =  round(100*r(estimate))/100 if _n==`row'
	qui replace se2 =  round(100*r(se))/100 if _n==`row'
}

* Capture the values, naics 1d, residual
qui gen b3  = .
qui gen se3 = .

qui gen eventtime3 = _n-6

forv i=95/105{
	qui reg naics1d_emp_res_`i' winner $X_10pre i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105 {
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b3  =  round(100*r(estimate))/100 if _n == `row'
	qui replace se3 =  round(100*r(se))/100 if _n == `row'
}


* Capture the values, all emp, residual
qui gen b4  = .
qui gen se4 = .

qui gen eventtime4 = _n-6

forv i=95/105 {
	qui reg emp_res_`i' winner $X_10pre i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105{
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b4  =  round(100*r(estimate))/100 if _n == `row'
	qui replace se4 =  round(100*r(se))/100 if _n == `row'
}

preserve

keep in 1/11 // Make plot

rename (eventtime1 eventtime2 eventtime3 ) (fig_t1 fig_t2 fig_t3) 
qui replace fig_t2 = fig_t2 - .13 if fig_t2!=-1

qui replace fig_t3 = fig_t3 + .13 if fig_t3!=-1

ES_graph3, ci(1.96) xti("Years since deal") yti("Employment") ///
	lab1(3-D) lab2(2-Digit Residual) lab3(1-Digit Residual) ///
	outname(appxfig4a) row(1)

restore

capture drop  b1 b2 b3 b4 se1 se2 se3 se4  eventtime*

	/***************************************************************************
		PANEL B: EFFECT OF A FIRM-SPECIFIC DEAL ON EMPLOYMENT IN 3-D INDUSTRY 
			OF DEAL IN JVR DEALS DATASET WITH SPILLOVERS ONTO 1-D INDUSTRY, 2-D
			INDUSTRY, AND COUNTY-WIDE EMPLOYMENT
	***************************************************************************/

use $processeddir/deal_specific_jvr_analysis.dta, clear

forv eventyr = 95/105 {
	forv i = 1/2 { // Make residual employment variables
		gen naics`i'd_emp_res_`eventyr' = naics`i'd_emp_`eventyr' - naics3d_emp_`eventyr'
	}
	gen emp_res_`eventyr' = emp_`eventyr' - naics3d_emp_`eventyr'
}

* Capture the values, naics 3d
qui gen b1  = .
qui gen se1 = .

qui gen eventtime1 = _n-6

forv i=95/105 {
	qui reg naics3d_emp_`i' winner ln_pop_90 ln_emp_90 ln_avg_wages_90 i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105 {
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b1  = r(estimate) if _n==`row'
	qui replace se1 =  r(se) if _n==`row'
}

* Capture the values, naics 2d, residual
qui gen b2  = .
qui gen se2 = .

qui gen eventtime2 = _n-6

forv i=95/105 {
	qui reg naics2d_emp_res_`i' winner ln_pop_90 ln_emp_90 ln_avg_wages_90 i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105 {
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b2  = round(100*r(estimate))/100 if _n==`row'
	qui replace se2 = round(100*r(se))/100 if _n==`row'
}

* Capture the values, naics 1d, residual
qui gen b3  = .
qui gen se3 = .

qui gen eventtime3 = _n-6

forv i=95/105{
	qui reg naics1d_emp_res_`i' winner ln_pop_90 ln_emp_90 ln_avg_wages_90 i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105 {
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b3  =  round(100*r(estimate))/100 if _n == `row'
	qui replace se3 =  round(100*r(se))/100 if _n == `row'
}

* Capture the values, all emp, residual
qui gen b4  = .
qui gen se4 = .

qui gen eventtime4 = _n-6

forv i=95/105 {
	qui reg emp_res_`i' winner $X_10pre i.deal_year
	estimates store R`i'
}

qui suest R95 R96 R97 R98 R99 R100 R101 R102 R103 R104 R105 , vce(cluster fips)

disp "Simple event study"
forv i=95/105{
	local row = `i' - 94

	qui lincom _b[R`i'_mean:winner] -_b[R99_mean:winner]

	qui replace b4  =  round(100*r(estimate))/100 if _n == `row'
	qui replace se4 =  round(100*r(se))/100 if _n == `row'
}

preserve

keep in 1/11 // Make plot

rename (eventtime1 eventtime2 eventtime3 ) (fig_t1 fig_t2 fig_t3) 
qui replace fig_t2 = fig_t2 - .13 if fig_t2!=-1

qui replace fig_t3 = fig_t3 + .13 if fig_t3!=-1

ES_graph3, ci(1.96) xti("Years since deal") yti(Employment) ///
	lab1(3-D) lab2(2-Digit Residual) lab3(1-Digit Residual) ///
	outname(appxfig4b) row(1)

restore

capture drop  b1 b2 b3 b4 se1 se2 se3 se4  eventtime*

/*******************************************************************************
	APPX FIGURE 5: SCATTERPLOTS: EFFECTS OF CHANGES IN INCENTIVE SPENDING ON 
					(A) STATE GDP PER CAPITA
					(B) TOTAL STATE TAX REVENUE
					(C) DIRECT STATE GOVERNMENT SPENDING PER CAPITA
					(D) TOTAL STATE GOVERNMENT SPENDING PER CAPITA
*******************************************************************************/
	
	/***************************************************************************
		1) Load in and prep data, saving as temp file the data we need for all 
			four graphs
	***************************************************************************/
	
use "$processeddir/exhibit_collapses/state_year_spending_incentives_external.dta", clear

tsset fips year

drop if inlist(stateabbrev, "AK", "ND")

* Convert independent var to per capita measures
qui gen incentives_pop = (total_credits+ total_budget)/pop

* Convert outcome variables var to per capita measures
qui gen gdp_capita = (GDP*1e6)/pop
qui gen tax_capita = grev_own_tax*1000/pop
qui gen govexp_capita = tot_exp*1000/pop
qui gen govexp_direct_capita = genexp_direct*1000/pop

tempfile data_in_common
save `data_in_common' // save data that's useful for all graphs A-D

	/***************************************************************************
		2) Cycle through y-variables and make graphs
	***************************************************************************/

foreach yvar in gdp_capita tax_capita govexp_capita govexp_direct_capita {
	
	use `data_in_common', clear

	keep if inlist(year, 2007, 2014)

	qui gen Dincentive = incentives_pop - L7.incentives_pop
	qui gen D`yvar' = `yvar' - L7.`yvar'

	keep if year == 2014

	local xvar = "Dincentive"
	
	* Choose y-axis title and figure name based on which y variable we're using
	if regexm("`yvar'", "gdp") {
		local ytitle = "Chg. in GDP Per Capita (2014-07)"
		local subfig = "a"
	}
	else if regexm("`yvar'", "tax") {
		local ytitle = "Chg in Total Tax Rev Per Capita (2014-07)"
		local subfig = "b"
	}
	else if regexm("`yvar'", "govexp_direct") {
		local ytitle = "Chg in Dir Gov Spending Per Capita (2014-07)"
		local subfig = "c"
	}
	else {
		local ytitle = "Chg in Total Gov Spending Per Capita (2014-07)"
		local subfig = "d"
	}

	* Compute regression to get best fit line
	qui reg D`yvar' Dincentive [aw=pop] if year==2014
	matrix define M = e(b)
	local b = substr(string(round(M[1,1],.01)),1,4)
	local se = substr(string(round(_se[Dincentive],.01)),1,4)

	qui sum D`yvar' if year == 2014 [aw=pop], detail
	local mean_D`yvar' = r(mean)
	display `mean_D`yvar''
	
	qui sum Dincentive if year==2014 [aw=pop], detail
	local mean_Dincentive = r(mean)

		/***********************************************************************
			Make scatterplot!
		***********************************************************************/

	twoway (scatter D`yvar' Dincentive [aw=pop] if year==2014, msymbol(circle_hollow) ///
		mcolor(navy)) ///
	(scatter D`yvar' Dincentive [aw=pop] if year==2014, msymbol(none) ///
		mlabposition(0) mlabcolor(navy) mlabel(stateabbrev) mlabsize(vsmall)) ///
	(lfit D`yvar' Dincentive [aw=pop] if year==2014, lcolor(cranberry)), ///
	ytitle("`ytitle'", size(medium)) legend(off) ///
	xtitle("Chg in Incentive Spend Per Capita (2014-07)", size(medium)) ///
	yline(`mean_D`yvar'', lcolor(gs6) lwidth(thin) lpattern(shortdash)) ///
	xline(`mean_Dincentive', lcolor(gs6) lwidth(thin) lpattern(shortdash)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white)) ///
	note("Slope= `b' (`se')", position(4) ring(0) size(medsmall))

	* Save figure
	graph export "$graphdir/appxfig5`subfig'.pdf", replace
}