/*
The Rural-Nonrural Divide? K-12 District Spending and Implications of Equity-Based School Funding

Created by: Paul Bruno & Tasmin Dhaliwal
Created on: August 14, 2017
Modified on: December 21st, 2020

This file includes code used for the analysis of rural and nonrural spending used in the AERA Open publication. 

*/

clear all
set maxvar 120000
macro drop _all
set more off
global wd "."

local cdate: display %td_YY_NN_DD date(c(current_date), "DMY")
local cdate = subinstr("`cdate'"," ","",.)
global date `cdate'
display $date


use "AERAOpen_lcffruralpanel_0418_replication.dta"

****************************************************
********TABLE 2: Summary statistics*****************
****************************************************
eststo clear
///Rural remote
eststo: estpost summarize k12ada dd_ptotfrl d_pmin2 dd_pell d_pspeced pop517 pov517 ///District Characteristics
totexp_1 st_1 prekadult_1 capfacil_1 debt_1 retiree_1 nonagcs_1 ///Total
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1   ///
genadmin_all_ex1 otherfunctions_ex1  ///Functions
salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 ///objects
 if rural_remote == 1 & schendyr==2013 & rural_remote_in13==1 & rural_remote_in18==1
///Rural distant 
eststo: estpost summarize k12ada dd_ptotfrl d_pmin2 dd_pell d_pspeced pop517 pov517 ///District Characteristics
totexp_1 st_1 prekadult_1 capfacil_1 debt_1 retiree_1 nonagcs_1 ///Total
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1   ///
genadmin_all_ex1 otherfunctions_ex1  ///Functions
salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 ///objects
 if rural_distant == 1 & schendyr==2013 & rural_distant_in13==1 & rural_distant_in18==1
///Rural fringe
eststo: estpost summarize k12ada dd_ptotfrl d_pmin2 dd_pell d_pspeced pop517 pov517 ///District Characteristics
totexp_1 st_1 prekadult_1 capfacil_1 debt_1 retiree_1 nonagcs_1 ///Total
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1   ///
genadmin_all_ex1 otherfunctions_ex1  ///Functions
salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 ///objects
 if rural_fringe == 1 & schendyr==2013 & rural_fringe_in13==1 & rural_fringe_in18==1

esttab using "${wd}\output\sumstats_${date}.rtf", replace label nonumbers cells("count(label(N)) mean(fmt(0) label(Mean)) sd(fmt(0) label(SD)) min(fmt(0) label(Min)) max(fmt(0) label(Max))") ///
coeflabels(dd_ptotfrl "% FRL" d_pmin2 "% students of color" dd_pell "% English language learners" d_pspeced "% SPED identified" pop517 "Population Ages 5-17" pov517 "Population Ages 5-17 in Poverty" totexp_1 "Total" st_1 "Student" prekadult_1 "Pre-K & Adult" capfacil_1 "Capital & Facilities" debt_1 "Debt Service" retiree_1 "Retiree Benefits" nonagcs_1 "Non-agency & Community Service" instruction_all_ex1 "Instruction" spedinstruction_ex1 "SPED Instruction" instrelservs_all_ex1 "Instruction-related Services" pupservs_all_ex1 "Pupil Services" transportservs_ex1 "Transportation" plantservs_ex1 "Plant Services" genadmin_all_ex1 "General Administration" otherfunctions_ex1 "Other functions" salaries_all_ex1 "Salaries" salaries_tchr_ex1 "Teacher Salaries" salaries_admin_ex1 "Admin. Salaries" benefits_all_ex1 "Benefits" capitaloutlay_ex1 "Capital" otherobjects_ex1 "Other objects") title(Table 2 - Summary Statistics)

eststo clear
///Town 
eststo: estpost summarize k12ada dd_ptotfrl d_pmin2 dd_pell d_pspeced pop517 pov517 ///District Characteristics
totexp_1 st_1 prekadult_1 capfacil_1 debt_1 retiree_1 nonagcs_1 ///Total
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1   ///
genadmin_all_ex1 otherfunctions_ex1  ///Functions
salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 ///objects
 if town_locale == 1 & schendyr==2013 & town_locale_in13==1 & town_locale_in18==1

///Suburb 
eststo: estpost summarize k12ada dd_ptotfrl d_pmin2 dd_pell d_pspeced pop517 pov517 ///District Characteristics
totexp_1 st_1 prekadult_1 capfacil_1 debt_1 retiree_1 nonagcs_1 ///Total
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1   ///
genadmin_all_ex1 otherfunctions_ex1  ///Functions
salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 ///objects
 if suburb_locale == 1 & schendyr==2013 & suburb_locale_in13==1 & suburb_locale_in18==1

//Urban 
eststo: estpost summarize k12ada dd_ptotfrl d_pmin2 dd_pell d_pspeced pop517 pov517 ///District Characteristics
totexp_1 st_1 prekadult_1 capfacil_1 debt_1 retiree_1 nonagcs_1 ///Total
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1   ///
genadmin_all_ex1 otherfunctions_ex1  ///Functions
salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 ///objects
 if urban_locale == 1 & schendyr==2013 & urban_locale_in13==1 & urban_locale_in18==1

esttab using "${wd}\output\sumstats2_${date}.rtf", replace label nonumbers cells("count(label(N)) mean(fmt(0) label(Mean)) sd(fmt(0) label(SD)) min(fmt(0) label(Min)) max(fmt(0) label(Max))") ///
coeflabels(dd_ptotfrl "% FRL" d_pmin2 "% students of color" dd_pell "% English language learners" d_pspeced "% SPED identified" pop517 "Population Ages 5-17" pov517 "Population Ages 5-17 in Poverty" totexp_1 "Total" st_1 "Student" prekadult_1 "Pre-K & Adult" capfacil_1 "Capital & Facilities" debt_1 "Debt Service" retiree_1 "Retiree Benefits" nonagcs_1 "Non-agency & Community Service" instruction_all_ex1 "Instruction" spedinstruction_ex1 "SPED Instruction" instrelservs_all_ex1 "Instruction-related Services" pupservs_all_ex1 "Pupil Services" transportservs_ex1 "Transportation" plantservs_ex1 "Plant Services" genadmin_all_ex1 "General Administration" otherfunctions_ex1 "Other functions" salaries_all_ex1 "Salaries" salaries_tchr_ex1 "Teacher Salaries" salaries_admin_ex1 "Admin. Salaries" benefits_all_ex1 "Benefits" capitaloutlay_ex1 "Capital" otherobjects_ex1 "Other objects") title(Table 2 - Summary Statistics)


****************************************************
******TABLE 3-5: PER ADA SPENDING 2017-18***********
****************************************************
///TABLE 3 
*** Edited by Ryan
eststo clear
***
foreach var of varlist totexp_1 st_1 nonstudent_1 ///
capfacil_1  debt_1 nonagcs_1 prekadult_1 retiree_1 {
	eststo: regress `var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_shares_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) 
	}
