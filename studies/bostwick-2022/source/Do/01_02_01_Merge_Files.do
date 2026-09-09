***************************************************************************
*Create a file that merges all undergraduate enrollment SM99-SP17 with
*Demographics, credits, GPA, and Major codes
*keep only students who started in the Fall terms of 99-16
*June 6, 2018
***************************************************************************


***************************************************************************
*Input files:
local enroll "Intermediate_Data/All_Campuses/Enroll_allOH_SM99-SP17.dta"
local demos "Intermediate_Data/All_Campuses/Entrance_allOH_Und_FirstTime.dta"
local credits "Intermediate_Data/All_Campuses/Credits_allOH_SM99-SP17.dta"
local gpa "Intermediate_Data/All_Campuses/GPA_allOH_SM99-SP17.dta"
local majors "Intermediate_Data/All_Campuses/majors_matched_toCIP.dta"
local inst_num_list "Intermediate_Data/All_Campuses/Inst_num_list.dta"
local terms "$mydir/Dropbox/OLDA/Raw_Other_Files/mytermindex.dta"

*Do files to call
local match_majors "Current_Do_Files/All_Campuses/01_02_01a_Match_Majors_toCIP.do"

*Output files
local enroll_demos "Intermediate_Data/All_Campuses/FTFresh_enroll_allOH_SM99-SP17.dta"
local out "Intermediate_Data/All_Campuses/FTFresh_FallStarts_00-16_Long.dta"

***************************************************************************



************************************************
*Keep only fall-starters
************************************************

*Only keep students who started in the Fall terms of 99-16
use `enroll', clear
gen temp=(term_code!="AU" & first_term==term_index)
egen todrop=max(temp), by(hei_psid inst_code campus_code)
drop if todrop
drop temp todrop
compress
save "temp data files/enroll_fallonly.dta", replace


*****************************************************************
*Merge in Demographics and limit sample to first-time freshmen
*****************************************************************
***Note: each row is a person-inst-campus-term
***Note: demos file does not have campus code (only inst code)
local last=1
foreach i of numlist 24 48 72{
use "temp data files/enroll_fallonly.dta", clear
keep if first_term>=`last' & first_term<=`i'
merge m:1 hei_psid inst_code using `demos', keep(match)
drop _merge
save "temp data files/enroll_plus_demos_`last'-`i'.dta", replace
local last=`i'+1
}

local last=1
foreach i of numlist 24 48 {
append using "temp data files/enroll_plus_demos_`last'-`i'.dta"
local last=`i'+1
}

*Drop the obs where first term in enrollment file != first term in entrance file
bysort person_campus (term_index): gen todrop=(yr_num[1]!=first_enroll_yr[1] | term_code[1]!=first_enroll_term[1])
drop if todrop==1
drop todrop
*Keep only students who start as freshmen
bysort person_campus (term_index): gen todrop=(rank_code[1]!="FR")
drop if todrop==1
drop todrop




************************************************
*If a student simultaneously enrolls as a first-time freshman 
*at 2 different institutions - OK keep
*at 2 campuses of the same institution - keep campus with more (non-filled) obs
************************************************

*identify FTF at multiple campuses
duplicates tag hei term_index inst_code, gen(temp)
egen person_inst_dup=max(temp), by(hei)
*delete the campus with less terms enrolled
egen num_terms_enroll=count(yr_num), by(hei inst_code campus_code)
bysort hei_psid inst_code (num_terms_enroll): drop if (num_terms_enroll!=num_terms_enroll[_N])
drop temp person_inst_dup num_terms_enroll
*Otherwise, delete the campus with the earlier end term
bysort hei_psid inst_code (last_term): drop if last_term!=last_term[_N]
*otherwise, keep at random
bysort hei_psid inst_code (campus_code): drop if campus_code!=campus_code[_N]

encode inst_code, gen(inst_num)
compress
save `enroll_demos', replace


*merge in inst_num_list created in 01_01_03_Calc_Credit_Hours.do
keep if term_index<=36
merge m:1 inst_code using `inst_num_list', keep(master matched)
save "temp data files/temp.dta", replace
use `enroll_demos', clear
keep if term_index>36
merge m:1 inst_code using `inst_num_list', keep(master matched)
append using "temp data files/temp.dta"
drop _merge
save `enroll_demos', replace



************************************************
*Call do file that takes all major codes
*Matches to CIP data
************************************************

do `match_majors' 


************************************************
*Merge in credits attempted and completed
*Merge in GPA
*Merge in CIP codes/titles/etc. for each major
************************************************
***Note: this loop must correspond to loop in 01_01_03_Calc_Credit_Hours.do
local last=1
foreach i of numlist 2 4 6 7 8 10 12 14{
*Split sample (too big for merge)
use `enroll_demos', clear
keep if inst_num>=`last' & inst_num<=`i'

*merge in yr_num and term_code for missing rows
merge m:1 term_index using `terms', update
drop if _merge==2
drop _merge

*Merge in credit data
merge 1:1 hei_psid inst_code campus_code yr_num term_code using "temp data files/collapsed_credits_inst`last'-`i'.dta", keep(master match)
*If _merge=master only, replace missing credits with 0 credits
foreach var of varlist course* credit* {
replace `var'=0 if _merge==1
}
drop _merge

*Merge in GPA
merge m:1 hei_psid inst_code yr_num term_code using `gpa', keep(master match)
drop _merge

*Merge in major CIP codes
merge m:1 major_study_field_code term_index using `majors', keep(master match)
drop _merge

save "temp data files/enroll_withcredits`last'-`i'.dta", replace
local last=`i'+1
}

*Put data back together
local last=1
foreach i of numlist 2 4 6 7 8 10 12 {
append using "temp data files/enroll_withcredits`last'-`i'.dta"
local last=`i'+1
}

*Keep track of how many gaps in enrollment (credits attempted==0) each student has
*count Fall and Spring terms only
egen enroll_gaps=sum(credit_hrs_attempted==0 & (term_code=="AU" | term_code=="SP")), by(hei_psid inst_code campus_code)

*Fill-down previous gpa in missing quarters
bysort person_campus (term_index): replace gpa=gpa[_n-1] if person_campus==person_campus[_n-1] & gpa==.

save "temp data files/enroll_long.dta", replace



************************************************
*Keep only first 6 years of enrollment
************************************************

*Identify first term with a declared major
gen undeclared=(major_study_field_code=="UNDECI")
bysort person_campus (undeclared term_index): gen term_first_declared=term_index[1]
*Save initial major and stem designation
bysort person_campus (term_index): gen initial_major=major_cipcode2010[1]
bysort person_campus (term_index): gen initial_stem=major_stemdesignation[1]

***Generate school-year variable***
*If started in F2009 then sy=1 if term={F2009, W2010, SP2010}
*sy=2 if term={SM2010, F2010, W2011, SP2011}
gen sy=ceil((term_index-first_term+2)/4)

***Only keep first 6 years of enrollment
drop if sy>6

*Keep track of how many gaps in enrollment (credits attempted==0) each student has in first 6 years
*count Fall and Spring terms only
egen enroll_gaps_first6yrs=sum(credit_hrs_attempted==0 & (term_code=="AU" | term_code=="SP")), by(hei_psid inst_code campus_code)

compress
save `out', replace




