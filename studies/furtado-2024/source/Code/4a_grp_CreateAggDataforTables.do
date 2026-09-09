/*This dofile makes aggregate data(CZ level) for the tables beyond the baseline.*/  

* Stata version: 17.0 MP

cd $ResultD // Change your default workspace 

** Table 2 goes first, since Table 1 is based on Table 2's results.
***********************************************
* Prepare data for Table 2 Baseline Regression Data
***********************************************
use "FBsampleCZ", clear 
run $wkdir/collapsedifs.do
save "Ready4RegressBaseline", replace 

**********************************************
* Prepare data for Table 1 Descriptive Statistics Data
***********************************************
set more off
use "Ready4RegressBaseline.dta", clear
keep year t2 czone d_tradeusch_pw_adh d_tradeotch_pw_lag_adh
sort year
by year: egen p25 = pctile(d_tradeusch_pw_adh), p(25) // Q1 of d_tradeusch_pw_adh 
by year: egen p50 = pctile(d_tradeusch_pw_adh), p(50) // Q2 of d_tradeusch_pw_adh
by year: egen p75 = pctile(d_tradeusch_pw_adh), p(75) // Q3 of d_tradeusch_pw_adh
save "import_exposure_usch.dta", replace

use "import_exposure_usch.dta", clear
* In each year, we define heavily affect CZs if d_tradeusch_pw_adh > 50th quantile.
gen heavy = (d_tradeusch_pw_adh > p50) 
keep year czone heavy t2
save "heavy_import_expo_dscrpt.dta", replace

use "Ready4RegressBaseline.dta", clear
merge m:1 t2 czone using "heavy_import_expo_dscrpt.dta"
drop _merge // all matched 1432 obs.
save "Ready4RegressBaseline.dta", replace

***********************************************
* Prepare data for Table 3,4 Employment in Different Occupations
***********************************************

run $wkdir/4b_oralScore_table3&4.do

***********************************************
* Prepare data for Table 5, Heterogeneity
***********************************************

/* Panel A: Heterogeneity by English Fluency Major */

** Ready4RegressBaseline has all the variables needed

/* Panel B: heterogeniety by Race */

** generate 10-year equivalent changes of interested variables for different ethnic groups: 1: white, 2: black, 3: asian, 4: hispanic
cd $ResultD
foreach i in 1 2 3 4 {
	use FBsampleCZ.dta, clear 
    keep if hetero_race == `i' 	
	run $wkdir/collapsedifs.do
    save "Ready4Regress_race_`i'.dta", replace 
	}

* calculate the subgroup obs numbers, and the average obs numbers.
foreach i in 1 2 3 4 {
	use Ready4Regress_race_`i'.dta, clear 
    keep czone 
	duplicates drop
    save "race_`i'_cz.dta", replace 
	}
foreach i in 1 2 3 4 {
	use FBsampleCZ.dta, clear 
    keep if hetero_race == `i' 
	gen pop = 1 
    egen obs_nmbr_wt = total(pop*afactor),  by(czone year)
	merge n:1 czone using "race_`i'_cz.dta"
	drop if _merge != 3
	keep czone year obs_nmbr_wt
	duplicates drop
	egen tot_obs = total(obs_nmbr_wt)
	egen ave_obs = mean(obs_nmbr_wt)
	drop if year ==2007
    save "Rawobs_race_`i'.dta", replace
	}
foreach i in 1 2 3 4 {
	use "Ready4Regress_race_`i'.dta", clear 
    merge 1:1 czone year using "Rawobs_race_`i'.dta"
	drop if _merge!= 3
	drop _merge
    save "Ready4Regress_race_`i'_samplesize.dta", replace 
	}

/* Panel C: Education  */
foreach i in 0 1 { 
		use FBsampleCZ.dta, clear 
		keep if edu_hs==`i' 
		run $wkdir/collapsedifs.do
		save Ready4Regress_eduLS_`i'.dta, replace
}
***********************************************
* Prepare data for Table 6 Edu Enrollment data-- the low skilled sample (non-English speaking immigrants VS Natives) 
***********************************************

