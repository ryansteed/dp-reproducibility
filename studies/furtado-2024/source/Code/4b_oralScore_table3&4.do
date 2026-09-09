/* This dofile creates year-CZ level data with changes in employment share in manufacturing/service/farming occupations and in different oral score quantiles among employed immigrants, as well as changes in share of unemployed and not in labor force, the end dataset is oral_emp_eff.dta */

* Stata version 17 

clear
set more off
cd $wkdir
/*******************************************************************************
Step 1, match occupation code in O*NET files (which is ONETSOC2010Code) with occ1990 code in IPUMS dataset. In summary:
cw_onet_and_soc.dta cotains value of O*Netsoc2010 code(which will be found in O*Net files, 1110 occupations in total) and soc2010 code.
cw_soc2010_and_occ2010.dta cantains value of soc2010 code (841 occupations in total) and corresponding occ2010 code.
cw_occ2010_and_occ1990.dta cantains value of occ2010 code (566 occupations in total) and corresponding occ1990 code.
Finally, a dataset call "cw_z_onet_and_occ1990.dta" is created, it contains O*NETsoc2010 code and corresponding occ1990 code.
ONET data downloaded from: https://www.onetcenter.org/database.html#all-files.
*******************************************************************************/
use $OriginalD/cw_onet_and_soc.dta
merge m:1 SOC2010Code using $OriginalD/cw_soc2010_and_occ2010.dta
/*******************************************************************************
All 1110 o*net occupations are matched.
*******************************************************************************/
keep ONETSOC2010Code OCC2010Code
merge m:1 OCC2010Code using $OriginalD/cw_occ2010_and_occ1990.dta
/*******************************************************************************
1110 o*net occupations are matched, but we have 46 not matched from using. 
Reasons:
1, ONETSOC2010Code doesn't report "Unknown" or "Unemployed", while, they are reported in cw_occ2010_and_occ1990.dta.
2, OCC2010Code is not consistent across different crosswalk files, for example, OCC2010Code=8965 exists in cw_occ2010_and_occ1990.dta 
but doesn't exist in cw_soc2010_and_occ2010.dta.
*******************************************************************************/
drop if _merge !=3
drop Occupationcategorydescription
drop OCC2010Code
drop _merge
save $ResultD/cw_z_onet_and_occ1990.dta, replace
/********************************************************************************
At last, we have a occ1990 code for each O*NET occupation.
*******************************************************************************/


/*******************************************************************************
Step 2, create indicators of education or preparation needed for each ONET occupation. Dataset "Education", "jobzone", and "skills" are also downloaded from ONET website: https://www.onetcenter.org/database.html#all-files
*******************************************************************************/
use $OriginalD/Education.dta, clear
keep if ScaleID=="RL" // 'RL' means "Required Level Of Education (Categories 1-12)"
keep if Category==1| Category==2| Category==3
/*******************************************************************************
Category=1 means "Less than a High School Diploma"
Category=2 means "High School Diploma - or the equivalent (for example, GED)"
Category=3 means "Post-Secondary Certificate - awarded for training completed after high school"
Category=4 means "Some College Courses"
Category=5 means "Associate's Degree (or other 2-year degree)"
Category=6 means "Bachelor's Degree"
...
Category=12 means "Post-Doctoral Training"
*******************************************************************************/
keep Title ScaleName Category DataValue ONETSOCCode
collapse (sum) DataValue, by (ONETSOCCode)
/*******************************************************************************
Every ONET occupation has 12 "DataValue", each "DataValue" means the share of workers within each "Category", because we just keep Category 1-3, after SUM we will get the share of low education workers(high school or less) in each ONET occupation.
*******************************************************************************/ 
rename DataValue low_skill_share
save $ResultD/EducationOnly.dta, replace

use $OriginalD/jobzone.dta, clear
keep Title JobZone ONETSOCCode Date
gen byte highskill=(JobZone==3|JobZone==4| JobZone==5)
/*******************************************************************************
JobZone=1 means "Some of these occupations may require a high school diploma or GED certificate"
JobZone=2 means "These occupations usually require a high school diploma"
JobZone=3 means "Most occupations in this zone require training in vocational schools, related on-the-job experience, or an associate's degree"
JobZone=4 means "Most of these occupations require a four-year bachelor's degree, but some do not"
JobZone=5 means "Most of these occupations require graduate school. For example, they may require a master's degree, and some require a Ph.D., M.D., or J.D. (law degree)"
*******************************************************************************/
save $ResultD/JobzoneOnly.dta, replace

