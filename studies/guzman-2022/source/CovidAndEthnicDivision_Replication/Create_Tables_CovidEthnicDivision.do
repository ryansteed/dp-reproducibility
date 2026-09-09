
/*
* PURPOSE: Identity during a Crisis: COVID-19 and Ethnic Divisions in the United States - Replication Tables
* Data Source: Master_data_covid_EHI.dta
* AUTHORs: Jakina Debnam Guzman, Marie Christelle Mabeu, and Roland Pongou
DATE: 2022 January, 12
*/

*---------------------------------------------------------------------------*
*				 			SET YOUR DIRECTORY 	
*--------------------------------------------------------------------------*	
global CovidAndEthnic "."
	  	
clear all 
set maxvar 32767
set matsize 10000
*---------------------------------------------------------------------------*
*				 			TABLE 1, TABLE A4, TABLE A5, TABLE A6
*--------------------------------------------------------------------------*

cd "${CovidAndEthnic}/"
use Master_data_covid_EHI.dta, clear

*** Edited by Ryan
* Pandas does not allow naming variables with reserved words
capture rename var_case case
***

rename national_lockdown P1
rename county_lockdown P2
rename stringencyindex P3
rename safer_home P4
rename business_close P5

rename case case1
rename death death1
gen case=case1/pop*100000
gen death=death1/pop*100000

gen area=density_2018/pop

eststo clear
local clear

global controls "area male age poverty educ urban immig share"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"


set more off

foreach index of varlist  EHI {
eststo clear
local clear

foreach y of varlist  case death case1 death1 {

foreach policy of varlist  P1 P2 P4 P5 {

****Columns 1
eststo reg1_`y'_`policy': reg `y'  i.`policy' `index' , cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe 
estadd local dfe
estadd local control  
drop sample 


****Columns 4
eststo reg4_`y'_`policy': reghdfe `y' i.`policy'##c.`index' $controls $controls2, absorb(istate date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe "\checkmark"
estadd local cfe 
estadd local dfe "\checkmark"
estadd local control  "\checkmark"
drop sample 


****Columns 5
eststo reg5_`y'_`policy': reghdfe `y'  i.`policy'##c.`index', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 

}
}
}




foreach index of varlist  EHI {

foreach y of varlist  case death case1 death1 {

foreach policy of varlist  P3 {

****Columns 1
eststo reg1_`y'_`policy': reg `y'  c.`policy' `index' , cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe 
estadd local dfe
estadd local control  
drop sample 


****Columns 4
eststo reg4_`y'_`policy': reghdfe `y' c.`policy'##c.`index' $controls $controls2, absorb(istate date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe "\checkmark"
estadd local cfe 
estadd local dfe "\checkmark"
estadd local control  "\checkmark"
drop sample 


****Columns 5
eststo reg5_`y'_`policy': reghdfe `y'  c.`policy'##c.`index', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 

}
}
}


*******GOVERNMENT POLICIES AND COVID BY LEVEL OF RESIDENTIAL SEGREGATION INDEX**
xtile medianw = seg_index, nq(2)
xtile median_bw = seg_index_bw, nq(2)

global controls "area male age poverty educ urban immig share"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"

set more off

foreach index of varlist  EHI  {

foreach median of varlist  medianw median_bw {

foreach x of numlist  1(1)2 {

foreach y of varlist  case death case1 death1  {

foreach policy of varlist  P1 P2 P4 P5 {

****Columns 1
eststo reg1_`y'_`x'_`median'_`policy': reg `y'  i.`policy' c.`index' if `median'==`x' , cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe 
estadd local dfe
estadd local control  
drop sample 


****Columns 5
eststo reg5_`y'_`x'_`median'_`policy': reghdfe `y'  i.`policy'##c.`index' if `median'==`x', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 

}

}
}
}
}



global controls "area male age poverty educ urban immig share"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"

set more off

foreach index of varlist  EHI  {

foreach median of varlist  medianw median_bw {

foreach x of numlist  1(1)2 {

foreach y of varlist  case death case1 death1  {

foreach policy of varlist  P3 {

****Columns 1
eststo reg1_`y'_`x'_`median'_`policy': reg `y'  c.`policy' c.`index' if `median'==`x' , cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe 
estadd local dfe
estadd local control  
drop sample 


****Columns 5
eststo reg5_`y'_`x'_`median'_`policy': reghdfe `y'  c.`policy'##c.`index' if `median'==`x', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 

}

}
}
}
}

