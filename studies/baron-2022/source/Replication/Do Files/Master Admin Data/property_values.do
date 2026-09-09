/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports and cleans information on each school district's
equalized property values since 1984-85 for each WI school district. This
information comes from the Wisconsin Department of Public Instruction. 
https://dpi.wi.gov/sfs/statistical/longitudinal-data/property-valuation.
I also collect information on total levied property taxes, and on membership.
DATA INPUTS: (1) property_values.xls; (2) cpiu
DATA OUTPUTS: (1) property_values.dta
*********************************/

*****************************************
******SECTION I: IMPORT PROP. VAL DATA
*****************************************
clear
cd "${path}Data\Raw\Property_Values"
import excel using property_values.xls, firstrow sheet(Data)

*****************************************
******SECTION II: GEN DISTRICT-BY-YEAR PANEL
*****************************************
drop if A ==.
rename A district_code 
rename NAME district_name
drop TYPE

*Rename variables of interest
rename (fall84_levy fall85_levy fall86_levy fall87_levy fall88_levy fall89_levy ///
fall90_levy fall91_levy fall92_levy fall93_levy fall94_levy fall95_levy fall96_levy ///
fall97_levy fall98_levy fall99_levy fall00_levy fall01_levy fall02_levy fall03_levy ///
fall04_levy fall05_levy fall06_levy fall07_levy fall08_levy fall09_levy fall10_levy ///
fall11_levy fall12_levy fall13_levy fall14_levy fall15_levy fall16_levy fall17_levy ///
fall18_levy fall19_levy) ///
(prop_tax_rev84 prop_tax_rev85 prop_tax_rev86 prop_tax_rev87 prop_tax_rev88 prop_tax_rev89 ///
prop_tax_rev90 prop_tax_rev91 prop_tax_rev92 prop_tax_rev93 prop_tax_rev94 prop_tax_rev95 prop_tax_rev96 ///
prop_tax_rev97 prop_tax_rev98 prop_tax_rev99 prop_tax_rev00 prop_tax_rev01 prop_tax_rev02 prop_tax_rev03 ///
prop_tax_rev04 prop_tax_rev05 prop_tax_rev06 prop_tax_rev07 prop_tax_rev08 prop_tax_rev09 prop_tax_rev10 ///
prop_tax_rev11 prop_tax_rev12 prop_tax_rev13 prop_tax_rev14 prop_tax_rev15 prop_tax_rev16 prop_tax_rev17 ///
prop_tax_rev18 prop_tax_rev19) 


rename (fall84_value fall85_value fall86_value fall87_value fall88_value fall89_value ///
fall90_value fall91_value fall92_value fall93_value fall94_value fall95_value fall96_value ///
fall97_value fall98_value fall99_value fall00_value fall01_value fall02_value fall03_value ///
fall04_value fall05_value fall06_value fall07_value fall08_value fall09_value fall10_value ///
fall11_value fall12_value fall13_value fall14_value fall15_value fall16_value fall17_value ///
fall18_value fall19_value) ///
(prop_val84 prop_val85 prop_val86 prop_val87 prop_val88 prop_val89 ///
prop_val90 prop_val91 prop_val92 prop_val93 prop_val94 prop_val95 prop_val96 ///
prop_val97 prop_val98 prop_val99 prop_val00 prop_val01 prop_val02 prop_val03 ///
prop_val04 prop_val05 prop_val06 prop_val07 prop_val08 prop_val09 prop_val10 ///
prop_val11 prop_val12 prop_val13 prop_val14 prop_val15 prop_val16 prop_val17 ///
prop_val18 prop_val19) 

