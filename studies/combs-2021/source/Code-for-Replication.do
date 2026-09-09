*------------------------------------------------------------------------------
*The Effects of Homestead Exemptions for Seniors and Disabled People
*Authors: Alex Combs & John Foster
*Replication of Tables
*------------------------------------------------------------------------------

set more off

use kyexemptreplicationdata.dta, clear

xtset ncesid year

//Setting locals for the regression models

local iv1 lnivtaxableratio1 lntaxableratio1terc ivaidshare1
local iv2 lnivtaxableratio2 lntaxableratio2terc ivaidshare2
local iv3 lnivtaxableratio3 lntaxableratio3terc ivaidshare3
local controls lntaxshare lnrealp50inc pctefrl2 pctsped2 pctlep2 bachplus homeown black lnenrollment lnenrollmentsq youthpct oldhosh disabhosh

///Summary Statistics Table for Manuscript, Table 1

local sumvars realtcurelscpp taxableratio1 taxableratio2 taxableratio3 aidsharestyinger1 aidsharestyinger2 aidsharestyinger3 taxshare realp50inc pctefrl2 pctsped2 pctlep2 bachplus homeown black enrollment youthpct oldhosh disabhosh

tabstat `sumvars' if hasalldata==1, stat(mean sd min max) save
matrix summary = r(StatTotal)'
putexcel set combs-foster_kyhex_tables.xlsx, sheet(table1) modify
putexcel A1 = matrix(summary), names nformat(number_d2)

putexcel A1=("Variables") B1=("Mean") C1=("SD") D1=("Min") E1=("Max")
local row=2
foreach x of local sumvars {
	describe `x'
	local varlabel : var label `x'
	putexcel A`row' = ("`varlabel'")
	local ++row
}

*------------------------------------------------------------------------------
*OLS Results Spending for Manuscript, Columns 1-3 of Table 2 
*------------------------------------------------------------------------------

forval i=1/3 {

xtreg lnrealtcurelscpp lntaxableratio`i' aidsharestyinger`i' `controls' i.year, fe cluster(ncesid)

eststo m`i'

local lntaxableratiolist `lntaxableratiolist' lntaxableratio`i' lntaxableratio

local aidsharestyingerlist `aidsharestyingerlist' aidsharestyinger`i' aidsharestyinger

}

