* July 8, 2024
* this program loads the covid case data at the county level
* the data is available from
* https://data.cdc.gov/Public-Health-Surveillance/Weekly-COVID-19-County-Level-of-Community 
* Transmis/jgk8-6dpn/about_data 
* and is filtered by date from August 1, 2021 to May 31, 2022

set more off
clear

use covidcase_data\covid_case_data_8_1_21_5_31_22
rename fips_code fips
rename year_avg_cases_per_100k covid_rate_sy
keep fips covid_rate_sy
save stata_data_files\covid_cases_county, replace
clear


* read in lea to county crosswalk
import excel lea_county_crosswalk\lea_county_crosswalk.xlsx, firstrow
rename STCOUNTY countyfips
destring countyfips, replace
rename LEAID nces_id
destring nces_id, replace

gen state=int(nces_id/100000)
drop if state>56
rename NAME_LEA22 name_crosswalk 
keep nces_id name_crosswalk countyfips
sort nces_id
by nces_id: egen county=rank(countyfips)
reshape wide countyfips, i(nces_id name_crosswalk) j(county)
save stata_data_files\nces_county_mapping, replace
clear

use nces_county_mapping
forvalues i=1/8 {
rename countyfips`i' fips
merge m:1 fips using covid_cases_county
rename covid_rate_sy covid_rate_sy_`i'
rename fips county`i'
drop if _merge==2
drop _merge

} 
drop if covid_rate_sy_1==. & covid_rate_sy_2==. & covid_rate_sy_3==. & covid_rate_sy_4==. ///
& covid_rate_sy_5==. & covid_rate_sy_6==. & covid_rate_sy_7==. & covid_rate_sy_8==.

forvalues i=1/8 {
gen v`i'=covid_rate_sy_`i'
gen d`i'=v`i'~=.
replace v`i'=0 if v`i'==.
}
gen xsum=v1+v2+v3+v4+v5+v6+v7+v8
gen nsum=d1+d2+d3+d4+d5+d6+d7+d8
gen covid_rate_sy=xsum/nsum
drop if covid_rate_sy==0 
drop if covid_rate_sy==.
keep nces covid_rate_sy
save stata_data_files\covid_rate_by_district, replace