run $wkdir/4c_NativeEnroll_table6.do

***********************************************
* Prepare data for Table 7, population change
***********************************************
run $wkdir/4d_populationChange_table7.do

* The following data for low-skill immigrants from English speaking countries and arrive after 18
* is created by the do file "4d_populationChange_table7.do". The pre-trend population changes are named as "d_pop_..." 

cd $ResultD
set more off
use OldEngImm_sampleCZ, clear 
run $wkdir/collapsedifs.do
merge 1:1 czone t2 using d_pop_80_oldENGsample
drop if _merge != 3
drop _merge 
save temp_90_cz_oldEngImm, replace

use OldEngImm_sampleCZ, clear 
run $wkdir/collapsedifs.do
merge 1:1 czone t2 using d_pop_90_oldENGsample
drop if _merge != 3
drop _merge 
append using temp_90_cz_oldEngImm
save Ready4Regress_oldEngImm.dta, replace
erase temp_90_cz_oldEngImm.dta

* low-skill immigrants from non-English speaking countries, arrive after 18
use FBsampleCZ,  clear // this is created from "3_CommutingZone.do"
save temp_90_07_cz_AllNEngImm.dta, replace
run $wkdir/collapsedifs.do
merge 1:1 czone t2 using d_pop_80
drop if _merge != 3
drop _merge 
save temp_90_cz_AllNEngImm.dta, replace

use FBsampleCZ,  clear // this is created from "3_CommutingZone.do"
save temp_90_07_cz_AllNEngImm.dta, replace
run $wkdir/collapsedifs.do
merge 1:1 czone t2 using d_pop_90.dta
drop if _merge != 3
drop _merge
append using temp_90_cz_AllNEngImm.dta
save Ready4Regress_AllNEngImm.dta, replace

erase temp_90_cz_AllNEngImm.dta

* split by goodeng:
foreach i in 0 1 { 
	use "temp_90_07_cz_AllNEngImm.dta",  clear   //this is created above 
	keep if goodeng == `i' 
	run $wkdir/collapsedifs.do
	save "Ready4Regress_AllNEngImm_goodeng`i'.dta", replace 
	}

* Bad speaker, merge with the lag population change 	
use Ready4Regress_AllNEngImm_goodeng0.dta , replace
merge 1:1 czone t2 using d_pop_80_bad.dta
drop if _merge != 3
drop _merge 
merge 1:1 czone t2 using d_pop_80.dta
drop if _merge != 3
drop _merge
save temp.dta, replace

use Ready4Regress_AllNEngImm_goodeng0.dta , replace
merge 1:1 czone t2 using d_pop_90_bad.dta
drop if _merge != 3
drop _merge 
merge 1:1 czone t2 using d_pop_90.dta
drop if _merge != 3
drop _merge
append using temp.dta
save Ready4Regress_AllNEngImm_goodeng0.dta, replace
erase temp.dta

** Good speaker, merge with the lag population change
use Ready4Regress_AllNEngImm_goodeng1.dta , replace
merge 1:1 czone t2 using d_pop_80_good.dta
drop if _merge != 3
drop _merge 
merge 1:1 czone t2 using d_pop_80.dta
drop if _merge != 3
drop _merge
save temp.dta, replace

use Ready4Regress_AllNEngImm_goodeng1.dta , replace
merge 1:1 czone t2 using d_pop_90_good.dta
drop if _merge != 3
drop _merge 
merge 1:1 czone t2 using d_pop_90.dta
drop if _merge != 3
drop _merge
append using temp.dta
save Ready4Regress_AllNEngImm_goodeng1.dta, replace
erase temp.dta


***********************************************
* Prepare data for Table 8, Impact of Chinese Imports on Changes in Demographic Composition:
* Data is already created, the same as the one created in prepare data for Table 2
***********************************************

