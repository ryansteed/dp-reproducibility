/* This dofile prepares data of low-education natives, to create Table 6 enrollment of low-education immigrant VS native. The end data set is Ready4RegressBaseline_natives.dta */

* Stata version 17 

set more off 

cd $wkdir

use $OriginalD/80_10_original.dta, clear 

* Restrict years used 
keep if year == 1980 | year == 1990 | year == 2000 | year == 2006 | year == 2007 | year == 2008

* Drop two states Alaska and Hawaii, just like ADH (2013)
drop if statefip == 2 | statefip == 15  

* keep people in working age
drop if age > 65
drop if age < 18

* keep the native born 
keep if yrimmig == 0 // keep if the individual is not immigrant...ie, nativeborn 

* keep only those have at most a high school degree
drop if educd == 001 // drop if edu info not available
gen edu_non_c = ( educd < 65) // = 0 if at least have some college experience, 1 with no college experience
drop if edu_non_c == 0 // drop if they have college experience
save $ResultD/NBsample.dta, replace

* We use the 2006-2008 3 yeaar sample but call it "2007" so that our programs run 
replace year = 2007 if year > 2005 // we need to conbine 2007-2011 data as the 2010 data

* reweight the 3-year conbined sample.
replace perwt = perwt/3 if year == 2007 //  If we had downloaded the 3-year ACS, this wouldn't have been necessary 

gen female = (sex == 2) //  =1 if female.

** Employment status: whether employed and detailed sector 
gen manu_d = (occ1990 >= 503 & occ1990 <= 889)  // create industrial dummy for individual who works in manufacturing sector
gen ser_d = (occ1990 >= 3 & occ1990 <= 469)  // create industrial dummy for individual who works in service sector including "manage_d" and "sale_d"
gen manage_d = (occ1990 >= 3 & occ1990 <= 200)  // create industrial dummy for individual who works in professional management sector
gen sale_d = (occ1990 >= 203 & occ1990 <= 389)  // create industrial dummy for individual who works in technical sales and administrative support sector
gen farm_d = (occ1990 >= 473 & occ1990 <= 498)  // create industrial dummy for individual who works in farming sector

* If the employment status is NOT employed or N/A, then do not treat them as working in reported industrial sectors.
replace manu_d = 0 if empstatd == 0 | empstatd >= 20
replace ser_d = 0 if empstatd == 0 | empstatd >= 20
replace manage_d = 0 if empstatd == 0 | empstatd >= 20
replace sale_d = 0 if empstatd == 0 | empstatd >= 20
replace farm_d = 0 if empstatd == 0 | empstatd >= 20

gen notemp = (empstatd >= 20 ) // notemp = 1 if not currently employed
gen unemp = (empstatd >= 20 & empstatd < 30) // unemp= 1 if  currently unemployed
gen notlf = (empstatd >= 30) // notemp = 1 if currently not in labor force

** age square
gen agesq = age^2

** age intervals
gen ageintvl_20=( age<30 )
gen ageintvl_30=( age<40 &age>=30)
gen ageintvl_40=( age<50 &age>=40)
gen ageintvl_50=( age>=50)

** high school graduates
gen edu_hs = (educd == 64 | educd == 63 | educd == 62)  if year>1980
replace edu_hs = (educd == 60)  if year == 1980

**Enrolled in school 
gen enroll = (school == 2) // enroll = 1 if in school, = 0 if not in school
replace enroll=. if school==0 | school==9  // make sure enroll ==. if school is missing, changed nothing

** race 
gen race_b = (hispan == 0 & race == 2) // Black not hispanic
gen race_w = (hispan == 0 & race == 1) //  White not hispanic
gen race_a = (race == 4 & hispan == 0 | race == 5 & hispan == 0 | race == 6 & hispan == 0) // Asian
gen race_h = (hispan != 0) // hispanic include mixed race, other race
gen race_an = (race == 3 & hispan == 0) // American Indian 
gen race_m = (hispan == 0 & race == 9 | race == 8 & hispan == 0) // Mixed not hispanic, race = 9 three or more major races, race = 8 two major races
gen race_o = (hispan == 0 & race == 7) // Other not hispanic, race = 7 other race, nec
gen race_all_other = (race_w == 0 & race_b == 0 & race_a == 0 & race_h ==0)

