/*********************************************************************************/
/****                             STREGS                                      ****/
/*********************************************************************************/

/* This program analyzes data on aggregate sales by state, computing summary     */
/* statistics and estimating the two negative binomial regressions in the paper. */
/* Aggregate sales data are in streg128.dta and streg256.dta.  State-level       */
/* covariates are in StateChar.csv and stlevel3.dta.                             */
/* Runs under Stata version 7.0.                                                 */

*** EDITED by: Ryan Steed
version 8
***

cd "."

capture clear

set more off

capture log close
clear

log using stregs.log, replace

insheet using StateChar.csv
sort postal
save StateChar.dta, replace
clear

insheet using stlevel3.txt
sort postal
save stlevel3.dta, replace


use streg128_new.dta


sum torder to2050 to100p

reg lq lpop00 homeintf salestax cpergas calif shiptime
eststo: nbreg torder lpop00 homeintf salestax cpergas calif shiptime

nbreg to2050 lpop00 homeintf salestax cpergas calif shiptime
nbreg to100p lpop00 homeintf salestax cpergas calif shiptime

drop _merge
sort postal
merge postal using StateChar.dta
tab _merge

/* merging in the new state-level variables */
drop _merge
sort postal
merge postal using stlevel3.dta


replace hhi99=hhi99/1000
replace ba=ba/100
replace grad=grad/100
replace comp=comp/100
sum salestax homeintf cpergas lpop00 hhi99 ba grad comp calif shiptime unemp whiteperc blackperc medage
corr salestax homeintf cpergas lpop00 hhi99 ba grad comp unemp whiteperc blackperc medage

eststo: nbreg torder lpop00 homeintf salestax cpergas calif shiptime hhi99 ba grad comp 

estout using "../../results/table128.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace


clear

use streg256_new.dta

sum torder to2050 to100p

reg lq lpop00 homeintf salestax cpergas calif shiptime
eststo: nbreg torder lpop00 homeintf salestax cpergas calif shiptime

nbreg to2050 lpop00 homeintf salestax cpergas calif shiptime
nbreg to100p lpop00 homeintf salestax cpergas calif shiptime

drop _merge
sort postal
merge postal using StateChar.dta
tab _merge

/* merging in the new state-level variables */
drop _merge
sort postal
merge postal using stlevel3.dta

replace hhi99=hhi99/1000
replace ba=ba/100
replace grad=grad/100
replace comp=comp/100
sum salestax homeintf cpergas lpop00 hhi99 ba grad comp calif shiptime
corr salestax homeintf cpergas lpop00 hhi99 ba grad comp

eststo: nbreg torder lpop00 homeintf salestax cpergas calif shiptime hhi99 ba grad comp 

estout using "../../results/table256.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
log close


