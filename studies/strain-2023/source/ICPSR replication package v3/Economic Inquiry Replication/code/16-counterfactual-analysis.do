
*** This do file generates inputs for Table A1 for the paper
*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

* Table A1: Counterfactual Analysis: Estimated Effect on States Neither Program, Ending Only FPUC Before September and National Effects Using All Transitions and DD or DDD Regression Coefficients Applied to the Pre period Average from February-June 2021


*** Outputs:

* counterfactual-pre-post-25-54.csv: Pre and post period employment, labor force, unemployment, and population ages 25-54 for each state group.

* counterfactual-pre-post-16-64.csv: Pre and post period employment, labor force, unemployment, and population ages 16-64 for each state group. 

* counterfactual-pre-post-16plus.csv: Pre and post period employment, labor force, unemployment, and population ages 16 and over for each state group.

* DD-counterfactual-coefs-25-54.csv: Coefficients from DD transition regressions estimated using individuals ages 25-54.

* DD-counterfactual-coefs-16-64.csv: Coefficients from DD transition regressions estimated using individuals ages 16-64.

* DD-counterfactual-coefs-16-plus.csv: Coefficients from DD transition regressions estimated using individuals ages 16 and over.

* DDD-counterfactual-coefs-25-54.csv: Coefficients from DDD transition regressions estimated using individuals ages 25-54.

* DDD-counterfactual-coefs-16-64.csv: Coefficients from DD transition regressions estimated using individuals ages 16-64.

* DDD-counterfactual-coefs-16-plus.csv: Coefficients from DD transition regressions estimated using individuals ages 16 and over.

set more off
capture log close
clear all

* Load aggregate data
use "$wrkdir/aggregate-analysis.dta", clear

gen post =.
replace post = 0 if inrange(month,2,6)
replace post = 1 if inrange(month,7,8)

* Generate variable for state groups
gen stategroup = 0
replace stategroup = 1 if endallstate == 1
replace stategroup = 2 if endallstate == 0
replace stategroup = 3 if endonlyfpuc == 1
replace stategroup = 4 if missing(endallstate) & missing(endonlyfpuc)

tab stategroup, missing

keep if year == 2021

bysort stategroup month: egen totalemp_2554 = sum(totemp_2554)
bysort stategroup month: egen totallabforce_2554 = sum(totlabforce_2554)
bysort stategroup month: egen totalunemp_2554 = sum(totunemp_2554)
bysort stategroup month: egen totalpop_2554 = sum(statepop_2554)

bysort stategroup month: egen totalemp_1664 = sum(totemp_1664)
bysort stategroup month: egen totallabforce_1664 = sum(totlabforce_1664)
bysort stategroup month: egen totalunemp_1664 = sum(totunemp_1664)
bysort stategroup month: egen totalpop_1664 = sum(statepop_1664)

bysort stategroup month: egen totalemp_16plus = sum(totemp_16plus)
bysort stategroup month: egen totallabforce_16plus = sum(totlabforce_16plus)
bysort stategroup month: egen totalunemp_16plus = sum(totunemp_16plus)
bysort stategroup month: egen totalpop_16plus = sum(statepop_16plus)

gen epop_2554 = totemp_2554/statepop_2554 * 100
gen epop_1664 = totemp_1664/statepop_1664 * 100
gen epop_16plus = totemp_16plus/statepop_16plus * 100

gen ur_2554 = totunemp_2554/totlabforce_2554 * 100
gen ur_1664 = totunemp_1664/totlabforce_1664 * 100
gen ur_16plus = totunemp_16plus/totlabforce_16plus * 100

* Convert to millions
foreach var of varlist totalemp_2554-totalpop_16plus {
	replace `var' = `var'/1000000
}

* Label variables
label var totalemp_2554 "Total Employment Ages 25-54 (millions)"
label var totallabforce_2554 "Total Labor Force Ages 25-54 (millions)"
label var totalunemp_2554 "Total Unemployed Ages 25-54 (millions)"
label var totalpop_2554 "Total Population Ages 25-54 (millions)"

label var totalemp_1664 "Total Employment Ages 16-64 (millions)"
label var totallabforce_1664 "Total Labor Force Ages 16-64 (millions)"
label var totalunemp_1664 "Total Unemployed Ages 16-64 (millions)"
label var totalpop_1664 "Total Population Ages 16-64 (millions)"

label var totalemp_16plus "Total Employment Ages 16 and Over (millions)"
label var totallabforce_16plus "Total Labor Force Ages 16 and Over (millions)"
label var totalunemp_16plus "Total Unemployed Ages 16 and Over (millions)"
label var totalpop_16plus "Total Population Ages 16 and Over (millions)"

est clear

*** Pre and post period aggregates for counterfactual analysis for each state group

* Ages 25-54
bysort stategroup post: eststo: estpost tabstat totalpop_2554 totallabforce_2554 totalemp_2554 totalunemp_2554 [aw=statepop_2554], ///
	columns(statistics) statistics(mean)

esttab using "$tabdir/counterfactual-pre-post-25-54.csv", replace cells(mean(fmt(4))) label nolegend nonotes compress nogap not nostar unstack nonumber nonote noobs ///
mtitles("Ended Both FPUC and PUA in June Pre Period" "Ended Both FPUC and PUA in June Post Period" /// 
		"Ended Neither FPUC nor PUA Before September Pre Period" "Ended Neither FPUC nor PUA Before September Post Period" ///
		"Ended Only FPUC in June Pre Period" "Ended Only FPUC in June Post Period" ///
		"Other States Pre Period" "Other States Post Period")