*** Edited by Annie
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***
eststo clear
foreach var of varlist pctst_1 pctnonstudent_1 pctcapfacil_1 pctdebt_1 pctnonagcs_1 /// 
pctprekadult_1 pctretiree_1 {
	regress `var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_pctshares_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) 
	}
	
///TABLE 4	
foreach var of varlist instruction_all_ex1 spedinstruction_ex1 ///
instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1   ///
genadmin_all_ex1 otherfunctions_ex1   {
	regress `var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_shares_${date}functions.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) 
	}

	
foreach var of varlist pctinstruction_all_ex1 pctspedinstruction_ex1 ///
pctinstrelservs_all_ex1 pctpupservs_all_ex1 pcttransportservs_ex1   ///
pctplantservs_ex1 pctgenadmin_all_ex1 pctotherfunctions_ex1   {
	regress `var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_pctshares_${date}functions.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) 
	}
	
///TABLE 5	
foreach var of varlist salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 ///
benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1  {
	regress `var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_shares_${date}objects.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) 
	}	
	
foreach var of varlist pctsalaries_all_ex1 pctsalaries_tchr_ex1 pctsalaries_admin_ex1 ///
pctbenefits_all_ex1 pctcapitaloutlay_ex1 pctotherobjects_ex1  {
	regress `var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_pctshares_${date}objects.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) 
	}
	
*********************************************************************
******TABLE 6-8: CHANGE IN PER ADA SPENDING 12-13 TO 17-18***********
*********************************************************************
sort dcode schendyr
*Generating the diff and percent change variables between 17-18 and 12-13
foreach var of varlist totexp_1 st_1 nonstudent_1 capfacil_1  debt_1  nonagcs_1  prekadult_1 retiree_1 ///
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1 genadmin_all_ex1 otherfunctions_ex1 ///	
 salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 {
 
 bys dcode: egen max_`var'=max(`var') if schendyr==2013
 bys dcode: egen `var'_in13=max(max_`var')
 drop max_`var'
 }

foreach var of varlist totexp_1 st_1 nonstudent_1 capfacil_1  debt_1  nonagcs_1  prekadult_1 retiree_1 ///
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1 genadmin_all_ex1 otherfunctions_ex1 ///	
 salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 {
 
 bys dcode: egen max_`var'=max(`var') if schendyr==2018
 bys dcode: egen `var'_in18=max(max_`var')
 drop max_`var'
 }
 
foreach var of varlist totexp_1 st_1 nonstudent_1 capfacil_1  debt_1  nonagcs_1  prekadult_1 retiree_1 ///
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1 genadmin_all_ex1 otherfunctions_ex1 ///	
 salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 {
	gen chg`var'=((`var'_in18 - `var'_in13)/`var'_in13)*100 
	local label : variable label `var'
	label var chg`var' "%age chg of 2013: `label'"
}

