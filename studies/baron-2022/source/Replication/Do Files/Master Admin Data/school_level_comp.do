/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file generates a *school-level* dataset of teacher salaries for each 
public school in Wisconsin. I use the individual level dataset reported in the
"All-Staff" files by the WDPI to create this dataset. 


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
******SECTION II: CLEAN DATASET
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
egen compensation = rowtotal(salary fringe)
destring fte, replace

rename year school_year
bysort district_code school_code school_year: egen avgsalary = wtmean(salary), weight(fte)
bysort district_code school_code school_year: egen avgfringe = wtmean(fringe), weight(fte)
bysort district_code school_code school_year: egen avgcomp = wtmean(comp), weight(fte)
bysort district_code school_code school_year: egen numfte = sum(fte)

duplicates drop district_code school_code school_year, force

***Keep only relevant years
drop if school_year==1995|school_year==2015

***Convert nominal figures to 2010 dollars using the Midwestern CPI-U
merge m:1 school_year using "${path}Data\Intermediate\cpiu"
edit if _merge==2 // I simply don't have info on comp/exp for those years
drop if _merge==2
order cpi
sort district_code school_year

**Make a variable CPI in 2010
gen cpi2010 =.
replace cpi2010=208.046
gen newcpi = cpi/cpi2010

***Convert
foreach v in avgsalary avgfringe avgcomp {
replace `v' = (`v'/newcpi) //deflate
}

***Sort and drop other variables
sort district_code school_code school_year
drop _merge cpi* newcpi 

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
duplicates drop district_code school_code school_year, force

***Keep only relevant variables
keep district_code grade_group school_code school_name district_code district_name ///
school_year avg* numfte
sort district_code school_code school_year

***Destring the variable "grade_group"
destring grade_group, replace

***Keep only relevant variables
keep district_code school_year grade_group numfte avg*

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
collapse (mean) avg* [aw=numfte], by(district_code grade_group school_year) 
reshape wide avg*, i(district_code school_year) j(grade_group)

***Rename variables
rename (avgsalary1 avgsalary2 avgsalary3) ///
(el_avgsalary middle_avgsalary hi_avgsalary)

rename (avgfringe1 avgfringe2 avgfringe3) ///
(el_avgfringe middle_avgfringe hi_avgfringe)

rename (avgcomp1 avgcomp2 avgcomp3) ///
(el_avgcomp middle_avgcomp hi_avgcomp)

***Generate logs
sum hi* middle* el*
foreach v in el_avgsalary middle_avgsalary hi_avgsalary ///
el_avgfringe middle_avgfringe hi_avgfringe ///
el_avgcomp middle_avgcomp hi_avgcomp {
    gen log_`v' = log(`v'+1)
}

***Examine summary statistics
local z el_avgsalary middle_avgsalary hi_avgsalary ///
el_avgfringe middle_avgfringe hi_avgfringe ///
el_avgcomp middle_avgcomp hi_avgcomp

*Truncate top & bottom 1% of each
foreach v in `z'{
   qui su `v', d
   replace `v'=. if `v'<r(p1)
   replace `v'=. if `v'>r(p99) 
}


*****************************************
******SECTION III: SAVE CLEAN DATASET
*****************************************
***Save this dataset
save "${path}Data\Raw\Completed_Files\school_level_comp", replace
