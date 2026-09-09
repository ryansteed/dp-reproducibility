/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	01/06/2020
Modified by:	Dustin Swonder
Description:	This file replicates the tables in Slattery and Zidar's 
				"Evaluating State and Local Business Tax Incentives."
*******************************************************************************/

global tabdir "$outdir/tables"

/*******************************************************************************
	TABLE 1: SUMMARY STATISTICS ACROSS STATES FOR VARIOUS POLICY INSTRUMENTS

		Need access to internal data to run commented-out section here
*******************************************************************************/

/* use $internaldir/data/processed/firm_level_subsidy_runnerup.dta, clear

* collapse at the state level
g n = 1
keep if winner == 1

g subsidy_tot = subsidy

collapse (sum) n subsidy_tot jobs (mean) subsidy, by(stateabbrev)

g cost_per_job = subsidy * 10^6 / jobs

save $processeddir/exhibit_collapses/firm_subs_statelevel.dta, replace */

use $processeddir/exhibit_collapses/firm_subs_statelevel.dta, clear

tempfile firmsubs
save `firmsubs'

* insheet other datasets
* state tax rates
use $rawdir/taxrates_stateyear_1950_2017.dta, clear

keep year fips stateabbrev corprate

* merge gov spending
merge 1:1 stateabbrev year using $rawdir/govexp_styear.dta, keep(3) nogen
adjust_inflation *exp*, year(2017)

* merge rev
merge 1:1 stateabbrev year using $rawdir/govrev_styear.dta, keep(3) nogen ///
	keepusing(grev_own_incometax_corp grev_own_tax)
adjust_inflation grev*, year(2017)

rename grev_own_incometax_corp corptaxrev

* merge GDP
merge 1:1 fips year using $processeddir/bea_statevars.dta, keep(3) nogen ///
	keepusing(GDP)

* merge econ dev 
merge 1:1 stateabbrev year using $rawdir/state_year_chars.dta, nogen keep(1 3) ///
	keepusing(total_credits total_budget) 

* Adjust for inflation
adjust_inflation GDP, year(2017) 
lab var GDP "GDP, Million 2017 USD"
lab var total_credits "Total credit expend, 2017 USD"
lab var total_budget "Total econ dev budget, Million 2017 USD"

sort fips year

replace total_credits = 0 if missing(total_credits)
gen total_incentives = cond(missing(total_credits), total_budget, ///
	cond(missing(total_budget), total_credits, total_credits + total_budget))
lab var total_incentives "Tax credit expend + econ dev budget, 2017 USD"

keep if year == 2014

tempfile statechars
save `statechars'

* PREP TO MAKE TABLE
use `firmsubs', clear
merge 1:1 stateab using `statechars'

* PER CAPITA
foreach var of varlist corptaxrev *_credits *_budget grev_own_tax {
	qui gen `var'_pc = `var' / pop
}

qui replace corptaxrev_pc = corptaxrev_pc*10^3
qui gen incentive_corptax = round((total_incentives / (corptaxrev * 1000)) * 100)

order stateabbrev n subsidy cost_per_job total_credits_pc total_budget_pc ///
	corptaxrev_pc incentive_corptax corprate
sort fips

*Format
format subsidy cost_per_job %12.0fc
format *_credits_pc *_budget_pc grev_own_tax_pc corptaxrev_pc %12.0fc
format pop %12.0fc

keep stateabbrev - corprate

sort stateabbrev

* Make state-specific numbers
foreach stateabbrev in AL CA NV NY PA SC TN WV {
	qui count if stateabbrev <= "`stateabbrev'"
	local row = `r(N)'
	foreach var in corptaxrev_pc incentive_corptax corprate total_credits_pc total_budget_pc n cost_per_job {
		if "`stateabbrev'" == "NV" & "`var'" == "incentive_corptax" {
			qui gen col_`var'_`stateabbrev' = "N/A"
		}
		else if "`var'" == "corprate" {
			qui gen col_`var'_`stateabbrev' = round(`var'[`row'], 0.1) in 1
		}
		else {
			qui gen col_`var'_`stateabbrev' = round(`var'[`row']) in 1
		}
	}
}

