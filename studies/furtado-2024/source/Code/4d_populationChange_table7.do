/* This dofile creates year-CZ level data for low-education immigrants from English and non-English speaking countries, including pre-period population change variables, to create Table 7 population change. The end data sets are:
(1) Ready4Regress_AllNEngImm.dta 
(2) Ready4Regress_oldEngImm.dta */

set more off 
cd $wkdir 
use $OriginalD/80_10_original.dta, clear 
** Years used 
keep if year == 1980 | year == 1990 | year == 2000 | year == 2006 | year == 2007 | year == 2008

** drop two states Alaska and Hawaii, just like ADH (2013)
drop if statefip == 2 | statefip == 15  

** keep people in working age
drop if age > 65
drop if age < 18

/* Drop those that arrived before age 18
yrimmig in different year reports different intervals, I take the average of the start 
and end year of each interval, refer to Arturo Gonzalez 2003.
*/
gen yrimmig_new = yrimmig 
replace yrimmig_new = 1945 if yrimmig == 1949 & year ==1980
replace yrimmig_new = 1954.5 if yrimmig == 1959 & year ==1980
replace yrimmig_new = 1962 if yrimmig == 1964 & year ==1980
replace yrimmig_new = 1967 if yrimmig == 1969 & year ==1980
replace yrimmig_new = 1972 if yrimmig == 1974 & year ==1980
replace yrimmig_new = 1977.5 if yrimmig == 1980 & year ==1980
* in 1990 the interval changed 
replace yrimmig_new = 1945 if yrimmig == 1949 & year ==1990
replace yrimmig_new = 1954.5 if yrimmig == 1959 & year ==1990
replace yrimmig_new = 1962 if yrimmig == 1964 & year ==1990
replace yrimmig_new = 1967 if yrimmig == 1969 & year ==1990
replace yrimmig_new = 1972 if yrimmig == 1974 & year ==1990
replace yrimmig_new = 1977 if yrimmig == 1979 & year ==1990
replace yrimmig_new = 1980.5 if yrimmig == 1981 & year ==1990
replace yrimmig_new = 1983 if yrimmig == 1984 & year ==1990
replace yrimmig_new = 1985.5 if yrimmig == 1986 & year ==1990
replace yrimmig_new = 1988.5 if yrimmig == 1990 & year ==1990

** for immigrants, define their age at arrivle
gen yrsusa = year - yrimmig_new // years in the USA.
gen arv_age = age - yrsusa // age on arrival.
replace arv_age = . if yrimmig_new==0
replace arv_age = 0 if arv_age < 0

** define those who arrived young (under the age of 18)
gen young_arv = . 
replace young_arv = 1 if arv_age < 18 & arv_age!=. 
replace young_arv = 0 if arv_age >= 18 & arv_age!=. 

** keep those only have at most a high school degree
drop if educd == 001 // drop if edu info not available
gen edu_non_c = ( educd < 65) // = 0 if at least have some college experience, 1 with no college experience
drop if edu_non_c == 0 // drop if they have college experience

** identify those from non-English speaking countries, not speaking English only, and have English ability data

** define immirants from non-English speaking countries
merge m:1 bpld using $OriginalD/non_eng_cnty.dta //identify those immigrants from non-English speaking countries. (88,994 observations deleted)
gen non_eng_immig= .
replace non_eng_immig = 1 if _merge == 3 //  immigrants from non-English speaking countries.
replace non_eng_immig = 0 if _merge != 3 & yrimmig_new!=0 //  immigrants from English speaking countries.
drop _merge

** define those native speaker
gen ntv_spkr = (speakeng==3) // =1 if speak English only

save $ResultD/Allsample.dta, replace


use $ResultD/Allsample.dta, clear 
replace year = 2007 if year > 2005 // we conbine 2006-2008 data as the 2007 data
** reweight the 3-year conbined sample.
replace perwt = perwt/3 if year == 2007 //  If we had downloaded the 3-year ACS, this wouldn't have been necessary 

** generate language variables 
gen goodeng = (speakeng == 4) // =1 if speaks English very well.
gen goodeng_altr1 = (speakeng == 4 | speakeng == 5) // =1 speak well
gen goodeng_altr2 = (speakeng == 4 | speakeng == 5 | speakeng == 6) // =1 speak English
gen female = (sex == 2) //  =1 if female.

