

clear
set more off
set maxvar 11000


use "./chn/msa_labormarket_1990_main.dta"
sort metarea
save "./chn/msa_labormarket_1990_main.dta", replace


if ("`1'" != "") {
 use "./chn/msa_labormarket_2000_2013_`1'_alt_v3.dta"
 sort metarea
}
else {
 use "./chn/msa_labormarket_2000_2013_main_same_alt_v3.dta"
 sort metarea
}



drop if missing(metarea)

sort metarea
merge metarea using  "./chn/msa_labormarket_1990_main.dta", uniqusing uniqmaster
tab _merge, missing
drop if _merge == 2
drop _merge



/**
 **
variable summary:
 "pop emp cons retail fire full wage wage_adj  (x)  2000, 2007, 2011"

1. rename 
 lowed_male lm
 mided_male mm
 ...
 highed_fem hf

 rename 2000 to 00
 2007 to 07
 2011 to 11

2. generate
 "lowed_male mided_male highed_male lowed_fem mided_fem highed_fem"
 across age groups for each "outcome" 

3. ...
 
 **
 **/





**
** 1. Rename
**
foreach var of varlist *1990 {
 local newvar = subinstr("`var'", "1990", "90", .)
 rename `var' `newvar'
}
foreach var of varlist *2000 {
 local newvar = subinstr("`var'", "2000", "00", .)
 rename `var' `newvar'
}
foreach var of varlist *2007 {
 local newvar = subinstr("`var'", "2007", "07", .)
 rename `var' `newvar'
}
foreach var of varlist *2011 {
 local newvar = subinstr("`var'", "2011", "11", .)
 rename `var' `newvar'
}
foreach var of varlist *2013 {
 local newvar = subinstr("`var'", "2013", "13", .)
 rename `var' `newvar'
}
foreach var of varlist * {
 local newvar = subinstr("`var'", "lowed_male", "le_m", .)
 local newvar = subinstr("`newvar'", "mided_male", "me_m", .)
 local newvar = subinstr("`newvar'", "highed_male", "he_m", .)
 local newvar = subinstr("`newvar'", "lowed_fem", "le_f", .)
 local newvar = subinstr("`newvar'", "mided_fem", "me_f", .)
 local newvar = subinstr("`newvar'", "highed_fem", "he_f", .)
 local newvar = subinstr("`newvar'", "male", "m", .)
 local newvar = subinstr("`newvar'", "fem", "f", .)
 local newvar = subinstr("`newvar'", "lowed", "le", .)
 local newvar = subinstr("`newvar'", "mided", "me", .)
 local newvar = subinstr("`newvar'", "highed", "he", .)
 local newvar = subinstr("`newvar'", "total", "tot", .)
 if ("`newvar'" != "`var'") {
  di "renaming `var' to `newvar' ..."
  rename `var' `newvar'
 }
}



/*
foreach var of varlist unemp* {
  local lfp = subinstr("`var'", "unemp", "lfp", .)
  local emp = subinstr("`var'", "unemp", "emp", .)
  gen `lfp' = `emp' + `var'
}
 */



**
** 2. Sum across ages (for le_m through he_f)
**
local vars = "pop emp cons fire full wage wage_adj"

local years = "00 07 11 13"
local types = "le_m me_m he_m le_f me_f he_f"

foreach type of local types {
 foreach var of local vars {
  foreach yr of local years {

   *assert(`var'_18_29_`type'_`yr' + `var'_30_45_`type'_`yr' + `var'_45_55_`type'_`yr' == ///
   * `var'_18_34_`type'_`yr' + `var'_35_55_`type'_`yr')

   *gen `var'_`type'_`yr' = ///
   *  (`var'_18_29_`type'_`yr' + `var'_30_45_`type'_`yr' + `var'_45_55_`type'_`yr')

  }
 }
}



** 1990's only is subset of variables
local vars = "pop emp full wage wage_adj"
local years = "90"
local types = "le_m me_m he_m le_f me_f he_f"

