
*** This do file generates the datasets used to create figures A1 and A2 for the paper
*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 


*** This do file performs a placebo test
*** We assign the treatment status to each state not ending FPUC or PUA before September 2021 in our sample and run regressions
*** with the each placebo "treated state" and the other states not ending early as control states. 
*** We then compare the distribution of placebo treatment effects with the 
*** actual treatment effect calculated using the states that actually ended as the treated states 


*** Last updated: 8/16/2023


set more off
capture log close
clear all


****************************************************************************************************
************				 1. Program: DD Placebo Results						        ************
**************************************************************************************************** 

capture program drop did_placebo
program define did_placebo

	syntax, outcome(string) sample(string) treatstate(real) treatdate(real) controls(string) regtype(string) [matc(real 1)]
	
	cap drop treat weight treat post sample
	
	qui gen sample = 1 if `sample' == 1 & inrange(date,733,739)

	* Set treat post and weights for each regression
	qui gen treat =.
	qui gen post =.
	
	* Control states are always states ending neither program
	qui replace treat = 0 if endallstate == 0
	qui replace treat = 1 if statefip == `treatstate'
	
	* Generate treat and post indicators
	qui replace post = 0 if inrange(month, 2, 6)
	qui replace post = 1 if inrange(month, 7, 8)

	qui gen weight = perwt
	qui replace weight = panlwt if "`outcome'" == "UEtoE_2m"


