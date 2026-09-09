***************************************************************************************
****************    TABLE 5 -- POLITICIANS SELECTION      *****************************
***************************************************************************************

clear
use meet_the_press_data_elections , clear
preserve 
foreach var of varlist gender age years_school empl_not{
drop if diff_`var'==.
}


foreach var of varlist gender age years_school empl_not {
areg  diff_`var' du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
}

restore
