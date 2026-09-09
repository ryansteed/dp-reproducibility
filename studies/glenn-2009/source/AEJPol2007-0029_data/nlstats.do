/***************************************************************************/
/*****                                                                 *****/
/*****                         NLSTATS                                 *****/
/*****                                                                 *****/
/***************************************************************************/

/* computes summary statistics for the data used in the discrete choice    */
/* model of demand                                                         */
/* this program runs under stata version 8.0                               */

set matsize 800
set mem 800m
set maxvar 32000

cd c:/research/tax/aejfinal
capture clear
program drop _all

set more off

capture log close
log using nlstats.log, replace

use nldata1280.dta

for num 1/24: gen dtaxX=homeX*priceX*tax
egen mhome=rmean(home1-home24)
egen mprox=rmean(prox1-prox24)
egen mdtax=rmean(dtax1-dtax24)
sum norder cprice price1 crank mhome chome mprox cprox mdtax if postal~="CA" 
clear

use nldata1283.dta

for num 1/24: gen dtaxX=homeX*priceX*tax
egen mhome=rmean(home1-home24)
egen mprox=rmean(prox1-prox24)
egen mdtax=rmean(dtax1-dtax24)
sum norder cprice price1 crank mhome chome mprox cprox mdtax if postal~="CA" 
clear

use nldata2560.dta

for num 1/12: gen dtaxX=homeX*priceX*tax
egen mhome=rmean(home1-home12)
egen mprox=rmean(prox1-prox12)
egen mdtax=rmean(dtax1-dtax12)
sum norder cprice price1 crank mhome chome mprox cprox mdtax if postal~="CA" 
clear

use nldata2563.dta

for num 1/12: gen dtaxX=homeX*priceX*tax
egen mhome=rmean(home1-home12)
egen mprox=rmean(prox1-prox12)
egen mdtax=rmean(dtax1-dtax12)
sum norder cprice price1 crank mhome chome mprox cprox mdtax if postal~="CA" 
clear


log close



