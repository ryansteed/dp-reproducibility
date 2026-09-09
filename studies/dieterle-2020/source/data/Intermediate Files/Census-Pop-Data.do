*Census-Pop-Data.do


clear
/*Calculate distance to border- border counties only
Note: must edit the nearstat.ado file to create
variables using double precision
*/
*Get list of border counties
use border-counties.dta if border_county==1
keep st_county_cd
duplicates drop
save county-list.dta, replace

clear
use US_trim_dbf.dta
gen st_county_cd=STATEFP10+COUNTYFP10
merge m:1 st_county_cd using county-list.dta
keep if _merge==3
drop _merge
destring STATEFP10, gen(st_fips)
save county-pairs-dbf.dta, replace

********************
preserve
keep GIS_id
rename GIS_id _ID
merge 1:m _ID using US_trim_coord.dta

keep if _merge==3
drop _merge
save county-pairs-coord.dta, replace
restore
********************



forvalues i=1/56{
clear
capture noisily: use county-pairs-dbf.dta if st_fips==`i'

if _N>0{
merge 1:1 _n using FIPS`i'-state-border-cord.dta
drop _merge
xtile temp=GIS_id, nq(100)
gen near_bor=""
gen d2b=.
forvalues j=1/100{
nearstat y_CB_cent x_CB_cent if temp==`j', near(_Y _X) dist(temp2) favor(speed) nid(state_bor_fips temp3)
replace near_bor=temp3 if temp==`j'
replace d2b=temp2 if temp==`j'
drop temp2 temp3
}
keep GIS_id-st_county_cd near_bor d2b
save FIPS`i'-d2b-dbf.dta
}
}


*

clear

*Now for nonborders - can be skipped if only replicating results 
*Get list of non-border counties


use US_trim_dbf.dta
gen st_county_cd=STATEFP10+COUNTYFP10
merge m:1 st_county_cd using county-list.dta
keep if _merge==1
drop _merge
destring STATEFP10, gen(st_fips)
save nonborder-county-dbf.dta, replace


forvalues i=1/56{
clear
capture noisily: use nonborder-county-dbf.dta if st_fips==`i'

if _N>0{
merge 1:1 _n using FIPS`i'-state-border-cord.dta
drop _merge
xtile temp=GIS_id, nq(1000)
gen near_bor=""
gen d2b=.
forvalues j=1/1000{
nearstat y_CB_cent x_CB_cent if temp==`j', near(_Y _X) dist(temp2) favor(speed) nid(state_bor_fips temp3)
replace near_bor=temp3 if temp==`j'
replace d2b=temp2 if temp==`j'
drop temp2 temp3
}
keep GIS_id-st_county_cd near_bor d2b
save FIPS`i'-nonborder-d2b-dbf.dta
}
}




*Generate distance moments
/*START WITH CENSUS BLOCKS THAT ARE CLOSEST TO THE
WITHIN COUNTY MODAL STATE BORDER
*/

clear

forvalues i=1/56{
clear
capture noisily: use FIPS`i'-d2b-dbf.dta

if _N>0{


bysort st_county_cd: egen near_mode=mode(near_bor)
gen modal_block=near_bor==near_mode
tab modal_block

egen temp=group(st_county_cd)
sum temp
local m=r(max)
gen double mu1=.
gen double mu2=.
gen double mu3=.
gen double mu4=.
gen double mu5=.
gen double mu6=.
forvalues h=1/6{
gen double temp`h'=d2b^`h'
forvalues j=1/`m'{
mean temp`h' [fweight=POP10] if temp==`j' & modal_block==1
replace  mu`h'=_b[temp`h'] if temp==`j' & modal_block==1
}
drop temp`h'
}

drop temp
save temp`i', replace
}
}