esttab m1 m2 m3 using table2part1.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) wide ///
	drop(*.year) title("OLS Total Current Expenditure Results") ///
	mtitle("50% Threshold" "40% Threshold" "30% Threshold") ///
	rename(`lntaxableratiolist' `aidsharestyingerlist') ///
	order(lntaxableratio aidsharestyinger) ///
	coeflabels(lntaxableratio "Taxable share ratio" ///
				aidsharestyinger "State aid share") ///
	scalars("N_clust Clusters" ///
			"r2_w Within R-squared") ///
	sfmt(%9.0f %9.3f) ///
	replace

estimates clear

*------------------------------------------------------------------------------
/*GMM Results Spending Table for Manuscript and Storing the Exemption Price 
and Aid coefficients for the simulation, Columns 4-6 of Table 2*/
*------------------------------------------------------------------------------

eststo: xi: reg i.year

forval i=1/3 {

xtivreg2 lnrealtcurelscpp (lntaxableratio`i' aidsharestyinger`i'= `iv`i'') `controls' ///
 _Iyear_2000-_Iyear_2013, fe cluster(ncesid) endog(lntaxableratio`i' aidsharestyinger`i') first gmm2s

eststo m`i'

local lntaxableratiolist `lntaxableratiolist' lntaxableratio`i' lntaxableratio

local aidsharestyingerlist `aidsharestyingerlist' aidsharestyinger`i' aidsharestyinger

gen cftaxableratio`i'=_b[lntaxableratio`i']

gen cfaidshare`i'=_b[aidsharestyinger`i']

}
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

esttab m1 m2 m3 using table2part2.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) wide ///
	drop(_Iyear_*) title("Regression Estimates for the Current Expenditure Model") ///
	mtitle("50% Threshold" "40% Threshold" "30% Threshold") ///
	rename(`lntaxableratiolist' `aidsharestyingerlist') ///
	order(lntaxableratio aidsharestyinger) ///
	coeflabels(lntaxableratio "Taxable share ratio" ///
				aidsharestyinger "State aid share") ///
	scalars("N_clust Clusters" ///
			"r2 R-squared" ///
			"idp Underid P-value" ///
			"arfp Endogeneity Test P-value" ///
			"widstat Weak IV F-Stat" /// 
			"jp Hansen P-value") ///
	sfmt(%9.0f %9.3f) ///
	replace

estimates clear


///Calculating District's Lump-Sum SEEK Aid if Exemption Did Not Exist
 
gen realstateseeknoexemptpp=realadjseekpp-.0035*realassessaltpp
replace realstateseeknoexemptpp=0 if realstateseeknoexemptpp<0
gen realstateseekdiff=realstateseekpp-realstateseeknoexemptpp

///Calculating District's Tier 1 Aid if Exemption Did Not Exist
gen equallevelalt=statenomassessaltpp*1.5
gen tier1diff=((1-(pp_assessment/equallevel))-(1-(nomassessaltpp/equallevelalt)))*maxtier1amt
gen realtier1diff=tier1diff/deflator
gen realtier1diffpp=realtier1diff/enrollment

///Calculating District's Total Exemption-Driven State Aid Differential

gen realstateaidnoexemptpp=realtstrevpp-realstateseekdiff-realtier1diffpp

///Calculating Median Voter's Aid Share without Exemption
gen aidsharenoexempt=taxshare*(realstateaidnoexemptpp/realp50inc)


///Estimating Tax Price and Aid Impacts from Exemption

gen taxableratio1diff=taxableratio1-1
 
gen taxableratio1eff=(exp(cftaxableratio1*ln(1+taxableratio1diff))-1)*100
label var taxableratio1eff "Price Effect" 

replace taxableratio1diff=taxableratio1diff*100
label var taxableratio1diff "% Change in Price"

gen aidshare1diff=aidsharestyinger1-aidsharenoexempt
label var aidshare1diff "Aid Share Change"
gen aidshare1eff=(exp(cfaidshare1*aidshare1diff)-1)*100
label var aidshare1eff "Income Effect"

//NOTE: We use the proportion forms of the change in state aid per dollar of the
//median household income and the median voter's share of state aid (i.e., "aidshare1diff")
//to compute the income effect. However, we convert these measures to percentage
//form for Table 3 in order to enhance readability. 

replace aidshare1diff=aidshare1diff*100
gen aidincratiodiff=((realtstrevpp-realstateaidnoexemptpp)/realp50inc)*100
label var aidincratiodiff "Change in State Aid Per Dollar of Income"
gen netexpeffect1=aidshare1eff+taxableratio1eff
label var netexpeffect1 "Net Effect"

*------------------------------------------------------------------------------
*Spending Simulations
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
/* Table 3: Simulated Impacts of the Homestead Exemption on Current 
Expenditure Per-Pupil, FY 2013*/
*------------------------------------------------------------------------------

local simvars taxableratio1diff taxableratio1eff aidincratiodiff aidshare1diff aidshare1eff netexpeffect1

putexcel set combs-foster_kyhex_tables.xlsx, sheet(table3) modify

tabstat `simvars' if exemptratetile==5 & year==2013 & claimp50sh<=.5, stat(mean) save
matrix pctile5 = r(StatTotal)
putexcel B3 = matrix(pctile5), nformat(number_d2)

tabstat `simvars' if exemptratetile==50 & year==2013 & claimp50sh<=.5, stat(mean) save
matrix pctile50 = r(StatTotal)
putexcel B4 = matrix(pctile50), nformat(number_d2)

tabstat `simvars' if exemptratetile==95 & year==2013 & claimp50sh<=.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel B5 = matrix(pctile95), nformat(number_d2)

tabstat `simvars' if year==2013 & claimp50sh>.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel B6 = matrix(pctile95), nformat(number_d2)

putexcel B1=("% Change in Price")
putexcel C1=("Price Effect")
putexcel D1=("Change in State Aid Per Dollar of Income")
putexcel E1=("Aid Share Change")
putexcel F1=("Income Effect")
putexcel G1=("Net Effect")

putexcel A2=("Claimant Minority Districts")
putexcel A3=("5th Pctile Exemption Loss")
putexcel A4=("Median Exemption Loss")
putexcel A5=("95th Pctile Exemption Loss")
putexcel A6=("Claimant Majority Districts")

///Calculating Millage Rate Differential Due to the Exemption

gen proptaxshare=proptax/tlocrev

gen proptaxrate=realproptaxpp/realpp_assessment

gen proptaxratechange=(netexpeffect1/100)*proptaxshare*(realtcurelscpp/realpp_assessment)
gen proptaxratepercchange=(proptaxratechange/treal)*100
label var proptaxratepercchange "% Change in Property Tax Rate"


///Calculating Property Tax Relief Offset Due to the Impact of the Exemption on Expenditure

gen offsetold=-((proptaxratechange*netoldvalueh)/(treal*exemption))*100
label var offsetold "% Change in Offset for Seniors"

gen offsetdisab=-((proptaxratechange*netdisabvalueh)/(treal*exemption))*100
label var offsetdisab "% Change in Offset for Disabled"


*------------------------------------------------------------------------------
/*Table 4: Simulated Impacts of the Homestead Exemption on Property Tax 
Rates and Exemption Offsets, FY 2013*/
*------------------------------------------------------------------------------

local sim2vars proptaxratepercchange offsetold offsetdisab

putexcel set combs-foster_kyhex_tables.xlsx, sheet(table4) modify

tabstat `sim2vars' if exemptratetile==5 & year==2013 & claimp50sh<=.5, stat(mean) save
matrix pctile5 = r(StatTotal)
putexcel B3 = matrix(pctile5), nformat(number_d2)

tabstat `sim2vars' if exemptratetile==50 & year==2013 & claimp50sh<=.5, stat(mean) save
matrix pctile50 = r(StatTotal)
putexcel B4 = matrix(pctile50), nformat(number_d2)

tabstat `sim2vars' if exemptratetile==95 & year==2013 & claimp50sh<=.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel B5 = matrix(pctile95), nformat(number_d2)

tabstat `sim2vars' if year==2013 & claimp50sh>.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel B6 = matrix(pctile95), nformat(number_d2)

putexcel B1=("% Change in Property Tax Rate")
putexcel C1=("% Change in Offset for Senior")
putexcel D1=("% Change in Offset for Disabled")

putexcel A2=("Claimant Minority Districts")
putexcel A3=("5th Pctile Exemption Loss")
putexcel A4=("Median Exemption Loss")
putexcel A5=("95th Pctile Exemption Loss")
putexcel A6=("Claimant Majority Districts")

///Saving Net Expenditure Effect Estimates for Academic Achievement Impact Simulations

gen netexpeffect1p=netexpeffect1/100

keep if year==2013

keep ncesid year claimp50sh netexpeffect1 exemptratetile

gen netexpeffect1p=netexpeffect1/100

save distnetexpeffect2013.dta, replace 

*------------------------------------------------------------------------------
/* Table 5: OLS Results for the Achievement Equations
The below code generates three tables. The top row of coefficients were
taken from each to construct Table 5. */
*------------------------------------------------------------------------------

foreach d in elemschools midschools highschools {
use ky`d'replication.dta
xtset oaacode year
foreach x of varlist maai rdai scai ssai {

by year, sort: egen `x'mean=mean(`x')
by year, sort: egen `x'sd=sd(`x')
gen z`x'=(`x'-`x'mean)/`x'sd
}

foreach y of varlist zmaai zrdai zscai zssai {
xtreg `y' lnrealspendpp frp_per_CCD ethb_CCD pctsped2 pctlep2 lnenroll lnenrollsq i.year, fe cluster(oaacode)
gen `y'spcfols=_b[lnrealspendpp]

eststo m`d'`y'
}
esttab m`d'zmaai m`d'zrdai m`d'zscai m`d'zssai using achieveols`d'.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*.year) title("OLS Results, Achievement Equations") ///
	mtitle("Math" "Reading" "Science" "Social Studies") ///
	scalars("N_clust Clusters" ///
			"r2_w Within R-squared" ///
			"F F-stat" ///
			"p Model P-value") ///
	sfmt(%9.0f %9.3f %9.0f %9.3f) ///
	replace

save `d'ols.dta, replace
}

*------------------------------------------------------------------------------
*Academic Performance Impacts
*------------------------------------------------------------------------------
//Elementary Level Impacts

use elemschoolsols.dta

joinby ncesid using distnetexpeffect2013.dta, unmatched(master)
tab _merge
drop _merge


foreach x in maai scai ssai {

gen `x'expeffectols=z`x'spcfols*ln(1+netexpeffect1p)

}

