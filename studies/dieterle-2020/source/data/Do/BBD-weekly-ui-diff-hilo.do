*Generate Table E.1 and Figure 2
use ui-weekly-hilo.dta, clear

*Table E.1
tab st_bound_nm if hilo==1
tab st_bound_nm if hilo==0

*Figure 2
keep if hiui==1
bysort week: egen temp=mean(uidiff)
keep week temp
duplicates drop
sort week
line temp week
