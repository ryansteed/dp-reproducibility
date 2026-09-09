**************************************************
*Merge cleaned UI data into full estimation sample
*When this do file is called term_index must be set to first term of year to be merged
**************************************************



*Note: have to merge in 2 parts because employment data is too big
merge m:1 hei term_index using $wage1
drop if _merge==2
save "temp data files/merge1.dta", replace
keep if _merge==1
drop _merge 
merge m:1 hei term_index using $wage2, update
drop if _merge==2
save "temp data files/merge2.dta", replace
use "temp data files/merge1.dta", clear
drop if _merge==1
append using "temp data files/merge2.dta"
drop _merge yr_num term_code term_num

*Repeat for naics data
merge m:1 hei term_index using $naics1
drop if _merge==2
save "temp data files/merge1.dta", replace
keep if _merge==1
drop _merge 
merge m:1 hei term_index using $naics2, update
drop if _merge==2
save "temp data files/merge2.dta", replace
use "temp data files/merge1.dta", clear
drop if _merge==1
append using "temp data files/merge2.dta"
drop _merge term_index yr_num term_code term_num
