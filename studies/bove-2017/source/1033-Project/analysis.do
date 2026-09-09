
 
/* ************************************************************ */
/* File Name: analysis.do */
/* Date: September, 2016 */
/* Article Title:  Police Officer on the Frontline or a Soldier? The Effect of Police Militarization  on Crime */
/* Authors: Vincenzo Bove & Evelina Gavrilova*/
/* *************************************************************/

* cd ""
use militarization.dta, clear
*** Edited by Ryan
xtset fips year
***

********************

** Instrument

********************
gen ind=.
replace ind=1 if weapons_quant!=0|vehicles_q!=0|gears_q!=0|other_q!=0
replace ind=. if year<2006
bys fips: egen  Aid1=count(ind)
sort fips year

gen burden_iv= Aid1/7*L2.burden
gen milex_iv= Aid1/7*log(L2.milex)
gen casualties_iv= Aid1/7*log(L2.casualties)

lab var milex_iv "Military Exp. IV"
lab var burden_iv "Burden IV"
lab var casualties_iv "Casualties IV"


********************

* Keep only the main estimation sample

********************
qui xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate lpop share*  statetimefe_* (ltotal_cost = milex_iv), fe
keep if e(sample)

********************

* Summary Statistics. Table 1

********************
sutex   crime murder robbery assault burglary larceny mvtheft amurder arobbery aassault aburglary alarceny amvtheft milex_iv ///
total_raw tot_q weapons_c weapons_q vehicles_c vehicles_q gears_c ///
gears_q other_c other_q PovertyPercentAllAges MedianHouseholdIncome Unempl_Rate ///
pop sharemale sharebl shareage1519 shareage2024 shareage2529 shareage3034, ///
  digits(1) minmax lab file(Table1) replace



/*
********************

* Figures

********************
preserve
collapse (mean) crime total_raw_cap, by(fips)
set scheme s1mono

graph twoway (scatter total crime, msymbol(circle_hollow)) if crime<10000&total<20, ytitle(Total Aid per Capita) xtitle("Crime Rate")
graph export "Figure_1.png",replace
restore


preserve

 replace Aid1=7 if Aid1==6|Aid1==5|Aid1==4|Aid1==3
 replace Aid1=1 if Aid1==2
collapse (mean) ltotal_cost crime, by (year Aid1 milex)
reshape wide crime ltotal_cost, i(year milex) j(Aid1)
replace milex=milex/1000

twoway (line crime7 year,  lwidth(thick)) (line crime1 year, lwidth(thick) lpattern(dash))  (connected milex year, yaxis(2) lcolor(gs10)) , /*
*/legend(label(2 Low Recipients) label(1 High Recipients) label(3 US Military Spending)) scheme(s1mono) ytitle(Crime) ylabel(600(100)800, axis(2)) ylabel(2000(2000)4000) xtitle(Year) ytitle("Billion USD",axis(2))
graph export "Figure_2a.png",replace

twoway (line ltotal_cost7 year,  lwidth(thick)) (line ltotal_cost1 year, lwidth(thick) lpattern(dash))  (connected milex year, yaxis(2) lcolor(gs10)) , /*
*/legend(label(2 Low Recipients) label(1 High Recipients) label(3 US Military Spending)) scheme(s1mono) ytitle(Total Aid) ylabel(600(100)800, axis(2))  xtitle(Year) ytitle("Billion USD",axis(2))
graph export "Figure_2b.png",replace
restore


preserve
xtreg ltotal_cost milex_iv PovertyPercentAllAges lMedian Unempl_Rate lpop share* statetimefe_*, fe cl(State)
predict iv_predict
set scheme s1mono 
 
binscatter crime iv_predict, controls(PovertyPercentAllAges lMedian Unempl_Rate lpop share* statetimefe_*) absorb(fips) ytitle("Crime Rate") xtitle(Predicted Total Aid) 
graph export Figure3b.png, replace

binscatter ltotal_cost milex_iv, controls(PovertyPercentAllAges lMedian Unempl_Rate lpop share* statetimefe_*) absorb(fips) ytitle(Total Aid) xtitle(Military Expenditure IV)
graph export Figure_3a.png, replace

binscatter ltotal_cost milex_iv, controls(PovertyPercentAllAges lMedian Unempl_Rate lpop share* statetimefe_*) absorb(fips) by(Aid1) ytitle(Total Aid) xtitle(Military Expenditure IV) /*
*/ legend(label(1 No Aid) lab(2 Aid in 1 year) lab(3 2 years) lab(4 3 years) lab(5 4 years) lab(6 5 years) lab(7 6 years) lab(8 7 years))
graph export Figure_A2.png, replace
restore
 


