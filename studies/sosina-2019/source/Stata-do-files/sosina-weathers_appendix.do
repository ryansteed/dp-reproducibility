********************************************************************************
* pathways to inequality: appendix paper tables
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
local taba3 = 1
local taba4 = 1
local taba5 = 1
local tabb1 = 1
local tabb2 = 1
local tabb3 = 1
local tabb4 = 1
local tabb5 = 1
local tabb6 = 1
local tabb7 = 1
local tabb8 = 1
local tabb9 = 1
local figb1 = 1

********************************************************************************
* TABLE A3
********************************************************************************
if `taba3' == 1{
	*Restrict for 15-year sample****************************************************
	use "15_year_sample_district_all-obs_190625.dta", clear
	
	* count for sample restriction
	qui count if year >= 1999 & year <= 2013
	local res1 = `r(N)'
	keep if year >= 1999 & year <= 2013
	
	qui count if drop_notstate == 1
	local res2 = `r(N)'
	drop if drop_notstate == 1
	
	qui count if drop_noop == 1
	local res3 = `r(N)'
	drop if drop_noop == 1
	
	qui count if drop_vocspec == 1
	local res4 = `r(N)'
	drop if drop_vocspec == 1
	
	qui count if drop_esa == 1
	local res5 = `r(N)'
	drop if drop_esa == 1
	
	qui count if drop_jj == 1
	local res6 = `r(N)'
	drop if drop_jj == 1
	
	qui count if drop_charter == 1
	local res7 = `r(N)'
	drop if drop_charter == 1
	
	qui count if drop_out == 1
	local res8 = `r(N)'
	drop if drop_out == 1
	
	qui count if drop_miss == 1
	local res9 = `r(N)'
	drop if drop_miss == 1
	
	qui count if Drop_poverty == 1
	local res10 = `r(N)'
	drop if Drop_poverty == 1
	
	local res11 = (`res2' + `res3' + `res4' + `res5' + `res6' + ///
				   `res7' + `res8' + `res9' + `res10')
	
	local res12 = `res1' - `res11'
	
	* display sample restriction
	local col = 70
	
	tempname t
	file open `t' using "Results/sosina-weathers_taba3.txt", replace write
	
	file write `t' ///
	 	"Total district-year observations between 1999 and 2013" _tab (`res1') _n ///
		"Total BIE, DOD, territories, DC, and Hawaii districts dropped" _tab (`res2') _n ///
		"Total non-operational districts dropped" _tab (`res3') _n ///
		"Total vocational/special education districts" _tab (`res4') _n ///
		"Total federal, regional, or other ESAs dropped" _tab (`res5') _n ///
		"Total juvenile justice districts dropped" _tab (`res6') _n ///
		"Total charter districts dropped" _tab (`res7') _n ///
		"Total high/low total per pupil expenditures outliers dropped" _tab (`res8') _n ///
		"Total missing expenditure or per pupil expenditures dropped" _tab (`res9') _n ///
		"Total with no 5-17 year olds according to SAIPE dropped" _tab (`res10') _n ///
		"Total district-years dropped" _tab (`res11') _n ///
		"Total district-years in analytical sample" _tab (`res12')
	
	file close `t'
}

********************************************************************************
* TABLE A4
********************************************************************************
if `taba4' == 1{
	use "15_year_sample_state_${date}", clear

	rename red_samp fy

	keep fy imp_fips year
	reshape wide fy, i(imp_fips) j(year)

	foreach v of var fy*{
		replace `v' = `v' - 1
		replace `v' = 1 if `v' == -1
		tostring `v', replace
		replace `v' = "" if `v' == "0"
		replace `v' = "X" if `v' == "1"
	}

	export excel "Results/sosina-weathers_taba4_${date}", ///
		replace firstrow(variables)

}

********************************************************************************
* TABLE A5
********************************************************************************
if `taba5' == 1{
	use "15_year_sample_state_${date}", clear
	estimates clear

	* fix the sample for the speced/ell comparison
	keep if red_samp == 1
	
	* black-white
	global g "bw"

	local outcomes ""
	local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
	local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
	local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"

	foreach o of local outcomes {
		xtreg `o' ${g}difpov ${g}difcity ${g}difothgeo ///
			i.year, i(imp_fips) fe vce(cluster imp_fips)
			
		predict pred_`o'
	}

	* hispanic-white
	global g "hw"

	local outcomes ""
	local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
	local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
	local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"

	foreach o of local outcomes {
		xtreg `o' ${g}difpov ${g}difcity ${g}difothgeo ///
			i.year, i(imp_fips) fe vce(cluster imp_fips)
			
		predict pred_`o'
	}

	keep year imp_fips pred_*
	
	* black-white table
	eststo clear
	eststo: quietly estpost summarize 	///
		pred_bw*, d

	esttab using "Results/sosina-weathers_taba5-bw_${date}.csv", ///
		replace nodepvar noobs ///
		cells("mean(fmt(%4.2f)) sd(fmt(%4.2f))  min(fmt(%10.2f)) max(fmt(%10.2f))") ///
		title("Descriptive Statistics for Predicted Values, Conditional on Poverty Disparity and Urbanicity")
	
	* hispanic-white tables
	eststo clear
	eststo: quietly estpost summarize 	///
		pred_hw*, d

	esttab using "Results/sosina-weathers_taba5-hw_${date}.csv", ///
		append nodepvar noobs ///
		cells("mean(fmt(%4.2f)) sd(fmt(%4.2f))  min(fmt(%10.2f)) max(fmt(%10.2f))") ///
		title("Descriptive Statistics for Predicted Values, Conditional on Poverty Disparity and Urbanicity")
}

********************************************************************************
* TABLE B1
********************************************************************************
if `tabb1' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	global g3 "blk"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* generate trend in segregation interaction variables
		gen ${g}dif${g3}_X_incseg = ${g}dif${g3} * ${g}dif${g3}_trend 
		gen ${g}difpov_X_incseg   = ${g}difpov * ${g}dif${g3}_trend  
		//racial and poverty segregation interacted with indicator of inc race seg
		
			local text "disparity X increasing racial seg trend"
			label variable ${g}dif${g3}_X_incseg "${g} ${g3} enroll `text'"
			label variable ${g}difpov_X_incseg   "${g} ${g3} poverty `text'"
		
		* run models - dollar differences standardized**************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		* interaction***********************************************************
		local tablenm "tab1c8a"
		local `tablenm'exp ""
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifpov bwdifblk_X_incseg bwdifpov_X_incseg ///
				bwdifhsp ${controls} prop_pov ${state}, ${options}
			di e(cmdline)
			di _n
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb1`o'", replace)

		}
		
		* table 
		estout tab1c8a${g}* using "Results/sosina-weathers_tabb1-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(``tablenm'exp') ///	
			label delimiter(",") title("Table B1.`Race' Expenditure Disparities")
	
	****************************************************************************
	* HISPANIC MODELS
	****************************************************************************
	*change for different race models
	global Race ""
	global Race "Hispanic-White"
	global g "hw"
	global g3 "hsp"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* generate trend in segregation interaction variables
		gen ${g}dif${g3}_X_incseg = ${g}dif${g3} * ${g}dif${g3}_trend 
		gen ${g}difpov_X_incseg   = ${g}difpov * ${g}dif${g3}_trend  
		//racial and poverty segregation interacted with indicator of inc race seg
		
			local text "disparity X increasing racial seg trend"
			label variable ${g}dif${g3}_X_incseg "${g} ${g3} enroll `text'"
			label variable ${g}difpov_X_incseg   "${g} ${g3} poverty `text'"
		
		* run models - dollar differences standardized**************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		* interaction***********************************************************
		local tablenm "tab1c8a"
		local `tablenm'exp ""
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifpov hwdifhsp_X_incseg hwdifpov_X_incseg ///
				hwdifblk ${controls} prop_pov ${state}, ${options}
			di e(cmdline)
			di _n
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb1`o'", replace)
		}
		* table
		estout tab1c8a${g}* using "Results/sosina-weathers_tabb1-${g}_${date}.csv", ///
		replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
		stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
		labels("N" "R-squared" "F" "Prob > F")) ///
		mlabel(``tablenm'exp') ///	
		label delimiter(",") title("Table B1.`Race' Expenditure Disparities")
			
}

********************************************************************************
* TABLE B2
********************************************************************************
if `tabb2' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	global g3 "blk"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* generate recession interaction variables
		gen ${g}dif${g3}_X_rec = ${g}dif${g3} * recession //racial seg 2008 & post
		gen ${g}difpov_X_rec   = ${g}difpov * recession   //poverty seg 2008 & post
		
			local text "disparity X post-recession"
			label variable ${g}dif${g3}_X_rec "${g} ${g3} enroll `text'"
			label variable ${g}difpov_X_rec     "${g} ${g3} poverty `text'"
		
		* run models - dollar differences standardized**************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		* interaction***********************************************************
		local tablenm "tab1c6a"
		local `tablenm'exp ""
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifpov bwdifblk_X_rec bwdifpov_X_rec ///
				bwdifhsp ${controls} prop_pov ${state}, ${options}
			di e(cmdline)
			di _n	
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb2`o'", replace)

		}
		
	* table
	estout tab1c6a${g}* using "Results/sosina_weathers_tabb2-${g}_${date}.csv", ///
		replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
		stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
		labels("N" "R-squared" "F" "Prob > F")) ///
		mlabel(``tablenm'exp') ///	
		label delimiter(",") title("Table B2.`Race' Expenditure Disparities")
		
	****************************************************************************
	*HISPANIC MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Hispanic-White"
	global g "hw"
	global g3 "hsp"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* generate recession interaction variables
		gen ${g}dif${g3}_X_rec = ${g}dif${g3} * recession //racial seg 2008 & post
		gen ${g}difpov_X_rec   = ${g}difpov * recession   //poverty seg 2008 & post
		
			local text "disparity X post-recession"
			label variable ${g}dif${g3}_X_rec "${g} ${g3} enroll `text'"
			label variable ${g}difpov_X_rec     "${g} ${g3} poverty `text'"
		
		* run models - dollar differences standardized**************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		* interaction***********************************************************
		local tablenm "tab1c6a"
		local `tablenm'exp ""
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifpov hwdifhsp_X_rec hwdifpov_X_rec ///
				hwdifblk ${controls} prop_pov ${state}, ${options}
			di e(cmdline)
			di _n
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb2`o'", replace)

		}
		* table
		estout tab1c6a${g}* using "Results/sosina_weathers_tabb2-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(``tablenm'exp') ///	
			label delimiter(",") title("Table B2.`Race' Expenditure Disparities")				
}

