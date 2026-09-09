***************************************************************************
*Run Main Analyses
*Creates Tables 4-7 and Figures 3-5 in manuscript

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
global main "Analysis_Data/All_Campuses/Main_Data_Sample.dta"
global full "Analysis_Data/All_Campuses/Full_Data_Sample.dta"

*Do files to call
local heterogeneity "Current_Do_Files/All_Campuses/03_01_01_Heterogeneity_Analysis.do"
local event_study "Current_Do_Files/All_Campuses/03_01_02_Event_Study_Analysis.do"


*Set lists of control variables
global controls "female age age2 international race_ind1-race_ind4"
global FEs "i.campus_num i.first_term"
global time_trends "c.first_term#i.campus_num"

***************************************************************************




***************************************************************************
*Table 4: Individual-Level Summary Statistics
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Table4.log", replace
use $full, clear
*Panel A: Characteristics of First-Year Students
summ female race_ind* international age
*Panel B: Graduation Outcomes
summ BAin4 BAin5
*Panel C: First-Year Academic Outcomes
summ dropout_sy1 transfer_sy1 full_load_sy1 gpa_sy1 probation_sy1 switch_sy1
log close




***************************************************************************
*Figure 3: Students’ Enrollment Status By Year
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Figure3.log", replace
****Look at timing of transfer vs dropout vs graduation*****
*limit to cohorts that we see for 6+ years
use $full , clear
keep if dropout_by6!=.
*Collapse down to averages
collapse (mean) dropout_by* BAin* transfer_by* 
*Create bar graph
gen id=1
reshape long dropout_by BAin transfer_by , i(id) j(endyear)
gen enrolled=1-BAin-dropout_by-transfer_by
graph bar enrolled dropout transfer BA, over(endyear) percent blabel(bar, format( %4.1f)) legend(label(1 "Enrolled") label(2 "Dropped Out") label(3 "Transferred") label(4 "Graduated")) ytitle("% of students") scheme(s2mono) graphregion(color(white))
graph export "Log Files/All_Campuses/Dropout_Timing_6yrs.png", replace
log close




***************************************************************************
*Table 5: Effect of Switching to Semesters on Graduation Rates
***************************************************************************
****Replicate On-time Graduation results from Institution-Level Analysis****
capture log close
log using "Log Files/All_Campuses/Table5.log", replace
use $main, clear
*Panel A: Effect on 4-yr graduation rates
summ BAin4 
*Multi-way clustering:
	reghdfe BAin4 G1_4 G2 $controls $time_trends i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
*Campus-level clustering:
	reg BAin4 G1_4 G2 $controls $FEs $time_trends, cluster(campus_num)
*Wild bootstrap:
	boottest {G1_4} {G2}, boott(wild) small

*Panel B: Effect on 5-yr graduation rates
summ BAin5 
*Multi-way clustering:
	reghdfe BAin5 G1_5 G2 $controls $time_trends i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
*Campus-level clustering:
	reg BAin5 G1_5 G2 $controls $FEs $time_trends, cluster(campus_num)
*Wild bootstrap:
	boottest {G1_5} {G2}, boott(wild) small
	
*Repeat the above regressions estimated separately for: women, men, URM, non-URM, low-income, high-income
	do `heterogeneity' 

log close



***************************************************************************
*Figure 4: Effect of Switching to Semesters on Graduation Rates
***************************************************************************
***Main Event Study Graphs***
capture log close
log using "Log Files/All_Campuses/Figure4.log", replace
use $full, clear
*Arguments to pass: 1 = outcome variable; 2 = year of enrollment at which outcome is measured
do `event_study' BAin4 4
do `event_study' BAin5 5
log close





***************************************************************************
*Table 6: Effect of Switching to Semesters on First-Year Outcomes
***************************************************************************
*Mechanism Analysis for First-Year Students
capture log close
log using "Log Files/All_Campuses/Table6.log", replace
local outcomes "dropout_sy1 transfer_sy1 full_load_sy1 probation_sy1 switch_sy1"
use $full, clear
summ `outcomes'
foreach y of varlist `outcomes' {
	*Multi-way clustering:
	reghdfe `y' G2 $controls $time_trends i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
	*Campus-level clustering:
	reg `y' G2 $controls $FEs $time_trends, cluster(campus_num)
	*Wild bootstrap:
	boottest {G2}, boott(wild) small
}
log close




***************************************************************************
*Figure 5: Event Study: Mechanism Analysis–First-Year Outcomes
***************************************************************************
capture log close
log using "Log Files/All_Campuses/Figure5.log", replace
local outcomes "dropout_sy1 transfer_sy1 full_load_sy1 probation_sy1 switch_sy1"
use $full, clear
foreach y of varlist `outcomes' {
	*Arguments to pass: 1 = outcome variable; 2 = year of enrollment at which outcome is measured
	do `event_study' `y' 1
}
log close








***************************************************************************
*Table 7: Effect of Switching to Semesters on Student-Level Cumulative Outcomes by Year in School
***************************************************************************
*Run Each Mechanism for Freshman-Senior Year
*Keep cohorts included constant across years:
*sample is conditional on enrolling 4+ years
capture log close
log using "Log Files/All_Campuses/Table7.log", replace
local outcomes "ontrack_enrolled_sy probation_spy ever_switch_sy"
use $main, clear
keep if started_sy4==1
foreach var of local outcomes {
	summ `var'*
	*Freshman year, no partially treated group:
	local y "`var'1"
	*Multi-way clustering:
	reghdfe `y'  G2 $controls $time_trends i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
	*Campus-level clustering:
	reg `y' G2 $controls $FEs $time_trends, cluster(campus_num)
	*Wild bootstrap:
	boottest  {G2}, boott(wild) small

	*2nd-4th years:
	forval t=2/4 {
		local y "`var'`t'"
		*Multi-way clustering:
		reghdfe `y' G1_`t' G2 $controls $time_trends i.first_term, absorb(campus_num) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
		*Campus-level clustering:
		reg `y' G1_`t' G2 $controls $FEs $time_trends, cluster(campus_num)
		*Wild bootstrap:
		boottest {G1_`t'} {G2}, boott(wild) small
	}

}

log close










