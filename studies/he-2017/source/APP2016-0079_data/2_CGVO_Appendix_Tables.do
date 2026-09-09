*==============================================================================* 
* Project: CGVO and Rural Development in China                                 *
* Date:   December 2016                                                        *
* Please contact Guojun He (gjhe@ust.hk) for any coding errors                 * 
*==============================================================================* 

*** Change to your own directories ***
global path C:\Users\pcadmin\Dropbox\Projects\Village_Officials\AEJ-Acceptance\Data_and_Codes\Data
global result C:\Users\pcadmin\Dropbox\Projects\Village_Officials\AEJ-Acceptance\Data_and_Codes\Results
global graph C:\Users\pcadmin\Dropbox\Projects\Village_Officials\AEJ-Acceptance\Data_and_Codes\Graphs




***** CGVO and Rural Development *****
* II. Appendix Tables ***
* Appendix Tables A1-A2. Determinants of CGVO assignment
* Apeendix Tables D1-D2. Robustness Check I
* Apeendix Tables E1-E2. Robustness Check II
* Apeendix Tables F1-F2. Robustness Check III

*==============================================================================*
*==============================================================================*
*==============================================================================*


*** Appendix Tables A1-A2: Determinants of CGVO assignment: panel survey
use $path/workfile_AEJ, clear
** 2006 measures 
foreach y of var l_subsidy_rate l_poor_reg_rate l_poor_housing_rate enroll_rate l_village_pop l_income_pc gov_officials high_gov_quality terrain econ_zone suburb town_center poor_village precipitation temperature{
gen `y'_06 = `y' if year ==2006
by new_id, sort: egen `y'_06_mean = mean(`y'_06)
drop `y'_06
rename `y'_06_mean `y'_06
}

sort new_id year
xtset new_id year


* eventually treated villages
by v_fe, sort: egen cgvo_final = sum(cgvo)
replace cgvo_final = 1 if cgvo_final>0

sort new_id year

** Regressions 
cap erase $result/App_T_A1.xml
cap erase $result/App_T_A1.txt

*** Cross-sectional Estimates ***

*** population and income
logit cgvo_final l_village_pop_06 l_income_pc_06 if year == 2006 , robust
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append

*** population and income + outcome variables 
logit cgvo_final l_village_pop_06 l_income_pc_06 l_poor_housing_rate_06 l_subsidy_rate_06 l_poor_reg_rate_06 if year == 2006 , robust
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append

*** population and income + outcome variables + gov
logit cgvo_final l_village_pop_06 l_income_pc_06 l_poor_housing_rate_06 l_subsidy_rate_06 l_poor_reg_rate_06 gov_officials high_gov_quality  if year == 2006 , robust
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append

*** population and income + outcome variables + gov + other time invariant factors 
logit cgvo_final l_village_pop_06 l_income_pc_06 l_poor_housing_rate_06  l_subsidy_rate_06 l_poor_reg_rate_06 gov_officials high_gov_quality terrain_06 econ_zone_06 suburb_06 town_center_06 poor_village_06 precipitation_06 temperature_06 if year == 2006 , robust 
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append


*** Duration Dependence ***
*** population and income
logit cgvo_occur l_village_pop_06 l_income_pc_06 duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append

*** population and income + outcome variables 
logit cgvo_occur l_village_pop_06 l_income_pc_06 l_poor_housing_rate_06 l_subsidy_rate_06 l_poor_reg_rate_06 duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append

*** population and income + outcome variables + gov
logit cgvo_occur l_village_pop_06 l_income_pc_06 l_poor_housing_rate_06 l_subsidy_rate_06 l_poor_reg_rate_06 gov_officials high_gov_quality  duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append

*** population and income + outcome variables + gov + other time invariant factors 
logit cgvo_occur l_village_pop_06 l_income_pc_06 l_poor_housing_rate_06 l_subsidy_rate_06 l_poor_reg_rate_06 gov_officials high_gov_quality terrain_06 econ_zone_06 suburb_06 town_center_06 poor_village_06 precipitation_06 temperature_06 duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A1 , ctitle(poly+level) excel dec(2) append


*==============================================================================*
*==============================================================================*
*==============================================================================*


*** Shocks *** 
use $path/workfile_AEJ, clear
sort new_id year
xtset new_id year


* eventually treated villages
by v_fe, sort: egen cgvo_final = sum(cgvo)
replace cgvo_final = 1 if cgvo_final>0

sort new_id year


cap erase $result/App_T_A2.xml
cap erase $result/App_T_A2.txt

* changes 
foreach y of var subsidy_rate poor_reg_rate poor_housing_rate enroll_rate village_pop income_pc gov_officials high_gov_quality {
gen `y'_diff = `y'-L.`y'
gen `y'_change = L.`y'_diff
}


replace village_pop_diff = village_pop_diff/1000
replace income_pc_diff = income_pc_diff/1000
replace poor_housing_rate_diff = poor_housing_rate_diff/100
replace subsidy_rate_diff = subsidy_rate_diff/100
replace poor_reg_rate_diff = poor_reg_rate_diff/100
replace gov_officials_diff = gov_officials_diff/100
replace high_gov_quality_diff = high_gov_quality_diff/100

