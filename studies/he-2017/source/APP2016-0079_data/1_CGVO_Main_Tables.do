*==============================================================================* 
* Project: CGVO and Rural Development in China                                 *
* Date:   December 2016                                                        *
* Please contact Guojun He (gjhe@ust.hk) for any coding errors                 * 
*==============================================================================* 


*** Change to your own directories ***

global path .
global result .
global graph .


use $path/workfile_AEJ, clear

/*
***** CGVO and Rural Development *****
*** I. Main Tables ***
* Table 1. Number of CGVOs in China
* Table 2. Summary Stats
* Table 3. How CGVOs Help Rural Households

* Table 4. CGVO and Pro-Poor Policies: Registration Effect
* Table 5. CGVO and Subsidies
* Table 6. Tests for Parallel Trends Assumption
* Table 7. CGVO and Income-Related Measures
* Table 8. CGVO and Rural Governance 
* Table 9. CGVO and Elite Capture

*==============================================================================*
*==============================================================================*
*==============================================================================*

*** Table 1. Number of CGVOs in China
* N/A

*** Table 2. Summary Stats
sum village_pop income_pc subsidy_rate poor_housing_rate poor_reg_rate disability_rate gov_officials high_gov_quality mid_gov_quality low_gov_quality ag_rate business_income_pc fiscal_rev_pc fiscal_exp_pc col_revenue_pc trained_labor_rate safe_water_rate computer_rate med_ins_rate enroll_rate

/*

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 village_pop |      2,773    1755.762    1324.182        200      19343
   income_pc |      2,661    3945.936    2718.168        300      23410
subsidy_rate |      2,102     29.7293    42.85456          0   1161.568
poor_housi~e |      2,417    56.69201    31.34762          0        100
poor_reg_r~e |      2,654     6.55331    10.18974          0        100
-------------+---------------------------------------------------------
disability~e |      1,826    10.59793    10.86952          0   114.6026
gov_offici~s |      2,801    5.960728    3.180728          1         39
high_gov_q~y |      2,801     42.3831    27.44026          0        100
mid_gov_qu~y |      2,801    49.66191    26.66628          0        100
low_gov_qu~y |      2,801    7.954989    14.88212          0        100
-------------+---------------------------------------------------------
     ag_rate |      2,621    74.34609    24.04926          0        100
business_i~c |      2,747    177.9862    1232.998   .1058191   39689.09
fiscal_rev~c |      1,974    5.035611    27.98268          0   448.7276
fiscal_exp~c |      1,584    3.193367    17.58924          0   288.0452
col_revenu~c |      2,162    7.920567    67.34728          0   1590.542
-------------+---------------------------------------------------------
trained_la~e |      2,607    18.62317    21.70422          0        100
safe_water~e |      1,408    79.95204    33.46556          0        100
computer_r~e |      1,471    7.208909    12.77096          0   99.60861
med_ins_rate |      1,320    83.29065    27.57533          0        100
 enroll_rate |      2,369    97.97712    6.764177         10        100
*/


*==============================================================================*
*==============================================================================*
*==============================================================================*



*** Table 3. How CGVOs Help Rural Households ***

*** Poor Households Survey ***
/* The Original Data Set is not provided because it does not belong to the authors. We only provide relevant variables that can be used to reproduce the main results and tables

use $path/community_survey_poor_hhs, clear
rename SAMPLEID id
gen SAMPLEID = substr(id, 1,6)
merge m:1 SAMPLEID using $path/village_temp.dta

keep if _merge==3
drop _merge
keep id F1 F2 F3 f4_1_1 f4_1_2 f4_1_3 f4_1_4 f4_1_5 f4_1_6 f4_1_7 f4_1_8 f4_1_9 f4_1_10
save $path/community_survey_poor_hhs_AEJ, replace
*/

use $path/community_survey_poor_hhs_AEJ, clear

tab F1 
/*
     是否听 |
     过大学 |
     生村官 |      Freq.     Percent        Cum.
------------+-----------------------------------
     不适用 |          3        0.10        0.10
     不知道 |         16        0.52        0.62
         是 |        603       19.58       20.20
         否 |      2,457       79.80      100.00
------------+-----------------------------------
      Total |      3,079      100.00

*/

keep if F1 ==1 

tab F2
/*
     有没有 |
     大学生 |
       村官 |      Freq.     Percent        Cum.
------------+-----------------------------------
     不知道 |         12        1.99        1.99
         有 |        146       24.21       26.20
       没有 |        445       73.80      100.00
------------+-----------------------------------
      Total |        603      100.00

*/

* keep observations relevant 
* 有大学生村官
keep if F2==1

