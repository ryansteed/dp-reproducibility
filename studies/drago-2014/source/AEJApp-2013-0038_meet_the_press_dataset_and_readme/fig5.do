clear
use meet_the_press_data_elections, clear

***********
*TURNOUT
***********
sort id_city_istat_2009 year

g dm1=du_diff_news_TOT[_n-1]
g dm2=du_diff_news_TOT[_n-2]

g dp1=du_diff_news_TOT[_n+1]
g dp2=du_diff_news_TOT[_n+2]

areg diff_turnout du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(du_diff_news_TOT,replace)

areg diff_turnout dp1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne , r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp1,replace)
areg diff_turnout dp2 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne , r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp2,replace)
areg diff_turnout dm1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne , r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm1,replace)
areg diff_turnout dm2 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne , r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm2,replace)

preserve
use "du_diff_news_TOT.dta",clear
append using "dp1.dta"
append using "dp2.dta"
append using "dm1.dta"
append using "dm2.dta"

gen year=1 if parm=="dm1"
replace year=2 if parm=="dm2"

replace year=0 if parm=="du_diff_news_TOT"
replace year=-1 if parm=="dp1"
replace year=-2 if parm=="dp2"

eclplot estimate min95 max95 year,yline(0) xtitle("Terms from change in number local editions") ytitle("Change in turnout rate") name(graph1)
restore

erase "du_diff_news_TOT.dta"
erase "dp1.dta"
erase "dp2.dta"
erase "dm1.dta"
erase "dm2.dta"


***********
*REELECTION
***********

preserve

keep if recandidate==1
areg  diff_reelected du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(du_diff_news_TOT,replace)

areg  diff_reelected dp1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp1,replace)
areg  diff_reelected dp2 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp2,replace)
areg  diff_reelected dm1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm1,replace)
areg  diff_reelected dm2 diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm2,replace)

restore 

*different samples (preferred)
preserve
use "du_diff_news_TOT.dta",clear
append using "dp1.dta"
append using "dp2.dta"
append using "dm1.dta"
append using "dm2.dta"

gen year=1 if parm=="dm1"
replace year=2 if parm=="dm2"

replace year=0 if parm=="du_diff_news_TOT"
replace year=-1 if parm=="dp1"
replace year=-2 if parm=="dp2"

eclplot estimate min95 max95 year,yline(0) xtitle("Terms from change in number local editions") ytitle("Change in reelection rate") name(graph2)
restore

erase "du_diff_news_TOT.dta"
erase "dp1.dta"
erase "dp2.dta"
erase "dm1.dta"
erase "dm2.dta"

*********************
*SPEED OF COLLECTION
********************
*all sample
areg  diff_avg_rev_collect du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(du_diff_news_TOT,replace)

areg  diff_avg_rev_collect dp1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp1,replace)
areg  diff_avg_rev_collect dp2 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp2,replace)
areg  diff_avg_rev_collect dm1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm1,replace)
areg  diff_avg_rev_collect dm2 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm2,replace)

*different samples (preferred)
preserve
use "du_diff_news_TOT.dta",clear
append using "dp1.dta"
append using "dp2.dta"
append using "dm1.dta"
append using "dm2.dta"

gen year=1 if parm=="dm1"
replace year=2 if parm=="dm2"

replace year=0 if parm=="du_diff_news_TOT"
replace year=-1 if parm=="dp1"
replace year=-2 if parm=="dp2"

eclplot estimate min95 max95 year,yline(0) xtitle("Terms from change in number local editions") ytitle("Change in speed of collection" "(all sample)") name(graph3)
restore

erase "du_diff_news_TOT.dta"
erase "dp1.dta"
erase "dp2.dta"
erase "dm1.dta"
erase "dm2.dta"

*********************
*SPEED OF COLLECTION
********************
*non-binding term limit
preserve
keep if term_limit==0
areg  diff_avg_rev_collect du_diff_news_TOT diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(du_diff_news_TOT,replace)

areg  diff_avg_rev_collect dp1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp1,replace)
areg  diff_avg_rev_collect dp2 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dp2,replace)
areg  diff_avg_rev_collect dm1 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm1,replace)
areg  diff_avg_rev_collect dm2 diff_log_unem diff_own* diff_delta_log* diff_logpop_res_tagliacarne, r cluster(id_city_istat_2009) absorb(group_year_areageog)
parmest, saving(dm2,replace)
restore

preserve
use "du_diff_news_TOT.dta",clear
append using "dp1.dta"
append using "dp2.dta"
append using "dm1.dta"
append using "dm2.dta"

gen year=1 if parm=="dm1"
replace year=2 if parm=="dm2"

replace year=0 if parm=="du_diff_news_TOT"
replace year=-1 if parm=="dp1"
replace year=-2 if parm=="dp2"

eclplot estimate min95 max95 year,yline(0) xtitle("Terms from change in number local editions") ytitle("Change in speed of collection" "(non-binding term limit)") name(graph4)
restore


erase "du_diff_news_TOT.dta"
erase "dp1.dta"
erase "dp2.dta"
erase "dm1.dta"
erase "dm2.dta"


graph combine graph1 graph2 graph3 graph4



