******************************************************************
*Take course enrollment file
*Collapse down to term-level
*keep: total credits attempted; total credits earned; total courses attempted;
*total coursed completed
*May 16, 2018
******************************************************************


***************************************************************************
*Input files:
local in "$mydir/Dropbox/OLDA/Combined_HEI_Files/hei_crse_enroll_SM99-SP17.dta"


*output files:
local out "Intermediate_Data/All_Campuses/Credits_allOH_SM99-SP17.dta"

local inst_num_list "Intermediate_Data/All_Campuses/Inst_num_list.dta"
***************************************************************************





use `in', clear



*keep only undergrad students (note first-time freshmen at Toledo are mis-classified as admis=="HGH" in 2013)
keep if admis_area=="UND" | admis_area=="HGH" 
*keep only attempted academic credit at this institution
keep if attempt_acad_cr=="I"
*keep only enrollment in degree-granting instituions
keep if inst_code=="AKRN" | inst_code=="BGSU" | inst_code=="CINC" | inst_code=="CLEV" | inst_code=="CNTL" | inst_code=="KENT" | inst_code=="MIAM" | inst_code=="OHSU" | inst_code=="OHUN" | inst_code=="SHAW" | inst_code=="TLDO" | inst_code=="WSUN" | inst_code=="YNGS"

replace crse_outcomeid=7 if gpa!=.
gen completed=crse_outcomeid==7

*Drop duplicate obs
drop crse_enroll_audit_sw id_num crse_sect_id key_id inst_temp_id hei_ranid inst_assigned_sw
duplicates drop
duplicates tag hei_psid inst_code campus_code yr_num term_code crse_id, gen(dups)
*If one dup is for credit and others are not, only keep the credit one
egen max_credit=max(crse_enroll_cr_hrs), by(hei_psid inst_code campus_code yr_num term_code crse_id)
drop if (crse_enroll_cr_hrs==0 & crse_enroll_cr_hrs!=max_credit & dups>0)
drop dups max_credit
*if one dup is a completed course and the other isn't keep the completion
duplicates tag hei_psid inst_code campus_code yr_num term_code crse_id, gen(dups)
egen max_completed=max(completed), by(hei_psid inst_code campus_code yr_num term_code crse_id)
drop if (completed==0 & max_completed!=0 & dups>0)
drop dups max_completed
duplicates tag hei_psid inst_code campus_code yr_num term_code crse_id, gen(course_dups)
tab course_dups
*Leave the remaining duplicates for now (0.18% of data)

****Collapse to person-inst-campus-term level****
*Must do in parts (size constraint)
encode inst_code, gen(inst_num)
compress
save "temp data files/temp.dta", replace


*Save list of inst_code inst_num mappings for use in 01_02_01_Merge_Files.do
keep inst_code inst_num
duplicates drop
save `inst_num_list', replace


local last=1
foreach i of numlist 2 4 6 7 8 10 12 14 {
use "temp data files/temp.dta", clear
keep if inst_num>=`last' & inst_num<=`i'
gen credit_hrs_completed=crse_enroll_cr_hrs*completed
collapse (sum) credit_hrs_attempted=crse_enroll_cr_hrs credit_hrs_completed courses_completed=completed course_dups (count) courses_attempted=completed , by(hei_psid inst_code campus_code yr_num term_code)
save "temp data files/collapsed_credits_inst`last'-`i'.dta", replace
local last=`i'+1
}

*Append segments back together
use "temp data files/collapsed_credits_inst1-2.dta", clear
local last=3
foreach i of numlist 4 6 7 8 10 12 14{
append using "temp data files/collapsed_credits_inst`last'-`i'.dta"
local last=`i'+1
}

*The course outcome variable and gpa only start in 2012
replace credit_hrs_completed=. if yr_num<2012
replace courses_completed=. if yr_num<2012

save `out', replace