* Make average numbers
foreach var in corptaxrev_pc incentive_corptax corprate total_credits_pc total_budget_pc n cost_per_job {
	qui summ `var'
	if "`var'" == "corprate" {
		qui gen avg_`var' = round(`r(mean)', 0.1) in 1
	}
	else {
		qui gen avg_`var' = round(`r(mean)') in 1
	}
}

format avg_cost_per_job col_cost_per_job_* %12.0fc

qui gen label_corptaxrev_pc = "Corporate Tax Revenue Per Capita (2017 USD)" in 1
qui gen label_corprate = "Corporate Tax Rate (\%)" in 1
qui gen label_incentive_corptax = "Incentives as a percent of Corp Tax Revenues (\%)"
qui gen label_total_credits_pc = "Tax Credits per capita (2017 USD)" in 1
qui gen label_total_budget_pc = "Econ Development per capita (2017 USD)" in 1
qui gen label_n = "Number of subsidies" in 1
qui gen label_cost_per_job = "Cost per job (2017 USD)" in 1

	/***************************************************************************
		MAKE TABLE
	***************************************************************************/

qui gen tab = "\begin{tabular}{r*{10}{c}}" in 1
qui gen top = "\toprule" in 1

qui gen mid = "  \midrule " in 1
qui gen hline = " \hline" in 1

qui gen bot = "  \bottomrule" in 1

qui gen end = "\end{tabular}" in 1
qui gen title0 = " & Average & AL & CA & NV & NY & PA & SC & TN & WV" in 1

qui gen panel1 = "\multicolumn{10}{l}{\textit{Instrument 1:}}" in 1 
qui gen panel2 = "\multicolumn{10}{l}{\textit{Instrument 2:}}" in 1 
qui gen panel3 = "\multicolumn{10}{l}{\textit{Instrument 3:}}" in 1 

local filename = "table1"

listtex tab if _n == 1 using "$tabdir/`filename'.tex", replace rstyle(none)
listtex top if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex title0 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)

listtex mid if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)

listtex panel1 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex label_corprate avg_corprate col_corprate_* if _n == 1, ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex label_corptaxrev_pc avg_corptaxrev_pc col_corptaxrev_pc_* if _n == 1, ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular)

listtex panel2 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex label_total_credits_pc avg_total_credits_pc col_total_credits_pc_* if _n == 1, ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular)	
listtex label_total_budget_pc avg_total_budget_pc col_total_budget_pc_* if _n == 1, ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular)

listtex panel3 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex label_n avg_n col_n_* if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)	
listtex label_cost_per_job avg_cost_per_job col_cost_per_job_* if _n == 1, ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular)

listtex mid if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)

listtex label_incentive_corptax avg_incentive_corptax col_incentive_corptax_* if _n == 1, ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular)

listtex bot if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)
listtex end if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)

/*******************************************************************************
	TABLE 2: SUMMARY STATISTICS of AVERAGE DEAL AND SELECT INDUSTRIES RECEIVING 
			SUBSIDIES
*******************************************************************************/
	
	/***************************************************************************
		LOAD IN AND PREP DATA (Need access to internal data in order to run 
			commented section here)
	***************************************************************************/

