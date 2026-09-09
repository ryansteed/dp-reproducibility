
/* This dofile generates the sample including all natives, Eng-speaking and non-Eng-speaking country immigants, with all educational attaiment level for TableA.1.5(in our main analysis code we only include low skilled non-Eng immgrants) so that we can compare the effect on employment for each of the education-immigrant cell.The end datasets are: 
All_Manu_All_Edu_Ready4RegressBaseline.dta
Native_Manu_All_Edu_Ready4RegressBaseline.dta
Native_Manu_Low_Edu_Ready4RegressBaseline.dta
NonEng_Immig_Manu_Low_Edu_Ready4RegressBaseline.dta
*/

*Stata version 17

cd $ResultD
set more off 
use $OriginalD/80_10_original.dta, clear 
/*******************************************************************************************************
Step 1, create a sample keeps all working age individuals at regardless of their immigrant status and  education level
*******************************************************************************************************/
**Years used 
keep if year == 1980 | year == 1990 | year == 2000 | year == 2006 | year == 2007 | year == 2008
**drop two states Alaska and Hawaii, like ADH (2013)
drop if statefip == 2 | statefip == 15  // 
** keep people in working age
drop if age > 65
drop if age < 18
** for immigrant, define their immigrant year 
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

** define those who arrived young (UNDER 18)
gen young_arv = . 
replace young_arv = 1 if arv_age < 18 & arv_age!=. 
replace young_arv = 0 if arv_age >= 18 & arv_age!=. 

** keep all individuals but label those only have at most a high school degree
* drop if educd == 001 // 001: edu info not available, we dropped it later, right before running the regressions.
gen edu_non_c = ( educd < 65) // = 0 if at least have some college experience, 1 with no college experience

** define immirants from non-English speaking countries
merge m:1 bpld using $OriginalD/non_eng_cnty.dta //identify those immigrants from non-English speaking countries. (88,994 observations deleted)
gen non_eng_immig= .
replace non_eng_immig = 1 if _merge == 3 //  immigrants from non-English speaking countries.
replace non_eng_immig = 0 if _merge != 3 & yrimmig_new!=0 //  immigrants from English speaking countries.
drop _merge

** define those native speaker
gen ntv_spkr = (speakeng==3) // all those in our sample have reported English fluency
gen year_original = year

save AllsampleAllEdu.dta, replace

/*******************************************************************************************************
Step 2, create individual level variables needed, merge to get CZ information
*******************************************************************************************************/
use AllsampleAllEdu.dta, clear
** reweight the 3-year 2007 data set.
replace year = 2007 if year > 2005 // we conbine 2006-2008 data as the 2007 data
replace perwt = perwt/3 if year == 2007 //  If we had downloaded the 3-year ACS, this wouldn't have been necessary 

** language skill variables 
gen goodeng = (speakeng == 4) // =1 if speaks English very well.
gen goodeng_altr1 = (speakeng == 4 | speakeng == 5) // =1 speak well
gen goodeng_altr2 = (speakeng == 4 | speakeng == 5 | speakeng == 6) // =1 speak English
gen female = (sex == 2) //  =1 if female.
** occupation employed variables
gen manage_d = (occ1990 >= 3 & occ1990 <= 200)  // create industrial dummy for individual who works in professional management sector
gen sale_d = (occ1990 >= 203 & occ1990 <= 389)  // create industrial dummy for individual who works in technical sales and administrative support  sector
gen ser_d = (occ1990 >= 3 & occ1990 <= 469)  // create industrial dummy for individual who works in service sector including management and sales occupations
gen farm_d = (occ1990 >= 473 & occ1990 <= 498)  // create industrial dummy for individual who works in farming sector
gen manu_d = (occ1990 >= 503 & occ1990 <= 889)  // create industrial dummy for individual who works in manufacturing sector
* If the employment status is NOT employed or N/A, then do not treat them as working in manufacturing or service sector.
replace manu_d = 0 if empstatd == 0 | empstatd >= 20
replace ser_d = 0 if empstatd == 0 | empstatd >= 20
replace manage_d = 0 if empstatd == 0 | empstatd >= 20
replace sale_d = 0 if empstatd == 0 | empstatd >= 20
replace farm_d = 0 if empstatd == 0 | empstatd >= 20

