* July 8, 2026
* This program loads the covid vaccination data by county
* The source is in the data appendix for the paper
* the data counts vaccinations until the end of 2021

set more off
clear

* read vaccination data
insheet using vaccination_data\COVID-19_Vaccinations_in_the_United_States_County.csv, comma
* keep the end date
keep if date=="12/31/2021"
drop if fips=="UNK"
destring fips, replace
drop if fips>56999
keep fips series_complete_pop_pct
label var series_complete_pop_pct "percent complete vaccination"
save stata_data_files\vaccination_mid_august, replace
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

use stata_data_files\nces_county_mapping
forvalues i=1/8 {
rename countyfips`i' fips
merge m:1 fip using stata_data_files\vaccination_mid_august
rename series_complete_pop_pct vax_rate_county_`i'
drop if _merge==2
drop _merge
rename fips county`i'
} 
drop if vax_rate_county_1==. & vax_rate_county_2==. & vax_rate_county_3==. & vax_rate_county_4==. ///
& vax_rate_county_5==. & vax_rate_county_6==. & vax_rate_county_7==. & vax_rate_county_8==.

forvalues i=1/8 {
gen v`i'=vax_rate_county_`i'
gen d`i'=v`i'~=.
replace v`i'=0 if v`i'==.
}
gen xsum=v1+v2+v3+v4+v5+v6+v7+v8
gen nsum=d1+d2+d3+d4+d5+d6+d7+d8
gen vax_rate=xsum/nsum
drop if vax_rate==0
keep nces vax_rate
save stata_data_files\vax_rate_by_district, replace



