/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	01/03/2020
Modified by:	Dustin Swonder
Description:	This file replicates the appendix tables in Slattery and Zidar's 
				"Evaluating State and Local Business Tax Incentives."
*******************************************************************************/

gl tabdir "$outdir/tables/appendix"

/*******************************************************************************
	APPENDIX TABLE 1:
		SUMMARY STATISTICS: SIZE DISTRIBUTION OF FIRMS RECEIVING DISCRETIONARY 
		SUBSIDIES
*******************************************************************************/

	/***************************************************************************
		LOAD IN AND PREP DATA
	***************************************************************************/
	
		/***********************************************************************
			First, retrieve and process national-level data on business entry by
				size, industry classification, and year, and get total counts of 
				establishment entry from 2002-2016
		***********************************************************************/

* Load in national-level data from Census Business Dynamics Statistics (BDS)
insheet using "$rawdir/bds_e_szsic_release.csv", comma clear

keep if year >= 2002

rename size size_old

gen size = cond(regexm(size_old, "a") | regexm(size_old, "b") /* 
				*/ | regexm(size_old, "c") | regexm(size_old, "d") /*
				*/ | regexm(size_old, "e"), "1_99", /* Size is 1_99 if size_old is a-e
			*/ cond(regexm(size_old, "f"), "100_249", /* Size is 100_249 if size_old is f
			*/ cond(regexm(size_old, "g"), "250_499", /* etc.
			*/ cond(regexm(size_old, "h"), "500_999", "1000"))))

collapse (sum) estabs_entry, by(size)
rename estabs_entry estabs

tempfile entry_size
sa `entry_size', replace

		/***********************************************************************
			Second, load in and process data on subsidy-induced estab. entries 
				(estab.-level) (need access to internal data in order to run 
				commented section here)
		***********************************************************************/

/* Firm-level dataset of subsidies is already 2002-2016, so no need to drop 
	any observations to make compatible with BDS dataset */
/* import excel $internaldir/data/raw/subsidy_deal_raw_JEP.xlsx, clear firstrow

keep firm year state county sub_M jobs_direct jobs_retain invest_M threat_clean ///
	threat_county naics4

rename (sub_M threat_clean jobs_direct jobs_retain) (subsidy threat_state new_jobs retain_jobs)

adjust_inflation subsidy invest_M, year(2017)

ds, has(type string) // trim all the string variables
foreach variable in `r(varlist)' {
	replace `variable' = ltrim(rtrim(`variable'))
}

destring retain_jobs invest_M, replace
gen jobs = cond(!missing(retain_jobs), new_jobs + retain_jobs, new_jobs)

keep year jobs
gen n = 1

* Create size bins to compare with BDS
gen size = cond(missing(jobs), "", /*
			*/ cond(jobs < 100, "1_99", /*
			*/ cond(jobs < 250, "100_249", /*
			*/ cond(jobs < 500, "250_499", /*
			*/ cond(jobs < 1000, "500_999", "1000")))))
			
* Get counts of incentive-induced estab. entries by size bin
collapse (sum) n, by(size)

save $processeddir/exhibit_collapses/deals_coverage.dta, replace */

use $processeddir/exhibit_collapses/deals_coverage.dta, clear

* Merge BDS data onto incentive count dataset by size class
merge 1:1 size using `entry_size', nogen

* Compute share of establishments in size class receiving subsidies
gen sh = round((n/estabs)*100, .01)
format sh %5.2f

gen order = cond(size == "", 6, /*
				*/ cond(size == "1_99", 1, /*
				*/ cond(size == "100_249", 2, /*
				*/ cond(size == "250_499", 3, /*
				*/ cond(size == "500_999", 4, 5)))))

tempfile jobtotal
save `jobtotal'

	/***********************************************************************
		Clean up a bit
	***********************************************************************/

sort order
replace size = subinstr(size, "_", " - ", .)
replace size = "1000+" if size == "1000"

format n estabs %12.0fc

	/***********************************************************************
		Make table
	***********************************************************************/

gen tab = "\begin{tabular}{l|rrr}" in 1

gen header =  "Employment & \# of Firm-Specific Incentives & Total Establishment Entry & \% Coverage  " in 1
gen hline = "\hline" in 1
gen end = "\end{tabular}"