*Keep only these variables
keep district_code district_name prop_tax_rev84 prop_tax_rev85 prop_tax_rev86 ///
prop_tax_rev87 prop_tax_rev88 prop_tax_rev89 prop_tax_rev90 prop_tax_rev91 ///
prop_tax_rev92 prop_tax_rev93 prop_tax_rev94 prop_tax_rev95 prop_tax_rev96 ///
prop_tax_rev97 prop_tax_rev98 prop_tax_rev99 prop_tax_rev00 prop_tax_rev01 ///
prop_tax_rev02 prop_tax_rev03 prop_tax_rev04 prop_tax_rev05 prop_tax_rev06 ///
prop_tax_rev07 prop_tax_rev08 prop_tax_rev09 prop_tax_rev10 prop_tax_rev11 ///
prop_tax_rev12 prop_tax_rev13 prop_tax_rev14 prop_tax_rev15 prop_tax_rev16 ///
prop_tax_rev17 prop_tax_rev18 prop_tax_rev19 prop_val84 prop_val85 prop_val86 ///
prop_val87 prop_val88 prop_val89 prop_val90 prop_val91 prop_val92 prop_val93 ///
prop_val94 prop_val95 prop_val96 prop_val97 prop_val98 prop_val99 prop_val00 ///
prop_val01 prop_val02 prop_val03 prop_val04 prop_val05 prop_val06 prop_val07 ///
prop_val08 prop_val09 prop_val10 prop_val11 prop_val12 prop_val13 prop_val14 ///
prop_val15 prop_val16 prop_val17 prop_val18 prop_val19

*Reshape
reshape long prop_tax_rev prop_val, i(district_code) j(school_year) string

*Destring year variable
destring school_year, replace
replace school_year = school_year+1900 if school_year >=20 
replace school_year = school_year+2000 if school_year <=20 

*Sort dataset
sort district_code school_year

*Convert to real 2010 dollars using the Midwestern CPI-U
merge m:1 school_year using "${path}Data\Intermediate\cpiu"
keep if _merge==3
drop _merge
sort district_code school_year
order cpi

*Make a variable CPI in 2010
gen cpi2010 =.
order cpi2010
replace cpi2010=208.046
gen newcpi = cpi/cpi2010
order newcpi

*Write loop to convert to real dollars, per member measures
local z prop_tax_rev prop_val
foreach v in `z'{
replace `v' = (`v'/newcpi) //deflate
}

*Drop these variables
drop newcpi cpi2010 cpi 

*Deal with consolidations, name changes, and mergers
*The are a few consolidations a mergers to worry about. The full list can
*be found here: https://dpi.wi.gov/sms/reorganization/history-and-orders

*(1) River Ridge (merge between Bloomington and West Grant in 1995)
*Since this was in 1995, this merger is not a problem in this dataset.
drop if district_code==4249 | district_code==539

*(2) Trevor - Wilmot (merge between Trevor Grade and Wilmot Grade in 2006)
replace district_code = 5780 if district_code== 5061 //replace Trevor's (Salem) district_code
replace district_code = 5780 if district_code== 5075 //replace Wilmot's district_code
edit if district_code== 5780
sort district_code school_year //at the end, I will collapse by year and district_code to fix this merger


*(3) There was a split between Shawano-Gresham into Shawano and Gresham in 2007-08
replace district_code = 5264 if district_code== 2415

*(4) Glidden and Park Falls merged in 2009 to become Chequamegon
replace district_code = 1071 if district_code == 2205 //glidden
replace district_code = 1071 if district_code == 4242 //park falls
edit if district_code==1071

*(5) Chetek and Weyerhauser merged to become Chetek - Weyerhauser
replace district_code = 1080 if district_code == 1078 //chetek
replace district_code = 1080 if district_code == 6410 //weyerhauser
edit if district_code==1080

*(6) Herman, Neosho, Rubicon merged in 2016
replace district_code=2525 if district_code==4998 //Rubicon 
replace district_code=2525 if district_code==3913 //Neosho
replace district_code=2525 if district_code==2523 //Herman
edit if district_code==2525

