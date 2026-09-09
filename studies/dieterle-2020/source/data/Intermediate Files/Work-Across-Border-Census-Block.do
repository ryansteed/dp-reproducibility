
use state_nm st_fips st_county_cd year qtr near_mode st_bound neigh_st st_bound_qtr_id using BBD-RD-No-Drop.dta, clear

gen county_cd=substr(st_county_cd, 3,3)
destring st_county_cd, gen(h_cty)
gen w_st=neigh_st
keep state_nm st_fips county_cd st_county_cd h_cty year near_mode st_bound neigh_st w_st
duplicates drop
save County-By-Border-for-LODES-yearly.dta, replace


clear
use STATEFP10 st_fips COUNTYFP10 TRACTCE10 BLOCKCE BLOCKID10 PARTFLG HOUSING10 POP10 st_county_cd near_bor d2b near_mode modal_block POP10_TOTAL using All-States-All-County-with-Nonmodal-Pop-Dist.dta
destring BLOCKID10, gen(h_geocode)
save Census-2010-D2B-CensusBlock-for-LODES.dta, replace

clear
use LODES_JT00_HomeCensusBlock_WorkState.dta
merge m:1 h_geocode using Census-2010-D2B-CensusBlock-for-LODES.dta, keepusing(st_fips POP10 st_county_cd d2b near_mode POP10_TOTAL)
drop if _merge==2
drop _merge

gen temp1=real(substr(near_mode,1,2 )) if length(near_mode)==9
replace temp1=real(substr(near_mode,1,1 )) if length(near_mode)==8
replace temp1=real(substr(near_mode,1,1 )) if length(near_mode)==7
gen temp2=real(substr(near_mode,4,2 )) if length(near_mode)==9
replace temp2=real(substr(near_mode,3,2 )) if length(near_mode)==8
replace temp2=real(substr(near_mode,3,1 )) if length(near_mode)==7

gen neigh_st=temp1 if temp1~=st_fips
replace neigh_st=temp2 if temp1==st_fips
drop temp*
gen temp=neigh==w_st


bysort h_geocode year: egen work_neigh=total(s000) if temp==1
bysort h_geocode year: egen work_total=total(s000)

bysort h_geocode year: egen temp2=mode(work_neigh)
replace work_neigh=temp2 if work_neigh==.
drop temp2
replace work_neigh=0 if work_neigh==. & work_total<.
gen work_neigh_frac=work_neigh/work_total

drop w_st w_stusps w_stname temp s000
duplicates drop



joinby h_cty near_mode year using County-By-Border-for-LODES-yearly.dta


merge m:1  st_fips year using UIB-data-for-LODES.dta

drop if _merge==2
drop _merge

save temp1, replace

keep st_bound st_fips year ui_avail*
bysort st_bound st_fips year: keep if _n==1
foreach x of varlist ui_avail*{
bysort st_bound year: egen `x'_min=min(`x')
bysort st_bound year: egen `x'_max=max(`x')
gen `x'_diff=`x'-`x'_max if `x'==`x'_min
replace `x'_diff=`x'-`x'_min if `x'==`x'_max
}

keep st_bound st_fips year *_diff
save temp2, replace

use temp1, clear
merge m:1 st_bound st_fips year using temp2, nogen

erase temp1.dta 
erase temp2.dta

xtset h_geocode year
format %20.0g h_geocode

set seed 7523957
gen ran=runiform()
bysort h_geocode: replace ran=ran[1]

drop h_stname h_ctyname state_nm st_name county_cd w_st
compress

save Work-Across-Border-Census-Block.dta, replace

