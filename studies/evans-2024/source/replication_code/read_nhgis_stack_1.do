set more off
clear

local level "elm sec uni"
local group1 "02 03 04 05 06 07 08 09 10 11 12 13 14 15 16"

* read in most of the 2022 data
* there are 3 files -- for elementary school districts, high school
* districts, and unified school districts

foreach mm of local level {
clear
insheet using nhgis_data\acs_2022\nhgis0083_ds262_20225_sd_`mm'.csv, comma

* median hh income
rename aqp6e001 med_hh_income
label var med_hh_income "median hh income in 2022 $"

* education of adults aged 25+
gen high_school=100*(aqpke017+aqpke018)/aqpke001
gen some_college=100*(aqpke019+aqpke020+aqpke021)/aqpke001
gen college_deg=100*(aqpke022+aqpke023+aqpke024+aqpke025)/aqpke001
gen xx=0
foreach nn of local group1 {
replace xx=xx+aqpke0`nn'
}
gen lt_high_school=100*xx/aqpke001
label var lt_high_school "% adults aged 25+ < high school degree"
label var high_school "% adults aged 25+ with high school degree"
label var some_college "% adults aged 25+ with some college"
label var college_deg "% adults aged 25+ with 4-year college degree"

* on cash assistance
gen cash_assistance=100*aqq5e002/aqq5e001
label var cash_assistance "% of families on cash assistance"


* own children in single-parent families
gen single_parent=100*(aqn8e001-aqn8e002)/aqn8e001
label var single_parent "% of children < 18 in single parent families"

gen nces_id=substr(geo_id,10,7)

* drop rest of state
gen last5=substr(nces_id,3,5)
drop if last5=="99999"
destring nces_id, replace
rename name_e district_name 

gen poverty=100*(aqpze002+aqpze003)/aqpze001
label var poverty "percent in poverty"
gen pop=aqpze001

keep district_name nces_id med_hh_income cash_assistance single_parent lt_high_school high_school some_college college_deg poverty pop

save stata_data_files\temp_`mm', replace
}
append using stata_data_files\temp_elm
append using stata_data_files\temp_sec
gen year=2122
save stata_data_files\all_demos_2122, replace
clear


* read in 2019 data for most variables 

foreach mm of local level {
clear
insheet using nhgis_data\acs_2019\nhgis0082_ds244_20195_sd_`mm'.csv, comma

* median hh income
rename alw1e001 med_hh_income
label var med_hh_income "median hh income in 2019 $"

* education of adults aged 25+
gen high_school=100*(alwge017+alwge018)/alwge001
gen some_college=100*(alwge019+alwge020+alwge021)/alwge001
gen college_deg=100*(alwge022+alwge023+alwge024+alwge025)/alwge001
gen xx=0
foreach nn of local group1 {
replace xx=xx+alwge0`nn'
}
gen lt_high_school=100*xx/alwge001
label var lt_high_school "% adults aged 25+ < high school degree"
label var high_school "% adults aged 25+ with high school degree"
label var some_college "% adults aged 25+ with some college"
label var college_deg "% adults aged 25+ with 4-year college degree"

* on cash assistance
gen cash_assistance=100*alx0e002/alx0e001
label var cash_assistance "% of families on cash assistance"


* own children in single-parent families
gen single_parent=100*(alu4e001-alu4e002)/alu4e001
label var single_parent "% of children < 18 in single parent families"

gen nces_id=substr(geoid,8,7)
* drop rest of state
gen last5=substr(nces_id,3,5)
drop if last5=="99999"
destring nces_id, replace
rename name_e district_name 

gen poverty=100*(alwve002+alwve003)/alwve001
label var poverty "percent in poverty"

gen pop=alwve001


keep district_name nces_id med_hh_income cash_assistance single_parent lt_high_school high_school some_college college_deg poverty pop

save stata_data_files\temp_`mm', replace
}
append using stata_data_files\temp_elm
append using stata_data_files\temp_sec
gen year=1819
save stata_data_files\all_demos_1819, replace
clear

* now read in med hh income for families w kids < 18 
* first for 18-19 then for 21-22

foreach mm of local level {
clear
insheet using nhgis_data\acs_2019\nhgis0088_ds245_20195_sd_`mm'.csv, comma
gen medhhincwkids=ame8e002 
gen nces_id=substr(geoid,8,7)
* drop rest of state
gen last5=substr(nces_id,3,5)
drop if last5=="99999"
destring nces_id, replace
rename name_e district_name 
label var medhhincwkids "median hh income for families w kids < 18"
keep district_name nces_id medhhincwkids
save stata_data_files\temp_a_`mm', replace
}
append using stata_data_files\temp_a_elm
append using stata_data_files\temp_a_sec
gen year=1819
save stata_data_files\medhhinckids_1819, replace
clear



foreach mm of local level {
clear
insheet using nhgis_data\acs_2022\nhgis0088_ds263_20225_sd_`mm'.csv, comma
gen medhhincwkids=aq9fe002

gen nces_id=substr(geo_id,10,7)

* drop rest of state
gen last5=substr(nces_id,3,5)
drop if last5=="99999"
destring nces_id, replace
rename name_e district_name 

label var medhhincwkids "median hh income for families w kids < 18"
keep district_name nces_id medhhincwkids
save temp_a_`mm', replace
}
append using temp_a_elm
append using temp_a_sec
gen year=2122
save stata_data_files\medhhinckids_2122, replace
append using stata_data_files\medhhinckids_1819
save stata_data_files\medhhinckids, replace
clear

use stata_data_files\all_demos_1819
append using stata_data_files\all_demos_2122
merge 1:1 nces_id district_name year using stata_data_files\medhhinckids
drop _merge
save stata_data_files\all_demos_stack, replace
clear





