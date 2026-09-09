set more off
clear

insheet using learning_mode\District_Overall_Shares_03.08.23.csv, comma
rename ncesdistrictid nces_id
drop stateabbrev
rename districtname name_lm_data
label var name_lm_data "district name from learning mode data"
label var share_inperson "share inperson days 20-21 school year"
label var share_hybrid "share inperson days 20-21 school year"
label var share_virtual "share inperson days 20-21 school year"
save stata_data_files\learning_mode, replace
clear



* read in membership data for 2021-22
insheet using common_core\ccd_lea_052_2122_l_1a_071722.csv, comma
gen ti11=substr(total_indicator,1,11)
keep if ti11=="Derived - S"
gen race5=substr(race_ethnicity,1,5)
gen enroll_total=student_count
gen enroll_black=student_count
replace enroll_black=0 if race5~="Black"
gen enroll_hispanic=student_count
replace enroll_hispanic=0 if race5~="Hispa"
gen enroll_white=student_count
replace enroll_white=0 if race5~="White"
gen enroll_asian=student_count
replace enroll_asian=0 if race5~="Asian"
rename leaid nces_id
collapse (sum) enroll_total enroll_white enroll_hispanic enroll_black enroll_asian, ///
by(nces_id lea_name)

label var enroll_total "total enrollment"
label var enroll_white "enrollment, white non-Hispanic students"
label var enroll_black "enrollment, black non-Hispanic students"
label var enroll_asian "enrollment, asian students"
label var enroll_hispanic "enrollment, Hispanic student"
save stata_data_files\enroll_2122, replace
clear

use enroll_2122
merge 1:1 nces_id using stata_data_files\learning_mode
list if _merge==2
keep if _merge==3
drop _merge
keep nces_id enroll_total share_*
replace nces_id=3620580 if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600081, 3600083, 3600084, 3600085)
replace nces_id=3620580 if inlist(nces_id, 3600086, 3600087, 3600088, 3600090, 3600091, 3600092, 3600094, 3600095)
replace nces_id=3620580 if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace nces_id=3620580 if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)
collapse (mean) share_* [fw=enroll_total], by(nces_id)
gen year=2122
save stata_data_files\learning_mode_2122, replace
replace year=1819
replace share_virtual=0
replace share_hybrid=0
replace share_inperson=1
save stata_data_files\learning_mode_1819, replace
append using stata_data_files\learning_mode_2122
save stata_data_files\leanring_mode_stack, replace
clear


use enroll_2122
replace nces_id=3620580 if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600083, 3600084, 3600085, 3600086)
replace nces_id=3620580 if inlist(nces_id, 3600087, 3600088, 3600090, 3600091, 3600092, 3600093, 3600094, 3600095)
replace nces_id=3620580 if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace nces_id=3620580 if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)
replace lea_name="NYC Schools" if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600083, 3600084, 3600085, 3600086)
replace lea_name="NYC Schools" if inlist(nces_id, 3600087, 3600088, 3600090, 3600091, 3600092, 3600093, 3600094, 3600095)
replace lea_name="NYC Schools" if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace lea_name="NYC Schools" if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)
replace lea_name="NYC Schools" if nces_id==3620580

collapse (sum) enroll_total* enroll_white* enroll_hispanic* enroll_black* enroll_asian*, ///
by(nces_id lea_name)
gen year=2122
save stata_data_files\enroll_2122_2, replace
clear


insheet using ca_data\sy2122_fs195_dg814_lea.csv, comma
rename ncesleaid nces_id
keep if subgroup=="All Students in LEA"
rename value ca
rename lea district_name_ca
label var ca "counts, chronic absent students"
label var district_name_ca "district name chronic absent data"

replace nces_id=3620580 if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600081, 3600083, 3600084, 3600085)
replace nces_id=3620580 if inlist(nces_id, 3600086, 3600087, 3600088, 3600090, 3600091, 3600092, 3600094, 3600095)
replace nces_id=3620580 if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace nces_id=3620580 if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)

