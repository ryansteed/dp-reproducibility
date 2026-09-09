/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file generates variables from the individual-level dataset.
This dataset is publicly available through the WDPI "All Staff" files. It contains
information on the universe of WI public school teachers. In this do-file,
I will use it to create a "Lagged Attrition" variable to measure whether
additional school spending leads to changes in teacher turnover.

DATA INPUTS: (1) indiv_level.dta
DATA OUTPUTS: (1) turnover.dta

*********************************/

*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASET
*****************************************
clear
cd "${path}Data\Raw\Individual_Level"
use indiv_level


*****************************************
******SECTION II: CLEAN DATASET
*****************************************
***The first thing to do here is to decode the uniqueid variable in order to 
***be able to use it

***Sort this dataset
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

***Now, generate the variable leaver
bysort teacher: gen leaver = (district_code!=district_code[_n-1])
order leaver

***Generate first observation in the sample for each teacher
bysort teacher: gen firstobs = (_n==1)
order firstobs
replace leaver=. if firstobs==1

***Generate a lead of leaver
bysort teacher: gen lead_leaver = leaver[_n+1]
order lead_leaver
*replace lead_leaver =. if year==1995
*drop if year==2015

***Weight by FTE
replace lead_leaver=1 if lead_leaver==. & year!=2015 // this gets at people who leave the sample
destring fte, replace
replace fte=fte/100
replace lead_leaver=fte*lead_leaver
tab lastname if year==2015 & lead_leaver!=.
drop if year==2015

***Generate number of leavers per school district
bysort district_code year: egen num_leavers = sum(lead_leaver)

****Generate number of teachers per school district
bysort district_code year: egen num_teachers = sum(fte)

***Generate turnover rate_dt = number of leavers_t-1/number of teachers_t-1
order num_leavers num_teachers
gen turnover = num_leavers / num_teachers
order turnover
order year
replace year = year+1
rename year school_year
duplicates drop district_code school_year, force
keep district_code school_year turnover num_leavers num_teachers
replace turnover = turnover*100
rename turnover turnover_LA


***Keep only full panel
bysort district_code: gen nobs=_N
edit if nobs!=20

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
collapse (sum) num_leavers num_teachers (mean) turnover_LA [aw=num_teachers] ///
, by(district_code school_year)

bysort district_code: gen nobs=_N
drop nobs
keep if school_year<=2014

*****************************************
******SECTION III: SAVE CLEAN DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\turnover", replace