***********************************************
* Prepare data for Table 9, Migration
***********************************************
** 4e_migartionIndiv_table9.do generates the individual level data set needed below.
run $wkdir/4e_migartionIndiv_table9.do
***********Panel A Move Out of Past CZ***************
use "temp_80_00_cz_5yrsago.dta",  clear 
** Assigning people to CZs they lived in 5 years ago by renaming czone5ago as czone.
rename czone current_czone
rename czone5ago czone
run $wkdir/collapsedifsmig_80base.do
rename czone czone5ago 
save "Ready4Regress_czmigpast_moveout_80_00.dta", replace 
* split by goodeng:
foreach i in 0 1 { 
	use "temp_80_00_cz_5yrsago.dta",  clear   
	keep if goodeng == `i' 
	rename czone current_czone 
	rename czone5ago czone  
	run $wkdir/collapsedifsmig_80base.do
	rename czone czone5ago 
	save "Ready4Regress_czmigpast_moveout_80_00_goodeng`i'.dta", replace 
	}

***********Panel B Move In Current CZ***************
use "temp_80_00_cz_5yrsago.dta",  clear
run $wkdir/collapsedifsmig_80base.do
* all sample included:
save "Ready4Regress_czmigcurrent_moveout_80_00.dta", replace 
* split by goodeng:
foreach i in 0 1 { 
	use "temp_80_00_cz_5yrsago.dta",  clear  
	keep if goodeng == `i' 
	run $wkdir/collapsedifsmig_80base.do
	save "Ready4Regress_czmigcurrent_moveout_80_00_goodeng`i'.dta", replace 
	}

***********************************************
* Prepare data for Table 10. Years in the US 
***********************************************
foreach i in  yrusintvl_10plus  yrusintvl_9 yrusintvl_7 yrusintvl_5 yrusintvl_1 { 
	use FBsampleCZ.dta, clear 
	keep if  `i' == 1
    run $wkdir/collapsedifs.do
	save "Ready4Regress_`i'.dta", replace 
	}
***********************************************
* Prepare data for Table 11, Heterogeneity by Recent Migration History 
***********************************************
** different types of migration in the past 5 years (same house, same state, different state, and abroad)**
*1. Same house, 2. Same state 3. Different state 4. Different country 
foreach i in 1 2 3 4 {
	use FBsampleCZ_80base.dta, clear 
    keep if migrate5 == `i'
	run $wkdir/collapsedifs_80base.do
	replace t2 = 1 if t2==0
	replace t2= 0 if t2==-1
	merge 1:1 czone year using $ResultD/1980_femaleEmpShare.dta
	drop if _merge ==2
	drop _merge 
	merge 1:1 czone year using $ResultD/1980_manuEmpShare.dta
	drop if _merge ==2
	drop _merge 
	merge 1:1 czone year using $ResultD/1980_colEduShare.dta
	drop if _merge ==2
	drop _merge 

	replace l_shind_manuf_cbp=manu_share if missing(l_shind_manuf_cbp)
	replace l_sh_empl_f=emp_f if missing(l_sh_empl_f)
	replace l_sh_popedu_c=edu_c if missing(l_sh_popedu_c)
    save "Ready4Regress_migrate_`i'_80.dta", replace 
	}
	
***********************************************
* Prepare data for Appendix Table A.1.1   
***********************************************	
* data already exists.

***********************************************
* Prepare data for Appendix Table A.1.2   
***********************************************	
* data already exists.


***********************************************
* Prepare data for Appendix Table A.1.4 Placebo   
***********************************************	
use "Ready4RegressBaseline.dta", clear
keep if t2 == 1 // Keep 2000-2007 change in import exposure.
keep czone d_tradeusch_pw_adh d_tradeotch_pw_lag_adh
rename d_tradeusch_pw_adh d_tradeusch_pw_adh_future
rename d_tradeotch_pw_lag_adh d_tradeotch_pw_lag_adh_future
save "ipw_placebo.dta", replace

