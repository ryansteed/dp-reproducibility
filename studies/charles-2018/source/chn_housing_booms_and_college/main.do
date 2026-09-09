

clear
clear matrix
clear mata

set more off
set linesize 220
set matsize 11000
set maxvar 11000
set seed 12345

graph set eps fontface "Times New Roman"
graph set eps logo off
graph set eps


do init.do













**
**http://www.bls.gov/nls/quex/y97r3geocbk101.pdf
**https://usa.ipums.org/usa-action/variables/METAREA/#codes_section

clear
use ./chn/msa_units_growth.dta

**
** Mapping of MSA codes
**
replace msa_code = 2080 if msa_code_orig == 1125
replace msa_code = 3360 if msa_code_orig == 1145
replace msa_code =  730 if msa_code_orig == 733
replace msa_code =  740 if msa_code_orig == 743
replace msa_code = 5600 if msa_code_orig == 875
replace msa_code = 1310 if msa_code_orig == 1303
replace msa_code = 8730 if msa_code_orig == 8735
replace msa_code = 4480 if msa_code_orig == 5945
replace msa_code = 7360 if msa_code_orig == 5775
replace msa_code = 5480 if msa_code_orig == 5483
replace msa_code = 5600 if msa_code_orig == 5015



preserve
gen metarea = msa_code / 10
keep metarea units*
desc, full
collapse (sum) units1990-units2012, by(metarea)
reshape long units, i(metarea) j(year)
keep if year >= 2000
rename year year_orig
sort metarea year_orig
save ./chn/msa_units_annual_data.dta, replace
restore



collapse (sum) units1990-units2012, by(msa_code)

egen units_sum_90_97 = rowmean(units1990-units1997)
egen units_sum_00_07 = rowmean(units2000-units2007)
egen units_sum_07_11 = rowmean(units2007-units2012)
egen units_sum_08_12 = rowmean(units2008-units2012)
egen units_sum_00_11 = rowmean(units2000-units2011)
egen units_sum_00_12 = rowmean(units2000-units2012)
egen units_sum_03_04 = rowmean(units2003-units2004)
egen units_sum_01_02 = rowmean(units2001-units2002)
egen units_sum_04_06 = rowmean(units2004-units2006)
egen units_sum_01_05 = rowmean(units2001-units2006)
egen units_sum_98_00 = rowmean(units1998-units2000)
desc, full

gen units_growth = log(units_sum_04_06) - log(units_sum_98_00)
gen units_growth_alt = log(units_sum_01_05) - log(units_sum_98_00)

gen units_growth_06_11 = log(units_sum_08_12) - log(units_sum_01_05)
gen units_growth_alt_06_11 = log(units_sum_08_12) - log(units_sum_01_05)

gen units_growth_00_11 = log(units_sum_00_12) - log(units_sum_90_97)
gen units_growth_00_06 = log(units2006) - log(units2000)

gen units_00_06 = log(units2006) - log(units2000)
gen units_97_06 = log(units2006) - log(units1997)

summ units2*

sort msa_code
rename msa_code metarea
keep metarea units_growth units_growth_* units_00_06 units_97_06

replace metarea = metarea / 10

isid metarea
sort metarea
save ./chn/msa_units_growth_FINAL.dta, replace









**
** generate: pop_prev college_share_2000 female_employed_share_2000
**
clear
use  ./chn/analysis_sample_FINAL_v2_main_same.dta, replace
capture drop pop_prev
gen pop_prev = log(pop_18_25_00 + pop_26_55_00)
gen female_employed_share_2000 = emp_f_00 / pop_f_00
gen college_share_2000 = (emp_me_00 + emp_he_00) / emp_tot_00
keep metarea pop_prev female_employed_share_2000 college_share_2000
sort metarea
save ./chn/controls.dta, replace






clear
use  ./chn/analysis_sample_FINAL_v2_main_same.dta, replace



sort metarea
capture drop _merge
sort metarea 
merge metarea using ./chn/share_foreign.dta, uniqusing uniqmaster
assert _merge != 1
keep if _merge == 3
drop _merge

sort metarea
capture drop _merge
sort metarea 
merge metarea using ./chn/controls.dta, uniqusing uniqmaster
assert _merge != 1
keep if _merge == 3
drop _merge
capture drop pop_prev female_employed_share_2000 college_share_2000
gen pop_prev = log(pop_tot_00)
gen female_employed_share_2000 = emp_f_00 / pop_f_00
gen college_share_2000 = (emp_me_00 + emp_he_00) / emp_tot_00



