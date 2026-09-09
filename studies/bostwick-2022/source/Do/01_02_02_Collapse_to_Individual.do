***************************************************************************
*Take long-form file of first-time freshman enrollment
*reshape to wide, then collapse to one obs per person
*June 6, 2018
***************************************************************************


***************************************************************************
*Input files:
local in "Intermediate_Data/All_Campuses/FTFresh_FallStarts_00-16_Long.dta"

*Output files
local out "Intermediate_Data/All_Campuses/Indiv_FTFresh_allOH_SM99-SP17.dta"
***************************************************************************



************************************************
*Collapse to person-inst-campus-schoolyear level
*Then reshape wide to person-inst-campus level
************************************************

*Variables needed:
*Credits: total credits/courses attempted per school-year
*Majors: cip code and stem designation initially and at end of each school-year
*GPA: cumulative GPA at end of each school-year



*Collapse down to school-year level (by person)
local last=1
foreach i of numlist 2(2)14{
*Split sample (too big for preserve)
use `in', clear
keep if inst_num>=`last' & inst_num<=`i'
gen summer_credits=credit_hrs_attempted if term_code=="SM"
collapse (first) admis hei_psid inst_code campus_code first_term last_term sex_code birth* race* sy_start_index=term_index term_first_declared initial_major initial_stem first_enroll* enroll_gap* (sum) *credit* courses* (last) gpa_spy=gpa major_cipcode2010_spy=major_cipcode2010 stem_spy=major_stemdesignation, by(person_campus sy)
reshape wide sy_start_index *credit* courses* gpa_spy major_cipcode2010_spy stem_spy, i(person_campus) j(sy)
save "temp data files/enroll_wide_inst`last'-`i'.dta", replace
local last=`i'+1
}
*Append the data back together
local last=1
foreach i of numlist 2(2)12 {
append using "temp data files/enroll_wide_inst`last'-`i'.dta"
local last=`i'+1
}

save `out', replace




