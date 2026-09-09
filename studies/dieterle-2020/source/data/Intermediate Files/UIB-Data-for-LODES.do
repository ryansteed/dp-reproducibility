clear
use stateuistatus.dta

#delimit ;
  gen nweeks=26 if state_euc1<.;
  replace nweeks=nweeks+totavail_euc1 if state_euc1==1;
  replace nweeks=nweeks+totavail_euc2 if state_euc2==1;
  replace nweeks=nweeks+totavail_euc3 if state_euc3==1;
  replace nweeks=nweeks+totavail_euc4 if state_euc4==1;
  replace nweeks=nweeks+totavail_eb if state_eb==1 | state_eb==2;
#delimit cr

keep state month day year week nweeks
rename nweeks ui_avail

rename state st_cens

merge m:1 st_cens using statecodes.dta
drop _merge

drop st_cens state st_soi



xtset st_fips week, delta(7)

gen temp=.
forvalues t=2004/2011{
replace temp=abs(week-td(1apr`t')) if year==`t'
}

bysort year: egen temp2=min(temp)
gen obs=temp==temp2

drop temp*

xtset st_fips week, delta(7)

bysort st_fips: gen temp=sum(obs)
replace temp=temp-1 if obs==1

bysort st_fips temp: gen obs2=abs(_n-52)
bysort st_fips temp: replace obs2=abs(_n-53) if temp==6

bysort temp: egen ref_week=max(week)
format %td ref_week

xtset st_fips week, delta(7)


drop day month year week temp obs

reshape wide ui_avail, i(st_fips st_name ref_week) j(obs2)

egen ui_avail_yr_avg=rowmean(ui_avail0-ui_avail51)

gen year=year(ref_week)


save UIB-data-for-LODES.dta, replace
