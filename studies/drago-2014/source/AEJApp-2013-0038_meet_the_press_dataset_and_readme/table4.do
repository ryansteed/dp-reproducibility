***************************************************************************************
****************    TABLE 4 -- READERSHIP & ELECTORAL OUTCOMES    *********************
***************************************************************************************
clear
use meet_the_press_data_elections , clear
preserve
clear
use meet_the_press_data_readership

*READERSHIP, col 1
*READERSHIP WITH RESPECT TO ALL TYPES OF ENTRY (PRINT+ONLINE)
areg diff_news_readership_pc mean_entry_pc  diff_mean_own*    diff_log_unem diff_delta_log*  , r cluster(provincia_ADS) absorb(group_year_areageog)

restore

***TURNOUT, col 2

eststo newsturnout: areg diff_turnout du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne , r cluster(id_city_istat_2009) absorb(group_year_areageog)

***RECANDIDATE & REELECTION, col 3 and 4

preserve
keep if term_limit==0
eststo: areg  diff_recandidate du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
restore 

preserve
keep if recandidate==1
eststo newsreelected: areg  diff_reelected du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
restore 

*** EDITED by Donna
estout using "../../results/table4.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace