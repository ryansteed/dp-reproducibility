/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports district-level postsecondary enrollment data, available through the WDPI, 
and gets it ready to merge with the master dataset. These data are available from 2005-06 through 2014-15.

DATA INPUTS: (1) postsecondary_enrollment_current_2005-06.dta,...,postsecondary_enrollment_current_2014-15.dta
(2) grade9_enr.dta
DATA OUTPUTS: (1) postsec_enr.dta
*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
set more off
cd "${path}\Data\Raw\Postsec_Enrollment"

*Append these files into one
use postsecondary_enrollment_current_2005-06
append using postsecondary_enrollment_current_2006-07 ///
postsecondary_enrollment_current_2007-08 postsecondary_enrollment_current_2008-09 ///
postsecondary_enrollment_current_2009-10 postsecondary_enrollment_current_2010-11 ///
postsecondary_enrollment_current_2011-12 postsecondary_enrollment_current_2012-13 ///
postsecondary_enrollment_current_2013-14 postsecondary_enrollment_current_2014-15 


*****************************************
******SECTION II: GEN DISTRICT-BY-YEAR PANEL
*****************************************
***Clean up file
***Keep only "All students"
tab group_by
keep if group_by=="All Students"
drop group_by

***Keep only school district level data
tab agency_type
keep if agency_type=="School District"
drop agency_type

***Drop school-level specific variables
tab grade_group
drop grade_group
tab school_code
drop school_code

***Drop suppressed data
tab group_by_value
keep if group_by_value=="All Students"
drop group_by_value

****Continue getting rid of variables that are of no use
tab charter_ind
drop charter_ind cesa county school_name

****Get rid of potential duplicates
duplicates drop school_year district_code initial_enrollment institution_level ///
institution_type institution_location group_count student_count, force

***Destring count variables
destring group_count, replace
destring student_count, replace

***Numeric year variable
replace school_year = "2005" if school_year == "2005-06"
replace school_year = "2006" if school_year == "2006-07"
replace school_year = "2007" if school_year == "2007-08"
replace school_year = "2008" if school_year == "2008-09"
replace school_year = "2009" if school_year == "2009-10"
replace school_year = "2010" if school_year == "2010-11"
replace school_year = "2011" if school_year == "2011-12"
replace school_year = "2012" if school_year == "2012-13"
replace school_year = "2013" if school_year == "2013-14"
replace school_year = "2014" if school_year == "2014-15"
destring school_year, replace

***Order dataset
order group_count student_count

***I am only interested in "first fall" enrollment for now
keep if initial_enrollment == "First Fall" 

***Keep only variables of interest
drop group_count initial_enrollment institution_type

***The sample here is enrollment the following fall in in-state, out-of-state, or multiple
***In-State
bysort district_code school_year: egen first_enr = sum(student_count) if institution_location=="In-State"
bysort district_code school_year: egen initial_enrollment_fouryr = sum(student_count) if institution_level=="4-Year"&institution_location=="In-State"
bysort district_code school_year: egen initial_enrollment_twoyr = sum(student_count) if (institution_level=="2-Year"|institution_level=="Less Than 2-Year")&institution_location=="In-State"
bysort district_code school_year: egen initial_enrollment_multiple = sum(student_count) if institution_level=="Multiple"&institution_location=="In-State"

bysort district_code school_year: egen first_enr1 = max(first_enr)
bysort district_code school_year: egen initial_enrollment_fouryr1 = max(initial_enrollment_fouryr)
bysort district_code school_year: egen initial_enrollment_twoyr1 = max(initial_enrollment_twoyr)
bysort district_code school_year: egen initial_enrollment_multiple1 = max(initial_enrollment_multiple) 

drop first_enr initial_enrollment_fouryr initial_enrollment_twoyr initial_enrollment_multiple

rename(first_enr1 initial_enrollment_fouryr1 initial_enrollment_twoyr1 initial_enrollment_multiple1) ///
(instate_enr instate_enrollment_fouryr instate_enrollment_twoyr instate_enrollment_multiple)


***Out-of-State
bysort district_code school_year: egen first_enr = sum(student_count) if institution_location=="Out-of-State"
bysort district_code school_year: egen initial_enrollment_fouryr = sum(student_count) if institution_level=="4-Year"&institution_location=="Out-of-State"
bysort district_code school_year: egen initial_enrollment_twoyr = sum(student_count) if (institution_level=="2-Year"|institution_level=="Less Than 2-Year")&institution_location=="Out-of-State"
bysort district_code school_year: egen initial_enrollment_multiple = sum(student_count) if institution_level=="Multiple"&institution_location=="Out-of-State"

bysort district_code school_year: egen first_enr1 = max(first_enr)
bysort district_code school_year: egen initial_enrollment_fouryr1 = max(initial_enrollment_fouryr)
bysort district_code school_year: egen initial_enrollment_twoyr1 = max(initial_enrollment_twoyr)
bysort district_code school_year: egen initial_enrollment_multiple1 = max(initial_enrollment_multiple) 