**
** Re-assign proper states for clustering (state se's)
**
replace statefip = 47 if metarea == 156
replace statefip = 29 if metarea == 704
replace statefip = 17 if metarea == 160
replace statefip = 17 if metarea == 196
replace statefip = 29 if metarea == 376
replace statefip = 36 if metarea == 560
replace statefip = 11 if metarea == 884



preserve
keep metarea pop_prev female_employed_share_2000 college_share_2000 statefip
sort metarea
save ./chn/controls.dta, replace
restore






***
* Merge in permits
***
sort metarea
capture drop _merge
merge metarea using ./chn/msa_units_growth_FINAL, uniqusing uniqmaster
tab metarea _merge, missing
drop if _merge == 2



reg deltaP units_growth [aw=msa_total_emp_all_2000]
reg deltaP units_growth
gen demand2 = deltaP + units_growth
gen demand3 = deltaP + units_00_06
reg hp_growth_real_00_06 demand2 [aw=msa_total_emp_all_2000]
corr hp_growth_real_00_06 demand2 demand3 [aw=msa_total_emp_all_2000]
replace hp_growth_real_00_06 = demand2





**
* Save out age of 18-29 population
**
preserve
 gen d_pop = log(pop_tot_07) - log(pop_tot_00)
 keep pop*18_29* metarea region d_pop
 sort metarea
 save chn/pop_18_29.dta, replace
restore




capture drop _merge
sort metarea 
merge metarea using ./chn/unemp_manuf.dta, uniqusing uniqmaster
*assert _merge != 1
keep if _merge == 3
drop _merge

capture drop _merge
sort metarea 
merge metarea using ./chn/routine_share_2000.dta, uniqusing uniqmaster
*assert _merge != 1
keep if _merge == 3
drop _merge




**
** MAIN CONTROLS
**
global controls  = "college_share_2000 female_employed_share_2000 pop_prev share_foreign_18_55_2000"
replace pop_18_33_00 = exp(pop_prev)
replace hp_growth_real_00_06 = deltaP + units_growth







capture drop _merge
sort metarea
merge metarea using ./chn/fhfa/new_iv_fg, uniqusing
drop _merge







preserve
 rename pop_18_33_00 wgt
 gen housing_demand_shock = deltaP + units_growth
 gen housing_demand_shock_alt = deltaP + units_growth_alt
 keep metarea iv iv2_log t_log housing_demand_shock* deltaP units_growth units_growth_alt wgt female_employed_share_2000 college_share_2000 pop_prev elasticity reg*
 summ
 sort metarea
 save ./chn/main_data.dta, replace
restore




**
** Calculate top two-thirds
**
_pctile iv [aw=pop_18_33_00], p(66.7)
return list
_pctile iv , p(66.7)
local p67 = r(r1)
return list
summ iv if iv > `p67'
summ iv [aw=pop_18_33_00] if iv > `p67'




**
** Run by itself to generate figures
**
if ("`1'" == "graphs") {
 do chn/chn_iv_graphs.do
 do chn/chn_intro_graphs.do
 exit
}






/**
 **
 ** Run by itself for education results
 **/
if ("`1'" == "educ") {
desc pop*, full
local types = "same"`
foreach type of local types {
 do chn/table3_educ.do "_" "`type'"
 do chn/table3_educ.do "_men_" "`type'"
 do chn/table3_educ.do "_women_" "`type'"

 **
 ** Table 7
 **
 ** Changed by Donna
 do chn/table3_educ.do "_" "`type'" "06_12"
 do chn/table3_educ.do "_men_" "`type'" "06_12"
 do chn/table3_educ.do "_women_" "`type'" "06_12"
 do chn/table3_educ.do "_" "`type'" "00_12"
 do chn/table3_educ.do "_men_" "`type'" "00_12"
 do chn/table3_educ.do "_women_" "`type'" "00_12"
}
exit
}



do chn/table3_educ.do "_" "`type'"

*** Changed By Donna
/*

**
** Confirm that main housing depand change is dP+dQ
**
replace hp_growth_real_00_06 = deltaP + units_growth
summ hp_growth_real_00_06 [aw=pop_18_33_00]



do chn/table1_emp_all.do "18_25" 

do chn/table2_rel_wage.do

**
** Online appendix tables for labor market outcomes
**
do chn/tableOA1_summ_stats.do

do chn/tableOA_first_stage.do

do chn/tableOA_lr.do "18_25"

do chn/tableOA_P_Q.do

do chn/tableOA_elast_inter.do "18_25"

do chn/tableOA_elast_inter.do "18_25" "dummy"

do chn/tableOA_robustness.do "18_25"

do chn/tableOA_robustness2.do "18_25"

preserve
replace hp_growth_real_00_06 = (iv > .0883834)
do chn/table1_emp_all.do "18_25" "OA24"
restore

preserve
foreach var of varlist d_wage* {
 ** See: http://www.mitpressjournals.org/doi/pdf/10.1162/rest.88.2.324 for source of 0.32
 replace `var' = `var' - rent_growth * 0.32
}
foreach var of varlist d_cons* {
 replace `var' = rent_growth
}
foreach var of varlist d_fire* {
 replace `var' = deltaP
}
do chn/table1_emp_all.do "18_25" "OA18"

restore

exit
*/