* variable: reported as manufacturer
gen manage = (occ1990 >= 3 & occ1990 <= 200)  // create industrial dummy for individual who works in professional management sector
gen sale = (occ1990 >= 203 & occ1990 <= 389)  // create industrial dummy for individual who works in technical sales and administrative support  sector
gen ser = (occ1990 >= 3 & occ1990 <= 469)  // create industrial dummy for individual who works in service sector
gen farm = (occ1990 >= 473 & occ1990 <= 498)  // create industrial dummy for individual who works in farming sector
gen manu = (occ1990 >= 503 & occ1990 <= 889)  // create industrial dummy for individual who works in manufacturing sector

gen notemp = (empstatd >= 20 )
gen unemp = (empstatd >= 20 & empstatd < 30) // unemp= 1 if  currently unemployed, update: 2022 Dec 4
gen notlf = (empstatd >= 30) // notemp = 1 if  currently not in labor force, update: 2022 Dec 4

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

** calculate the CZ population of different ethnic groups 
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
replace r_incwage = incwage * 100/66.373 if year == 1990 // wage is in 1989 (last year) dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/83.4864 if year == 2000 // wage is in 1989 dollars, inflated to 2007 dollars
replace r_incwage = incwage * 100/94.9417 if year == 2006 // wage is in 2005 dollars, inflated to 2007 dollars	
replace r_incwage = incwage * 100/97.5245 if year == 2007 // wage is in 2006 dollars, inflated to 2007 dollars
save All_sampleAllEdu.dta, replace 

cd $ResultD
use All_sampleAllEdu.dta, clear 
keep if year == 1990 
gen t2 = 0
gen puma1990 = puma + statefip*10000
joinby puma1990 using $OriginalD/cw_puma1990_czone.dta
gen czperwt = perwt * afactor // "afactor" is from "cw_puma1990_czone.dta", puma1990 will be split into multiple CZs.
save "1990_allsampleAllEdu_cz.dta", replace

use All_sampleAllEdu.dta, clear 
keep if year == 2000
gen t2 = 1
gen puma2000 = puma + statefip*10000
joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
gen czperwt = perwt * afactor // "afactor" is from "cw_puma2000_czone.dta", puma2000 will be split to multiple CZs.
save "2000_allsampleAllEdu_cz.dta", replace

use All_sampleAllEdu.dta, clear 
keep if year > 2005
gen t2 = 2
gen puma2000 = puma + statefip*10000
/* Due to the effects of Hurricane Katrina, PUMAs 01801, 01802, and 01905 were all 
coded as living in PUMA 77777 from 2006-2011. So they are not matched, 
but 01801, 01802, and 01905 are all in CZ 3300 */
replace puma2000 = 221801 if puma2000 == 297777
joinby puma2000 using $OriginalD/cw_puma2000_czone.dta
gen czperwt = perwt * afactor
save "2007_allsampleAllEdu_cz.dta", replace
append using "1990_allsampleAllEdu_cz.dta"
append using "2000_allsampleAllEdu_cz.dta"
drop puma1990 puma2000
save All_sampleAllEduCZ.dta, replace
/*
Now it has 1990 2000 2006-2008 data, person weight and immigrant year modified, 
with CZ information and t2 = 0(year = 1990), 1(year = 2000) and 2(year = 2006-2008).
*/

/*******************************************************************************************************
Step 3, create aggregate year-cz level variables for differnt samples
*******************************************************************************************************/
/* All observations, all skills*/
use All_sampleAllEduCZ, clear 
run $wkdir/collapsedifs.do
save All_Manu_All_Edu_Ready4RegressBaseline, replace 

