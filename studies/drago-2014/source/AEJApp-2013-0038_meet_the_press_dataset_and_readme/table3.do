*********
**TABLE 3 
*********
clear
use meet_the_press_data_elections , clear

**RECODING ENTRY

gen entry1=0
replace entry1=1 if entry==1
replace entry1=-1 if exit==1
drop entry exit
rename entry1 entry

*YEAR FIXED EFFECTS, col 1
reg 	 entry news_TOT_lag log_unem  delta_log*   logpop_res_tagliacarne i.year,  r   cluster(id_city_istat_2009)


*CITY and year FIXED EFFECTS, col 2
areg 	 entry news_TOT_lag log_unem  delta_log*   logpop_res_tagliacarne i.year,  r   cluster(id_city_istat_2009) absorb(id_city_istat_2009)


*CITY, Macro region and year FIXED EFFECTS, col 3
areg 	 entry news_TOT_lag log_unem  delta_log*   logpop_res_tagliacarne id_group_year_areageog*,  r   cluster(id_city_istat_2009) absorb(id_city_istat_2009)


gen party_maj_other=1
replace party_maj_other=0 if party_maj_left==1
replace party_maj_other=0 if party_maj_right==1
replace party_maj_other=0 if party_maj_center==1

*CITY, Macro region and year FIXED EFFECTS - POLITICAL CONTROLS, col 4
areg 	 entry news_TOT_lag log_unem  delta_log*   logpop_res_tagliacarne party_maj_left party_maj_right party_maj_center term_limit id_group_year_areageog*,  r   cluster(id_city_istat_2009) absorb(id_city_istat_2009)


