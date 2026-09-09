
foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
clear
insheet using `x'_xwalk.csv, comma
capture noisily: destring stwib wired1name wired2name wired3name stsldl stsldu, replace force
capture noisily: tostring stseconname tsubname stsldlname trib tribname stwibname, replace force
save `x'_xwalk.dta, replace
}

clear
use al_xwalk.dta
foreach x in ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
append using `x'_xwalk.dta
}

keep tabblk2010 st stusps stname cty ctyname trct trctname bgrp bgrpname
save LODES_xwalk.dta, replace

clear

foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
clear
capture noisily: insheet using `x'_od_`j'_JT00_`t'.csv, comma
if _N>0{
gen year=`t'
gen state="`x'"
gen file="`j'"
save `x'_od_`j'_JT00_`t'.dta, replace
}
}
}
}

clear
use LODES_xwalk
rename tabblk2010 geocode
preserve
rename * w_*
save w_LODES_xwalk.dta, replace
restore

preserve
rename * h_*
save h_LODES_xwalk.dta, replace
restore

clear
foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
clear
capture noisily: use w_geocode h_geocode s000 year state file using `x'_od_`j'_JT00_`t'.dta
if _N>0{
merge m:1 h_geocode using h_LODES_xwalk, keepusing(h_st h_stusps h_stname h_cty h_ctyname)
drop if _merge==2
drop _merge
merge m:1 w_geocode using w_LODES_xwalk,  keepusing(w_st w_stusps w_stname w_cty w_ctyname)
drop if _merge==2
drop _merge
save `x'_`j'_`t'_temp_xwalk.dta, replace
}
}
}
}


foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
clear
capture noisily: use `x'_`j'_`t'_temp_xwalk.dta
if _N>0{
collapse (sum) s000, by(h_st h_stusps h_stname h_cty h_ctyname w_st w_stusps w_stname year)
save `x'_`j'_`t'_temp_xwalk_county.dta
}
}
}
}

clear
foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
capture noisily: append using `x'_`j'_`t'_temp_xwalk_county.dta
}
}
}

collapse (sum) s000, by(h_st h_stusps h_stname h_cty h_ctyname w_st w_stusps w_stname year)
sort year h_st h_cty w_st
bysort h_cty year: egen lodes_total_emp=total(s000)
save LODES_JT00_HomeCounty_WorkState.dta, replace



*********************************
*********************************
*********************************
*********************************

foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
clear
capture noisily: use `x'_`j'_`t'_temp_xwalk.dta
if _N>0{
collapse (sum) s000, by(h_st h_stusps h_stname w_st w_stusps w_stname  w_cty w_ctyname year)
save `x'_`j'_`t'_temp_xwalk_county_work.dta
}
}
}
}

clear
foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
capture noisily: append using `x'_`j'_`t'_temp_xwalk_county_work.dta
}
}
}

collapse (sum) s000, by(h_st h_stusps h_stname w_st w_stusps w_stname  w_cty w_ctyname year)
sort year w_st w_cty h_st
bysort w_cty year: egen lodes_total_emp=total(s000)
save LODES_JT00_WorkCounty_HomeState.dta, replace