foreach type of local types {
 foreach var of local vars {
  foreach yr of local years {

   *assert(`var'_18_29_`type'_`yr' + `var'_30_44_`type'_`yr' + `var'_45_55_`type'_`yr' == ///
   * `var'_18_34_`type'_`yr' + `var'_35_55_`type'_`yr')

   gen `var'_`type'_`yr' = ///
     (`var'_18_29_`type'_`yr' + `var'_30_44_`type'_`yr' + `var'_45_55_`type'_`yr')

  }
 }
}



foreach var of varlist *_me_* {
 local le = subinstr("`var'", "_me_", "_le_", .)
 local lm = subinstr("`var'", "_me_", "_lm_", .)
 gen `lm' = `var' + `le'
}

foreach var of varlist *_me_* {
 local he = subinstr("`var'", "_me_", "_he_", .)
 local mh = subinstr("`var'", "_me_", "_mh_", .)
 gen `mh' = `var' + `he'
}



foreach var of varlist *_26_55_* {
 local v18_25 = subinstr("`var'", "26_55", "18_25", .)
 local v18_55 = subinstr("`var'", "26_55", "18_55", .)
 gen `v18_55' = `var' + `v18_25'
}





**
* 3. Process data for different demog groups
**


foreach var of varlist pop*00 {

 local pop = subinstr("`var'", "_00", "", .)
 *local pop_90 = subinstr("`var'", "00", "90", .)
 local pop_07 = subinstr("`var'", "00", "07", .)
 local pop_11 = subinstr("`var'", "00", "11", .)
 local pop_13 = subinstr("`var'", "00", "13", .)

 local emp = subinstr("`var'", "pop", "emp", .)
 *local emp_90 = subinstr("`pop_90'", "pop", "emp", .)
 local emp_07 = subinstr("`pop_07'", "pop", "emp", .)
 local emp_11 = subinstr("`pop_11'", "pop", "emp", .)
 local emp_13 = subinstr("`pop_13'", "pop", "emp", .)

 local typ = "full"
 local full = subinstr("`pop'", "pop", "`typ'", .)
 *local `typ'_90 = subinstr("`pop_90'", "pop", "`typ'", .)
 local `typ'_07 = subinstr("`pop_07'", "pop", "`typ'", .)
 local `typ'_11 = subinstr("`pop_11'", "pop", "`typ'", .)
 local `typ'_13 = subinstr("`pop_13'", "pop", "`typ'", .)

 local types = "pop emp cons fire wage wage_adj"
 
foreach typ of local types {
 local type = subinstr("`pop'", "pop", "`typ'", .)
 local `type'_07 = subinstr("`pop_07'", "pop", "`typ'", .)
 local `type'_11 = subinstr("`pop_11'", "pop", "`typ'", .)
 local `type'_13 = subinstr("`pop_13'", "pop", "`typ'", .)

if ("`typ'" == "wage" | "`typ'" == "wage_adj") {

 gen d_`type' = log(``type'_07'/`full_07') - log(`type'_00/`full'_00)
 gen d_`type'_07_11 = log(``type'_11'/`full_11') - log(``type'_07'/`full_07')
 gen d_`type'_00_11 = log(``type'_11'/`full_11') - log(`type'_00/`full'_00)
 gen d_`type'_07_13 = log(``type'_13'/`full_13') - log(``type'_07'/`full_07')
 gen d_`type'_00_13 = log(``type'_13'/`full_13') - log(`type'_00/`full'_00)

 gen d_e`type' = (`emp_07' / `pop_07') * log(``type'_07'/`full_07') - log(`type'_00/`full'_00) * (`emp' / `pop'_00)
 gen d_e`type'_07_11 = (`emp_11' / `pop_11') * log(``type'_11'/`full_11') - log(``type'_07'/`full_07') * (`emp_07' / `pop_07')
 gen d_e`type'_00_11 = (`emp_11' / `pop_11') * log(``type'_11'/`full_11') - log(`type'_00/`full'_00) * (`emp' / `pop'_00)
 gen d_e`type'_07_13 = (`emp_13' / `pop_13') * log(``type'_13'/`full_13') - log(``type'_07'/`full_07') * (`emp_07' / `pop_07')
 gen d_e`type'_00_13 = (`emp_13' / `pop_13') * log(``type'_13'/`full_13') - log(`type'_00/`full'_00) * (`emp' / `pop'_00)

}
else {
 if ("`typ'" == "pop") {
  gen d_`type' = log(``type'_07') - log(`type'_00)
  gen d_`type'_07_11 = log(``type'_11') - log(``type'_07')
  gen d_`type'_00_11 = log(``type'_11') - log(`type'_00)
  gen d_`type'_07_13 = log(``type'_13') - log(``type'_07')
  gen d_`type'_00_13 = log(``type'_13') - log(`type'_00)
 }
 else {
  gen d_`type' = ``type'_07'/`pop_07' - `type'_00/`pop'_00
  gen d_`type'_07_11 = ``type'_11'/`pop_11' - ``type'_07'/`pop_07'
  gen d_`type'_00_11 = ``type'_11'/`pop_11' - `type'_00/`pop'_00
  gen d_`type'_07_13 = ``type'_13'/`pop_13' - ``type'_07'/`pop_07'
  gen d_`type'_00_13 = ``type'_13'/`pop_13' - `type'_00/`pop'_00
  if ("`typ'" == "emp") {
   *gen d_`type'_90_00 = `type'_00/`pop'_00 -  ``type'_90'/`pop_90'
   *gen d_`type'_90_00 = ``type'_90'/`pop_90'
  }
 }
}

