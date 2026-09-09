cap log close
clear all
set more off



do set_path.do
cd "$root"




use "Public Data/NLSY97 Public.dta"
merge 1:1 PUBID_1997 KEY_SEX_1997 KEY_BDATE_M_1997 KEY_BDATE_Y_1997 KEY_RACE_ETHNICITY_1997 using "Public Data/NLSY97_2013/NLSY97_2013.dta"
drop _merge



* College *

	tab YSCH_5000_1997
	

	gen college_1997 = 1 	if YSCH_5000_1997 >= 13 & YSCH_5000_1997 <= 20
	replace college_1997 = 0 if YSCH_5000_1997 >= 0 & YSCH_5000_1997 <= 12


	forvalues y=1998(1)2013{
	if `y' == 2012{
	continue
	}	
		gen aux_college_`y' = 0 if YSCH_3112_`y' >= 0 	& YSCH_3112_`y' <= 12
		replace aux_college_`y' = 1 if YSCH_3112_`y' >= 13 	& YSCH_3112_`y' <= 20
	
	}

	forvalues y=1998(1)2013{
	if `y' == 2012{
	continue
	}
		egen college_`y' = rowmax(college_1997 aux_college_1998 - aux_college_`y') if YSCH_3112_`y' != -5
		}
	
	
	
* Bachelors *

	gen bachelors_1997 = 0 		if YSCH_5000_1997 >= 0 & YSCH_5000_1997 < 16
	replace bachelors_1997 = 1 	if YSCH_5000_1997 >= 16 & YSCH_5000_1997 <= 20

forvalues y = 1998(1)2013{
	if `y' == 2012{
	continue
	}
	tab YSCH_3112_`y'
	
	gen aux_bachelors_`y' = 0 		if YSCH_3112_`y' >= 0  & YSCH_3112_`y' < 16
	replace aux_bachelors_`y' = 1 	if YSCH_3112_`y' >= 16 & YSCH_3112_`y' <= 20
	
	}


forvalues y = 1998(1)2013{
	if `y' == 2012{
	continue
	}
	egen bachelors_`y' = rowmax(bachelors_1997 aux_bachelors_1998 - aux_bachelors_`y') if YSCH_3112_`y'!=-5
}	

* Some College, Incomplete *

gen incmp_college_1997 = 0 			if YSCH_5000_1997 >= 0 & YSCH_5000_1997 <= 12
replace incmp_college_1997 = 1 		if YSCH_5000_1997 >= 13 & YSCH_5000_1997 <= 15
replace incmp_college_1997 = 1 		if YSCH_4000_1997 == 16 & YSCH_5000_1997 <= 15
replace incmp_college_1997 = 0 		if YSCH_5000_1997 >= 16 & YSCH_5000_1997 <= 20

	forvalues y = 1998(1)2013{
	if `y' == 2012{
	continue
	}
	gen aux_incmp_college_`y' = 0 		if YSCH_3112_`y' >= 0 & YSCH_3112_`y' <= 12
	replace aux_incmp_college_`y' = 1 	if YSCH_3112_`y' >= 13 & YSCH_3112_`y' <= 15
	replace aux_incmp_college_`y' = 1 	if YSCH_2857_`y' == 16 & YSCH_3112_`y' <= 15
	replace aux_incmp_college_`y' = 0 	if YSCH_3112_`y' >= 16 & YSCH_3112_`y' <= 20
	}

