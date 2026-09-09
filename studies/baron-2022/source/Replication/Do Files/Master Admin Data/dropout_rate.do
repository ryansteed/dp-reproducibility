/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports and cleans up high school dropout rate information
from 1996-97 through 2014-15. This dataset is available from 1996-97 through
2014-15 from the Wisconsin Department of Public Instruction.

DATA INPUTS: (1) dropout_rate_1996-97,...,dropouts_certified_2014-15
DATA OUTPUTS: (1) dropout_rate.dta
*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
cd "${path}Data\Raw\Dropout_Rates"

***Append these files
append using dropout_rate_1996-97 dropout_rate_1997-98 dropout_rate_1998-99 ///
dropout_rate_1999-00 dropout_rate_2000-01 dropout_rate_2001-02 ///
dropout_rate_2002-03 dropout_rate_2003-04 dropout_rate_2004-05 ///
dropouts_certified_2005-06 dropouts_certified_2006-07 dropouts_certified_2007-08 ///
dropouts_certified_2008-09 dropouts_certified_2009-10 dropouts_certified_2010-11 ///
dropouts_certified_2011-12 dropouts_certified_2012-13 dropouts_certified_2013-14 ///
dropouts_certified_2014-15     

*****************************************
******SECTION II: GEN DIST BY YEAR PANEL
*****************************************
****Clean up the data
****Deal with year and district code first
order year school_year
destring year, replace
replace year = year-1

***Turn school year into a numeric variable
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

****Generate complete year variable
replace school_year = year if school_year==.
drop year

****District code
order district_code district_number
destring district_number, replace
destring district_code, replace
replace district_code = district_number if district_code==.
drop if district_code==.
drop district_number

****Sort dataset
sort district_code school_year
drop if district_code==0


****Keep only school district variables
order school_type grade_group school_name
tab school_type
tab grade_group
**********
keep if school_type=="Summary"|grade_group=="[All]"

***Get rid of charter schools
tab charter
tab charter_ind
keep if charter=="N" | charter_ind=="No"

***Keep only "all students information"
tab group_by_value if group_by=="Grade Level"
tab grade
keep if (grade =="Grades 7-12 Combined" &race_ethnicity=="All Groups Combined" ///
&gender=="Both Groups Combined"&disability_status=="Both Groups Combined" ///
&economic_status=="Both Groups Combined"&english_proficiency_status=="Both Groups Combined") ///
| group_by_value=="All Students"

****Keep only variables of interest
tab school_type 
tab grade_group 
tab school_name
keep district_code school_year district_name enrollment students_expected students_who ///
drop_outs drop_out_rate student_count dropout_count completed_term_count dropout_rate

****Generate unique variables
replace student_count = enrollment if student_count==""
drop enrollment
***Note: student_count is really the number of students expected to complete the
***term. However, enrollment is not reported since 2005. I will create a unique variable
***student count which is equal to enrollment prior to 2005, and expected thereafter.
***This change should not bias my results, since it should be unrelated to treatment
replace dropout_count = drop_outs if dropout_count==""
drop drop_outs

replace dropout_rate = drop_out_rate if dropout_rate==""
drop drop_out_rate

*replace completed_term_count = students_who if completed_term==""
drop students_who students_expected completed_term dropout_rate

****Destring variables
foreach v in student_count dropout_count{
replace `v' ="." if `v'=="*" | `v'=="NA"
destring `v', replace
}

***Generate "missing" dummy
gen missing = (dropout_count==.)
sum missing


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
collapse (sum) student_count dropout_count missing, by(district_code school_year)
replace dropout_count=. if missing==1
tab missing

***Keep only years of master datasets
keep if school_year<=2014
tab missing

***Generate dropout rate
gen dropout_rate = dropout_count/student_count

***Look at summary statistics
sum dropout_rate

***Replace dropout rate variable
replace dropout_rate=dropout_rate*100
drop missing

***Label variables
label var dropout_rate "7-12 Combined Dropout Rate"
label var student_count "Prior to 2005: Enrollment, After: Expected to Complete Term"

*****************************************
******SECTION III: SAVE THIS DATASET
*****************************************
****This is the dropout rate 7-12 combined
save "${path}Data\Raw\Completed_Files\dropout_rate", replace