* Get industry names (labels)
/* import delimited using "$rawdir/naics4d_labels.csv", clear
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

qui gen tab = "\begin{tabular}{l|rrrrr}" in 1
qui gen top = "\toprule" in 1
*Midrule
qui gen mid = " \midrule" in 1 
qui gen hline = " \hline" in 1 
*Bottomrule
qui gen bot = "\bottomrule" in 1
*End
qui gen end = "\end{tabular}" in 1

*Panel
#delimit ;
qui gen title1 = "& \# of & Subsidy & Jobs Promised & 
			Cost Per Job & Investment Promise \\ " in 1;
qui gen title2 = "& Deals & (2017 M USD) & & (2017 USD) & (2017 M USD)\\ " in 1;
#delimit cr

g c = " "

*Output
local filename = "table2"

listtex tab if _n == 1 using "$tabdir/`filename'.tex", replace rstyle(none)
listtex title1 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex title2 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex hline if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex longname n subsidy jobs cost_per_job invest_M if longname == "Full sample", ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular) 
listtex hline if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex longname n subsidy jobs cost_per_job invest_M if ///
	inlist(longname, "Automobile manuf. (3361)", "Aerospace manuf. (3364)", ///
			"Financial activities (5239)", "Scientific R\&D svc (5417)", ///
			"Basic chemical manuf. (3251)"), ///
	appendto("$tabdir/`filename'.tex") rstyle(tabular) 
listtex bot if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex end if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)

/*******************************************************************************
	TABLE 3: REGRESSION TABLE:
		INDICATOR FOR PER CAPITA INCENTIVES INCREASING BY 20% ON:
			GOVERNOR BEING ABLE TO RUN AS INCUMBENT
			ELECTION YEAR
			INTXN B/W INCUMBENT AND ELECTION YEAR
			GDP PER CAPITA ($1000) IN T-1
			% OF POPULATION EMPOYED IN T-1
********************************************************************************/
		
	/***************************************************************************
		LOAD IN AND PREP DATA
	***************************************************************************/
		
use "$rawdir/state_year_chars.dta", clear

qui egen bc_all=rowtotal(bc_gov bc_house bc_senate) // Business contributions to political office campaigns

qui gen dem_gov = (gov_party == "Democratic") // Part control of offices
qui gen dem_state = (party_control == "Dem")

foreach v in GDP GOS bc_gov bc_all emp_CBP educ_expend grev_own_tax corptaxrev /// Convert to per capita
	total_incentives {

	qui gen `v'_percap = `v' / pop
}

qui replace GDP_percap=GDP_percap * 1000 // Rescale gdp per cap in 1000s

* Converge wage & comp measures to per employee
qui gen avg_wage=avgpay_CBP/emp_CBP
qui gen avg_comp = comp/emp_CBP
rename emp_CBP_percap epop 

rename total_incentives_percap incentive_percap

qui replace epop = epop * 100 // epop in %

sort fips year
qui by fips: gen d_incentive = incentive_percap-incentive_percap[_n-1] // get change in incentive
qui by fips: gen pc_incentive = d_incentive/incentive_percap[_n-1] // get change in incentive (pct)

/* Create indicators for per capita incentive spending increasing at various 
	thresholds */
qui gen increase = cond(missing(pc_incentive), ., pc_incentive >= .20)
qui gen increase50 = cond(missing(pc_incentive), ., pc_incentive >= .50)

local vlist "bc_all_percap incumbent new GDP_percap epop"
sort fips year
foreach v in `vlist' {
	qui by fips: gen `v't1 = `v'[_n-1] // Make lag variables
}

replace incumbent = 1 if new == 1

qui gen eyear = ((year - election_year) == 4)
qui gen eyearXincumbent = eyear * incumbent

label var incumbent "Governor can run as incumbent"
label var eyear "Election year"
label var eyearXincumbent "Gov can run as incumbent $\times$ Election year"
label var GDP_percapt1 "GDP per capita (\textdollar1000) in $ t-1$"
label var epopt1 "\% of population employed in $ t-1$"

	/***************************************************************************
		COMPUTE AND STORE REGRESSION COEFFICIENTS, MAKE OUTPUT
	***************************************************************************/

