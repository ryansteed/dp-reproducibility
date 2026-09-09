/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/22/2020

DESCRIPTION:
This is the master do-file for the construction of Master_Admin_Data_Final. This
is the district-year panel administrative dataset used to construct the one-step
panel and the ITT panel used to generate the main results of the paper. This do-file
has two main sections. First, it runs every other do-file that cleans each individual
dataset. For instance, it first runs do-files that clean the individual district-level
dropout rates, test scores, postsecondary enrollment, expenditures, revenues, etc. After
running each individual do-file that cleans these datasets, Section 2 of the do-file 
merges all of these files by district code and year in order to generate Master_Admin_Data_Final.
*********************************/

*********************************/
*Set Globals
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"

*****************************************
******SECTION I: RUN INDIVIDUAL DO-FILES
******TO CLEAN EACH INDIVIDUAL DATASET 
******USED TO CREATE MASTER PANEL
*****************************************
*Set directory where individual do-files are located
clear
set more off
cd "${path}Do Files\Master Admin Data"

*Run individual do-files
*First, clean revenue limits, expenditures, property values
do "${path}Do Files\Master Admin Data\revenue_limits.do"
do "${path}Do Files\Master Admin Data\expenditures_revenues_ccd.do" 
do "${path}Do Files\Master Admin Data\property_values.do" 

*Clean student outcomes (test scores, dropout rates, and postsec enr)
do "${path}Do Files\Master Admin Data\wkce.do" 
do "${path}Do Files\Master Admin Data\dropout_rate.do" 
do "${path}Do Files\Master Admin Data\grade9_enr.do" 
do "${path}Do Files\Master Admin Data\postsec_enr.do" 

*Clean plausible mechanisms (compensation and experience, turnover, class sizes)
do "${path}Do Files\Master Admin Data\stu_teach_ratio.do" 
do "${path}Do Files\Master Admin Data\comp_experience.do" 
do "${path}Do Files\Master Admin Data\turnover.do" 

*Clean plausible mechanisms at the *school level*
do "${path}Do Files\Master Admin Data\school_level_str.do" 
do "${path}Do Files\Master Admin Data\school_level_enrollment.do" 
do "${path}Do Files\Master Admin Data\school_level_comp.do" 

*Clean district demographics, infrastructure condition, urbanicity 
do "${path}Do Files\Master Admin Data\demographics.do" 
do "${path}Do Files\Master Admin Data\shareof_econ_dis.do" 
do "${path}Do Files\Master Admin Data\initial_inf_condition.do" 
do "${path}Do Files\Master Admin Data\urbanicity.do" 


*****************************************
******SECTION II: MERGE FILES TO GENERATE
******MASTER ADMINISTRATIVE DATASET
*****************************************
*Set directory
clear 
cd "${path}\Data\Raw\Completed_Files"

***Start with expenditure and revenue dataset
use rev_expenditures //available from 1996-97 through 2014-15

***Merge with revenue limits data (1996-2014)
merge 1:1 district_code school_year using revenue_limits
drop _merge

***Merge with property values data (1996-2014)
merge 1:1 district_code school_year using property_values 
keep if _merge==3
drop _merge

***Merge with initial condition of school building infrastructure (1998-99)
merge m:1 district_code using initial_condition
drop _merge //this dataset only has information on 364 school districts

***Merge with share of economically disadvantaged students (2000-01)
merge m:1 district_code using shareof_econdis
drop _merge

***Merge with degree of urbanicity (2014-15)
merge m:1 leaid using urbanicity
drop _merge

***Merge with measure of teacher attrition (1996-2014)
merge 1:1 district_code school_year using turnover
drop _merge

***Merge with measure of student-staff ratios (1996-2014)
merge 1:1 district_code school_year using stu_teach
drop _merge

***Merge with measures of teacher compensation and experience (1997-2014)
merge 1:1 district_code school_year using comp_experience
drop _merge

***Merge with measures of school demographics (enr, share of min, share of econdis)
merge 1:1 district_code school_year using demographics //(2005-2014)
drop _merge

***Merge with measure of district-level postsecondary enrollment (2005-2014)
merge 1:1 district_code school_year using postsec_enr 
drop _merge

***Merge with test scores on the WKCE (2005-2013)
merge 1:1 district_code school_year using wkce
drop _merge

***Merge with each district's dropout rate
merge 1:1 district_code school_year using dropout_rate
drop _merge

***Merge with each district's school-level STR
merge 1:1 district_code school_year using school_level_str
drop _merge

***Merge with each district's school-level compensation
merge 1:1 district_code school_year using school_level_comp
drop _merge