preserve
drop if year < 2006
collapse (sum) total_raw, by(year milex)
replace total_=total_/1000000
replace milex=milex/1000
format %12.0g total_r
set scheme s1mono
tsset year
twoway (tsline total_, recast(dropline) lcolor(black)) , ytitle(Total Aid (in mln)) xtitle("")
graph export "Figure_A1.png",replace
restore

*/

 
*******************************************

** Table 2

*******************************************
eststo clear
mat B=J(1,9,.)
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg crime `controls' statetimefe_* ltotal_cost, fe  cl(State) 

local i=2
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
local i=`i'+1
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument'), fe  cl(State) 
qui sum `depvar'
mat B[1,`i']=_b[ltotal_cost]/r(mean)
}
}
}
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
* esttab  using "Table2.tex", order(milex_iv ltotal_cost) drop (`controls' statetimefe_* ) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 
mat rownames B="Elasticities"

* esttab matrix(B, fmt(2)) using elast.tex, replace frag nomtitles noline nonumbers

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

***************************************************
** Table 3
** Effect of military aid on arrest rates
***************************************************
 

eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"


foreach depvar of varlist murder robbery assault burglary larceny mvtheft {
eststo: xtivreg2 a`depvar' `controls' statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 

}


esttab  using "Table3.tex", keep(*ltotal_cost) se nocon  scalars("rkf Kleibergen-Paap F-Statistic") ///
nonumbers  mtitles("Homicide" "Robbery" "Assault" "Burglary" "Larceny" "Vehicle Theft") label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 


eststo clear


***************************************************
** Table 4
** Effect of military aid on police activities
***************************************************
preserve
use police.dta, clear


local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
foreach depvar of varlist officerx1000 tot_empl off_to_empl total_calls injuries civil_disorder_asslts offenders_killed{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (ltotal_cost= milex_iv), fe  cl(State) 
}
restore

eststo: xtivreg2 logcom `controls' statetimefe_* (ltotal_cost= milex_iv), fe  cl(State) 
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "Table4.tex", keep(ltotal_cost) se nocon scalars("rkf KP F-Statistic")  ///
nonumbers nomtitles nolines label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 

eststo clear


/*

*********************************************************************************

* Appendix

*********************************************************************************


**************************

** Table 1 Appendix. Categories

**************************
preserve
use categories.dta, clear
log using TableA1, t
bysort category: tabulate federal_supply_category_name, summarize(total_cost)  nostandard 
log close
restore


**************************

** Table 2 Appendix. Controls one by one

**************************
tab year, g(yr_)
eststo clear
xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate lpop sharemale shareblack shareage1519 shareage2024 shareage2529 shareage3034 statetimefe_* (ltotal_cost = milex_iv), fe 
keep if e(sample)
eststo: xtivreg2 crime yr_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges  statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges lMedian statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate lpop statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate lpop sharemale statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate lpop sharemale shareblack statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate lpop sharemale shareblack shareage1519 shareage2024 statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 
eststo: xtivreg2 crime PovertyPercentAllAges lMedian Unempl_Rate lpop sharemale shareblack shareage1519 shareage2024 shareage2529 shareage3034 statetimefe_* (ltotal_cost = milex_iv), fe  cl(State) 

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA2.tex", order(ltotal_cost) drop ( statetimefe_* yr_*) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 
drop yr_*


***************************************************

** Table 3 Appendix. OLS estimates of the effect of military aid on crime

***************************************************


eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtreg `depvar' `controls' statetimefe_* `var', fe  cl(State) 
}
}

*local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
*eststo: xtivreg2 crime `controls' statetimefe_* (ltotal_cost =lzHUdI1 lzHUdI6 lzHUdIl lzHUdIh), fe  cl(State) 

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA3.tex", order(ltotal_cost) drop (`controls' statetimefe_* ) se nocon  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 


*******************************************
** Table 4 Appendix
** Effect of military aid by type: Total crime
** Several Panels

*******************************************
 
eststo clear


local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*  "
foreach depvar of varlist  crime robbery assault larceny mvtheft{
foreach var of varlist ltotal_cost {
eststo: xtivreg2 `depvar'  statetimefe_* `controls' (`var' = milex_iv), fe  cl(State) 
}
}