forvalues y = 1998(1)2013{
	if `y' == 2012{
	continue
	}
	egen incmp_college_`y' = rowlast(incmp_college_1997 aux_incmp_college_1998 - aux_incmp_college_`y') if YSCH_3112_`y'!=-5
}		
	
* Attended first year or more *

	gen first_year_1997 = 1 		if CV_ENROLLSTAT_1997 == 9 | CV_ENROLLSTAT_1997 == 10
	replace first_year_1997 = 0 	if CV_ENROLLSTAT_1997 >=1 & CV_ENROLLSTAT_1997 <= 8


	forvalues y=1998(1)2013{
	if `y' == 2012{
	continue
	}
		
		gen aux_first_year_`y' = 0 		if YSCH_2857_`y' >= 0 	& YSCH_2857_`y' <= 12
		replace aux_first_year_`y' = 0 	if YSCH_3112_`y' >= 0 	& YSCH_3112_`y' <= 12
		replace aux_first_year_`y' = 1 	if YSCH_2857_`y' >= 13 	& YSCH_2857_`y' <= 20
		replace aux_first_year_`y' = 1 	if YSCH_3112_`y' >= 13 	& YSCH_3112_`y' <= 20
	
	}

	forvalues y=1998(1)2013{
	if `y' == 2012{
	continue
	}
		egen first_year_`y' = rowmax(first_year_1997 aux_first_year_1998 - aux_first_year_`y') if YSCH_2857_`y' != -5 | YSCH_3112_`y' != -5
		}	
	

** Number of years of post-secondary education **

	gen years_college_1997 = cond(YSCH_5000_1997 >= 13, YSCH_5000_1997-12, 0) if YSCH_5000_1997>=0 & YSCH_5000_1997<=20
	
	forvalues y = 1998/2013{
	if `y' == 2012{
	continue
	}
		gen aux_years_college_`y' = cond(YSCH_3112_`y' >= 13, YSCH_3112_`y' - 12, 0) if YSCH_3112_`y'>=0 & YSCH_3112_`y'<=20
		}
	
	forvalues y=1998(1)2013{
	if `y' == 2012{
	continue
	}
		egen years_college_`y' = rowmax(years_college_1997 aux_years_college_1998 - aux_years_college_`y') if YSCH_3112_`y' != -5 
		}
		
		
** Completed at least 2, 3, 4:

	forvalues y=1997/2013{
	if `y' == 2012{
	continue
	}
	forvalues grade = 1/4{
	gen completed`grade'_`y' = cond(years_college_`y' >= `grade' , 1, 0) if years_college_`y' != .
	}
	}
	
** Associates **
	mmerge PUBID_1997 using "Public Data/highest_degree_2013/highest_degree_2013.dta", _merge(hm)
	drop hm
	
	gen associates_1997 = (CV_HIGHEST_DEGREE_EVER_1997 == 3) if CV_HIGHEST_DEGREE_EVER_1997 >= 0
	forvalues y = 1998/2013{
	if `y' == 2012{
	continue
	}
	gen associates_`y' = (CV_HIGHEST_DEGREE_EVER_EDT_`y' == 3) if CV_HIGHEST_DEGREE_EVER_EDT_`y' >= 0
	gen associates_more_`y' = (CV_HIGHEST_DEGREE_EVER_EDT_`y' >= 3) if CV_HIGHEST_DEGREE_EVER_EDT_`y' >= 0
	}
	
	
** Employment **

	forvalues y = 1997(1)2013{
	if `y' == 2012{
	continue
	}
		egen employed_`y' = anymatch(YEMP_CURFLAG_*_`y'), values(1)
		replace employed_`y' = . if YEMP_CURFLAG_01_`y'==-5
		
		
	}
	
		forvalues y = 1997(1)2001{
		egen employedFL_`y' = anymatch(YEMP_110200_*_`y'), values (1)
		replace employed_`y' = 1 if employedFL_`y' == 1
		}
		
** Original Region, MSA, Urban/Rural **

	gen region97=CV_CENSUS_REGION_1997
	label values region97 vlR7222400

	gen msa97=CV_MSA_1997
	label values msa97 vlR7237200

	tab region97
	tab msa97

* Merge to parental education *
keep PUBID_* KEY_SEX_* KEY_BDATE_M_* KEY_BDATE_Y_* KEY_RACE_ETHNICITY_* CV_CENSUS_REGION_* CV_URBAN_RURAL_* college_* SAMPLING_WEIGHT_CC_* SAMPLING_PANEL_WEIGHT_* region97 msa97 bachelors_* first_year_* incmp_college_* years_college_* completed* employed_* associates_*
sort PUBID_1997