sum maaiexpeffectols scaiexpeffectols ssaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==5

sum maaiexpeffectols scaiexpeffectols ssaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==50

sum maaiexpeffectols scaiexpeffectols ssaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==95

sum maaiexpeffectols scaiexpeffectols ssaiexpeffectols if year==2010 & claimp50sh>.5

*------------------------------------------------------------------------------
*Exporting Table 6, Columns 2-4
*------------------------------------------------------------------------------

local sim3vars maaiexpeffectols scaiexpeffectols ssaiexpeffectols

putexcel set combs-foster_kyhex_tables.xlsx, sheet(table6) modify

tabstat `sim3vars' if exemptratetile==5 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile5 = r(StatTotal)
putexcel B3 = matrix(pctile5), nformat(number_d5)

tabstat `sim3vars' if exemptratetile==50 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile50 = r(StatTotal)
putexcel B4 = matrix(pctile50), nformat(number_d5)

tabstat `sim3vars' if exemptratetile==95 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel B5 = matrix(pctile95), nformat(number_d5)

tabstat `sim3vars' if year==2010 & claimp50sh>.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel B6 = matrix(pctile95), nformat(number_d5)

putexcel B1=("Elementary Math")
putexcel C1=("Elementary Science")
putexcel D1=("Elementary Social Studies")

