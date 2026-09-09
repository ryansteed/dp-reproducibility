*Census-GIS-data.do

clear

forvalues i=1/9{
capture noisily: shp2dta using tabblock2010_0`i'_pophu, database(state0`i'_dbf) coordinates(state0`i'_coord) genid(GIS_id) gencentroids(CB_cent) replace
}

forvalues i=10/56{
capture noisily: shp2dta using tabblock2010_`i'_pophu, database(state`i'_dbf) coordinates(state`i'_coord) genid(GIS_id) gencentroids(CB_cent) replace
}


use state01_dbf
sum GIS_id
local g=r(max)
save state01_dbf_new, replace
use state01_coord
save state01_coord_new, replace
forvalues i=4/6{
clear
use state0`i'_coord
replace _ID=_ID+`g'
save state0`i'_coord_new, replace
clear
use state0`i'_dbf
replace GIS_id=GIS_id+`g'
save state0`i'_dbf_new, replace
sum GIS_id
local g=r(max)
}
forvalues i=8/9{
clear
use state0`i'_coord
replace _ID=_ID+`g'
save state0`i'_coord_new, replace
clear
use state0`i'_dbf
replace GIS_id=GIS_id+`g'
save state0`i'_dbf_new, replace
sum GIS_id
local g=r(max)
}

forvalues i=10/13{
clear
use state`i'_coord
replace _ID=_ID+`g'
save state`i'_coord_new, replace
clear
use state`i'_dbf
replace GIS_id=GIS_id+`g'
save state`i'_dbf_new, replace
sum GIS_id
local g=r(max)
}
forvalues i=16/42{
clear
use state`i'_coord
replace _ID=_ID+`g'
save state`i'_coord_new, replace
clear
use state`i'_dbf
replace GIS_id=GIS_id+`g'
save state`i'_dbf_new, replace
sum GIS_id
local g=r(max)
}
forvalues i=44/51{
clear
use state`i'_coord
replace _ID=_ID+`g'
save state`i'_coord_new, replace
clear
use state`i'_dbf
replace GIS_id=GIS_id+`g'
save state`i'_dbf_new, replace
sum GIS_id
local g=r(max)
}
forvalues i=53/56{
clear
use state`i'_coord
replace _ID=_ID+`g'
save state`i'_coord_new, replace
clear
use state`i'_dbf
replace GIS_id=GIS_id+`g'
save state`i'_dbf_new, replace
sum GIS_id
local g=r(max)
}

clear
use state01_dbf_new
forvalues i=2/9{
capture noisily: append using state0`i'_dbf_new
}
forvalues i=10/56{
capture noisily: append using state`i'_dbf_new
}

save US_dbf.dta, replace

clear
use state01_coord_new
forvalues i=2/9{
capture noisily: append using state0`i'_coord_new
}
forvalues i=10/56{
capture noisily: append using state`i'_coord_new
}

save US_coord.dta, replace

********
gen GIS_id=_ID
merge m:1 GIS_id using US_dbf.dta, nogen

*Remove uninhabited census blocks in water
drop if real(substr(BLOCKCE,1,1))==0

keep _ID _Y _X
save US_trim_coord.dta, replace

keep _ID
duplicates drop
rename _ID GIS_id
save trim_list.dta, replace

use US_dbf.dta, clear
merge 1:1 GIS_id using trim_list.dta, nogen keep(match)
save US_trim_dbf.dta, replace
  
*Create state border coordinates data
use US_trim_coord.dta, clear
drop if _X==.

gen GIS_id=_ID
merge m:1 GIS_id using US_trim_dbf.dta, nogen keep(match)
destring STATE, gen(st_fips)
bysort _Y _X: egen max=max(st_fips)
bysort _Y _X: egen min=min(st_fips)
gen diff=max-min

keep if diff>0
*drop identical coordinates in same state
duplicates drop _X _Y st_fips, force

bysort _Y _X: egen rank=rank(st_fips), track

gen st_fips1=st_fips if rank==1
gen st_fips2=st_fips if rank==2
gen st_fips3=st_fips if rank==3
gen st_fips4=st_fips if rank==4

bysort _Y _X: egen temp=mode(st_fips1)
replace st_fips1=temp
drop temp
bysort _Y _X: egen temp=mode(st_fips2)
replace st_fips2=temp
drop temp
bysort _Y _X: egen temp=mode(st_fips3)
replace st_fips3=temp
drop temp
bysort _Y _X: egen temp=mode(st_fips4)
replace st_fips4=temp
drop temp
gen state_bor_fips=string(st_fips1)+"-"+string(st_fips2)+"-"+string(st_fips3)+"-"+string(st_fips4)

gen st_bor=1

keep _ID _X _Y st_fips? state_bor state_bor_fips
replace _ID=-1
duplicates drop


*Create State-specific border files

sum st_fips1
local min=r(min)
local max=r(max)
forvalues i=`min'/`max'{
preserve
keep if st_fips1==`i'
if _N>0{
save FIPS`i'-state-border-cord.dta
}
restore
}

keep _X _Y _ID state_bor state_bor_fips
duplicates drop
save US-state-borders-coord.dta, replace