mmerge PUBID_1997 KEY_SEX_1997 KEY_BDATE_M_1997 KEY_BDATE_Y_1997 KEY_RACE_ETHNICITY_1997 using "$publicdata\NLSY97_Parental_Educ\NLSY97_Parental_Educ.dta", type(1:1) _merge(m_parent_educ)
assert m_parent_educ ==3
drop m_parent_educ

local parents = "DAD MOM"
foreach parent of local parents{
gen `parent'_educ = .
	replace `parent'_educ = 1 if CV_HGC_BIO_`parent'_1997 == -4 | CV_HGC_BIO_`parent'_1997 == -3 | CV_HGC_BIO_`parent'_1997 == 95
	replace `parent'_educ = 2 if CV_HGC_BIO_`parent'_1997 >= 1 & CV_HGC_BIO_`parent'_1997 <= 11
	replace `parent'_educ = 3 if CV_HGC_BIO_`parent'_1997 == 12
	replace `parent'_educ = 4 if CV_HGC_BIO_`parent'_1997 >= 13 & CV_HGC_BIO_`parent'_1997 <= 15
	replace `parent'_educ = 5 if CV_HGC_BIO_`parent'_1997 >= 16 & CV_HGC_BIO_`parent'_1997 <= 20
	tab CV_HGC_BIO_`parent'_1997 `parent'_educ, m
	}
	rename DAD_educ fathers_educ
	rename MOM_educ mothers_educ
	
	label def parental_educ 1 "Missing"
	label def parental_educ 2 "No HS Degree", add
	label def parental_educ 3 "HS Degree", add
	label def parental_educ 4 "Some College", add
	label def parental_educ 5 "Bachelor's+", add
	
	label val fathers_educ parental_educ
	label val mothers_educ parental_educ

* Merge to cognitive scores *

mmerge PUBID_1997 KEY_SEX_1997 KEY_BDATE_M_1997 KEY_BDATE_Y_1997 KEY_RACE_ETHNICITY_1997 using "$publicdata\NLSY97_Cogn_Scores\NLSY97_Cogn_Scores.dta", type(1:1) _merge(m_cogn_scores)
assert m_cogn_scores ==3
drop m_cogn_scores	

gen asvab = ASVAB/1000 if ASVAB>= 0
gen asvab_missing = cond(ASVAB <0, 1, 0)
replace asvab = 0 if asvab_missing == 1

* Merge to extra employment data *
mmerge PUBID_1997 KEY_SEX_1997 KEY_BDATE_M_1997 KEY_BDATE_Y_1997 KEY_RACE_ETHNICITY_1997 using "$publicdata\NLSY97_Extra_Employment\NLSY97_Extra_Employment.dta", type(1:1) _merge(m_extra_employ)
assert m_extra_employ == 3
drop m_extra_employ

	foreach var of varlist CV_WKSWK_DLI_ALL_????{
	replace `var' = . if `var' == -5 | `var' == -3
	assert `var' >= 0
	}

	foreach var of varlist CV_WKSWK_DLI_????{
	replace `var' = . if `var' < 0 
	}

	foreach var of varlist CV_WKSWK_DLI_ET_????{
	replace `var' = . if `var' == -5 | `var' == -3
	assert `var' >= 0
	}

	local employment_varlist = "CVC_WKSWK_TEEN_XRND CVC_WKSWK_ADULT_ET_XRND CVC_WKSWK_ADULT_ALL_XRND CVC_HOURS_WK_TEEN_XRND CVC_HOURS_WK_ADULT_ET_XRND CVC_HOURS_WK_ADULT_ALL_XRND"
	foreach var of local employment_varlist{
	replace `var' = . if `var' == -3
	assert `var' >= 0
	sum `var'
	}

	* # weeks worked in ET job between 2000 - 2006
	egen wks_worked_00_06_et = rowtotal(CV_WKSWK_DLI_ET_2000 CV_WKSWK_DLI_ET_2001 CV_WKSWK_DLI_ET_2002 CV_WKSWK_DLI_ET_2003 CV_WKSWK_DLI_ET_2004 CV_WKSWK_DLI_ET_2005 CV_WKSWK_DLI_ET_2006), missing
	
	* # weeks worked in any job between 2000-2006
	egen wks_worked_00_06_all = rowtotal(CV_WKSWK_DLI_ALL_2000 CV_WKSWK_DLI_ALL_2001 CV_WKSWK_DLI_ALL_2002 CV_WKSWK_DLI_ALL_2003 CV_WKSWK_DLI_ALL_2004 CV_WKSWK_DLI_ALL_2005 CV_WKSWK_DLI_ALL_2006), missing
	
	* ever employed: weeks worked (et, all), and rowmax of employed_(year)
	
	gen ever_employed_v1_et = (wks_worked_00_06_et >= 52) if wks_worked_00_06_et != . 
	gen ever_employed_v1_all = (wks_worked_00_06_all >= 52 ) if wks_worked_00_06_all != . 
	egen ever_employed_v2 = rowmax(employed_????)
	
	* # years employed in ET/any job between 2000-2006 
	gen years_worked_00_06_et = wks_worked_00_06_et/52
	gen years_worked_00_06_all = wks_worked_00_06_all/52
	
	drop CV_WKSWK_DLI_1997- CVC_HOURS_WK_ADULT_ALL_XRND