// double check
use $OriginalD/skills.dta
drop if ScaleID=="LV" // keep "IM" importance for each skills required in each occupation.
save $ResultD/skillsOnly.dta, replace


/*******************************************************************************
Step 3, calculate the "oral score" for each occupation.

O*NET provides a score measuring the importance of several dozen skills and abilities used in performing the job for each occupation, data is stored in "Ability.dta", which is also obtained from ONET website.

We select two abilities that incolves conversation skills: "Oral Comprehension" and "Oral Expression".
*******************************************************************************/
use $OriginalD/Ability.dta, clear
keep if ElementName=="Oral Comprehension" //964 occupations reported.
gen ocscore=(DataValue-1)/4 //DataValue ranges from 1 to 5.
merge 1:1 ONETSOCCode using $ResultD/EducationOnly.dta
//EducationOnly.dta conatins the share of low skill workers (with no college experience) for each occupation.
drop if _merge==2
drop _merge
//3 occupations don't have education data.
merge 1:1 ONETSOCCode using $ResultD/JobzoneOnly.dta
//JobzoneOnly.dta conatins the JobZone and a dummy variable "highskill" which is set to 1 if the that occupation has a JobZone greater than 2.
drop if _merge==2
drop _merge
// 1 occupation reported Jobzone but don't report Oral Comprehension
keep ONETSOCCode Title JobZone low_skill_share highskill ocscore
save $ResultD/ocophsn_score.dta, replace
/*******************************************************************************
We have 963 ONETSOC2010 occupations reported the Oral Comprehension score.
*******************************************************************************/
use $OriginalD/Ability.dta, clear
keep if ElementName=="Oral Expression"
gen oescore=(DataValue-1)/4
merge 1:1 ONETSOCCode using $ResultD/EducationOnly.dta
drop if _merge==2
drop _merge
merge 1:1 ONETSOCCode using $ResultD/JobzoneOnly.dta
drop if _merge==2
drop _merge
keep ONETSOCCode Title JobZone low_skill_share highskill oescore
save $ResultD/oexpsn_score.dta, replace
/*******************************************************************************
We also have 963 ONETSOC2010 occupations reported the Oral Expression score.
*******************************************************************************/

use $ResultD/ocophsn_score.dta, clear
rename ONETSOCCode ONETSOC2010Code
merge 1:1 ONETSOC2010Code using $ResultD/cw_z_onet_and_occ1990.dta
/*******************************************************************************
All 963 occupations with oral comprehension scores are matched, recall that we have 1110 ONET occupations, so the rest 147 o*net occupations don't have reported oral comprehension score.
Each occ1990 code would match with multiple ONET codes, but we have five occ1990 code (349 415 454 733 905) don't have oral comprehension scores.
*******************************************************************************/
drop if _merge!=3
drop _merge
collapse  (mean)  ocscore JobZone highskill low_skill_share, by (occ1990)
/*******************************************************************************
We use the unweighted mean to calculate the oral comprehension score as well as the education needed for each occ1990.
*******************************************************************************/
save $ResultD/oral_cmphensn_score_occ1990, replace

/*******************************************************************************
Same procedure to get the oral expression score for each occ1990.
*******************************************************************************/
use $ResultD/oexpsn_score.dta, clear
rename ONETSOCCode ONETSOC2010Code
merge 1:1 ONETSOC2010Code using $ResultD/cw_z_onet_and_occ1990.dta
drop if _merge!=3
collapse  (mean)  oescore JobZone highskill low_skill_share, by (occ1990)
save $ResultD/oral_expsn_score_occ1990, replace

merge 1:1 occ1990 using $ResultD/oral_cmphensn_score_occ1990.dta
/*******************************************************************************
324 occ1990 matched.
*******************************************************************************/
keep occ1990 oescore ocscore JobZone highskill low_skill_share
save $ResultD/oral_scorea_occ1990, replace


/*************************************************************************
Step 4, calculate the rescaled oral score for each occupation.
We use 2007-2011 five year combined ACS data (also known as the "2010 data"), keep only those employed workers.
We have got the oral comprehension score and oral expression score for each occ1990 occupation from Step 3, we will rescale those values so that they'll equal percentiles measuring the share of the workers using less of the 2 abilities in "2010 data".
*************************************************************************/
use $OriginalD/80_10_original.dta, clear
keep if year >=2007 & year <=2011
replace year = 2010
replace perwt = perwt/5
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
// refine the inconsistent occ1990 code
drop if empstatd!=10
// only keep employed
merge m:1 occ1990 using $ResultD/oral_scorea_occ1990.dta
// merge the oral comprehension and oral expression for each occ1990 to "2010 data".
drop if _merge!=3
drop _merge
egen group = group(occ1990)
// assign a group number for each occ1990 to make loop easier
save $ResultD/10_prepare_rescale.dta, replace