********************************************************************************
* TABLE B3
********************************************************************************
if `tabb3' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	global g3 "blk"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear //use no cwi file
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - dollar differences standardized***************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}difstR 	${g}difstRnout" 
		
		* student teacher ratio*************************************************
		local tablenm "tab1c10"
		local `tablenm'exp ""

		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifpov bwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			di e(cmdline)
			di _n
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb3`o'", replace)

		}
		
		* table
		estout tab1c10${g}* using "Results/sosina_weathers_tabb3-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(``tablenm'exp') ///	
			label delimiter(",") title("Table B3.`Race' Expenditure Disparities")

	****************************************************************************
	* HISPANIC MODELS
	****************************************************************************
	*change for different race models
	global Race ""
	global Race "Hispanic-White"
	global g "hw"
	global g3 "hsp"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear //use no cwi file
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - dollar differences standardized**************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}difstR 	${g}difstRnout" 
		
		* student teacher ratio*************************************************
		local tablenm "tab1c10"
		local `tablenm'exp ""
				
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifpov hwdifblk ${controls} prop_pov ${state}, ///
				${options}
			di e(cmdline)
			di _n
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb3`o'", replace)

		}
		* table
		estout tab1c10${g}* using "Results/sosina_weathers_tabb3-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(``tablenm'exp') ///	
			label delimiter(",") title("Table B3.`Race' Expenditure Disparities")
	 
}

