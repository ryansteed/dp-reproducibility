clear
version 8.0
capture log close
set more off
set mem 60m
set matsize 400

********************************************************************************
**** This file creates Figures 1-4, the main results in Tables 1-2 and 4-7, ****
**** and the non-parametric estimation results discussed in Section IV.C    ****
**** of the paper                                                           ****
********************************************************************************

***********************************************************************************
**** Create Figures 1 and 2 with the results of the calibration and simulation ****
**** from Section II.C of the paper                                            ****
***********************************************************************************
do calibration_simulation/graph_orig_calsim.do

******************************************************************
**** Create the Border - Non-border Graphs in Figures 3 and 4 ****
******************************************************************

do regressions/main_results/subroutines/border_graphs.do

**********************************************************************************
**** Run the code to create matched pairs to be used below in the regressions ****
**** for Table 4 of the paper                                                 ****
**********************************************************************************

do regressions/main_results/subroutines/matching.do

log using regressions/main_results/logs/main_results.log,replace

*************************************
**** Now Create the Main Results ****
**** in Tables 1-2 and 4-7       ****
*************************************

use regressions/main_results/data/RemotenessAER_Main.dta
so city year
tsset city year , generic

merge city using regressions/main_results/temp/matchpairs.dta
so city year
tab _merge
drop _merge

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

*****************************************
**** TABLE 1 : List of Border Cities ****
*****************************************

list cities if bzone==1&year==1939

*******************************
**** TABLE 2: Basic Table ****
*******************************

* Column (1), baseline specification 
eststo all: reg g_pop treat bzone yy* if year<1990&sample==1, cluster(city) 
* outreg bzone treat using regressions/main_results/tables/Table2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) title(Table 2: Baseline Results) replace

* Column (2), time heterogeneity
reg g_pop treat1960 treat1970 treat1980 treat1988 bzone yy* if year<1990&sample==1, cluster(city) 
* outreg bzone treat1960 treat1970 treat1980 treat1988 using regressions/main_results/tables/Table2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (3), distance grid cells specification
reg g_pop treat25 treat2550 treat5075 treat75100 bzone25 bzone2550 bzone5075 bzone75100 yy* if year<1990&sample==1, cluster(city) 
* outreg treat25 treat2550 treat5075 treat75100 bzone25 bzone2550 bzone5075 bzone75100 using regressions/main_results/tables/Table2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (4), run baseline specification for small cities only 
eststo small: reg g_pop treat bzone yy* if year<1990&sample==1&size1919<med_size1919, cluster(city) 
* outreg bzone treat using regressions/main_results/tables/Table2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (5), run baseline specification for large cities only 
reg g_pop treat bzone yy* if year<1990&sample==1&size1919>=med_size1919, cluster(city) 
* outreg bzone treat using regressions/main_results/tables/Table2.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

*** EDITED by Donna, Ryan
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save final.dta, replace
***

*********************************************
**** Table 3: Results of the Grid Search ****
**** ****************************************

**** Created by the do file grid_search/gridsearch_results_table3_figure5.do

****************************
**** TABLE 4 : Matching ****
****************************

* Correlation coefficient between matching variables
pwcorr conpop conemp coniscore conaiscore concaiscore, star(.05)

* Column (1) : Match on population
reg g_pop treat bzone yy* if year<1990&sample==1&(bzone==1|conpop==1), cluster(city) 
* outreg bzone treat using regressions/main_results/tables/Table4.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) title(Table 4: Matching) replace

* Column (2) : Match on employment
reg g_pop treat bzone yy* if year<1990&sample==1&(bzone==1|conemp==1), cluster(city) 
* outreg bzone treat using regressions/main_results/tables/Table4.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (3) : Match on full industry structure
reg g_pop treat bzone yy* if year<1990&sample==1&(bzone==1|conaiscore==1), cluster(city) 
* outreg bzone treat using regressions/main_results/tables/Table4.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (4) : Match on full industry structure, with control 100-175km
reg g_pop treat bzone yy* if year<1990&sample==1&(bzone==1|concaiscore==1), cluster(city) 
* outreg bzone treat using regressions/main_results/tables/Table4.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

**********************************
**** TABLE 5 : War Disruption ****
**********************************

gen temp=pop if year==1939
egen pop1939=max(temp),by(city)
so city year
drop temp

* Cross-section regressions of war disruption on proximity to the border
reg rubble bzone if year==1939&laender_2000~="SL"
reg flats bzone if year==1939&laender_2000~="SL"
reg refugees bzone if year==1939&laender_2000~="SL", robust

* Column (1) : Basic treatment with rubble interacted with year dummies
gen ru=rubble
gen zy=year if year<1990&year~=1950&year~=1919
xi: reg g_pop treat bzone i.zy|ru yy* if year<1990&sample==1, cluster(city) 
* outreg bzone treat ru _IzyXru_1933 _IzyXru_1939 _IzyXru_1960 _IzyXru_1970 _IzyXru_1980 _IzyXru_1988 using regressions/main_results/tables/Table5.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) title(Table 5: War Disruption) replace

