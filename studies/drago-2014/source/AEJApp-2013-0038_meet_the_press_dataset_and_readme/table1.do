*********
**TABLE 1 
*********
clear
use meet_the_press_data_elections , clear

*row 1 and 2
tabstat turnout,s(mean sd min max N) f(%12.2fc)
 
local varpippo_1 recandidate reelected 
local varpippo_2 gender age years_school empl_not
local varpippo_3 avg_rev_collect avg_expend_speed

forvalues i=1/1 {
preserve
foreach var of local varpippo_`i' {
drop if `var'==.
}
foreach var of local varpippo_`i' {
tabstat `var',s(mean sd min max N) f(%12.2fc)
}
restore
}

*row 3
preserve
keep if recandidate==1
tabstat reelected ,s(mean sd min max N) f(%12.2fc) 
restore 

*row 4-10
forvalues i=2/3 {
preserve
foreach var of local varpippo_`i' {
drop if diff_`var'==.
quietly areg  diff_`var' du_diff_loc_TOT du_diff_naz_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
g pippo=e(sample)
drop if pippo!=1
drop pippo
}
foreach var of local varpippo_`i' {
tabstat `var',s(mean sd min max N) f(%12.2fc)
*latabstat `var',s(mean sd min max N) f(%12.2fc)
}
restore
}