putexcel A2=("Claimant Minority Districts")
putexcel A3=("5th Pctile Exemption Loss")
putexcel A4=("Median Exemption Loss")
putexcel A5=("95th Pctile Exemption Loss")
putexcel A6=("Claimant Majority Districts")

clear

//Middle School Level Impacts

use midschoolsols.dta

joinby ncesid using distnetexpeffect2013.dta, unmatched(master)
tab _merge
drop _merge

gen ssaiexpeffectols=zssaispcfols*ln(1+netexpeffect1p)

sum ssaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==5

sum ssaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==50

sum ssaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==95

sum ssaiexpeffectols if year==2010 & claimp50sh>.5

*------------------------------------------------------------------------------
*Exporting Table 6, Column 5
*------------------------------------------------------------------------------

tabstat ssaiexpeffectols if exemptratetile==5 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile5 = r(StatTotal)
putexcel E3 = matrix(pctile5), nformat(number_d5)

tabstat ssaiexpeffectols if exemptratetile==50 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile50 = r(StatTotal)
putexcel E4 = matrix(pctile50), nformat(number_d5)

tabstat ssaiexpeffectols if exemptratetile==95 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel E5 = matrix(pctile95), nformat(number_d5)

tabstat ssaiexpeffectols if year==2010 & claimp50sh>.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel E6 = matrix(pctile95), nformat(number_d5)

putexcel E1=("Middle School Social Studies")

clear

//HS Level Impact

use highschoolsols.dta

joinby ncesid using distnetexpeffect2013.dta, unmatched(master)
tab _merge
drop _merge

gen scaiexpeffectols=zscaispcfols*ln(1+netexpeffect1p)

sum scaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==5

sum scaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==50

sum scaiexpeffectols if year==2010 & claimp50sh<.5 & exemptratetile==95

sum scaiexpeffectols if year==2010 & claimp50sh>.5

*------------------------------------------------------------------------------
*Exporting Table 6, Column 6
*------------------------------------------------------------------------------

tabstat scaiexpeffectols if exemptratetile==5 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile5 = r(StatTotal)
putexcel F3 = matrix(pctile5), nformat(number_d5)

tabstat scaiexpeffectols if exemptratetile==50 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile50 = r(StatTotal)
putexcel F4 = matrix(pctile50), nformat(number_d5)

tabstat scaiexpeffectols if exemptratetile==95 & year==2010 & claimp50sh<.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel F5 = matrix(pctile95), nformat(number_d5)