replace district_name_ca="NYC Schools" if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600081, 3600083, 3600084, 3600085)
replace district_name_ca="NYC Schools" if inlist(nces_id, 3600086, 3600087, 3600088, 3600090, 3600091, 3600092, 3600094, 3600095)
replace district_name_ca="NYC Schools" if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace district_name_ca="NYC Schools" if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)
replace district_name_ca="NYC Schools" if nces_id==3620580

collapse (sum) ca, by(nces_id district_name_ca)
gen year=2122
keep nces_id year district_name_ca ca
save stata_data_files\ca_2122, replace
clear



insheet using ca_data\sy1819_fs195_dg814_lea.csv, comma
rename ncesleaid nces_id
keep if subgroup=="All Students"
rename value ca
rename lea district_name_ca
label var ca "counts, chronic absent students"
replace nces_id=3620580 if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600081, 3600083, 3600084, 3600085)
replace nces_id=3620580 if inlist(nces_id, 3600086, 3600087, 3600088, 3600090, 3600091, 3600092, 3600094, 3600095)
replace nces_id=3620580 if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace nces_id=3620580 if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)

replace district_name_ca="NYC Schools" if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600081, 3600083, 3600084, 3600085)
replace district_name_ca="NYC Schools" if inlist(nces_id, 3600086, 3600087, 3600088, 3600090, 3600091, 3600092, 3600094, 3600095)
replace district_name_ca="NYC Schools" if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace district_name_ca="NYC Schools" if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)
replace district_name_ca="NYC Schools" if nces_id==3620580

collapse (sum) ca, by(nces_id district_name_ca)
gen year=1819
keep nces_id year ca district_name_ca
save stata_data_files\ca_1819, replace
append using stata_data_files\ca_2122
save stata_data_files\ca_stack, replace
clear

* read in membership data for 2018-19
insheet using common_core\ccd_lea_052_1819_l_1a_091019.csv, comma
gen ti11=substr(total_indicator,1,11)
keep if ti11=="Derived - S"
gen race5=substr(race_ethnicity,1,5)
gen enroll_total=student_count
gen enroll_black=student_count
replace enroll_black=0 if race5~="Black"
gen enroll_hispanic=student_count
replace enroll_hispanic=0 if race5~="Hispa"
gen enroll_white=student_count
replace enroll_white=0 if race5~="White"
gen enroll_asian=student_count
replace enroll_asian=0 if race5~="Asian"
rename leaid nces_id

replace nces_id=3620580 if inlist(nces_id, 3600076, 3600077, 3600078, 3600079, 3600081, 3600083, 3600084, 3600085)
replace nces_id=3620580 if inlist(nces_id, 3600086, 3600087, 3600088, 3600090, 3600091, 3600092, 3600094, 3600095)
replace nces_id=3620580 if inlist(nces_id, 3600096, 3600097, 3600098, 3600099, 3600100, 3600101, 3600102, 3600103)
replace nces_id=3620580 if inlist(nces_id, 3600119, 3600120, 3600121, 3600122, 3600123, 3600151, 3600152, 3600153)
collapse (sum) enroll_total enroll_white enroll_hispanic enroll_black enroll_asian, ///
by(nces_id)

label var enroll_total "total enrollment"
label var enroll_white "enrollment, white non-Hispanic students"
label var enroll_black "enrollment, black non-Hispanic students"
label var enroll_hispanic "enrollment, Hispanic students"
label var enroll_asian "enrollment, Asian students"
gen year=1819
save stata_data_files\enroll_1819, replace
append using stata_data_files\enroll_2122_2
save stata_data_files\enroll_stack, replace


merge 1:1 nces_id year using stata_data_files\ca_stack
keep if _merge==3
drop _merge


merge 1:1 nces_id year using stata_data_files\leanring_mode_stack
keep if _merge==3
drop _merge

merge 1:1 nces_id year using stata_data_files\all_demos_stack
keep if _merge==3
sum
save stata_data_files\stacked_1, replace