tab F3
/*

      几次得到大 |
      学生村官帮 |
              助 |      Freq.     Percent        Cum.
-----------------+-----------------------------------
          不知道 |          2        1.37        1.37
             0次 |         95       65.07       66.44
  1-5次（含5次） |         35       23.97       90.41
5-10次（含10次） |          3        2.05       92.47
        10次以上 |         11        7.53      100.00
-----------------+-----------------------------------
           Total |        146      100.00


*/

* 得到过帮助
keep if F3>=2

/*
 tab F4SP

                               其他帮助 |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                     -8 |        137       93.84       93.84
                                 不清楚 |          1        0.68       94.52
                                   关爱 |          1        0.68       95.21
                               关爱老人 |          1        0.68       95.89
                             咨询一类的 |          1        0.68       96.58
                       帮助个人生活好事 |          1        0.68       97.26
             帮忙做一些小事情，有情有义 |          1        0.68       97.95
                             申请低收入 |          1        0.68       98.63
                               直接拿钱 |          1        0.68       99.32
                                 谈谈心 |          1        0.68      100.00
----------------------------------------+-----------------------------------
                                  Total |        146      100.00

申请低收入， 直接拿钱 应该算帮助申请补贴 +2 
咨询一类的 归为政策咨询 +1 

*/

foreach x of var f4_1_1 f4_1_2 f4_1_3 f4_1_4 f4_1_5 f4_1_6 f4_1_7 f4_1_8 f4_1_9{
tab `x' if `x'>=0
}


***** Random Villager Survey *****
/*
use $path/community_survey_residents, clear
tostring SAMPLEID, replace
merge m:1 SAMPLEID using $path/village_temp.dta
keep if _merge==3
keep hhid F1 F2 F3 f4_1 f4_2 f4_3 f4_4 f4_5 f4_6 f4_7 f4_8 f4_9 f4_10
save $path/community_survey_residents_AEJ, replace
*/


use $path/community_survey_residents_AEJ, clear

tab F1
/*
     听说过 |
     大学生 |
     村官吗 |      Freq.     Percent        Cum.
------------+-----------------------------------
     不知道 |          9        0.32        0.32
         有 |      1,138       40.53       40.85
       没有 |      1,661       59.15      100.00
------------+-----------------------------------
      Total |      2,808      100.00
*/

keep if F1 ==1

tab F2

/*
tab F2


     有大学 |
     生村官 |
         吗 |      Freq.     Percent        Cum.
------------+-----------------------------------
     不知道 |         13        1.14        1.14
         有 |         50        4.39        5.54
       没有 |      1,075       94.46      100.00
------------+-----------------------------------
      Total |      1,138      100.00


*/

keep if F2 ==1

tab F3
/*
tab F3

     大学生 |
     村官帮 |
     助次数 |      Freq.     Percent        Cum.
------------+-----------------------------------
     不知道 |          3        6.00        6.00
          0 |         31       62.00       68.00
          1 |          2        4.00       72.00
          2 |          1        2.00       74.00
          3 |          4        8.00       82.00
          4 |          3        6.00       88.00
          5 |          2        4.00       92.00
          9 |          1        2.00       94.00
         10 |          1        2.00       96.00
        100 |          2        4.00      100.00
------------+-----------------------------------
      Total |         50      100.00

*/

keep if F3>=1
foreach x of var f4_1 f4_2 f4_3 f4_4 f4_5 f4_6 f4_7 f4_8 f4_9 f4_10 {
tab `x'  if `x'>=0
}