* Column (2) : Basic treatment with flats interacted with year dummies
gen fl=flats
xi: reg g_pop treat bzone i.zy|fl yy* if year<1990&sample==1, cluster(city) 
* outreg bzone treat fl _IzyXfl_1933 _IzyXfl_1939 _IzyXfl_1960 _IzyXfl_1970 _IzyXfl_1980 _IzyXfl_1988 using regressions/main_results/tables/Table5.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (3) : Basic treatment with refugees interacted with year dummies 
gen rf=refugees
xi: reg g_pop treat bzone i.zy|rf yy* if year<1990&sample==1, cluster(city) 
* outreg bzone treat rf _IzyXrf_1933 _IzyXrf_1939 _IzyXrf_1960 _IzyXrf_1970 _IzyXrf_1980 _IzyXrf_1988 using regressions/main_results/tables/Table5.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Results discussed in the paper, including refugees and bombing simultaneously
xi: reg g_pop treat bzone i.zy|refugees i.zy|ru yy* if year<1990&sample==1, cluster(city) 
xi: reg g_pop treat bzone i.zy|refugees i.zy|fl yy* if year<1990&sample==1, cluster(city) 

************************************************
**** TABLE 6 : Western European Integration ****
************************************************

* Generate proximity to Western border of West Germany treatment variables

gen fzone=0
replace fzone=1 if dist_fg_border<75

gen ftreat=fzone*division

gen ftreat1960=0
replace ftreat1960=1 if year==1960&fzone==1

gen ftreat1970=0
replace ftreat1970=1 if year==1970&fzone==1

gen ftreat1980=0
replace ftreat1980=1 if year==1980&fzone==1

gen ftreat1987=0
replace ftreat1987=1 if year==1987&fzone==1

gen ftreat1988=0
replace ftreat1988=1 if year==1988&fzone==1

gen fzone25=0
replace fzone25=1 if dist_fg_border<25
gen ftreat25=division*fzone25

gen fzone2550=0
replace fzone2550=1 if dist_fg_border<50&dist_fg_border>=25
gen ftreat2550=division*fzone2550

gen fzone5075=0
replace fzone5075=1 if dist_fg_border<75&dist_fg_border>=50
gen ftreat5075=division*fzone5075

gen fzone75100=0
replace fzone75100=1 if dist_fg_border<100&dist_fg_border>=75
gen ftreat75100=division*fzone75100

gen fzone100150=0
replace fzone100150=1 if dist_fg_border<150&dist_fg_border>=100
gen ftreat100150=division*fzone100150

* Column (1) : 75 km border zone
reg g_pop treat ftreat bzone fzone yy* if year<1990&sample==1, cluster(city) 
* outreg treat ftreat bzone fzone using regressions/main_results/tables/Table6.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) title(Table 6: Western Economic Integration) replace

* Column (2) : distance grid cells 
reg g_pop treat25 treat2550 treat5075 treat75100 ftreat25 ftreat2550 ftreat5075 ftreat75100 fzone25 fzone2550 fzone5075 fzone75100 bzone25 bzone2550 bzone5075 bzone75100 yy* if year<1990&sample==1, cluster(city) 
* outreg treat25 treat2550 treat5075 treat75100 ftreat25 ftreat2550 ftreat5075 ftreat75100 using regressions/main_results/tables/Table6.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

**********************************
**** TABLE 7 : Re-unification ****
**********************************

* Column (1) : baseline specification
reg g_pop treat bzone yy* if year>1950&year~=1992&laender_2000~="SL", cluster(city)
* outreg treat bzone using regressions/main_results/tables/Table7.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) title(Table 7: Re-unification) replace

* Column (2) : 1980s and post-re-unification only
reg g_pop treat bzone yy* if year>1980&year~=1992&laender_2000~="SL", cluster(city)
* outreg treat bzone using regressions/main_results/tables/Table7.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (3) : 1980s and post-re-unification only, small cities
reg g_pop treat bzone yy* if year>1980&year~=1992&laender_2000~="SL"&size1919<med_size1919, cluster(city)
* outreg treat bzone using regressions/main_results/tables/Table7.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

* Column (4) : 1980s and post-re-unification only, large cities
reg g_pop treat bzone yy* if year>1980&year~=1992&laender_2000~="SL"&size1919>=med_size1919, cluster(city)
* outreg treat bzone using regressions/main_results/tables/Table7.out, se coefastr 10pct sigsymb(***,**,*) bdec(3) append

log close

************************************
**** Non-parametric regressions ****
************************************

do regressions/main_results/subroutines/nonparametric_regressions.do

