/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports district-level fall enrollment by grade. The goal
is to create a measure of a school district's 9th grade enrollment in t-3.
I was asked by Referee #3 to divide the number of high school completers in
enrolling in college in year t by 9th grade enrollment three years ago (t-3).
This do-file generates this information, which will then be merged with
college enrollment information.

DATA INPUTS: (1) enrollment_by_grade_level_placement_1995-96.csv,...,enrollment_by_grade_level_placement_2004-05.csv
(2)enrollment_certified_2005-06.csv,...,enrollment_certified_2011-12.csv
DATA OUTPUTS: (1) grade9_enr.dta
*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
cd "${path}Data\Raw\Enrollment"

**Write loop to import datasets
local allfiles : dir . files "*.csv"
display `allfiles'

foreach file in `allfiles' {
insheet using `file'
local noextension : subinstr local file ".csv" ""
tostring *, replace
save `noextension'.dta, replace
clear
}


*****************************************
******SECTION II: GEN DISTRICT-BY-YEAR PANEL
*****************************************
***Years 1995-2004 are different. Start with these.
clear
append using enrollment_by_grade_level_placement_1995-96 ///
enrollment_by_grade_level_placement_1996-97 enrollment_by_grade_level_placement_1997-98 ///
enrollment_by_grade_level_placement_1998-99 enrollment_by_grade_level_placement_1999-00 ///
enrollment_by_grade_level_placement_2000-01 enrollment_by_grade_level_placement_2001-02 ///
enrollment_by_grade_level_placement_2002-03 enrollment_by_grade_level_placement_2003-04 ///
enrollment_by_grade_level_placement_2004-05

***Note that this dataset reports *fiscal* year rather than academic year.
destring year, replace
replace year=year-1
tab year
rename year school_year

***Destring district code
destring district_number, replace
rename district_number district_code

***Now, keep only grade 9 information
keep school_year district_code school_type charter district_name school_name ///
grade9_count school_type


***Drop state-level information
drop if district_name =="Entire State"

***Sort data
sort district_code school_year

***Get rid of charter schools
drop if charter=="Y"
drop charter 

***Keep only district-level information
keep if school_type=="Summary" //there should be 10 obs per district
bysort district_code: gen nobs=_N
tab nobs //this is correct
drop nobs school_name

***Destring
destring grade9_count, replace

***Save these years as a tempfile
tempfile firstdata
drop school_type
save `firstdata'

****Now, years 2005-06 on.
clear
append using enrollment_certified_2005-06 enrollment_certified_2006-07 ///
enrollment_certified_2007-08 enrollment_certified_2008-09 ///
enrollment_certified_2009-10 enrollment_certified_2010-11 ///
enrollment_certified_2011-12

***Fix year variable
***Destring school year variable
replace school_year = "2005" if school_year == "2005-06"
replace school_year = "2006" if school_year == "2006-07"
replace school_year = "2007" if school_year == "2007-08"
replace school_year = "2008" if school_year == "2008-09"
replace school_year = "2009" if school_year == "2009-10"
replace school_year = "2010" if school_year == "2010-11"
replace school_year = "2011" if school_year == "2011-12"
tab school_year
destring school_year, replace

***Keep only variables of interest
keep school_year agency_type district_code grade_group group_by ///
group_by_value student_count district_name charter_ind

**Keep only school-district level data
keep if agency_type=="School District"
tab grade_group
drop grade_group

***Keep only 9th grade enrollment
keep if group_by_value=="9"
tab charter_ind
drop charter_ind

***Sort
destring district_code, replace
sort district_code school_year

***Keep only variables of interest
rename student_count grade9_count
drop group_by group_by_value
destring grade9_count, replace

***Append to earlier years
append using `firstdata'

***Sort
sort district_code school_year
drop agency_type

***Now, since this is lagged enrollment, I will add three years to the year var
replace school_year = school_year+3

***Rename grade9 variable
rename grade9 grade9lagged
label var grade9lagged "Fall Grade 9 Enrollment in t-3"

bysort district_code: gen nobs=_N
edit if nobs!=17

***Fix mergers and consolidations
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

***Collapse
collapse (sum) grade9lagged, by(district_code school_year)
bysort district_code: gen nobs=_N
edit if nobs!=17 //these are non high schools
sort district_code school_year
drop if nobs!=17
drop nobs


*****************************************
******SECTION III: SAVE THIS DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\grade9_enr", replace



