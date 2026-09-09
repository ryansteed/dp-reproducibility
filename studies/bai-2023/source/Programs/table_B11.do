/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off

global results "C:\CR_Legacy\files\results"

cd "C:\CR_Legacy\files\data"
	
/******************************************************************************************************/
/*** Table B11: Individual-level Results: Revolutionary Intensity and Perceived Return to Education ***/
/******************************************************************************************************/
use cgss2006_tabB11.dta, clear

local DIDinteractions agrp2xCR agrp3xCR agrp4xCR agrp5xCR agrp6xCR agrp7xCR agrp8xCR agrp9xCR

reg std_selfedu `DIDinteractions' i.birthyear i.provID [aweight=weight], cluster(provID)
outreg2 using "$results\\cgss_DID_values.xls", label dec(3)  nocons  replace keep( agrp*)  addtex(Prov. FE, Yes, Year of Birth FE, Yes, Individual Controls, No, Province Cohort Trends, No)

reg  std_selfedu `DIDinteractions' male han rural i.birthyear i.provID [aweight=weight], cluster(provID)
outreg2 using "$results\\cgss_DID_values.xls", label dec(3)  nocons  append keep( agrp*)  addtex(Prov. FE, Yes, Year of Birth FE, Yes, Individual Controls, Yes, Province Cohort Trends, No)

reg  std_selfedu `DIDinteractions' male han rural i.birthyear i.provID provtrend* [aweight=weight], cluster(provID)
outreg2 using "$results\\cgss_DID_values.xls", label dec(3)  nocons  append keep( agrp*)  addtex(Prov. FE, Yes, Year of Birth FE, Yes, Individual Controls, Yes, Province Cohort Trends, Yes)















