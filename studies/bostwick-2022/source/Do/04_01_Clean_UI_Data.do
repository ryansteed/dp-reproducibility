******************************************************************
*Clean UI employment data for individuals in full estimation sample
******************************************************************


**************************************************
*Input files
local full "Analysis_Data/All_Campuses/Full_Data_Sample.dta"
local full_xwalk "$mydir/Dropbox/OLDA/Combined_HEI_Files/HEI_PSID_KEY_ID_XWALK_03162017.dta"
local raw_UI "Intermediate_Data/All_Campuses/UI_Wages_for_Calendars/UI_Wages_for_Calendars.dct"
local UIdo "Intermediate_Data/All_Campuses/UI_Wages_for_Calendars-value-labels.do"
local terms "$mydir/Dropbox/OLDA/Raw_Other_Files/mytermindex.dta"
local cpi "$mydir/Dropbox/OLDA/Raw_Other_Files/CPI.dta"


*Output files
local list_hei "Intermediate_Data/All_Campuses/FullSample_hei_psids"
local UI_working "Intermediate_Data/All_Campuses/UI_Wages_for_Calendars.dta"
local xwalk "Intermediate_Data/All_Campuses/FullSample_ID_xwalk.dta"

local wages "Analysis_Data/All_Campuses/UI_Wages_cleaned.dta"
local naics "Analysis_Data/All_Campuses/UI_NAICS_cleaned.dta"
local wage1 "Analysis_Data/All_Campuses/UI_Wages_cleaned_F99-07.dta"
local wage2 "Analysis_Data/All_Campuses/UI_Wages_cleaned_F08-17.dta"
local naics1 "Analysis_Data/All_Campuses/UI_NAICS_cleaned_F99-07.dta"
local naics2 "Analysis_Data/All_Campuses/UI_NAICS_cleaned_F08-16.dta"
**************************************************


*Get list of hei_psids from full estimation sample
use `full', clear
keep hei_psid 
duplicates drop
save `list_hei', replace


*Convert UI data into .dta format
infile using `raw_UI', clear
do `UIdo'
rename KEY_ID_TOPC key_id
drop *1995* *1996* *1997* *1998*
compress
save `UI_working', replace


*Make xwalk between full sample hei_psids and key_ids (UI data only has key_id)
use `full_xwalk', clear
merge m:1 hei_psid using `list_hei'
keep if _merge==3
drop _merge
codebook
save `xwalk', replace


***************************************************************************
*Convert UI data to long format
***************************************************************************
*Create a separate long-form file for each of the following variables:
local vars "NAICS1_3_DIGIT NAICS2_3_DIGIT WEEKS1 WEEKS2 WAGES1 WAGES2"
foreach var of local vars {
	*First reshape quarters between 1999q1 and 2009q4
	use `UI_working', clear
	keep key `var'*
	drop *201*
	reshape long `var'_@_TOPC, i(key) j(yearq)
	save "temp data files/`var'", replace
	
	*then reshape 2010q1 to 2018q2
	use `UI_working', clear
	keep key `var'*
	keep key *201*
	reshape long `var'_@_TOPC, i(key) j(yearq)
	
	*Append two time periods together
	append using "temp data files/`var'"
	*Merge in hei_psid
	merge m:1 key_id using `xwalk'
	drop if _merge!=3
	drop _merge
	
	*Create year and quarter variables
	tostring yearq, replace
	gen year=substr(yearq, 1, 4)
	destring year, replace
	gen quarter=substr(yearq, 5, 1)
	destring quarter, replace
	save "temp data files/`var'_long", replace
}


***************************************************************************
*Collapse each long-form file to person-schoolyear level
***************************************************************************
*Wages:
use "temp data files/WAGES1_long", clear
*define employed as having non-missing wages
gen employed=1-missing(WAGES)
*Define which school-year the current quarter corresponds to
gen fall_year=year
replace fall_year=year-1 if quarter!=4
*Drop data from before transcript data starts
drop if fall==1998
*Convert wages to 2018 dollars (CPI in 2018 = 251.107)
rename year Year
merge m:1 Year using `cpi'
gen real_wage = WAGES*251.107/CPI
drop _merge 
forval i=1/4 {
	gen employed_q`i'=0 if quarter==`i'
	replace employed_q`i'=1 if real_wage!=. & quarter==`i'
	gen wage_q`i' = real_wage if quarter==`i'
}
rename fall_year yr_num
save "temp data files/UIcollapsed", replace
forval y=1999/2017 {
	use "temp data files/UIcollapsed", clear
	keep if yr_num==`y'
	collapse (sum) total_wages=real_wage (max) ever_employed=employed (min) employed_q* wage_q*, by(hei yr_num)
	gen term_code="AU"
	merge m:1 yr_num term_code using `terms'
	drop if _merge==2
	drop _m
	if `y'!=1999 {
		append using `wages'
	}
	save `wages', replace
}

*NAICS:
use "temp data files/NAICS1_3_DIGIT_long", clear
*Define which school-year the current quarter corresponds to
gen fall_year=year
replace fall_year=year-1 if quarter!=4
*Drop data from before transcript data starts
drop if fall==1998
*Identify when employment is in Food Service or Retail industry codes
forval i=1/4 {
	gen FS_retail_q`i'=0 if quarter==`i'
	replace FS_retail_q`i'=1 if (NAICS==722 | NAICS==451 | NAICS==452 | NAICS==453 | NAICS==454) & quarter==`i'
	gen naics_q`i' = NAICS if quarter==`i'
}
rename fall_year yr_num
save "temp data files/UIcollapsed", replace
forval y=1999/2016 {
	use "temp data files/UIcollapsed", clear
	keep if yr_num==`y'
	collapse (min) FS_retail_q* naics_q*, by(hei yr_num)
	gen term_code="AU"
	merge m:1 yr_num term_code using `terms'
	drop if _merge==2
	drop _m
	if `y'!=1999 {
		append using `naics'
	}
	save `naics', replace
}


***************************************************************************
*Split data into smaller files (too big for Stata to handle future merges)
***************************************************************************
use `wages', clear
keep if term_index<38
save `wage1', replace
use `wages', clear
keep if term_index>=38
save `wage2', replace

use `naics', clear
keep if term_index<38
save `naics1', replace
use `naics', clear
keep if term_index>=38
save `naics2', replace