** generate occupation/employment variables 
gen manu_d = (occ1990 >= 503 & occ1990 <= 889)  // create industrial dummy for individual who works in manufacturing sector
gen ser_d = (occ1990 >= 3 & occ1990 <= 469)  // create industrial dummy for individual who works in service sector
gen manage_d = (occ1990 >= 3 & occ1990 <= 200)  // create industrial dummy for individual who works in professional management sector
gen sale_d = (occ1990 >= 203 & occ1990 <= 389)  // create industrial dummy for individual who works in technical sales and administrative support  sector
gen farm_d = (occ1990 >= 473 & occ1990 <= 498)  // create industrial dummy for individual who works in farming sector
gen trans_d = (occ1990 >= 701 & occ1990 <= 889)  // create industrial dummy for individual who works in transport and material moving sector

* If the employment status is NOT employed or N/A, then do not treat them as working in manufacturing or service sector. updated 2023/08/28
replace manu_d = 0 if empstatd == 0 | empstatd >= 20
replace ser_d = 0 if empstatd == 0 | empstatd >= 20
replace manage_d = 0 if empstatd == 0 | empstatd >= 20
replace sale_d = 0 if empstatd == 0 | empstatd >= 20
replace farm_d = 0 if empstatd == 0 | empstatd >= 20
replace trans_d = 0 if empstatd == 0 | empstatd >= 20

gen notemp = (empstatd >= 20 )
gen unemp = (empstatd >= 20 & empstatd < 30) // unemp= 1 if  currently unemployed, update: 2022 Dec 4
gen notlf = (empstatd >= 30) // notemp = 1 if  currently not in labor force, update: 2022 Dec 4

** years in US square
gen yrsusasq = yrsusa^2

** years in US interval, generate 2 bins: > or < 10 years
gen yrusintvl_2bin_10 = (yrsusa<=10)

** generate variables in multiple year bins
gen yrusintvl_1 = (yrsusa<=3)
gen yrusintvl_5= (yrsusa>3 & yrsusa<=5)
gen yrusintvl_7=( yrsusa>5 & yrsusa<=8)
gen yrusintvl_9=( yrsusa>8 & yrsusa<=10)
gen yrusintvl_10plus =( yrsusa> 10 )

** age square
gen agesq = age^2

** age interval, generate 2 bins: > or < age 40 
gen ageintvl_2bin_40 = ( age<=40 )

** age variables in multiple age bins (width of 10)
gen ageintvl_20=( age<30 )
gen ageintvl_30=( age<40 &age>=30)
gen ageintvl_40=( age<50 &age>=40)
gen ageintvl_50=( age>=50)

** age at arrival interval
gen arv_age_20 =(arv_age<30)
gen arv_age_30 =(arv_age<40 & arv_age >=30)
gen arv_age_40 =(arv_age<50 & arv_age >=40)
gen arv_age_50 =(arv_age<60 & arv_age >=50)
gen arv_age_60 =(arv_age>=60)

** high school graduates
gen edu_hs = (educd == 64 | educd == 63 | educd == 62)  if year>1980
replace edu_hs = (educd == 60)  if year == 1980

**Enrolled in school 

gen enroll = (school == 2) // enroll = 1 if in school, = 0 if not in school
replace enroll=. if school==0 | school==9  //none should drop out since universe is anyone above the age of 3

** Ethnic groups
gen race_w = (hispan == 0 & race == 1) //  White not hispanic
gen race_b = (hispan == 0 & race == 2) // Black not hispanic
gen race_a = (race == 4 & hispan == 0 | race == 5 & hispan == 0 | race == 6 & hispan == 0) // Asian
gen race_an = (race == 3 & hispan == 0) // American Indian 
gen race_m = (hispan == 0 & race == 9 | race == 8 & hispan == 0) // Mixed not hispanic, race = 9 three or more major races, race = 8 two major races
gen race_o = (hispan == 0 & race == 7) // Other not hispanic, race = 7 other race, nec
gen race_h = (hispan != 0) // hispanic include mixed race, other race
gen race_all_other = (race_w == 0 & race_b == 0 & race_a == 0 & race_h ==0)

** calculate the CZ population of different race groups 
gen hetero_race = 0
replace hetero_race = 1 if hispan==0 & race==1 //  white not hispanic
replace hetero_race = 2 if hispan==0 & race==2 // black not hispanic
replace hetero_race = 3 if race ==4  & hispan==0 | race==5 & hispan==0  | race==6 & hispan==0 // Asian
replace hetero_race = 4 if hispan!=0 & race!=8 & race!=9 // hispanic, not mixed races

** marital status
gen mard = (marst == 1) // married, spouse present
gen mard_s = (marst == 2 | marst == 3 | marst == 4 |marst == 5) //married, spouse absent (2), separated (3), divorced (4), widowed (5) 
gen single = (marst == 6) //single

