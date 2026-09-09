clear

/*Use stateuistatus.dta from Rothstein for up to 2011q1 
and merge to similarly formatted file from EUC EB trigger reports
*/
use stateuistatus.dta
append using stateuistatus-2011q2-2012q1.dta

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


/*
Create quarterly averages of the unemployment benefits
*/

xtset st_fips week
tsfill

bysort st_fips: egen temp=mode(st_name)
replace st_name=temp if st_name==""
drop temp

gen qtr=qofd(week)


sort st_fips week
replace ui_avail=ui_avail[_n-1] if ui_avail==. & st_fips==st_fips[_n-1]

bysort st_fips qtr: egen ui_avail_qtr_avg=mean(ui_avail)

keep st_fips st_name qtr ui_avail_qtr_avg
duplicates drop


save UI-Benefits-Quarterly-Average-All.dta, replace