***** Village Survey *****
/*
use $path/community_survey_village, clear
* related outcomes: 

desc 
fsum D19 D20 D21A D21B D21_1 D21_1SP D22 D23 D24 D25 D25SP D26_1A ///
 D26_1B D26_2A D26_2B D26_3A D26_3B D26_4A D26_4B D26_5A D26_5B D26_6A ///
 D26_6B D26_7A D26_7B D26_8A D26_8B D26_9A D26_9B D26_10A D26_10B D26_11A ///
 D26_11B D26_12A D26_12B D26_13A D26_13B D26_14A D26_14B D26_51A D26_15B ///
 D26_16A D26_16B , f(10.3) stats(n miss mean sd min max) label

fsum I00 I01 I01_1 I01_2 I01_3 I01_4 I01_5 I01_6 I01_7 I01_8 I02 I03A ///
I03B I04 I04_1 I04_1SP I05 I06 I06_1 I07 i08_1 i08_2 i08_3 i08_4 i08_5 ///
i08_6 i08_7 I08SP i09_1 i09_2 i09_3 i09_4 i09_5 i09_6 i09_7 i09_8 I09SP ///
I10 I10_1 I10_2 I10_3 I10_4 I10_5 I10_6 I10_6SP I11 I12 I13 i14_1 i14_2 ///
i14_3 i14_4 i14_5 I14SP I15 I16 i16_1_1 i16_1_2 i16_1_3 i16_1_4 i16_1_5 ///
i16_1_6 i16_1_7 i16_1_8 i16_1_9 i16_1_10 I16_1SP I17_1A I17_1B I17_1C ///
I17_1D I17_1E I17_1ESP I17_2A I17_2B I17_2C I17_2D I17_2E I17_2ESP I17_3A ///
I17_3B I17_3C I17_3D I17_3E I17_3ESP I17_4A I17_4B I17_4C I17_4D I17_4E ///
I17_4ESP I17_5A I17_5B I17_5C I17_5D I17_5E I17_5ESP I17_6A I17_6B I17_6C ///
I17_6D I17_6E I17_6ESP I17_7A I17_7B I17_7C I17_7D I17_7E I17_7ESP I17_8A ///
I17_8B I17_8C I17_8D I17_8E I17_8ESP I17_9A I17_9B I17_9C I17_9D I17_9E ///
I17_9ESP I17_10A I17_10B I17_10C I17_10D I17_10E I17_10ESP I17_11A I17_11B ///
I17_11C I17_11D I17_11E I17_11ESP I17_12A I17_12B I17_12C I17_12D I17_12E ///
I17_12ESP I17_13A I17_13B I17_13C I17_13D I17_13E I17_13ESP I17_14A I17_14B ///
I17_14C I17_14D I17_14E I17_14ESP I17_15A I17_15B I17_15C I17_15D I17_15E ///
I17_15ESP I17_16A I17_16B I17_16C I17_16D I17_16E I17_16ESP I17_17 I17_17A ///
I17_17B I17_17C I17_17D I17_17E I17_17ESP,f(10.3) stats(n miss mean sd min max) label


* village survey
tab D19
keep if D19 == 1

foreach x of var D25 D26_1A D26_1B D26_2A D26_2B D26_3A D26_3B D26_4A D26_4B D26_5A D26_5B D26_6A D26_6B D26_7A D26_7B D26_8A D26_8B D26_9A D26_9B D26_10A D26_10B D26_11A D26_11B D26_12A D26_12B D26_13A D26_13B D26_14A D26_14B D26_51A D26_15B D26_16A D26_16B {
tab `x' if `x'>=0
}

keep SAMPLEID I00 i16_1_1 i16_1_2 i16_1_3 i16_1_4 i16_1_5 i16_1_6 i16_1_7 i16_1_8 i16_1_9 I17_1A I17_2A I17_3A I17_4A I17_5A I17_6A I17_7A I17_8A I17_9A I17_10A I17_11A I17_12A I17_13A I17_14A I17_15A I17_16A 
save $path/community_survey_village_AEJ, replace

*/

use $path/community_survey_village_AEJ, clear

* CGVO survey
tab I00
keep if I00 == 1 
* 185 CGVOs 
foreach x of var i16_1_1 i16_1_2 i16_1_3 i16_1_4 i16_1_5 i16_1_6 i16_1_7 i16_1_8 i16_1_9 I17_1A I17_2A I17_3A I17_4A I17_5A I17_6A I17_7A I17_8A I17_9A I17_10A I17_11A I17_12A I17_13A I17_14A I17_15A I17_16A {
tab `x' if `x'>=0
}

clear



*==============================================================================*
*==============================================================================*
*==============================================================================*



use $path/workfile_AEJ, clear

*/

*** Table 4. CGVO and Pro-Poor Policies: Registration Effect

*** Main Results ***
local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

cap erase $result/T4_registration.xml
cap erase $result/T4_registration.txt

foreach y of var l_poor_reg_rate l_disability_rate {
** current : three different cluster std err
quietly reg `y' cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/T4_registration , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T4_registration , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

** lagged
quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/T4_registration , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T4_registration , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/T4_registration , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

}


*==============================================================================*
*==============================================================================*
*==============================================================================*




*** Table 5. CGVO and Pro-Poor Policies: Subsidies

local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

cap erase $result/T5_main.xml
cap erase $result/T5_main.txt

foreach y of var l_subsidy_rate l_poor_housing_rate {
** current : three different cluster std err
quietly reg `y' cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/T5_main , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T5_main , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

** lagged
quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/T5_main , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T5_main , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

}

*** EDIT BY Donna
eststo clear
eststo: reg l_poor_reg_rate cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
eststo: reg l_poor_reg_rate lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
eststo: reg l_disability_rate cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
eststo: reg l_disability_rate lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
eststo: reg l_subsidy_rate cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
eststo: reg l_subsidy_rate lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

