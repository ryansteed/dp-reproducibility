***************************************************************************************
****************    TABLE 6 -- GOVERNMENT EFFICIENCY      *****************************
***************************************************************************************

clear
use meet_the_press_data_elections , clear

*col 1-2
foreach var of varlist avg_rev_collect avg_expend_speed {
eststo `var': areg  diff_`var' du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
}
*** EDITED by Donna
estout using "../../results/table6.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*col 3-4
preserve 
keep if term_limit==0
foreach var of varlist avg_rev_collect avg_expend_speed {
areg  diff_`var' du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
}
restore



***********
