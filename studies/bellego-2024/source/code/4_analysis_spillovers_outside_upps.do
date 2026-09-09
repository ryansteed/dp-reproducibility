clear all
set max_memory 30g
set matsize 11000
set more off

*** EDIT by Donna
do 0_macro_libraries.do
*** ----------------------------------------------------------------------------
*** BUILD DATASET FOR GEOGRAPHICAL SPILLOVERS ----------------------------------
***-----------------------------------------------------------------------------

tempfile a b
* Import "average" number of individuals living in Rio at a given range distance from DPs
import delimited $spillover/Traitement_Denominateur_Spillovers.csv, clear
forv j=1/90 {
	rename denominateur_`=(`j'-1)*100'`=`j'*100' d_rio_`=(`j'-1)*100'_`=`j'*100' 
}
save `a', replace
* Import "average" number of individuals living each month in pacified favelas at a given range distance from DPs
import delimited $spillover/Traitement_Numerateur_Spillovers.csv, clear
forv j=1/90 {
	rename numerateur_`=(`j'-1)*100'`=`j'*100'    n_`=(`j'-1)*100'_`=`j'*100' 
}
merge m:1 dp using `a', nogen 
save `a', replace 
* Add crime data of the DP (without crimes in UPPs)
import delimited $spillover/CrimeDP_without_UPP.csv, clear
save `b', replace
use `a', clear
merge 1:1 dp date using `b', nogen
save `a', replace 

* Add population living in the DPs (but not in UPPs)
import delimited $spillover/pop_dp_no_upp.csv, clear
rename pop population
save `b', replace
use `a', clear
merge m:1 dp using `b', nogen


* Program to estimate the treatment variable on a given range distance [i;j]
cap prog drop gentreat_rio
program gentreat_rio 
	args i j
	tempvar num denum
	cap drop t_`i'_`j'
	qui egen `num'   =rowtotal(n_`i'_`=`i'+100'-n_`=`j'-100'_`j') 
	qui egen `denum' =rowtotal(d_rio_`i'_`=`i'+100'-d_rio_`=`j'-100'_`j')  
	gen t_`i'_`j'=`num'/`denum'
end

* Generate treatment variables used in the regression
gentreat_rio 0 3000
gentreat_rio 3000 6000
gentreat_rio 6000 9000

* Generate crime variables used in the analysis
* Warning: variable "armarrest", "occurrenceswithflagrante" and "compliancewarrantofarrest" does not exist in the DP data, contrary to the UPP data
gen policeaction= drugarrest  + carrecovery
* Violence from Police
gen policekill=resistancetodeathofpolic
* Murder 
gen murder =  homicideintentional + bodyinjurydeathfollowed + robberydeathfollowed
* Violence without killing
gen violencenokill = bodyinjuryintentional + attemptedmurder
* Extortion
gen totalextortion= extortion + extortionwithkidnap + extortionwithmomentarykidnapping 
* Accident
gen accident=homicidenointentional + bodyinjurynointentional 
* Shorten the name of some variables
rename robberywithdrivingtotakeoutinatm atmdriverobbery
rename extortionwithkidnapping extortionwithkidnap
rename extortionwithmomentarykidnapping extortwithmomentarykidnap
rename resistancetodeathofpoliceopponen resistancetodeathofpolic
* Total events
gen totevent = eventsregistration

*** Set the panel
egen id_dp = group(dp)
xtset id_dp date

*** Linear timetrend specific to each DP
qui unique(id_dp)
forv j=1/`r(unique)' {
	gen dp_`j'=(id_dp==`j')
	gen dp_timetrend`j' = dp_`j'*date
	drop dp_`j'
}

*** Generate log of crime percentage
rename population populationdp_not_in_upp
foreach v of varlist homicideintentional-eventsregistration  policeaction policekill murder violencenokill totalextortion accident totevent {
	gen `v'_cap=`v'
	replace `v'_cap=0 if `v'<0
	gen p_`v' = `v' / populationdp_not_in_upp
	gen p_`v'_cap = `v'_cap / populationdp_not_in_upp
	gen ln1_p_`v'=log((`v'_cap+1) / populationdp_not_in_upp)
	gen ln2_p_`v'=log((`v'_cap+0.5) / populationdp_not_in_upp)
	gen ln3_p_`v'=log((`v'_cap+0.25) / populationdp_not_in_upp)
}


*** ----------------------------------------------------------------------------
*** RESULTS: GEOGRAPHICAL SPILLOVERS *** ---------------------------------------
***-----------------------------------------------------------------------------

*** TABLE 8 *** ----------------------------------------------------------------
eststo clear
foreach v of varlist murder violencenokill rape totalrobbery totaltheft {
		eststo: quietly xtreg ln2_p_`v' t_0_3000 t_3000_6000 t_6000_9000  i.date dp_timetrend* if dp!="1", fe vce(cluster dp) 	
}
esttab , nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(t_* ) replace
esttab using $results/table8.rtf, nolabel star(* 0.10 ** 0.05 *** 0.01) stats(N r2_o r2_w r2_b) se notes keep(t_* ) replace

