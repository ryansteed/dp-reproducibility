
*** This do file produces the following results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 
					
* Table 2: Effects of Early Expiration of FPUC and PUA or Just FPUC on the Probability of Unemployment to Employment Transitions

* Last updated: 8/16/2023

clear all 
capture log close 
set more off

* Load data
use "$wrkdir/individual-analysis.dta", replace

* Generate post variable after June
cap drop post
gen post =.
replace post = 0 if inrange(month,2,6)
replace post = 1 if inrange(month,7,8)


est clear


****** TRIPLE DIFF INDICATORS 2019 and 2021

gen baseyear2019 =.
replace baseyear2019 = 0 if year == 2019
replace baseyear2019 = 1 if year == 2021

*** Table 2: Effects of Ending FPUC and PUA Early on Robust U-E transitions

eststo: reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,25,54), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant

eststo: reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,64), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant

eststo: reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,90), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant


esttab using "$tabdir/table-2.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.post 1.endonlyfpuc#1.post 1.endfpucandpua#1.baseyear2019#1.post 1.endonlyfpuc#1.baseyear2019#1.post) 

est clear