*I will also generate a variable for the difference and output these results 
foreach var of varlist totexp_1 st_1 nonstudent_1 capfacil_1  debt_1  nonagcs_1  prekadult_1 retiree_1 ///
instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1 genadmin_all_ex1 otherfunctions_ex1 ///	
 salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1 capitaloutlay_ex1 otherobjects_ex1 {
	gen diff`var'=(`var'_in18 - `var'_in13)
	drop `var'_in18 `var'_in13
	local label : variable label `var'
	label var diff`var' "diff 2018-2013 SY: `label'"
}


///TABLE 6
*Expenditures overall and by function 
foreach var of varlist totexp_1 st_1 nonstudent_1 capfacil_1  debt_1  nonagcs_1  prekadult_1 retiree_1   {
	eststo: regress chg`var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_changesagg_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +)
	}

foreach var of varlist totexp_1 st_1 nonstudent_1 capfacil_1  debt_1  nonagcs_1  prekadult_1 retiree_1  {
	regress diff`var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_diffchangesagg_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +)
	}
estout using "../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
///TABLE 7
*Expenditures overall and by function 
foreach var of varlist instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1 ///
genadmin_all_ex1 otherfunctions_ex1  {
	regress chg`var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_changesfunc_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +)
	}

foreach var of varlist instruction_all_ex1 spedinstruction_ex1 instrelservs_all_ex1 pupservs_all_ex1 transportservs_ex1 plantservs_ex1 ///
genadmin_all_ex1 otherfunctions_ex1  {
	regress diff`var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada] if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expenditures_diffchangesfunc_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +)
	}
	
	
///TABLE 8
*Expenditures by object
foreach var of varlist  salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1  otherobjects_ex1   {
	regress chg`var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada]if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expendituresobj_changes_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +)

	}
	
foreach var of varlist  salaries_all_ex1 salaries_tchr_ex1 salaries_admin_ex1 benefits_all_ex1  otherobjects_ex1   {
	regress diff`var'  rural_distant rural_fringe town_locale suburb_locale urban_locale [aweight=k12ada]if schendyr == 2018 & present1318==1, vce(robust)
	outreg2 using "${wd}\output\expendituresobj_diffchanges_${date}.doc", append ///
	alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +)

	}	


