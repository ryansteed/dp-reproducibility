
local year_0 2008
local month_0 12
local year_0 2008
local month_0 12
local year_1 2009
local month_1 1

local l_year_0 2008
local l_month_0 4
local l_year_1 2008
local l_month_1 11

cd "C:\Documents and Settings\William Woolston\My Documents\My Dropbox\ARRA\Haver Data July 13 2010\Cleaned Version"
use "C:\Documents and Settings\William Woolston\My Documents\My Dropbox\ARRA\Haver Data July 13 2010\Haver Data\final_cleaned_data.dta", clear




*****
*	Keep just the needed dates
*****
gen time_temp = time

preserve
keep if time_temp ==(`year_0'-1960)*12 + (`month_0' -1)
xpose, clear varname
drop if _n==1
rename _varname data_series
rename v1 _`year_0'`month_0'
save "Junk\year_0_temp", replace
restore

preserve
keep if time_temp ==(`year_1'-1960)*12 + (`month_1' -1)
xpose, clear varname
drop if _n==1
rename _varname data_series
rename v1 _`year_1'`month_1'
save "Junk\year_1_temp", replace
restore

preserve
keep if time_temp ==(`l_year_0'-1960)*12 + (`l_month_0' -1)
xpose, clear varname
drop if _n==1
rename _varname data_series
rename v1 _`l_year_0'`l_month_0'
save "Junk\l_year_0_temp", replace
restore

preserve
keep if time_temp ==(`l_year_1'-1960)*12 + (`l_month_1' -1)
xpose, clear varname
drop if _n==1
rename _varname data_series
rename v1 _`l_year_1'`l_month_1'
save "Junk\l_year_1_temp", replace

cd "Junk"
foreach v in l_year_0 year_1 year_0 {
	merge data_series using "`v'_temp.dta", sort
	assert _merge==3
	drop _merge
	}
cd ..
drop if data_series=="time_temp"

capture drop state_abrev
gen state_abrev = substr(data_series,1,2) 
gen data_type = substr(data_series,3,.)
order state_abrev data_type 



*****
*Relabels the variables
*****
*CES
replace data_type = "educ and health, NSA" if data_type=="LEDUH"
replace data_type = "educ and health, SA" if data_type=="LEDUHA"

replace data_type = "federal govt, NSA" if data_type=="LFGOV"
replace data_type = "federal govt, SA" if data_type=="LFGOVA"

replace data_type = "govt, NSA" if data_type=="LGOVT"
replace data_type = "govt, SA" if data_type=="LGOVTA"

replace data_type = "local govt, NSA" if data_type=="LLGOV"
replace data_type = "local govt, SA" if data_type=="LLGOVA"

replace data_type = "total nonfarm, NSA" if data_type=="LNAGR"
replace data_type = "total nonfarm, SA" if data_type=="LNAGRA"

replace data_type = "educational services, NSA" if data_type=="LS0"
replace data_type = "educational services, SA" if data_type=="LS0A"

replace data_type = "state govt, NSA" if data_type=="LSGOV"
replace data_type = "state govt, SA" if data_type=="LSGOVA"

replace data_type = "health and special assistance, NSA" if data_type=="LT0"
replace data_type = "health and special assistance, SA" if data_type=="LT0A"


*	QCEW
replace data_type = "federal govt, QCEW" if data_type=="FEZ0"
replace data_type = "local govt, QCEW" if data_type=="LEZ0"
replace data_type = "private ind: educ services, QCEW" if data_type=="PES0"

replace data_type = "private Ind: Health Care & Social Assistance, QCEW" if data_type=="PET0"
replace data_type = "private Ind: Education & Health Services, QCEW" if data_type=="PEZ25"
replace data_type = "state govt, QCEW" if data_type=="SEZ0"
replace data_type = "total govt, QCEW" if data_type=="TEGZ0"
replace data_type = "private Ind: Total, All Industries, QCEW" if data_type=="TEZ0"

save temp_file, replace