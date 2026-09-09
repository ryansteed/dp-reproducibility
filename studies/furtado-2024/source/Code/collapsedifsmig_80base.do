/* This dofile helps to make the year-CZ level variables as well as the decadal equivalent changes in 1980-1990 and 1990-2000, for those interested variables, based on the individual level data with migration histories created by 4e_migrationIndiv_table9, also defines 1980 import shocks at 0 level. */

*Stata version 17

*******************************************************************
*Collapse our FB individual-level sample by czone-year
*******************************************************************
gen pop = 1
* generate CZ-year level shares of interested variables
collapse (mean) mig notemp goodeng_altr1 goodeng_altr2 goodeng manu_d ser_d female yrsusasq  ///
 yrusintvl_10plus yrusintvl_9 yrusintvl_5 yrusintvl_1  ///
 agesq ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
 arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
 edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard mard_s single yrsusa age arv_age (sum) popczyr=pop [pw = czperwtmig], by (czone year)

* adjust the value of interested variables to percentage point by multiplying with 100.
foreach j in mig notemp  goodeng_altr1 goodeng_altr2 goodeng manu_d ser_d female  ///
 yrusintvl_10plus yrusintvl_9 yrusintvl_5 yrusintvl_1 ///
 agesq ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
 arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
 edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard mard_s single {
     replace `j' = `j' * 100  // Change percent to percentage point.
} 
 
bysort year: egen totpopyear=total(popczyr)  

gen cell_wt = popczyr/totpopyear

gen yrsusa_sq = yrsusa^2 
gen age_sq = age^2 

gen t2 = 0 
replace t2 = 1 if year == 1990 
replace t2 = 2 if year == 2000 
bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.

drop if totnum < 3  
drop totnum  

save temp, replace 

*******************************************************************
*Codes below are used to calculate the decadal changes in those variables above.
*******************************************************************

global var_mean  t2 totpopyear cell_wt popczyr mig notemp goodeng_altr1 goodeng_altr2 goodeng manu_d ser_d female ///
yrusintvl_10plus yrusintvl_9 yrusintvl_5 yrusintvl_1 ///  
ageintvl_20 ageintvl_30 ageintvl_40 ageintvl_50 ///
arv_age_20 arv_age_30 arv_age_40 arv_age_50 arv_age_60 ///
yrsusa_sq age_sq yrsusasq agesq yrsusa age arv_age ///
edu_hs enroll race_w race_b race_an race_all_other race_a race_m race_o race_h mard_s mard  single 

global d_var_mean d_mig d_totpopyear d_cell_wt d_popczyr d_notemp d_goodeng_altr1 d_goodeng_altr2 d_goodeng d_manu_d d_ser_d d_female ///
 d_yrusintvl_10plus d_yrusintvl_9 d_yrusintvl_5 d_yrusintvl_1 ///  
 d_ageintvl_20 d_ageintvl_30 d_ageintvl_40 d_ageintvl_50 ///
 d_arv_age_20 d_arv_age_30 d_arv_age_40 d_arv_age_50 d_arv_age_60 ///
 d_yrsusa_sq d_age_sq d_yrsusasq d_agesq d_yrsusa d_age d_arv_age /// 
 d_edu_hs d_enroll d_race_w d_race_b d_race_an d_race_all_other d_race_a d_race_m d_race_o d_race_h d_mard_s d_mard d_single 

reshape wide $var_mean, i(czone) j(year)
// For example, goodeng --> goodeng1990 goodeng2000 goodeng2007 
foreach i in $var_mean{
    gen d_`i'0 = `i'1990 - `i'1980 
    gen d_`i'1 = `i'2000 - `i'1990
}

* keep only those differences, which are named as d_goodeng, etc
foreach j in $var_mean {
	drop `j'*
}

reshape long $d_var_mean, i(czone) j(t2)
// For example, d_goodeng0 d_goodeng1 --> d_goodeng with t2 =0 or 1

* merge to get initial variable (levels) in each period.
merge 1:1 czone t2 using temp 
drop if _merge != 3 
drop _merge

erase temp.dta 

** merge to get import shock variables from Dorn's data: workfile_china.dta
replace t2 = -1 if t2 == 0 
replace t2 = 0 if t2 == 1
merge 1:1 t2 czone using $OriginalD/workfile_china.dta
drop if _merge == 2 
drop _merge
** Dorn's interested variables are ended with "_adh".
rename d_tradeusch_pw d_tradeusch_pw_adh
rename d_tradeotch_pw_lag d_tradeotch_pw_lag_adh
** set 1980 import shock at 0.
replace d_tradeusch_pw_adh = 0 if year ==1980 
replace d_tradeotch_pw_lag_adh = 0 if year ==1980

foreach k in statefip city reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif{
   bys czone(year): replace `k' = `k'[_N] if missing(`k')
}
** Merge to get 1980 CZ level important controls: l_shind_manuf_cbp, l_sh_empl_f, l_sh_popedu_c.
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