** Merging with household income **
preserve

	clear
	import delimited "$publicdata\Income\Income.csv", case(preserve)
	run "$publicdata\Income\Income-value-labels.do"
	
	keep CV_INCOME_GROSS_YR_1997 PUBID_1997
	replace CV_INCOME_GROSS_YR_1997 = . 		if CV_INCOME_GROSS_YR_1997 <=0
	
	gen missing_parent_inc = cond(CV_INCOME_GROSS_YR_1997 == ., 1, 0)
	gen log_gross_hh_income = ln(CV_INCOME_GROSS_YR_1997)
	recode log_gross_hh_income (.= 0)
	
	tab missing_parent_inc
	drop CV_INCOME_GROSS_YR_1997
	save "$publicdata\Income\parental_income.dta", replace

restore	
	
	mmerge PUBID_1997 using "$publicdata\Income\parental_income.dta", t(1:1) _merge(m_pi)
	drop m_pi
	
* Merge to geocoded data *
sort PUBID_1997
merge 1:1 PUBID_1997 KEY_SEX_1997 KEY_BDATE_M_1997 KEY_BDATE_Y_1997 KEY_RACE_ETHNICITY_1997 using "$cleaned\NLSY_Location_1997.dta" 

keep if _merge == 3

save "$cleaned\NLSY_Survey_Merged_1997_v2.dta", replace

* Create metarea variable matching Housing Boom Indicator *
use "$cleaned\NLSY_Survey_Merged_1997_v2.dta", clear

rename R1242900 COUNTY_1997
rename R1243200 PMSA_1997
rename R1243000 STATE_1997

rename R5521300 COUNTY_2000
rename R5521400 STATE_2000
rename R5521600 PMSA_2000