/*
/***** results using balanced panel: used to address one referee's concern. *****
preserve 
keep if l_subsidy_rate !=. & l_poor_housing_rate !=.

local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

cap erase $result/T5_main_balanced.xml
cap erase $result/T5_main_balanced.txt

foreach y of var l_poor_reg_rate l_disability_rate l_subsidy_rate l_poor_housing_rate {
** current : three different cluster std err
quietly reg `y' cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

** lagged
quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

quietly reg `y' lag_cgvo `v_fe' `t_fe', cluster (sm)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe', cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did) excel dec(2) drop(`v_fe' `t_fe' o.*) append
*quietly cgmreg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (v_fe prov_year_fe)
*outreg2 using $result/T5_main_balanced , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

}


restore 

*/



*==============================================================================*
*==============================================================================*
*==============================================================================*

use $path/workfile_AEJ, clear

*** Table 6. Pre-trends Tests

local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

cap erase $result/T6_pre_trends.xml
cap erase $result/T6_pre_trends.txt

foreach y of var l_subsidy_rate l_poor_housing_rate l_poor_reg_rate l_disability_rate {

quietly reg `y' Lead_D4_plus Lead_D3 Lead_D2 D0 Lag_D1 Lag_D2 Lag_D3_plus `v_fe' `t_fe', cluster (v_id)
*outreg2 using $result/T6_pre_trends , excel dec(2) drop(`v_fe' `t_fe' o.*) append

}


*==============================================================================*
*==============================================================================*
*==============================================================================*


*** Table 7. CGVO and Income-Related Measures
use $path/workfile_AEJ, clear

local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

cap erase $result/T7_income.xml
cap erase $result/T7_income.txt

foreach y of var l_income_pc l_ag_rate l_business_income_pc l_fiscal_rev_pc l_fiscal_exp_pc l_col_revenue_pc{
** current : three different cluster std err
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T7_income , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' precipitation temperature o.*) append

** lagged
quietly reg `y' lag_cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T7_income , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' precipitation temperature o.*) append

}


*==============================================================================*
*==============================================================================*
*==============================================================================*


*** Table 8. CGVO and Rural Governance
use $path/workfile_AEJ, clear
local v_fe "v_fe*"
local t_fe "t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11"

cap erase $result/T8_gov.xml
cap erase $result/T8_gov.txt

foreach y of var gov_officials high_gov_quality mid_gov_quality low_gov_quality{
** current : three different cluster std err
quietly reg `y' cgvo `v_fe' `t_fe' precipitation temperature, cluster (sm)
*outreg2 using $result/T8_gov , ctitle(`y'_did_control) excel dec(2) drop(`v_fe' `t_fe' o.*) append

}



*==============================================================================*
*==============================================================================*
*==============================================================================*

use $path/community_merged_AEJ, clear
*** Regressions ***** 
cap erase $result/T9_poor_hhs.xml
cap erase $result/T9_poor_hhs.txt
*** focus on the following outcomes 
* transfer_subsidy

foreach y of var log_transfer_subsidy  {
reg `y' cgvo , robust
*outreg2 using  $result/T9_poor_hhs, excel dec(2) append

* family member condtions: 
quietly reg `y' cgvo pop_family pop_work pop_disabled pop_care i.state, robust
*outreg2 using  $result/T9_poor_hhs, excel dec(2) drop(i.state) append

* land, income and financial conditions: 
quietly reg `y' cgvo land log_other_income log_savings log_debt i.state, robust
*outreg2 using  $result/T9_poor_hhs, excel dec(2) drop(i.state) append

* properties 
quietly reg `y' cgvo house_size house_year tv laundry ref air_con computer elec_moto moto phone car other_expensive i.state, robust
*outreg2 using  $result/T9_poor_hhs, excel dec(2) drop(i.state) append

* village characteristics
quietly reg `y' cgvo pop mino_share arable_land_pc local_share i.village_type i.geo_surface i.state, robust
*outreg2 using  $result/T9_poor_hhs, excel dec(2) drop(i.state) append

* everything 
quietly reg `y' cgvo pop_family pop_work pop_disabled pop_care land log_other_income log_savings log_debt house_size house_year tv laundry ref air_con computer elec_moto moto phone car other_expensive pop mino_share arable_land_pc local_share i.village_type i.geo_surface i.state, robust
*outreg2 using  $result/T9_poor_hhs, excel dec(2) drop(i.state) append
}


clear

*==============================================================================*
*==============================================================================*
*==============================================================================*
*==============================================================================*
*==============================================================================*


*/


