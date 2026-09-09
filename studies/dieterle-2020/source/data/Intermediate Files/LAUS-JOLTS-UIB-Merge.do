clear

use "Intermediate Files/BLS-LAUS-All"
merge m:1 month year using "Intermediate Files/Jolts-Separation"

drop _merge



egen st_cn_id=group(st_county_cd)

gen temp=month+string(year)

gen temp2=monthly(temp, "MY")
gen qtr=qofd(dofm(temp2))
drop temp*

replace month="1" if month=="jan"
replace month="2" if month=="feb"
replace month="3" if month=="mar"
replace month="4" if month=="apr"
replace month="5" if month=="may"
replace month="6" if month=="jun"
replace month="7" if month=="jul"
replace month="8" if month=="aug"
replace month="9" if month=="sep"
replace month="10" if month=="oct"
replace month="11" if month=="nov"
replace month="12" if month=="dec"

destring month, replace

bysort st_cn_id qtr: egen sep_denom_qtr=total(sep_denom)
bysort st_cn_id qtr: egen sep_level_qtr=total(sep_level)
gen sep_rate_qtr=sep_level_qtr/sep_denom_qtr

gen emp_r=emp/labforce

foreach x of varlist emp emp_r labforce unemp unemp_r sep_level sep_rate sep_denom{
bysort st_cn_id qtr: egen temp=mean(`x')
replace `x'=temp
drop temp
}

gen quarter=1
replace quarter=2 if month==4 | month==5 | month==6
replace quarter=3 if month==7 | month==8 | month==9
replace quarter=4 if month==10 | month==11 | month==12

drop month
duplicates drop




merge m:1  st_fips qtr using UI-Benefits-Quarterly-Average-All.dta
drop if _merge==2
drop _merge


save LAUS-JOLTS-UIB.dta, replace