clear
use temp1
forvalues i=2/56{
capture noisily: append using temp`i'.dta
}

save All-States-Border-County-Pop-Dist.dta, replace

preserve
keep st_county_cd near_mode mu*
drop if mu1==.
duplicates drop
save Border-County-Pop-Moments.dta, replace


restore







*Repeat for nonborders - again can be skipped for replicating current results
/*START WITH CENSUS BLOCKS THAT ARE CLOSEST TO THE
WITHIN COUNTY MODAL STATE BORDER
*/
clear

forvalues i=1/56{
clear
capture noisily: use FIPS`i'-nonborder-d2b-dbf.dta

if _N>0{


bysort st_county_cd: egen near_mode=mode(near_bor), maxmode
gen modal_block=near_bor==near_mode
tab modal_block

egen temp=group(st_county_cd)
sum temp
local m=r(max)
gen double mu1=.
gen double mu2=.
gen double mu3=.
gen double mu4=.
gen double mu5=.
gen double mu6=.
forvalues h=1/6{
gen double temp`h'=d2b^`h'
forvalues j=1/`m'{
mean temp`h' [fweight=POP10] if temp==`j' & modal_block==1
replace mu`h'=_b[temp`h'] if temp==`j' & modal_block==1
}
drop temp`h'
}

drop temp
save temp`i', replace
}
}

clear
use temp1
forvalues i=2/56{
capture noisily: append using temp`i'.dta
}

save All-States-Non-Border-County-Pop-Dist.dta, replace

preserve
keep st_county_cd near_mode mu*
drop if mu1==.
duplicates drop
save Non-Border-County-Pop-Moments.dta, replace


restore



*Now generate moments for nonmodal
clear
use All-States-All-County-Pop-Dist.dta

keep if modal_block==0
drop mu*
rename d2b d2b_nearest

gen near_mode_grp=.
forvalues i=1/56{
capture noisily: egen temp=group(near_mode) if st_fips==`i'
capture noisily: replace near_mode_grp=temp if st_fips==`i'
capture noisily: drop temp
}

save temp-nonmodal-census-blocks.dta, replace

keep st_fips near_mode near_mode_grp
duplicates drop
gen state_bor_fips=near_mode
save temp-mode, replace


forvalues i=1/56{
clear
use temp-mode if st_fips==`i'
if _N>0{
merge 1:m state_bor_fips using FIPS`i'-state-border-cord.dta
drop _merge
sum near_mode_grp
local max=r(max)

forvalues j=1/`max' {
preserve
keep if near_mode_grp==`j'
drop st_fips near_mode near_mode_grp
save FIPS`i'-state-border-cord-group`j'.dta, replace
restore
}
}
}

clear


forvalues i=1/56{
forvalues j=1/8{
clear
use temp-nonmodal-census-blocks.dta if st_fips==`i' & near_mode_grp==`j'

if _N>0{
merge 1:1 _n using FIPS`i'-state-border-cord-group`j'.dta
drop _merge
gen d2b_nonmodal=.

nearstat y_CB_cent x_CB_cent, near(_Y _X) dist(temp) favor(speed)
replace d2b_nonmodal=temp
drop temp
keep GIS_id-state_bor_fips d2b_nonmodal
save FIPS`i'-nonmodal-group`j'-d2b-dbf.dta, replace
}
}
}



*Merge border, and nonborder sets
clear


use Border-County-Pop-Moments.dta
append using Non-Border-County-Pop-Moments.dta
duplicates drop
save All-County-Pop-Moments.dta, replace

clear 
use All-States-Border-County-Pop-Dist.dta
append using All-States-Non-Border-County-Pop-Dist.dta
duplicates drop
save All-States-All-County-Pop-Dist.dta, replace


*Now nonmodal blocks
clear

use FIPS1-nonmodal-group1-d2b-dbf.dta

forvalues i=1/56{
forvalues j=1/8{
capture noisily: append using FIPS`i'-nonmodal-group`j'-d2b-dbf.dta
}
}
duplicates drop
drop if GIS_id==.

keep GIS_id d2b_nonmodal d2b_nearest

merge 1:1 GIS_id using All-States-All-County-Pop-Dist.dta

replace d2b=d2b_nonmodal if _merge==3
drop _merge d2b_nonmodal
order d2b_nearest, last


drop mu*

bysort st_county_cd: egen POP10_TOTAL=total(POP10)
bysort st_county_cd: egen CB_count=count(GIS_id)
gen wgt=(POP10*CB_count)/POP10_TOTAL

forvalues h=1/6{
bysort st_county_cd:  egen double mu`h'=mean((d2b^`h')*wgt)
}


save All-States-All-County-with-Nonmodal-Pop-Dist.dta, replace

preserve
keep st_county_cd POP10_TOTAL
duplicates drop
save county-total-population.dta, replace
restore

preserve
keep st_county_cd near_mode mu*
drop if mu1==.
duplicates drop
save All-States-All-County-with-Nonmodal-Pop-Moments.dta, replace

restore





