set matsize 11000
use "data\county_level_variables.dta", clear
sort countyfips year
save temp.dta, replace

**restrict counties to border counties
use "data\contiguous_countypairs_tx_border_states.dta", clear
sort countyfips
joinby countyfips using temp.dta,  _merge(_merge)
tab _merge
**to keep only contiguos county pairs
keep if _merge==3
drop _merge
sort countyfips year
sort pair countyfips

merge m:1 countyfips year using "data\countypop_nber.dta"
keep if _merge==3|_merge==1
drop _merge

destring statefips, replace

**sample selection (1)
drop if lf==0
drop if lf>countypop15plus
gen lfpr=lf/countypop15plus
sum lfpr, det
keep if lfpr>=r(p1) & lfpr<=r(p99)

***end of sample selection

egen groupcountyfips=group(countyfips)
sort countyfips year

**sample selection (2)
**keep if year>=1992 & year<=2007
**create balalnced panel of counties?
egen count=count(year), by(countyfips pair)
keep if count==16

**convert lfpr to percent
replace lfpr=lfpr*100

cap drop texas
gen texas=stateusps=="TX"
cap drop post1997
gen post1997=year>=1998
gen texas_post1997=texas*post1997
cap drop post2003
gen post2003=year>=2004
gen texas_post2003=texas*post2003
gen post1997to2003=year>=1998 & year<=2003
gen texas_post1997to2003=texas*post1997to2003
egen t=group(year)
egen groupstatefips=group(statefips)
egen groupstateusps=group(stateusps)

char year[omit] 1997
char statefips[omit] 1
char groupstateusps[omit] 1
char pair[omit] 1

xi i.year i.statefips*t i.pair*i.year

label var texas_post1997 "Texas X Post 1997"
label var texas_post2003 "Texas X Post 2003"
label var texas_post1997to2003 "Texas X 1998-2003"

**this sample is just border state but create border state dummy
gen borderstate=stateusps=="TX"|stateusps=="OK"|stateusps=="NM"|stateusps=="LA"|stateusps=="AR"
tab stateusps


**make  a table of estimates for the policy variable texas_post
**don't include lagged house prices as we lose lots of observations
**dont include division by year effects as almost all of them would be in the same division
estimates clear
eststo: areg lfpr _Iyear* texas_post1997to2003 texas_post2003 [w=countypop], ab(groupcountyfips) robust cluster(groupcountyfips)
eststo: areg lfpr _Iyear* _IstaXt_* texas_post1997to2003 texas_post2003 [w=countypop], ab(groupcountyfips) robust cluster(groupcountyfips)
eststo: areg lfpr _IpaiXyea* texas_post1997to2003 texas_post2003 [w=countypop], ab(groupcountyfips) robust cluster(groupcountyfips)

esttab using "$resultsdir\Table A1.rtf", replace title("Table A1: Difference-in-Differences Estimates using only Border Counties") keep(texas_post1997to2003 texas_post2003) order(texas_post1997to2003 texas_post2003) nocons b(%7.5f) se(%7.3f) nonotes starlevels(* 0.10 ** 0.05) label  sfmt(%12.4f) nomtitles scalars("r2_a AdjR-Sq") indicate("County Fixed Effects=_cons*" "Year Fixed Effects=_Iyear*" "State X Linear Trend=_IstaXt_*" "County-Pair X Year Effects=_IpaiXyea*") 

