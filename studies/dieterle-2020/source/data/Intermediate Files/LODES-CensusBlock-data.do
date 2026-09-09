
clear

foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
clear
capture noisily: use `x'_`j'_`t'_temp_xwalk.dta
if _N>0{
collapse (sum) s000, by(h_geocode h_st h_stusps h_stname h_cty h_ctyname w_st w_stusps w_stname year)
save `x'_`j'_`t'_temp_xwalk_cb.dta
}
}
}
}

clear
foreach x in al ar az ca co ct dc de fl ga ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy{
forvalues t=2002/2011{
foreach j in aux main{
capture noisily: append using `x'_`j'_`t'_temp_xwalk_cb.dta
}
}
}

collapse (sum) s000, by(h_geocode h_st h_stusps h_stname h_cty h_ctyname w_st w_stusps w_stname year)
sort year h_geocode h_st h_cty w_st
bysort h_geocode year: egen lodes_total_emp=total(s000)
save LODES_JT00_HomeCensusBlock_WorkState.dta, replace


save LODES_JT00_HomeCensusBlock_WorkState.dta, replace

