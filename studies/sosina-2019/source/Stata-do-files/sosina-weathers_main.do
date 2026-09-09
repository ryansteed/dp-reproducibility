********************************************************************************
* pathways to inequality: main paper tables
* Victoria Sosina (vsosina@stanford.edu)
********************************************************************************
* preliminaries
capture log close
macro drop _all
version 13
set linesize 82
set more off, perm

* set date
global date "190625"

* create results directory
cap mkdir "Results"
cap mkdir "Results/Estimates"

********************************************************************************
*PROGRAMS
********************************************************************************
*fstat
capture program drop fstat
	program define fstat
		args F P
		
		local F: di %4.3f `F'
		estadd local Fstat `F'
		
		local P: di %4.3f `P'
		estadd local Fstatpval `P'
	end
	
*omnibus test
capture program drop Test
	program define Test
		
		args cmdline options o 
		
		di _n
		di "********************"
		di "`e(cmdline)'"
		di "********************"
		
		local independent `e(cmdline)'
		local independent subinstr("`independent'",", `options'", "",1)
		local independent subinstr(`independent', "`o'", "",1)
		local independent subinstr(`independent',"xtreg", "",1)
		local independent subinstr(`independent',"i.", "",1)
		local independent = `independent'
		local independent subinstr("`independent'", "year", "",1)

		local vars = `independent'
		local Test ""
		foreach v of local vars{
			local Test "`Test' `v' = "
		}

		local Test = substr("`Test'",1,length("`Test'")-3)
		di _n
		di "********************"
		di "test `Test'"
		di "********************"
		test `Test'

	end
	
********************************************************************************
* SPECIFY TABLES TO CREATE
********************************************************************************

* set local for desired table to 1
local tab1 = 0
local tab2 = 0
local tab3 = 0
local fig1 = 0
local fig2 = 0

********************************************************************************
* TABLE 1
********************************************************************************
if `tab1' == 1{

	* open analytical file
	use "data_files/15_year_sample_state_${date}", clear

	* keep sample reduced for missing controls
	keep if red_samp == 1

	* drop unncessary variables that interfere with reshaping
	drop *trend
		
	* rename for reshape
	local stubs ""
	foreach v of var bw* hw*{
			*dissect to create stubs for reshaping
			local pre = substr("`v'", 1, 2)
			local suf = substr("`v'", 3, .)
			
			*rename to create stubs for reshaping
			rename `v' `suf'`pre'
	}

	* get stubs to reshape
	foreach v of var *bw{		
			*save variable labels
			local l`v' : variable label `v'
			local l`v' = subinstr("`l`v''", "black-white", "", 1)
			
			*get stubs for reshaping
			local new = substr("`v'", 1, length("`v'") - 2)
			local stubs "`stubs' `new'"
			
			*save variable label with the stub name
			local l`new' = "`l`v''"
	}

	* reshape
	gen id = _n
	reshape long `stubs', i(id) j(race) string

	* keep variables and subgroups of interest
	keep imp_fips year race `stubs' red_samp

	* collapse to get descriptive statistics
	collapse (mean) ddexp_totexp_std 	ddexp_admin_std ///
					ddexp_infra_std 	ddexp_instr_std ///
					ddexp_social_std 	ddexp_other_std ///
					difpov				difwht ///
					difhsp 				difblk  ///
					difspec				difpsch ///
					difell				difcity ///
					difsuburb 			difothgeo ///
						, by(imp_fips race)

	* apply labels
	foreach v of var * {
		local first = substr("`l`v''",1,1)
		if "`first'"==" "{
			local l`v' = subinstr("`l`v''", " ", "", 1)
		}
		
		label variable `v' "`l`v''"

	}
						
	* make table of descriptive statistics - sample reduced for missing controls
	sort race
	eststo clear
	by race: eststo: quietly estpost summarize 	///
		ddexp_totexp_std 	ddexp_admin_std ///
		ddexp_infra_std 	ddexp_instr_std ///
		ddexp_social_std 	ddexp_other_std ///
		difpov				difwht ///
		difhsp 				difblk  ///
		difspec				difpsch ///
		difell				difcity ///
		difsuburb difothgeo
	
	* set format
	local fmt3 "fmt(%4.3f)"
	local fmt3_l "fmt(%10.3f)"
	local fmt0 "fmt(%10.0f)"
	
	* make table
	esttab using "Results/sosina-weathers_tab1_${date}.csv", ///
		replace label nodepvar noobs ///
		cells("mean(`fmt3') sd(`fmt3') min(`fmt3_l') max(`fmt3_l') count(`fmt0')") ///
		title("Descriptive Statistics for 15 Year Sample State Disparity Measures")

}

