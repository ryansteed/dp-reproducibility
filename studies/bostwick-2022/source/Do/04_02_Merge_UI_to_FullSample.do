******************************************************************
*Merge cleaned UI employment data into the full estimation sample
******************************************************************


**********************************************************************
*Input files
local full "Analysis_Data/All_Campuses/Full_Data_Sample.dta"
global wage1 "Analysis_Data/All_Campuses/UI_Wages_cleaned_F99-07.dta"
global wage2 "Analysis_Data/All_Campuses/UI_Wages_cleaned_F08-17.dta"
global naics1 "Analysis_Data/All_Campuses/UI_NAICS_cleaned_F99-07.dta"
global naics2 "Analysis_Data/All_Campuses/UI_NAICS_cleaned_F08-16.dta"

*Do files to call
local mergeUI "Current_Do_Files/All_Campuses/04_02a_Run_UI_Merge.do"

*Output files
local out "Analysis_Data/All_Campuses/FullSample_withEmp.dta"
***********************************************************************


use `full', clear
*NAICS industry data only available 2000q1-2018q1
drop if first_term==2

*Keep only pertinent variables
local outcomes "BAin4 BAin5 dropout_sy* transfer_sy* ontrack_enrolled_sy* probation_sy* switch_sy* ever_switch_sy*"
keep hei inst_code female age age2 international race_ind* campus_num first_term  sy_start_index* t tdummy* G1* G2 cluster_id* `outcomes' tenbefore fiveormore started_sy* semester

*Create variables for summer employment (Q2 and Q3) and for school-year employment (Q4 and Q1)
*Separately identify employment in food service and retail industry codes
local emp_vars "employed_q1q4 employed_q2q3 ever_employed"
local FSonly_vars "FS_retail_q1q4 FS_retail_q2q3 ever_FS_retail"
local noFS_vars "employed_noFS_q1q4 employed_noFS_q2q3 ever_employed_noFS"

***Loop over 4 years of enrollment
forval i=1/4 {
	*merge in UI wages from current year of enrollment
	if `i'==1 {
		gen term_index=sy_start_index`i'
	}
	else {
		gen term_index=sy_start_index`i'+1
	}
	do `mergeUI' 

	gen employed_q1q4=(employed_q1 | employed_q4)
	replace employed_q1q4=. if employed_q1==. | employed_q4==.
	gen employed_q2q3=(employed_q2 | employed_q3)
	replace employed_q2q3=. if employed_q2==. | employed_q3==.

	*Separately identify employment NOT in food service and retail industry codes
	forval j=1/4 {
		gen employed_noFS_q`j'=employed_q`j'
		replace employed_noFS_q`j'=0 if FS_retail_q`j'==1
	}
	gen employed_noFS_q1q4=(employed_noFS_q1 | employed_noFS_q4)
	replace employed_noFS_q1q4=. if employed_noFS_q1==. | employed_noFS_q4==.
	gen employed_noFS_q2q3=(employed_noFS_q2 | employed_noFS_q3)
	replace employed_noFS_q2q3=. if employed_noFS_q2==. | employed_noFS_q3==.
	gen ever_employed_noFS=(employed_noFS_q1q4 | employed_noFS_q2q3)
	replace ever_employed_noFS=. if employed_noFS_q1q4==. | employed_noFS_q2q3==.

	*Separately identify employment in ONLY food service and retail industry codes
	gen FS_retail_q1q4=(FS_retail_q1 | FS_retail_q4)
	replace FS_retail_q1q4=. if missing(FS_retail_q1) | missing(FS_retail_q4)
	gen FS_retail_q2q3=(FS_retail_q2 | FS_retail_q3)
	replace FS_retail_q2q3=. if missing(FS_retail_q2) | missing(FS_retail_q3)
	gen ever_FS_retail=(FS_retail_q1q4 | FS_retail_q2q3)
	replace ever_FS_retail=. if FS_retail_q1q4==. | FS_retail_q2q3==. 

	*Drop individal quarter variables
	drop employed_q1-employed_q4 employed_noFS_q1-employed_noFS_q4 FS_retail_q1-FS_retail_q4 naics_q1-naics_q4 wage_q1-wage_q4 total_wage

	*Rename all new employment vars for current school-year
	foreach var of varlist `emp_vars' `FSonly_vars' `noFS_vars' {
		rename `var' `var'_sy`i'
	}

}


****Share of (first 4) school-years or (first 3) summers employed:
gen num_q1q4_noFS=employed_noFS_q1q4_sy1 + employed_noFS_q1q4_sy2 + employed_noFS_q1q4_sy3 + employed_noFS_q1q4_sy4
gen num_q2q3_noFS=employed_noFS_q2q3_sy1 + employed_noFS_q2q3_sy2 + employed_noFS_q2q3_sy3
gen share_summer_noFS=num_q2q3_noFS/3
gen share_sy_noFS=num_q1q4_noFS/4

gen num_FS_retail_q1q4=FS_retail_q1q4_sy1 + FS_retail_q1q4_sy2 + FS_retail_q1q4_sy3 + FS_retail_q1q4_sy4
gen num_FS_retail_q2q3=FS_retail_q2q3_sy1 + FS_retail_q2q3_sy2 + FS_retail_q2q3_sy3
gen share_summer_FS_retail=num_FS_retail_q2q3/3
gen share_sy_FS_retail=num_FS_retail_q1q4/4


save `out', replace