eststo clear
foreach indepvar in incumbent eyear GDP_percapt1 epopt1 {
	eststo: reghdfe increase `indepvar', absorb(year fips)
}
eststo: reghdfe increase eyear incumbent eyearXincumbent, absorb(year fips)
eststo: reghdfe increase incumbent eyear eyearXincumbent GDP_percapt1 epopt1, absorb(year fips)

* Output
*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
* esttab using "$tabdir/table3.tex", replace ///
	cells(b(star fmt(%-10.2fc)) se(par fmt(%-10.2fc)))	///
	starlevels(* 0.10 ** 0.05 *** 0.01)	noconstant		///
	stats(N r2, fmt(0 2)	///
	labels("Observations" "R-squared"))	nonumber	///
	label  collabels(none) mlabels(none) ///
	mgroup("Per Capita Incentives Increase by 20\%", ///
	pattern(1 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span erepeat(\cmidrule(lr){@span}))

/*******************************************************************************
	TABLE 4: DiD EFFECTS OF WINNING A FIRM-SPECIFIC DEAL ON COUNTY- 
			LEVEL EMPLOYMENT IN 1, 2, AND 3-D INDUSTRY OF DEAL, PLUS RESIDUAL 
			EMPLOYMENT, AVERAGE WAGES IN 3-D INDUSTRY OF DEAL, PERSONAL INCOME, 
			LOG HPI, AND EMPLOYMENT-TO-POPULATION RATIO
*******************************************************************************/

	/***************************************************************************
		1) CREATE LISTS OF VARIABLES
	***************************************************************************/
	
global X_10pre "ln_pop_90 ln_emp_90 ln_avg_wages_90" // controls

gl countyleveloutcomes "naics3d_emp naics2d_emp_res naics1d_emp_res emp_res personal_inc_pc HPI epop"

	/***************************************************************************
		2) LOAD IN AND PREP DATA
	***************************************************************************/

use $processeddir/deal_specific_tva_analysis.dta, clear

forv i = 95/105 { // Make outcomes that we want but which we don't have yet	
	gen epop_`i' = emp_`i' / pop_`i'
	gen ln_epop_`i' = log(epop_`i') 
}

reshape long naics3d_emp naics3d_ln_emp naics2d_emp_res naics2d_ln_emp_res ///
			naics1d_emp_res naics1d_ln_emp_res emp_res ln_emp_res personal_inc_pc ///
			ln_personal_inc ln_HPI epop ln_epop, i(id runnerup_id) ///
		j(eventyr _90 _95 _96 _97 _98 _99 _100 _101 _102 _103 _104 _105, string)

keep id runnerup_id deal_year fips fipscounty naics3d_emp naics3d_ln_emp ///
	naics2d_emp_res naics2d_ln_emp_res naics1d_emp_res naics1d_ln_emp_res ///
	emp_res ln_emp_res personal_inc_pc ln_personal_inc ln_HPI epop ln_epop ///
	$X_10pre eventyr winner

rename (naics3d_ln_emp naics2d_ln_emp_res naics1d_ln_emp_res) ///
	(ln_naics3d_emp ln_naics2d_emp_res ln_naics1d_emp_res)

destring eventyr, replace ignore("_")
	
	/***************************************************************************
		3) CREATE DiD VARIABLES
	***************************************************************************/
	
qui gen post = (eventyr >= 100)
qui gen postXwinner = post * winner

	/***************************************************************************
		4) RUN DiD REGRESSIONS
	***************************************************************************/

