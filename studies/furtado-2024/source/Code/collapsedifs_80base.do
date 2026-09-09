/*************************************************************************************
Codes below helps to generate aggreagate level data set with 2 decades: 1980-1990 and 1990-2000, and set the import shock in 1980s as 0.
**************************************************************************/
* STATA version 17 

*******************************************************************
*Collapse our FB individual-level sample by czone-year for 1980.1990.2000
*******************************************************************
gen pop = 1
* generate CZ level shares of interested variables
* r_incwage notemp are created to check the manu and wage effect on immigrants vs mnatives.
collapse (mean)  r_incwage goodeng_altr1 goodeng_altr2 goodeng ///
notemp notlf unemp ///
manu_d ser_d manage_d sale_d farm_d   ///
female yrsusasq ///
yrusintvl_10plus yrusintvl_9 yrusintvl_5 yrusintvl_1 ///
 agesq ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
 arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
 edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard mard_s single yrsusa age arv_age (sum) popczyr=pop [pw = czperwt], by (czone year) 

* adjust the value of interested variables to percentage point by multiplying with 100.
foreach j in    goodeng_altr1 goodeng_altr2 goodeng female  ///
notemp notlf unemp ///
manu_d ser_d manage_d sale_d farm_d   ///
yrusintvl_10plus yrusintvl_9 yrusintvl_5 yrusintvl_1 ///
 agesq ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
 arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
 edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard mard_s single {
     replace `j' = `j' * 100  // Change percent to percentage point.
}



bysort year: egen totpopyear=total(popczyr)  
gen cell_wt = popczyr/totpopyear
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

gen yrsusa_sq = yrsusa^2 
gen age_sq = age^2 

gen t2 = 0 // 717 CZs in 1980
replace t2 = 1 if year == 1990 // 721 CZs in 1990.
replace t2 = 2 if year == 2000 // 722 CZs in 2000.  
bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.

drop if totnum < 3 // 9 obs deleted.  
drop totnum  

save temp, replace 
/* There are 2151 obs: 717(CZs)*3(years).  */

*******************************************************************
*Calculate the decadal changes in those variables.
*******************************************************************
global var_mean  t2   totpopyear cell_wt popczyr lnpopczyr r_incwage goodeng_altr1 goodeng_altr2 goodeng  female ///
notemp notlf unemp ///
manu_d ser_d manage_d sale_d farm_d   ///
yrusintvl_10plus yrusintvl_9 yrusintvl_5 yrusintvl_1 ///  
ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
yrsusa_sq age_sq yrsusasq agesq yrsusa age arv_age ///
edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard_s mard  single 

global d_var_mean d_r_incwage d_totpopyear d_cell_wt d_popczyr d_lnpopczyr d_goodeng_altr1 d_goodeng_altr2 d_goodeng d_female ///
d_notemp d_notlf d_unemp ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   ///
d_yrusintvl_10plus d_yrusintvl_9 d_yrusintvl_5 d_yrusintvl_1 ///  
d_ageintvl_20 d_ageintvl_30 d_ageintvl_40 d_ageintvl_50 ///
d_arv_age_20 d_arv_age_30 d_arv_age_40 d_arv_age_50 d_arv_age_60 ///
d_yrsusa_sq d_age_sq d_yrsusasq d_agesq d_yrsusa d_age d_arv_age ///
d_edu_hs d_enroll d_race_w d_race_b d_race_an d_race_all_other d_race_a d_race_m d_race_o d_race_h d_mard_s d_mard d_single 

reshape wide $var_mean, i(czone) j(year)
// Now the data has 82 columns/variables: czone and 27(variables)*3(years), 717 rows/obs. 
// For example, goodeng --> goodeng1980 goodeng1990 goodeng2000 
foreach i in $var_mean{
    gen d_`i'0 = `i'1990 - `i'1980 
    gen d_`i'1 = `i'2000 - `i'1990
}

* keep only those difference terms, which are named as d_goodeng, etc
foreach j in $var_mean {
	drop `j'*
}

* Now we have the decadal changes in each of the variable(mainly for descriptive purpose).
reshape long $d_var_mean, i(czone) j(t2)
// The data has 29 columns/variables: czone t2 27 changes in variables; 
// For example, d_goodeng0 d_goodeng1 --> d_goodeng with t2 =0 or 1

*******************************************************************
*Merge with start-of-period immigrants' characteristics controls and ADH's working age pop controls to get the final data which will be used to run regression.
*******************************************************************


* merge to get initial variable (levels)
merge 1:1 czone t2 using temp 
drop if _merge != 3 
drop _merge

erase temp.dta 

** merge to get import shock variables from Dorn's data set workfile_china.dta
replace t2 = -1 if t2 == 0 
replace t2 = 0 if t2 == 1
merge 1:1 t2 czone using $OriginalD/workfile_china.dta
drop if _merge == 2 // 727 CZs in Dorn's data (722 2000 base year data + 5 1990 base year data) mot matched, 717 obs matched.
drop _merge

rename d_tradeusch_pw d_tradeusch_pw_adh
rename d_tradeotch_pw_lag d_tradeotch_pw_lag_adh
// Dorn's variables are ended with "_adh".

replace d_tradeusch_pw_adh = 0 if year ==1980 
replace d_tradeotch_pw_lag_adh = 0 if year ==1980
// set 1980 import shock at 0.


foreach k in statefip city reg_midatl reg_encen reg_wncen ///
reg_satl reg_escen reg_wscen reg_mount reg_pacif{
   bys czone(year): replace `k' = `k'[_N] if missing(`k')
}