use "Ready4RegressBaseline.dta", clear
keep if t2 == 0 // Keep 1990 characteristics.
merge 1:1  czone using "ipw_placebo.dta"
drop _merge
save "placebo_90_10_cz_character_ready_reg.dta", replace
erase "ipw_placebo.dta"

***********************************************
* Prepare data for Appendix Table A.1.5 effect on manufacturing employment
***********************************************

run $wkdir/4f_native_immig_manuEmp.do

***********************************************
* Prepare data for Appendix Table A.1.6 Gender  
***********************************************	

cd $ResultD
foreach i in 0 1 { 
		use FBsampleCZ.dta, clear 
		keep if female==`i' 
		run $wkdir/collapsedifs.do
		save Ready4Regress_female_`i'.dta, replace
}

***********************************************
* Prepare data for Appendix Table A.1.7 Robustness with Different Sample Size 
***********************************************	

use "FBsampleCZ", clear
gen pop = 1 
egen obs_nmbr_wt = total(pop*afactor),  by(czone year)
drop pop
save "temp_r1_wt.dta", replace
* drop the CZs with few observations, check the robustness.
foreach i in 5 10 50 100{
    use "temp_r1_wt.dta"
    drop if obs_nmbr_wt < `i'
	save "fewobs_wt_cz_`i'.dta",replace
	run $wkdir/collapsedifs.do 
    save "Ready4RegressBaseline_fewobs_wt_`i'.dta", replace 
	}

***********************************************
* Prepare data for Appendix Figure A.2.1 Occupational Distribution of Low Education Immigrants vs. Low Education Natives
***********************************************	
run $wkdir/4g_native_immig_empPlot.do

***********************************************
* Prepare data for Appendix Figure A.2.2 Data will be created in 5_grp_MakeTables.do
***********************************************	

***********************************************
* Prepare data for Appendix Figure A.2.3 Employment Distribution of Low Education Immigrants by Different Types of Educational Attainment 
***********************************************	

cd $ResultD
use "FBsampleCZ.dta", clear
keep if year == 1990
keep if edu_hs == 1
collapse (mean) occu1=manu_d occu2=ser_d occu3=farm_d occu4=unemp occu5=notlf [aw=czperwt]
gen group = 1
save hs_occu.dta, replace

use "FBsampleCZ.dta", clear
keep if year ==1990
keep if edu_hs ==0
collapse (mean) occu1=manu_d occu2=ser_d occu3=farm_d occu4=unemp occu5=notlf [aw=czperwt]
gen group = 0
save lhs_occu.dta, replace

append using hs_occu.dta
reshape long occu, i(group) j(ind)
reshape wide occu, i(ind) j(group)
drop if ind>3
save hs_nhs_occu_change.dta, replace

erase hs_occu.dta
erase lhs_occu.dta

***********************************************
* Prepare data for Appendix Table A.3.1 & A.3.2
***********************************************	
use "Ready4RegressBaseline.dta", clear 
keep czone year
save cz_consistant.dta, replace

use $OriginalD/Lshares.dta, clear  // download from BHJ (2022) replication file BHJ, path: BHJ/ADH/Data
merge n:1 year czone using cz_consistant
drop if _merge !=3
drop _merge
save Lshares_revise.dta, replace

use $OriginalD/Lshares_wide.dta, clear // download from BHJ (2022) replication file BHJ, path: BHJ/ADH/Data
merge 1:1 year czone using cz_consistant
drop if _merge !=3
drop _merge
save Lshares_wide_revise.dta, replace

local outcomes d_goodeng
local adhcontrols  edu_hs age yrsusa race_b race_a race_m race_an race_h race_o female   i.statefip  l_sh_popedu_c l_sh_empl_f  
local aadhp_czcontrols cz_prode_share1991 cz_cap_va1991 cz_log_avg_wage1991 cz_ind_ci_1990 cz_ind_htsh1_1990
local aadhp_czpretrends cz_d_ind_shemp_7691 cz_d_ind_lnavgw_7691 

