/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports data from 2005-06 through 2013-14 on WKCE scale scores as 
well as cut scores to merge with master dataset. This dataset is made publicly 
available through the WDPI.

DATA INPUTS: (1) wsas_certified_2005-06,...,wsas_certified_2014-15.dta
DATA OUTPUTS: (1) wkce.dta
*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
set more off
cd "${path}Data\Raw\WKCE"

*These files have already been converted to Stata. Append each of the years. 
use wsas_certified_2005-06
append using wsas_certified_2006-07
append using wsas_certified_2007-08
append using wsas_certified_2009-10
append using wsas_certified_2008-09
append using wsas_certified_2009-10
append using wsas_certified_2010-11
append using wsas_certified_2011-12
append using wsas_certified_2012-13
append using wsas_certified_2013-14
append using wsas_certified_2014-15

*****************************************
******SECTION II: GEN DISTRICT-BY-YEAR PANEL
*****************************************
*Begin with sample restrictions
*Only looking at WKCE, not WAA-SWD
tab test_group
keep if test_group =="WKCE"

*Keep only district-level information
tab agency_type
keep if agency_type=="School District"

*Make sure there are no charter schools left using the charter_ind variable
tab charter_ind
drop charter_ind //don't need this variable anymore

*Keep only variables of interest
tab group_by
keep if group_by =="All Students"

tab school_name
drop school_name 

tab group_by_value
drop group_by

tab grade_group
drop grade_group

drop agency_type cesa county school_code

*Keep only grades of interest
keep if grade_level==4|grade_level==8|grade_level==10

*Keep only Math and Reading classes
keep if test_subject=="Mathematics"|test_subject=="Reading"

*Generate share of students who score in the various categories
tab test_result_code
replace test_result_code = "5" if test_result_code=="NOTST"
tab test_result_code
edit if test_result_code=="*"
drop  if test_result_code=="*"

keep school_year district_code district_name test_subject grade_level ///
test_result_code student_count percent_of_group wkce_average group_count

*Destring variables and begin reshape
replace test_subject="1" if test_subject=="Mathematics"
replace test_subject="2" if test_subject=="Reading"

local z test_subject test_result_code student_count percent_of_group wkce_average group_count
foreach var in `z'{
    destring `var', replace
}

*Destring school year variable
replace school_year = "2005" if school_year == "2005-06"
replace school_year = "2006" if school_year == "2006-07"
replace school_year = "2007" if school_year == "2007-08"
replace school_year = "2008" if school_year == "2008-09"
replace school_year = "2009" if school_year == "2009-10"
replace school_year = "2010" if school_year == "2010-11"
replace school_year = "2011" if school_year == "2011-12"
replace school_year = "2012" if school_year == "2012-13"
replace school_year = "2013" if school_year == "2013-14"
destring school_year, replace

*Generate various proficiency levels (# of students in each category)
gen min_performance = student_count if test_result==1
bysort district_code school_year grade_level test_subject: egen min = max(min_performance)
drop min_performance

gen basic_performance = student_count if test_result==2
bysort district_code school_year grade_level test_subject: egen basic= max(basic_performance)
drop basic_performance

gen prof_performance = student_count if test_result==3
bysort district_code school_year grade_level test_subject: egen prof= max(prof_performance)
drop prof_performance

gen adv_performance = student_count if test_result==4
bysort district_code school_year grade_level test_subject: egen adv= max(adv_performance)
drop adv_performance

gen notst_performance = student_count if test_result==5
bysort district_code school_year grade_level test_subject: egen notst= max(notst_performance)
drop notst_performance
sort min

*Make sure all of these sum up to "group count"
egen check = rowtotal(min basic prof adv notst)
tab check //this is right

*Keep only variables of interest
drop notst check

*Generate advanced or proficiency threshold
egen advprof = rowtotal(adv prof)

*Generate minimal or basic 
egen minbas = rowtotal(min basic)

*Drop duplicates
rename wkce_average_sc wkce
drop if wkce==. 
drop student_count

duplicates drop district_code school_year wkce min basic prof adv ///
advprof minbas grade_level test_subject, force
drop test_result percent

reshape wide wkce adv prof min basic advprof minbas group_count, i(district_code school_year grade_level) j(test_subject)

*Rename variables for second reshape
rename (group_count1 wkce1 adv1 prof1 min1 basic1 advprof1 minbas1) ///
(num_takers_math wkce_math adv_math prof_math min_math basic_math advprof_math minbas_math)

rename (group_count2 wkce2 adv2 prof2 min2 basic2 advprof2 minbas2) ///
(num_takers_reading wkce_reading adv_reading prof_reading min_reading basic_reading advprof_reading minbas_reading)


reshape wide num_takers_math wkce_math adv_math prof_math min_math basic_math advprof_math minbas_math ///
num_takers_reading wkce_reading adv_reading prof_reading min_reading basic_reading advprof_reading minbas_reading ///
, i(district_code school_year) j(grade_level)


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
*Collapse data to account for these consolidations
collapse (sum) num_takers_math4 min_math4 basic_math4 advprof_math4 minbas_math4 ///
num_takers_reading4 min_reading4 basic_reading4 advprof_reading4 minbas_reading4 ///
num_takers_math8 min_math8 basic_math8 advprof_math8 minbas_math8 num_takers_reading8 ///
min_reading8 basic_reading8 advprof_reading8 minbas_reading8 num_takers_math10 ///
min_math10 basic_math10 advprof_math10 minbas_math10 num_takers_reading10 ///
min_reading10 basic_reading10 advprof_reading10 minbas_reading10 ///
(mean) wkce_math4 wkce_math8 wkce_math10 wkce_reading10 ///
adv_math10 adv_math8 adv_math4 adv_reading10 adv_reading8 adv_reading4 ///
prof_math10 prof_math8 prof_math4 prof_reading10 prof_reading8 prof_reading4 ///
wkce_reading8 wkce_reading4, by(district_code school_year) 

local y num_takers_math4 min_math4 basic_math4 advprof_math4 minbas_math4 ///
num_takers_reading4 min_reading4 basic_reading4 advprof_reading4 minbas_reading4 ///
num_takers_math8 min_math8 basic_math8 advprof_math8 minbas_math8 num_takers_reading8 ///
min_reading8 basic_reading8 advprof_reading8 minbas_reading8 num_takers_math10 ///
min_math10 basic_math10 advprof_math10 minbas_math10 num_takers_reading10 ///
min_reading10 basic_reading10 advprof_reading10 minbas_reading10 ///
wkce_math4 wkce_math8 wkce_math10 wkce_reading10 ///
adv_math10 adv_math8 adv_math4 adv_reading10 adv_reading8 adv_reading4 ///
prof_math10 prof_math8 prof_math4 prof_reading10 prof_reading8 prof_reading4 ///
wkce_reading8 wkce_reading4

foreach var in `y'{
    replace `var'=. if `var'==0
}

