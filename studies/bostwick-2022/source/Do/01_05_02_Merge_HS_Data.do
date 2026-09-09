****************************************************
*Merge in cleaned High School zip code data
*September 25, 2020
****************************************************


**************************************************
*Input files
local in "Intermediate_Data/All_Campuses/Enrollment_Data_noHS_SM99-SP17.dta"
local hs_und "Intermediate_Data/All_Campuses/high_school_undergraduates.dta"
local hs_non_und "Intermediate_Data/All_Campuses/high_school_non_undergrad.dta"
local acs "$mydir/Dropbox/OLDA/Raw_Other_Files/ACS_HH_Income_byZip_2006-2010.dta"

*Output files
local with_hs "Analysis_Data/All_Campuses/Final_Enrollment_Data_SM99-SP17.dta"

***************************************************************************


use `in' , clear
compress
merge 1:m hei inst using `hs_und'
drop if _merge==2
duplicates tag hei inst, gen(dups)
tab dups
drop if dups>0 & (yr_num!=first_enroll_yr_num | term_code!=first_enroll_term_code)
drop dups

*If unmatched to hs data for undergrad admission, try non-undergrad
preserve
keep if _merge==3
drop _merge
save "temp data files/temp.dta", replace
restore
keep if _merge==1
drop _merge yr_num act_code grad_year term_code
merge 1:m hei inst using `hs_non_und'
drop if _merge==2
duplicates tag hei inst, gen(dups)
tab dups
drop dups _merge
append using "temp data files/temp.dta"
gen no_hs=missing(act_code)

***Merge in mean and median incomes for HS zip codes***
destring hs_zip, gen(zip)
merge m:1 zip using `acs'
drop if _merge==2
drop _merge
rename mean mean_income
rename median median_income
save `with_hs', replace
