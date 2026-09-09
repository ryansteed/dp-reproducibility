/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
File created:	12/28/2019
Last modified: 	12/28/2019
Modified by:	Dustin Swonder
Description:	This file compiles various raw data sets from the ACS 2010, 
				Census 2000, and Census 2010 to yield the dataset 
				demographics_census_2000_2010_bycounty.dta, which is an input
				to analysis datasets.
*******************************************************************************/

set more off

********************************************************************************
******************************** 0. ENVIRONMENT ********************************
********************************************************************************

global acsdir	 "$rawdir/acs_census_raw"

********************************************************************************
******************************** 1. CLEAN 2010 *********************************
********************************************************************************


********* 2010, DEMOGRAPHICS ********

import delimited using $acsdir/census2010/DEC_10_DP_DPDP1_with_ann.csv, ///
	clear case(preserve)


/*Variables of interest:
HD01_S001	Number; SEX AND AGE - Total population
HD01_S078	Number; RACE - Total population - One Race - White
HD01_S107	Number; HISPANIC OR LATINO - Total population - Hispanic or Latino (of any race)
*/

keep GEOid2 /*GEOdisplaylabel*/ HD01_S001 HD01_S078 HD01_S107

rename (GEOid2 /*GEOdisplaylabel*/) (fipscounty /*county_state*/) 

* Clean up annotated variables
foreach var in HD01_S001 {
	split `var', parse("(")
	drop `var' `var'2

	destring `var'1, replace
	rename `var'1 `var'
}

*Rename vars
rename (HD01_S001 HD01_S078 HD01_S107) (pop white hispanic)

*Replace white and hispanic levels with share of total county pop
replace white = white/pop*100
replace hispanic = hispanic/pop*100

*Rename variables for 2010
foreach var in pop white hispanic{
	rename `var' `var'_2010
}

tempfile 2010
save `2010'

********* 2010, URBAN V RURAL ********

import delimited using $acsdir/census2010/DEC_10_SF1_H2_with_ann.csv, clear case(preserve) varnames(1)

keep GEOid2 D001 D002

* Clean up annotated variables
foreach var in D001 {
	split `var', parse("(")
	drop `var' `var'2

	destring `var'1, replace
	rename `var'1 `var'
}


rename (GEOid2) (fipscounty) 

rename D002 urban

replace urban = urban/D001*100

drop D001

rename urban urban_2010

merge 1:1 fipscounty using `2010', nogen assert(3)

save `2010', replace

********* 2010, FOREIGN-BORN ********

import delimited using $acsdir/acs2010/ACS_10_1YR_B06003_with_ann.csv, clear case(preserve) varnames(1)

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 HD01_VD01 HD01_VD14

rename (GEOid2) (fipscounty) 

rename HD01_VD14 foreign

replace foreign = foreign/HD01_VD01*100

drop HD01_VD01

rename foreign foreign_2010

merge 1:1 fipscounty using `2010', nogen 

save `2010', replace

********* 2010, SHARE W BA ********

import delimited using $acsdir/acs2010/ACS_10_1YR_S1501_with_ann.csv, clear case(preserve) varnames(1)

/*
HC01_EST_VC17	Total; Estimate; Percent bachelor's degree or higher
*/

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 HC01_EST_VC17

rename GEOid2 fipscounty

rename HC01_EST_VC17 ba_over25_2010

merge 1:1 fipscounty using `2010', nogen 

save `2010', replace

********* 2010, MEDIAN OWNER-OCCUPIED HOUSING VALUE ********

import delimited using $acsdir/acs2010/ACS_10_1YR_B25077_with_ann.csv, clear case(preserve) varnames(1)

/*
HD01_VD01	Estimate; Median value (dollars)
*/

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 HD01_VD01

rename GEOid2 fipscounty

rename HD01_VD01 median_houvalue_2010

g year = 2010

adjust_inflation median_houvalue_2010, year(2017)

drop year

merge 1:1 fipscounty using `2010', nogen 

save `2010', replace


********* 2010, MEDIAN GROSS RENT ********

import delimited using $acsdir/acs2010/ACS_10_1YR_B25064_with_ann.csv, clear case(preserve) varnames(1)

/*
HD01_VD01	Estimate; Median gross rent
*/

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 HD01_VD01

rename GEOid2 fipscounty

rename HD01_VD01 median_grossrent_2010

g year = 2010

adjust_inflation median_grossrent_2010, year(2017)

drop year

merge 1:1 fipscounty using `2010', nogen 

save `2010', replace

********* 2010, # HOUSING UNITS ********

import delimited using $acsdir/acs2010/ACS_10_1YR_B25001_with_ann.csv, clear case(preserve) varnames(1)