esttab  using "TableA4Panel1.tex", order(ltotal_cost) drop ( `controls' statetimefe_*) se nocon  scalars("rkf Kleibergen-Paap F-Statistic") ///
nonumbers nomtitles label nodep nolines nogaps noobs frag b(%10.3f) replace 

foreach varel of varlist  lweapons lvehicles lgears{

eststo clear
foreach depvar of varlist  crime robbery assault larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`varel' = milex_iv), fe  cl(State) 
}
esttab  using "TableA4`varel'.tex", order(`varel') drop ( `controls' statetimefe_*) se nocon nolines b(%10.3f) scalars("rkf Kleibergen-Paap F-Statistic") ///
nonumbers mtitles("  " "  " "  " " " "  ") label nodep nogaps noobs frag replace 
}

eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*  "
foreach depvar of varlist  crime robbery assault larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (lother_cost = milex_iv), fe  cl(State) 
}
esttab  using "TableA4lother_cost.tex", order(lother_cost) drop ( `controls' statetimefe_*) se nocon nolines b(%10.3f) scalars("rkf Kleibergen-Paap F-Statistic") ///
nonumbers mtitles("  " "  " "  " " " "  ") label nodep nogaps  frag replace 


eststo clear



*******************************************
** Test of Effect of military aid by type: Total crime
** Several Panels
*******************************************
 
local i=0
mat B=J(1,5,.)
foreach varel of varlist  lweapons  lvehicles lgears lother{
local i=`i'+1
qui xtivreg2 crime `controls' statetimefe_* (`varel' = milex_iv), fe  cl(State) 
test `varel'=-59.293
mat B[1,1]=`r(p)'
qui xtivreg2 robbery `controls' statetimefe_* (`varel' = milex_iv), fe  cl(State) 
test `varel'=-6.102
mat B[1,2]=`r(p)'
qui xtivreg2 assault `controls' statetimefe_* (`varel' = milex_iv), fe  cl(State) 
test `varel'=-5.305
mat B[1,3]=`r(p)'
qui xtivreg2 larceny `controls' statetimefe_* (`varel' = milex_iv), fe  cl(State) 
test `varel'=-27.429
mat B[1,4]=`r(p)'
qui xtivreg2 mvtheft `controls' statetimefe_* (`varel' = milex_iv), fe  cl(State) 
test `varel'=-11.644
mat B[1,5]=`r(p)'
mat rownames B="P-value"
mat colnames B="" "" "" "" ""
esttab matrix(B, fmt(2)) using tests`varel'.tex, replace frag nomtitles noline
}






***************************************************

** Table 5 Appendix. Robustness Checks
** Panel by panel

***************************************************
**************************
*Table A5 Panel 1* Population
**************************
eststo clear

bys fips: egen popmean=mean(pop)
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
*eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv if popmean<250000, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument') if popmean<250000, fe  cl(State) 

}
}
}

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA5_pop.tex", order(ltotal_cost) drop ( `controls' statetimefe_* ) se nocon scalars("rkf KP F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps noline ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 
eststo clear



**************************
*Table A5 Panel 2* Unempl Rate
**************************
bys fips: egen meanunempl=mean(Unempl_Rate)

eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
*eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv if meanunempl>=7, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument') if meanunempl>=7, fe  cl(State) 
}
}
}
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA5_unempl.tex", order(ltotal_cost) drop (`controls' statetimefe_* ) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 
eststo clear
drop meanun


**************************
*Table A5 Panel 3* Poverty
**************************
bys fips: egen meanpov=mean(PovertyPercent)

eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
*eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv if meanpov>=16, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument') if meanpov>=15, fe  cl(State) 
}
}
}
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA5_poverty.tex", order(ltotal_cost) drop (`controls' statetimefe_* ) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 
eststo clear
drop meanpov



**************************
*Table A5 Panel 4* Income
**************************
bys fips: egen meanmedian=mean(Median)

eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
*eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv if meanmedian>=40000, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument') if meanmedian>=40000, fe  cl(State) 
}
}
}
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA5_income.tex", order(ltotal_cost) drop (`controls' statetimefe_* ) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 
eststo clear
drop meanmedian


**************************
*Table A5 Panel 5* Share of blacks
**************************
bys fips: egen meanbl=mean(shareblack)

eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
*eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv if meanbl>=0.06, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument') if meanbl>=0.05, fe  cl(State) 
}
}
}
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA5_black.tex", order(ltotal_cost) drop (`controls' statetimefe_* ) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 
eststo clear
drop meanbl



***************************************************

** Table 6 Appendix. Robustness
* Several Panels
***************************************************


