**************************************************************
*Append and clean student entrance files
*Keep non-transfer, first time freshmen
*merge in race variables
*May 16, 2018
**************************************************************
 

***************************************************************************
*Input files:
local in "$mydir/Dropbox/OLDA/Combined_HEI_Files/hei_stud_entrance_SM99-SP17.dta"
local race "$mydir/Dropbox/OLDA/Combined_Hei_Files/hei_race_ethnic_29jan16.dta"

*Final output file:
local out "Intermediate_Data/All_Campuses/Entrance_allOH_Und_FirstTime.dta"
***************************************************************************



use `in', clear

*keep only undergrad students
*Note: first-time freshmen at Toledo are mis-classified as admis=="HGH" in 2013
keep if admis_area=="UND" | (admis_area=="HGH" & inst_code=="TLDO" & first_enroll_yr_num==2013)
*keep only first-time students
keep if first_time_in_college=="Y"


*Note: there are 5 students with duplicate observations in the entrance file
duplicates tag hei_psid inst_code, gen(dups)
tab dups
*4 of these are true duplicates (the same person)
*For these, keep the one that represents earliest
duplicates tag hei_psid inst_code sex_code birth_yr race_ethnic_code, gen(temp)
tab temp
bysort hei_psid inst_code (yr_num): gen todrop=(yr_num!=yr_num[1])
drop if todrop==1 & temp==1
drop todrop temp dups
duplicates drop hei_psid inst_code, force


***merge in race_ethnicity codes (they change in 2009) ***
*change year and term for 2015-2017 obs so that they match
replace yr_num=yr_num-1 if yr_num==2016
replace yr_num=yr_num-2 if yr_num==2017
merge m:1 race yr_num term_code using `race'
drop if _merge==2
replace race_ethnic_code="AS" if race_ethnic_code=="HP"
replace race_ethnic_code="UK" if race_ethnic_code=="MR"
*drop unneeded variables
drop yr_num term_code first_time key_id _merge log_ord 


save `out', replace