*** Edit by Ryan/Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
exit
***


foreach index of varlist  EHI {

*---------------------------------------------------------------------------*
*				 			TABLE 1
*--------------------------------------------------------------------------*

**Table1: Emergency declarations, ethnic fragmentation, and COVID-19 outcomes
esttab reg1_case_P1 reg4_case_P1 reg5_case_P1 reg1_case_1_medianw_P1 reg5_case_1_medianw_P1 reg1_case_2_medianw_P1 reg5_case_2_medianw_P1 reg1_case1_1_medianw_P1 reg5_case1_1_medianw_P1 reg1_case1_2_medianw_P1 reg5_case1_2_medianw_P1  using Table_1_`index'.tex, keep(1.P1 `index' 1.P1#c.`index' ) replace /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment nonumbers label nobaselevels ///
mtitles("\shortstack{(1)}" "\shortstack{(2)}" "\shortstack{(3)}" "\shortstack{(4)}" "\shortstack{(5)}" "\shortstack{(6)}" "\shortstack{(7)}" "\shortstack{(8)}" "\shortstack{(9)}" "\shortstack{(10)}" "\shortstack{(11)}") ///
mgroups("All" "Low W-NW res. seg." "High W-NW res. seg." "Low W-NW res. seg." "High W-NW res. seg.",pattern(1 0 0 1 0 1 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr) {@span})) ///
nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\midrule \\ ///
\multicolumn{11}{c}{\emph{\textbf{\textcolor{red}{Government policy: National Emergency Declaration}}}} \\ \multicolumn{11}{c}{\emph{\textbf{Panel A: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_P1 reg4_death_P1 reg5_death_P1 reg1_death_1_medianw_P1 reg5_death_1_medianw_P1 reg1_death_2_medianw_P1 reg5_death_2_medianw_P1 reg1_death1_1_medianw_P1 reg5_death1_1_medianw_P1 reg1_death1_2_medianw_P1 reg5_death1_2_medianw_P1  using Table_1_`index'.tex, keep(1.P1 `index' 1.P1#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{Panel B: Covid-19 deaths }}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))


esttab reg1_case_P2 reg4_case_P2 reg5_case_P2 reg1_case_1_medianw_P2 reg5_case_1_medianw_P2 reg1_case_2_medianw_P2 reg5_case_2_medianw_P2 reg1_case1_1_medianw_P2 reg5_case1_1_medianw_P2 reg1_case1_2_medianw_P2 reg5_case1_2_medianw_P2  using Table_1_`index'.tex, keep(1.P2 `index' 1.P2#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{\textcolor{red}{Government policy: County Emergency Declaration}}}} \\ \multicolumn{11}{c}{\emph{\textbf{Panel C: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_P2 reg4_death_P2 reg5_death_P2 reg1_death_1_medianw_P2 reg5_death_1_medianw_P2 reg1_death_2_medianw_P2 reg5_death_2_medianw_P2 reg1_death1_1_medianw_P2 reg5_death1_1_medianw_P2 reg1_death1_2_medianw_P2 reg5_death1_2_medianw_P2  using Table_1_`index'.tex, keep(1.P2 `index' 1.P2#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{Panel D: Covid-19 deaths }}} \\) prefoot(\addlinespace)  ///
stat( N sfe cfe dfe control, fmt( %11.0gc  0 0 0 0) layout( @ @ @ @ @ ) ///
labels("Observations" "\midrule State FE" "County FE" "Day FE" "Controls"  ))

}


*---------------------------------------------------------------------------*
*				 		 TABLE A5
*--------------------------------------------------------------------------*

foreach index of varlist  EHI {
**TableA2: Other policies, ethnic fragmentation, and COVID-19 outcomes
esttab reg1_case_P3 reg4_case_P3 reg5_case_P3 reg1_case_1_medianw_P3 reg5_case_1_medianw_P3 reg1_case_2_medianw_P3 reg5_case_2_medianw_P3 reg1_case1_1_medianw_P3 reg5_case1_1_medianw_P3 reg1_case1_2_medianw_P3 reg5_case1_2_medianw_P3  using Table_A5_`index'.tex, keep(P3 `index' c.P3#c.`index' ) replace ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment nonumbers label nobaselevels ///
mtitles("\shortstack{(1)}" "\shortstack{(2)}" "\shortstack{(3)}" "\shortstack{(4)}" "\shortstack{(5)}" "\shortstack{(6)}" "\shortstack{(7)}" "\shortstack{(8)}" "\shortstack{(9)}" "\shortstack{(10)}" "\shortstack{(11)}") ///
mgroups("All" "Low W-NW res. seg." "High W-NW res. seg." "Low W-NW res. seg." "High W-NW res. seg.",pattern(1 0 0 1 0 1 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr) {@span})) ///
nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\midrule \\ ///
\multicolumn{11}{c}{\emph{\textbf{\textcolor{red}{Government policy: National Stringency Index}}}} \\ \multicolumn{11}{c}{\emph{\textbf{Panel A: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_P3 reg4_death_P3 reg5_death_P3 reg1_death_1_medianw_P3 reg5_death_1_medianw_P3 reg1_death_2_medianw_P3 reg5_death_2_medianw_P3 reg1_death1_1_medianw_P3 reg5_death1_1_medianw_P3 reg1_death1_2_medianw_P3 reg5_death1_2_medianw_P3  using Table_A5_`index'.tex, keep(P3 `index' c.P3#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{Panel B: Covid-19 deaths }}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))


esttab reg1_case_P4 reg4_case_P4 reg5_case_P4 reg1_case_1_medianw_P4 reg5_case_1_medianw_P4 reg1_case_2_medianw_P4 reg5_case_2_medianw_P4 reg1_case1_1_medianw_P4 reg5_case1_1_medianw_P4 reg1_case1_2_medianw_P4 reg5_case1_2_medianw_P4  using Table_A5_`index'.tex, keep(1.P4 `index' 1.P4#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{\textcolor{red}{Government policy: County Safer-at-Home}}}} \\ \multicolumn{11}{c}{\emph{\textbf{Panel C: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_P4 reg4_death_P4 reg5_death_P4 reg1_death_1_medianw_P4 reg5_death_1_medianw_P4 reg1_death_2_medianw_P4 reg5_death_2_medianw_P4 reg1_death1_1_medianw_P4 reg5_death1_1_medianw_P4 reg1_death1_2_medianw_P4 reg5_death1_2_medianw_P4  using Table_A5_`index'.tex, keep(1.P4 `index' 1.P4#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{Panel D: Covid-19 deaths }}} \\) postfoot(\addlinespace)  ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))


esttab reg1_case_P5 reg4_case_P5 reg5_case_P5 reg1_case_1_medianw_P5 reg5_case_1_medianw_P5 reg1_case_2_medianw_P5 reg5_case_2_medianw_P5 reg1_case1_1_medianw_P5 reg5_case1_1_medianw_P5 reg1_case1_2_medianw_P5 reg5_case1_2_medianw_P5  using Table_A5_`index'.tex, keep(1.P5 `index' 1.P5#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{\textcolor{red}{Government policy: County Business Closure}}}} \\ \multicolumn{11}{c}{\emph{\textbf{Panel C: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_P5 reg4_death_P5 reg5_death_P5 reg1_death_1_medianw_P5 reg5_death_1_medianw_P5 reg1_death_2_medianw_P5 reg5_death_2_medianw_P5 reg1_death1_1_medianw_P5 reg5_death1_1_medianw_P5 reg1_death1_2_medianw_P5 reg5_death1_2_medianw_P5  using Table_A5_`index'.tex, keep(1.P5 `index' 1.P5#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{11}{c}{\emph{\textbf{Panel D: Covid-19 deaths }}} \\) prefoot(\addlinespace)  ///
stat( N sfe cfe dfe control, fmt( %11.0gc  0 0 0 0) layout( @ @ @ @ @ ) ///
labels("Observations" "\midrule State FE" "County FE" "Day FE" "Controls"  ))

}


*---------------------------------------------------------------------------*
*				 			TABLE A4
*--------------------------------------------------------------------------*

***Black-White segrgegation index
foreach index of varlist  EHI {

**Table1: Emergency declarations, ethnic fragmentation, and COVID-19 outcomes
esttab reg1_case_1_median_bw_P1 reg5_case_1_median_bw_P1 reg1_case_2_median_bw_P1 reg5_case_2_median_bw_P1 reg1_case1_1_median_bw_P1 reg5_case1_1_median_bw_P1 reg1_case1_2_median_bw_P1 reg5_case1_2_median_bw_P1  using Table_A4_`index'.tex, keep(1.P1 `index' 1.P1#c.`index' ) replace /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment nonumbers label nobaselevels ///
mtitles("\shortstack{(1)}" "\shortstack{(2)}" "\shortstack{(3)}" "\shortstack{(4)}" "\shortstack{(5)}" "\shortstack{(6)}" "\shortstack{(7)}" "\shortstack{(8)}" ) ///
mgroups("Low B-W res. seg." "High B-W res. seg." "Low B-W res. seg." "High B-W res. seg.",pattern(1 0 1 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr) {@span})) ///
nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\midrule \\ ///
\multicolumn{9}{c}{\emph{\textbf{\textcolor{red}{Government policy: National Emergency Declaration}}}} \\ \multicolumn{9}{c}{\emph{\textbf{Panel A: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab  reg1_death_1_median_bw_P1 reg5_death_1_median_bw_P1 reg1_death_2_median_bw_P1 reg5_death_2_median_bw_P1 reg1_death1_1_median_bw_P1 reg5_death1_1_median_bw_P1 reg1_death1_2_median_bw_P1 reg5_death1_2_median_bw_P1  using Table_A4_`index'.tex, keep(1.P1 `index' 1.P1#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{Panel B: Covid-19 deaths }}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))


esttab  reg1_case_1_median_bw_P2 reg5_case_1_median_bw_P2 reg1_case_2_median_bw_P2 reg5_case_2_median_bw_P2 reg1_case1_1_median_bw_P2 reg5_case1_1_median_bw_P2 reg1_case1_2_median_bw_P2 reg5_case1_2_median_bw_P2  using Table_A4_`index'.tex, keep(1.P2 `index' 1.P2#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{\textcolor{red}{Government policy: County Emergency Declaration}}}} \\ \multicolumn{9}{c}{\emph{\textbf{Panel C: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_1_median_bw_P2 reg5_death_1_median_bw_P2 reg1_death_2_median_bw_P2 reg5_death_2_median_bw_P2 reg1_death1_1_median_bw_P2 reg5_death1_1_median_bw_P2 reg1_death1_2_median_bw_P2 reg5_death1_2_median_bw_P2  using Table_A4_`index'.tex, keep(1.P2 `index' 1.P2#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{Panel D: Covid-19 deaths }}} \\) prefoot(\addlinespace)  ///
stat( N sfe cfe dfe control, fmt( %11.0gc  0 0 0 0) layout( @ @ @ @ @ ) ///
labels("Observations" "\midrule State FE" "County FE" "Day FE" "Controls"  ))

}

*---------------------------------------------------------------------------*
*				 		 TABLE A6
*--------------------------------------------------------------------------*

foreach index of varlist  EHI {

**TableA2: Other policies, ethnic fragmentation, and COVID-19 outcomes
esttab  reg1_case_1_median_bw_P3 reg5_case_1_median_bw_P3 reg1_case_2_median_bw_P3 reg5_case_2_median_bw_P3 reg1_case1_1_median_bw_P3 reg5_case1_1_median_bw_P3 reg1_case1_2_median_bw_P3 reg5_case1_2_median_bw_P3  using Table_A6_`index'.tex, keep(P3 `index' c.P3#c.`index' ) replace ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment nonumbers label nobaselevels ///
mtitles("\shortstack{(1)}" "\shortstack{(2)}" "\shortstack{(3)}" "\shortstack{(4)}" "\shortstack{(5)}" "\shortstack{(6)}" "\shortstack{(7)}" "\shortstack{(8)}" ) ///
mgroups("Low B-W res. seg." "High B-W res. seg." "Low B-W res. seg." "High B-W res. seg.",pattern( 1 0 1 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr) {@span})) ///
nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\midrule \\ ///
\multicolumn{9}{c}{\emph{\textbf{\textcolor{red}{Government policy: National Stringency Index}}}} \\ \multicolumn{9}{c}{\emph{\textbf{Panel A: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_1_median_bw_P3 reg5_death_1_median_bw_P3 reg1_death_2_median_bw_P3 reg5_death_2_median_bw_P3 reg1_death1_1_median_bw_P3 reg5_death1_1_median_bw_P3 reg1_death1_2_median_bw_P3 reg5_death1_2_median_bw_P3  using Table_A6_`index'.tex, keep(P3 `index' c.P3#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{Panel B: Covid-19 deaths }}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))


esttab  reg1_case_1_median_bw_P4 reg5_case_1_median_bw_P4 reg1_case_2_median_bw_P4 reg5_case_2_median_bw_P4 reg1_case1_1_median_bw_P4 reg5_case1_1_median_bw_P4 reg1_case1_2_median_bw_P4 reg5_case1_2_median_bw_P4  using Table_A6_`index'.tex, keep(1.P4 `index' 1.P4#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{\textcolor{red}{Government policy: County Safer-at-Home}}}} \\ \multicolumn{9}{c}{\emph{\textbf{Panel C: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_1_median_bw_P4 reg5_death_1_median_bw_P4 reg1_death_2_median_bw_P4 reg5_death_2_median_bw_P4 reg1_death1_1_median_bw_P4 reg5_death1_1_median_bw_P4 reg1_death1_2_median_bw_P4 reg5_death1_2_median_bw_P4  using Table_A6_`index'.tex, keep(1.P4 `index' 1.P4#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{Panel D: Covid-19 deaths }}} \\) postfoot(\addlinespace)  ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))


esttab  reg1_case_1_median_bw_P5 reg5_case_1_median_bw_P5 reg1_case_2_median_bw_P5 reg5_case_2_median_bw_P5 reg1_case1_1_median_bw_P5 reg5_case1_1_median_bw_P5 reg1_case1_2_median_bw_P5 reg5_case1_2_median_bw_P5  using Table_A6_`index'.tex, keep(1.P5 `index' 1.P5#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{\textcolor{red}{Government policy: County Business Closure}}}} \\ \multicolumn{9}{c}{\emph{\textbf{Panel C: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_1_median_bw_P5 reg5_death_1_median_bw_P5 reg1_death_2_median_bw_P5 reg5_death_2_median_bw_P5 reg1_death1_1_median_bw_P5 reg5_death1_1_median_bw_P5 reg1_death1_2_median_bw_P5 reg5_death1_2_median_bw_P5  using Table_A6_`index'.tex, keep(1.P5 `index' 1.P5#c.`index' ) append ///
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{9}{c}{\emph{\textbf{Panel D: Covid-19 deaths }}} \\) prefoot(\addlinespace)  ///
stat( N sfe cfe dfe control, fmt( %11.0gc  0 0 0 0) layout( @ @ @ @ @ ) ///
labels("Observations" "\midrule State FE" "County FE" "Day FE" "Controls"  ))

}





*---------------------------------------------------------------------------*
*				 			TABLE A2
*--------------------------------------------------------------------------*

use Master_data_covid_EHI.dta, clear

rename national_lockdown P1
rename county_lockdown P2

rename case case1
rename death death1
gen case=case1/pop*100000
gen death=death1/pop*100000

gen area=density_2018/pop

eststo clear
local clear

global controls "area male age poverty educ urban immig share"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"


set more off

*******GOVERNMENT POLICIES AND COVID BY LEVEL OF RESIDENTIAL SEGREGATION INDEX**
xtile medianw = seg_index, nq(2)
xtile median_bw = seg_index_bw, nq(2)

global controls "area male age poverty educ urban immig share"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"

set more off
label define seg 1 "Low Res. Segr. index" 2 "High Res. Segr. index" 

foreach median of varlist  medianw median_bw   {
gen seg=`median'
label variable seg "Res. Segr. index"
label values seg seg
foreach y of varlist  case death case1 death1  {

foreach policy of varlist  P1 P2 {

****Columns 1
eststo reg1_`y'_`median'_`policy': reg `y'  i.`policy' i.seg , cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe 
estadd local dfe
estadd local control  
drop sample 


****Columns 4
eststo reg4_`y'_`median'_`policy': reghdfe `y' i.`policy'##i.seg $controls $controls2, absorb(istate date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe "\checkmark"
estadd local cfe 
estadd local dfe "\checkmark"
estadd local control  "\checkmark"
drop sample 


****Columns 5
eststo reg5_`y'_`median'_`policy': reghdfe `y'  i.`policy'##i.seg, absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 

}

}
drop seg
}

*---------------------------------------------------------------------------*
*				 			TABLE A2
*--------------------------------------------------------------------------*

**Table1: Emergency declarations, racial segregation, and COVID-19 outcomes
esttab reg1_case_medianw_P1 reg4_case_medianw_P1 reg5_case_medianw_P1 reg1_case1_medianw_P1 reg4_case1_medianw_P1 reg5_case1_medianw_P1 using Table_A2.tex, keep(1.P1 2.seg 1.P1#2.seg ) replace /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment nonumbers label nobaselevels ///
mtitles("\shortstack{(1)}" "\shortstack{(2)}" "\shortstack{(3)}" "\shortstack{(4)}" "\shortstack{(5)}" "\shortstack{(6)}") ///
mgroups("COVID outcomes in rates" "COVID outcomes in level" ,pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr) {@span})) ///
nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\midrule \\ ///
\multicolumn{7}{c}{\emph{\textbf{\textcolor{red}{Government policy: National Emergency Declaration}}}} \\ \multicolumn{7}{c}{\emph{\textbf{Panel A: Covid-19 cases}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_medianw_P1 reg4_death_medianw_P1 reg5_death_medianw_P1 reg1_death1_medianw_P1 reg4_death1_medianw_P1 reg5_death1_medianw_P1 using Table_A2.tex, keep(1.P1 2.seg 1.P1#2.seg ) append /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{7}{c}{\emph{\textbf{Panel B: Covid-19 deaths}}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))


esttab reg1_case_medianw_P2 reg4_case_medianw_P2 reg5_case_medianw_P2 reg1_case1_medianw_P2 reg4_case1_medianw_P2 reg5_case1_medianw_P2 using Table_A2.tex, keep(1.P2 2.seg 1.P2#2.seg ) append /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{7}{c}{\emph{\textbf{\textcolor{red}{Government policy: County Emergency Declaration}}}} \\ \multicolumn{7}{c}{\emph{\textbf{Panel C: Covid-19 cases }}} \\) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N, fmt( %11.0gc ) layout( @ ) ///
labels("Observations" ))

esttab reg1_death_medianw_P2 reg4_death_medianw_P2 reg5_death_medianw_P2 reg1_death1_medianw_P2 reg4_death1_medianw_P2 reg5_death1_medianw_P2 using Table_A2.tex, keep(1.P2 2.seg 1.P2#2.seg ) append /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\addlinespace \multicolumn{7}{c}{\emph{\textbf{Panel D: Covid-19 deaths}}} \\) prefoot(\addlinespace)  ///
stat( N sfe cfe dfe control, fmt( %11.0gc  0 0 0 0) layout( @ @ @ @ @ ) ///
labels("Observations" "\midrule State FE" "County FE" "Day FE" "Controls"  ))


*---------------------------------------------------------------------------*
*				 			TABLE A3
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

rename national_lockdown P1
rename county_lockdown P2

rename case case1
rename death death1
gen case=case1/pop*100000
gen death=death1/pop*100000

gen area=density_2018/pop

global controls "area male age poverty educ urban immig share"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"

xtile decilew = seg_index, nq(10)
xtile decile_bw = seg_index_bw, nq(10)


eststo clear
local clear

set more off

foreach index of varlist  EHI  {

foreach decile of varlist decilew  decile_bw {

foreach y of varlist  case death case1 death1  {

foreach policy of varlist  P1 P2    {
gen Policy=`policy'
qui postfile bskeep decile beta_`y'_`policy' ci_l95_`y'_`policy' ci_u95_`y'_`policy' using fig_`y'_`policy'_`decile', replace
*qui postfile bskeep decile beta ci_l95 ci_u95 using fig_`y'_`policy'_`decile', replace

foreach x of numlist  1(1)10 {


****Columns 5
eststo reg5_`y'_`x'_`policy'_`decile': reghdfe `y'  i.Policy##c.`index' if `decile'==`x', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  "\checkmark"
drop sample 

	local cil95 = _b[1.Policy#c.`index'] - _se[1.Policy#c.`index']*invttail(25, 0.025)
	local ciu95 = _b[1.Policy#c.`index'] + _se[1.Policy#c.`index']*invttail(25, 0.025)
	post bskeep (`x') (_b[1.Policy#c.`index']) (`cil95') (`ciu95')

}
/* Save the Stata data file */
qui postclose bskeep
drop Policy
}
}

}
}

*---------------------------------------------------------------------------*
*				 			TABLE A3
*--------------------------------------------------------------------------*

foreach index of varlist  EHI  {

foreach x of numlist  1 {

**Table_Government policy and Covid by level of residential segregation: Cases and deaths 
esttab reg5_case_`x'_P1_decilew reg5_death_`x'_P1_decilew reg5_case_`x'_P2_decilew reg5_death_`x'_P2_decilew ///
reg5_case1_`x'_P1_decilew reg5_death1_`x'_P1_decilew reg5_case1_`x'_P2_decilew reg5_death1_`x'_P2_decilew ///
using Table_A3.tex, keep(1.Policy#c.`index' ) replace /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment nonumbers label nobaselevels ///
mtitles("\shortstack{Cases in rates\\(1)}" "\shortstack{Deaths in rates\\(2)}" "\shortstack{Cases in rates\\(3)}" "\shortstack{Deaths in rates\\(4)}" "\shortstack{Cases in level\\(5)}" "\shortstack{Deaths in level\\(6)}" "\shortstack{Cases in level\\(7)}" "\shortstack{Deaths in level\\(8)}" ) ///
mgroups("FSOE" "CSOE" "FSOE" "CSOE" ,pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr) {@span})) ///
nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
posthead(\midrule) prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N , fmt( %11.0gc ) layout( @  ) ///
labels("Observations"))
}
}


foreach index of varlist  EHI  {

foreach x of numlist  2(1)9 {

**Table_Government policy and Covid by level of residential segregation: Cases and deaths 
esttab reg5_case_`x'_P1_decilew reg5_death_`x'_P1_decilew reg5_case_`x'_P2_decilew reg5_death_`x'_P2_decilew ///
reg5_case1_`x'_P1_decilew reg5_death1_`x'_P1_decilew reg5_case1_`x'_P2_decilew reg5_death1_`x'_P2_decilew ///
using Table_A3.tex, keep(1.Policy#c.`index' ) append /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
prefoot(\addlinespace) postfoot(\addlinespace) ///
stat( N , fmt( %11.0gc ) layout( @  ) ///
labels("Observations"))
}
}


foreach index of varlist  EHI  {

foreach x of numlist  10 {

**Table_Government policy and Covid by level of residential segregation: Cases and deaths 
esttab reg5_case_`x'_P1_decilew reg5_death_`x'_P1_decilew reg5_case_`x'_P2_decilew reg5_death_`x'_P2_decilew ///
reg5_case1_`x'_P1_decilew reg5_death1_`x'_P1_decilew reg5_case1_`x'_P2_decilew reg5_death1_`x'_P2_decilew ///
using Table_A3.tex, keep(1.Policy#c.`index' ) append /// 
cells(b(star fmt(2)) se( par fmt(2))) noobs booktabs fragment label nobaselevels nomtitle ///
nonumber nolines collabels(none) star(* 0.1 ** 0.05 *** 0.01) ///
 prefoot(\addlinespace) ///
stat( N cfe dfe controls, fmt( %11.0gc 0 0 0) layout( @ @ @ @) ///
labels("Observations" "\midrule County FE" "Day FE" "Policy and EFI controls"  ))
}
}



*---------------------------------------------------------------------------*
*				 			TABLE A1
*--------------------------------------------------------------------------*

use Master_data_covid_EHI.dta, clear

***Counties with covid-19 response 
gen county_lockdown_dummy=1
replace county_lockdown_dummy=0 if county_lockdown_date==.

gen county_safer_home_dummy=1
replace county_safer_home_dummy=0 if county_safer_home_date==.

gen county_business_dummy=1
replace county_business_dummy=0 if county_business_close_date==.

***Duration of the pandemic in each county
sort fips date2 
gen duration=0 
replace duration=duration[_n-1]+1 if case>0

keep if date=="20200607"


****Panel A:  COVID-19 outcomes

**Total cases 
label var case "Total cases"
estpost tabstat case, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(%11.0gc))" ) nomtitle ///
collabels("N" "Mean" "Std. de." "Min." "Max.") ///
replace

**Total death 
label var death "Total death"
estpost tabstat death, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(%11.0gc))" ) nomtitle ///
append


**** Duration of the pandemic
label var duration "Duration of the pandemic"
estpost tabstat duration, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(%11.0gc))" ) nomtitle ///
append


**** Panel B: ethnic divisions and residential segregation index 

**** Ethnic fragmentation 
label var EHI "Ethnic Fragmentation Index"
estpost tabstat EHI, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Residential segregation index (Whites vs non-Whites)
label var seg_index "White-non-White Residential segregation index"
estpost tabstat seg_index, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(0))" ) nomtitle ///
append

**** Residential segregation index (Black-White)
label var seg_index_bw "Black-White Residential segregation index"
estpost tabstat seg_index_bw, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(0))" ) nomtitle ///
append


**** Panel C: Local government response 

**** County emergency declaration
label var county_lockdown_dummy "County with SOE (in \%)"
estpost tabstat county_lockdown_dummy, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(%11.0gc))" ) nomtitle ///
append

**** County safer at home policy
label var county_safer_home_dummy "County with safer-at-home order (in \%)"
estpost tabstat county_safer_home_dummy, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(%11.0gc))" ) nomtitle ///
append


**** County business closure
label var county_business_dummy "County with business closure (in \%)"
estpost tabstat county_business_dummy, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(%11.0gc))" ) nomtitle ///
append


**** Panel D: Demographic control at the county level 

**** Population density in 2018
label var density_2018 "Population density"
estpost tabstat density_2018, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Percentage of male
label var male "Percentage of male"
estpost tabstat male, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Age
label var age "Median age"
estpost tabstat age, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Poverty
label var poverty "Poverty rate"
estpost tabstat poverty, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Education
label var educ "Educational attainment"
estpost tabstat educ, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Urban population
label var urban "Urban population (in \%)"
estpost tabstat urban, statistics(n mean sd min max) columns(statistics)
matrix n=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append


**** Immigration
label var immig "Foreign-born (in \%)"
estpost tabstat immig, statistics(n mean sd min max) columns(statistics)
matrix count=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append


**** Panel E: Health characteristic at the county level 

**** Percentage of adults reporting fair or poor health (age-adjusted)
label var fairorpoorhealth "Adults with fair or poor health (in \%)"
estpost tabstat fairorpoorhealth, statistics(n mean sd min max) columns(statistics)
matrix count=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Percentage of adults who are current smokers
label var smokers "Smokers (in \%)"
estpost tabstat smokers, statistics(n mean sd min max) columns(statistics)
matrix count=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Percentage of the adult population (age 20 and older) that reports a body mass index (BMI) greater than or equal to 30 kg/m2.
label var adultswithobesity "Adults with obesity (in \%)"
estpost tabstat adultswithobesity, statistics(n mean sd min max) columns(statistics)
matrix count=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append

**** Percentage of adults aged 20 and above with diagnosed diabetes.
label var adultswithdiabetes "Adults with diabetes (in \%)"
estpost tabstat adultswithdiabetes, statistics(n mean sd min max) columns(statistics)
matrix count=e(count)
matrix mean=e(mean)
matrix sd=e(sd)
matrix min=e(min)
matrix max=e(max)
esttab . using "Table_A1.tex", nostar noobs nonote  booktabs fragment label nobaselevels nonumber nolines collabels(none) /// 
cells("count (fmt(%11.0gc)) mean (fmt(2)) sd (fmt(2)) min (fmt(0)) max (fmt(2))" ) nomtitle ///
append