*********************************************************************
***********FIGURE 1: TOTAL & STUDENT SPENDING OVER TIME**************
*********************************************************************
*All spending and student spending-- using all categories disaggregated
preserve
keep if present_panel==1
collapse totexp_1 st_1 [aweight=k12ada], by(schendyr timeinvar_locale)

*All spending and student spending
twoway (scatter totexp_1 schendyr if timeinvar_locale == 1, connect(direct) msymbol(diamond) mcolor(gs3) lpattern(dash) lcolor(gs3)) ///
(scatter totexp_1 schendyr if (timeinvar_locale==2), connect(direct)  msymbol(circle) mcolor(edkblue) lpattern(solid) lcolor(edkblue)) ///
(scatter totexp_1 schendyr if (timeinvar_locale==3), connect(direct)  msymbol(square) mcolor(forest_green) lpattern(dot) lcolor(forest_green)) ///
(scatter totexp_1 schendyr if (timeinvar_locale==4), connect(direct)  msymbol(triangle) mcolor(gs10) lpattern(dash_dot) lcolor(gs10)) ///
(scatter totexp_1 schendyr if (timeinvar_locale==5), connect(direct)  msymbol(plus) mcolor(cranberry) lpattern(shortdash) lcolor(cranberry)) ///
(scatter totexp_1 schendyr if (timeinvar_locale==6), connect(direct)  msymbol(X) mcolor(dkorange) lpattern(longdash_dot) lcolor(dkorange)) ///
(scatteri 6000 2007.5 26000 2007.5, c(l) m(i) lpattern(dash)) ///
(scatteri 6000 2013.5 26000 2013.5, c(l) m(i) lpattern(dash)), scheme(s1mono) ///
xlabel(2005(2)2018) xtitle("School Year (e.g., 2005 = 2004-5)") ///
ylabel(6000(6000)26000) ///
text(24000 2009 "Recession Start") text(24000 2014.05 "LCFF") ///
title("Total Spending per ADA") /// 
subtitle("California Districts, 2003-4 through 2017-18") ///
note("ADA-weighted and in 2018 dollars.") ///
legend(label(6 "Urban") label(5 "Suburban") label(4 "Town")  label(3 "Rural Fringe")  label(2 "Rural Distant") ///
label(1 "Rural Remote") order(6 5 4 3 2 1)) name(longexpend, replace)

graph export "${wd}\output\totlong_${date}_localeall.png", as(png) replace

twoway  (scatter st_1 schendyr if timeinvar_locale == 1, connect(direct) msymbol(diamond) mcolor(gs3) lpattern(dash) lcolor(gs3)) ///
(scatter st_1 schendyr if (timeinvar_locale==2), connect(direct)  msymbol(circle) mcolor(edkblue) lpattern(solid) lcolor(edkblue)) ///
(scatter st_1 schendyr if (timeinvar_locale==3), connect(direct)  msymbol(square) mcolor(forest_green) lpattern(dot) lcolor(forest_green)) ///
(scatter st_1 schendyr if (timeinvar_locale==4), connect(direct)  msymbol(triangle) mcolor(gs10) lpattern(dash_dot) lcolor(gs10)) ///
(scatter st_1 schendyr if (timeinvar_locale==5), connect(direct)  msymbol(plus) mcolor(cranberry) lpattern(shortdash) lcolor(cranberry)) ///
(scatter st_1 schendyr if (timeinvar_locale==6), connect(direct)  msymbol(X) mcolor(dkorange) lpattern(longdash_dot) lcolor(dkorange)) ///
(scatteri 6000 2007.5 26000 2007.5, c(l) m(i) lpattern(dash)) ///
(scatteri 6000 2013.5 26000 2013.5, c(l) m(i) lpattern(dash)), scheme(s1mono) ///
xlabel(2005(2)2018) xtitle("School Year (e.g., 2005 = 2004-5)") ///
ylabel(6000(6000)26000) ///
text(24000 2009 "Recession Start") text(24000 2014.05 "LCFF") ///
title("Student Spending per ADA") /// 
subtitle("California Districts, 2003-4 through 2017-18") ///
note("ADA-weighted and in 2018 dollars.") ///
legend(label(6 "Urban") label(5 "Suburban") label(4 "Town")  label(3 "Rural Fringe")  label(2 "Rural Distant") ///
label(1 "Rural Remote") order(6 5 4 3 2 1)) name(longexpend, replace)

