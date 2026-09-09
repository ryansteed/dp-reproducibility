/******************************************************************
*
* TABLE 4
*
******************************************************************/

	// call data
use "$data/state_year", clear

	// Define macro controls
global symacro "lnur  lnpop lnrpcpi ln_gov"  //lnrpcpi

eststo clear

	// ==============================================
	// THRESHOLD REGRESSIONS, LOG OF GIVING/POP
	 
	// ---------------------
	// TOP 0.1% 
global ln_income "ln_t01"
global ln_itax "lfs_irate_t01"
global ln_inequality "ln_sht01_frank"

eststo A1: reg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income, vce(cluster stfips)
eststo A2: reg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income isweighted [aw=popsh], vce(cluster stfips)
eststo A3: areg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income stfx, absorb(stfips) vce(cluster stfips)
eststo A4: areg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income stfx isweighted [aw=popsh],  absorb(stfips) vce(cluster stfips)


	// top 1%
global ln_income "ln_t1"
global ln_itax "lfs_irate_t1"
global ln_inequality "ln_sht1_frank"


eststo B1: reg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income, vce(cluster stfips)
eststo B2: reg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income isweighted [aw=popsh], vce(cluster stfips)
eststo B3: areg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income stfx, absorb(stfips) vce(cluster stfips)
eststo B4: areg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income stfx isweighted [aw=popsh],  absorb(stfips) vce(cluster stfips)

		
		// top 0.01%
global ln_income "ln_t001"
global ln_itax "lfs_irate_t001"
global ln_inequality "ln_sht001_frank"

eststo C1: reg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income, vce(cluster stfips)
eststo C2: reg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income isweighted [aw=popsh], vce(cluster stfips)
eststo C3: areg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income stfx, absorb(stfips) vce(cluster stfips)
eststo C4: areg ln_c_styear yr???? $ln_itax  $ln_inequality $symacro   $ln_income stfx isweighted [aw=popsh],  absorb(stfips) vce(cluster stfips)


	 // ==============================================
	 // MAKE TABLE OUTPUT
	 
	 // Word-formatted table, full list of variables
esttab A1 A2 A3 A4  B4  C4 using "$tables/table4.csv", 				///
	replace label csv r2 se  nonotes nogaps						///
	indicate("Macro Controls = $symacro  " 						/// 
		"Year Effects = yr????"  								///
		"State Fixed Effects = stfx"							///
		"Population Share Weighted = isweighted")				///
		starlevels(+ 0.10 * 0.05 ** 0.01)						
*** Edited by Ryan
estout A1 A2 A3 A4  B4  C4 using "./../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace	
***
