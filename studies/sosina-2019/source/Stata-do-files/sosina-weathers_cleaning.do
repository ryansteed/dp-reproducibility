********************************************************************************
* pathways to inequality: creating composite datasets
* Victoria Sosina (vsosina@stanford.edu)
********************************************************************************

* preliminaries
capture log close
macro drop _all

version 13
clear all
set linesize 82
set more off, perm

********************************************************************************
*SET DATES AND DIRECTORIES
********************************************************************************
/*Creating a program to set the date and directory allows me to drop macros in 
each do file while still preserving the date and directory path in a macro. */

*program for setting the date
capture program drop setdate
	program define setdate
	
	global date "190625"

	end

*program for setting the directory
capture program drop setdirectory
	program define setdirectory
	
	global curdir `c(pwd)'
	cd "$curdir"

	end

*run date and directory program
setdate
setdirectory

********************************************************************************
*MAKE DIRECTORIES
********************************************************************************
cap mkdir "${curdir}/Logs/"	
cap mkdir "${curdir}/Derived/"	
cap mkdir "${curdir}/Results/"	
cap mkdir "${curdir}/Results/Estimates"	

********************************************************************************
*STEP #1: CLEAN FISCAL DATA
********************************************************************************
	do "cleaning-do-files/1-rutgers_${date}.do"

********************************************************************************
*STEP #2: PREPARE CCD SCHOOL LEVEL ENROLLMENT FILE
********************************************************************************
	do "cleaning-do-files/2-ccd-imputed_${date}.do"
	
********************************************************************************
*STEP #3: PREPARE CCD DISTRICT LEVEL FILE
********************************************************************************
	do "cleaning-do-files/3-ccd-lea_${date}.do"

********************************************************************************
*STEP #4: PREPARE CWI FILES
********************************************************************************
	do "cleaning-do-files/4-cwi_${date}.do"
	
********************************************************************************
*STEP #5: MERGE DATA FILES
********************************************************************************
	do "cleaning-do-files/5-merge_${date}.do"	

********************************************************************************
*STEP #6: CONTRUCT MEASURES
********************************************************************************
	do "cleaning-do-files/6-construct-measures_${date}.do"	

********************************************************************************
*STEP #7: CONTRUCT MEASURES FOR STATE LEVEL ANALYTICAL FILES
********************************************************************************
	*main file
	use "Derived/15_year_sample_district_${date}", clear
	do "cleaning-do-files/7-construct-measures-state_${date}.do"	
	save "Derived/15_year_sample_state_${date}", replace
	
	*robustness checks files
	use "Derived/15_year_sample_district_NO-ELL-SPECED-OUT${date}", clear
	do "cleaning-do-files/7-construct-measures-state_${date}.do"	
	save "Derived/15_year_sample_state_NO-ELL-SPECED-OUT${date}", replace
	
	*no cwi adjustment
	use "Derived/15_year_sample_district_${date}", clear
	do "cleaning-do-files/7-construct-measures-state_no-cwi_${date}.do"	
	save "Derived/15_year_sample_state_no-cwi_${date}", replace
	//search for /!!!/ to see how this file is different from the main file
	//propotion variables are still cwi adjusted
	
********************************************************************************
*END MATTER
********************************************************************************

rm "Derived/1-rutgers_190625.dta"
rm "Derived/2-ccd-imputed_190625.dta"
rm "Derived/3-clean_ccd-lea_190625.dta"
rm "Derived/4-cwi_dis_190625.dta"
rm "Derived/4-cwi_state_190625.dta"
rm "Derived/5-merge_190625.dta"
rm "Derived/15_year_sample_district_190625.dta"
rm "Derived/15_year_sample_district_NO-ELL-SPECED-OUT190625.dta"
rm "Derived/15_year_sample_state_NO-ELL-SPECED-OUT190625.dta"
rm "Derived/temp.dta"

rm "Results/districts-by-size_190625.xls"
rm "Results/rev-exp-outlier-agreement_190625.xls"