*Collapse data to account for these consolidations
collapse (sum) prop_tax_rev prop_val, by(district_code school_year) 

*Save as a tempfile and merge with membership information to gen value/member
tempfile prop_val
drop if school_year==2019
save `prop_val'

clear
import excel using "${path}Data\Intermediate\membership.xlsx", firstrow sheet(Data)


*Rename variables
rename (A NAME D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF ///
AG AH AI AJ AK AL AM) ///
(district_code district_name membership84 membership85 membership86 membership87 ///
membership88 membership89 membership90 membership91 membership92 membership93 ///
membership94 membership95 membership96 membership97 membership98 membership99 ///
membership00 membership01 membership02 membership03 membership04 membership05 ///
membership06 membership07 membership08 membership09 membership10 membership11 ///
membership12 membership13 membership14 membership15 membership16 membership17 ///
membership18 membership19)
drop C

*Reshape
drop if district_code==.
reshape long membership, i(district_code) j(school_year) string
drop if school_year=="19"

***Destring year variable
destring school_year, replace
replace school_year = school_year+1900 if school_year >=20 
replace school_year = school_year+2000 if school_year <=20 

***Sort dataset
sort district_code school_year

*Deal with consolidations, name changes, and mergers

*(1) River Ridge (merge between Bloomington and West Grant in 1995)
drop if district_code==4249 | district_code==539

*(2) Trevor - Wilmot (merge between Trevor Grade and Wilmot Grade in 2006)
*Also, Salem changed name to Trevor in 2000
replace district_code = 5780 if district_code== 5061 //replace Trevor's (Salem) district_code
replace district_code = 5780 if district_code== 5075 //replace Wilmot's district_code
edit if district_code== 5780
sort district_code school_year //at the end, I will collapse by year and district_code to fix this merger


*(3) There was a split between Shawano-Gresham into Shawano and Gresham in 2007-08
edit if district_code==2415|district_code==5264
replace district_code = 5264 if district_code== 2415


*(4) Glidden and Park Falls merged in 2009 to become Chequamegon
replace district_code = 1071 if district_code == 2205 //glidden
replace district_code = 1071 if district_code == 4242 //park falls
edit if district_code==1071

*(5) Chetek and Weyerhauser merged to become Chetek - Weyerhauser
replace district_code = 1080 if district_code == 1078 //chetek
replace district_code = 1080 if district_code == 6410 //weyerhauser
edit if district_code==1080

*(6) Herman, Neosho, Rubicon merged in 2016
replace district_code=2525 if district_code==4998 //Rubicon 
replace district_code=2525 if district_code==3913 //Neosho
replace district_code=2525 if district_code==2523 //Herman
edit if district_code==2525


******************************************************************************
******************************************************************************
collapse (sum) membership, by(district_code school_year)
merge 1:1 district_code school_year using `prop_val'
edit if _merge==1
drop if _merge==1
edit if _merge==2
drop if _merge==2
drop _merge

*How many school districts?
egen unique = group(district_code)

*Generate property tax rev per member
*I have shown that the mill rate (a measure of the school
*portion of the local property tax) decreased rapidly following the enactment
*of revenue limits. However, Referee #1 has suggested that since the mill rate
*depends on assessed values (equalized property value is in the denominator)
*property tax revenue might be a better statistic to examine.
bysort school_year: egen wi_pt_rev = sum(prop_tax_rev)
bysort school_year: egen wi_mem = sum(membership)
gen wi_pt_rev_mem = wi_pt_rev/wi_mem



*****************************************
******SECTION III: SAVE THIS DATASET
*****************************************
***Save this dataset and get ready to merge with master dataset
keep if school_year>=1996 & school_year<=2014
gen prop_val_mem = prop_val/membership
label var prop_val_mem "(Equalized) Property Values per Pupil (2010 dollars)"
keep district_code school_year prop_val_mem
save "${path}Data\Raw\Completed_Files\property_values", replace



