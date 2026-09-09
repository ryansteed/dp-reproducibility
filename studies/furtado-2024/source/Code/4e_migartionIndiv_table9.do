/* This dofile generates individual level data set with the information of each individual's CZ lived 5 years ago, and CZs they are living in when taking the survey, in 1980, 1990, and 2000. The end data set is temp_80_00_cz_5yrsago.dta. */

*Stata version 17

/*******************************************************************************
First generate the 1980 base year CZ level characteristics:
(1) manufacturing employment share (l_shind_manuf_cbp) in 1980 is calculated from the replication data for ADH (2013) provided by Borusyak et al. (2022), the name of the dataset is czone_industry1980.dta. 
(2) persentage of college educated population (l_sh_popedu_c)
(3) persentage of employment among women (l_sh_empl_f) 
*******************************************************************************/
set more off
cd $ResultD
use $OriginalD/80_10_original.dta, clear 
** keep only 1980 data
keep if year == 1980 
** drop two states Alaska and Hawaii, ADH (2013)
drop if statefip == 2 | statefip == 15  
** keep people in working age 18-65
drop if age > 65
drop if age < 18
gen female = (sex == 2) //  =1 if female.
gen edu_c = (educd >= 65) // with at least some college education is defined as high skill in ADH
// convert to CZ from 1980 county groups 
gen ctygrp1980 = cntygp98 + statefip*1000
joinby ctygrp1980 using $OriginalD/cw_ctygrp1980_czone_corr.dta
gen czperwt = perwt * afactor
save 1980_base_cz.dta , replace
 
use 1980_base_cz.dta, clear
keep if female == 1 // female only
gen emp_f = (empstat == 1) // currently employed 
collapse (mean) emp_f [pw = czperwt], by (czone year) // share of currently employed among women.
replace  emp_f = emp_f*100
save 1980_femaleEmpShare.dta, replace

use 1980_base_cz.dta, clear
collapse (mean) edu_c [pw = czperwt], by (czone year)
replace  edu_c = edu_c*100
save 1980_colEduShare.dta, replace

use $OriginalD/czone_industry1980.dta, clear 
bys czone: egen manu_emp = sum(imp_emp)
gen manu_share = manu_emp/tot_emp_cz *100
keep czone manu_share 
duplicates drop 
gen year = 1980
save 1980_manuEmpShare.dta, replace

erase 1980_base_cz.dta

/*******************************************************************************
Generate individual level data with migration histories in the past five years.
*******************************************************************************/
use 1980_cz.dta, clear 
append using 1990_cz.dta
append using 2000_cz.dta
drop puma1990 puma2000
save FBsampleCZ_80base.dta, replace

use $OriginalD/cw_puma1990_czone.dta, clear
gen crosscz = (afactor!=1)
bys puma1990: gen n= _N
replace crosscz=0 if n==1 & crosscz==1
keep crosscz puma1990 
duplicates drop
save crosscz_puma1990, replace

use $OriginalD/cw_puma2000_czone.dta, clear
gen crosscz = (afactor!=1)
bys puma2000: gen n= _N
replace crosscz=0 if n==1 & crosscz==1
keep crosscz puma2000
duplicates drop
save crosscz_puma2000, replace

*********** 1980 data ***********
		use FBsampleCZ_80base.dta, clear 
		/*************
		1. Rename variables 
		*************/
		rename czone current_czone
		rename afactor current_afactor // Rename these because we need to merge with CZ-PUMA crosswalk file(which also has "afactor" variable) in next step, to avoid confusion.
	    keep if year == 1980
		/*************
		2. Get the county group and CZ people lived in five years ago, using David Dorn crosswalk 
		*************/
        drop ctygrp1980
		gen cogrp5yrsago = migcogrp // migcogrp is the county groups of residence 5 years ago
	    drop if migrate5 == 0 // drop those not reported migrate status. (88,164 out of 176043 observations deleted, nearly 50% dropped)
	    drop if migrate5 == 4 // drop those lived abroad 5 years ago. (20,364 observations deleted, nearly 11.5% of 176,043)
	    
		replace cogrp5yrsago = cntygp98 if migcogrp == 999 // (36,641 out of 67,515 nearly 54.3% not moved, county group they lived in 5 years ago is exactly the same county group they are living in in 1980.)
	
		gen migstate5 = migplac5 
		replace migstate5 = statefip if migplac5 == 990 // same house 
		* get the 5-year ago ctygrp1980
		gen ctygrp1980 = cogrp5yrsago + migstate5*1000  // migstate5 reports the state the respondent was living 5 years ago.
        
		save "1980_pastctygp.dta", replace	
		
		joinby ctygrp1980 using $OriginalD/cw_ctygrp1980_czone_corr.dta
		rename ctygrp1980 ctygrp1980_5ago 
		gen ctygrp1980 = cntygp98 + statefip*1000 

		save "1980_cz_baseon5yrago.dta", replace
		
