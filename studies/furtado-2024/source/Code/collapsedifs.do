/* This file calculates the year-CZ level variables as well as the decadal equivalent changes in those CZ-year variables.*/

*Stata version 17 MP
 
 *******************************************************************
*Codes below are used to calculate the year-CZ level interested variables.
*******************************************************************
gen pop = 1
* generate CZ level shares of interested variables
collapse (mean)  r_incwage goodeng_altr1 goodeng_altr2 goodeng ///
notemp notlf unemp ///
manu_d ser_d manage_d sale_d farm_d   ///
female yrsusasq ///
yrusintvl_10plus yrusintvl_9 yrusintvl_7 yrusintvl_5 yrusintvl_1 ///
 agesq ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
 arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
 edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard mard_s single yrsusa age arv_age (sum) popczyr=pop [pw = czperwt], by (czone year) 

* adjust the value of interested variables to percentage point by multiplying with 100.
foreach j in goodeng_altr1 goodeng_altr2 goodeng female  ///
notemp notlf unemp ///
manu_d ser_d manage_d sale_d farm_d   ///
yrusintvl_10plus yrusintvl_9 yrusintvl_7 yrusintvl_5 yrusintvl_1 ///
 agesq ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
 arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
 edu_hs enroll race_w race_b race_an  race_all_other race_a race_m race_o race_h mard mard_s single{
     replace `j' = `j' * 100  // Change percent to percentage point.
}

bysort year: egen totpopyear=total(popczyr)  // report the total population in each year.  

gen cell_wt = popczyr/totpopyear
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

gen yrsusa_sq = yrsusa^2 
gen age_sq = age^2 

gen t2 = 0 // 721 CZs in 1990
replace t2 = 1 if year == 2000 // 722 CZs in 2000.
replace t2 = 2 if year == 2007 // 717 CZs in 2007.  
bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.

drop if totnum < 3 // 12 obs deleted.  
drop totnum  

save temp.dta, replace 

*******************************************************************
*Codes below are used to calculate the decadal changes in those variables.
*******************************************************************

global var_mean  t2   totpopyear cell_wt popczyr lnpopczyr r_incwage goodeng_altr1 goodeng_altr2 goodeng  female ///
notemp notlf unemp ///
manu_d ser_d manage_d sale_d farm_d   ///
yrusintvl_10plus yrusintvl_9 yrusintvl_7 yrusintvl_5 yrusintvl_1 ///  
ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
yrsusa_sq age_sq yrsusasq agesq yrsusa age arv_age ///
edu_hs enroll race_w race_b race_an  race_all_other race_a race_m race_o race_h mard_s mard  single 

global d_var_mean d_r_incwage d_totpopyear d_cell_wt d_popczyr d_lnpopczyr d_goodeng_altr1 d_goodeng_altr2 d_goodeng d_female ///
d_notemp d_notlf d_unemp ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   ///
d_yrusintvl_10plus d_yrusintvl_9 d_yrusintvl_7 d_yrusintvl_5 d_yrusintvl_1 ///  
d_ageintvl_20 d_ageintvl_30 d_ageintvl_40 d_ageintvl_50 ///
d_arv_age_20 d_arv_age_30 d_arv_age_40 d_arv_age_50 d_arv_age_60 ///
d_yrsusa_sq d_age_sq d_yrsusasq d_agesq d_yrsusa d_age d_arv_age ///
d_edu_hs d_enroll d_race_w d_race_b d_race_an d_race_all_other d_race_a d_race_m d_race_o d_race_h d_mard_s d_mard d_single 

reshape wide $var_mean, i(czone) j(year)
// For example, goodeng --> goodeng1990 goodeng2000 goodeng2007 
foreach i in $var_mean{
    gen d_`i'0 = `i'2000 - `i'1990 
    gen d_`i'1 = (`i'2007 - `i'2000)*10/7
}

* keep only those difference terms, which are named as d_goodeng, etc
foreach j in $var_mean{
	drop `j'*
}

* Now we have the decadal changes in each of the variable(mainly for descriptive purpose).
reshape long $d_var_mean, i(czone) j(t2)
// For example, d_goodeng0 d_goodeng1 --> d_goodeng with t2 =0 or 1

* merge to get IPW variable from Dorn's data
merge 1:1 t2 czone using $OriginalD/workfile_china.dta
drop if _merge != 3 
drop _merge
rename d_tradeusch_pw d_tradeusch_pw_adh
rename d_tradeotch_pw_lag d_tradeotch_pw_lag_adh
// Dorn's variables are ended with "_adh".

*******************************************************************
*Merge with start-of-period immigrants' characteristics controls and ADH's working age pop controls to get the final data which will be used to run regression.
*******************************************************************

* merge to get the initial year CZ level variable in each decade.
merge 1:1 czone t2 using temp.dta 
drop if _merge != 3 
drop _merge

erase temp.dta 