local filename = "appxtable1"

listtex tab if _n == 1 using "$tabdir/`filename'.tex", replace rstyle(none)
listtex hline if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
	
listtex header if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)	
listtex hline if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex size n estabs sh if size != "", appendto("$tabdir/`filename'.tex") rstyle(tabular) 
listtex hline if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex end if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	


/*******************************************************************************
	APPENDIX TABLE 2: 
		SUMMARY STATISTICS: EMPLOYMENT AND FINANCIAL CHARACTERISTICS OF  
			SUBSIDIZED FIRMS
*******************************************************************************/

use $processeddir/exhibit_collapses/compustatmatcheddeals.dta, clear

label var emp "Employees (1000s)"
label var ppent "Capital Stock (\textdollar M)"
label var revt "Revenue (\textdollar M)"
label var gp "Gross Profit (\textdollar M)"
label var txs "State Income Taxes (\textdollar M)"
label var txt "Total Income Taxes (\textdollar M)"
label var mkval "Market Value (\textdollar M)"

	/***************************************************************************
		MAKE TABLE
	***************************************************************************/

*STATS OF FULL COMPUSTAT SAMPLE
eststo full: estpost tabstat emp ppent revt gp mkval txs txt, stats(mean p50) col(stats) 
*STATS OF SUBSIDIZED FIRMS, IN YEAR OF SUBSIDY
eststo subyear: estpost tabstat emp ppent revt gp mkval txs txt if one==1, stats(mean p50) col(stats)
*STATS OF SUBSIDIZED FIRMS, ALL YEARS
eststo suball: estpost tabstat emp ppent revt gp mkval txs txt if max==1, stats(mean p50) col(stats)

esttab full suball subyear using "$tabdir/appxtable2.tex", replace ///
			cells("mean(fmt(%9.1fc)) p50(fmt(%9.1fc))") ///
			collabels("Mean" "Median") nonote nonumbers label ///
			mtitle("All Compustat" "Subsidized Firms" ///
			"\shortstack{Subsidized Firms:\\Year of Deal}") booktabs ///
			stats(N , fmt(%9.0fc) labels("Observations"))

/*******************************************************************************
	APPENDIX TABLE 3: 
		SUMMARY STATISTICS: AVERAGE DEAL AND TOP 10 INDUSTRIES RECEIVING 
		SUBSIDIES
*******************************************************************************/
	/***************************************************************************
		LOAD IN AND PREP DATA (Need access to internal data in order to run 
			commented section here)
	***************************************************************************/

/* Get industry names (labels)
import delimited using "$rawdir/naics4d_labels.csv", clear
rename naics4d naics4
tempfile indnames
save `indnames'

import excel using $internaldir/data/raw/subsidy_deal_raw_JEP.xlsx, clear firstrow

keep firm year state county sub_M jobs_direct jobs_retain invest_M threat_clean ///
	threat_county naics4

rename (sub_M threat_clean jobs_direct jobs_retain) (subsidy threat_state new_jobs retain_jobs)

adjust_inflation subsidy invest_M, year(2017)

ds, has(type string) // trim all the string variables
foreach variable in `r(varlist)' {
	replace `variable' = ltrim(rtrim(`variable'))
}

destring retain_jobs invest_M, replace
gen jobs = cond(!missing(retain_jobs), new_jobs + retain_jobs, new_jobs)

* Merge with industry names
merge m:1 naics4 using `indnames', assert(2 3) keep(3) nogen

gen n = 1
gen cost_per_job = (subsidy * 10^6) / jobs // subsidy is in $M, cost per job is $

tempfile main
save `main'

* Compute average and median of variables for full sample
use `main', clear
collapse (mean) subsidy jobs invest_M ///
	(sum) n total_sub = subsidy ///
	total_jobs = jobs ///
	(p50) subsidy_p50 = subsidy jobs_p50 = jobs ///
	invest_M_p50 = invest_M

gen cost_per_job = (total_sub * 1E6) / total_jobs
gen cost_per_job_p50 = (subsidy_p50 * 1e6) / jobs_p50

g longname = "Full sample" 
tempfile mean
save `mean'

* Compute average and median of variables for establishments in analysis sample
use $internaldir/data/processed/deal_specific_analysis.dta, clear
drop emp_74-avg_wages_res_89 emp_106-avg_wages_res_115	

keep if sample == 1

keep if winner == 1

gen n = 1

tempfile analysis
save `analysis'

collapse (sum) n (mean) subsidy jobs invest_M ///
	(sum) total_sub = subsidy total_jobs = jobs ///
	(p50) subsidy_p50 = subsidy invest_M_p50 = invest_M jobs_p50 = jobs

gen cost_per_job = (total_sub * 1E6) / total_jobs
gen cost_per_job_p50 = (subsidy_p50 * 1e6) / jobs_p50

gen longname = "Analysis sample" 

tempfile analysis_fortab
save `analysis_fortab'

/* Compute average and median of variables for establishments in analysis sample 
	and manufacturing */
