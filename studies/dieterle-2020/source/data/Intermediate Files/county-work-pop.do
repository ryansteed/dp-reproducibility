/*county-work-pop.do
This file crates a quarterly population estimate
by county to create the employemnt to population ratio
*/
clear
import delimited co-est00int-agesex-5yr.csv, varnames(1)

keep if sex==0
*Keep age 15 and up
keep if agegrp>3

gen st_county_cd=""
replace st_county_cd="0"+string(state)+"00"+string(county) if strlen(string(state))==1 & strlen(string(county))==1 
replace st_county_cd="0"+string(state)+"0"+string(county) if strlen(string(state))==1 & strlen(string(county))==2 
replace st_county_cd="0"+string(state)+string(county) if strlen(string(state))==1 & strlen(string(county))==3 
replace st_county_cd=string(state)+"00"+string(county) if strlen(string(state))==2 & strlen(string(county))==1 
replace st_county_cd=string(state)+"0"+string(county) if strlen(string(state))==2 & strlen(string(county))==2 
replace st_county_cd=string(state)+string(county) if strlen(string(state))==2 & strlen(string(county))==3 

forvalues t=2000/2009{
bysort st_county_cd: egen pop_over15`t'=total(popestimate`t') 
}

keep st_county_cd pop_over15*
duplicates drop

reshape long pop_over15@, i(st_county_cd) j(year) 



save county-work-pop-2000-2009, replace

clear
import delimited cc-est2016-alldata.csv, varnames(1)
drop if year<3
replace year=2007+year
keep if agegrp>3


gen st_county_cd=""
replace st_county_cd="0"+string(state)+"00"+string(county) if strlen(string(state))==1 & strlen(string(county))==1 
replace st_county_cd="0"+string(state)+"0"+string(county) if strlen(string(state))==1 & strlen(string(county))==2 
replace st_county_cd="0"+string(state)+string(county) if strlen(string(state))==1 & strlen(string(county))==3 
replace st_county_cd=string(state)+"00"+string(county) if strlen(string(state))==2 & strlen(string(county))==1 
replace st_county_cd=string(state)+"0"+string(county) if strlen(string(state))==2 & strlen(string(county))==2 
replace st_county_cd=string(state)+string(county) if strlen(string(state))==2 & strlen(string(county))==3 

bysort st_county_cd year: egen pop_over15=total(tot_pop)

keep st_county_cd year pop_over15
duplicates drop


save county-work-pop-2010-2016.dta, replace


append using county-work-pop-2000-2009.dta

gen qtr=yq(year, 1)

egen tempid=group(st_county_cd)

xtset tempid qtr

tsfill
bysort tempid: egen temp=mode(st_county_cd)
replace st_county_cd=temp if st_county_cd==""
drop temp
replace year=yofd(dofq(qtr)) if year==.

gen quarter=quarter(dofq(qtr))

gen temp=(f4.pop_over15-pop_over15)/4

replace pop_over15=l.pop_over15+l.temp if quarter==2
replace pop_over15=l.pop_over15+l2.temp if quarter==3
replace pop_over15=l.pop_over15+l3.temp if quarter==4

drop temp*

replace pop_over15=round(pop_over15)

save county-work-pop.dta, replace