*********** 1990 data ***********

		use "FBsampleCZ", clear 
		/*************
		1. Rename variables 
		*************/
		rename czone current_czone
		rename afactor current_afactor // Rename these because we need to merge with CZ-PUMA crosswalk file(which also has "afactor" variable) in next step, to avoid confusion.
		/*************
		2. Get the PUMA and CZ people lived in five or one year ago, using David Dorn crosswalk 
		*************/
		gen puma5yrsago = migpuma  // migpuma is the PUMA of residence 5 years ago, but if people live in the same house, migpuma=0.
		gen puma1yrsago = migpuma1

        keep if year == 1990  
	    drop if migrate5 == 0 // drop those not reported migrate status, 0 deleted.
	    drop if migrate5 == 4 // drop those lived abroad 5 years ago, 58,773 deleted (nearly 27% of raw data).
		* get the 5-year ago puma
		gen puma1990 = migplac5*10000 + puma5yrsago*100  // migplac5 reports the state the respondent was living 5 years ago. 
		replace puma1990 = statefip*10000 + puma if migrate5==1  // PUMA 5 years ago = current PUMA if lived in the same house
		save "1990_pastpuma.dta", replace
		
		merge m:1 puma1990 using "crosscz_puma1990.dta"  // crosscz_puma1990.dta just shows whether a PUMA1990 is splitted into multiple CZs, this is created based on $OriginalD/cw_puma1990_czone.dta
		drop if _merge == 2
		replace puma1990 = puma1990+1 if _merge == 1  // in 1990, puma only report the left 3 digit indtead of 5 digit, but pumas with the same left 3 digit goes to the same CZ.
		drop _merge crosscz 
		
		joinby puma1990 using $OriginalD/cw_puma1990_czone.dta
		rename puma1990 puma1990_5ago 
		
		gen puma1990 = puma + statefip*10000  // some of the pumas have 4 digits, but they're all in states with one digit, so in the end, puma1990 has up to 6 digits 

		save "1990_cz_baseon5yrago.dta", replace
	
***********  2000 data ***********
		
        use "FBsampleCZ", clear 
		
	    rename czone current_czone
        rename afactor current_afactor // Rename these because we need to merge with CZ-PUMA crosswalk file(which also has "afactor" variable) in next step, to avoid confusion.
		
	    gen puma5yrsago = migpuma 
	    gen puma1yrsago = migpuma1		
				
        keep if year == 2000 
	    drop if migrate5 == 0 // drop those not reported migrate status, 0 deleted.
	    drop if migrate5 == 4 // drop those lived abroad 5 years ago, 100,709 (nearly 22% of all obs) deleted.

		gen puma2000 = migplac5*10000 + puma5yrsago*100  // migplac5 reports the state the respondent was living 5 years ago. I'm not sure why puma5yrs ago must be multiplied by 100, but that's what it looks like in the code.  
		replace puma2000 = statefip*10000 + puma if migrate5==1  // PUMA 5 years ago = current PUMA if lived in the same house
		save "2000_pastpuma.dta", replace
		
		merge m:1 puma2000 using "crosscz_puma2000.dta"
		drop if _merge == 2
		/* In 2000, puma only report the left 3 digit indtead of 5 digit, but most pumas with the same left 3 digit will be matched with the same CZ, except the following 7 codes: 80100 80500 170100 171100 182000 422000 422800. Those codes can be matched with multiple PUMAs, and these PUMAs do not match to the same CZ, so we drop them from analysis, but the obs number is low (645), so, droping them does not hurt our results. */
		drop if puma2000 == 80100 | puma2000 == 80500 | puma2000 ==170100 | puma2000 ==171100 | puma2000 ==182000 | puma2000 ==422000 | puma2000 ==422800  // 287 obs dropped
		replace puma2000 = puma2000+1 if _merge == 1  
		drop _merge crosscz 
		
		joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
		rename puma2000 puma2000_5ago
		
		gen puma2000 = puma + statefip*10000 
		save "2000_cz_baseon5yrago.dta", replace 
	
*********** Create the variable indicating migrated across CZs in the past 5 years ***********
use "1980_cz_baseon5yrago.dta", clear 
append using "1990_cz_baseon5yrago.dta"
append using "2000_cz_baseon5yrago.dta"

rename czone czone5ago
rename current_czone czone

gen czperwtmig = czperwt * afactor 
gen mig = (czone != czone5ago) // if CZ 5 yewars ago is not the same as CZ today, identify as migrated.

drop if migrate5 == 1 & mig==1 // same house means not moving, however, joinby command will create multiple obs with different cz even if they never moved, we need to delete those observations.
save temp_80_00_cz_5yrsago.dta, replace

erase 1980_pastctygp.dta
erase 1990_pastpuma.dta
erase 2000_pastpuma.dta

erase "1980_cz_baseon5yrago.dta"
erase "1990_cz_baseon5yrago.dta"
erase "2000_cz_baseon5yrago.dta"