use `analysis', clear
keep if inrange(naics4d, 3000, 3999)

collapse (mean) subsidy jobs /* cost_per_job */ invest_M ///
		(sum) n total_sub = subsidy total_jobs = jobs ///
		(p50) subsidy_p50 = subsidy invest_M_p50 = invest_M jobs_p50 = jobs

gen cost_per_job = (total_sub * 1E6) / total_jobs
gen cost_per_job_p50 = (subsidy_p50 * 1e6) / jobs_p50

gen longname = "Manufacturing analysis sample" 

tempfile analysis_mfg
save `analysis_mfg'

* Compute average and median of variables by industry
use `main', clear
collapse (sum) n total_sub = subsidy total_jobs = jobs ///
		(mean) subsidy jobs invest_M ///
		(p50) invest_M_p50 = invest_M subsidy_p50 = subsidy jobs_p50 = jobs, ///
			by(naics4 longname)

gen cost_per_job = (total_sub * 1E6) / total_jobs
gen cost_per_job_p50 = (subsidy_p50 * 1e6) / jobs_p50
		
gsort -n longname

replace longname = subinstr(longname, "mfg.", "manuf.", .)
replace longname = subinstr(longname, "product/parts ", "", .)
replace longname = subinstr(longname, "Motor vehicle", "Automobile", .)
replace longname = "Information Technology" if longname=="Computer sys design/related svc"
replace longname = subinstr(longname, "research/development", "R\&D", .)
replace longname = subinstr(longname, "compnt manuf.", "manuf.", .)
replace longname = subinstr(longname, "products manuf.", "manuf.", .)
replace longname = "Financial activities" if longname=="Other financial investment actvty"
replace longname = longname + " (" + string(naics4) + ")"

* keep top 11 (wanted to keep oil & gas extraction)
keep if _n <= 11

qui summ total_sub, detail // get total subsidy amount for top 10 industries
local top_11_sub = `r(sum)'
drop total_sub

* append total and average
append using `mean'
append using `analysis_fortab'
append using `analysis_mfg'

* Compute top 11 industries total sub. as proportion of all subsidies in deals 
gen top_ind_prop_dollars = `top_11_sub' / total_sub
list top_ind_prop_dollars if !missing(total_sub)
drop total_sub top_ind_prop_dollars

save $processeddir/exhibit_collapses/topind_full.dta, replace */

use $processeddir/exhibit_collapses/topind_full.dta, clear

* Reformat variables
format *jobs* cost_*_job* %12.0fc
format subsidy* invest* %12.1fc

	/***************************************************************************
		MAKE TABLE
	***************************************************************************/

g tab = "\begin{tabular}{l|rr|rr|rr|rr|c}" in 1
g top = "\toprule" in 1
*Midrule
g mid = " \midrule" in 1 
g hline = " \hline" in 1 
*Bottomrule
g bot = "\bottomrule" in 1
*End
g end = "\end{tabular}" in 1
*Panel
#delimit ;
g title1 = " & \multicolumn{2}{c|}{Subsidy (\\$ M)} & \multicolumn{2}{c|}{\# Jobs Promised} 
			& \multicolumn{2}{c|}{Cost per Job (\\$)} & \multicolumn{2}{c|}{Investment(\\$ M)} 
			& \multicolumn{1}{c}{\# of} \\ " in 1;
g title2 = "Industry (NAICS) & Mean	& Median &	Mean &	Median & Mean &	Median & Mean & Median & Deals \\" in 1;
#delimit cr

g c = " "

*Output
local filename = "appxtable3"

listtex tab if _n == 1 using "$tabdir/`filename'.tex", replace rstyle(none)

listtex c c c c c c c c c c if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)		
listtex title1 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex title2 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex c c c c c c c c c c if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)	
listtex hline if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex c c c c c c c c c c if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)	
listtex longname subsidy subsidy_p50 jobs jobs_p50 cost_per_job cost_per_job_p50 invest_M invest_M_p50 n if /*
	*/ inlist(longname, "Full sample", "Analysis sample", "Manufacturing analysis sample"), /*
	*/ appendto("$tabdir/`filename'.tex") rstyle(tabular) 