use All_sampleAllEduCZ, clear 
keep if empstat == 1 
replace occ1990=4 if occ1990==3
replace occ1990=22 if occ1990==16
replace occ1990=22 if occ1990==17
replace occ1990=22 if occ1990==21
replace occ1990=68 if occ1990==67
replace occ1990=154 if occ1990==113
replace occ1990=154 if occ1990==114
replace occ1990=154 if occ1990==115
replace occ1990=154 if occ1990==116
replace occ1990=154 if occ1990==118
replace occ1990=154 if occ1990==119
replace occ1990=154 if occ1990==123
replace occ1990=154 if occ1990==125
replace occ1990=154 if occ1990==127
replace occ1990=154 if occ1990==128
replace occ1990=154 if occ1990==139
replace occ1990=154 if occ1990==145
replace occ1990=154 if occ1990==147
replace occ1990=154 if occ1990==149
replace occ1990=154 if occ1990==150
replace occ1990=169 if occ1990==168
replace occ1990=178 if occ1990==179
replace occ1990=214 if occ1990==213
replace occ1990=214 if occ1990==215
replace occ1990=214 if occ1990==235
replace occ1990=379 if occ1990==314
replace occ1990=319 if occ1990==323
replace occ1990=344 if occ1990==343
replace occ1990=347 if occ1990==345
replace occ1990=159 if occ1990==387
replace occ1990=405 if occ1990==407
replace occ1990=443 if occ1990==438
replace occ1990=473 if occ1990==474
replace occ1990=473 if occ1990==475
replace occ1990=473 if occ1990==476
replace occ1990=479 if occ1990==483
replace occ1990=488 if occ1990==484
replace occ1990=525 if occ1990==538
replace occ1990=726 if occ1990==646
replace occ1990=596 if occ1990==653
replace occ1990=733 if occ1990==659
replace occ1990=666 if occ1990==667
replace occ1990=668 if occ1990==674
replace occ1990=785 if occ1990==717
replace occ1990=729 if occ1990==728
replace occ1990=736 if occ1990==734
replace occ1990=736 if occ1990==735
replace occ1990=756 if occ1990==768
replace occ1990=783 if occ1990==784
replace occ1990=759 if occ1990==789
replace occ1990=799 if occ1990==796
replace occ1990=883 if occ1990==834
replace occ1990=889 if occ1990==876
replace occ1990=889 if occ1990==877
merge m:1 occ1990 using "occ1990_and_oral_rescale_score.dta"
* Not matched: some of them do not have oral scores reported, some of them only exist in 1990 data.
* 684   Other precision and craft workers, exists in 1990
* 693	Adjusters and calibrators, 1990
* 415	Supervisors of guards, all years
* 454	Elevator operators, all years
* 905	Military, all years
* 733	Other woodworking machine operators, all years
* 349	Other telecom operators, all years
drop if _merge != 3
drop _merge 

merge m:1 occ1990 using AllOcc_Oral_p25
gen oral_all_p25 = (_merge == 3)
replace oral_all_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p25_50
gen oral_all_p25_50 = (_merge == 3)
replace oral_all_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p50
gen oral_all_p50 = (_merge == 3)
replace oral_all_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p75
gen oral_all_p75= (_merge == 3 )
replace oral_all_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge


merge m:1 occ1990 using LowSkillOcc_Oral_p25
gen oral_lowsk_p25= (_merge == 3 )
replace oral_lowsk_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p25_50
gen oral_lowsk_p25_50= (_merge == 3 )
replace oral_lowsk_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p50
gen oral_lowsk_p50= (_merge == 3 )
replace oral_lowsk_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p75
gen oral_lowsk_p75= (_merge == 3 )
replace oral_lowsk_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

