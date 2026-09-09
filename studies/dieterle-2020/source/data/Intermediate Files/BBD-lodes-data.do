use h_geocode d2b work_neigh_frac work_neigh work_total ui_avail_yr_avg_diff st_fips st_county_cd st_bound st_fips year using  Work-Across-Border-Census-Block.dta if d2b<=50, clear

merge m:1 st_bound st_fips using hilosamp.dta, nogen 

save BBD-lodes.dta, replace


