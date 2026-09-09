/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports and gets ready to merge with the main bond file info
on the infrastructure condition of each school building in WI. In 1998, the 
legislature passed a law require the DPI to survey the condition of most school
buildings in the state. The survey was conducted during the 1998-99 school year 
and a report was issued in 1999-2000. 

DATA INPUTS: (1) fasrv_database.xls
DATA OUTPUTS: (1) initial_condition.dta

*********************************/

*********************************/
*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
cd "${path}Data\Raw\Infrastructure"
import excel using fasrv_database.xls, firstrow


*****************************************
******SECTION II: CLEAN DATASET
*****************************************
***How many school districts are in this dataset?
egen uniqueid = group(district)
order uniqueid

***The purpose of this dataset is twofold. (1) To examine het. in capital exp.
***effects by initial condition of the building. (2) To examine WI's institutional
***context. What was the condition of these buildings at the beg. of the sample?

***First, get this dataset ready to merge with master administrative dataset
***Since this dataset is at the individual building level, I need to first
***create the average original condition of buildings in that district.
***I will gen a total square foot-weighted average of the condition of the
***initial buildings in the state

***Note that I have two variables: "original" condition and "addition" condition.
***Since I am interested in understanding the building condition as of 1998,
***I need to take into account this addition.
rename district district_code
order total_sqft original_sqft original_condition addition_condition

replace total_sqft = original_sqft if total_sqft==0 //total sqft as of 1998-99
gen additional_sqft = total_sqft - original_sqft // total additional sqft from original building to 1998-99
order additional_sqft
replace additional=0 if additional<0 //these are clear coding mistakes

***Generate an individual school building condition (original + addition)
gen share_addition = additional_sqft/total_sqft //share of total sq. footage in additions
gen share_original = original_sqft/total_sqft //share of total sq. footage in original structure
order share_addition share_original

replace original_condition=. if original_condition==7
replace addition_condition=. if addition_condition==7

gen building_condition = (share_addition)*addition_condition + (share_original)*original_condition
order building_condition 
tab building_condition

***Fix variable
replace building_condition=original_condition if (total_sqft<original_sqft)
replace building_condition = original_condition if addition_condition==.
tab building_condition

***Bin the condition variable
replace building_condition = round(building_condition)
tabplot building_condition

*ssc install _gwtmean
bysort district_code: egen condition = wtmean(building_condition), weight(total_sqft)
order building_condition condition
replace condition = round(condition)
duplicates drop condition district_code, force
tabplot condition
drop if condition==.

***Rename variables and keep only variables of interest
rename condition district_inf_cond
label var district_inf_cond "Infrastructure Condition of Buildings as of 1998-99"
keep district_code district_inf_cond

***Fix mergers or consolidations
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

******************************************************************************
******************************************************************************
****Collapse data to account for these consolidations
collapse (mean) district_inf_cond, by(district_code) 
replace district_inf_cond=round(district_inf_cond)
tabplot district_inf_cond

*****************************************
******SECTION III: SAVE DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\initial_condition", replace