**************************
*Table A6 Panel 1* Quantities
**************************
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltot_q `controls' statetimefe_* milex_iv, fe  cl(State) 
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
foreach  instrument of varlist milex_iv {
foreach var of varlist ltot_q {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument'), fe  cl(State) 

}
}
}

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA6_1.tex", order(milex_iv ltot_q) drop ( `controls' statetimefe_* ) se nocon scalars("rkf KP F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps noline  ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 





**************************
*Table A6 Panel 2 & 3* Another IV
**************************
foreach  instrument of varlist burden_iv  casualties_iv{
eststo clear
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltotal_cost `controls' statetimefe_* `instrument', fe  cl(State) 
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"

foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument'), fe  cl(State) 

}

}

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA6_`instrument'.tex", order(`instrument' ltotal_cost) drop ( `controls' statetimefe_* ) se nocon scalars("rkf KP F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps noline ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 
eststo clear
}



***************************************************

** Table 7 Appendix. Robustness
* Several Panels
***************************************************


**************************
*Table A7 Panel 1* Weighting
**************************
eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv  [aweight=popmean], fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
foreach var of varlist ltotal_cost {
eststo: xtivreg2 `depvar' `controls' statetimefe_*  (`var' = `instrument') [aweight=popmean] , fe  cl(State) 
}
}
}
esttab  using "TableA7_1.tex", order(milex_iv ltotal_cost ) drop (  `controls' statetimefe_* ) se nocon  scalars("rkf KP F-Statistic") ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) frag noline replace 

eststo clear


**************************
*Table A7 Panel 2* Total Aid per capita
**************************
eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost_cap {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument'), fe  cl(State) 
}
}
}
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA7_2.tex", order(milex_iv) drop (`controls' statetimefe_* ) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes noline frag  replace 
eststo clear

 



**************************
*Table A7 Panel 3* Coverage indicator = 100
**************************
preserve
gen indic=rcovind==100&acovind==100

eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
xtivreg2 crime `controls' statetimefe_* (ltotal_cost = milex_iv) if indic==1, fe 
keep if e(sample)
gen counter=1
bys fips: egen flip=count(counter)
drop if flip==1


local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltotal_cost `controls' statetimefe_* milex_iv if indic==1, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument') if indic==1, fe  cl(State) 

}
}
}

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA7_3.tex", order(milex_iv ltotal_cost) drop ( `controls' statetimefe_* ) se nocon scalars("rkf KP F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps noline ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 

eststo clear
restore


***************************************************

** Table 8 Appendix. Robustness Specifications
* Several Panels
***************************************************


**************************
*Table A8 Panel 1* Year and State fixed effects
**************************
tab year, g(yr_)
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltotal_cost `controls' milex_iv yr_* , fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' yr_* (`var' = `instrument'), fe  cl(State) 

}
}
}

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA8_1.tex", order(milex_iv ltotal_cost) drop ( yr_* `controls' ) se nocon scalars("rkf KP F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps noline ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 
eststo clear
drop yr_*

**************************
*Table A8 Panel 2* Including County Linear Trends
**************************
gen time=year-2006
quietly tab fips, gen(lineartrend) 
capt quietly for num 1/2921: replace lineartrendX = lineartrendX*time 

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
eststo: xtreg ltotal_cost `controls' lineartrend* milex_iv, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' lineartrend* (`var' = `instrument'), fe  cl(State) 

}
}
}

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA8_2.tex", order(milex_iv ltotal_cost) drop ( `controls' lineartrend* ) se nocon scalars("rkf KP F-Statistic")  ///
nonumbers  nomtitles label nodep nogaps noline ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag replace 
eststo clear


**************************
*Table A8 Panel 3* Dropping 0s and 1s
**************************
preserve
drop if Aid1==0
drop if Aid1==7
eststo clear

local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"

eststo: xtivreg2 ltotal_cost `controls' statetimefe_* milex_iv, fe  cl(State) 
foreach  instrument of varlist milex_iv{
foreach var of varlist ltotal_cost {
foreach depvar of varlist crime murder robbery assault burglary larceny mvtheft{
eststo: xtivreg2 `depvar' `controls' statetimefe_* (`var' = `instrument'), fe  cl(State) 
}
}
}
local controls= "PovertyPercentAllAges lMedian Unempl_Rate lpop share*"
esttab  using "TableA8_3.tex", order(milex_iv ltotal_cost) drop (`controls' statetimefe_* ) se nocon scalars("rkf Kleibergen-Paap F-Statistic")  ///
nonumbers nomtitles label nodep nogaps noline ///
star(* 0.10 ** 0.05 *** 0.01) b(%10.3f) nonotes frag  replace 
eststo clear

restore

*/