*** DD Regression

	* Sparse controls 
	if "`controls'" == "sparse" & "`regtype'" == "DD" {
		qui reghdfe `outcome' i.treat##i.post [aw=weight] if sample == 1, absorb(statefip date age educ) cluster(statefip) nosample noconstant
	}
	* Add Covid controls 
	if "`controls'" == "covid" & "`regtype'" == "DD"  {
		qui reghdfe `outcome' i.treat##i.post lnnewcases stringencyindex [aw=weight] if sample == 1, absorb(statefip date age educ) cluster(statefip) nosample noconstant
	}	

	* Indicator for whether the estimate is a placebo
	local placebo = 1
	
	local beta = _b[1.treat#1.post]
	local se = _se[1.treat#1.post]
	local pval = 2*ttail(e(df_r),abs(_b[1.treat#1.post]/_se[1.treat#1.post]))
	local ci_lower = _b[1.treat#1.post] - invttail(e(df_r),0.025)*_se[1.treat#1.post]
	local ci_upper = _b[1.treat#1.post] + invttail(e(df_r),0.025)*_se[1.treat#1.post]

	matrix est[`matc',1] = `treatstate'
	matrix est[`matc',2] = `treatdate'
	matrix est[`matc',3] = `beta'
	matrix est[`matc',4] = `se'
	matrix est[`matc',5] = `pval'
	matrix est[`matc',6] = `ci_lower'
	matrix est[`matc',7] = `ci_upper'
	matrix est[`matc',8] = `placebo'
	matrix est[`matc',9] = `matc'

	* labels
	c_local matid`matc'sample = "`sample'"
	c_local matid`matc'outcome = "`outcome'"
	c_local matid`matc'controls = "`controls'"
	c_local matid`matc'regtype = "`regtype'"
		
	c_local matid`matc'lab = "`sample'`outcome'`treatstate'`treatdate'`controls'"
	
	* next value in matrix 
	c_local nmat = `matc' + 1 

end 



****************************************************************************************************
************				 1. Program: DDD Placebo Results						    ************
**************************************************************************************************** 


capture program drop ddd_placebo
program define ddd_placebo

	syntax, outcome(string) sample(string) treatstate(real) treatdate(real) controls(string) regtype(string) [matc(real 1)]

	local datemin = `treatdate' - 5
	local datemax = `treatdate' + 4

	
	cap drop treat weight treat post sample baseyear2019
	
	* Generate 2019 or 2021 indicator
	qui gen baseyear2019 = 0 if year == 2019
	qui replace baseyear2019 = 1 if year == 2021
	
	qui gen sample = 1 if `sample' == 1 


	* Set treat post and weights for each regression
	qui gen treat =.
	qui replace treat = 0 if endallstate == 0
	qui replace treat = 1 if statefip == `treatstate'
	
	* Generate treat and post indicators
	qui gen post =.
	qui replace post = 0 if inrange(month, 2, 6)
	qui replace post = 1 if inrange(month, 7, 8)

	qui gen weight = perwt
	qui replace weight = panlwt if "`outcome'" == "UEtoE"
	qui replace weight = panlwt if "`outcome'" == "UEtoE_2m"
	qui replace weight = panlwt if "`outcome'" == "NEtoE"
	qui replace weight = panlwt if "`outcome'" == "UNEtoE"
	qui replace weight = panlwt if "`outcome'" == "UNEtoE_2m"
	
*** DDD regression

	* Sparse controls 
	qui reghdfe `outcome' i.treat##i.baseyear2019##i.post [aw=weight] if sample == 1, absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip date age educ) cluster(statefip) nosample noconstant
		
	
	* Indicator for whether the estimate is a placebo
	local placebo = 1
	
	local beta = _b[1.treat#1.baseyear2019#1.post]
	local se = _se[1.treat#1.baseyear2019#1.post]
	local pval = 2*ttail(e(df_r),abs(_b[1.treat#1.baseyear2019#1.post]/_se[1.treat#1.baseyear2019#1.post]))
	local ci_lower = _b[1.treat#1.baseyear2019#1.post] - invttail(e(df_r),0.025)*_se[1.treat#1.baseyear2019#1.post]
	local ci_upper = _b[1.treat#1.baseyear2019#1.post] + invttail(e(df_r),0.025)*_se[1.treat#1.baseyear2019#1.post]

	matrix est[`matc',1] = `treatstate'
	matrix est[`matc',2] = `treatdate'
	matrix est[`matc',3] = `beta'
	matrix est[`matc',4] = `se'
	matrix est[`matc',5] = `pval'
	matrix est[`matc',6] = `ci_lower'
	matrix est[`matc',7] = `ci_upper'
	matrix est[`matc',8] = `placebo'
	matrix est[`matc',9] = `matc'

	* labels
	c_local matid`matc'sample = "`sample'"
	c_local matid`matc'outcome = "`outcome'"
	c_local matid`matc'controls = "`controls'"
	c_local matid`matc'regtype = "`regtype'"
		
	c_local matid`matc'lab = "`sample'`outcome'`treatstate'`treatdate'`controls'"
	
	* next value in matrix 
	c_local nmat = `matc' + 1 

end 


















**** Load data and run programs
use "$wrkdir/individual-analysis.dta", replace

* Generate locals to loop through
local outcomes UEtoE_2m

* SAmples 25-54, 16-64, and 16 and over
local samples age2554 age1664 age16plus

* States that ended FPUC nor PUA neither before September are the sample
levelsof statefip if endallstate == 0, local(treatstates)


local treatdates 737

local regtypes DD DDD

local controlsets sparse covid

local states_num: word count `treatstates'
local outcomes_num: word count `outcomes'
local dates_num: word count `treatdates'
local reg_num: word count `regtypes'
local control_num: word count `controlsets'
local sample_num: word count `samples'

di "`dates_num'"
di "`outcomes_num'"
di "`states_num'"

* Count total iterations
* Multiply by 2 sets of controls, 3 samples, and 2 regression types
local iter = `states_num' * `outcomes_num' * `dates_num' * `control_num' * `reg_num' * `sample_num'

di "`iter'"

set trace off
*set trace on
set tracedepth 1


matrix define est = J(`iter', 10, .)

local nmat = 1


*** Loop through DD Placebos
foreach reg in DD {
foreach out of local outcomes {
	foreach samp of local samples {
		foreach state of local treatstates {
			foreach date of local treatdates {
				foreach covars in sparse covid {
				
					display "Iteration `nmat' of `iter': Sample: `samp'. Outcome: `out'. Treatment State: `state'. Treatment Date: `date'. Controls: `covars'. Regression: DD."
					did_placebo, outcome(`out') sample(`samp') treatstate(`state') treatdate(`date') controls(`covars') regtype(`reg') matc(`nmat')
					
					}
				}
			}
		}
	}
}
*/
* Check variables are dropped
cap drop treat post weight sample

*** Loop through DDD placebos
foreach reg in DDD {
foreach out of local outcomes {
	foreach samp of local samples {
		foreach state of local treatstates {
			foreach date of local treatdates {
				foreach covars in sparse {
					
					display "Iteration `nmat' of `iter': Sample: `samp'. Outcome: `out'. Treatment State: `state'. Treatment Date: `date'.  Regression: DDD."
					ddd_placebo, outcome(`out') sample(`samp') treatstate(`state') treatdate(`date') controls(`covars') regtype(`reg') matc(`nmat')
					
					}
				}
			}
		}
	}
}

*** Save matrix

svmat est

drop if est1 ==.

drop year-weight est10

*** Save as .dta file
rename est1 treatstate
rename est2 treatdate
rename est3 beta
rename est4 se
rename est5 pval
rename est6 ci_lower
rename est7 ci_upper
rename est8 placebo
rename est9 iteration

gen lab = ""
gen sample = ""
gen outcome = ""
gen controls = ""
gen regression = ""


*
forvalues n = 1(1)`iter' {
	di "iteration = `n'"
	
	replace lab = "`matid`n'lab'" if iteration == `n'
	replace outcome = "`matid`n'outcome'" if iteration == `n'
	replace sample = "`matid`n'sample'" if iteration == `n'
	replace controls = "`matid`n'controls'" if iteration == `n'
	replace regression = "`matid`n'regtype'" if iteration == `n'
	

}

* Save data
save "$wrkdir/DD-and-DDD-placebos-individual.dta" , replace