run $wkdir/collapsedifs_oral_occ.do
keep czone t2 manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   ///
d_oral_lowsk_p25_50  d_oral_all_p25_50 d_oral_all_p25  d_oral_all_p50 d_oral_all_p75 d_oral_lowsk_p25  d_oral_lowsk_p50 d_oral_lowsk_p75 oral_all_p25_50 oral_lowsk_p25_50 oral_all_p25  oral_all_p50 oral_all_p75 oral_lowsk_p25   oral_lowsk_p50 oral_lowsk_p75 
save depvar, replace

use All_Manu_All_Edu_Ready4RegressBaseline, clear 
drop manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d  
merge 1:1 czone t2 using depvar
save All_Manu_All_Edu_Ready4RegressBaseline.dta, replace

/* Only natives, all skills*/
use All_sampleAllEduCZ, clear 
keep if yrimmig_new == 0
run $wkdir/collapsedifs.do
save Native_Manu_All_Edu_Ready4RegressBaseline, replace 

use All_sampleAllEduCZ, clear 
keep if yrimmig_new == 0
keep if empstat == 1 
replace occ1990=4 if occ1990==3
replace occ1990=22 if occ1990==16
replace occ1990=22 if occ1990==17
replace occ1990=22 if occ1990==21
replace occ1990=68 if occ1990==67
replace occ1990=154 if occ1990==113
replace occ1990=154 if occ1990==114
replace occ1990=154 if occ1990==115
replace occ1990=154 if occ1990==116
replace occ1990=154 if occ1990==118
replace occ1990=154 if occ1990==119
replace occ1990=154 if occ1990==123
replace occ1990=154 if occ1990==125
replace occ1990=154 if occ1990==127
replace occ1990=154 if occ1990==128
replace occ1990=154 if occ1990==139
replace occ1990=154 if occ1990==145
replace occ1990=154 if occ1990==147
replace occ1990=154 if occ1990==149
replace occ1990=154 if occ1990==150
replace occ1990=169 if occ1990==168
replace occ1990=178 if occ1990==179
replace occ1990=214 if occ1990==213
replace occ1990=214 if occ1990==215
replace occ1990=214 if occ1990==235
replace occ1990=379 if occ1990==314
replace occ1990=319 if occ1990==323
replace occ1990=344 if occ1990==343
replace occ1990=347 if occ1990==345
replace occ1990=159 if occ1990==387
replace occ1990=405 if occ1990==407
replace occ1990=443 if occ1990==438
replace occ1990=473 if occ1990==474
replace occ1990=473 if occ1990==475
replace occ1990=473 if occ1990==476
replace occ1990=479 if occ1990==483
replace occ1990=488 if occ1990==484
replace occ1990=525 if occ1990==538
replace occ1990=726 if occ1990==646
replace occ1990=596 if occ1990==653
replace occ1990=733 if occ1990==659
replace occ1990=666 if occ1990==667
replace occ1990=668 if occ1990==674
replace occ1990=785 if occ1990==717
replace occ1990=729 if occ1990==728
replace occ1990=736 if occ1990==734
replace occ1990=736 if occ1990==735
replace occ1990=756 if occ1990==768
replace occ1990=783 if occ1990==784
replace occ1990=759 if occ1990==789
replace occ1990=799 if occ1990==796
replace occ1990=883 if occ1990==834
replace occ1990=889 if occ1990==876
replace occ1990=889 if occ1990==877
merge m:1 occ1990 using "occ1990_and_oral_rescale_score.dta"
* Not matched: some of them do not have oral scores reported, some of them only exist in 1990 data.
* 684   Other precision and craft workers, exists in 1990
* 693	Adjusters and calibrators, 1990
* 415	Supervisors of guards, all years
* 454	Elevator operators, all years
* 905	Military, all years
* 733	Other woodworking machine operators, all years
* 349	Other telecom operators, all years
drop if _merge != 3
drop _merge 

