
*** This do file produces the following results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

* Table 4: Effects of Early Expiration of FPUC and PUA or Just FPUC on the Share of HPS Respondents Who Report No Difficulty Paying Expenses in the Past Seven Days

* Last updated: 8/16/2023

set more off
capture log close
clear all

* Load clean HPS data
use  "$wrkdir/hps-analysis.dta", clear

cap drop post
gen post =.
replace post = 0 if inrange(month,2,6)
replace post = 1 if inrange(month,7,8)


* Table 4:Table 4: Effects of Early Expiration of FPUC and PUA or Just FPUC on the Share of HPS Respondents Who Report No Difficulty Paying Expenses in the Past Seven Days
eststo: reghdfe share_expens_not_diff_2554 i.endfpucandpua##i.post i.endonlyfpuc##i.post if inrange(date,733,739), absorb(i.statefip i.date) cluster(statefip) noconstant
eststo: reghdfe share_expens_not_diff_2554 i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases if inrange(date,733,739), absorb(i.statefip i.date) cluster(statefip) noconstant

eststo: reghdfe share_expens_not_diff_1864 i.endfpucandpua##i.post i.endonlyfpuc##i.post if inrange(date,733,739), absorb(i.statefip i.date) cluster(statefip) noconstant
eststo: reghdfe share_expens_not_diff_1864 i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases if inrange(date,733,739), absorb(i.statefip i.date) cluster(statefip) noconstant

eststo: reghdfe share_expens_not_diff_18plus i.endfpucandpua##i.post i.endonlyfpuc##i.post if inrange(date,733,739), absorb(i.statefip i.date) cluster(statefip) noconstant
eststo: reghdfe share_expens_not_diff_18plus i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases if inrange(date,733,739), absorb(i.statefip i.date) cluster(statefip) noconstant

estfe *, labels(statefip "State FE" date "Month FE")

esttab using "$tabdir/table-4-hps.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.post 1.endonlyfpuc#1.post)

est clear