
version 17
clear all
set more off
timer clear

*** THis master script produces main results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 


*External Packages:
*	- reghdfe version 6.12.2 02Nov2021
*	- ftools version 2.49.0 06may2022
*	- mplotoffset version 1.1.1 14mar2015
*	- grc1leg2 version 1.6 15Jun2021
*	- estout version 3.17  02jun2014 

*ssc install reghdfe, replace
*ssc install ftools, replace
*ssc install mplotoffset, replace
*ssc install estout, replace
* ssc install grc1leg2, replace 

** Need to have $path point to the directory containing this README file

global path "."

** Confirm that the globals for the project root directory and data folder exist
assert !missing("$path")

** Log Session
cap mkdir "$path/logfiles"
cap log close
local datetime : di %tcCCYY.NN.DD!_HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$path/logfiles/log_all_`datetime'.log"
log using "`logfile'"
di "Begin date and time: $S_DATE $S_TIME"

timer on 1

** Directories:
global codedir = "$path/code"
global logdir = "$path/logfiles"
global dtadir = "$path/data/raw"

* Make Subdirectories:
cap mkdir "$path/data/proc"
cap mkdir "$path/results"
cap mkdir "$path/results/figures"
cap mkdir "$path/results/tables"

* Define globals that point to directories to save needed results
global wrkdir "$path/data/proc"
global tabdir "$path/results/tables"
global figdir "$path/results/figures"

*** Process raw datafiles and generate main analysis datasets:

* Generate dataset: proc/individual-analysis.dta
* do "$codedir/01-clean-individual-data.do"

* Generate dataset: proc/aggregate-analysis.dta
*** EDITED by Ryan Steed
/* do "$codedir/02-clean-aggregate-data.do" */
***

* Generate dataset: proc/hps-analysis.dta
do "$codedir/03-clean-hps-data.do"

*** Generate Main Tables and Figures

* Table 1: Unadjusted Differences in Robust U-E Transitions Across Sets of States Ages 25-54, Ages 16-64, and Ages 16 and Over
do "$codedir/04-table-1-ue-transitions.do"

* Table 1: Unadjusted Differences in EPOP and UR Across Sets of States Ages 25-54, Ages 16-64, and Ages 16 and Over
do "$codedir/05-table-1-epop-ur.do"

* Table 2: Effects of Early Expiration of FPUC and PUA or Just FPUC on the Probability of Unemployment to Employment Transitions
do "$codedir/06-table-2.do"

* Table 3: Effects of Early Expiration of FPUC and PUA or Just FPUC on the State Employment Population Ratio and Unemployment Rate
do "$codedir/07-table-3.do"

* Table 4: Effects of Early Expiration of FPUC and PUA or Just FPUC on the Share of HPS Respondents Who Report No Difficulty Paying Expenses in the Past Seven Days
* do "$codedir/08-table-4.do"

* Figure 1: DD Event Studies of Changes in Robust Monthly Transitions into Employment from Unemployment Following the June 2021 Expiration of FPUC and PUA or Only FPUC UI Benefits Extended to September 2021. 
* do "$codedir/09-figure-1.do"


*** Generate datasets of placebo treatment effect estimates:

* Generate dataset: proc/DD-and-DDD-placebos-individual.dta used to make Figures A1 and A2
* do "$codedir/10-placebo-program-individual-data.do"

* Generate proc/DD-and-DDD-placebos-aggregate.dta used to make Figures A3, A4, A5, and A6
* do "$codedir/11-placebo-program-aggregate-data.do"

*** Appendix Tables and Figures:

* Figures A1 and A2
* do "$codedir/12-figures-A1-A2.do" 

* Figures A3, A4, A5, and A6
* do "$codedir/13-figures-A3-A6.do"

* Figure A7
* do "$codedir/14-figure-A7.do"

* Figures A8 and A9
* do "$codedir/15-figures-A8-A9.do" 

* Inputs for counterfactual calculations
* do "$codedir/16-counterfactual-analysis.do" 


timer off 1

timer list 1