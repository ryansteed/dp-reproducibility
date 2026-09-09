  /****************************************************************************************

* Project: Common tongue: The impact of language on educational outcomes

* Coder: Tarun Jain

* Description:  1) Creates log of main variables.
				2) Generates fixed-effects terms.
				3) Runs regression presented in the paper "Jain, T. (2016). Common tongue: The impact of language on educational outcomes. Journal of Economic History"			
			
*****************************************************************************************/
clear all
set more off
capture log close
global fold "if 1 == 1"
*****************************************************************************************/


// User needs to specify directory consistent with file location.

use Common_tongue.dta, clear




//Create log of variables
**************************

$fold{

gen Total_pop = ln(record1_100)												/* Total population */
gen Rural_pop = ln(record2_100)												/* Total rural population */
gen Male_pop  = ln(record3_100)												/* Total male population */
gen Farm_workers = ln(record1_112/record1_100)					  			/* Farm workers (main) population/Total population */
gen Cultivators = ln(record1_113/record1_100)					  			/* Cultivators (main) population/Total population */
gen Agri_labor = ln(record1_114/record1_100)					  			/* Agricultural Laborers (main) population/Total population */
gen Manufacturing = ln(record1_119/record1_100)					  			/* Manufacturing (main) population/Total population */
gen Commerce = ln(record1_121/record1_100)					  				/* Commerce (main) population/Total population */
gen Transport_Communication = ln(record1_122/record1_100)					/* Transport and Communication (main) population/Total population */

/* Literacy variables */

gen Literates_5_plus = ln(record1_140/record1_100)							/* Literates (Age 5+) population/Total population */
gen Literates_5_plus_rural = ln(record2_140/record2_100)					/* Rural Literates (Age 5+) population/Total rural population */
gen Literates_5_9 = ln(record1_141/record1_161)								/* Literates (Age 5 to 9) population/Total population 5-9 */
gen Literates_35_plus = ln(record1_147/record1_167)							/* Literates (Age 35+) population/Total population */


/* Other education variables */
gen Primary_school = ln(record1_151/record1_100)							/* Primary School or higher/Total population */
gen Primary_school_rural = ln(record2_151/record2_100)						/* Primary School or higher (Rural)/Total rural population */
gen Primary_school_male = ln(record3_151/record3_100)						/* Primary School or higher (Male)/Total male population */

gen Middle_school = ln(record1_152/record1_100)								/* Middle School or higher/Total population */
gen Middle_school_rural = ln(record2_152/record2_100)						/* Middle School or higher (Rural)/Total rural population */
gen Middle_school_male = ln(record3_152/record3_100)						/* Middle School or higher (Male)/Total male population */

gen Matriculates = ln(record1_153/record1_100)								/* Matriculates or higher/Total population */
gen Matriculates_rural = ln(record2_153/record2_100)						/* Matriculates or higher (Rural)/Total rural population */
gen Matriculates_male = ln(record3_153/record3_100)							/* Matriculates or higher (Male)/Total male population */

gen Diploma = ln(record1_155/record1_100)									/* Diploma or higher/Total population */
gen Diploma_rural = ln(record2_155/record2_100)								/* Diploma or higher (Rural)/Total rural population */
gen Diploma_male = ln(record3_155/record3_100)								/* Diploma or higher (Male)/Total male population */

gen Graduates = ln(record1_156/record1_100)									/* Graduates or higher/Total population */
gen Graduates_rural = ln(record2_156/record2_100)							/* Graduates or higher (Rural)/Total rural population */
gen Graduates_male = ln(record3_156/record3_100)							/* Graduates or higher (Male)/Total male population */



/* Migration variables */
gen Migrants = ln(record1_300/record1_100)									/* Migrants/Total population */
gen Migrants_male = ln(record3_300/record3_100)								/* Migrants (male)/Total male population */


/* SC, ST variables */
gen SC = record1_200/record1_100											/* SC Population/Total population */
gen SC_rural = record2_200/record2_100										/* SC Rural Population/Total rural population */
gen SC_male = record3_200/record3_100										/* SC Male Population/Total male population */

gen ST = record1_250/record1_100											/* ST Population/Total population */
gen ST_rural = record2_250/record2_100										/* ST Population/Total population */
gen ST_male = record3_250/record3_100										/* ST male Population/Total male population*/
}







