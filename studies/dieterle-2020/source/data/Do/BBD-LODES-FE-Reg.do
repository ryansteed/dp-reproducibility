*Generate estimates for Table 5
use h_geocode d2b work_neigh_frac ui_avail_yr_avg_diff st_county_cd year using Data/BBD-lodes.dta if d2b<=5, clear

xtset h_geocode year
eststo: xtreg work_neigh_frac ui_avail_yr_avg_diff i.year , fe vce(cluster st_county_cd)
eststo: xtreg work_neigh_frac ui_avail_yr_avg_diff l.ui_avail_yr_avg_diff i.year , fe vce(cluster st_county_cd)
eststo: xtreg work_neigh_frac ui_avail_yr_avg_diff l(1/3).ui_avail_yr_avg_diff i.year , fe vce(cluster st_county_cd)

*** EDITED by Ryan Steed
estout using "../../results/Table5.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***