** calculate rescaled oral expression ability score
use $ResultD/10_prepare_rescale.dta, clear
su group, meanonly
forvalues i=1/`r(max)'{
    gen be`i' =oescore if group==`i' //generate be1 be2 ... but be1=oescore only if group=1, the others are missing
    su be`i' if !missing(be`i'), meanonly
    replace be`i'=r(mean) if missing(be`i') //replace the missing values with the corresponding oescore
/* The codes above generate new variable be1 be2 be3... for example, all values in be1 are set equal to the oral expression score of group=1, which is also occ1990=4.
Variable 'oescore' has different values for different occupations. The reason why we use 'be*' here is to aviod using 'oe*' since it will not only include 'oe1' 'oe2' 'oe3' ... but also 'oescore'. */
    replace be`i'=1 if be`i'>=oescore  //compare be`i' with different occupation scores
    replace be`i'=0 if be`i'!=1
/* The variables be1 be2 be3... which show oral expression scores of different occupations are then changed to dummy variables: for example, compare the oral expression score of group 1 with the score of other groups, be1=1 if be1>=oescore(oral expression score) means be1=1 if oral expression score of group 1 is grearter or equal to the score of other occupations, be1=0 otherwise. */
} 
save $ResultD/oral_rescale_e.dta,replace

collapse (mean) be* [pw=perwt]
// calculate the share of workers using less of the oral expression ability
gen id = 1
reshape long be, i(id) j(group)
// change dataset from 1 row, 324 columns to 324 rows, 2 columns
drop id 
save $ResultD/oral_expression_rescale.dta, replace
// file 'oral_expression_rescale' contains rescaled oral expression score for each group (or occ1990)

** calculate rescaled oral comprehension ability score 
use $ResultD/10_prepare_rescale.dta
su group, meanonly
forvalues i=1/`r(max)'{
    gen bc`i' =ocscore if group==`i'
    su bc`i' if !missing(bc`i'), meanonly
    replace bc`i'=r(mean) if missing(bc`i')
/* generate variables bc1 bc2 bc3... for example, all values in bc1 are set equal to the oral compregension score of group=1, which is also occ1990=4.
Summarize bc`i' if bc`i' is not missing can get us the mean (which is also the ocscore for occupation i), then fill the missing be`i' with occupations i's oscore.
Variabel 'ocscore' has different values for different occupations. The reason why we use 'bc*' here is to aviod using 'oc*' will not only include 'oc1' 'oc2' 'oc3' ... but also include 'occ1990' and 'ocscore'. */
    replace bc`i'=1 if bc`i'>=ocscore
    replace bc`i'=0 if bc`i'!=1
}
save $ResultD/oral_rescale_c.dta,replace

collapse (mean) bc*  [pw=perwt]
gen id = 1
reshape long bc, i(id) j(group)
drop id 
// until now the dataset contains rescaled oral comprehension score for each group (or occ1990)
merge 1:1 group using $ResultD/oral_expression_rescale.dta
// put the rescaled oral expression score and comprehension score together
drop _merge
gen oral_rescale=(be+bc)/2 
// take the average as the final recaled oral score
save $ResultD/oral_rescale_ready_merge.dta, replace

use $ResultD/10_prepare_rescale.dta, clear
merge m:1 group using $ResultD/oral_rescale_ready_merge.dta
keep occ1990 JobZone highskill low_skill_share oral_rescale 
duplicates drop
save $ResultD/occ1990_and_oral_rescale_score.dta, replace
// In this dataset, every occ1990 has a recaled oral score, 
// as well as other indicators of education needed for future use


/*************************************************************************
Step 5, rank the 324 manufacturing occupations from low to high, based on the rescaled oral scores calculated from last step(for main analysis). Also keep only those occ1990 occupations which at least 50% of the SOC occupations do not require any college education, rank the rescaled oral scores froom low to high(for robustness check).
*************************************************************************/
use $ResultD/occ1990_and_oral_rescale_score.dta, clear
** keep all those 324 occupations
sort oral_rescale
egen p25 = pctile(oral_rescale), p(25)
egen p50 = pctile(oral_rescale), p(50)
egen p75 = pctile(oral_rescale), p(75)
save $ResultD/AllOcc_Oral.dta, replace