merge m:1 occ1990 using AllOcc_Oral_p25
gen oral_all_p25 = (_merge == 3)
replace oral_all_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p25_50
gen oral_all_p25_50 = (_merge == 3)
replace oral_all_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p50
gen oral_all_p50 = (_merge == 3)
replace oral_all_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p75
gen oral_all_p75= (_merge == 3 )
replace oral_all_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge


merge m:1 occ1990 using LowSkillOcc_Oral_p25
gen oral_lowsk_p25= (_merge == 3 )
replace oral_lowsk_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p25_50
gen oral_lowsk_p25_50= (_merge == 3 )
replace oral_lowsk_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p50
gen oral_lowsk_p50= (_merge == 3 )
replace oral_lowsk_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p75
gen oral_lowsk_p75= (_merge == 3 )
replace oral_lowsk_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

run $wkdir/collapsedifs_oral_occ.do
keep czone t2 manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   ///
 d_oral_lowsk_p25_50  d_oral_all_p25_50 d_oral_all_p25  d_oral_all_p50 d_oral_all_p75 d_oral_lowsk_p25  d_oral_lowsk_p50 d_oral_lowsk_p75 oral_all_p25_50 oral_lowsk_p25_50 oral_all_p25  oral_all_p50 oral_all_p75 oral_lowsk_p25   oral_lowsk_p50 oral_lowsk_p75 
save depvar, replace

use Native_Manu_All_Edu_Ready4RegressBaseline, clear 
drop manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d    
merge 1:1 czone t2 using depvar
save Native_Manu_All_Edu_Ready4RegressBaseline.dta, replace

/* low-education natives */
use All_sampleAllEduCZ, clear 
drop if educd == 001 // drop if edu info not available
drop if edu_non_c == 0 // drop if they have college experience
keep if yrimmig_new == 0
run $wkdir/collapsedifs.do
save Native_Manu_Low_Edu_Ready4RegressBaseline, replace 

use All_sampleAllEduCZ, clear 
drop if educd == 001 // drop if edu info not available
drop if edu_non_c == 0 // drop if they have college experience
keep if yrimmig_new == 0
keep if empstat == 1 
replace occ1990=4 if occ1990==3
replace occ1990=22 if occ1990==16
replace occ1990=22 if occ1990==17
replace occ1990=22 if occ1990==21
replace occ1990=68 if occ1990==67
replace occ1990=154 if occ1990==113
replace occ1990=154 if occ1990==114
replace occ1990=154 if occ1990==115
replace occ1990=154 if occ1990==116
replace occ1990=154 if occ1990==118
replace occ1990=154 if occ1990==119
replace occ1990=154 if occ1990==123
replace occ1990=154 if occ1990==125
replace occ1990=154 if occ1990==127
replace occ1990=154 if occ1990==128
replace occ1990=154 if occ1990==139
replace occ1990=154 if occ1990==145
replace occ1990=154 if occ1990==147
replace occ1990=154 if occ1990==149
replace occ1990=154 if occ1990==150
replace occ1990=169 if occ1990==168
replace occ1990=178 if occ1990==179
replace occ1990=214 if occ1990==213
replace occ1990=214 if occ1990==215
replace occ1990=214 if occ1990==235
replace occ1990=379 if occ1990==314
replace occ1990=319 if occ1990==323
replace occ1990=344 if occ1990==343
replace occ1990=347 if occ1990==345
replace occ1990=159 if occ1990==387
replace occ1990=405 if occ1990==407
replace occ1990=443 if occ1990==438
replace occ1990=473 if occ1990==474
replace occ1990=473 if occ1990==475
replace occ1990=473 if occ1990==476
replace occ1990=479 if occ1990==483
replace occ1990=488 if occ1990==484
replace occ1990=525 if occ1990==538
replace occ1990=726 if occ1990==646
replace occ1990=596 if occ1990==653
replace occ1990=733 if occ1990==659
replace occ1990=666 if occ1990==667
replace occ1990=668 if occ1990==674
replace occ1990=785 if occ1990==717
replace occ1990=729 if occ1990==728
replace occ1990=736 if occ1990==734
replace occ1990=736 if occ1990==735
replace occ1990=756 if occ1990==768
replace occ1990=783 if occ1990==784
replace occ1990=759 if occ1990==789
replace occ1990=799 if occ1990==796
replace occ1990=883 if occ1990==834
replace occ1990=889 if occ1990==876
replace occ1990=889 if occ1990==877