graph export "${wd}\output\stulong_${date}_localeall.png", as(png) replace

restore 

*********************************************************************
***********FIGURE 2: SPENDING PROGRESSIVITY OVER TIME****************
*********************************************************************
gen timeinvar_locale2=. 
replace timeinvar_locale2=1 if rural_remote_timeinvar==1
replace timeinvar_locale2=2 if rural_distant_timeinvar==1
replace timeinvar_locale2=3 if rural_fringe_timeinvar==1
replace timeinvar_locale2=4 if (town_timeinvar==1|suburb_timeinvar==1)
replace timeinvar_locale2=5 if urban_timeinvar==1


preserve
drop if present_panel==0

gen nonpov517 = pop517-pov517
drop if missing(nonpov517)

tabstat nonpov517, by(schendyr)
tabstat nonpov517 if timeinvar_locale2 == 1, by(schendyr)
tabstat nonpov517 if timeinvar_locale2 == 2, by(schendyr)
tabstat nonpov517 if timeinvar_locale2 == 3, by(schendyr)
tabstat nonpov517 if timeinvar_locale2 == 4, by(schendyr)
tabstat nonpov517 if timeinvar_locale2 == 5, by(schendyr)

collapse st_1 strev1 [aweight=pov517], by(timeinvar_locale2 schendyr)
rename st_1 povweight
rename strev1 povweight_rev

tabstat povweight, by(schendyr)
tabstat povweight if timeinvar_locale2 == 1, by(schendyr)
tabstat povweight if timeinvar_locale2 == 2, by(schendyr)
tabstat povweight if timeinvar_locale2 == 3, by(schendyr)
tabstat povweight if timeinvar_locale2 == 4, by(schendyr)
tabstat povweight if timeinvar_locale2 == 5, by(schendyr)


compress
save "${wd}\source data\uimeasure_pov_noncwi_ruralcombo.dta", replace
restore

tabstat st_1, by(schendyr)
tabstat st_1 if timeinvar_locale2 == 1, by(schendyr)
tabstat st_1 if timeinvar_locale2 == 2, by(schendyr)
tabstat st_1 if timeinvar_locale2 == 3, by(schendyr)
tabstat st_1 if timeinvar_locale2 == 4, by(schendyr)
tabstat st_1 if timeinvar_locale2 == 5, by(schendyr)


preserve
drop if present_panel==0
gen nonpov517 = pop517-pov517
drop if missing(nonpov517)
collapse st_1 strev1 [aweight=nonpov517], by(timeinvar_locale2 schendyr)
compress
merge 1:1 timeinvar_locale schendyr using "${wd}\source data\uimeasure_pov_noncwi_ruralcombo.dta"
gen uimeasure = povweight - st_1

gen uimeasurerev = povweight_rev - strev1
tabstat povweight st_1 uimeasure, by(schendyr)
tabstat povweight st_1 uimeasure if timeinvar_locale2 == 1, by(schendyr)
tabstat povweight st_1 uimeasure if timeinvar_locale2 == 2, by(schendyr)
tabstat povweight st_1 uimeasure if timeinvar_locale2 == 3, by(schendyr)
tabstat povweight st_1 uimeasure if timeinvar_locale2 == 4, by(schendyr)
tabstat povweight st_1 uimeasure if timeinvar_locale2 == 5, by(schendyr)


