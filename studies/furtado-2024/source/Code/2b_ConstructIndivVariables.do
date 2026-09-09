/*This dofile constructs individual level variables from the Census/ACS data, including age, gender, race, employment status, industrial sector, whether individual speaks good English, etc. The end data set is: FBsample_var.dta. */  

* Stata version: 17.0 MP, updated on 2023/04/20

set more off 
cd $wkdir
use $ResultD/FBsample.dta, clear 

gen year_original = year
**We name the 2006-2008 3 year sample as "2007" data.
replace year = 2007 if year > 2005 
**reweight the 3-year conbined sample.
replace perwt = perwt/3 if year == 2007 

** English skills
gen goodeng = (speakeng == 4) 
* =1 if speaks English very well.
gen goodeng_altr1 = (speakeng == 4 | speakeng == 5) 
* =1 speak well
gen goodeng_altr2 = (speakeng == 4 | speakeng == 5 | speakeng == 6) 
* =1 speak English

** Gender
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

gen notemp = (empstatd >= 20 )
gen unemp = (empstatd >= 20 & empstatd < 30) // unemp= 1 if  currently unemployed
gen notlf = (empstatd >= 30) // notemp = 1 if currently not in labor force

** years in US square
gen yrsusasq = yrsusa^2

** years in US intervals 
gen yrusintvl_1 = (yrsusa<=3)
gen yrusintvl_5= (yrsusa>3 & yrsusa<=5)
gen yrusintvl_7=( yrsusa>5 & yrsusa<=8)
gen yrusintvl_9=( yrsusa>8 & yrsusa<=10)
gen yrusintvl_10plus =( yrsusa> 10 )

** age square
gen agesq = age^2

** age intervals
gen ageintvl_20=( age<30 )
gen ageintvl_30=( age<40 &age>=30)
gen ageintvl_40=( age<50 &age>=40)
gen ageintvl_50=( age>=50)

** age at arrival intervals
gen arv_age_20 =(arv_age<30)
gen arv_age_30 =(arv_age<40 & arv_age >=30)
gen arv_age_40 =(arv_age<50 & arv_age >=40)
gen arv_age_50 =(arv_age<60 & arv_age >=50)
gen arv_age_60 =(arv_age>=60)

** high school graduates
gen edu_hs = (educd == 64 | educd == 63 | educd == 62)  if year>1980
replace edu_hs = (educd == 60)  if year == 1980
/* 
Before 1990, 
60 Grade 12 is used to show high school graduates(with/without diploma).

Start from 1990, 
62	High school graduate or GED(used before year 2008).
Start from 2008, code 62 will not be used, instead:
63	Regular high school diploma, 
64	GED or alternative credential.
*/

**Enrolled in school 
gen enroll = (school == 2) // enroll = 1 if currently in school; = 0 if not enrolled in school
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

** inflate wage income to 2007 US$.
/*************************************************************************************
The numbers we used to inflate to 2007 US$ are calculated by annual Personal Consumption Expenditure(PCE) 
price index, they are collected from Fred Economic Data: 
https://fred.stlouisfed.org/series/PCEPI
In Autor et al. (2013), they use PCEPI to convert the import values in different years to 2007 US$, that's the reason to use PCEPI instead of CPI inflation calculator. 
*************************************************************************************/
g r_incwage = .
replace r_incwage = incwage * 100/40.7386 if year == 1980 // wage is in 1979 (last year) dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/66.373 if year == 1990 // wage is in 1989 (last year) dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/83.4864 if year == 2000 // wage is in 1990 dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/94.9417 if year == 2006 // wage is in 2005 dollars, inflated to 2007 dollars	
replace r_incwage = incwage * 100/97.5245 if year == 2007 // wage is in 2006 dollars, inflated to 2007 dollars
/*************************************************************************************
"incwage" reported in 1980 is in 1979 US$, 
"incwage" reported in 1990 is in 1989 US$, 
"incwage" reported in 2000 is in 1999 US$... 
"incwage" reported in 2008 is in 2007 US$. 
So the weight for "incwage" in 2008 is 1. 

In ACS, individuals can be survey all year round, so if some are surveyed in January, 
and the other are surveyed in December, the dollar values can be different, Census Bureau has created an adjuster, while it is a constant value (year round average) for all individuals surveyed in the same year. IPUMS find implying it makes little difference to the final result, so we did not use the adjuster. *************************************************************************************/

save $ResultD/FBsample_var.dta, replace 




