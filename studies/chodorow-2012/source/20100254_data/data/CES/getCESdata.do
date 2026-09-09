
* To run this file, we downloaded sm.data.1.AllData into this folder from BLS website on June 8, 2011: ftp://ftp.bls.gov/pub/time.series/sm/
* To re-run this file, go to the above website and download sm.data.1.AllData into this file: $dir/data/CES".  Any difference in output will be due to data revisions subsequent to June 8, 2011.  

clear
set mem 700M

insheet using sm.data.1.AllData

gen SA = substr(series_id,3,1)
gen state_code = substr(series_id,4,2)
gen area_id = substr(series_id,6,5)
gen industry = substr(series_id,11,8)
gen data_type = substr(series_id,19,2)

* keep all employees
keep if data_type == "01"

* drop annual data
drop if period == "M13"

* keep seasonally-adjusted
keep if (SA == "S") | (SA == "U" & industry=="90910000") | (SA == "U" & state_code == "56") //We need the unseasonally-adjusted Federal govt data for some of the states that local state SA data.

* keep only statewide data
keep if area_id == "00000"

* keep if nonfarm, total govt, fed govt, state govt, local govt, education and health
keep if industry == "00000000" | industry == "65000000" | industry=="90930000" | industry == "90920000" | industry == "90910000" | industry == "90000000" | industry == "65610000" | industry == "65611000" | industry == "65620000"
replace industry = "total" if industry=="00000000"
replace industry = "edhealth" if industry=="65000000"
replace industry = "local" if industry=="90930000"
replace industry = "state" if industry=="90920000"
replace industry = "federal" if industry=="90910000"
replace industry = "totgov" if industry=="90000000" 
replace industry = "education1" if industry=="65610000" //only 42 states have this variable, and VA only for certain dates.
replace industry = "education2" if industry=="65611000" //zero states have this variable
replace industry = "health" if industry=="65620000" //only 42 states have this variable

destring state_code, replace
drop if state_code > 56
sort state_code
merge state_code using state_abbrevs, uniqusing
drop _merge

gen month = substr(period,2,2)
destring month, replace

gen date = ym(year,month)
drop if date < tm(1990m1)


keep value state_abrev date industry SA

* reshape the data

gen indSA = industry + SA
drop industry SA

rename value _
reshape wide _, i(date state_abrev) j(indSA) string

* generate total employment variable
gen totalemp = _totalS

* generate state and local government variable
tab state_abrev if (_stateS ~= . & _localS ~= .)
gen totalgov = _stateS + _localS if (_stateS ~= . & _localS ~= .)
tab state_abrev if ~(_stateS ~= . & _localS ~= .) & (_federalS ~= .)
replace totalgov = _totgovS - _federalS if ~(_stateS ~= . & _localS ~= .) & (_federalS ~= .)
tab state_abrev if ~(_stateS ~= . & _localS ~= .) & ~(_federalS ~= .)
replace totalgov = _totgovS - _federalU if ~(_stateS ~= . & _localS ~= .) & ~(_federalS ~= .)

* generate education and health variables
tab state_abrev if (_edhealthS ==.)
gen edhealth = _edhealthS
replace edhealth = _healthU + _education1U if state_abrev == "WY" //NOTE: USE NSA DATA FOR WYOMING!
gen education = _education1S
gen health = _healthS

* one by one create the data sets
foreach type in totalemp totalgov edhealth education health {
	preserve
	keep date state_abrev `type'
	rename `type' _
	gen year = string(year(dofm(date)))
	gen month = string(month(dofm(date)))
	gen time = year + month
	keep time state_abrev _
	reshape wide _ , i(state_abrev) j(time) string
	save `type'june82011, replace
	restore
}