merge m:1 occ1990 using "occ1990_and_oral_rescale_score.dta"
* Not matched: some of them do not have oral scores reported, some of them only exist in 1990 data.
* 684   Other precision and craft workers, exists in 1990
* 693	Adjusters and calibrators, 1990
* 415	Supervisors of guards, all years
* 454	Elevator operators, all years
* 905	Military, all years
* 733	Other woodworking machine operators, all years
* 349	Other telecom operators, all years
drop if _merge != 3
drop _merge 

merge m:1 occ1990 using AllOcc_Oral_p25
gen oral_all_p25 = (_merge == 3)
replace oral_all_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p25_50
gen oral_all_p25_50 = (_merge == 3)
replace oral_all_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p50
gen oral_all_p50 = (_merge == 3)
replace oral_all_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p75
gen oral_all_p75= (_merge == 3 )
replace oral_all_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p25
gen oral_lowsk_p25= (_merge == 3 )
replace oral_lowsk_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p25_50
gen oral_lowsk_p25_50= (_merge == 3 )
replace oral_lowsk_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p50
gen oral_lowsk_p50= (_merge == 3 )
replace oral_lowsk_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p75
gen oral_lowsk_p75= (_merge == 3 )
replace oral_lowsk_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

run $wkdir/collapsedifs_oral_occ.do
keep czone t2 manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   ///
 d_oral_lowsk_p25_50  d_oral_all_p25_50 d_oral_all_p25  d_oral_all_p50 d_oral_all_p75 d_oral_lowsk_p25  d_oral_lowsk_p50 d_oral_lowsk_p75 oral_all_p25_50 oral_lowsk_p25_50 oral_all_p25  oral_all_p50 oral_all_p75 oral_lowsk_p25   oral_lowsk_p50 oral_lowsk_p75 
save depvar, replace

use Native_Manu_Low_Edu_Ready4RegressBaseline, clear 
drop manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d    
merge 1:1 czone t2 using depvar
save Native_Manu_Low_Edu_Ready4RegressBaseline.dta, replace

/* only non-English speaking country immigrants*/
use All_sampleAllEduCZ, clear 
drop if educd == 001 // drop if edu info not available
drop if edu_non_c == 0 // drop if they have college experience
keep if yrimmig_new != 0 & non_eng_immig == 1
keep if young_arv == 0
drop if speakeng == 0 | speakeng==3 
run $wkdir/collapsedifs.do
save NonEng_Immig_Manu_Low_Edu_Ready4RegressBaseline, replace 

