/* This dofile makes the sample selection for the analysis. We keep only 1980-2008 Census/ACS data, and only working-age, low-education immigrants from non-English speaking countries in the mainland 48 US states, who arrived in the US after the age of 18.

It creates the Stata data file called: FBsample.dta.*/

* Stata version: 17.0 MP (updated on 2023_04_20)
set more off 

cd $wkdir 
use $OriginalD/80_10_original.dta, clear 
**keep only 1980,1990, 2000, 2006-2008 ACS data.
keep if year == 1980 | year == 1990 | year == 2000 | year == 2006 | year == 2007 | year == 2008

*drop two states Alaska and Hawaii, following ADH (2013)
drop if statefip == 2 | statefip == 15  // 

* keep people in working age 18-65
drop if age > 65
drop if age < 18

* keep the foreign born 
drop if yrimmig == 0 

/* 
Drop those that arrived before age 18.
In 1990 and 1980 ACS data, "yrimmig" do not report accurate year entered the US but in (different) intervals, we take the average of the start and end year of each interval, following Arturo Gonzalez 2003.
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
* starting from here, 1990 data has different interval length, not 5 years
replace yrimmig_new = 1977 if yrimmig == 1979 & year ==1990
replace yrimmig_new = 1980.5 if yrimmig == 1981 & year ==1990
replace yrimmig_new = 1983 if yrimmig == 1984 & year ==1990
replace yrimmig_new = 1985.5 if yrimmig == 1986 & year ==1990
replace yrimmig_new = 1988.5 if yrimmig == 1990 & year ==1990

gen yrsusa = year - yrimmig_new // generate years in the USA.
gen arv_age = age - yrsusa // calculate age on arrival.
drop if arv_age < 18 // Drop those arrived before 18.

* keep only immigrants have at most a high school degree
drop if educd == 001 // drop if edu info not available
gen edu_non_c = (educd < 65) // edu_non_c= 0 if at least have some college experience, =1 if no college experience at all.
drop if edu_non_c == 0 // drop if they have college experience


* keep only those from non-English speaking countries, not speaking English only, and have English ability data
/*************************************************************************************
To define English speaking countries:
We create the list based on Bleakley & Chin (2004): 
English-speaking countries are deﬁned as those countries from which more than half the recent (less than 3 years) adult immigrants did not speak a language other than English at home, as well as those countries listed English as an official language on Wikipedia. We treat all the rest countries as non-English speaking countries. 
*************************************************************************************/
drop if speakeng == 0 | speakeng==3 // Drop samples without English proficiency data or speak English only.
merge m:1 bpld using $OriginalD/non_eng_cnty.dta //identify those immigrants from non-English speaking countries. 
drop if _merge != 3 // keep immigrants from non-English speaking countries.
drop _merge
* 1,015,221 obs left.

save $ResultD/FBsample.dta, replace
