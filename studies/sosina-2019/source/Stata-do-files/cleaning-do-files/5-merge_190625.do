
capture log close
macro drop _all
setdate
setdirectory

log using "Logs/5-merge_${date}", replace text
********************************************************************************
*merge_$date: merge data files
*Victoria Sosina (vsosina@stanford.edu)
di "Date: $date"
********************************************************************************
/*Merge ccd imputed dataset, ccd lea msc, and Rutgers fiscal dataset*/
********************************************************************************

version 13
set linesize 82
set more off, perm

********************************************************************************
*MERGE
********************************************************************************
*(1) merge rutgers using ccd imputed
use "Derived/1-rutgers_${date}.dta", clear

merge 1:1 leaid year using "Derived/2-ccd-imputed_${date}.dta", ///
	gen(merge_rutimp)

*(2) merge rutgers/ccd imputed using ccd lea
merge 1:1 leaid year using "Derived/3-clean_ccd-lea_${date}.dta", ///
	gen(merge_rutimpccd)
//the only obs in  using and not in rutgers/ccd impute is nyc spec schs

	*drop nyc spec schs
	drop if merge_rutimpccd == 2

preserve
	*(3) merge rutgers/ccd imputed/ccd lea using DISTRICT cwi
	merge 1:1 leaid year using "Derived/4-cwi_dis_${date}.dta", ///
		gen(cwi_nomatch)
	recode cwi_nomatch (3=0) (1=1) (2=1)
	_strip_labels cwi_nomatch	//take away the _merge labels
	//if not matched, this indicator will have a value of 1

	*check cwi
	su rut_cwi cwi_ecwi_D if year >= 1999 & year <= 2013
	gen diff = rut_cwi - cwi_ecwi_D 
	su diff, d
	//all the differences are effectively zero, though the # of obs differs

	drop diff
	
restore

*(4) merge rutgers/ccd imputed/ccd lea using STATE cwi
	
	*create fipst for matching
	gen fipst = imp_fips
	gen fipst2 = substr(leaid,1,2) if missing(imp_fips)	//for those not in ccd
	destring fipst2, replace
	su fipst if !missing(fipst2)
	su fipst2 if !missing(fipst)
	replace fipst = fipst2 if missing(fipst)
	drop fipst2
	
	*conduct merge using STATE cwi
	merge m:1 fipst year using "Derived/4-cwi_state_${date}.dta"
	tab year if _merge==1
	tab fipst if year >=1997 & year <= 2014 & _merge==1
	//only ones in master not matched are from non-states

	drop fipst _merge
	//don't need the merge b/c all states match an obs and not using dis cwi

********************************************************************************
*CLEAN UP MERGE - LABEL
********************************************************************************
tab year merge_rutimp

*drop years where there is no Rutgers/CCD imputed data
drop if year<=1991
drop if year==2016

*new value labels for _merge
label def merge_rutimp 	1 "1. rutgers only" ///
						2 "2. ccd imputed only" ///
						3 "3. matched"
label values merge_rutimp merge_rutimp
label variable merge_rutimp "Result of merging Rutgers using CCD imp"

tab year merge_rutimp

*new value labels for Rutgers/CCD imputed/CCD LEA merge
label def merge_rutimpccd 	1 "1. rutgers/ccd imp only" ///
							2 "2. ccd lea only" ///
							3 "3. matched"
label values merge_rutimpccd merge_rutimpccd

label variable merge_rutimpccd "Result of merging Rutgers/CCD imp using CCD LEA"


********************************************************************************
*CHECK MERGE - DROP INDICATORS FOR RUT & CCD IMP MERGE
********************************************************************************

*explore merge using sample restriction indicators - rut & ccd imp
*create master Drop indicator
gen Drop = 0
foreach v of var drop_*{
	local lab: variable label `v'
	di _n
	di "******************"
	di "`v'" _col(20) "`lab'"
	tab `v' merge_rutimp , missing
	
	replace Drop = 1 if `v'==1
}

	*update Drop indicator to take into consideration fiscal year
	replace Drop = 1 if year < 1995
	label variable Drop "Drop from analytical sample"
	
	/*Drop indicator now takes into consideration: 
		*voc/spec
		*ESA
		*jj
		*noop
		*charter district
		*not a state
		*fiscal year (1995 through 2015)
	*/

*check merge against Drop indicator*********************************************
*unmerged observations not in Drop indicator
tab Drop merge_rutimp

tabstat merge_rutimp, by(year) statistics(count), ///
	if Drop == 0 & merge_rutimp == 1

mdesc rut_member if Drop == 0 & merge_rutimp == 1
mdesc exp_totexp rev_totalrev if Drop == 0 & merge_rutimp == 1 & missing(rut_member)
mdesc exp_totexp rev_totalrev if Drop == 0 & merge_rutimp == 1

bys year: tab Drop merge_rutimp
tabstat merge_rutimp, by(year) statistics(count), ///
	if Drop == 0 & merge_rutimp == 1 & year>=1999 & year <= 2014 & ///
		!missing(rut_member)

gsort -rut_member
order rut_member rut_perwhite rut_tottch_ccdlea
br if Drop == 0 & merge_rutimp == 1 & year>=1999 & year <= 2014 & ///
	!missing(rut_member)

mdesc rut_member rut_perwhite rut_tottch_ccdlea ///
	if Drop == 0 & merge_rutimp == 1 & year>=1999 & year <= 2014 & ///
	!missing(rut_member)

********************************************************************************
*CHECK MERGE - DROP INDICATORS FOR RUT & CCD IMP MERGE
********************************************************************************

*Explore merge using sample restriction indicators
tab merge_rutimpccd Drop

bys year: tab Drop merge_rutimpccd

********************************************************************************
*CHECK COMPARABILITY BETWEEN DATASETS
********************************************************************************

*check local variable in rutgers and ccd lea
tab rut_ulocal ulocal_ccd, missing
tab year Drop if missing(ulocal_ccd) & !missing(rut_ulocal), missing

*keep ccd lea versions and not the rutgers version
rename msc_ccd 		ccd_msc
rename ulocal_ccd 	ccd_ulocal
rename local_ccd 	ccd_local

drop rut_ulocal

********************************************************************************
*SAVE
********************************************************************************

save "Derived/5-merge_${date}.dta", replace

********************************************************************************
*END MATTER
********************************************************************************

capture log close