********************************************************************************
*TABLE 2
********************************************************************************

if `tab2' == 1{	
	* open analytical file
	use "data-files/15_year_sample_state_${date}", clear
	
	* keep sample reduced for missing controls
	keep if red_samp == 1

	* drop unncessary variables that interfere with reshaping
	drop *trend

	* rename for reshape
	local stubs ""
	foreach v of var bw* hw*{
			*dissect to create stubs for reshaping
			local pre = substr("`v'", 1, 2)
			local suf = substr("`v'", 3, .)
			
			*rename to create stubs for reshaping
			rename `v' `suf'`pre'
	}

	* get stubs to reshape
	foreach v of var *bw{		
			*save variable labels
			local l`v' : variable label `v'
			local l`v' = subinstr("`l`v''", "black-white", "", 1)
			
			*get stubs for reshaping
			local new = substr("`v'", 1, length("`v'") - 2)
			local stubs "`stubs' `new'"
			
			*save variable label with the stub name
			local l`new' = "`l`v''"
	}

	* reshape
	gen id = _n
	reshape long `stubs', i(id) j(race) string

	* keep variables and subgroups of interest
	keep imp_fips year race `stubs' red_samp

	levelsof imp_fips, local(states)

	* calculate descriptive statistics
	foreach v in 	ddexp_totexp_std 	ddexp_admin_std ///
					ddexp_infra_std 	ddexp_instr_std ///
					ddexp_social_std 	ddexp_other_std ///
					difpov				difhsp 	///			
					difblk 				/// 
					difspec				difpsch ///
					difell				difcity ///
					difsuburb 			difothgeo{
					
					capture drop `v'trend
					capture drop `v'sd
					
					gen `v'trend = . 
					gen `v'sd = . 
					
					foreach r in bw hw{
						foreach s of local states{
							qui reg `v' year if race == "`r'" & imp_fips == `s'
							replace `v'trend = `=_b[year]' if race == "`r'" & imp_fips == `s'
							replace `v'sd = `v'trend  if race == "`r'" & imp_fips == `s'
						}
					}
				}
				
	collapse *trend (sd) *sd, by(imp_fips race) 

	drop *sd


	* make table of descriptive statistics - sample reduced for missing controls
	sort race
	eststo clear
	by race: eststo: quietly estpost summarize 	///
		ddexp_totexp_std 	ddexp_admin_std ///
		ddexp_infra_std 	ddexp_instr_std ///
		ddexp_social_std 	ddexp_other_std ///
		difpov				difhsp 		///
		difblk 							/// 
		difspec				difpsch ///
		difell				difcity ///
		difsuburb 			difothgeo, d
	
	* set format
	local fmt3 "fmt(%4.3f)"
	local fmt3_l "fmt(%10.3f)"
	local fmt0 "fmt(%10.0f)"
	
	local cells "mean(`fmt3') sd(`fmt3')  min(`fmt3_1') p5(`fmt3_1')"
	local cells "`cells' p25(`fmt3_1') p50(`fmt3_1') p75(`fmt3_1')"
	local cells "`cells' p95(`fmt3_1') max(`fmt3_1') count(`fmt0')"
	
	* make table
	esttab using "Results/sosina-weathers_tab2_${date}.csv", ///
		replace label nodepvar noobs ///
		cells("`cells'") ///
		title("Descriptive Statistics for 15 Year Sample State Disparity Measures")
}

********************************************************************************
*TABLE 3
********************************************************************************


	********************************************************************************
	* BLACK MODELS
	********************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	********************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "../data-files/15_year_sample_state_${date}", clear
		estimates clear
		
		*fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************

		* run models - dollar differences standardized**************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c"
		
		foreach o of local outcomes {
		
			eststo: xtreg `o' bwdifblk bwdifpov bwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tab3-`o'", replace)
		}
		estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
		eststo clear
		* make table
		estout tab1c${g}* using "Results/sosina-weathers_tab3-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table 3.`Race' Expenditure Disparities")
			
	********************************************************************************
	*HISPANIC MODELS
	********************************************************************************
	* change for different race models
	global Race ""
	global Race "Hispanic-White"
	global g "hw"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "../data-files/15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - dollar differences standardized**************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c"
		
		foreach o of local outcomes {
		
			eststo: xtreg `o' hwdifhsp hwdifpov hwdifblk ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tab3-`o'", replace)
		}
		***Edited by Annie
		estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace		
		estout tab1c${g}* using "Results/sosina-weathers_tab3-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table 1c.`Race' Expenditure Disparities")
			


