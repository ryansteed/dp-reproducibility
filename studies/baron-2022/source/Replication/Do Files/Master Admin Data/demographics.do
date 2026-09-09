/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file collects demographic variables to perform robustness checks:
Has the school composition changed as a result of referendum approval?
I collect demographic information from 2005-06 through 2014-15. 

DATA INPUTS: (1) enrollment_certified_2005-06.dta,...,enrollment_certified_2014-15
DATA OUTPUTS: (1) demographics.dta

*********************************/
*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
cd "${path}Data\Raw\Demographics"

***Append all files into a single one
append using enrollment_certified_2005-06 enrollment_certified_2005-06 ///
enrollment_certified_2006-07 enrollment_certified_2007-08 ///
enrollment_certified_2008-09 enrollment_certified_2009-10 ///
enrollment_certified_2010-11 enrollment_certified_2011-12 ///
enrollment_certified_2012-13 enrollment_certified_2013-14 ///
enrollment_certified_2014-15


*****************************************
******SECTION II: GEN DIST BY YEAR PANEL
*****************************************
****Begin with sample restrictions
***Keep only district-level information
tab agency_type
quietly edit if agency_type=="School District"
keep if agency_type=="School District"

***Make sure there are no charter schools left using the charter_ind variable
tab charter_ind
drop charter_ind //don't need this variable anymore

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

***Make sure it worked
tab school_year
destring school_year, replace

***Keep only relevant variables
tab school_code
keep school_year district_code district_name grade_group group_by ///
group_by_value student_count percent_of_group

****The three variables I'm interested in: Enrollment, Percent Econ Disadv,
****and Perc Minorities

***Sort data
destring district_code, replace
sort district_code school_year

***I am interested in all grades, not specific ones
tab group_by
tab group_by_value if group_by=="Grade Level"

***Generate new variables
gen perc_white = percent_of_group if group_by_value=="White"
gen perc_econdis = percent_of_group if group_by_value=="Econ Disadv"
gen enrollment = student_count if group_by_value=="All Students"

***Destring these variables
foreach v in perc_white perc_econdis enrollment {
destring `v', replace
}

***Now, keep only these variables and take the max
keep school_year district_code perc_white perc_econdis enrollment district_name
foreach v in perc_white perc_econdis enrollment{
bysort district_code school_year: egen `v'1 = max(`v')
drop `v'
rename `v'1 `v'
}

***Drop duplicates
duplicates drop district_code school_year perc_white perc_econdis enrollment, force
gen perc_min = 100 - perc_white
drop perc_white

***Summarize variables
sum *


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
****Collapse the data by year, district code
collapse (sum) enrollment (mean) perc_econdis perc_min [aw=enrollment], ///
by(district_code school_year) 

***Make sure I have a baanced panel
bysort district_code: gen nobs=_N
edit if nobs!=10
drop nobs

***Generate log of enrollment
sum enrollment
gen log_enr = log(enrollment)


*****************************************
******SECTION III: SAVE DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\demographics", replace
