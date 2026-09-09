*****************************************************************************************************************
* Author: V Perez																								*
* Created: 			August 19, 2017																				*
* Last Modified:    August 19, 2017																				*
* Purpose: Analyze the effect of fiscal uncertainty on simulated Medicaid eligibility							*
* Final file for output: nasbo_shocks_finalfile																	*
*****************************************************************************************************************

clear all
set more off

eststo clear
/*Working Directories*/

*** EDIT by Donna
* global db "/Users/vieperez/Dropbox/Work"
* global basedir "${db}/BPS_MedicaidCoverage&Recessions/PapersProceedings"
global outputdir "../2_data"
global inputdir "${outputdir}/NASBO/ExpenditureReports"
global sourcedir "."
global logdir "."
global tabledir "../4_output"
global datadir "${outputdir}/NASBO"

********************************************************************************
*																			   *
* Part 1: Merge measures of fiscal margins of error with simulated eligibility *
*																			   *
********************************************************************************

	use "${outputdir}/sim_elig_adults2.dta", clear
		merge 1:1 year st_fips using "${datadir}/nasbo_shocks_finalfile.dta"
			drop if _merge==1
			drop _merge
			
		merge 1:1 year st_fips using "${outputdir}/AllStates_JulyAnnualUnemploymentRate2001_2010.dta"
			drop if _merge!=3
			drop _merge	

	xtset st_fips year

/********************************************************************************
*																			   *
* Part 2: Summary table of measures											   *
*																			   *
********************************************************************************/
		label var sim_mcd_elig "Simulated Medicaid eligibility"

*** EDIT by Donna
	estpost tabstat sim_mcd_elig rdshocklvl ann_unempl,  ///
		statistics(mean sd ) columns(statistics) listwise
		eststo doctor

	esttab doctor using "${tabledir}/stage1summarystats.tex", ///
		main(mean) aux(sd)  noobs nonote nonumber f label unstack ///
		mtitle("By Medicaid Eligibility") ///
		replace

********************************************************************************/
*																			   *
* Part 3: Analysis - Extensive Margin Generosity (Eligibility)				   *
*																			   *
********************************************************************************
gen neg=rdshocklvl <= 0
gen pos=rdshocklvl >= 0

		foreach var in rdshocklvl {
		replace `var'=ln(`var'+4500)

	}
	* Table 1 - 
	*** Edit by Donna
	foreach var in neg pos rdshocklvl{		 
	set more off

		eststo: xtreg sim_mcd_elig l.`var' l.ann_unempl i.year, fe cluster(st_fips) 	
		estadd local year_fe "Yes"
		estadd local state_fe "Yes" 
		estimates store e`var'
			estadd ysumm
			estimates store m2`var'
	}					 	
	
	esttab m2rdshocklvl m2neg m2pos /// 	
	using "${tabledir}/stage1_results.tex", ///		
	 starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001) label ///
	booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	stats(ymean ysd N state_fe year_fe , fmt(a2 a2 0 0 ) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ) ///
	label("\hline \hline Dep. Variable Mean" "Dep. Variable SE" "Obs." "\hline State FE" "Year FE")) ///
	f substitute(\_ _) ///
	mgroups("DV: Medicaid Eligibility" "DV: Negative shock (0/1)" "DV: Positive shock (0/1)", pattern(1 1 1 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	noline collabels(none) ///
	nogaps compress nomtitles ///
	replace 

	*** EDITED by Donna
	estout m2rdshocklvl m2neg m2pos using "../../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace	
