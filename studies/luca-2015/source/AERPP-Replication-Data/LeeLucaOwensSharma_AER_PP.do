
cd "."

#delimit ;
set more off;
clear all;
set matsize 1000;

capture log close;

*****************************************************************;
* Program: LeeLucaOwensSharma_AER_PP.do;
* Article: "Can Alcohol Prohibition Reduce Violence Against Women?"
* Authors: Lee Luca, Owens, and Sharma
* Journal: American Economic Review, Papers & Proceedings
* Date: March 5, 2015
*****************************************************************;
* Log;
*******************;
log using LeeLucaOwensSharma_AER_PP_Results.txt, text replace;

*****************************************************************;
* Individual Level Data from National Family Household Survey
*******************;

use LeeLucaOwensSharma_AER_PP_NFHSData.dta;

*****************************************************************;
* Set state controls and state by year fixed effects 
*******************;
 
global controls literacy purban pcgdp unemp pcpolice pcpolice_exp pmale health educ ;
egen C=group(State year) ;

*****************************************************************;
* Generate results, using Donald and Lang (2007) two-step correction for
* standard errors 
*******************;

*****************************************************************;
di as text "Table 1 Row 1" ;
*******************;

* 1. year FE ;
eststo: xi: reg husb_drink prohib  i.year $controls [aw=stwt], cluster(State);

* 2. husband controls ;
xi: areg husb_drink husb_age husb_educ husb_wc urban hhsize i.religion [aw=stwt], absorb(C);
predict drink2, dr ;
eststo: xi: reg drink2 prohib $controls i.year [aw=stwt], cluster(State) ;

* 3. add bargaining controls ;
xi: areg husb_drink husb_age husb_educ husb_wc urban hhsize children rep_educ rep_age rep_wc r_* b_unfaithful ownmoney i.religion [aw=stwt], absorb(C) ;
predict drink3, dr ;
eststo: xi: reg drink3 prohib $controls i.year [aw=stwt], cluster(State) ;

* 4. interacted age categories as fixed effects ;
xi: areg husb_drink husb_age husb_educ husb_wc urban hhsize children rep_educ rep_age rep_wc b_unfaithful ownmoney r_* i.husb_age_cat*i.rep_age_cat i.religion [aw=stwt], absorb(C) ;
predict drink4, dr ;
eststo: xi: reg drink4 prohib $controls i.year [aw=stwt], cluster(State) ;

* 5. age gap + education gap as fixed effects ;
xi: areg husb_drink husb_age husb_educ husb_wc urban hhsize children rep_educ rep_age rep_wc b_unfaithful ownmoney i.agegap_cat i.educgap_cat i.religion [aw=stwt], absorb(C) ;
predict drink5, dr ;
eststo: xi: reg drink5 prohib $controls i.year [aw=stwt], cluster(State) ;

*** EDIT by Donna
* esttab using LeeLucaOwensSharma_AER_PP_Table1A.csv, se b(4) se(4) r2(%9.2f) starlevels(* .10 ** .05 *** .01) drop(_I* o.*) replace ;


*****************************************************************;
di as text "Table 1 Row 2" ;
*******************;

eststo clear ;

* 1. year FE ;
eststo: xi: reg husb_beat prohib i.year $controls [aw=stwt], cluster(State) ;

* 2. husband controls ;
xi: areg husb_beat husb_age husb_educ husb_wc urban hhsize i.religion [aw=stwt], absorb(C) ;
predict beat2, dr ;
eststo: xi: reg beat2 prohib $controls i.year [aw=stwt], cluster(State) ;

* 3. add bargaining controls ;
xi: areg husb_beat husb_age husb_educ husb_wc urban hhsize children rep_educ rep_age rep_wc r_* b_unfaithful ownmoney i.religion [aw=stwt], absorb(C) ;
predict beat3, dr ;
eststo: xi: reg beat3 prohib $controls i.year [aw=stwt], cluster(State) ;

* 4. interacted age categories as fixed effects ;
xi: areg husb_beat husb_age husb_educ husb_wc urban hhsize children rep_educ rep_age rep_wc b_unfaithful ownmoney r_* i.husb_age_cat*i.rep_age_cat i.religion [aw=stwt], absorb(C) ;
predict beat4, dr ;
eststo: xi: reg beat4 prohib $controls i.year [aw=stwt], cluster(State) ;

* 5. age gap + education gap as fixed effects ;
xi: areg husb_beat husb_age husb_educ husb_wc urban hhsize children rep_educ rep_age rep_wc b_unfaithful ownmoney i.agegap_cat i.educgap_cat i.religion [aw=stwt], absorb(C) ;
predict beat5, dr ;
eststo: xi: reg beat5 prohib $controls i.year [aw=stwt], cluster(State) ;

*** EDIT by Donna
* esttab using LeeLucaOwensSharma_AER_PP_Table1B.csv, se b(4) se(4) r2(%9.2f) starlevels(* .10 ** .05 *** .01) drop(_I* o.*) replace ;


*****************************************************************;
* State Level Data from Indian Government Records 
*******************;

# delimit ;

use LeeLucaOwensSharma_AER_PP_CrimeData.dta, clear ;

global controls literacy urban pcgdp unemp pcpolice ;

eststo clear ;

xi i.State i.year ;

eststo: reg women_indexnf prohib  _I*  $controls [aw=pop], cluster(State) ;
eststo: reg women_index_f prohib  _I*  $controls [aw=pop], cluster(State) ;
eststo: reg women_index prohib  _I*  $controls [aw=pop], cluster(State) ;
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace ;

***EDIT by Donna

/*
foreach x in women_indexnf r_cruelty r_molestation r_sexualharassment r_rape women_index_f  r_suicides_f r_dowrydeath r_fire_f women_index { ;

	qui eststo:  reg `x' prohib  _I*  $controls [aw=pop], cluster(State) ;
	di "`x'" ;
	bootwildctpopwt prohib  _I* $controls, numvars(1) ;
} ; 
*/

*** EDIT by Donna
* esttab using LeeLucaOwensSharma_AER_PP_Table2.csv, se b(3) se(3) r2(%9.2f) starlevels(* .10 ** .05 *** .01) keep(prohib) replace ;

log close;