listtex c c c c c c c c c c if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)	
listtex hline if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex c c c c c c c c c c if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)		
listtex longname subsidy subsidy_p50 jobs jobs_p50 cost_per_job cost_per_job_p50 invest_M invest_M_p50 n if /*
	*/ !inlist(longname, "Full sample", "Analysis sample", "Manufacturing analysis sample", "Foreign parent"),  /*
	*/	appendto("$tabdir/`filename'.tex") rstyle(tabular) 
listtex bot if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	

listtex end if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none) 

/*******************************************************************************
	APPENDIX TABLE 4:
		SUMMARY STATISTICS: COUNTY CHARACTERISTICS FOR COUNTIES THAT PROVIDE 
			SUBSIDIES (WINNERS AND RUNNERS-UP) NOT POP-WEIGHTED
*******************************************************************************/			

	/***************************************************************************
		LOAD IN AND PREP DATA ON DEALS AND CORRESPONDING LOCATIONS
	***************************************************************************/

/* Load deal-specific analysis data; for every year other than 2000, variables 
	are coded in time relative to event, with event == 100, ten years 
	prior == 90, etc. */
use "$processeddir/deal_specific_analysis.dta", clear

* Drop industry variables we are not using
drop *ind1* *ind2* *ind6* *ind7* *ind8* 

* Compute wagebill in 2000
gen wagebill_2000 = avg_wages_2000*emp_2000	

* Keep only the 2000 and change variables
keep id runnerup_id winner hasthreat sample fipscounty countyname stateabbrev *_2000 D_*

* Rescale 
foreach var in pop personal_inc personal_inc_pc emp avg_wages {
	replace `var'_2000 = `var'_2000 / 10^3 // to thousands, except personal inc is $M
}

replace wagebill_2000 = wagebill_2000 / 10^6 // to millions

* Format
format emp_2000 pop_2000 %12.0fc
format wagebill_2000 avg_wages_2000 personal_inc_2000 personal_inc_pc_2000 ///
		pop_density_2000 ln_hou_units_2000  %12.1fc
format sh_emp_ind3_2000 sh_emp_ind5_2000 unemp_2000 pop_density_2000 white_2000 ///
		hispanic_2000 urban_2000 ba_over25_2000 foreign_2000 %12.1fc

/* Identify unique winner counties in the full sample, unique winner counties 
	in the analysis sample, and unique runnerups */
egen tag_winner_full = tag(fipscounty) if winner == 1
egen tag_winner_analysis = tag(fipscounty) if winner == 1 & sample == 1
egen tag_runnerup_analysis = tag(fipscounty) if runnerup == 1 & sample == 1

		/***********************************************************************
			COMPUTE STATISTICS ON COUNTIES IN COMPETITION FOR DEALS
		***********************************************************************/

eststo clear

