
use state_nm st_fips st_bound st_bound_nm using BBD-RD.dta, clear
keep state_nm st_fips st_bound st_bound_nm
duplicates drop
save temp-bound, replace



use stateuistatus.dta, clear

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


save ui-weekly.dta, replace

joinby st_fips using temp-bound

rename ui_avail ui
sort st_bound week st_fips
by st_bound week: gen tempid=_n

gen uidiff=ui-ui[_n-1] if st_bound==st_bound[_n-1] & week==week[_n-1] & tempid==tempid[_n-1]+1

replace uidiff=ui-ui[_n+1] if st_bound==st_bound[_n+1] & week==week[_n+1] & tempid==tempid[_n+1]-1

bysort st_bound st_fips: egen min=min(uidiff)
bysort st_bound st_fips: egen max=max(uidiff)

gen hiui=min==0 & max>0
gen loui=max==0 & min<0


gen hilosamp=hiui==1 | loui==1


preserve
save ui-weekly-hilo.dta, replace
keep if hiui==1
bysort week: egen temp=mean(uidiff)
keep week temp
duplicates drop
sort week
line temp week
restore

keep st_bound st_fips hiui loui hilosamp
duplicates drop

save hilosamp.dta, replace



