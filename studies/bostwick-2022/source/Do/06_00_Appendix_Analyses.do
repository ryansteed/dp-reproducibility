***************************************************************************
*Run Analysis for Appendix Tables A3-A8 and Appendix Figure A4

*October 15, 2020
***************************************************************************


*Current User for directories
global mydir "/Users/vkbostwick"
cd "$mydir/Dropbox/OLDA/Calendars"


***************************************************************************
*Input files
global main "Analysis_Data/All_Campuses/Main_Data_Sample.dta"
global full "Analysis_Data/All_Campuses/Full_Data_Sample.dta"
global with_emp "Analysis_Data/All_Campuses/FullSample_withEmp.dta"

*Do files to call
local event_study "Current_Do_Files/All_Campuses/03_01_02_Event_Study_Analysis.do"


*Set lists of control variables
global controls "female age age2 international race_ind1-race_ind4"
global FEs "i.campus_num i.first_term"
global time_trends "c.first_term#i.campus_num"

***************************************************************************



***************************************************************************
*Table A3: Timing of Calendar Switch for Ohio Campuses
***************************************************************************
capture log close
log using "Log Files/All_Campuses/TableA3.log", replace
*Year of Switch to Semesters:
*MIAM & AKRN switch to semester sometime before 1987
*BGSU switches to semester in F1982
*CLEV switches to semester in F1999
*KENT switches to semester in F1979
*TLDO switches to semester in F1997
*CINC, OHSU, OHUN, WSUN switch to semester in SM/F2012
*CNTL switches to semester in F2005
*SHAW switches to semester in SM2007
*YNGS switches to semester in F00
use $full, clear
tab campus_code semester, row
log close



***************************************************************************
*Table A4: Effect of Switching to Semesters on First-Year Outcomes with Limited Cohorts
***************************************************************************
*Repeat first-year mechanism analysis with limited sample
*Use only t=-1 cohort (1 year before switch to semesters) as "control" 
*and t=0 cohort as "treament"
capture log close
log using "Log Files/All_Campuses/TableA4.log", replace
local outcomes "dropout_sy1 transfer_sy1 full_load_sy1 probation_sy1 switch_sy1"
use $full, clear
keep if t==0 | t==-1
foreach y of varlist `outcomes' {
	*Campus-level clustering:
	reg `y' G2 $controls $FEs , cluster(campus_num)
	*Wild bootstrap:
	boottest {G2}, boott(wild) small
}
log close




***************************************************************************
*Figure A4: Event Study: Mechanism Analysis–Effect of Switching to Semesters on Cumulative Outcomes by Year in School
***************************************************************************
capture log close
log using "Log Files/All_Campuses/FigureA4.log", replace
*Keep cohorts included constant across years:
*sample is conditional on enrolling 4+ years
use $main, clear
keep if started_sy4==1
local outcomes "ontrack_enrolled_sy probation_spy ever_switch_sy"
foreach var of local outcomes {
	*Loop over 4 years of enrollment
	forval i=1/4 {
		local y "`var'`i'"
		*Arguments to pass: 1 = outcome variable; 2 = year of enrollment at which outcome is measured
		do `event_study' `y' `i'
	}
}
log close



***************************************************************************
*Table A5: Effect of Switching to Semesters on Student-Level Cumulative Outcomes with Individual Fixed Effects
***************************************************************************
*Run mechanism outcomes using individual FE approach
capture log close
log using "Log Files/All_Campuses/TableA5.log", replace

*Limit the sample to cohorts that we can observe for 5+ years
use $full, clear
keep if first_term<=54

local outcomes "ontrack_enrolled_sy probation_spy ever_switch_sy"
*reshape to long
reshape long `outcomes', i(person_campus) j(sy)
keep `outcomes' person_campus sy campus_num campus_code inst_code first_term cluster* 
xtset person_campus sy
*Calculate term index for each school-year observation
gen sy_term_index=first_term+4*(sy-1)
*Limit analysis to first 5 years of enrollment
drop if sy>5

***Create main x-var: semester***
*AKRN, BGSU, CLEV, KENT, MIAM, TLDO are always on semesters
*BGSU switches to semester in F1982
*CLEV switches to semester in F1999
*KENT switches to semester in F1979
*TLDO switches to semester in F1997
gen semester=1 if inst_code=="AKRN" | inst_code=="BGSU" | inst_code=="CLEV" | inst_code=="KENT" | inst_code=="MIAM" | inst_code=="TLDO"
*CINC, OHSU, OHUN, WSUN switch to semester in SM/F2012
replace semester=(sy_term_index>=54) if inst_code=="CINC" | inst_code=="OHSU" | inst_code=="OHUN" | inst_code=="WSUN"
*CNTL switches to semester in F2005
replace semester=(sy_term_index>=26) if inst_code=="CNTL"
*SHAW switches to semester in SM2007
replace semester=(sy_term_index>=34) if inst_code=="SHAW"
*YNGS switches to semester in F00
replace semester=(sy_term_index>=6) if inst_code=="YNGS"

*Run mechanism regressions
foreach var of local outcomes {
	*Multi-way clustering:
	reghdfe `var'  semester , absorb(person_campus sy sy_term) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
	*Campus-level clustering:
	xtreg `var'  semester i.sy i.sy_term, fe cluster(campus_num)
	*Wild bootstrap:
	boottest  {semester}, boott(wild) small
}
log close






***************************************************************************
*Table A6: Effect of Switching to Semesters on Student-Level Cumulative Outcomes by Year in School (Full Sample)
***************************************************************************
*Repeat mechanism analysis for cumulative measures
*Do NOT limit sample to student who enroll for 4+ year
capture log close
log using "Log Files/All_Campuses/TableA6.log", replace
local outcomes "ontrack_enrolled_sy probation_spy ever_switch_sy"
use $full, clear
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




***************************************************************************
*Table A7: Effect of Switching to Semesters on Summer Employment (Full Sample)
***************************************************************************
capture log close
log using "Log Files/All_Campuses/TableA7.log", replace
*Do NOT limit sample to student who enroll for 4+ year
use $with_emp, clear

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
*Table A8: Effect of Switching to Semesters on School-Year Employment (Full Sample)
***************************************************************************
capture log close
log using "Log Files/All_Campuses/TableA8.log", replace
*Do NOT limit sample to student who enroll for 4+ year
use $with_emp, clear

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