* Cycle through sub-samples to get summary statistics
foreach designation in winner_full winner_analysis runnerup { 
	di "`designation'"
	
	* For draft	
	eststo `designation': estpost tabstat emp_2000 pop_2000 wagebill_2000 avg_wages_2000  ///
			personal_inc_2000 personal_inc_pc_2000 pop_density_2000 unemp_2000 ///
			sh_emp_ind3_2000 sh_emp_ind5_2000 urban_2000 ba_over25_2000 white_2000 ///
			hispanic_2000  foreign_2000 ln_hou_units_2000 ///
		if tag_`designation' == 1, ///
			statistics(mean sd p50) columns(statistics)

	* For slides
	eststo `designation'_slides: estpost tabstat emp_2000 pop_2000 avg_wages_2000 ///
			pop_density_2000 sh_emp_ind3_2000 sh_emp_ind5_2000 urban_2000 ///
			ba_over25_2000 white_2000 hispanic_2000 foreign_2000 ln_hou_units_2000 ///
			wagebill_2000 personal_inc_2000 personal_inc_pc_2000 ///
			unemp_2000 ///
		if tag_`designation' == 1, ///
			statistics(mean sd p50) columns(statistics)
}

		/***********************************************************************
			LOAD IN DATA ON ALL U.S. COUNTIES FOR COMPARISON WITH "COMPETITION
				COUNTIES"
		***********************************************************************/

use "$processeddir/firm_location_analysis.dta", clear

* drop industries we are not using
drop *ind1* *ind2* *ind6* *ind7* *ind8* 

g wagebill_2000 = avg_wages_2000*emp_2000

* Rescale
foreach var in emp avg_wages personal_inc_pc pop personal_inc {
	replace `var'_2000 = `var'_2000 / 10^3 // to thousands, except personal inc is $M
}

replace wagebill_2000 = wagebill_2000/10^6 // to millions

* Format
format emp_2000 pop_2000 %12.0fc
format wagebill_2000 avg_wages_2000 personal_inc_2000 personal_inc_pc_2000 ///
		pop_density_2000 ln_hou_units_2000  %12.1fc
format sh_emp_ind3_2000 sh_emp_ind5_2000 unemp_2000 pop_density_2000 white_2000 ///
		hispanic_2000 urban_2000 ba_over25_2000 foreign_2000 %12.1fc

		/***********************************************************************
			COMPUTE SUMMARY STATISTICS ON ALL US COUNTIES FOR COMPARISON WITH
				"COMPETITION COUNTIES"
		***********************************************************************/

foreach subsample in avg /* full sample of US counties */ avg_cities /* "cities" */ {
	tempvar samp
	if "`subsample'" == "avg" {
		gen `samp' = 1
	}
	else {
		gen `samp' = pop_2000 > 100 & !missing(pop_2000) // Pop in excess of 100k = city 
	}
	
	* For draft
	eststo us_`subsample': estpost tabstat emp_2000 pop_2000 wagebill_2000 avg_wages_2000 ///
		personal_inc_2000 personal_inc_pc_2000 pop_density_2000 unemp_2000 ///
		sh_emp_ind3_2000 sh_emp_ind5_2000 urban_2000 ba_over25_2000 white_2000 ///
		hispanic_2000 foreign_2000 ln_hou_units_2000 ///
		if `samp' == 1, statistics(mean sd p50) columns(statistics)

	* For slides				
	eststo us_`subsample'_slides: estpost tabstat emp_2000 pop_2000 ///
		avg_wages_2000 pop_density_2000 sh_emp_ind3_2000 sh_emp_ind5_2000 ///
		urban_2000 ba_over25_2000 white_2000 hispanic_2000  foreign_2000 ///
		ln_hou_units_2000 wagebill_2000 personal_inc_2000 ///
		personal_inc_pc_2000 unemp_2000 if `samp' == 1, ///
		statistics(mean p50) columns(statistics)
}

		/***********************************************************************
			MAKE TABLES
		***********************************************************************/
		
			/*******************************************************************
				For draft
			*******************************************************************/
				
