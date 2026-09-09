***************************************************************************
*Run Employment Analyses
*Creates Tables 8-10 and Figures 6-7 in manuscript

*No institution-specific time trends in these regressions

*Calculate Standard Errors 3 ways:
*1) Campus-level clustering
*2) Campus-level Wild Cluster Bootstrap
*3) Multi-way clustering

*October 15, 2020
***************************************************************************



*Current User for directories
global mydir "/Users/vkbostwick"
cd "$mydir/Dropbox/OLDA/Calendars"


***************************************************************************
*Input files
global with_emp "Analysis_Data/All_Campuses/FullSample_withEmp.dta"

*Do files to call
local event_study "Current_Do_Files/All_Campuses/05_01_Employment_Event_Study.do"

*Set lists of control variables
global controls "female age age2 international race_ind1-race_ind4"
global FEs "i.campus_num i.first_term"
***************************************************************************



***************************************************************************
*Table 8: Employment Summary Statistics
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Table8.log", replace
****Summary Stats on Employment Data****
*Keep cohorts included constant across years:
*sample is conditional on enrolling 4+ years
use $with_emp, clear
keep if sy_start_index4!=. & started_sy4==1


*Panel A: Excluding Retail and Food Service Employment
*Column 1: All Students
summ share_summer_noFS employed_noFS_q2q3*  share_sy_noFS employed_noFS_q1q4*
*Column 2 & 3: Semester vs. Quarters (dropping partially-treated)
*Note: G1_4 = 1 if in partially-treated cohorts
bysort semester: summ share_summer_noFS employed_noFS_q2q3*  share_sy_noFS employed_noFS_q1q4* if G1_4==0

*Panel B: Retail and Food Service Employment Only
*Column 1: All Students
summ share_summer_FS_retail FS_retail_q2q3*  share_sy_FS_retail FS_retail_q1q4*
*Column 2 & 3: Semester vs. Quarters (dropping partially-treated)
bysort semester: summ share_summer_FS_retail FS_retail_q2q3*  share_sy_FS_retail FS_retail_q1q4* if G1_4==0

*Is internship-type summer employment different between semesters/quarters?
tab semester, summ(share_summer_noFS)
forval i=1/3 {
tab employed_noFS_q2q3_sy`i' G2, chi2 col
ttest  employed_noFS_q2q3_sy`i', by(semester)
}

log close





***************************************************************************
*Figure 6: Event Study: Summer Employment 
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Figure6.log", replace
*Keep cohorts included constant across years:
*sample is conditional on enrolling 4+ years
use $with_emp, clear
keep if sy_start_index4!=. & started_sy4==1
*Loop over 3 years of enrollment
forval i=1/3 {
	local y "employed_q2q3_sy`i'"
	*Arguments to pass: 1 = outcome variable; 2 = year of enrollment at which outcome is measured
	do `event_study' `y' `i'
}
log close






***************************************************************************
*Table 9: Effect of Switching to Semesters on Summer Employment 
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Table9.log", replace
*Keep cohorts included constant across years:
*sample is conditional on enrolling 4+ years
use $with_emp, clear
keep if sy_start_index4!=. & started_sy4==1

*Panel A: Excluding Retail and Food Service Employment
*Column 1: Share of summers employed
*Multi-way clustering:
reghdfe share_summer_noFS G1_4 G2 $controls  i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
*Campus-level clustering:
reg share_summer_noFS G1_4 G2 $controls $FEs , cluster(campus_num)
*Wild bootstrap:
boottest {G1_4} {G2}, boott(wild) small

