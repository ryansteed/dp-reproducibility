*Use county-pair.dta from Dube et al.
use county-pair.dta, clear
gen border_county=1

drop pair_id
duplicates drop

merge 1:1 countyreal using countylist.dta, nogen

gen st_county_cd=string(countyreal)
replace st_county_cd="0"+st_county_cd if strlen(st_county_cd)==4

drop countyreal


save border_counties.dta, replace
