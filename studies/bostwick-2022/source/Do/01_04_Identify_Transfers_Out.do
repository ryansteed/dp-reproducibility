************************************************************
*Identify students who enroll at a different campus (as an undergrad) following last_term
*(aka students who transfer out of original college)
*June 4, 2018
************************************************************


***************************************************************************
*Input and output files:
local in "Intermediate_Data/All_Campuses/Indiv_FTFresh_withDegrees_SM99-SP17.dta"
local all_enroll "Intermediate_Data/All_Campuses/Enroll_allOH_unclean"
local out "Intermediate_Data/All_Campuses/Enrollment_Data_noHS_SM99-SP17.dta"
***************************************************************************


	
*Take individual-level enrollment file and keep only identifiers and last_term
use `in', clear
keep hei_psid inst_code campus_code last_term

*Merge in all undergrad enrollment for those students
rename inst_code main_inst
rename campus_code main_campus
joinby hei_psid using `all_enroll', update

*Drop enrollment before last_term
drop if term_index<last_term
*If there is no enrollment after last_term, then they did not transfer out
bysort hei_psid main_campus (term_index): gen transfer_out=(last_term<term_index[_N])
keep hei main* transfer
rename main_campus campus_code
rename main_inst inst_code
duplicates drop

*Merge back into individual-level cleaned enrollment file
merge 1:1 hei inst campus using `in'
drop _merge

*Note: 2 types of problem
*(1) Person who earns degree and then goes on to another university should not be labeled as transfering out
*(2) Person who transfers to another campus and then earns a degree should not ba labeled as everBA==1
gen yrsenroll=(last_term-first_term+1)/4
replace transfer_out=0 if transfer_out==1 & everBA==1 & yrstoBA<=yrsenroll
gen remove_BA=(transfer_out==1 & everBA==1 & yrstoBA>yrsenroll)
foreach var of varlist *degree* {
capture replace `var'=. if remove_BA==1
capture replace `var'="" if remove_BA==1
}
replace everBA=0 if remove_BA==1
replace multipleBA=0 if remove_BA==1
replace yrstoBA=. if remove_BA==1
drop remove_BA yrsenroll

save `out', replace