use $ResultD/AllOcc_Oral.dta
keep if oral_rescale<=p25
save $ResultD/AllOcc_Oral_p25.dta, replace // it captures those oral score from 0 - 25 pctile

use $ResultD/AllOcc_Oral.dta
keep if oral_rescale<=p50 & oral_rescale>p25
save $ResultD/AllOcc_Oral_p25_50.dta, replace // it captures those oral score from 25(not included)  - 50 pctile

use $ResultD/AllOcc_Oral.dta
keep if oral_rescale>p50 & oral_rescale<=p75
save $ResultD/AllOcc_Oral_p50.dta, replace // it captures those oral score from 50(not included) - 75 pctile

use $ResultD/AllOcc_Oral.dta
keep if oral_rescale>p75
save $ResultD/AllOcc_Oral_p75.dta, replace // it captures those oral score from 75(not included) - 100 pctile

** keep only those low skilled occupations
use $ResultD/occ1990_and_oral_rescale_score.dta, clear 
keep if low_skill_share >= 50
egen p25 = pctile(oral_rescale), p(25)
egen p50 = pctile(oral_rescale), p(50)
egen p75 = pctile(oral_rescale), p(75)
save $ResultD/LowSkillOcc_Oral.dta, replace

keep if oral_rescale<=p50 & oral_rescale>p25
save $ResultD/LowSkillOcc_Oral_p25_50.dta, replace

use $ResultD/LowSkillOcc_Oral.dta
keep if oral_rescale<=p25
save $ResultD/LowSkillOcc_Oral_p25.dta, replace

use $ResultD/LowSkillOcc_Oral.dta
keep if oral_rescale>p50 & oral_rescale<=p75
save $ResultD/LowSkillOcc_Oral_p50.dta, replace

use $ResultD/LowSkillOcc_Oral.dta
keep if oral_rescale>p75
save $ResultD/LowSkillOcc_Oral_p75.dta, replace

/*************************************************************************
Step 6, match the rescaled oral scores and quantile groups of each occ1990 with all the currently employed workers in our main immigrant dataset. 
*************************************************************************/

use $ResultD/FBsampleCZ,  clear
keep if empstat == 1
* refine the inconsistent occ1990
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

merge m:1 occ1990 using $ResultD/occ1990_and_oral_rescale_score.dta
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

merge m:1 occ1990 using $ResultD/AllOcc_Oral_p25
gen oral_all_p25 = (_merge == 3)
replace oral_all_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using $ResultD/AllOcc_Oral_p25_50
gen oral_all_p25_50 = (_merge == 3)
replace oral_all_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using $ResultD/AllOcc_Oral_p50
gen oral_all_p50 = (_merge == 3)
replace oral_all_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using $ResultD/AllOcc_Oral_p75
gen oral_all_p75= (_merge == 3 )
replace oral_all_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge


merge m:1 occ1990 using $ResultD/LowSkillOcc_Oral_p25
gen oral_lowsk_p25= (_merge == 3 )
replace oral_lowsk_p25 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using $ResultD/LowSkillOcc_Oral_p25_50
gen oral_lowsk_p25_50= (_merge == 3 )
replace oral_lowsk_p25_50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using $ResultD/LowSkillOcc_Oral_p50
gen oral_lowsk_p50= (_merge == 3 )
replace oral_lowsk_p50 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

merge m:1 occ1990 using $ResultD/LowSkillOcc_Oral_p75
gen oral_lowsk_p75= (_merge == 3 )
replace oral_lowsk_p75 = 0 if empstatd == 0 | empstatd >= 20
drop _merge

run "collapsedifs_oral_occ.do"

keep czone t2 manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d   ///
d_oral_lowsk_p25_50  d_oral_all_p25_50 d_oral_all_p25  d_oral_all_p50 d_oral_all_p75 d_oral_lowsk_p25  d_oral_lowsk_p50 d_oral_lowsk_p75 ///
oral_all_p25_50 oral_lowsk_p25_50 oral_all_p25  oral_all_p50 oral_all_p75 oral_lowsk_p25   oral_lowsk_p50 oral_lowsk_p75 
 
save $ResultD/depvar, replace

use $ResultD/FBsampleCZ, clear 
run "collapsedifs.do"
drop manu_d ser_d manage_d sale_d farm_d  ///
d_manu_d d_ser_d d_manage_d d_sale_d d_farm_d    // since those occupational employment changes are created based on all population, not the employed changes among employed. We only need the import shock levels and CZ level controls. 
merge 1:1 czone t2 using $ResultD/depvar
save $ResultD/oral_emp_eff.dta, replace