// the first seven control sets are for Table 4, the last four are for Table C4
local controls1 t2 l_shind_manuf_cbp `adhcontrols'  // including service, start-period manu,  compare to SSIV
local controls2 t2 l_shind_manuf_cbp `adhcontrols' // excluding service, start-period manu, compare to control 1
local controls3 t2 Lsh_manuf  `adhcontrols'  // test including service industry , use lagged manu share , compare to control1 
local controls4 t2 Lsh_manuf `adhcontrols'  // excluding service industry, use lagged manu manu, compare to control 2

local controls5 t2 Lsh_manuf `adhcontrols' Lsh_sicgroup*  // like Acemoglu et al. (2016, AADHP) col 2
local controls6 t2 Lsh_manuf `adhcontrols' `aadhp_czcontrols' // AADHP col 3
local controls7 t2 Lsh_manuf ind_share* `adhcontrols' // AADHP col 8

local controls8 t2 Lsh_manuf `aadhp_czpretrends' `adhcontrols' // AADHP col 4
local controls9 t2 Lsh_manuf Lsh_sicgroup* `aadhp_czcontrols' `adhcontrols' // AADHP col 5
local controls10 t2 Lsh_manuf Lsh_sicgroup* `aadhp_czpretrends' `adhcontrols' // AADHP col 6
local controls11 t2 Lsh_manuf Lsh_sicgroup* `aadhp_czpretrends' `aadhp_czcontrols' `adhcontrols' // AADHP col 7

// Generate the industry-level dataset
use "Ready4RegressBaseline.dta", clear 
merge 1:1 year czone using $OriginalD/location_level.dta  // download from BHJ (2022) replication file BHJ, path: BHJ/ADH/Data
drop if _merge !=3
drop _merge

merge 1:1 czone year using Lshares_wide_revise, assert(3) nogen //only for col 7 controls

gen x90_ = x*(year==1990)
gen x00_ = x*(year==2000)

ssaggregate `outcomes' z x x90_ x00_ zAUS-zNZL [aw=cell_wt], ///
	n(sic87dd) t(year) s(ind_share) sfilename(Lshares_revise) l(czone) addmissing  /// 
	controls("`controls1'" "`controls2'" "`controls3'" "`controls4'" "`controls5'" "`controls6'" "`controls7'" "`controls8'" "`controls9'" "`controls10'" "`controls11'") 

/* Could do the same in wide format instead (after merging in Lshares_wide)
ssaggregate `outcomes' z x x90_ x00_ zAUS-zNZL [aw=wei], n(sic87dd) t(year) s(ind_share) addmissing ///
	controls("`controls1'" "`controls2'" "`controls3'" "`controls4'" "`controls5'" "`controls6'" "`controls7'" "`controls8'" "`controls9'" "`controls10'" "`controls11'") 
*/

replace sic87dd = 0 if mi(sic87dd)
merge 1:1 sic87dd year using $OriginalD/shocks, assert(1 3) nogen // sic87dd==0 is _m==1 // download from BHJ (2022) replication file BHJ, path: BHJ/ADH/Data
merge m:1 sic87dd using $OriginalD/industries, assert(1 3) nogen // download from BHJ (2022) replication file BHJ, path: BHJ/ADH/Data
foreach v of varlist g* sic3 sic2 sicgroup {
	replace `v'= 0 if sic87dd==0
}

gen g90 = g*(year==1990)
gen g00 = g*(year==2000)

label var g "Industry China Shock (binned)"
forvalues r = 1/11 {
	label var d_goodeng`r' "Avg Good Eng Speaker Share Residual"
	label var x`r' "Avg Regional China Shock Residual"
}	
tsset sic87dd year, delta(10)
save industry_level_ext, replace // This extended industry-level file includes the non-manufacturing industry (for col.1)

drop if sic87dd==0
save industry_level, replace // 



