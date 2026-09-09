
******************************************************************
****** TABLE 7 **********
**** Non- linearities/competition 
******************************************************************
******************************************************************
clear
use meet_the_press_data_elections , clear

**in the table we report the "lincom" (linear combination) estimates
g dummy0= news_TOT_lag<2
g dummy1= news_TOT_lag==2
g dummy2= news_TOT_lag==3

foreach var of varlist du_diff_news_TOT {
g pluto0_`var'=`var'*dummy0
g pluto1_`var'=`var'*dummy1
g pluto2_`var'=`var'*dummy2
}

label variable pluto0_du_diff_news_TOT "City has 1 newspaper"
label variable pluto1_du_diff_news_TOT "City has 2 newspapers"
label variable pluto2_du_diff_news_TOT "City has 3 newspapers"

quietly areg diff_turnout du_diff_news_TOT pluto0_du_diff_news_TOT pluto1_du_diff_news_TOT pluto2_du_diff_news_TOT diff_log_unem dummy0 dummy1 dummy2 diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
lincom du_diff_news_TOT+pluto0_du_diff_news_TOT
lincom du_diff_news_TOT+pluto1_du_diff_news_TOT
lincom du_diff_news_TOT+pluto2_du_diff_news_TOT

preserve
keep if recandidate==1

quietly areg diff_reelected du_diff_news_TOT pluto0_du_diff_news_TOT pluto1_du_diff_news_TOT pluto2_du_diff_news_TOT diff_log_unem dummy0 dummy1 dummy2 diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
lincom du_diff_news_TOT+pluto0_du_diff_news_TOT
lincom du_diff_news_TOT+pluto1_du_diff_news_TOT
lincom du_diff_news_TOT+pluto2_du_diff_news_TOT
restore 

quietly areg diff_avg_rev_collect du_diff_news_TOT pluto0_du_diff_news_TOT pluto1_du_diff_news_TOT pluto2_du_diff_news_TOT diff_log_unem dummy0 dummy1 dummy2 diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
lincom du_diff_news_TOT+pluto0_du_diff_news_TOT
lincom du_diff_news_TOT+pluto1_du_diff_news_TOT
lincom du_diff_news_TOT+pluto2_du_diff_news_TOT

preserve 
keep if term_limit==0

quietly areg diff_avg_rev_collect du_diff_news_TOT pluto0_du_diff_news_TOT pluto1_du_diff_news_TOT pluto2_du_diff_news_TOT diff_log_unem dummy0 dummy1 dummy2 diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
lincom du_diff_news_TOT+pluto0_du_diff_news_TOT
lincom du_diff_news_TOT+pluto1_du_diff_news_TOT
lincom du_diff_news_TOT+pluto2_du_diff_news_TOT

restore