use All_sampleAllEduCZ, clear 
drop if educd == 001 // drop if edu info not available
drop if edu_non_c == 0 // drop if they have college experience
keep if yrimmig_new != 0 & non_eng_immig == 1
keep if young_arv == 0
drop if speakeng == 0 | speakeng==3 
keep if empstat == 1 
replace occ1990=4 if occ1990==3
replace occ1990=22 if occ1990==16
replace occ1990=22 if occ1990==17
replace occ1990=22 if occ1990==21
replace occ1990=68 if occ1990==67
replace occ1990=154 if occ1990==113
replace occ1990=154 if occ1990==114
replace occ1990=154 if occ1990==115
replace occ1990=154 if occ1990==116
replace occ1990=154 if occ1990==118
replace occ1990=154 if occ1990==119
replace occ1990=154 if occ1990==123
replace occ1990=154 if occ1990==125
replace occ1990=154 if occ1990==127
replace occ1990=154 if occ1990==128
replace occ1990=154 if occ1990==139
replace occ1990=154 if occ1990==145
replace occ1990=154 if occ1990==147
replace occ1990=154 if occ1990==149
replace occ1990=154 if occ1990==150
replace occ1990=169 if occ1990==168
replace occ1990=178 if occ1990==179
replace occ1990=214 if occ1990==213
replace occ1990=214 if occ1990==215
replace occ1990=214 if occ1990==235
replace occ1990=379 if occ1990==314
replace occ1990=319 if occ1990==323
replace occ1990=344 if occ1990==343
replace occ1990=347 if occ1990==345
replace occ1990=159 if occ1990==387
replace occ1990=405 if occ1990==407
replace occ1990=443 if occ1990==438
replace occ1990=473 if occ1990==474
replace occ1990=473 if occ1990==475
replace occ1990=473 if occ1990==476
replace occ1990=479 if occ1990==483
replace occ1990=488 if occ1990==484
replace occ1990=525 if occ1990==538
replace occ1990=726 if occ1990==646
replace occ1990=596 if occ1990==653
replace occ1990=733 if occ1990==659
replace occ1990=666 if occ1990==667
replace occ1990=668 if occ1990==674
replace occ1990=785 if occ1990==717
replace occ1990=729 if occ1990==728
replace occ1990=736 if occ1990==734
replace occ1990=736 if occ1990==735
replace occ1990=756 if occ1990==768
replace occ1990=783 if occ1990==784
replace occ1990=759 if occ1990==789
replace occ1990=799 if occ1990==796
replace occ1990=883 if occ1990==834
replace occ1990=889 if occ1990==876
replace occ1990=889 if occ1990==877

merge m:1 occ1990 using "occ1990_and_oral_rescale_score.dta"
* Not matched: some of them do not have oral scores reported, some of them only exist in 1990 data.
* 684   Other precision and craft workers, exists in 1990
* 693	Adjusters and calibrators, 1990
* 415	Supervisors of guards, all years
* 454	Elevator operators, all years
* 905	Military, all years
* 733	Other woodworking machine operators, all years
* 349	Other telecom operators, all years
drop if _merge != 3
drop _merge 

merge m:1 occ1990 using AllOcc_Oral_p25
gen oral_all_p25 = (_merge == 3)
replace oral_all_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p25_50
gen oral_all_p25_50 = (_merge == 3)
replace oral_all_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p50
gen oral_all_p50 = (_merge == 3)
replace oral_all_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using AllOcc_Oral_p75
gen oral_all_p75= (_merge == 3 )
replace oral_all_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge


merge m:1 occ1990 using LowSkillOcc_Oral_p25
gen oral_lowsk_p25= (_merge == 3 )
replace oral_lowsk_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p25_50
gen oral_lowsk_p25_50= (_merge == 3 )
replace oral_lowsk_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p50
gen oral_lowsk_p50= (_merge == 3 )
replace oral_lowsk_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using LowSkillOcc_Oral_p75
gen oral_lowsk_p75= (_merge == 3 )
replace oral_lowsk_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

run $wkdir/collapsedifs_oral_occ.do
keep czone t2 manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   ///
 d_oral_lowsk_p25_50  d_oral_all_p25_50 d_oral_all_p25  d_oral_all_p50 d_oral_all_p75 d_oral_lowsk_p25  d_oral_lowsk_p50 d_oral_lowsk_p75 oral_all_p25_50 oral_lowsk_p25_50 oral_all_p25  oral_all_p50 oral_all_p75 oral_lowsk_p25   oral_lowsk_p50 oral_lowsk_p75 
save depvar, replace

use NonEng_Immig_Manu_Low_Edu_Ready4RegressBaseline, clear 
drop manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   
merge 1:1 czone t2 using depvar
drop if _merge !=3
save NonEng_Immig_Manu_Low_Edu_Ready4RegressBaseline.dta, replace


