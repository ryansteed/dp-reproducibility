/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file generates a *school-level* dataset of enrollment figures for each 
public school in Wisconsin. This dataset will then be used to gen student-teacher
ratios at the school level.

DATA INPUTS: (1) enrollment_by_grade_level_placement_1995-96.csv,...,enrollment_by_grade_level_placement_2004-05
(2) enrollment_certified_2005-06.dta,...,enrollment_certified_2014-15.dta
DATA OUTPUTS: (1) school_level_enrollment.dta
*********************************/

*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
***************************************** 

***Import datasets and append
clear
cd "${path}Data\Raw\School_Level_Enrollment"

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
******SECTION II: GEN DIST BY YEAR PANEL
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

***Sort data
destring school_number, replace
sort district_code school_number school_year

***Get rid of charter schools
drop if charter=="Y"
drop charter 

***Now, keep only school-level data
tab school_type
drop if school_type=="Summary"
keep school_year district_code school_number school_type district_name ///
school_name total_enr

***Drop state-level information
drop if district_name =="Entire State"

***Destring and rename enrollment
destring total_enr, replace
rename total_enr student_count

***Save these years as a tempfile
tempfile firstdata
save `firstdata'


****Now, years 2005-06 on.
clear
append using enrollment_certified_2005-06 enrollment_certified_2006-07 ///
enrollment_certified_2007-08 enrollment_certified_2008-09 ///
enrollment_certified_2009-10 enrollment_certified_2010-11 ///
enrollment_certified_2011-12 enrollment_certified_2012-13 ///
enrollment_certified_2013-14 enrollment_certified_2014-15

***Fix year variable
***Destring school year variable
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
tab school_year
destring school_year, replace

***Get rid of charter schools
tab charter
drop if charter=="Yes"
drop charter 

***Now, keep only school-level data
tab grade_group
drop if grade_group=="[All]"

***Keep only "All Students" information
keep if group_by=="All Students"

***Keep only variables of interest
keep school_year district_code school_code district_name school_name ///
group_by student_count grade_group

***Destring variable
destring student_count, replace
destring school_code, replace
destring district_code, replace
***Rename variables
rename school_code school_number
rename grade_group school_type

***Sort data and append to earlier years
sort district_code school_number school_year
append using `firstdata'

***Sort data
sort district_code school_number school_year

***Keep only information from 1996 on
keep if school_year>1995

***Now, deal with school type variable
tab school_type

***Keep only relevant variables***Generate unique school identifier
tostring district_code, replace
tostring school_number, replace
gen schoolid = district_code + school_number
order schoolid


***Destring this unique id and keep only variables of interest
destring schoolid, replace
destring district_code, replace
destring school_number, replace

rename school_year year
rename school_number school_code

keep schoolid year student_count district_name school_name district_code school_code

***Make sure there are no duplicates
duplicates list district_code school_code year


*****************************************
******SECTION III: SAVE CLEAN DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\school_level_enrollment", replace

