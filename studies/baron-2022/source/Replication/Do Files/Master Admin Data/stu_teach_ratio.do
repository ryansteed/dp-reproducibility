/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports data on student-teacher ratios at the district level.
Data on student-teacher ratios come from the WDPI.

DATA INPUTS: (1) staff_fte_ratio_certified_2007-08.dta,...,staff_fte_ratio_certified_2014-15
(2) students_to_fte_staff_ratios_1996-97,...,students_to_fte_staff_ratios_2006-07
DATA OUTPUTS: (1) stu_teach.dta

*********************************/

*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
set more off
cd "${path}Data\Raw\Stu_Teach"

*****************************************
******SECTION II: CLEAN DATASET
*****************************************
***Append all files and begin cleanup
***Latest years first (2007-2014):
clear
append using staff_fte_ratio_certified_2007-08 staff_fte_ratio_certified_2008-09 ///
staff_fte_ratio_certified_2009-10 staff_fte_ratio_certified_2010-11 ///
staff_fte_ratio_certified_2011-12 staff_fte_ratio_certified_2012-13 ///
staff_fte_ratio_certified_2013-14 staff_fte_ratio_certified_2014-15, force

***Start cleanup
***First, keep only district-level data
tab agency_type_desc
keep if agency_type_desc =="Public school district"
keep if school_name =="[Districtwide]"

***Drop variables I will not be using
tab charter_ind
drop agency_type cesa county school_code grade_group charter_ind ///
athletic school_name

***Convert year to numeric variable
replace school_year = "2007" if school_year == "2007-08"
replace school_year = "2008" if school_year == "2008-09"
replace school_year = "2009" if school_year == "2009-10"
replace school_year = "2010" if school_year == "2010-11"
replace school_year = "2011" if school_year == "2011-12"
replace school_year = "2012" if school_year == "2012-13"
replace school_year = "2013" if school_year == "2013-14"
replace school_year = "2014" if school_year == "2014-15"

***Destring remaining variables
destring school_year, replace
destring ratio_stdnts_to_staff_support, replace

***Save as tempfile
tempfile later_years
save `later_years'

***Now, append earlier years (these have a different format)
clear
append using students_to_fte_staff_ratios_1996-97 students_to_fte_staff_ratios_1997-98 ///
students_to_fte_staff_ratios_1998-99 students_to_fte_staff_ratios_1999-00 ///
students_to_fte_staff_ratios_2000-01 students_to_fte_staff_ratios_2001-02 ///
students_to_fte_staff_ratios_2002-03 students_to_fte_staff_ratios_2003-04 ///
students_to_fte_staff_ratios_2004-05 students_to_fte_staff_ratios_2005-06 ///
students_to_fte_staff_ratios_2006-07

***Start cleanup
***First, keep only district-level data
tab agency_type
keep if agency_type =="03"
tab school_type

***Drop variables I do not need
keep year district_number district_name prek staff_type number_fte ratio_of charter

***Drop charter schools
tab charter
keep if charter=="N"
drop charter

***Note that years correspond to the fiscal year
tab year
rename year school_year
destring school_year, replace
replace school_year = school_year-1

***Sort data
foreach v in district_number school_year prek {
destring `v', replace
}
sort district_number school_year
rename district_number district_code

***Get ready to reshape
*I need the following reshape: ratio_stdnts_to_staff_total
tab staff_type
keep if staff_type =="Total" | staff_type=="Licensed Staff" | ///
staff_type=="Administration" | staff_type=="Aides/Support/Other"
replace staff_type="1" if staff_type =="Total"
replace staff_type="2" if staff_type =="Licensed Staff"
replace staff_type="3" if staff_type =="Administration"
replace staff_type="4" if staff_type =="Aides/Support/Other"
destring staff_type, replace

**Reshape
rename prek enrollment
reshape wide number ratio, i(school_year district_code) j(staff_type)
sort district_code school_year

***Rename variables
rename number_fte_staff1 number_fte_staff_total
rename number_fte_staff2 number_fte_staff_licensed
rename number_fte_staff3 number_fte_staff_admin 
rename number_fte_staff4 number_fte_staff_support

rename ratio_of_students_to_fte_staff1 ratio_stdnts_to_staff_total
rename ratio_of_students_to_fte_staff2 ratio_stdnts_to_staff_licensed 
rename ratio_of_students_to_fte_staff3 ratio_stdnts_to_staff_admin
rename ratio_of_students_to_fte_staff4 ratio_stdnts_to_staff_support

****Append to this dataset the newer years
append using `later_years'

***Sort and drop duplicates
sort district_code school_year
duplicates drop school_year district_code number_fte_staff_total ratio_stdnts_to_staff_total ///
number_fte_staff_licensed ratio_stdnts_to_staff_licensed number_fte_staff_admin ///
ratio_stdnts_to_staff_admin ratio_stdnts_to_staff_support number_fte_staff_support, force

***Fix last issues
order number_fte_staff_support ratio_stdnts_to_staff_support enrollment
replace enrollment = total if enrollment==.
drop total
rename enrollment fall_enr

***Create ratio for staff support in 2012 and 2014
replace ratio_stdnts_to_staff_support = fall_enr / number_fte_staff_support ///
if ratio_stdnts_to_staff_support==.

*******************************************************************************
**********Deal with consolidations, name changes, and mergers******************
***The are a few consolidations a mergers to worry about. The full list can
***be found here: https://dpi.wi.gov/sms/reorganization/history-and-orders
bysort district_code: gen nobs=_N
edit if nobs!=19

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

***Collapse data to account for these consolidations
*ratio_stdnts_to_staff_admin ratio_stdnts_to_staff_licensed ratio_stdnts_to_staff_support ratio_stdnts_to_staff_total
drop ratio*
collapse (sum) number* fall_enr, by(district_code school_year) 

***Generatio ratios
gen ratio_stdnts_to_staff_total = fall_enr/number_fte_staff_total
gen ratio_stdnts_to_staff_support = fall_enr/number_fte_staff_support
gen ratio_stdnts_to_staff_licensed = fall_enr/number_fte_staff_licensed
gen ratio_stdnts_to_staff_admin = fall_enr/number_fte_staff_admin

***Sort dataset
sort district_code school_year

***Label Variables
label var fall_enr "Total Fall Enrollment K-12"
label var ratio_stdnts_to_staff_total "Student-Total Staff Ratio"
label var ratio_stdnts_to_staff_admin "Student-Admin Staff Ratio"
label var ratio_stdnts_to_staff_licensed "Student-Licensed Staff Ratio"
label var ratio_stdnts_to_staff_support "Student-Support Staff Ratio"

label var number_fte_staff_total "Number of FTE Total Staff"
label var number_fte_staff_admin "Number of FTE Admin. Staff"
label var number_fte_staff_licensed "Number of FTE Licensed Staff"
label var number_fte_staff_support "Number of FTE Support Staff"

*****************************************
******SECTION III: SAVE CLEAN DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\stu_teach", replace


