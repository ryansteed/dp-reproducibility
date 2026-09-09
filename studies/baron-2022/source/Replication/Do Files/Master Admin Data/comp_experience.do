/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports and gets ready to merge with admin data information
on teacher salaries, benefits, and experience from 1997-1998 - 2014-2015.

DATA INPUTS: (1) 1997.dta,...,2014.dta; (2) cpiu
DATA OUTPUTS: (1) comp_experience.dta
*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear 
cd "${path}Data\Raw\Compensation_Experience"


*****************************************
******SECTION II: GEN DIST BY YEAR PANEL
*****************************************
***Note: 2010 has numeric variables - append after initial command
append using 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 ///
2011 2012 2013 2014 

***Destring experience variables to append to 2010
destring AverageLocalExperience, replace
destring AverageTotalExperience, replace
append using 2010

***Now, start cleaning file up
***There are numerous variables for district number:
order school_year DistrictCode DistCode DistNo AgencyCode
replace DistNo = DistCode if DistNo==""
replace DistNo = DistrictCode if DistNo==""
replace DistNo = AgencyCode if DistNo==""
drop AgencyCode DistrictCode DistCode
destring DistNo, replace
sort DistNo school_year
rename DistNo district_code // this is the district code variables

***Continue cleaning up district name
replace District = DistrictName if District==""
replace District = AgencyName if District==""
drop AgencyName DistrictName

***Drop unwanted variables
drop CtyCode CESA PosCode Position Year YEAR CountyC PositionName PositionCode ///
LowFringe HighFringe

***Generate compensation variable and destring remaining variables
foreach v in LowSalary HighSalary AverageSalary AverageFringe ///
AverageLocalExperience AverageTotalExperience {
destring `v', replace
}

egen compensation = rowtotal(AverageS AverageF)
order compensation

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
foreach v in LowSalary HighSalary AverageSalary AverageFringe compensation {
replace `v' = (`v'/newcpi) //deflate
}

***Sort and drop other variables
sort district_code school_year
drop _merge cpi* newcpi 



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
****Collapse data to account for these consolidations
collapse (mean) LowS HighS AverageS AverageF AverageL AverageTot comp, by(district_code school_year) 

***Keep only balanced panel
bysort district_code: gen nobs=_N
edit if nobs!=18
drop if nobs!=18
drop nobs


*****************************************
******SECTION III: SAVE DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\comp_experience", replace