tabstat scaiexpeffectols if year==2010 & claimp50sh>.5, stat(mean) save
matrix pctile95 = r(StatTotal)
putexcel F6 = matrix(pctile95), nformat(number_d5)

putexcel F1=("High School Science")

clear

*------------------------------------------------------------------------------
* Online Appendix
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
/*Table A1: Location of the Median Income
Output includes only income brackets with observations. Ranges with no 
observations were inserted manually.*/
*------------------------------------------------------------------------------

use kyexemptreplicationdata.dta
xtset ncesid year
tab p50loc if hasalldata==1, matcell(freq) matrow(names)

putexcel set combs-foster_kyhex_tables.xlsx, sheet(tableA1) modify

putexcel A1=("Income Bracket") ///
C1=("Number of District-Year Observations with Median Income Bracket") ///
D1=("Percent") E1=("Cum.")

local rows = rowsof(names)
local row = 2
local cum_percent = 0

forvalues i = 1/`rows' {
 
        local val = names[`i',1]
        local val_lab : label (p50loc) `val'
 
        local freq_val = freq[`i',1]
 
        local percent_val = `freq_val'/`r(N)'*100
        local percent_val : display %9.2f `percent_val'
 
        local cum_percent : display %9.2f (`cum_percent' + `percent_val')
 
        putexcel A`row'=("`val_lab'") C`row'=(`freq_val') /// 
		D`row'=(`percent_val') E`row'=(`cum_percent')
        local row = `row' + 1
}

putexcel B`row'=("Total") C`row'=(r(N)) D`row'=(100.00)

putexcel B1=("Bracket Range")
forvalues i = 2/8 {
	putexcel B`i'=("$4,999")
}
putexcel B9=("$9,999")
putexcel B10=("$14,999")
putexcel B11=("$24,999")
putexcel B12=("$24,999")
putexcel B13=("$49,999")

estimates clear
*------------------------------------------------------------------------------
/*First Stage Equation Results from GMM for Online Appendix,
Table B1: First Stage Regression Results from the Current Expenditure 
Analysis, 50% threshold*/
*------------------------------------------------------------------------------

local iv1 lnivtaxableratio1 lntaxableratio1terc ivaidshare1
local iv2 lnivtaxableratio2 lntaxableratio2terc ivaidshare2
local iv3 lnivtaxableratio3 lntaxableratio3terc ivaidshare3
local controls lntaxshare lnrealp50inc pctefrl2 pctsped2 pctlep2 bachplus homeown black lnenrollment lnenrollmentsq youthpct oldhosh disabhosh

foreach y of varlist lntaxableratio1 aidsharestyinger1 { 
xtreg `y' `iv1' `controls' i.year, fe cluster(ncesid)

eststo

}

esttab using firststagespend50thres.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*.year) title("GMM First Stage Results, 50% Threshold") ///
	mtitle("Taxable Share Ratio" "State Aid Share") ///
	coeflabels(lnivtaxableratio1 "IV Taxable Share Ratio" ///
				lntaxableratio1terc "Taxable share ratio tercile rank" ///
				ivaidshare1 "IV state aid share") ///
	scalars("N_clust Clusters" ///
			"r2_w Within R-squared" ///
			"F F-stat" ///
			"p Model P-value") ///
	sfmt(%9.0f %9.3f %9.0f %9.3f) ///
	replace

estimates clear

*------------------------------------------------------------------------------
/*First Stage Equation Results from GMM for Online Appendix,
Table B2: First Stage Regression Results from the Current Expenditure 
Analysis, 40% threshold*/
*------------------------------------------------------------------------------

foreach y of varlist lntaxableratio2 aidsharestyinger2 { 
xtreg `y' `iv1' `controls' i.year, fe cluster(ncesid)

eststo

}

esttab using firststagespend40thres.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*.year) title("GMM First Stage Results, 40% Threshold") ///
	mtitle("Taxable Share Ratio" "State Aid Share") ///
	coeflabels(lnivtaxableratio2 "IV Taxable Share Ratio" ///
				lntaxableratio2terc "Taxable share ratio tercile rank" ///
				ivaidshare2 "IV state aid share") ///
	scalars("N_clust Clusters" ///
			"r2_w Within R-squared" ///
			"F F-stat" ///
			"p Model P-value") ///
	sfmt(%9.0f %9.3f %9.0f %9.3f) ///
	replace