estout winner_full winner_analysis runnerup us_avg us_avg_cities ///
	using "$tabdir/appxtable4.tex",  replace style(tex) ///
		cells("mean(fmt(%9.1fc)) p50(fmt(%9.1fc))" "sd(fmt(%9.2fc) par)") ///
	stats(N , fmt(%9.0fc) labels("Observations"))  ///
	collabels("Mean" "Median") ///
	mlabels("Winner (Full)" "Winner (Analysis)" "Runner-up" "Average" "Pop $ >$ 100K ", ///
			span lhs("County:") ///
		prefix(\multicolumn{2}{c}{)suffix(}) ///
		end(\cline{2-11}))  ///
	prehead(\begin{tabular}{r*{@M}{c}*{@M}{c}} \toprule )  ///
	posthead(\midrule) ///
	prefoot(\midrule) postfoot(\bottomrule \end{tabular}) label ///
	varlabels(pop_2000 "Population (1000s)" emp_2000 "Employment (1000s)" ///
		wagebill_2000 "Wage bill (M)" avg_wages_2000 "Average wages (1000s)" ///
		unemp_2000 "Unemployment rate (\%)" pop_density_2000 "Population density" ///
		white_2000 "\% white" hispanic_2000 "\% Hispanic" urban_2000 "\% urban" ///
		ba_over25_2000 "\% Bachelor's or more" foreign_2000 "\% foreign-born" ///
		ln_hou_units_2000 "log housing units" sh_emp_ind3_2000 "\% emp in mfg." ///
		sh_emp_ind4_2000 "\% emp in trade" sh_emp_ind5_2000 "\% emp info \& prof svcs." ///
		personal_inc_2000 "Personal income (M)" ///
		personal_inc_pc_2000 "Personal income per capita (1000s)")	

			/*******************************************************************
				For slides
			*******************************************************************/
			
estout winner_full_slides winner_analysis_slides runnerup_slides us_avg ///
	us_avg_cities_slides ///
	using "$tabdir/appxtable4_slidesversion.tex", replace style(tex) ///
		cells("mean(fmt(%9.1fc)) p50(fmt(%9.1fc))") ///
	stats(N , fmt(%9.0fc) labels("Observations")) collabels("Mean" "Median") ///
	mlabels("Winner (Full)" "Winner (Analysis)" "Runner-up" "Average" "Pop $ >$ 100K ", ///
		span lhs("County:") prefix(\multicolumn{2}{c}{)suffix(}) end(\cline{2-11})) ///
	prehead(\begin{tabular}{r*{@M}{c}*{@M}{c}} \toprule ) posthead(\midrule) ///
	prefoot(\midrule) postfoot(\bottomrule \end{tabular}) label ///
	varlabels(pop_2000 "Population (K)" emp_2000 "Employment (K)" ///
		wagebill_2000 "Wage bill (M)" avg_wages_2000 "Average wages (K)" ///
		unemp_2000 "Unemployment rate (\%)" pop_density_2000 "Population density" ///
		white_2000 "\% white" hispanic_2000 "\% Hispanic" urban_2000 "\% urban" ///
		ba_over25_2000 "\% Bachelor's or more" foreign_2000 "\% foreign-born" ///
		ln_hou_units_2000 "log housing units" ///
		sh_emp_ind3_2000 "\% emp in mfg." sh_emp_ind4_2000 "\% emp in trade" ///
		sh_emp_ind5_2000 "\% emp info \& prof svcs." personal_inc_2000 "Personal income (M)" ///
		personal_inc_pc_2000 "Personal inc/capita (K)")

/*******************************************************************************
	APPENDIX TABLE 5:
		SUMMARY STATISTICS: COUNTY CHARACTERISTICS FOR COUNTIES THAT PROVIDE 
			SUBSIDIES (WINNERS AND RUNNERS-UP) POP-WEIGHTED
*******************************************************************************/			

	/***************************************************************************
		LOAD IN AND PREP DATA ON DEALS AND CORRESPONDING LOCATIONS
	***************************************************************************/

/* Load deal-specific analysis data; for every year other than 2000, variables 
	are coded in time relative to event, with event == 100, ten years 
	prior == 90, etc. */
use "$processeddir/deal_specific_analysis.dta", clear

* Drop industry variables we are not using
drop *ind1* *ind2* *ind6* *ind7* *ind8* 

* Compute wagebill in 2000
gen wagebill_2000 = avg_wages_2000*emp_2000	

* Keep only the 2000 and change variables
keep id runnerup_id winner hasthreat sample fipscounty countyname stateabbrev *_2000 D_* deal_year

* Rescale 
foreach var in pop personal_inc personal_inc_pc emp avg_wages {
	replace `var'_2000 = `var'_2000 / 10^3 // to thousands, except personal inc is $M
}

replace wagebill_2000 = wagebill_2000 / 10^6 // to millions

* Format
format emp_2000 pop_2000 %12.0fc
format wagebill_2000 avg_wages_2000 personal_inc_2000 personal_inc_pc_2000 ///
		pop_density_2000 ln_hou_units_2000  %12.1fc