drop in 1

/*
HD01_VD01	Estimate; Total
*/

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 HD01_VD01

destring *, replace

rename GEOid2 fipscounty

rename HD01_VD01 hou_units_2010

merge 1:1 fipscounty using `2010', nogen 

save `2010', replace

********************************************************************************
******************************** 2. CLEAN 2000 *********************************
********************************************************************************

********* 2000, DEMOGRAPHICS ********

import delimited using $acsdir/census2000/DEC_00_SF1_DP1_with_ann.csv, clear case(preserve) varnames(1)

drop in 1 //description

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 


/*Variables of interest:
HC01_VC01	Number; Total population
HC01_VC29	Number; Total population - RACE - One race - White
HC01_VC56	Number; HISPANIC OR LATINO AND RACE - Total population - Hispanic or Latino (of any race)
*/

keep GEOid2 /*GEOdisplaylabel*/ HC01_VC01 HC01_VC29 HC01_VC56

destring *, replace

rename (GEOid2 /*GEOdisplaylabel*/) (fipscounty /*county_state*/) 



*Rename vars
rename (HC01_VC01 HC01_VC29 HC01_VC56) (pop white hispanic)

*Replace white and hispanic levels with share of total county pop
replace white = white/pop*100
replace hispanic = hispanic/pop*100

*Rename variables for 2000
foreach var in pop white hispanic{
	rename `var' `var'_2000
}


tempfile 2000
save `2000'

********* 2000, URBAN V RURAL ********

import delimited using $acsdir/census2000/DEC_00_SF1_H002_with_ann.csv, clear case(preserve) varnames(1)

drop in 1

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 VD01 VD02

destring *, replace 

rename (GEOid2) (fipscounty) 

rename VD02 urban

replace urban = urban/VD01*100

drop VD01

rename urban urban_2000

merge 1:1 fipscounty using `2000', nogen assert(3)

save `2000', replace

********* 2000, FOREIGN-BORN ********

import delimited using $acsdir/census2000/DEC_00_SF3_P021_with_ann.csv, clear case(preserve) varnames(1)

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 VD01 VD13

rename (GEOid2) (fipscounty) 

rename VD13 foreign

replace foreign = foreign/VD01*100

drop VD01

rename foreign foreign_2000

merge 1:1 fipscounty using `2000', nogen assert(3)

save `2000', replace

********* 2000, SHARE W BA ********

import delimited using $acsdir/census2000/DEC_00_SF3_QTP20_with_ann.csv, clear case(preserve) varnames(1)

/*
HC01_VC32	Both sexes; EDUCATIONAL ATTAINMENT (highest level) - Percent of population 25 years and over - Percent bachelor's degree or higher	
*/

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 HC01_VC32

rename GEOid2 fipscounty

rename HC01_VC32 ba_over25_2000

merge 1:1 fipscounty using `2000', nogen 

save `2000', replace

********* 2000, MEDIAN OWNER-OCCUPIED HOUSING VALUE ********

import delimited using $acsdir/census2000/DEC_00_SF3_H085_with_ann.csv, clear case(preserve) varnames(1)

/*
VD01	Median value
*/

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 VD01

rename GEOid2 fipscounty

rename VD01 median_houvalue_2000


g year = 2000

adjust_inflation median_houvalue_2000, year(2017)

drop year


merge 1:1 fipscounty using `2000', nogen 

save `2000', replace

********* 2000, MEDIAN GROSS RENT ********

import delimited using $acsdir/census2000/DEC_00_SF3_H063_with_ann.csv, clear case(preserve) varnames(1)

/*
VD01	Median gross rent
*/

* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 VD01

rename GEOid2 fipscounty

rename VD01 median_grossrent_2000

g year = 2000

adjust_inflation median_grossrent_2000, year(2017)

drop year


merge 1:1 fipscounty using `2000', nogen 

save `2000', replace

********* 2000, # HOUSING UNITS ********

import delimited using $acsdir/census2000/DEC_00_SF3_H001_with_ann.csv, clear case(preserve) varnames(1)

/*
VD01	Total
*/
* drop if "urban" or "rural" only
drop if regexm(GEOdisplaylabel, "-- Urban") | regexm(GEOdisplaylabel, "-- Rural") 

keep GEOid2 VD01

destring *, replace

rename GEOid2 fipscounty

rename VD01 hou_units_2000

merge 1:1 fipscounty using `2000', nogen 

save `2000', replace

********************************************************************************
******************************** 3. MERGE **************************************
********************************************************************************

use `2000', clear

merge 1:1 fipscounty using `2010', nogen

sort fipscounty

save  $processeddir/demographics_census_2000_2010_bycounty.dta, replace