clear
version 8.0
capture log close
set more off
set mem 60m
set matsize 400

*********************************************************************
**** This file generates the results for the robustness test     ****
**** based on a sample containing all cities with populations    ****
**** greater than 50,000 in 2002 discussed in Section IV.B of    ****
**** the paper and Section C of the web-based technical appendix ****                              ****
*********************************************************************

log using regressions/robustness/techappendix_robustness/logs/2002_sample_robustness.log,replace

use regressions/robustness/techappendix_robustness/data/RemotenessAER_Robustness_2002sample.dta
so city year

******************************************
**** Time and Laender (state) Dummies ****
******************************************

quietly tab year, gen(yy)
encode laender_2000, gen(land)

******************************************
**** Create Annual Growth Rates Rates ****
******************************************

sort city year
quietly by city: gen lagyear=year[_n-1]
quietly by city: gen length=year-lagyear

quietly by city: gen lagpop=pop[_n-1]
gen g_pop=((pop/lagpop)^(1/length)-1)*100

gen lpop=ln(pop)
quietly by city: gen laglpop=lpop[_n-1]

***************************************************
**** Define sample for year growth regressions ****
***************************************************

gen sample=1
* Exclude the WW2 difference 1939-50 and the difference 1988-92
replace sample=0 if year==1950|year==1992
* Exclude the Saarland cities
replace sample=0 if laender_2000=="SL"

************************************
**** Create Treatment Variables ****
************************************

gen division=0
replace division=1 if year>1939&year<1990

gen bzone=0
replace bzone=1 if dist_gg_border<75

gen treat=bzone*division

* Time grids

gen treat1950=0
replace treat1950=1 if year==1950&bzone==1

gen treat1960=0
replace treat1960=1 if year==1960&bzone==1

gen treat1970=0
replace treat1970=1 if year==1970&bzone==1

gen treat1980=0
replace treat1980=1 if year==1980&bzone==1

gen treat1988=0
replace treat1988=1 if year==1988&bzone==1

* Distance grids

gen bzone25=0
replace bzone25=1 if dist_gg_border<25
gen treat25=division*bzone25

gen bzone2550=0
replace bzone2550=1 if dist_gg_border<50&dist_gg_border>=25
gen treat2550=division*bzone2550

gen bzone5075=0
replace bzone5075=1 if dist_gg_border<75&dist_gg_border>=50
gen treat5075=division*bzone5075

gen bzone75100=0
replace bzone75100=1 if dist_gg_border<100&dist_gg_border>=75
gen treat75100=division*bzone75100

*******************************************************************************
**** Robustness to Alternative Sample based on population > 50,000 in 2002 ****
*******************************************************************************

* Column (1), baseline specification
reg g_pop treat bzone yy* if year<1990&sample==1, cluster(city) 

log close


