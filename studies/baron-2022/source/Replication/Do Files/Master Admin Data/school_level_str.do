/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file generates a *school-level* dataset of student-teacher ratios for each 
public school in Wisconsin. I use the individual level dataset reported in the
"All-Staff" files by the WDPI to create this dataset. It first generates a school-level 
file of the number of teachers per school in Wisconsin. It then merges this information 
to "school_level_enrollment" to generate stu-teacher ratio at the school level. 

DATA INPUTS: (1) indiv_level; (2) cpiu; (3) agency_certified_2015-16
DATA OUTPUTS: (1) school_level_comp.dta
*********************************/

*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
cd "${path}Data\Raw\Individual_Level"
use indiv_level

*****************************************
******SECTION II: GEN DIST BY YEAR PANEL
*****************************************
***Generate numeric identifier
sort uniqueid year //uniqueid is a unique identifier made up of firstname+lastname+birth date
tab firstname
drop if firstname =="-"|firstname=="0"|firstname=="\"|firstname=="]"

egen long teacher = group(uniqueid)
drop uniqueid
order teacher //this is the unique numerical identifier for each teacher

***Now, check for duplicates
duplicates list teacher year //none

***Order dataset
order teacher lastname birthyr district_code district_name year
destring year, replace
destring district_code, replace

***Destring school code variable
destring school_code, replace
order school_name school_code

***Generate number of teachers at the school level
bysort district_code school_code year: gen numteach = _N
order numteach 

***Destring additional variables
destring school_code, replace
destring district_code, replace


***Drop duplicates by school
duplicates drop district_code school_code year numteach, force

***Keep only relevant years
drop if year==1995|year==2015


***Merge this information to school-level enrollment
merge 1:1 district_code school_code year using "${path}Data\Raw\Completed_Files\school_level_enrollment"
keep if _merge==3
drop _merge

***Merge to directory information to identify high schools, middle schools, and
***elementary schools
tempfile schoolvars 
save `schoolvars', replace

***Import directory of schools
clear
insheet using "${path}Data\Raw\Directory\agency_certified_2015-16.csv"

***Clean up dataset
tab grade_group
keep school_code district_code grade_group school_name district_name

replace grade_group="1" if grade_group =="Elementary School"|grade_group=="Combined Elementary/Secondary School"
replace grade_group="2" if grade_group =="Junior High School"|grade_group=="Middle School"
replace grade_group="3" if grade_group =="High School"
tab grade_group


***Keep only relevant information
keep district_code school_code grade_group

***Get rid of duplicates
duplicates list district_code school_code

***Merge to tempfile
merge 1:m district_code school_code using `schoolvars'
keep if _merge==3

***Drop duplicates
duplicates drop district_code school_code year, force


***Keep only relevant variables
keep district_code grade_group school_code school_name district_code district_name ///
year numteach student_count
sort district_code school_code year

***Destring the variable "grade_group"
destring grade_group, replace

***Keep only relevant variables
keep district_code year grade_group numteach student_count


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

collapse (sum) numteach student_count, by(district_code grade_group year) 
reshape wide numteach student_count, i(district_code year) j(grade_group)

***Rename variables
rename (student_count1 student_count2 student_count3) ///
(el_enr middle_enr hi_enr)

rename (numteach1 numteach2 numteach3) ///
(el_numteach middle_numteach hi_numteach)

***Rename variable
rename year school_year

***Generate student-teacher ratios
gen hi_str = hi_enr/hi_numteach
gen mid_str = middle_enr/middle_numteach
gen el_str = el_enr/el_numteach


***Examine summary statistics
sum hi_str mid_str el_str, d
local z hi_str mid_str el_str
*Truncate top & bottom 1% of each

foreach v in `z'{
   qui su `v', d
   replace `v'=. if `v'<r(p1)
   replace `v'=. if `v'>r(p99) 
}

*****************************************
******SECTION III: SAVE CLEAN DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\school_level_str", replace

