***************************************************************************
*Extract all major CIP codes from cleaned enrollment file
*match to master CIP code file
***************************************************************************


***************************************************************************
*Input and output files:
local in "Intermediate_Data/All_Campuses/FTFresh_enroll_allOH_SM99-SP17.dta"
local matched "Intermediate_Data/All_Campuses/majors_matched_toCIP.dta"
local CIP1990 "$mydir/Dropbox/OLDA/Raw_Other_Files/CIPmaster_nomiss1990.dta"
local CIP2000 "$mydir/Dropbox/OLDA/Raw_Other_Files/CIPmaster_nomiss2000.dta"
local CIP2010 "$mydir/Dropbox/OLDA/Raw_Other_Files/CIPmaster_nomiss2010.dta"
***************************************************************************



use `in' , clear
keep if term_index<=36
collapse (count) hei_psid , by(major_study_field_code term_index)
drop hei_psid
save "temp data files/majors_list.dta", replace

use `in' , clear
keep if term_index>36
collapse (count) hei_psid , by(major_study_field_code term_index)
drop hei_psid
append using "temp data files/majors_list.dta"

*Match in 2010 fields from CIP Master File
*first match codes from before 2010
replace major_study_field_code="" if major_study_field_code=="UNDECI"
destring major_study_field_code, gen(temp)
gen cipcode2000=temp if term_index<45
merge m:1 cipcode2000 using `CIP2000', keep(master match)
tab temp if _merge==1 & term_index<45, miss
***71 major study field codes that are from 1990 CIP***
preserve
keep if _merge==1 & term_index<45 & temp!=.
keep major_study temp term_index
gen cipcode1990=temp
merge m:1 cipcode1990 using `CIP1990', keep(master match)
drop _merge
save "temp data files/majors_from1990.dta", replace
restore
drop if _merge==1 & term_index<45 & temp!=.
append using  "temp data files/majors_from1990.dta"
drop _merge

*Then match codes after 2010
replace cipcode2010=temp if term_index>=45
merge m:1 cipcode2010 using `CIP2010', update 
drop if _merge==2
tab temp if _merge==1 & term_index>=45, miss
keep major_study_field_code term_index cipcode2010 ciptitle2010 disciplinearea subjectfield2010 stemdesignation
rename cipcode2010 major_cipcode2010
rename ciptitle2010 major_ciptitle2010
rename subjectfield2010 major_subjectfield2010
rename stemdesignation major_stemdesignation
rename disciplinearea major_disciplinearea
save `matched' , replace