** END foreach types
}

** END foreach vars
}



foreach var of varlist d_wage_*_me_* d_emp_*_me_* d_ewage_*_me_* {
 local le = subinstr("`var'", "_me_", "_le_", .)
 local he = subinstr("`var'", "_me_", "_he_", .)
 local hl = subinstr("`var'", "_me_", "_hl_", .)
 local ml = subinstr("`var'", "_me_", "_ml_", .)
 local mh = subinstr("`var'", "_me_", "_mh_", .)
 local mhl = subinstr("`var'", "_me_", "_mhl_", .)
 gen `hl' = `he' - `le'
 gen `ml' = `var' - `le'
 gen `mhl' = `mh' - `le'
}

foreach var of varlist d_wage_*_me d_emp_*_me d_ewage_*_me {
 local le = subinstr("`var'", "_me", "_le", .)
 local he = subinstr("`var'", "_me", "_he", .)
 local hl = subinstr("`var'", "_me", "_hl", .)
 local ml = subinstr("`var'", "_me", "_ml", .)
 local mh = subinstr("`var'", "_me", "_mh", .)
 local mhl = subinstr("`var'", "_me", "_mhl", .)
 gen `hl' = `he' - `le'
 gen `ml' = `var' - `le'
 gen `mhl' = `mh' - `le'
}



sort metarea


**
** BASELINE SAMPLE RESTRICTION TO IPUMS MSAs
**
keep if metarea < . & metarea != 0

capture drop msanecma

gen msanecma = 10 * metarea

** Original NECMAs that we tried to merge but with new metarea codes
replace msanecma = 743 if metarea == 74 
replace msanecma = 1123 if metarea == 112
replace msanecma = 3283 if metarea == 328
replace msanecma = 6403 if metarea == 640
replace msanecma = 6483 if metarea == 648
replace msanecma = 8003 if metarea == 800

** Non-NECMAs that we can merge now (most of these are in Census/ACS and FHFA data)
replace msanecma = 2335 if metarea == 233
replace msanecma = 2655 if metarea == 266
replace msanecma = 2975 if metarea == 297
replace msanecma = 2995 if metarea == 301
replace msanecma = 5345 if metarea == 534
replace msanecma = 5483 if metarea == 548
replace msanecma = 6895 if metarea == 689
replace msanecma = 8735 if metarea == 873

replace msanecma = 2330 if metarea == 232
replace msanecma = 7480 if metarea == 747
replace msanecma = 7485 if metarea == 748

capture drop _merge
sort msanecma
merge msanecma using chn/saiz_elasticity.dta, uniqusing uniqmaster

drop if _merge == 2

** housing prices, instrument, etc.
summ elasticity, det



gen msa_total_emp_lowed_2000 = pop_tot_00
gen msa_total_emp_all_2000 = pop_tot_00



**
* Use new house price file
**
drop if missing(metarea) | metarea == 0