********************************************************************************
*FIGURES
********************************************************************************
/*
if `fig1' == 1 | `fig2' == 1{

	****************************************************************************
	*OPEN FILE
	****************************************************************************

		*import fips labels
		import excel "fips.xlsx", clear firstrow
		rename fips imp_fips
		keep imp_fips postal

		*merge fips labels to clean dataset
		merge 1:m imp_fips using "data-files/15_year_sample_state_${date}.dta"

		*label fips and drop observations not in sample
		label values imp_fips imp_fips

		keep if red_samp == 1
			
	****************************************************************************

		*reshape for graphing***************************************************
		*keep only the start and end year
		*not all analytical sample states are present in 1999 and same for 2013
		bys imp_fips: egen min = min(year)
		bys imp_fips: egen max = max(year)	
		
		gen min_year = year if year == min
		gen max_year = year if year == max
		
		keep if !missing(min_year) | !missing(max_year)
		
		gen year_str = "min" if year == min_year
		replace year_str = "max" if year == max_year
		
		drop min* max*
		
		*keep only variables for analysis
		keep year year_str postal imp_fips bwdifblk hwdifhsp bwdifpov hwdifpov ///
			bwdifhsp hwdifblk ///
			imp_member imp_totblack imp_tothisp
			

		*reshape so that each row is a state
		reshape wide postal bwdifblk hwdifhsp bwdifpov hwdifpov ///
					 bwdifhsp hwdifblk ///
					 imp_member imp_totblack imp_tothisp year, ///
			i(imp_fips) j(year_str) string

		*keep one postal code variable
		rename postalmax postal
		drop postal???

		*shorten names for graphs
		rename imp_membermax 	membermax
		rename imp_totblackmax  blackmax
		rename imp_tothispmax 	hispmax
		
		*racial poverty segregation measures************************************
		*create change in poverty segregation levels between 2013 and 1999
		gen chgbwdifpov = bwdifpovmax - bwdifpovmin	//black
		gen chghwdifpov = hwdifpovmax - hwdifpovmin	//hispanic

		*baseline is poverty segregation in 1999
		gen baseblackpov = bwdifpovmin
		gen basehisppov = hwdifpovmin

		*racial segregation measures********************************************
		*create change in racial segregation levels between 2013 and 1999
		gen chgbwdifblk = bwdifblkmax - bwdifblkmin	//black
		gen chghwdifhsp = hwdifhspmax - hwdifhspmin	//hispanic
		
		*create change in other-group segregation levels between 2013 and 1999
		gen chgbwdifhsp = bwdifhspmax - bwdifhspmin	//black
		gen chghwdifblk = hwdifblkmax - hwdifblkmin	//hispanic
			
		*baseline is racial segregation in 1999
		gen baseblack = bwdifblkmin
		gen basehisp = hwdifhspmin
		
		gen baseblackoth = bwdifhspmin
		gen basehispoth = hwdifblkmin
		
		*clean for graphing*****************************************************
		*drop variables for other years
		drop bwdifblk???
}

* Make figure 1		
if `fig1' == 1{
	
		*set xsize and ysize
		global xsize "9"
		global ysize "6"
		//these values are based on the amount of space left on a page with 1-in
		//margins after adding a figure title but no figure notes


	*preferred - JUST RACIAL SEGREGATION****************************************
	*with x-axis at the bottom - aw by black in 2013 - poverty segregation
	twoway (scatter chgbwdifblk baseblack [aw = blackmax], ///
				msymbol(O) mfcolor("255 127 0%80") msize(small) ///
				mlwidth(vthin) mlcolor(gs1%50)) ///
		, ///
		title("Black-White", size(medium)) ///
		ytitle("") ///
		yline(0,lc(black) lw(thin)) ///
		yscale(range(-0.25 0.15) titlegap(*0)) ///
		ylabel(-0.25(0.05)0.15, angle(horizontal) nogrid format(%9.2f)) ///
		xtitle("") ///
		xscale(range(0 0.7)) ///
		xlabel(0(0.1)0.7, format(%9.2f)) ///
		legend(off) ///
		plotregion(color(white) margin(2 2 2 2)) ///
		graphregion(color(white) margin(0 2 0 0)) ///
		name(black1, replace)
		
		
	*with x-axis at the bottom - aw by hispanic in 2013 - poverty segregation
	twoway (scatter chghwdifhsp basehisp [aw = hispmax], ///
				msymbol(O) mfcolor("178 223 138%80") msize(small) ///
				mlwidth(vthin) mlcolor(gs1%50)) ///
		, ///
		title("Latinx-White", size(medium)) ///
		ytitle("") ///
		yline(0,lc(black) lw(thin)) ///
		yscale(range(-0.25 0.15) titlegap(*0)) ///
		ylabel(-0.25(0.05)0.15, angle(horizontal) nogrid format(%9.2f)) ///
		xtitle("") ///
		xscale(range(0 0.7)) ///
		xlabel(0(0.1)0.7, format(%9.2f)) ///
		plotregion(color(white) margin(2 2 2 2)) ///
		graphregion(color(white) margin(0 2 0 0)) ///
		name(hispanic1, replace)	

	****************************************************************************
	*scaled for print
	graph combine black1 hispanic1, ///
		b1title("Racial Segregation in First Fiscal Year", size(small)) ///
		l2title("Change in Racial Segregation" "(Between First and Last Fiscal Years)", ///
			position(9) size(small) orientation(vertical)) ///
		plotregion(c(white) margin(0 0 0 0)) ///		//outer box
		graphregion(c(white) margin(0 2 0 0))  ///		//inner box
		xsize(${xsize}) ysize(${ysize}) ///
		imargin(0 2 0 0)

	graph export "Results/sosina-weathers_fig1_${date}.png", as(png) replace
	window manage close graph _all
}

* Make figure 2

if `fig2' == 1{
	****************************************************************************
	local blk1 "227 26 28%80"	  	//red
	local blk2 "255 127 0%80"	  	//orange
	local blk3 "253 187 132%80"		//medium orange

	local hsp1 "31 120 180%80"	  	//blue
	local hsp2 "178 223 138%80"	  	//green
	local hsp3 "168 221 181%80"		//medium teal

	*preferred - JUST POVERTY SEGREGATION***************************************
	*with x-axis at the bottom - aw by black in 2013 - poverty segregation
	twoway (scatter chgbwdifpov baseblackpov [aw = blackmax], ///
				msymbol(O) mfcolor("`blk2'") msize(small) ///
				mlwidth(vthin) mlcolor(gs1%50)) ///
		, ///
		xline(0, lcolor(gs1%50) lpattern(dash)) ///
		title("Black-White", size(medium)) ///
		ytitle("") ///
		yline(0,lc(black) lw(thin)) ///
		yscale(titlegap(*0)) ///
		ylabel(, angle(horizontal) nogrid format(%9.2f)) ///
		xtitle("") ///
		xlabel(, format(%9.2f)) ///
		legend(off) ///
		plotregion(color(white) margin(2 2 2 2)) ///
		graphregion(color(white) margin(0 2 0 0)) ///
		name(black2, replace)
		
		
	*with x-axis at the bottom - aw by hispanic in 2013 - poverty segregation
	twoway (scatter chghwdifpov basehisppov [aw = hispmax], ///
				msymbol(O) mfcolor("`hsp2'") msize(small) ///
				mlwidth(vthin) mlcolor(gs1%50)) ///
		, ///
		xline(0, lcolor(gs1%50) lpattern(dash)) ///	
		title("Latinx-White", size(medium)) ///
		ytitle("") ///
		yline(0,lc(black) lw(thin)) ///
		yscale(titlegap(*0)) ///
		ylabel(, angle(horizontal) nogrid format(%9.2f)) ///
		xtitle("") ///
		xlabel(, format(%9.2f)) ///
		plotregion(color(white) margin(2 2 2 2)) ///
		graphregion(color(white) margin(0 2 0 0)) ///
		name(hispanic2, replace)	

	****************************************************************************
	*scaled for print	
	graph combine black2 hispanic2, ///
		ycommon xcommon ///
		b1title("Racial Poverty Segregation in First Fiscal Year", size(small)) ///
		l2title("Change in Racial Poverty Segregation" "(Between First and Last Fiscal Years)", ///
			position(9) size(small) orientation(vertical)) ///
		plotregion(c(white) margin(0 0 0 0)) ///		//outer box
		graphregion(c(white) margin(0 2 0 0))  ///		//inner box
		xsize(${xsize}) ysize(${ysize}) ///
		imargin(0 2 0 0)

	graph export "Results/sosina-weathers_fig2_${date}.png", as(png) replace
	window manage close graph _all
}
*/