drop first_enr initial_enrollment_fouryr initial_enrollment_twoyr initial_enrollment_multiple

rename(first_enr1 initial_enrollment_fouryr1 initial_enrollment_twoyr1 initial_enrollment_multiple1) ///
(outofstate_enr outofstate_enrollment_fouryr outofstate_enrollment_twoyr outofstate_enrollment_multiple)

foreach v in outofstate_enr outofstate_enrollment_fouryr outofstate_enrollment_twoyr outofstate_enrollment_multiple{
	replace `v'=0 if `v'==.
}

***Drop duplicates
duplicates drop school_year district_code instate_enr instate_enrollment_fouryr ///
outofstate_enr outofstate_enrollment_fouryr outofstate_enrollment_twoyr ///
outofstate_enrollment_multiple, force
keep school_year district_code district_name instate_enr outofstate_enr out* instate*


*******************************************************************************
**********Deal with consolidations, name changes, and mergers******************
***The are a few consolidations a mergers to worry about. The full list can
***be found here: https://dpi.wi.gov/sms/reorganization/history-and-orders

****(1) River Ridge (merge between Bloomington and West Grant in 1995)
***In 1995, the School District of Bloomington and the School District of W. Grant
***consolidated to become the River Ridge School District
***Since this was in 1995, this merger is not a problem in this dataset.
drop if district_code==4249 | district_code==539
****(2) Trevor - Wilmot (merge between Trevor Grade and Wilmot Grade in 2006)
****Also, Salem changed name to Trevor in 2000
replace district_code = 5780 if district_code== 5061 //replace Trevor's (Salem) district_code
replace district_code = 5780 if district_code== 5075 //replace Wilmot's district_code
edit if district_code== 5780
sort district_code school_year //at the end, I will collapse by year and district_code to fix this merger


****(3) There was a split between Shawano-Gresham into Shawano and Gresham in 2007-08
***Gresham appears in the data from 2007 on.
***I will take the Shawano-Gresham school district as one through the sample.
edit if district_code==2415|district_code==5264
replace district_code = 5264 if district_code== 2415


****(4) Glidden and Park Falls merged in 2009 to become Chequamegon
replace district_code = 1071 if district_code == 2205 //glidden
replace district_code = 1071 if district_code == 4242 //park falls
edit if district_code==1071

*****(5) Chetek and Weyerhauser merged to become Chetek - Weyerhauser
replace district_code = 1080 if district_code == 1078 //chetek
replace district_code = 1080 if district_code == 6410 //weyerhauser
edit if district_code==1080


****(6) Herman, Neosho, Rubicon merged in 2016
replace district_code=2525 if district_code==4998 //Rubicon 
replace district_code=2525 if district_code==3913 //Neosho
replace district_code=2525 if district_code==2523 //Herman
edit if district_code==2525

******************************************************************************
******************************************************************************

****Collapse data to account for these consolidations
collapse (sum) instate* outofstate*, by(district_code school_year) 
sum instate* outofstate*
***Generate logs and label variables
gen log_instate_four = log(instate_enrollment_fouryr+1)
gen log_instate_twoyr = log(instate_enrollment_twoyr+1)
gen log_instate_enr = log(instate_enr)

label var log_instate_four "Log of First-Fall Enrollment in a Four-Yr State Inst."
label var log_instate_twoyr "Log of First-Fall Enrollment in a Two-Yr State Inst."
label var log_instate_enr "Log of First-Fall Enrollment in a State Inst."


gen log_outofstate_four = log(outofstate_enrollment_fouryr+1)
gen log_outofstate_twoyr = log(outofstate_enrollment_twoyr+1)
gen log_outofstate_enr = log(outofstate_enr+1)

label var log_outofstate_four "Log of First-Fall Enrollment in a Four-Yr Out of State Inst."
label var log_outofstate_twoyr "Log of First-Fall Enrollment in a Two-Yr Out of State Inst."
label var log_outofstate_enr "Log of First-Fall Enrollment in an Out of State Inst."

****Merge to grade 9 (t-3) data
merge 1:1 district_code school_year using "${path}Data\Raw\Completed_Files\grade9_enr"
keep if _merge==3
bysort district_code: gen nobs=_N
drop if nobs!=10
drop _merge


***Generate shares
gen perc_instate_four = instate_enrollment_fouryr/grade9lagged
gen perc_instate_two = instate_enrollment_twoyr/grade9lagged
gen perc_instate = instate_enr/grade9lagged

gen perc_outofstate_four = outofstate_enrollment_fouryr/grade9lagged
gen perc_outofstate_two = outofstate_enrollment_twoyr/grade9lagged
gen perc_outofstate = outofstate_enr/grade9lagged

*****************************************
******SECTION III: SAVE THIS DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\postsec_enr", replace