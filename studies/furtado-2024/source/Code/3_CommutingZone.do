/*This dofile generates 1990 CZs based on county groups/PUMAs in the raw data, and merge to the 1980, 1990, 2000, 2007 individual level data. The end data set is: FBsampleCZ.dta. */  

* Stata version: 17.0 MP, updated on 2023/04/20

clear
set more off 

cd $wkdir 

** Convert from 1980 county group to 1990 commuting zones, crosswalk obtained from Dorn's website E3 
use $ResultD/FBsample_var.dta, clear 
keep if year == 1980
gen ctygrp1980 = cntygp98 + statefip*1000
joinby ctygrp1980 using $OriginalD/cw_ctygrp1980_czone_corr.dta
gen czperwt = perwt * afactor
save $ResultD/1980_cz.dta, replace

** Convert from 1990 Public Use Micro Areas to 1990 commuting zones, crosswalk obtained from Dorn's website E4
use $ResultD/FBsample_var.dta, clear 
keep if year == 1990 
gen t2 = 0
gen puma1990 = puma + statefip*10000  // in 1990, pumas are coded in 4 digits, so, puma1990 has 5/6 digits.
joinby puma1990 using $OriginalD/cw_puma1990_czone.dta
gen czperwt = perwt * afactor
// "afactor" is from "cw_puma1990_czone.dta", puma1990 will be split into multiple CZs.
save $ResultD/1990_cz.dta, replace

** Convert from 2000 Public Use Micro Areas to 1990 commuting zones, crosswalk obtained from Dorn's website E5
use $ResultD/FBsample_var.dta, clear 
keep if year == 2000
gen t2 = 1
gen puma2000 = puma + statefip*10000
joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
gen czperwt = perwt * afactor
// "afactor" is from "cw_puma2000_czone.dta", puma2000 will be split into multiple CZs.
save $ResultD/2000_cz.dta, replace

** Convert from 2005-2011 ACS Public Use Micro Areas to 1990 commuting zones, crosswalk obtained from Dorn's website E5
use $ResultD/FBsample_var.dta, clear 
keep if year > 2005
gen t2 = 2
gen puma2000 = puma + statefip*10000
/* Due to the effects of Hurricane Katrina, PUMAs 01801, 01802, and 01905 were all 
coded as living in PUMA 77777 from 2006-2011. So they are not matched, but 01801, 01802, and 01905 are all in CZ 3300 */
replace puma2000 = 221801 if puma2000 == 297777
joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
gen czperwt = perwt * afactor
save $ResultD/2007_cz.dta, replace

** Assemble all data with cz information.
append using $ResultD/1990_cz.dta
append using $ResultD/2000_cz.dta
drop puma1990 puma2000
save $ResultD/FBsampleCZ.dta, replace

** obs: 1,007,495