***** time-varying factors
logit cgvo_occur L.village_pop_diff L.income_pc_diff duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A2 , ctitle(poly+diff) excel dec(2) append

logit cgvo_occur L.village_pop_diff L.income_pc_diff L.poor_housing_rate_diff duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A2 , ctitle(poly+diff) excel dec(2) append

logit cgvo_occur L.village_pop_diff L.income_pc_diff L.subsidy_rate_diff duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A2 , ctitle(poly+diff) excel dec(2) append

logit cgvo_occur L.village_pop_diff L.income_pc_diff L.poor_reg_rate_diff duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A2 , ctitle(poly+diff) excel dec(2) append

logit cgvo_occur L.village_pop_diff L.income_pc_diff L.gov_officials_diff duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A2 , ctitle(poly+diff) excel dec(2) append

logit cgvo_occur L.village_pop_diff L.income_pc_diff L.high_gov_quality_diff duration duration2 duration3 duration4 , robust cluster(new_id)
*outreg2 using $result/App_T_A2 , ctitle(poly+diff) excel dec(2) append


*==============================================================================*
*==============================================================================*
*==============================================================================*


use $path/workfile_AEJ, clear

***** Appendix Table D1-D2. Robustness Checks *****
* add province-year fixed effects 
local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"
local prov_year_fe "prov_year*"
* local county_stats "gdp_pc ag_pop_share addedvalue_1st_pc addedvalue_2nd_pc expenditure_pc"

cap erase $result/App_T_D.xml
cap erase $result/App_T_D.txt
** current
foreach y of var l_subsidy_rate l_poor_housing_rate l_poor_reg_rate l_disability_rate{

quietly reg `y' cgvo `v_fe' `prov_year_fe' , cluster (sm)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' cgvo `v_fe' `prov_year_fe' , cluster (v_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

*quietly cgmreg `y' cgvo `v_fe' `prov_year_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' cgvo `v_fe' `prov_year_fe' , cluster (prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

*quietly cgmreg `y' cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append



** lag

quietly reg `y' lag_cgvo `v_fe' `prov_year_fe' , cluster (sm)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `prov_year_fe' , cluster (v_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

*quietly cgmreg `y' lag_cgvo `v_fe' `prov_year_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `prov_year_fe' , cluster (prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

*quietly cgmreg `y' lag_cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `prov_year_fe' precipitation temperature, cluster (prov_year_fe)
*outreg2 using $result/App_T_D , ctitle(`y'_fe_prov_year) excel dec(2) drop(`v_fe' `prov_year_fe' o.*) append

}

*==============================================================================*
*==============================================================================*
*==============================================================================*

***** Appendix Table E1-E2. Robustness Checks *****
use $path/workfile_AEJ, clear
**** Drop those villages with CGVOs long time ago **** 
tab new_id if cgvo == 1 & year ==2000 
drop if new_id == 24

tab new_id if cgvo == 1 & year ==2001
tab new_id if cgvo == 1 & year ==2002
tab new_id if cgvo == 1 & year ==2003
drop if new_id == 147

tab new_id if cgvo == 1 & year ==2004
drop if new_id == 65
drop if new_id == 145

tab new_id if cgvo == 1 & year ==2005
tab new_id if cgvo == 1 & year ==2006

cap erase $result/App_T_E.xml
cap erase $result/App_T_E.txt

local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

foreach y of var l_subsidy_rate l_poor_housing_rate l_poor_reg_rate  l_disability_rate{
** current : three different cluster std err
quietly reg `y' cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/App_T_E , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/App_T_E , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

** lagged
quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/App_T_E , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/App_T_E , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_E , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

}


*==============================================================================*
*==============================================================================*
*==============================================================================*


***** Appendix Table F1-F2. Robustness Checks *****

**** Use Alternative CGVOs Dummy as Suggested by a Referee **** 

use $path/workfile_AEJ, clear
sort new_id year
tab cgvo_occur
by new_id, sort: gen cgvo_continue = sum(cgvo_occur) 
tab new_id if  cgvo_continue ~= cgvo
* only 9 villages 

xtset new_id year
gen lag_cgvo_continue = L.cgvo_continue
replace lag_cgvo_continue =0 if lag_cgvo_continue==. 

cap erase $result/App_T_F.xml
cap erase $result/App_T_F.txt

local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

foreach y of var l_subsidy_rate l_poor_housing_rate l_poor_reg_rate l_disability_rate{
** current : three different cluster std err
quietly reg `y' cgvo_continue `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/App_T_F , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo_continue `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/App_T_F , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' cgvo_continue `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo_continue `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' cgvo_continue `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' cgvo_continue `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

** lagged
quietly reg `y' lag_cgvo_continue `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/App_T_F , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo_continue `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/App_T_F , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' lag_cgvo_continue `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo_continue `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' lag_cgvo_continue `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' lag_cgvo_continue `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/App_T_F , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

}

