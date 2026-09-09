/*This dofile makes data sets for Appendix Table A.1.1 and prepare data for Figure A.2.2*/
* Stata version 17

cd $ResultD
set more off
***********************************************
* Appendix Table A.1.1 share of immigrants from different country of origin in our sample
***********************************************
use "FBsample.dta", clear
bysort bpld: gen rawobs = _N // rawobs: the amount of raw observation from each country of origin.
keep bpld rawobs
duplicates drop 
egen tot = sum(rawobs) 
gen rawshare = rawobs/tot *100
gsort -rawobs  // decsending sort
drop if rawobs < 1230  // keep only the top 60 countries, 1230 is the 60th country: Albania, like  Bleakley and Chin (2004).
egen subtot = sum(rawobs)
gen subtot60 =  subtot/tot*100
gen subtotother = 100-subtot60
save $ResultT/AppendixA_1_1, replace


***********************************************
* Appendix Figure A.2.2 Non-Hispanics White Characteristics
***********************************************

********* continent *********
use FBsampleCZ.dta, clear 
keep if hetero_race == 1
* broadly split by their country of origin.
gen continent = " "
replace continent = "North America" if bpl>= 100 & bpl <= 199 // North America
replace continent = "Central and South America" if bpl>= 200 & bpl <= 300 // Central America,  Caribbean , South America
replace continent = "Europe" if bpl>= 400 & bpl <= 499 // Europe
replace continent = "Asia" if bpl>= 500 & bpl <=599 // Asia
replace continent = "Africa" if bpl>= 600 & bpl < 700 // Africa
replace continent = "Oceania" if bpl >= 700 & bpl <= 710 // Australia and New Zealand, pacific island. Oceania
gen pop =1 
collapse (sum)  pop [pw = czperwt], by (year continent)
reshape wide pop, i(continent) j(year)
gen pop = pop1990+ pop2000 + pop2007
egen totalpop=total(pop) 
gen share = round(pop/totalpop,0.0001)
save FigureA_2_2_1_data.dta, replace

********* country of origin *********
cd $ResultD
use FBsampleCZ.dta, clear 
keep if hetero_race == 1
keep if bpl>= 400 & bpl <= 499 // Europe
replace bpld = 46500 if  bpld == 46590 // refine russia/USSR, ns and USSR, ns
gen pop =1 
collapse (sum)  pop [pw = czperwt], by (year bpld)
reshape wide pop, i(bpld) j(year)
foreach i in 1990 2000 2007{
	replace pop`i' = 0 if pop`i' == .
}
gen pop = pop1990+ pop2000 + pop2007
egen totalpop=total(pop) 
gen share = round(pop/totalpop,0.01)
save FigureA_2_2_2_data.dta, replace
