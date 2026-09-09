clear
version 8.0
capture log close
set more off
set mem 60m
set matsize 400

log using regressions/robustness/techappendix_robustness/logs/techappendix_other_robustness.log,replace

********************************************************************************
**** This file creates the results for the other robustness tests discussed ****
**** in Section IV.B of the paper and Section C of the web-based            ****
**** technical appendix (except the 2002 sample robustness tests            ****
**** which are contained in 2002_sample_robustness.do)                      ****
********************************************************************************

use regressions/main_results/data/RemotenessAER_Main.dta
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

* Size heterogeneity

egen med_size1919=median(size1919)
so city year

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

*************************************************
**** Reproduce Baseline Results from Table 2 ****
*************************************************

* Column (1) of Table 2
reg g_pop treat bzone yy* if year<1990&sample==1, cluster(city) 

*****************************************************************************
**** Robustness Checks for Table 2 results discussed in Section C of the ****
**** web-based technical appendix                                        ****
*****************************************************************************

* 1) Including laender dummies
areg g_pop treat bzone yy* if year<1990&sample==1, cluster(city) absorb(land)

* 2) Including city fixed effects
areg g_pop treat yy* if year<1990&sample==1, cluster(city) absorb(city)

* 3) Excluding cities on the coast (both in treatment and control group)
gen coast=0
replace coast=1 if dist_coast<15 
list city if dist_coast<15

reg g_pop treat bzone yy* if year<1990&sample==1&coast==0, cluster(city) 

* 4) Excluding one land at a time
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="NW", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="BY", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="NI", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="SH", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="BW", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="RP", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="HE", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="HB", cluster(city)
reg g_pop treat bzone yy* if year<1990&sample==1&laender_2000~="SL"&laender_2000~="HH", cluster(city)

*******************************************************
**** TABLE A1 in the web-based technical appendix: ****
**** Robustness checks to excluding aggregations   **** 
**** and other city boundary changes               ****
*******************************************************

* 5) Robustness to excluding aggregations involving smaller settlements 
* > 10,000 and <20,000 in 1919 in all years of the sample

egen max_aggreg_small=max(aggreg_small),by(city)
so city year

tab cities if max_aggreg_small==1&laender_2000~="SL"

reg g_pop treat bzone yy* if year<1990&sample==1&max_aggreg_small~=1, cluster(city) 
* outreg bzone treat using regressions/robustness/techappendix_robustness/tables/TableA1.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) title(Table A1: Robustness to Excluding Aggregations) replace

* 6) Robustness to excluding all aggregations in all years of the sample

gen aggreg_any=0
replace aggreg_any=1 if aggreg_small==1
replace aggreg_any=1 if aggreg==1

egen max_aggreg_any=max(aggreg_any),by(city)
so city year

tab cities if max_aggreg_any==1&laender_2000~="SL"

reg g_pop treat bzone yy* if year<1990&sample==1&max_aggreg_any~=1, cluster(city)
* outreg bzone treat using regressions/robustness/techappendix_robustness/tables/TableA1.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* 7) Robustness to excluding other city-year boundary changes

reg g_pop treat bzone yy* if year<1990&sample==1&merger~=1, cluster(city) 
* outreg bzone treat using regressions/robustness/techappendix_robustness/tables/TableA1.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

**************************************************************************
**** TABLE A2 in the web-based technical appendix:                    ****
**** Robustness checks examining the correlation between aggregations ****
**** and other city boundary changes and the division treatment       ****
**************************************************************************

* Small aggregations with settlements > 10,000 and < 20,000 in 1919 
reg aggreg_small treat bzone yy* if year<1990&sample==1&year~=1919, cluster(city) 
* outreg bzone treat using regressions/robustness/techappendix_robustness/tables/TableA2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) title(Table A2: Aggregations and the Division Treatment) replace
* Any aggregations
reg aggreg_any treat bzone yy* if year<1990&sample==1&year~=1919, cluster(city) 
* outreg bzone treat using regressions/robustness/techappendix_robustness/tables/TableA2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append
* Other city-year boundary changes
reg merger treat bzone yy* if year<1990&sample==1&year~=1919, cluster(city) 
* outreg bzone treat using regressions/robustness/techappendix_robustness/tables/TableA2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

log close