********************************************************************************
* TABLE B4
********************************************************************************
if `tabb4' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	*change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"

		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* reduced sample for missing controls
		keep if red_samp == 1
		************************************************************************
		
		* run models - dollar difference, standardized**************************
		* just exposure to white seg
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c2"
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb4b`o'", replace)
		}
		
		* run models - dollar difference, standardized**************************
		* just exposure to white and exposure to blk/hsp seg 
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c3"
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb4c`o'", replace)
		}
		
		* run models - dollar difference, standardized**************************
		* just exposure poverty seg
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c4"
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifpov ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb4d`o'", replace)
		}

		* run models - dollar difference, standardized**************************
		* just exposure to white and exposure to poverty seg
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c5"
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifpov ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb4e`o'", replace)
		}
		
		
	****************************************************************************
		*Make tables	
		
		estout tab1c2${g}* using "Results/sosina_weathers_tabb4-${g}-blk_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B4.${Race} Expenditure Disparities")

		estout tab1c3${g}* using "Results/sosina_weathers_tabb4-${g}-blk-oth_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B4.${Race} Expenditure Disparities")
		
		estout tab1c4${g}* using "Results/sosina_weathers_tabb4-${g}-pov_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B4.${Race} Expenditure Disparities")
		
		estout tab1c5${g}* using "Results/sosina_weathers_tabb4-${g}-blk-pov_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B4.${Race} Expenditure Disparities")
}

********************************************************************************
* TABLE B5
********************************************************************************
if `tabb5' == 1{
	****************************************************************************
	* HISPANIC MODELS
	****************************************************************************
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
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* reduced sample for missing controls
		keep if red_samp == 1
		************************************************************************
		
		* run models - dollar difference, standardized**************************
		* just exposure to white seg
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c2"
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb5b`o'", replace)
		}
		
		* run models - dollar difference, standardized**************************
		* just exposure to white and exposure to blk/hsp seg 
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c3"
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifblk ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb5c`o'", replace)
		}
		
		* run models - dollar difference, standardized**************************
		* just exposure poverty seg
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c4"
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifpov ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb5d`o'", replace)
		}

		* run models - dollar difference, standardized**************************
		* just exposure to white and exposure to poverty seg
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "tab1c5"
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifpov ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb5e`o'", replace)
		}
		
		
	****************************************************************************
		*Make tables	
		estout tab1c2${g}* using "Results/sosina_weathers_tabb5-${g}-hsp_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B5.${Race} Expenditure Disparities")

		estout tab1c3${g}* using "Results/sosina_weathers_tabb5-${g}-hsp-oth_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B5.${Race} Expenditure Disparities")
		
		estout tab1c4${g}* using "Results/sosina_weathers_tabb5-${g}-pov_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B5.${Race} Expenditure Disparities")
		
		estout tab1c5${g}* using "Results/sosina_weathers_tabb5-${g}-hsp-pov_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B5.${Race} Expenditure Disparities")
}

