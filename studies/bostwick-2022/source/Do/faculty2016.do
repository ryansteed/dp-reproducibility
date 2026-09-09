* Created   October 5, 2017                                
*
* Modify the path below to point to your data file.
* The specified subdirectory was not created on
* your computer. You will need to do this.
*
* The stat program must be run against the specified
* data file. This file is specified in the program
* and must be saved separately.
*
* This program does not provide tab or summarize for all
* variables.
*
* There may be missing data for some institutions due
* to the merge used to create this file.
*
* This program does not include reserved values in its
* calculations for missing values.
*
* You may need to adjust your memory settings depending
* upon the number of variables and records.
*
* The save command may need to be modified per user
* requirements.
*
* For long lists of value labels, the titles may be
* shortened per program requirements.
*
clear
insheet using "$PATH/Academic Calendar/Data/sal2016_is_data_stata.csv", comma clear
label data "dct_sal2016_is"
label variable unitid   "Unique identification number of the institution"
label variable arank    "Academic rank"
label variable xsainstt "Imputation field for sainstt - Instructional staff - total"
label variable sainstt  "Instructional staff - total"
label variable xsainstm "Imputation field for sainstm - Instructional staff - men"
label variable sainstm  "Instructional staff - men"
label variable xsainstw "Imputation field for sainstw - Instructional staff - women"
label variable sainstw  "Instructional staff - women"
label variable xsa_9mct "Imputation field for sa_9mct - Instructional staff on less than 9-month contract-total"
label variable sa_9mct  "Instructional staff on less than 9-month contract-total"
label variable xsa_9mcm "Imputation field for sa_9mcm - Instructional staff on less than 9-month contract-men"
label variable sa_9mcm  "Instructional staff on less than 9-month contract-men"
label variable xsa_9mcw "Imputation field for sa_9mcw - Instructional staff on less than 9-month contract-women"
label variable sa_9mcw  "Instructional staff on less than 9-month contract-women"
label variable xsatotlt "Imputation field for satotlt - Instructional staff on 9, 10, 11 or 12 month contract-total"
label variable satotlt  "Instructional staff on 9, 10, 11 or 12 month contract-total"
label variable xsatotlm "Imputation field for satotlm - Instructional staff on 9, 10, 11 or 12 month contract-men"
label variable satotlm  "Instructional staff on 9, 10, 11 or 12 month contract-men"
label variable xsatotlw "Imputation field for satotlw - Instructional staff on 9, 10, 11 or 12 month contract-women"
label variable satotlw  "Instructional staff on 9, 10, 11 or 12 month contract-women"
label variable xsa09mct "Imputation field for sa09mct - Instructional staff on 9-month contract-total"
label variable sa09mct  "Instructional staff on 9-month contract-total"
label variable xsa09mcm "Imputation field for sa09mcm - Instructional staff on 9-month contract-men"
label variable sa09mcm  "Instructional staff on 9-month contract-men"
label variable xsa09mcw "Imputation field for sa09mcw - Instructional staff on 9-month contract-women"
label variable sa09mcw  "Instructional staff on 9-month contract-women"
label variable xsa10mct "Imputation field for sa10mct - Instructional staff on 10-month contract-total"
label variable sa10mct  "Instructional staff on 10-month contract-total"
label variable xsa10mcm "Imputation field for sa10mcm - Instructional staff on 10-month contract-men"
label variable sa10mcm  "Instructional staff on 10-month contract-men"
label variable xsa10mcw "Imputation field for sa10mcw - Instructional staff on 10-month contract-women"
label variable sa10mcw  "Instructional staff on 10-month contract-women"
label variable xsa11mct "Imputation field for sa11mct - Instructional staff on 11-month contract-total"
label variable sa11mct  "Instructional staff on 11-month contract-total"
label variable xsa11mcm "Imputation field for sa11mcm - Instructional staff on 11-month contract-men"
label variable sa11mcm  "Instructional staff on 11-month contract-men"
label variable xsa11mcw "Imputation field for sa11mcw - Instructional staff on 11-month contract-women"
label variable sa11mcw  "Instructional staff on 11-month contract-women"
label variable xsa12mct "Imputation field for sa12mct - Instructional staff on 12-month contract total"
label variable sa12mct  "Instructional staff on 12-month contract total"
label variable xsa12mcm "Imputation field for sa12mcm - Instructional staff on 12-month contract men"
label variable sa12mcm  "Instructional staff on 12-month contract men"
label variable xsa12mcw "Imputation field for sa12mcw - Instructional staff on 12--month contract women"
label variable sa12mcw  "Instructional staff on 12--month contract women"
label variable xsamntht "Imputation field for samntht - Number months covered for salary outlays - total"
label variable samntht  "Number months covered for salary outlays - total"
label variable xsamnthm "Imputation field for samnthm - Number of months covered for salary outlays - men"
label variable samnthm  "Number of months covered for salary outlays - men"
label variable xsamnthw "Imputation field for samnthw - Number of months covered for salary outlays - women"
label variable samnthw  "Number of months covered for salary outlays - women"
label variable xsaoutlt "Imputation field for saoutlt - Salary outlays - total"
label variable saoutlt  "Salary outlays - total"
label variable xsaoutlm "Imputation field for saoutlm - Salary outlays - men"
label variable saoutlm  "Salary outlays - men"
label variable xsaoutlw "Imputation field for saoutlw - Salary outlays - women"
label variable saoutlw  "Salary outlays - women"
label variable xsa09mot "Imputation field for sa09mot - Salary outlays for instructional staff on 9-month contract-total"
label variable sa09mot  "Salary outlays for instructional staff on 9-month contract-total"
label variable xsa09mom "Imputation field for sa09mom - Salary outlays for instructional staff on 9-month contract-men"
label variable sa09mom  "Salary outlays for instructional staff on 9-month contract-men"
label variable xsa09mow "Imputation field for sa09mow - Salary outlays for instructional staff on 9-month contract-women"
label variable sa09mow  "Salary outlays for instructional staff on 9-month contract-women"
label variable xsa10mot "Imputation field for sa10mot - Salary outlays for instructional staff on 10-month contract-total"
label variable sa10mot  "Salary outlays for instructional staff on 10-month contract-total"
label variable xsa10mom "Imputation field for sa10mom - Salary outlays for instructional staff on 10-month contract-men"
label variable sa10mom  "Salary outlays for instructional staff on 10-month contract-men"
label variable xsa10mow "Imputation field for sa10mow - Salary outlays for instructional staff on 10-month contract-women"
label variable sa10mow  "Salary outlays for instructional staff on 10-month contract-women"
label variable xsa11mot "Imputation field for sa11mot - Salary outlays for instructional staff on 11-month contract-total"
label variable sa11mot  "Salary outlays for instructional staff on 11-month contract-total"
label variable xsa11mom "Imputation field for sa11mom - Salary outlays for instructional staff on 11-month contract-men"
label variable sa11mom  "Salary outlays for instructional staff on 11-month contract-men"
label variable xsa11mow "Imputation field for sa11mow - Salary outlays for instructional staff on 11-month contract-women"
label variable sa11mow  "Salary outlays for instructional staff on 11-month contract-women"
label variable xsa12mot "Imputation field for sa12mot - Salary outlays for instructional staff on 12-month contract-total"
label variable sa12mot  "Salary outlays for instructional staff on 12-month contract-total"
label variable xsa12mom "Imputation field for sa12mom - Salary outlays for instructional staff on 12-month contract-men"
label variable sa12mom  "Salary outlays for instructional staff on 12-month contract-men"
label variable xsa12mow "Imputation field for sa12mow - Salary outlays for instructional staff on 12-month contract-women"
label variable sa12mow  "Salary outlays for instructional staff on 12-month contract-women"
label variable xsaeq9ot "Imputation field for saeq9ot - Salary outlays for instructional staff equated to a 9-month contract-total"
label variable saeq9ot  "Salary outlays for instructional staff equated to a 9-month contract-total"
label variable xsaeq9om "Imputation field for saeq9om - Salary outlays for instructional staff equated to a 9-month contract-men"
label variable saeq9om  "Salary outlays for instructional staff equated to a 9-month contract-men"
label variable xsaeq9ow "Imputation field for saeq9ow - Salary outlays for instructional staff equated to a 9-month contract-women"
label variable saeq9ow  "Salary outlays for instructional staff equated to a 9-month contract-women"
label variable xsaeq9at "Imputation field for saeq9at - Average salary for instructional staff equated to a 9-month contract-total"
label variable saeq9at  "Average salary for instructional staff equated to a 9-month contract-total"
label variable xsaeq9am "Imputation field for saeq9am - Average salary for instructional staff equated to a 9-month contract-men"
label variable saeq9am  "Average salary for instructional staff equated to a 9-month contract-men"
label variable xsaeq9aw "Imputation field for saeq9aw - Average salary for instructional staff equated to a 9-month contract-men"
label variable saeq9aw  "Average salary for instructional staff equated to a 9-month contract-men"
label variable xsa09mat "Imputation field for sa09mat - Average salary for instructional staff on 9-month contract-total"
label variable sa09mat  "Average salary for instructional staff on 9-month contract-total"
label variable xsa09mam "Imputation field for sa09mam - Average salary for instructional staff on 9-month contract-men"
label variable sa09mam  "Average salary for instructional staff on 9-month contract-men"
label variable xsa09maw "Imputation field for sa09maw - Average salary for instructional staff on 9-month contract-women"
label variable sa09maw  "Average salary for instructional staff on 9-month contract-women"
label variable xsa10mat "Imputation field for sa10mat - Average salary for instructional staff on 10-month contract-total"
label variable sa10mat  "Average salary for instructional staff on 10-month contract-total"
label variable xsa10mam "Imputation field for sa10mam - Average salary for instructional staff on 10-month contract-men"
label variable sa10mam  "Average salary for instructional staff on 10-month contract-men"
label variable xsa10maw "Imputation field for sa10maw - Average salary for instructional staff on 10-month contract-women"
label variable sa10maw  "Average salary for instructional staff on 10-month contract-women"
label variable xsa11mat "Imputation field for sa11mat - Average salary for instructional staff on 11-month contract-total"
label variable sa11mat  "Average salary for instructional staff on 11-month contract-total"
label variable xsa11mam "Imputation field for sa11mam - Average salary for instructional staff on 11-month contract-men"
label variable sa11mam  "Average salary for instructional staff on 11-month contract-men"
label variable xsa11maw "Imputation field for sa11maw - Average salary for instructional staff on 11-month contract-women"
label variable sa11maw  "Average salary for instructional staff on 11-month contract-women"
label variable xsa12mat "Imputation field for sa12mat - Average salary for instructional staff on 12-month contract-total"
label variable sa12mat  "Average salary for instructional staff on 12-month contract-total"
label variable xsa12mam "Imputation field for sa12mam - Average salary for instructional staff on 12-month contract-men"
label variable sa12mam  "Average salary for instructional staff on 12-month contract-men"
label variable xsa12maw "Imputation field for sa12maw - Average salary for instructional staff on 12-month contract-women"
label variable sa12maw  "Average salary for instructional staff on 12-month contract-women"
label variable xsaavmnt "Imputation field for saavmnt - Average weighted monthly salary  - total"
label variable saavmnt  "Average weighted monthly salary  - total"
label variable xsaavmnm "Imputation field for saavmnm - Average weighted monthly salary  - men"
label variable saavmnm  "Average weighted monthly salary  - men"
label variable xsaavmnw "Imputation field for saavmnw - Average weighted monthly salary  - women"
label variable saavmnw  "Average weighted monthly salary  - women"
label define label_arank 7 "All instructional staff total"
label define label_arank 1 "Professor",add
label define label_arank 2 "Associate professor",add
label define label_arank 3 "Assistant professor",add
label define label_arank 4 "Instructor",add
label define label_arank 5 "Lecturer",add
label define label_arank 6 "No academic rank",add
label values arank label_arank
*The following are the possible values for the item imputation field variables
*A Not applicable
*B Institution left item blank
*C Analyst corrected reported value
*D Do not know
*G Data generated from other data values
*H Value not derived - data not usable
*J Logical imputation
*K Ratio adjustment
*L Imputed using the Group Median procedure
*N Imputed using Nearest Neighbor procedure
*P Imputed using Carry Forward procedure
*R Reported
*Z Implied zero
tab arank
tab xsainstt
tab xsainstm
tab xsainstw
tab xsa_9mct
tab xsa_9mcm
tab xsa_9mcw
tab xsatotlt
tab xsatotlm
tab xsatotlw
tab xsa09mct
tab xsa09mcm
tab xsa09mcw
tab xsa10mct
tab xsa10mcm
tab xsa10mcw
tab xsa11mct
tab xsa11mcm
tab xsa11mcw
tab xsa12mct
tab xsa12mcm
tab xsa12mcw
tab xsamntht
tab xsamnthm
tab xsamnthw
tab xsaoutlt
tab xsaoutlm
tab xsaoutlw
tab xsa09mot
tab xsa09mom
tab xsa09mow
tab xsa10mot
tab xsa10mom
tab xsa10mow
tab xsa11mot
tab xsa11mom
tab xsa11mow
tab xsa12mot
tab xsa12mom
tab xsa12mow
tab xsaeq9ot
tab xsaeq9om
tab xsaeq9ow
tab xsaeq9at
tab xsaeq9am
tab xsaeq9aw
tab xsa09mat
tab xsa09mam
tab xsa09maw
tab xsa10mat
tab xsa10mam
tab xsa10maw
tab xsa11mat
tab xsa11mam
tab xsa11maw
tab xsa12mat
tab xsa12mam
tab xsa12maw
tab xsaavmnt
tab xsaavmnm
tab xsaavmnw
summarize sainstt
summarize sainstm
summarize sainstw
summarize sa_9mct
summarize sa_9mcm
summarize sa_9mcw
summarize satotlt
summarize satotlm
summarize satotlw
summarize sa09mct
summarize sa09mcm
summarize sa09mcw
summarize sa10mct
summarize sa10mcm
summarize sa10mcw
summarize sa11mct
summarize sa11mcm
summarize sa11mcw
summarize sa12mct
summarize sa12mcm
summarize sa12mcw
summarize samntht
summarize samnthm
summarize samnthw
summarize saoutlt
summarize saoutlm
summarize saoutlw
summarize sa09mot
summarize sa09mom
summarize sa09mow
summarize sa10mot
summarize sa10mom
summarize sa10mow
summarize sa11mot
summarize sa11mom
summarize sa11mow
summarize sa12mot
summarize sa12mom
summarize sa12mow
summarize saeq9ot
summarize saeq9om
summarize saeq9ow
summarize saeq9at
summarize saeq9am
summarize saeq9aw
summarize sa09mat
summarize sa09mam
summarize sa09maw
summarize sa10mat
summarize sa10mam
summarize sa10maw
summarize sa11mat
summarize sa11mam
summarize sa11maw
summarize sa12mat
summarize sa12mam
summarize sa12maw
summarize saavmnt
summarize saavmnm
summarize saavmnw


drop if arank!=7
keep unitid satotlt
rename satotlt faculty
gen year=2016

save "$PATH/Academic Calendar/Data/faculty2016.dta", replace
