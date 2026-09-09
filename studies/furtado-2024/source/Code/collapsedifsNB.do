/* This file calculates the year-CZ level variables as well as the decadal equivalent changes in those CZ-year variables for natives.*/

* Stata version 17 MP

*******************************************************************
*Collapse our Native individual-level sample by czone-year
*******************************************************************
gen pop = 1
* generate CZ level shares of interested variables
collapse (mean)   manu_d ser_d female edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h  mard mard_s single  age  (sum) popczyr=pop [pw = czperwt], by (czone year)

* adjust the value of interested variables to percentage point by multiplying with 100.
foreach j in manu_d ser_d female edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard mard_s single {
     replace `j' = `j' * 100  // Change percent to percentage point.
}

bysort year: egen totpopyear=total(popczyr)  //check this. 

gen cell_wt = popczyr/totpopyear
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

gen t2 = 0 // 721 CZs in 1990, details can be found in line 5414.
replace t2 = 1 if year == 2000 // 722 CZs in 2000.
replace t2 = 2 if year == 2007 // 717 CZs in 2007.  
bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.

drop if totnum < 3 // 12 obs deleted.  
drop totnum  

save temp, replace 

/* There are 2148 obs: 716(CZs)*3(years). */

*******************************************************************
*Codes below are used to calculate the decadal changes in those variables.
*******************************************************************
global var_mean   t2 totpopyear cell_wt popczyr lnpopczyr manu_d ser_d female age  ///
edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard_s mard  single 

global d_var_mean   d_totpopyear d_cell_wt d_popczyr d_lnpopczyr d_manu_d d_ser_d d_female ///
d_edu_hs d_enroll d_race_w d_race_b d_race_an d_race_all_other d_race_a d_race_m d_race_o d_race_h d_mard_s d_mard d_single 

reshape wide $var_mean, i(czone) j(year)
// Now the data has 82 columns/variables: czone and 27(variables)*3(years), 716 rows/obs. 
// For example, goodeng --> goodeng1990 goodeng2000 goodeng2007 
foreach i in $var_mean{
    gen d_`i'0 = `i'2000 - `i'1990 
    gen d_`i'1 = (`i'2007 - `i'2000)*10/7
}

* keep only those difference terms, which are named as d_goodeng, etc
foreach j in $var_mean {
	drop `j'*
}

* Now we have the decadal changes in each of the variable(mainly for descriptive purpose).
reshape long $d_var_mean, i(czone) j(t2)
// The data has 29 columns/variables: czone t2 27 changes in variables; 1432 rows/obs.
// For example, d_goodeng0 d_goodeng1 --> d_goodeng with t2 =0 or 1

* merge to get IPW variable from Dorn's data
merge 1:1 t2 czone using $OriginalD/workfile_china.dta
drop if _merge != 3 // 12 CZs in Dorn's data mot matched, 1432 obs matched.
drop _merge
rename d_tradeusch_pw d_tradeusch_pw_adh
rename d_tradeotch_pw_lag d_tradeotch_pw_lag_adh
// Dorn's variables are ended with "_adh".

*******************************************************************
*Merge with start-of-period immigrants' characteristics controls and ADH's working age pop controls to get the final data which will be used to run regression.
*******************************************************************

* merge to get initial variable (levels)
merge 1:1 czone t2 using temp.dta // "90_10_cz_character.dta" has the control variables in 1990 2000 and 2007.
drop if _merge != 3 // 716 CZs in 2007 not matched, because we only need 1990 2000 data as base year controls.
drop _merge

erase temp.dta  //added on 2022_03_21