format sh_emp_ind3_2000 sh_emp_ind5_2000 unemp_2000 pop_density_2000 white_2000 ///
		hispanic_2000 urban_2000 ba_over25_2000 foreign_2000 %12.1fc

/* Identify unique winner counties in the full sample, unique winner counties 
	in the analysis sample, and unique runnerups */
egen tag_winner_full = tag(fipscounty) if winner == 1
egen tag_winner_analysis = tag(fipscounty) if winner == 1 & sample == 1
egen tag_runnerup_analysis = tag(fipscounty) if runnerup == 1 & sample == 1

		/***********************************************************************
			COMPUTE STATISTICS ON COUNTIES IN COMPETITION FOR DEALS
		***********************************************************************/

eststo clear

* Cycle through sub-samples to get summary statistics
foreach designation in winner_full winner_analysis runnerup { 
	di "`designation'"
	
	* For draft	
	eststo `designation': estpost tabstat emp_2000 pop_2000 wagebill_2000 avg_wages_2000  ///
			personal_inc_2000 personal_inc_pc_2000 pop_density_2000 unemp_2000 ///
			sh_emp_ind3_2000 sh_emp_ind5_2000 urban_2000 ba_over25_2000 white_2000 ///
			hispanic_2000  foreign_2000 ln_hou_units_2000 ///
		if tag_`designation' == 1 [aw = pop_2000], ///
			statistics(mean sd p50) columns(statistics)

	* For slides
	eststo `designation'_slides: estpost tabstat emp_2000 pop_2000 avg_wages_2000 ///
			pop_density_2000 sh_emp_ind3_2000 sh_emp_ind5_2000 urban_2000 ///
			ba_over25_2000 white_2000 hispanic_2000 foreign_2000 ln_hou_units_2000 ///
			wagebill_2000 personal_inc_2000 personal_inc_pc_2000 ///
			unemp_2000 ///
		if tag_`designation' == 1 [aw = pop_2000], ///
			statistics(mean sd p50) columns(statistics)
}

		/***********************************************************************
			LOAD IN DATA ON ALL U.S. COUNTIES FOR COMPARISON WITH "COMPETITION
				COUNTIES"
		***********************************************************************/

use "$processeddir/firm_location_analysis.dta", clear

* drop industries we are not using
drop *ind1* *ind2* *ind6* *ind7* *ind8* 

g wagebill_2000 = avg_wages_2000*emp_2000

* Rescale
foreach var in emp avg_wages personal_inc_pc pop personal_inc {
	replace `var'_2000 = `var'_2000 / 10^3 // to thousands, except personal inc is $M
}

replace wagebill_2000 = wagebill_2000/10^6 // to millions

* Format
format emp_2000 pop_2000 %12.0fc
format wagebill_2000 avg_wages_2000 personal_inc_2000 personal_inc_pc_2000 ///
		pop_density_2000 ln_hou_units_2000  %12.1fc
format sh_emp_ind3_2000 sh_emp_ind5_2000 unemp_2000 pop_density_2000 white_2000 ///
		hispanic_2000 urban_2000 ba_over25_2000 foreign_2000 %12.1fc

		/***********************************************************************
			COMPUTE SUMMARY STATISTICS ON ALL US COUNTIES FOR COMPARISON WITH
				"COMPETITION COUNTIES"
		***********************************************************************/

foreach subsample in avg /* full sample of US counties */ avg_cities /* "cities" */ {
	tempvar samp
	if "`subsample'" == "avg" {
		gen `samp' = 1
	}
	else {
		gen `samp' = pop_2000 > 100 & !missing(pop_2000) // Pop in excess of 100k = city 
	}
	
	* For draft
	eststo us_`subsample': estpost tabstat emp_2000 pop_2000 wagebill_2000 avg_wages_2000 ///
		personal_inc_2000 personal_inc_pc_2000 pop_density_2000 unemp_2000 ///
		sh_emp_ind3_2000 sh_emp_ind5_2000 urban_2000 ba_over25_2000 white_2000 ///
		hispanic_2000 foreign_2000 ln_hou_units_2000  ///
		if `samp' == 1 [aw = pop_2000], statistics(mean sd p50) columns(statistics)

	* For slides				
	eststo us_`subsample'_slides: estpost tabstat emp_2000 pop_2000 ///
		avg_wages_2000 pop_density_2000 sh_emp_ind3_2000 sh_emp_ind5_2000 ///
		urban_2000 ba_over25_2000 white_2000 hispanic_2000  foreign_2000 ///
		ln_hou_units_2000  wagebill_2000 personal_inc_2000 ///
		personal_inc_pc_2000 unemp_2000 if `samp' == 1 [aw = pop_2000], ///
		statistics(mean p50) columns(statistics)
}
		/***********************************************************************
			MAKE TABLES
		***********************************************************************/
		
			/*******************************************************************
				For draft
			*******************************************************************/
				
