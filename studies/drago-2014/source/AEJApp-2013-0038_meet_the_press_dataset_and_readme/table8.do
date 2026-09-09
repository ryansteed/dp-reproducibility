

******************************************************************
***********************TABLE 8**********
************* Decomposition of Effects ****
******************************************************************
******************************************************************
******************************************************************

clear
use meet_the_press_data_readership, clear

****READERSHIP WITH RESPECT TO ALL TYPES OF PRINT VS. ONLINE ENTRY
areg diff_news_readership_pc mean_entry_print_pc mean_entry_web_pc  diff_mean_own*    diff_log_unem diff_delta_log*  , r cluster(provincia_ADS) absorb(group_year_areageog)
test (mean_entry_print_pc-mean_entry_web_pc=0)

****READERSHIP WITH RESPECT TO LOCAL VS. NATIONAL (PRINT+ONLINE)
areg diff_news_readership_pc mean_entry_loc_pc mean_entry_naz_pc diff_mean_own*    diff_log_unem diff_delta_log*  , r cluster(provincia_ADS) absorb(group_year_areageog)
test (mean_entry_loc_pc-mean_entry_naz_pc=0)


****READERSHIP WITH RESPECT TO NEW VS. EXISTING
areg diff_news_readership_pc mean_entry_existing_news_pc mean_entry_new_news_pc  diff_mean_own*    diff_log_unem diff_delta_log*  , r cluster(provincia_ADS) absorb(group_year_areageog)
test (mean_entry_existing_news_pc-mean_entry_new_news_pc=0)

clear
use meet_the_press_data_elections

****TURNOUT****
areg  diff_turnout du_diff_print_news_TOT du_diff_web_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_print_news_TOT-du_diff_web_TOT=0)

areg  diff_turnout du_diff_loc_TOT du_diff_naz_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_loc_TOT-du_diff_naz_TOT=0)

areg  diff_turnout du_diff_existing_news_TOT du_diff_new_news_TOT  diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_existing_news_TOT-du_diff_new_news_TOT=0)

****REELECTION****
preserve 
keep if recandidate==1

areg  diff_reelected du_diff_print_news_TOT du_diff_web_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_print_news_TOT-du_diff_web_TOT=0)

areg  diff_reelected du_diff_loc_TOT du_diff_naz_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_loc_TOT-du_diff_naz_TOT=0)

areg  diff_reelected du_diff_existing_news_TOT du_diff_new_news_TOT  diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_existing_news_TOT-du_diff_new_news_TOT=0)

restore

****SPEED OF COLLECTION****

areg  diff_avg_rev_collect du_diff_print_news_TOT du_diff_web_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_print_news_TOT-du_diff_web_TOT=0)

areg  diff_avg_rev_collect du_diff_loc_TOT du_diff_naz_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_loc_TOT-du_diff_naz_TOT=0)

areg  diff_avg_rev_collect du_diff_existing_news_TOT du_diff_new_news_TOT  diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_existing_news_TOT-du_diff_new_news_TOT=0)

****SPEED OF COLLECTION if term limit==0****
preserve
keep if term_limit==0

areg  diff_avg_rev_collect du_diff_print_news_TOT du_diff_web_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_print_news_TOT-du_diff_web_TOT=0)

areg  diff_avg_rev_collect du_diff_loc_TOT du_diff_naz_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_loc_TOT-du_diff_naz_TOT=0)

areg  diff_avg_rev_collect du_diff_existing_news_TOT du_diff_new_news_TOT  diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
test (du_diff_existing_news_TOT-du_diff_new_news_TOT=0)

restore