********************************************************************************
* TABLE B6
********************************************************************************
if `tabb6' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	global g3 "blk"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_no-cwi_${date}", clear //use no cwi file
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
		
		* split sample decreasing trend*****************************************
		local tablenm "tab1c9"
		local `tablenm'exp ""
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifpov bwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			di e(cmdline)
			di _n
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb6`o'", replace)

		}
		
		* table
		estout tab1c9${g}* using "Results/sosina_weathers_tabb6-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(``tablenm'exp') ///	
			label delimiter(",") title("Table B6.`Race' Expenditure Disparities")
	 
	****************************************************************************
	*HISPANIC MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Hispanic-White"
	global g "hw"
	global g3 "hsp"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_no-cwi_${date}", clear //use no cwi file
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
		
		* split sample segregation trend decreasing*****************************
		local tablenm "tab1c9"
		local `tablenm'exp ""
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifpov hwdifblk ${controls} prop_pov ${state}, ///
				${options}
			di e(cmdline)
			di _n
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local `tablenm'exp "``tablenm'exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb6`o'", replace)

		}
		
		* table
		estout tab1c9${g}* using "Results/sosina_weathers_tabb6-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(``tablenm'exp') ///	
			label delimiter(",") title("Table B6.`Race' Expenditure Disparities")

}

********************************************************************************
* TABLE B7
********************************************************************************
if `tabb7' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************

		* run models - dollar differences****************************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp 	${g}ddexp_admin" 
		local outcomes "`outcomes' ${g}ddexp_infra 		${g}ddexp_instr"
		local outcomes "`outcomes' ${g}ddexp_social 	${g}ddexp_other"
		
		local tablenm "tab1b"
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifpov bwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb7`o'", replace)

		}
		
		* table
		estout tab1b${g}* using "Results/sosina_weathers_tabb7-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B7.`Race' Expenditure Disparities")
					
	****************************************************************************
	* HISPANIC MODELS
	****************************************************************************
	*change for different race models
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
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - dollar differences***************************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp 	${g}ddexp_admin" 
		local outcomes "`outcomes' ${g}ddexp_infra 		${g}ddexp_instr"
		local outcomes "`outcomes' ${g}ddexp_social 	${g}ddexp_other"
		
		local tablenm "tab1b"
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifpov hwdifblk ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb7`o'", replace)
		}
		
		* table
		estout tab1b${g}* using "Results/sosina_weathers_tabb7-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B7.`Race' Expenditure Disparities")
}