** inflate wage income to 2007.
g r_incwage = .
replace r_incwage = incwage * 100/40.7386 if year == 1980 // wage is in 1979 (last year) dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/66.373 if year == 1990 // wage is in 1989 (last year) dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/83.4864 if year == 2000 // wage is in 1990 dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/94.9417 if year == 2006 // wage is in 2005 dollars, inflated to 2007 dollars	
replace r_incwage = incwage * 100/97.5245 if year == 2007 // wage is in 2006 dollars, inflated to 2007 dollars

save $ResultD/All_sample.dta, replace 


use $ResultD/All_sample.dta, clear 
keep if year == 1980 
gen ctygrp1980 = cntygp98 + statefip*1000
joinby ctygrp1980 using $OriginalD/cw_ctygrp1980_czone_corr.dta
gen czperwt = perwt * afactor
save $ResultD/1980_cz_allsample.dta, replace

use $ResultD/All_sample.dta, clear 
keep if year == 1990 
gen t2 = 0
gen puma1990 = puma + statefip*10000  //some of the pumas have 4 digits, but they're all in states with one digit, so in the end, this thing has 6 digits max
joinby puma1990 using $OriginalD/cw_puma1990_czone.dta
gen czperwt = perwt * afactor
// "afactor" is from "cw_puma1990_czone.dta", puma1990 will be split into multiple CZs.
save $ResultD/1990_cz_allsample.dta, replace

use $ResultD/All_sample.dta, clear 
keep if year == 2000
gen t2 = 1
gen puma2000 = puma + statefip*10000
joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
gen czperwt = perwt * afactor
// "afactor" is from "cw_puma2000_czone.dta", puma2000 will be split to multiple CZs.
save $ResultD/2000_cz_allsample.dta, replace

use $ResultD/All_sample.dta, clear 
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
append using $ResultD/1990_cz_allsample.dta
append using $ResultD/2000_cz_allsample.dta
drop puma1990 puma2000

save  $ResultD/All_sampleCZ.dta, replace
/*
Now it has 1990 2000 2006-2008 data, person weight and immigrant year modified, with CZ information and t2 = 0(year = 1990), 1(year = 2000) and 2(year = 2006-2008).
*/


use  $ResultD/All_sampleCZ.dta, clear  // This dataset contains all low skilled, 18-65 individules, including natives, immigrants from nonEng and English speaking countries.

keep if non_eng_immig == 0 // Keep immigrants from English speaking countries
drop if yrimmig_new==0 // Double check, drop natives, since natives are proved less mobile than immigrants
keep if ntv_spkr == 1 

* broadly split by their country of origin.
gen continent = .
replace continent = 2 if bpl>= 150 & bpl <= 199 // North America
replace continent = 2 if bpl>= 400 & bpl <= 499 // Europe
replace continent = 2 if bpl == 700 // Australia and New Zealand
replace continent = 3 if bpl>= 200 & bpl <= 300 // Central America,  Caribbean , South America
replace continent = 3 if bpl>= 500 & bpl <=599 // Asia
replace continent = 3 if bpl>= 600 & bpl < 700 // Africa

save  $ResultD/EngImm_sampleCZ.dta, replace

keep if young_arv == 0 // Keep those who arrived in the US after age 18. 
save  $ResultD/OldEngImm_sampleCZ.dta, replace // 50901/(81604+50901)=38.41% dropped


**********************************************************************
* Create change in log population 1980 - 1990 for non-Eng immigrants
**********************************************************************
* first create pre-trend population change, during 1980-1990.
* 1980_cz, 1990_cz, 2000_cz are created by 3_CommutingZone.do, they are the individual level data eith CZ information, or just FBsampleCZ.dta for each specific year.
use $ResultD/1980_cz.dta, clear 
append using $ResultD/1990_cz.dta
replace t2 = 1 if t2 == 0
replace t2 = 0 if missing(t2)

gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum  

reshape wide lnpopczyr popczyr, i(czone) j(year)
 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag = `i'1990 - `i'1980 
}

* keep only d_popczyr and d_lnpopczyr
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 0
save $ResultD/d_pop_80.dta,replace

* Only bad speakers pre-trend population change during 1980 - 1990 
use $ResultD/1980_cz.dta, clear 
append using $ResultD/1990_cz.dta
replace t2 = 1 if t2 == 0
replace t2 = 0 if missing(t2)

keep if goodeng == 0

gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum  