estout winner_full winner_analysis runnerup us_avg us_avg_cities ///
	using "$tabdir/appxtable5.tex",  replace style(tex) ///
		cells("mean(fmt(%9.1fc)) p50(fmt(%9.1fc))" "sd(fmt(%9.2fc) par)") ///
	stats(N , fmt(%9.0fc) labels("Observations"))  ///
	collabels("Mean" "Median") ///
	mlabels("Winner (Full)" "Winner (Analysis)" "Runner-up" "Average" "Pop $ >$ 100K ", ///
			span lhs("County:") ///
		prefix(\multicolumn{2}{c}{)suffix(}) ///
		end(\cline{2-11}))  ///
	prehead(\begin{tabular}{r*{@M}{c}*{@M}{c}} \toprule )  ///
	posthead(\midrule) ///
	prefoot(\midrule) postfoot(\bottomrule \end{tabular}) label ///
	varlabels(pop_2000 "Population (1000s)" emp_2000 "Employment (1000s)" ///
		wagebill_2000 "Wage bill (M)" avg_wages_2000 "Average wages (1000s)" ///
		unemp_2000 "Unemployment rate (\%)" pop_density_2000 "Population density" white_2000 "\% white" ///
		hispanic_2000 "\% Hispanic" urban_2000 "\% urban" ba_over25_2000 "\% Bachelor's or more" foreign_2000 "\% foreign-born" ///
		ln_hou_units_2000 "log housing units" ///
		sh_emp_ind3_2000 "\% emp in mfg." sh_emp_ind4_2000 "\% emp in trade" sh_emp_ind5_2000 "\% emp info \& prof svcs." ///
		personal_inc_2000 "Personal income (M)" personal_inc_pc_2000 "Personal income per capita (1000s)")	

			/*******************************************************************
				For slides
			*******************************************************************/
			
estout winner_full_slides winner_analysis_slides runnerup_slides us_avg ///
	us_avg_cities_slides ///
	using "$tabdir/appxtable5_slidesversion.tex", replace style(tex) ///
		cells("mean(fmt(%9.1fc)) p50(fmt(%9.1fc))") ///
	stats(N , fmt(%9.0fc) labels("Observations")) collabels("Mean" "Median") ///
	mlabels("Winner (Full)" "Winner (Analysis)" "Runner-up" "Average" "Pop $ >$ 100K ", ///
		span lhs("County:") prefix(\multicolumn{2}{c}{)suffix(}) end(\cline{2-11})) ///
	prehead(\begin{tabular}{r*{@M}{c}*{@M}{c}} \toprule ) posthead(\midrule) ///
	prefoot(\midrule) postfoot(\bottomrule \end{tabular}) label ///
	varlabels(pop_2000 "Population (K)" emp_2000 "Employment (K)" ///
		wagebill_2000 "Wage bill (M)" avg_wages_2000 "Average wages (K)" ///
		unemp_2000 "Unemployment rate (\%)" pop_density_2000 "Population density" ///
		white_2000 "\% white" hispanic_2000 "\% Hispanic" urban_2000 "\% urban" ///
		ba_over25_2000 "\% Bachelor's or more" foreign_2000 "\% foreign-born" ///
		ln_hou_units_2000 "log housing units" ///
		sh_emp_ind3_2000 "\% emp in mfg." sh_emp_ind4_2000 "\% emp in trade" ///
		sh_emp_ind5_2000 "\% emp info \& prof svcs." personal_inc_2000 "Personal income (M)" ///
		personal_inc_pc_2000 "Personal inc/capita (K)")