********************************************************************************
* TABLE B8
********************************************************************************
if `tabb8' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - wht race seg*********************************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "extra1"
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifwht bwdifpov bwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb8`o'", replace)

		}
		
		* table
		estout extra1${g}* using "Results/sosina_weathers_tabb8-${g}_${date}.csv", ///
		replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
		stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
		labels("N" "R-squared" "F" "Prob > F")) ///
		mlabel(`exp') ///	
		label delimiter(",") title("Table B8.`Race' Expenditure Disparities")
			
	****************************************************************************
	* HISPANIC MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Kispanic-White"
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
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - wht race seg*********************************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}ddexp_totexp_std 	${g}ddexp_admin_std" 
		local outcomes "`outcomes' ${g}ddexp_infra_std 		${g}ddexp_instr_std"
		local outcomes "`outcomes' ${g}ddexp_social_std 	${g}ddexp_other_std"
		
		local tablenm "extra1"
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifwht hwdifpov hwdifblk ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
		parmest, saving("Results/Estimates/tabb8`o'", replace)
		}		
		
		* table
		estout extra1${g}* using "Results/sosina_weathers_tabb8-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.2f)) se(par([ ]) fmt(%10.2f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table B8.`Race' Expenditure Disparities")
		
}

********************************************************************************
* TABLE B9
********************************************************************************
if `tabb9' == 1{
	****************************************************************************
	* BLACK MODELS
	****************************************************************************
	* change for different race models
	global Race ""
	global Race "Black-White"
	global g "bw"
	****************************************************************************
	global controls ""
	global controls "${controls} ${g}difpsch ${g}difspec ${g}difell"
	global controls "${controls} ${g}difcity ${g}difothgeo"

	global state ""
	global state "prop_black prop_hisp prop_asian prop_ind i.year"

	global options ""
	global options "i(imp_fips) fe vce(cluster imp_fips)"
	 
		************************************************************************
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - difference of proportions********************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}totexp 	${g}admin" 
		local outcomes "`outcomes' ${g}infra 	${g}instr"
		local outcomes "`outcomes' ${g}social 	${g}other"
		
		local tablenm "tab2"
		
		foreach o of local outcomes {
		
			xtreg `o' bwdifblk bwdifpov bwdifhsp ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb9`o'", replace)

		}
		
		* table
		estout tab2${g}* using "Results/sosina-weathers_tabb9-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.3f)) se(par([ ]) fmt(%4.3f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table 2.`Race' Expenditure Disparities")

	****************************************************************************
	* HISPANIC MODELS
	****************************************************************************
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
		use "15_year_sample_state_${date}", clear
		estimates clear
		
		* fix the sample for the speced/ell comparison
		keep if red_samp == 1
		************************************************************************
		
		* run models - difference of proportions********************************
		local exp ""
		
		local outcomes ""
		local outcomes "`outcomes' ${g}totexp 	${g}admin" 
		local outcomes "`outcomes' ${g}infra 	${g}instr"
		local outcomes "`outcomes' ${g}social 	${g}other"
		
		local tablenm "tab2"
		
		foreach o of local outcomes {
		
			xtreg `o' hwdifhsp hwdifpov hwdifblk ${controls} prop_pov ${state}, ///
				${options}
			Test e(cmdline) "${options}" "`o'"
			fstat `r(F)' `r(p)'
			estimates store `tablenm'`o'
			local lab: variable label `o'
			local exp "`exp' `"`lab'"'"
			parmest, saving("Results/Estimates/tabb9`o'", replace)

		}
		
		* table
		estout tab2${g}* using "Results/sosina-weathers_tabb9-${g}_${date}.csv", ///
			replace cells(b(star fmt(%10.3f)) se(par([ ]) fmt(%4.3f))) ///
			stats(N r2 Fstat Fstatpval, fmt(%4.0f %4.3f %4.3f %4.3f) /// 
			labels("N" "R-squared" "F" "Prob > F")) ///
			mlabel(`exp') ///	
			label delimiter(",") title("Table 2.`Race' Expenditure Disparities")
			
}