forvalues y = 1997(3)2000{
recode MSA_`y' (-4 = .)
recode PMSA_`y' (-4 = .)


gen metarea_`y' = .
gen flag_low_boom_`y' = .



** 1123 **
replace metarea_`y' = 120 if MSA_`y' == 1123 & COUNTY_`y' == 23
replace metarea_`y' = 924 if MSA_`y' == 1123 & COUNTY_`y' == 27
replace metarea_`y' = 112 if MSA_`y' == 1123 & COUNTY_`y' != 27 & COUNTY_`y' != 23


** 1303 **
replace metarea_`y' = 131 if MSA_`y' == 1303
replace flag_low_boom_`y' = 1 if metarea_`y' == 131

** 1602 (Chicago) ** 
replace metarea_`y' = 160 if MSA_`y' == 1602 & PMSA_`y' == 1600
replace metarea_`y' = 160 if MSA_`y' == 1602 & PMSA_`y' == 2960
replace metarea_`y' = 374 if MSA_`y' == 1602 & PMSA_`y' == 3740

** 1642 (Cincinnati, OH/KY/IN) **
replace metarea_`y' = 164 if MSA_`y' == 1642 & PMSA_`y' == 1640
replace metarea_`y' = 320 if MSA_`y' == 1642 & PMSA_`y' == 3200

** 1692 (Cleveland, etc.) **
replace metarea_`y' = 168 if MSA_`y' == 1692 & PMSA_`y' == 1680
replace metarea_`y' = 8 if MSA_`y' == 1692 & PMSA_`y' == 80

** 1922 **
replace metarea_`y' = 192 if MSA_`y' == 1922

** 2082 (Denver-Boulder-Greeley, CO) **
replace metarea_`y' = 208 if MSA_`y' == 2082 & PMSA_`y' == 1125
replace metarea_`y' = 208 if MSA_`y' == 2082 & PMSA_`y' == 2080
replace metarea_`y' = 306 if MSA_`y' == 2082 & PMSA_`y' == 3060

** 2162 (Detroit-Ann Arbor-Flint, MI) **
replace metarea_`y' = 216 if MSA_`y' == 2162 & PMSA_`y' == 2160
replace metarea_`y' = 44 if MSA_`y' == 2162 & PMSA_`y' == 440
replace metarea_`y' = 264 if MSA_`y' == 2162 & PMSA_`y' == 2640

** 2340 (Enid, OK) **
replace metarea_`y' = 234 if MSA_`y' == 2340
replace flag_low_boom_`y' = 1 if metarea_`y' == 234

** 2655 **
replace metarea_`y' = 266 if MSA_`y' == 2655
replace flag_low_boom_`y' = 1 if metarea_`y' == 266

** 3000 (Grand Rapids/Muskegon/Holland, MI) **
replace metarea_`y' = 300 if MSA_`y' == 3000

** 3362 (Houston-Galveston-Brazoria, TX)
replace metarea_`y' = 336 if MSA_`y' == 3362 & PMSA_`y' == 1145
replace metarea_`y' = 292 if MSA_`y' == 3362 & PMSA_`y' == 2920
replace metarea_`y' = 336 if MSA_`y' == 3362 & PMSA_`y' == 3360

** 3600 **
replace metarea_`y' = 359 if MSA_`y' == 3600 & STATE_`y' == 12

** 3720 (Kalamazoo/Battle Creek, MI) **
replace metarea_`y' = 372 if MSA_`y' == 3720 & COUNTY_`y' == 25
replace metarea_`y' = 372 if MSA_`y' == 3720 & COUNTY_`y' == 77
replace metarea_`y' = 372 if MSA_`y' == 3720 & COUNTY_`y' == 159

** 4472 (LA, etc.) **
replace metarea_`y' = 873 if MSA_`y' == 4472 & PMSA_`y' == 8735
replace metarea_`y' = 448 if MSA_`y' == 4472 & PMSA_`y' == 4480
replace metarea_`y' = 448 if MSA_`y' == 4472 & PMSA_`y' == 5945
replace metarea_`y' = 678 if MSA_`y' == 4472 & PMSA_`y' == 6780

** 4992 Miami Fort Lauderdale **
replace metarea_`y' = 268 if MSA_`y' == 4992 & PMSA_`y' == 2680
replace metarea_`y' = 500 if MSA_`y' == 4992 & PMSA_`y' == 5000

** 5082	Milwaukee-Racine, WI **
replace metarea_`y' = 660 if MSA_`y' == 5082 & PMSA_`y' == 6600
replace metarea_`y' = 508 if MSA_`y' == 5082 & PMSA_`y' == 5080

** 5483 New Haven/Bridgeport/ Stamford/Waterbury/Danbury, CT **
replace metarea_`y' = 548 if MSA_`y' == 5483 & COUNTY_`y' == 9
replace metarea_`y' = 1001 if MSA_`y' == 5483 & COUNTY_`y' != 9

** 5602 **
replace metarea_`y' = 560 if MSA_`y' == 5602 & PMSA_`y' == 5600
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==37
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==41
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==87
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==19
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==23
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==39
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==3
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==5
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==27 & PMSA_`y' == 5640
replace metarea_`y' = 228 if MSA_`y' == 5602 & COUNTY_`y' ==27 & PMSA_`y' == 2281
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==85
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==81
replace metarea_`y' = 848 if MSA_`y' == 5602 & COUNTY_`y' ==21
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==59
replace metarea_`y' = 519 if MSA_`y' == 5602 & COUNTY_`y' ==25
replace metarea_`y' = 519 if MSA_`y' == 5602 & COUNTY_`y' ==29
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==61
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==47
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==103
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==35
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==17
replace metarea_`y' = 566 if MSA_`y' == 5602 & COUNTY_`y' ==71
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==31
replace metarea_`y' = 560 if MSA_`y' == 5602 & COUNTY_`y' ==13

** 6162 **
replace metarea_`y' = 616 if MSA_`y' == 6162 & PMSA_`y' == 6160
replace metarea_`y' = 876 if MSA_`y' == 6162 & PMSA_`y' == 8760
replace metarea_`y' = 916 if MSA_`y' == 6162 & PMSA_`y' == 9160

** 6240 ** 
replace metarea_`y' = 440 if MSA_`y' == 6240

** 6442 **
replace metarea_`y' = 644 if MSA_`y' == 6442 & PMSA_`y' == 6440

** 6660 **
replace metarea_`y' = 666 if MSA_`y' == 6660
replace flag_low_boom_`y' = 1 if metarea_`y' == 666

** 6895 **
replace metarea_`y' = 689 if MSA_`y' == 6895 

** 7362 **
replace metarea_`y' = 736 if MSA_`y' == 7362 & COUNTY_`y' == 95
replace metarea_`y' = 736 if MSA_`y' == 7362 & COUNTY_`y' == 13
replace metarea_`y' = 748 if MSA_`y' == 7362 & COUNTY_`y' == 87
replace metarea_`y' = 736 if MSA_`y' == 7362 & COUNTY_`y' == 41
replace metarea_`y' = 736 if MSA_`y' == 7362 & COUNTY_`y' == 75
replace metarea_`y' = 750 if MSA_`y' == 7362 & COUNTY_`y' == 97
replace metarea_`y' = 736 if MSA_`y' == 7362 & COUNTY_`y' == 1
replace metarea_`y' = 740 if MSA_`y' == 7362 & COUNTY_`y' == 85
replace metarea_`y' = 736 if MSA_`y' == 7362 & COUNTY_`y' == 81

** 7602 **
replace metarea_`y' = 760 if MSA_`y' == 7602 & PMSA_`y' == 7600
replace metarea_`y' = 820 if MSA_`y' == 7602 & PMSA_`y' == 8200
replace metarea_`y' = 115 if MSA_`y' == 7602 & PMSA_`y' == 1150
replace metarea_`y' = 591 if MSA_`y' == 7602 & PMSA_`y' == 5910

** 8360 **
replace metarea_`y' = 836 if MSA_`y' == 8360
replace flag_low_boom_`y' = 1 if metarea_`y' == 836

** 8872 **
replace metarea_`y' = 72 if MSA_`y' == 8872 & PMSA_`y' == 720
replace metarea_`y' = 884 if MSA_`y' == 8872 & PMSA_`y' == 8840

** 6922 Sacramento **
replace metarea_`y' = 692 if MSA_`y' == 6922 & PMSA_`y' == 6920
replace metarea_`y' = 927 if MSA_`y' == 6922 & PMSA_`y' == 9270

** 3283 Hartford CT **
replace metarea_`y' = 328 if MSA_`y' == 3283

** 743 Barnstable **
replace metarea_`y' = 74 if MSA_`y' == 743

** 3605 Jacksonville NC **
replace metarea_`y' = 360 if MSA_`y' == 3605

** 5345
replace metarea_`y' = 534 if MSA_`y' == 5345

** 5523
replace metarea_`y' = 552 if MSA_`y' == 5523

** 6403
replace metarea_`y' = 640 if MSA_`y' == 6403

** 6483
replace metarea_`y' = 648 if MSA_`y' == 6483

gen MSA_string_`y' = string(MSA_`y')
gen length_`y' = length(MSA_string_`y')
replace length_`y' = length_`y' - 1
gen tail_`y' = substr(MSA_string_`y', -1, 1)
gen front_`y' = substr(MSA_string_`y', 1, length_`y') if tail_`y' == "0"
destring front_`y', replace