*Keep only variables of interest and label all additional variables
keep lea_name district_code leaid school_year membership tot_exp_mem ///
tot_exp_inst_mem tot_exp_ss_mem tot_exp_oth_mem ss_pupils_mem ss_instruction_mem ///
ss_schooladmin_mem ss_operation_maint_mem ss_transp_mem ss_other_mem tot_capout_mem ///
interest_debt_mem LT_debt_out rev_lim_mem prop_val_mem district_inf_cond ///
econ_disadv_percent above_median urban_centric_locale turnover_LA ///
number_fte_staff_licensed fall_enr ratio_stdnts_to_staff_total ///
ratio_stdnts_to_staff_licensed AverageLocalExperience compensation enrollment ///
perc_econdis perc_min log_enr log_instate_four log_instate_twoyr log_instate_enr ///
log_outofstate_four log_outofstate_twoyr log_outofstate_enr grade9lagged ///
perc_instate num_takers_math4 advprof_math4 num_takers_reading4 advprof_reading4 ///
num_takers_math8 advprof_math8 num_takers_reading8 advprof_reading8 num_takers_math10 ///
min_math10 basic_math10 advprof_math10 num_takers_reading10 advprof_reading10 ///
wkce_math10 student_count dropout_rate el_numteach middle_numteach hi_numteach ///
hi_str mid_str el_str log_hi_avgsalary log_middle_avgsalary log_el_avgsalary ///
hi_avgsal middle_avgsal el_avgsal

*Verify summary statistics and gen other needed vars for analysis
sum
replace perc_instate=. if perc_instate>1 //fix typo
gen logcomp = log(compensation)


*Label variables
label var lea_name "District Name"
label var district_code "District Numeric Identifier (WDPI)"
label var leaid "District Numeric Identifier (NCES)"
label var membership "Total District Membership"
label var school_year "Academic Year (Fall Year)"
label var rev_lim_mem "Revenue Limits PP"
label var prop_val_mem "Equalized Property Values PP"
label var district_inf_cond "Condition of District Infrastructure (1998)"
label var econ_disadv_percent "Percent of Econ. Disadv. Students (2000-01)"
label var above_median "District has Above Median Percent of Econ. Disadv. Students (2000-01)"
label var urban_centric_locale "Urban Centric Locale Code"
label var turnover_LA "Teacher Attrition %"
label var AverageLocalExperience "Average Local Teacher Experience (in years)"
label var compensation "Total Teacher Compensation ($2010)"
label var logcomp "Log of Total Teacher Compensation ($2010)"
label var enrollment "Total District Enrollment"
label var perc_econdis "Percent of Econ. Disadv. Students"
label var perc_min "Percent of Minority Students"
label var log_enr "Log of District Enrollment"
label var grade9lagged "Grade 9 Enrollment in t-3"
label var perc_instate "Percent of Students Enrolled in In-State Postsec. Ed."
label var num_takers_math4 "Number of Students Who Took the Math WKCE in Grade 4"
label var num_takers_math8 "Number of Students Who Took the Math WKCE in Grade 8"
label var num_takers_math10 "Number of Students Who Took the Math WKCE in Grade 10"
label var num_takers_reading4 "Number of Students Who Took the Reading WKCE in Grade 4"
label var num_takers_reading8 "Number of Students Who Took the Reading WKCE in Grade 8"
label var num_takers_reading10 "Number of Students Who Took the Reading WKCE in Grade 10"
label var advprof_math10 "Percent of Students Adv. or Prof. in WKCE Math Grade 10"
label var advprof_math8 "Percent of Students Adv. or Prof. in WKCE Math Grade 8"
label var advprof_math4 "Percent of Students Adv. or Prof. in WKCE Math Grade 4"
label var advprof_reading10 "Percent of Students Adv. or Prof. in WKCE Reading Grade 10"
label var advprof_reading8 "Percent of Students Adv. or Prof. in WKCE Reading Grade 8"
label var advprof_reading4 "Percent of Students Adv. or Prof. in WKCE Reading Grade 4"
label var min_math10 "Percent of Students Who Score Minimal in WKCE math Grade 10"
label var basic_math10 "Percent of Students Who Score Basic in WKCE math Grade 10"
label var wkce_math10 "Average Math WKCE Scale Score in Grade 10"
label var el_numteach "Number of Teachers in Elementary Schools in the District"
label var el_str "Student-Teacher Ratio in Elementary Schools in the District"
label var el_avgsalary "Average Teacher Salaries in Elementary Schools in the District"
label var middle_numteach "Number of Teachers in Middle Schools in the District"
label var mid_str "Student-Teacher Ratio in Middle Schools in the District"
label var middle_avgsalary "Average Teacher Salaries in Middle Schools in the District"
label var hi_numteach "Number of Teachers in High Schools in the District"
label var hi_str "Student-Teacher Ratio in High Schools in the District"
label var hi_avgsalary "Average Teacher Salaries in High Schools in the District"
label var log_el_avgsalary "Log of Average Teacher Salaries in Elementary Schools in the District"
label var log_middle_avgsalary "Log of Average Teacher Salaries in Middle Schools in the District"
label var log_hi_avgsalary "Log of Average Teacher Salaries in High Schools in the District"

*****************************************
******SECTION III: SAVE FINAL
******MASTER ADMINISTRATIVE DATASET
*****************************************
save "${path}Data\Intermediate\Master_Admin_Data_Final", replace



