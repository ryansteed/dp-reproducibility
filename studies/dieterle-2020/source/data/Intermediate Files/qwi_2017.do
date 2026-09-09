clear

import delimited qwi_2017.csv, varnames(1)
drop sex agegrp ownercode firmsize seasonadj industry

drop if emp=="Emp"
destring emp empend emps empspv emptotal earns earnbeg earnhiras earnhirns earnseps, force replace

gen year=substr(time, 1,4)
destring year, replace

gen quarter=substr(time, 7, 1)
destring quarter, replace

gen qtr=quarterly(time, "YQ")

drop time

gen st_county_cd=""
replace st_county_cd="0"+state+"00"+county if strlen(state)==1 & strlen(county)==1
replace st_county_cd="0"+state+"0"+county if strlen(state)==1 & strlen(county)==2
replace st_county_cd="0"+state+county if strlen(state)==1 & strlen(county)==3
replace st_county_cd=state+"00"+county if strlen(state)==2 & strlen(county)==1
replace st_county_cd=state+"0"+county if strlen(state)==2 & strlen(county)==2
replace st_county_cd=state+county if strlen(state)==2 & strlen(county)==3

drop state county


save qwi_2017.dta, replace