reshape wide lnpopczyr popczyr, i(czone) j(year)
 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag_bad = `i'1990 - `i'1980 
}

* keep only d_popczyr and d_lnpopczyr
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 0
save $ResultD/d_pop_80_bad,replace

* Only good speakers population change during 1980 - 1990 
use $ResultD/1980_cz.dta, clear 
append using $ResultD/1990_cz.dta
replace t2 = 1 if t2 == 0
replace t2 = 0 if missing(t2)

keep if goodeng == 1

gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum  

reshape wide lnpopczyr popczyr, i(czone) j(year)
 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag_good = `i'1990 - `i'1980 
}

* keep only d_popczyr and d_lnpopczyr
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 0
save $ResultD/d_pop_80_good,replace

**********************************************************************
* Create change in log population 1990 - 2000 for non-Eng immigrants
**********************************************************************
* All non-Eng immigrants, including both good and bad speakers, population change during 1990 - 2000 

use $ResultD/2000_cz.dta, clear 
append using $ResultD/1990_cz.dta

gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum 

reshape wide lnpopczyr popczyr, i(czone) j(year)
// For example, goodeng --> goodeng1990 goodeng2000 goodeng2007 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag = `i'2000 - `i'1990 
}

* keep only d_popczyr and d_lnpopczyr
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 1
save $ResultD/d_pop_90,replace


* Only bad speakers population change during 1990 - 2000 
use $ResultD/2000_cz.dta, clear 
append using $ResultD/1990_cz.dta

keep if goodeng == 0

gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum 

reshape wide lnpopczyr popczyr, i(czone) j(year)
// For example, goodeng --> goodeng1990 goodeng2000 goodeng2007 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag_bad = `i'2000 - `i'1990 
}

* keep only d_popczyr and d_lnpopczyr
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 1
save $ResultD/d_pop_90_bad,replace


* Only good speakers population change during 1990 - 2000 
use $ResultD/2000_cz.dta, clear 
append using $ResultD/1990_cz.dta

keep if goodeng == 1

gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum 

reshape wide lnpopczyr popczyr, i(czone) j(year)
// For example, goodeng --> goodeng1990 goodeng2000 goodeng2007 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag_good = `i'2000 - `i'1990 
}

* keep only d_popczyr and d_lnpopczyr
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 1
save $ResultD/d_pop_90_good,replace


**********************************************************************
* Create change in log population 1980 - 1990 for Eng immigrants
**********************************************************************

* Data file "1980/1990/2000_cz_allsample" are created above.

use $ResultD/1980_cz_allsample.dta, clear 
append using $ResultD/1990_cz_allsample.dta
replace t2 = 1 if t2 == 0
replace t2 = 0 if missing(t2)

keep if non_eng_immig == 0 // Keep immigrants from English speaking countries
drop if yrimmig_new==0 // Double check, drop natives, since natives are proved less mobile than immigrants
keep if ntv_spkr == 1 
keep if young_arv == 0 // Keep those who arrived in the US after age 18. 


gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum  

reshape wide lnpopczyr popczyr, i(czone) j(year)
 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag = `i'1990 - `i'1980 
}

* keep only those difference terms, which are named as d_popczyr, etc
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 0
save $ResultD/d_pop_80_oldENGsample,replace

**********************************************************************
* Create change in log population 1990 - 2000 for Eng immigrants
**********************************************************************

use $ResultD/2000_cz_allsample.dta, clear 
append using $ResultD/1990_cz_allsample.dta

keep if non_eng_immig == 0 // Keep immigrants from English speaking countries
drop if yrimmig_new==0 // Double check, drop natives, since natives are proved less mobile than immigrants
keep if ntv_spkr == 1 // Keep if only speak English
keep if young_arv == 0 // Keep those who arrived in the US after age 18. 


gen pop = 1
collapse (sum) popczyr=pop [pw = czperwt], by (czone year) 
gen lnpopczyr = ln(popczyr)
replace lnpopczyr = lnpopczyr*100

bysort czone: gen totnum = _N // totnum = how many times each CZ appear in the dataset.
drop if totnum < 2 

drop totnum 

reshape wide lnpopczyr popczyr, i(czone) j(year)
// For example, goodeng --> goodeng1990 goodeng2000 goodeng2007 
foreach i in lnpopczyr popczyr{
    gen d_`i'_lag = `i'2000 - `i'1990 
}

* keep only those difference terms, which are named as d_popczyr, etc
foreach j in lnpopczyr popczyr {
	drop `j'*
}

gen t2 = 1
save $ResultD/d_pop_90_oldENGsample,replace