// Add fixed effects terms	 
**************************

$fold{


gen Andhra_Pradesh = stateid ==2
gen Kerala = stateid == 14
gen Karnataka = stateid == 20 
gen Tamil_Nadu = stateid == 26

gen y1951= year == 1951
gen y1961= year == 1961
gen y1971= year == 1971
gen y1981= year == 1981
gen y1991= year == 1991
}







//Analysis
**************************

$fold{

//Test 1: Education difference between Minority and Majority districts
*** Table 4(a) ***
eststo: xi: reg Literates_5_plus switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Literates_5_plus_rural switcher SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid) 
eststo: xi: reg Middle_school switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Middle_school_rural switcher SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid) 
esttab using table4a.csv, keep(switcher SC ST SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned) b se ar2 star(* 0.10 ** 0.05 *** 0.01) replace
estout using "../results/table.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save final.dta, replace
eststo clear 
*** Table 4(b) ***
eststo: xi: reg Matriculates switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Matriculates_rural switcher SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid) 
eststo: xi: reg Graduates switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Graduates_rural switcher SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year, cluster(districtid) 
esttab using table4b.csv, keep(switcher SC ST SC_rural ST_rural coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned) b se ar2 star(* 0.10 ** 0.05 *** 0.01) replace
eststo clear



//Test 2: Education difference between Minority and Majority districts (Border districts only)

*** Table 5 ***
eststo: xi: reg Literates_5_plus switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year if border==1, cluster(districtid) 
eststo: xi: reg Middle_school switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year if border==1, cluster(districtid)
eststo: xi: reg Matriculates switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year if border==1, cluster(districtid)
eststo: xi: reg Graduates switcher SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid i.year i.stateid*year if border==1, cluster(districtid) 
esttab using table5.csv, keep(switcher) b se ar2 star(* 0.10 ** 0.05 *** 0.01) replace

eststo clear



//Test 4: Education difference between Minority and Majority districts x Linguistic Distance 

*** Table 7 ***
eststo: xi: reg Literates_5_plus switcher switcher_x_L SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Middle_school switcher switcher_x_L SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Matriculates switcher switcher_x_L SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Graduates switcher switcher_x_L SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
esttab using table7.csv, keep(switcher switcher_x_L) b se ar2 star(* 0.10 ** 0.05 *** 0.01) replace

eststo clear



//Test 5: Education difference with increasing MinorityFraction

*** Table 8 ***
eststo: xi: reg Literates_5_plus MinorityFraction SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Middle_school MinorityFraction SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Matriculates MinorityFraction SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Graduates MinorityFraction SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
esttab using table8.csv, keep(MinorityFraction) b se ar2 star(* 0.10 ** 0.05 *** 0.01) replace

eststo clear


//Test 9: Catch up in education between Minority and Majority districts

*** Table 9 ***
eststo: xi: reg Literates_5_plus switcher post switcher_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Middle_school switcher post switcher_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Matriculates switcher post switcher_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Graduates switcher post switcher_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
esttab using table9.csv,  keep(switcher switcher_x_post) b se ar2 star(* 0.10 ** 0.05 *** 0.01) replace

eststo clear



//Test 10: Catch up in education between Minority and Majority districts x Linguistic Distance 

*** Table 10 ***
eststo: xi: reg Literates_5_plus switcher switcher_x_L post switcher_x_L_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Middle_school switcher switcher_x_L post switcher_x_L_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Matriculates switcher switcher_x_L post switcher_x_L_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
eststo: xi: reg Graduates switcher switcher_x_L post switcher_x_L_x_post SC ST coastal british forest_land wasteland altitude latitude longitude rainfall_july_mean rainfall_jan_mean rainfall_july_sd rainfall_jan_sd Total_pop Rural_pop aligned i.stateid  i.year i.stateid*year, cluster(districtid)
esttab using table10.csv, keep(switcher_x_L switcher_x_L_x_post) b se ar2 star(* 0.10 ** 0.05 *** 0.01) replace

eststo clear

}


