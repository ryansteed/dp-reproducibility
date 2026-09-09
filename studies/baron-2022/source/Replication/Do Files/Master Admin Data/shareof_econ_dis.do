/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports data containing information on the share of
economically disadvantaged students at a school district during the
2000-01 academic year (the earliest year of data available for this var).
The goal is to show heterogeneity in school spending effects by the share
of economically disadvantaged students

DATA INPUTS: (1) enrollment_by_economic_status_2000-01.csv
DATA OUTPUTS: (1) shareof_econdis.dta
*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
set more off
cd "${path}Data\Raw\ShareEconDis"
insheet using enrollment_by_economic_status_2000-01.csv

*****************************************
******SECTION II: GEN DIST BY YEAR PANEL
*****************************************
***Keep only district-level information
destring district_number, replace
replace year=year-1
sort district_number year
keep if school_type=="Summary"

***Drop charter schools
drop if charter=="Y"

***Drop data for the entire state
drop if district_number==.
rename district_number district_code

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


****(3) There was a split between Shawano-Gresham into Shawano and Gresham in 2007-08
***Gresham appears in the data from 2007 on.
***I will take the Shawano-Gresham school district as one through the sample.
replace district_code = 5264 if district_code== 2415
edit if district_code==2415|district_code==5264

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
rename year school_year
keep school_year district_code total_enr econ_disadv_count not_econd_disadv_count
local z total_enr econ_disadv_count not_econd_disadv_count
foreach var in `z'{
    destring `var', replace
}

collapse (sum) total_enr econ_disadv_count not_econd_disadv_count, by(district_code)
gen school_year=2000

***Generate Shares
gen econ_disadv_percent = econ_disadv_count/total_enr
replace econ_disadv_percent=econ_disadv_percent*100

***Keep only variables of interest
keep district_code econ_disadv_percent school_year

***Summary statistics for this variable
sum econ_disadv, detail
gen above_median = (econ_disadv >=18.17427)
gen above_mean = (econ_disadv >=19.70575)

*****************************************
******SECTION III: SAVE DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\shareof_econdis", replace
