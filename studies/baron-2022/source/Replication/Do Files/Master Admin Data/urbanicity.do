/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports and cleans information on each school district's
***degree or urbanicity during the 2014-15 academic year. 

DATA INPUTS: (1) urban.csv
DATA OUTPUTS: (1) urbanicity.dta
*********************************/

*****************************************
******SECTION I: IMPORT RAW DATASETS
*****************************************
clear
set more off
cd "${path}Data\Raw\Urbanicity"
insheet using urban.csv


*****************************************
******SECTION II: GEN CROSS SECTION
*****************************************
***Keep only variables of interest
keep year leaid lea_name urban_centric 

***Clean up variable
tab urban_centric

***There are 12 categories in the CCD's Urban-Centric Locale (Categories):
***https://nces.ed.gov/ccd/CCDLocaleCode.asp

***3 cities (large, midsize, and small) 3 suburb (large, midsize, small)
***3 towns (large, midsize, and small) 3 rural (distant, fringe, remote)
***Hierarchy: City, Suburb, Town, Rural 
replace urban_centric = substr(urban_centric,1,4)
tab urban_centric

***Turn this into a numeric variable
replace urban_cent = "1" if urban_cent=="City"
replace urban_cent = "2" if urban_cent=="Subu"
replace urban_cent = "3" if urban_cent=="Town"
replace urban_cent = "4" if urban_cent=="Rura"
tab urban_cent

***Destring and label
destring urban_cent, replace
label var urban_cent "1 (City) 2 (Sub.) 3 (Town) 4 (Rural)"




*******************************************************************************
**********Deal with consolidations, name changes, and mergers******************

***The are a few consolidations a mergers to worry about. The full list can
***be found here: https://dpi.wi.gov/sms/reorganization/history-and-orders

****(1) River Ridge (merge between Bloomington and West Grant in 1995)
***In 1995, the School District of Bloomington and the School District of W. Grant
***consolidated to become the River Ridge School District
***Since this was in 1995, this merger is not a problem in this dataset.

****(2) Trevor - Wilmot (merge between Trevor Grade and Wilmot Grade in 2006)
****Also, Salem changed name to Trevor in 2000
**Trevor Wilmot Consolidated Grade School district is in the data since 2006.
**Its LEAID code is 5500052. Trevor Grade (Previously Salem School Dist)
**is in the data from 1996-2005, LEAID Code 5513320. I need to give it the same
**code as Wilmot Grade, which is in the data from 1996-2005, LEAID 5513380
replace leaid = 5500052 if leaid== 5513320 //replace Trevor's LEAID
replace leaid = 5500052 if leaid== 5513380 //replace Wilmot's LEAID
edit if leaid== 5500052


****(3) There was a split between Shawano-Gresham into Shawano and Gresham in 2007-08
***Gresham appears in the data from 2007 on, LEAID 5500056.
***I will take the Shawano-Gresham school district as one through the sample.
***Shawano-Gresham School District has LEAID 5513620
replace leaid = 5513620 if leaid== 5500056
edit if leaid==5513620


****(4) Glidden and Park Falls merged in 2009 to become Chequamegon
***Chequamegon is in the data since 2009, LEAID = 5500058
***Glidden is in the data from 1996-2009 LEAID = 5505550
***Park is in the data from 1996-2009 LEAID = 5511430
replace leaid = 5500058 if leaid == 5505550 //glidden
replace leaid = 5500058 if leaid == 5511430 //park falls
edit if leaid==5500058

*****(5) Chetek and Weyerhauser merged to become Chetek - Weyerhauser
***Weyerhauser is in the data from 1996-2009, LEAID = 5516530
***Chetek is in the data from 1996-2009 LEAID = 5502490
***Chetek-Weyerhauser is in the data from 2010-2014 LEAID = 5500061
replace leaid = 5500061 if leaid == 5502490 //chetek
replace leaid = 5500061 if leaid == 5516530 //weyerhauser
edit if leaid==5500061


****(6) Herman, Neosho, Rubicon merged in 2016
****I will give all three of them the LEAID code 5500075 - Herman-Neosho-Rubicon School District
replace leaid=5500075 if leaid==5513200 //Rubicon 
replace leaid=5500075 if leaid==5510410 //Neosho
replace leaid=5500075 if leaid==5506390 //Herman
edit if leaid==5500075


******************************************************************************
******************************************************************************

****Collapse data to account for these consolidations
collapse (mean) urban_centric, by(leaid) 
tab urban_centric
replace urban_centric = 4 if urban_centric==3.5

*****************************************
******SECTION III: SAVE DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\urbanicity", replace