*Column 2-4: Employment in each summers
*Loop over 3 years of enrollment
forval i=1/3 {
	local y "employed_noFS_q2q3_sy`i'"
	summ `y'
	*Use partially-treated group for t+1 outcomes (e.g. for 1st-year outcome use G1_2)
	local j=`i'+1
	*Multi-way clustering:
	reghdfe `y' G1_`j' G2 $controls i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
	*Campus-level clustering:
	reg `y' G1_`j' G2 $controls $FEs , cluster(campus_num)
	*Wild bootstrap:
	boottest {G1_`j'} {G2}, boott(wild) small
}


*Panel B: Retail and Food Service Employment Only
*Column 1: Share of summers employed
*Multi-way clustering:
reghdfe share_summer_FS_retail G1_4 G2 $controls  i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
*Campus-level clustering:
reg share_summer_FS_retail G1_4 G2 $controls $FEs , cluster(campus_num)
*Wild bootstrap:
boottest {G1_4} {G2}, boott(wild) small

*Column 2-4: Employment in each summers
*Loop over 3 years of enrollment
forval i=1/3 {
	local y "FS_retail_q2q3_sy`i'"
	summ `y'
	*Use partially-treated group for t+1 outcomes (e.g. for 1st-year outcome use G1_2)
	local j=`i'+1
	*Multi-way clustering:
	reghdfe `y' G1_`j' G2 $controls i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
	*Campus-level clustering:
	reg `y' G1_`j' G2 $controls $FEs , cluster(campus_num)
	*Wild bootstrap:
	boottest {G1_`j'} {G2}, boott(wild) small
}

log close




***************************************************************************
*Figure 6: Event Study: School-Year Employment 
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Figure7.log", replace
*Keep cohorts included constant across years:
*sample is conditional on enrolling 4+ years
use $with_emp, clear
keep if sy_start_index4!=. & started_sy4==1
*Loop over 4 years of enrollment
forval i=1/4 {
	local y "employed_q1q4_sy`i'"
	*Arguments to pass: 1 = outcome variable; 2 = year of enrollment at which outcome is measured
	do `event_study' `y' `i'
}
log close





***************************************************************************
*Table 10: Effect of Switching to Semesters on School-Year Employment 
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Table10.log", replace
*Keep cohorts included constant across years:
*sample is conditional on enrolling 4+ years
use $with_emp, clear
keep if sy_start_index4!=. & started_sy4==1

*Panel A: Excluding Retail and Food Service Employment
*Column 1: Share of school-years employed
*Multi-way clustering:
reghdfe share_sy_noFS G1_4 G2 $controls  i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
*Campus-level clustering:
reg share_sy_noFS G1_4 G2 $controls $FEs , cluster(campus_num)
*Wild bootstrap:
boottest {G1_4} {G2}, boott(wild) small

*Column 2-5: Employment in each of the school-years
*Loop over 4 years of enrollment
forval i=1/4 {
	local y "employed_noFS_q1q4_sy`i'"
	summ `y'
	*Freshman year, no partially treated group:
	if `i'==1 {
		*Multi-way clustering:
		reghdfe `y' G2 $controls i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
		*Campus-level clustering:
		reg `y' G2 $controls $FEs , cluster(campus_num)
		*Wild bootstrap:
		boottest {G2}, boott(wild) small
	}
	else {
		*Multi-way clustering:
		reghdfe `y' G1_`i' G2 $controls i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
		*Campus-level clustering:
		reg `y' G1_`i' G2 $controls $FEs , cluster(campus_num)
		*Wild bootstrap:
		boottest {G1_`i'} {G2}, boott(wild) small
	}
}


*Panel B: Retail and Food Service Employment Only
*Column 1: Share of school-years employed
*Multi-way clustering:
reghdfe share_sy_FS_retail G1_4 G2 $controls  i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
*Campus-level clustering:
reg share_sy_FS_retail G1_4 G2 $controls $FEs , cluster(campus_num)
*Wild bootstrap:
boottest {G1_4} {G2}, boott(wild) small

*Column 2-5: Employment in each of the school-years
*Loop over 4 years of enrollment
forval i=1/4 {
	local y "FS_retail_q1q4_sy`i'"
	summ `y'
	*Freshman year, no partially treated group:
	if `i'==1 {
		*Multi-way clustering:
		reghdfe `y' G2 $controls i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
		*Campus-level clustering:
		reg `y' G2 $controls $FEs , cluster(campus_num)
		*Wild bootstrap:
		boottest {G2}, boott(wild) small
	}
	else {
		*Multi-way clustering:
		reghdfe `y' G1_`i' G2 $controls i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
		*Campus-level clustering:
		reg `y' G1_`i' G2 $controls $FEs , cluster(campus_num)
		*Wild bootstrap:
		boottest {G1_`i'} {G2}, boott(wild) small
	}
}

log close