**
** NOTE: This code should drop Grand Forks, ND/MN (which is missing)
**
*assert d_emp_le_m == . if metarea == 2999
drop if metarea == 299

capture drop hp_growth_real_*

capture drop _merge
sort metarea
merge metarea using ./chn/fhfa/fhfa_data.dta, uniqmaster uniqusing
tab metarea _merge, missing
*assert _merge != 1
keep if _merge == 3
drop _merge

capture drop pval
sort metarea 
merge metarea using ./chn/fhfa/new_iv2_log.dta, uniqusing uniqmaster
tab _merge, missing
*assert _merge != 1
keep if _merge == 3
drop _merge
gen pval_log = pval

sort metarea 
merge metarea using ./chn/fhfa/new_iv2_poly3.dta, uniqusing uniqmaster
tab _merge, missing
*assert _merge != 1
keep if _merge == 3
drop _merge

capture drop _merge
sort metarea
merge metarea using ./chn/rent_by_msa_2000.dta, uniqusing uniqmaster
tab _merge, missing
assert _merge != 1
drop _merge

capture drop _merge
sort metarea
merge metarea using ./chn/rent_by_msa_2007.dta, uniqusing uniqmaster
tab _merge, missing
assert _merge != 1
drop _merge

summ hpi*, det

gen hpi2006 = exp(hp_growth_real_00_06 + log(hpi2000))

gen rent_growth = ln_rent_2007 - ln_rent_2000
gen price_rent_ratio = log(hpi2006/exp(ln_rent_2007)) - log(hpi2000/exp(ln_rent_2000))



rename hp_growth_real_00_06 deltaP
rename hp_growth_real_06_11 deltaP_06_11
rename hp_growth_real_00_11 deltaP_00_11

gen hp_growth_real_00_06 = deltaP * (0.7 + elasticity)
gen hp_growth_real_06_11 = deltaP_06_11 * (0.7 + elasticity)
gen hp_growth_real_00_11 = deltaP_00_11 * (0.7 + elasticity)

preserve
keep metarea hp_growth_real_00_06 elasticity
sort metarea
save ./chn/metarea_to_hp_growth.dta, replace
restore


replace iv2_log = exp(4*iv2_log)-1
gen iv = iv2_log

gen iv_sig  = iv2_log * (pval_log < 0.05)
gen iv_sig2 = iv2_log * (pval_log < 0.01)

capture drop count_num*

capture drop ln_wage*








capture drop _merge
sort metarea
capture drop region
merge metarea using chn/xwalk_metarea_to_state_and_region.dta, uniqusing
tab _merge, missing
keep if _merge == 3

capture drop _merge
sort metarea
merge metarea using chn/pop_msa_all_2000.dta, uniqusing
tab _merge, missing
keep if _merge == 3

gen pop_prev = log(pop_msa_all_2000)
gen reg4 = floor(region / 10)

gen ln_e = log(elasticity)
gen exp_e = exp(elasticity)
gen one_over_e = 1 / elasticity

xi i.reg4

** AZ, CA, FL, NV
gen sand = (statefip == 4 | statefip == 6 | statefip == 12 | statefip == 32)

gen land_aval = 1 - (((FLAT_SHARE_50_15/100)-lu11-lu92-lu91)*(S_LAND_50/100))
summ land_aval, det

replace land_aval = iv
summ land_aval, det
local mean = r(mean)
local median = r(p50)

gen subsample1 = (land_aval > `median')
gen subsample2 = (land_aval > `mean')


capture drop _merge

capture drop retail* 

capture drop full*07*
capture drop unemp*07*
capture drop emp*07*
capture drop lfp*07*
capture drop wage*07*

capture drop full*11*
capture drop unemp*11*
capture drop emp*11*
capture drop lfp*11*
capture drop wage*11*

capture drop full*13*
capture drop unemp*13*
capture drop emp*13*
capture drop lfp*13*
capture drop wage*13*


desc, full
if ("`1'" != "") {
 save ./chn/analysis_sample_FINAL_v2_`1'.dta, replace
}
else {
 save ./chn/analysis_sample_FINAL_v2_main_same.dta, replace
}