*** Edited by Ryan Steed
eststo clear
***
local colnum = 1
foreach outcome in $countyleveloutcomes {
	qui gen col_`outcome' = ""

	* Run levels regression, capture the values
	if "`outcome'" != "HPI" {
		eststo: qui reg `outcome' winner post postXwinner $X_10pre i.deal_year, vce(cluster fips)

		qui lincom _b[postXwinner] 

		qui replace col_`outcome'  =  string(r(estimate), "%9.3f") in 1
		qui replace col_`outcome' =  "(" + string(r(se), "%9.3f") + ")" in 2
		qui replace col_`outcome' = string(e(N)) in 7 if missing(col_`outcome'[7])

		if abs(r(p))< .01 {
			qui replace col_`outcome' = col_`outcome' + "$ ^{***}$ " in 1
		}
		if abs(r(p)) < .05 & abs(r(p)) >= .01 {
			qui replace col_`outcome' = col_`outcome' + "$ ^{**}$ " in 1
		}
		if abs(r(p)) < .1 & abs(r(p)) >= .05 {
			qui replace col_`outcome' = col_`outcome' + "$ ^{*}$ " in 1
		}

		qui summ `outcome' if postXwinner == 1
		qui replace col_`outcome' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 3
	}
	else {
		qui replace col_`outcome' = "N/A" in 1
		qui replace col_`outcome' = "N/A" in 2
		qui replace col_`outcome' = "N/A" in 3
	}

	if "`outcome'" == "personal_inc_pc" {
		local outcome = "personal_inc"
	} 

	* Run log regression, capture the values
	qui reg ln_`outcome' winner post postXwinner $X_10pre i.deal_year, vce(cluster fips) 
	qui lincom _b[postXwinner] 
	qui replace col_`outcome'  =  string(r(estimate), "%9.3f") in 4
	qui replace col_`outcome' =  "(" + string(r(se), "%9.3f") + ")" in 5
	qui replace col_`outcome' = string(e(N)) in 7 if missing(col_`outcome'[7])

	if abs(r(p))< .01 {
		qui replace col_`outcome' = col_`outcome' + "$ ^{***}$ " in 4
	}
	if abs(r(p)) < .05 & abs(r(p)) >= .01 {
		qui replace col_`outcome' = col_`outcome' + "$ ^{**}$ " in 4
	}
	if abs(r(p)) < .1 & abs(r(p)) >= .05 {
		qui replace col_`outcome' = col_`outcome' + "$ ^{*}$ " in 4
	}

	qui summ ln_`outcome' if postXwinner == 1
	qui replace col_`outcome' = " \textcolor{gray}{ " + string(r(mean), "%9.3f") +"}" in 6

	qui replace col_`outcome' = "(`colnum')" in 8
	local ++colnum
}
*** EDITED by Donna
estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

	/***************************************************************************
		5) MAKE TABLE
	***************************************************************************/

capture drop label

qui gen tab = "\begin{tabular}{r*{8}{c}}" in 1
qui gen top = "\toprule" in 1

qui gen mid = "  \midrule " in 1
qui gen hline = " \hline" in 1

qui gen bot = "  \bottomrule" in 1

qui gen end = "\end{tabular}" in 1

#delimit ;
qui gen title0 = " & 3-D Ind. & Res. 2-D Ind. & Res. 1-D Ind.
	& Res. County-wide & Personal inc. & log HPI & Emp/pop" in 1;
qui gen title1 = " & Employment & Employment & Employment
	& Employment &  &  & " in 1;
#delimit cr

qui gen panelA = "\multicolumn{8}{l}{\textit{Panel A. Levels Estimates}}" in 1 
qui gen panelB = "\multicolumn{8}{l}{\textit{Panel B. Log Estimates}}" in 1 

qui gen labels = "" 
qui replace labels = "Winner $ \times$ Post " if inlist(_n, 1, 4)
qui replace labels = " \textcolor{gray}{Mean of outcome} " if inlist(_n, 3, 6)
qui replace labels = "Observations" in 7

local filename = "table4"

listtex tab if _n == 1 using "$tabdir/`filename'.tex", replace rstyle(none)
listtex top if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)	
listtex title0 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex title1 if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex labels col_* if _n == 8, appendto("$tabdir/`filename'.tex") rstyle(tabular)

listtex mid if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)

listtex panelA if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex labels col_* if  inrange(_n, 1, 3), appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex mid if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)

listtex panelB if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex labels col_* if  inrange(_n, 4, 6), appendto("$tabdir/`filename'.tex") rstyle(tabular)
listtex bot if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)
listtex end if _n == 1, appendto("$tabdir/`filename'.tex") rstyle(none)