** define different race groups 
gen hetero_race = 0
replace hetero_race = 1 if hispan==0 & race==1 //  white not hispanic
replace hetero_race = 2 if hispan==0 & race==2 // black not hispanic
replace hetero_race = 3 if race ==4  & hispan==0 | race==5 & hispan==0  | race==6 & hispan==0 // Asian
replace hetero_race = 4 if hispan!=0 & race!=8 & race!=9 // hispanic, not mixed races

** marital status
gen mard = (marst == 1) // married, spouse present
gen mard_s = (marst == 2 | marst == 3 | marst == 4 |marst == 5) //married, spouse absent (2), separated (3), divorced (4), widowed (5) 
gen single = (marst == 6) //single

* inflate wage income to 2007.
/*************************************************************************************/
g r_incwage = .
replace r_incwage = incwage * 100/40.7386 if year == 1980 // wage is in 1979 (last year) dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/66.373 if year == 1990 // wage is in 1989 (last year) dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/83.4864 if year == 2000 // wage is in 1990 dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/94.9417 if year == 2006 // wage is in 2005 dollars, inflated to 2007 dollars	
replace r_incwage = incwage * 100/97.5245 if year == 2007 // wage is in 2006 dollars, inflated to 2007 dollars
/*************************************************************************************/

save $ResultD/NBsample.dta, replace 

use $ResultD/NBsample.dta, clear 
gen ctygrp1980 = cntygp98 + statefip*1000
joinby ctygrp1980 using $OriginalD/cw_ctygrp1980_czone_corr.dta
gen czperwt = perwt * afactor
save "1980_cz_nb.dta", replace

use $ResultD/NBsample.dta, clear 
keep if year == 1990 
gen t2 = 0
gen puma1990 = puma + statefip*10000  //some of the pumas have 4 digits, but they're all in states with one digit, so in the end, this thing has 6 digits max
joinby puma1990 using $OriginalD/cw_puma1990_czone.dta
gen czperwt = perwt * afactor
// "afactor" is from "cw_puma1990_czone.dta", puma1990 will be split into multiple CZs.
save "1990_cz_nb.dta", replace

use $ResultD/NBsample.dta, clear 
keep if year == 2000 
gen t2 = 1
gen puma2000 = puma + statefip*10000
joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
gen czperwt = perwt * afactor
// "afactor" is from "cw_puma2000_czone.dta", puma2000 will be split to multiple CZs.
save "2000_cz_nb.dta", replace

use $ResultD/NBsample.dta, clear 
keep if year > 2005
gen t2 = 2
gen puma2000 = puma + statefip*10000
/* Due to the effects of Hurricane Katrina, PUMAs 01801, 01802, and 01905 were all 
coded as living in PUMA 77777 from 2006-2011. So they are not matched, 
but 01801, 01802, and 01905 are all in CZ 3300 */
replace puma2000 = 221801 if puma2000 == 297777
joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
gen czperwt = perwt * afactor
// "afactor" is from "cw_puma2000_czone.dta", puma2000 will be split to multiple CZs.
append using "1990_cz_nb.dta"
append using "2000_cz_nb.dta"
drop puma1990 puma2000
save $ResultD/NBsampleCZ.dta, replace
/*
Now it has 1990 2000 2006-2008 data, person weight and immigrant year modified, 
with CZ information and t2 = 0(year = 1990), 1(year = 2000) and 2(year = 2006-2008).
*/
erase "1980_cz_nb.dta" 
erase "1990_cz_nb.dta" 
erase "2000_cz_nb.dta" 

use $ResultD/NBsampleCZ, clear 
run "collapsedifsNB.do"
save $ResultD/Ready4RegressBaseline_natives, replace 