*Finally, generate shares rather than numbers
replace advprof_math10 = (advprof_math10/num_takers_math10)*100
replace advprof_math8 = (advprof_math8/num_takers_math8)*100
replace advprof_math4 = (advprof_math4/num_takers_math4)*100

replace advprof_reading10 = (advprof_reading10/num_takers_reading10)*100
replace advprof_reading8 = (advprof_reading8/num_takers_reading8)*100
replace advprof_reading4 = (advprof_reading4/num_takers_reading4)*100

replace minbas_math10 = (minbas_math10/num_takers_math10)*100
replace minbas_math8 = (minbas_math8/num_takers_math8)*100
replace minbas_math4 = (minbas_math4/num_takers_math4)*100

replace minbas_reading10 = (minbas_reading10/num_takers_reading10)*100
replace minbas_reading8 = (minbas_reading8/num_takers_reading8)*100
replace minbas_reading4 = (minbas_reading4/num_takers_reading4)*100

replace adv_math10 = (adv_math10/num_takers_math10)*100
replace adv_math8 = (adv_math8/num_takers_math8)*100
replace adv_math4 = (adv_math4/num_takers_math4)*100

replace adv_reading10 = (adv_reading10/num_takers_reading10)*100
replace adv_reading8 = (adv_reading8/num_takers_reading8)*100
replace adv_reading4 = (adv_reading4/num_takers_reading4)*100

replace prof_math10 = (prof_math10/num_takers_math10)*100
replace prof_math8 = (prof_math8/num_takers_math8)*100
replace prof_math4 = (prof_math4/num_takers_math4)*100

replace prof_reading10 = (prof_reading10/num_takers_reading10)*100
replace prof_reading8 = (prof_reading8/num_takers_reading8)*100
replace prof_reading4 = (prof_reading4/num_takers_reading4)*100

replace basic_math10 = (basic_math10/num_takers_math10)*100
replace basic_math8 = (basic_math8/num_takers_math8)*100
replace basic_math4 = (basic_math4/num_takers_math4)*100

replace basic_reading10 = (basic_reading10/num_takers_reading10)*100
replace basic_reading8 = (basic_reading8/num_takers_reading8)*100
replace basic_reading4 = (basic_reading4/num_takers_reading4)*100

replace min_math10 = (min_math10/num_takers_math10)*100
replace min_math8 = (min_math8/num_takers_math8)*100
replace min_math4 = (min_math4/num_takers_math4)*100

replace min_reading10 = (min_reading10/num_takers_reading10)*100
replace min_reading8 = (min_reading8/num_takers_reading8)*100
replace min_reading4 = (min_reading4/num_takers_reading4)*100

*Generate math/reading average in 10th, 8th, and 4th grade
egen wkce10 = rowmean(wkce_math10 wkce_reading10)
egen wkce8 = rowmean(wkce_math8 wkce_reading8)
egen wkce4 = rowmean(wkce_math4 wkce_reading4)


*****************************************
******SECTION III: SAVE THIS DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\wkce", replace