estimates clear

*------------------------------------------------------------------------------
/*First Stage Equation Results from GMM for Online Appendix, 
Table B3: First Stage Regression Results from the Current Expenditure 
Analysis, 30% threshold*/
*------------------------------------------------------------------------------

foreach y of varlist lntaxableratio3 aidsharestyinger3 { 
xtreg `y' `iv1' `controls' i.year, fe cluster(ncesid)

eststo

}

esttab using firststagespend30thres.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*.year) title("GMM First Stage Results, 30% Threshold") ///
	mtitle("Taxable Share Ratio" "State Aid Share") ///
	coeflabels(lnivtaxableratio3 "IV Taxable Share Ratio" ///
				lntaxableratio3terc "Taxable share ratio tercile rank" ///
				ivaidshare3 "IV state aid share") ///
	scalars("N_clust Clusters" ///
			"r2_w Within R-squared" ///
			"F F-stat" ///
			"p Model P-value") ///
	sfmt(%9.0f %9.3f %9.0f %9.3f) ///
	replace

estimates clear
clear

*------------------------------------------------------------------------------
*Appendix C: GMM Results for Achievement Equations
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
*Table C1: GMM First Stage Results, Achievement Equations
*------------------------------------------------------------------------------

foreach d in elemschools midschools highschools {
use ky`d'replication.dta

xtset oaacode year

local controls frp_per_CCD ethb_CCD pctsped2 pctlep2 lnenroll lnenrollsq i.year

xtreg lnrealspendpp lnrealspendppterc lnncntyrealtcurelscpp `controls', fe cluster(oaacode)

eststo m`d'

}

esttab melemschools mmidschools mhighschools using firststageachieve.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*.year) title("GMM First Stage Results, Achievement Equations") ///
	mtitle("Elementary Schools" "Middle Schools" "High Schools") ///
	scalars("N_clust Clusters" ///
			"r2_w Within R-squared" ///
			"F F-stat" ///
			"p Model P-value") ///
	sfmt(%9.0f %9.3f %9.0f %9.3f) ///
	replace

estimates clear

clear

*------------------------------------------------------------------------------
*Tables C2-C4: GMM Results for Elementary-High School Achievement
*------------------------------------------------------------------------------

foreach d in elemschools midschools highschools {
use ky`d'replication.dta

xtset oaacode year

foreach x of varlist maai rdai scai ssai {

by year, sort: egen `x'mean=mean(`x')
by year, sort: egen `x'sd=sd(`x')
gen z`x'=(`x'-`x'mean)/`x'sd
}
local controls frp_per_CCD ethb_CCD pctsped2 pctlep2 lnenroll lnenrollsq _Iyear_2002-_Iyear_2010

foreach y of varlist zmaai zrdai zscai zssai {
xtivreg2 `y' (lnrealspendpp= lnrealspendppterc lnncntyrealtcurelscpp) `controls', fe cluster(oaacode) endog(lnrealspendpp) first gmm2s

eststo m`d'`y'
}
esttab m`d'zmaai m`d'zrdai m`d'zscai m`d'zssai using achievegmm`d'.rtf, b(%9.3f) se(%9.3f) label nonumbers ///
	compress star(* 0.10 ** 0.05 *** 0.01) ///
	drop(_Iyear_*) title("GMM Results, Achievement Equations") ///
	mtitle("Math" "Reading" "Science" "Social Studies") ///
	scalars("N_clust Clusters" ///
			"r2 R-squared" ///
			"idp Underid P-value" ///
			"arfp Endogeneity Test P-value" ///
			"widstat Weak IV F-Stat" /// 
			"jp Hansen P-value") ///
	sfmt(%9.0f %9.3f) ///
	replace

estimates clear

clear

}

*------------------------------------------------------------------------------
*Erasing Data Sets Created by this Do-File
*------------------------------------------------------------------------------

foreach x in elemschoolsols midschoolsols highschoolsols distnetexpeffect2013 {
erase `x'.dta

}

*------------------------------------------------------------------------------
*End of Program
*------------------------------------------------------------------------------