********************************************************************************
* FIGURE B1
********************************************************************************
if `figb1' == 1{
		*set xsize and ysize
		global xsize "9"
		global ysize "6"
		//these values are based on the amount of space left on a page with 1-inch 
		//margins after adding a figure title but no figure notes

	****************************************************************************
	* OPEN FILE
	****************************************************************************

		*import fips labels
		import excel "fips.xlsx", clear firstrow
		rename fips imp_fips
		keep imp_fips postal

		*merge fips labels to clean dataset
		merge 1:m imp_fips using "15_year_sample_state_${date}.dta"

		*label fips and drop observations not in sample
		label values imp_fips imp_fips

		keep if red_samp == 1
			
	****************************************************************************
	* CALCULATE RESIDUALIZED CORRELATIONS
	****************************************************************************
		*b-w		
		*regress racial segregation measure on state and year FEs; take residual
		qui reg bwdifblk i.imp_fips i.year
		predict residbwsegr, residuals

		*regress racial SES disparities on state and year FEs; take residual
		qui reg bwdifpov i.imp_fips i.year
		predict residbwsegp, residuals

		*look at corr of of the residuals
		corr residbwsegr residbwsegp	
		local bwcorr: display %9.3fc = `r(rho)'
		di "`bwcorr'"
		
		*h-w
		*regress racial segregation measure on state and year FEs; take residual
		qui reg hwdifhsp i.imp_fips i.year
		predict residhwsegr, residuals

		*regress racial SES disparities on state and year FEs; take residual
		qui reg hwdifpov i.imp_fips i.year
		predict residhwsegp, residuals

		*look at corr of of the residuals
		corr residhwsegr residhwsegp
		local hwcorr: display %9.3fc = `r(rho)'
		di "`hwcorr'"
		
	****************************************************************************
	local blk1 "227 26 28%80"	  	//red
	local blk2 "255 127 0%80"	  	//orange
	local blk3 "253 187 132%80"		//medium orange

	local hsp1 "31 120 180%80"	  	//blue
	local hsp2 "178 223 138%80"	  	//green
	local hsp3 "168 221 181%80"		//medium teal
		
	* residualized correlations - bl and hi on separate graphs, no aweight

	* black
	twoway (scatter residbwsegr residbwsegp, ///
				msymbol(O) mfcolor("`blk2'") msize(small) ///
				mlwidth(vthin) mlcolor(gs1%50)) ///
		, ///
		text(0.3 0.03 "r = `bwcorr'", size(small)) ///
		title("Black-White", size(medium)) ///
		yline(0,lc(black) lw(thin)) ///
		yscale(titlegap(*0)) ///
		ylabel(#10, angle(horizontal) nogrid format(%9.2f)) ///
		ytitle("") ///
		xlabel(#10, format(%9.2f)) ///
		xtitle("") ///
		legend(off) ///
		plotregion(color(white) margin(2 2 2 2)) ///
		graphregion(color(white) margin(0 2 0 0)) ///
		name(black, replace)

	* hispanic
	twoway (scatter residhwsegr residhwsegp, ///
				msymbol(O) mfcolor("`hsp2'") msize(small) ///
				mlwidth(vthin) mlcolor(gs1%50)) ///
		, ///
		text(0.3 0.03 "r = `hwcorr'", size(small)) ///
		title("Latinx-White", size(medium)) ///
		yline(0,lc(black) lw(thin)) ///
		yscale(titlegap(*0)) ///
		ylabel(#10, angle(horizontal) nogrid format(%9.2f)) ///
		ytitle("") ///
		xlabel(#10, format(%9.2f)) ///
		xtitle("") ///
		legend(off) ///
		plotregion(color(white) margin(2 2 2 2)) ///
		graphregion(color(white) margin(0 2 0 0)) ///
		name(hispanic, replace)

	****************************************************************************
	graph combine black hispanic, ///
		xcommon ycommon ///
		title("") ///
		b1title("Poverty Segregation Residuals", size(small)) ///
		l2title("Racial Segregation Residuals", ///
			position(9) size(small) orientation(vertical)) ///
		plotregion(c(white) margin(0 0 0 0)) ///		//outer box
		graphregion(c(white) margin(0 2 0 0))  ///		//inner box
		xsize(${xsize}) ysize(${ysize}) ///
		imargin(0 2 0 0)

		
	graph save "Results/sosina-weathers_figb1_${date}.gph", replace
	graph export "Results/sosina-weathers_figb1_${date}.png", as(png) replace
	window manage close graph _all
}