twoway (scatter uimeasure schendyr if timeinvar_locale2 == 1, connect(direct) msymbol(diamond) mcolor(gs3) lpattern(dash) lcolor(gs3)) ///
(scatter uimeasure schendyr if timeinvar_locale2 == 2, connect(direct)  msymbol(circle) mcolor(edkblue) lpattern(solid) lcolor(edkblue)) ///
(scatter uimeasure schendyr if timeinvar_locale2 == 3, connect(direct)  msymbol(square) mcolor(forest_green) lpattern(dot) lcolor(forest_green)) ///
(scatter uimeasure schendyr if timeinvar_locale2 == 4, connect(direct)  msymbol(triangle) mcolor(gs10) lpattern(dash_dot) lcolor(gs10)) ///
(scatter uimeasure schendyr if timeinvar_locale2 == 5, connect(direct)  msymbol(plus) mcolor(dkorange) lpattern(shortdash) lcolor(dkorange)) ///
(scatteri 0 2004 0 2018, c(l) m(i) lpattern(solid) lwidth(thick)) ///
(scatteri -300 2007.5 800 2007.5, c(l) m(i) lpattern(dash)) ///
(scatteri -300 2013.5 800 2013.5, c(l) m(i) lpattern(dash)), scheme(s1mono) ///
xlabel(2005(2)2018) xtitle("School Year (e.g., 2005 = 2004-5)") ///
ylabel(-300(500)800) yscale(range(-200 800)) ///
title("Progressivity in Student Spending") ///
subtitle("Difference between poverty-weighted and non-poverty weighted spending") ///
note("In 2018 dollars.") ///
text(700 2009 "Recession Start") text(700 2014.05 "LCFF") ///
legend(label(5 "Urban") label(4 "Surbuban/Town")  label(3 "Rural Fringe")  label(2 "Rural Distant")  ///
label(1 "Rural Remote") order(5 4 3 2 1)) name(longexpdiffui_rural_nocwiall, replace)

graph export "${wd}\output\longexpdiffui_rural_nocwicombo_drpti_${date}.png", as(png) replace

restore

*********************************************************************
***********APPENDIX A2: SPENDING PER ADA DIFF MEASURES***************
*********************************************************************

*Total and student spending unweighted and ADA weighted, including with COE adjustments 
foreach var of varlist rural_locale {
	sum totexp_1 if schendyr==2018 & `var'==1 & present1318==1 [aweight=k12ada]
	sum totexp_1 if schendyr==2018 & `var'==1 & present1318==1 
}

foreach var of varlist rural_locale {
	sum totexp_1_c if schendyr==2018 & `var'==1 & present1318==1 [aweight=k12ada]
	sum totexp_1_c if schendyr==2018 & `var'==1 & present1318==1 
}

foreach var of varlist rural_locale {
	sum totexp_1 if schendyr==2018 & `var'==0 & present1318==1 [aweight=k12ada]
	sum totexp_1 if schendyr==2018 & `var'==0 & present1318==1 
}

foreach var of varlist rural_locale {
	sum totexp_1_c if schendyr==2018 & `var'==0 & present1318==1 [aweight=k12ada]
	sum totexp_1_c if schendyr==2018 & `var'==0 & present1318==1 
}


foreach var of varlist rural_locale {
	sum st_1 if schendyr==2018 & `var'==1 & present1318==1 [aweight=k12ada]
	sum st_1 if schendyr==2018 & `var'==1 & present1318==1 
}

foreach var of varlist rural_locale {
	sum st_1_c if schendyr==2018 & `var'==1 & present1318==1 [aweight=k12ada]
	sum st_1_c if schendyr==2018 & `var'==1 & present1318==1 
}

foreach var of varlist rural_locale {
	sum st_1 if schendyr==2018 & `var'==0 & present1318==1 [aweight=k12ada]
	sum st_1 if schendyr==2018 & `var'==0 & present1318==1 
}

foreach var of varlist rural_locale {
	sum st_1_c if schendyr==2018 & `var'==0 & present1318==1 [aweight=k12ada]
	sum st_1_c if schendyr==2018 & `var'==0 & present1318==1 
}


*********************************************************************
**************APPENDIX B: ELEMENTARY & UNIFIED SCHOOLS***************
*********************************************************************
*Tables and figures in appendix B were created by using the main analysis code above 
*and limiting analysis to dtype=="Elementary" for the elementary analysis and dtype=="Unified" for 
*the unified analysis. 