est clear

* Ages 16-64
bysort stategroup post: eststo: estpost tabstat totalpop_1664 totallabforce_1664  totalemp_1664 totalunemp_1664 [aw=statepop_1664], ///
	columns(statistics) statistics(mean)

esttab using "$tabdir/counterfactual-pre-post-16-64.csv", replace cells(mean(fmt(4))) label nolegend nonotes compress nogap not nostar unstack nonumber nonote noobs ///
mtitles("Ended Both FPUC and PUA in June Pre Period" "Ended Both FPUC and PUA in June Post Period" /// 
		"Ended Neither FPUC nor PUA Before September Pre Period" "Ended Neither FPUC nor PUA Before September Post Period" ///
		"Ended Only FPUC in June Pre Period" "Ended Only FPUC in June Post Period" ///
		"Other States Pre Period" "Other States Post Period")
		
est clear

* Ages 16 and Over
bysort stategroup post: eststo: estpost tabstat totalpop_16plus totallabforce_16plus totalemp_16plus totalunemp_16plus [aw=statepop_16plus], ///
	columns(statistics) statistics(mean)

esttab using "$tabdir/counterfactual-pre-post-16plus.csv", replace cells(mean(fmt(4))) label nolegend nonotes compress nogap not nostar unstack nonumber nonote noobs ///
mtitles("Ended Both FPUC and PUA in June Pre Period" "Ended Both FPUC and PUA in June Post Period" /// 
		"Ended Neither FPUC nor PUA Before September Pre Period" "Ended Neither FPUC nor PUA Before September Post Period" ///
		"Ended Only FPUC in June Pre Period" "Ended Only FPUC in June Post Period" ///
		"Other States Pre Period" "Other States Post Period")

		
est clear


* Load individual data for transition regressions
use "$wrkdir/individual-analysis.dta", clear

gen post =.
replace post = 0 if inrange(month,2,6)
replace post = 1 if inrange(month,7,8)

**** DD Coefficients All Transitions. Include Covid Controls

* Compare all transitions 25-54: DD End Both FPUC and PUA or Just FPUC in June 2021
eststo: reghdfe UEtoE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoUE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoNE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoNE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoUE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,25,54) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant

esttab using "$tabdir/DD-counterfactual-coefs-25-54.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.post 1.endonlyfpuc#1.post stringencyindex lnnewcases) noomitted

est clear

* Compare all transitions 16-64: DD End Both FPUC and PUA or Just FPUC in June 2021
eststo: reghdfe UEtoE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoUE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoNE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoNE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoUE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,64) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant

esttab using "$tabdir/DD-counterfactual-coefs-16-64.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.post 1.endonlyfpuc#1.post stringencyindex lnnewcases) noomitted

est clear

* Compare all transitions: 16 and over DD End Both FPUC and PUA or Just FPUC in June 2021
eststo: reghdfe UEtoE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoUE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoNE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoNE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoUE_2m i.endfpucandpua##b0.post i.endonlyfpuc##b0.post stringencyindex lnnewcases [aw=panlwt] if inrange(age,16,90) & inrange(date,733,739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant

esttab using "$tabdir/DD-counterfactual-coefs-16plus.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.post 1.endonlyfpuc#1.post stringencyindex lnnewcases) noomitted

est clear


**** DDD Coefficients
cap drop baseyear2019
gen baseyear2019 =.

replace baseyear2019 = 0 if year == 2019 
replace baseyear2019 = 1 if year == 2021

* Compare all transitions 25-54: DDD End Both FPUC and PUA or Just FPUC in June 2021
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,25,54), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,25,54), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoUE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,25,54), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoNE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,25,54), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoNE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,25,54), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoUE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,25,54), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant

esttab using "$tabdir/DDD-counterfactual-coefs-25-54.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.baseyear2019#1.post 1.endonlyfpuc#1.baseyear2019#1.post)

est clear

* Compare all transitions 16-64: DD End Both FPUC and PUA or Just FPUC in June 2021
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,64), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,64), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoUE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,64), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoNE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,64), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoNE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,64), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoUE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,64), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant

esttab using "$tabdir/DDD-counterfactual-coefs-16-64.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.baseyear2019#1.post 1.endonlyfpuc#1.baseyear2019#1.post)


est clear

* Compare all transitions: 16 and over DDD End Both FPUC and PUA or Just FPUC in June 2021
eststo: reghdfe UEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,90), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,90), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoUE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,90), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe EtoNE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,90), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe UEtoNE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,90), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant
eststo: reghdfe NEtoUE_2m i.endfpucandpua##i.baseyear2019##i.post i.endonlyfpuc##i.baseyear2019##i.post [aw=panlwt] if inrange(age,16,90), absorb(i.statefip##i.month i.baseyear2019##i.month i.baseyear2019##i.statefip i.date i.age i.educ) cluster(statefip) noconstant

esttab using "$tabdir/DDD-counterfactual-coefs-16plus.csv", replace b(3) se(3) ar(3) star(* 0.10 ** 0.05 *** 0.01) compress nogap label indicate(`r(indicate_fe)') ///
keep(1.endfpucandpua#1.baseyear2019#1.post 1.endonlyfpuc#1.baseyear2019#1.post)

est clear