replace metarea_`y' = front_`y' if tail_`y' == "0" & metarea_`y' == .
drop MSA_string_`y' length_`y' tail_`y' front_`y'

tab MSA_`y' if metarea_`y' == .
}
* Merge with housing boom indicator *
forvalues y = 1997(3)2000{
rename metarea_`y' metarea
mmerge metarea using "$indicatorfile", type(n:1) _merge(indicator_merge_`y') ukeep(iv2_log) urename(iv2_log iv2_log_`y')
rename metarea metarea_`y'

	* Weighting three connecticut metarea values *

		local weight_116 = 0.42
		local weight_804 = 0.35
		local weight_193 = 0.23

		local ct_metarea = "116 804 193"
		foreach x of local ct_metarea{
		sum iv2_log_`y' if metarea_`y' == `x'
		local iv2_log_`x' = (`weight_`x''*r(mean))
		}

		replace iv2_log_`y' = (`iv2_log_116' + `iv2_log_804' + `iv2_log_193') if metarea_`y' == 1001

		replace indicator_merge_`y' = 3 if metarea_`y' == 1001
		
drop if indicator_merge_`y' == 2

label var flag_low_boom_`y' "1 if not in our data"
}
* Merge with version 2 of metarea controls *
forvalues y = 1997(3)2000{
gen metarea2_`y' = metarea_`y' 
	replace metarea2_`y' = 112 if metarea_`y' == 924 | metarea_`y' == 120
	replace metarea2_`y' = 560 if metarea_`y' == 519 
	replace metarea2_`y' = 548 if metarea_`y' == 1001

rename metarea2_`y' metarea

mmerge metarea using "$root\Housing Indicator\for_nlsy_v2.dta", type(n:1) _merge(controls_merge_`y') 
drop if controls_merge_`y' == 2

	rename region region_`y' 
	rename pop_prev pop_prev_`y' 
	rename college_share_2000 college_share_2000_`y' 
	rename female_employed_share_2000 fes_2000_`y' 
	rename reg4 reg4_`y' 
	rename assoc_share_1990 assoc_share_1990_`y' 
	rename missing_1990_data missing_1990_data_`y' 
	rename bachelor_share_1990 bachelor_share_1990_`y'
	rename assoc_share_2000 assoc_share_2000_`y'
	rename bachelor_share_2000 bachelor_share_2000_`y'
drop metarea

gen D_assoc_share_`y' = assoc_share_2000_`y' - assoc_share_1990_`y' if missing_1990_data_`y' == 0
replace D_assoc_share_`y' = 0 if missing_1990_data_`y' == 1

gen D_bachelor_share_`y' = bachelor_share_2000_`y' - bachelor_share_1990_`y' if missing_1990_data_`y' == 0
replace D_bachelor_share_`y' = 0 if missing_1990_data_`y' == 1
}
save "$cleaned\NLSY_1997_Cleaned_v2.dta", replace

** Merging with version 2 of housing indicator **
forvalues y = 1997(3)2000{
gen metarea2_`y' = metarea_`y' 
	replace metarea2_`y' = 112 if metarea_`y' == 120
	replace metarea2_`y' = 116 if metarea_`y' == 1001

	mmerge metarea2_`y' KEY_BDATE_Y_1997 using "$root\Housing Indicator\Alternative_Housing_Indicator.dta", t(n:1) _merge(merge_alt_housing_ind_`y') nolabel umatch(metarea KEY_BDATE_Y_1997)
	
	rename demand_change demand_change_`y'
	
drop metarea2_`y'
drop if merge_alt_housing_ind_`y' == 2
}

save "$cleaned\NLSY_1997_Cleaned_v2.dta", replace

