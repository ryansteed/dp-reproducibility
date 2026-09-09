
*** This do file produces the following results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

* Table 3: Effects of Early Expiration of FPUC and PUA or Just FPUC on the State Employment Population Ratio and Unemployment Rate

*** Last updated 8/14/2023

set more off
capture log close
clear all


* Load aggregate data
use "$wrkdir/aggregate-analysis.dta", clear

* Generate post variable after June and before September
cap drop post
gen post =.
replace post = 0 if inrange(month,2,6)
replace post = 1 if inrange(month,7,8)

*** Generate indicators for triple difference regressions
gen baseyear2019 =.
replace baseyear2019 = 0 if year == 2019
replace baseyear2019 = 1 if year == 2021

est clear

local agelist 2554 1664 16plus

*** Table 3 Panel A: CPS EPOP END BOTH PUA AND PUA OR ONLY FPUC SEPARATELY
foreach age of local agelist {

	eststo:reghdfe epop_cps_`age' i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_`age'] if inrange(date,733,739), absorb(i.statefip i.month) cluster(statefip)
	eststo:reghdfe epop_cps_`age' i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases [aw=statepop_`age'] if inrange(date,733,739), absorb(i.statefip i.month) cluster(statefip)
	eststo: reghdfe epop_cps_`age' i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=statepop_`age'], absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip) cluster(statefip)

}
estout using "../../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
esttab using "$tabdir/table-3-panel-A.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.post 1.endonlyfpuc#1.post 1.endfpucandpua#1.baseyear2019#1.post 1.endonlyfpuc#1.baseyear2019#1.post) 

est clear

*** Table 3 Panel B: CPS UR END BOTH PUA AND PUA OR ONLY FPUC SEPARATELY
foreach age of local agelist {

	eststo:reghdfe ur_cps_`age' i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_`age'] if inrange(date,733,739), absorb(i.statefip i.month) cluster(statefip)
	eststo:reghdfe ur_cps_`age' i.endfpucandpua##i.post i.endonlyfpuc##i.post stringencyindex lnnewcases [aw=statepop_`age'] if inrange(date,733,739), absorb(i.statefip i.month) cluster(statefip)
	eststo:reghdfe ur_cps_`age' i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=statepop_`age'], absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip) cluster(statefip)

}
estout using "../../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
esttab using "$tabdir/table-3-panel-B.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.post 1.endonlyfpuc#1.post 1.endfpucandpua#1.baseyear2019#1.post 1.endonlyfpuc#1.baseyear2019#1.post) 

est clear

