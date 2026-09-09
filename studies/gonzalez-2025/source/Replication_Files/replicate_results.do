* replicate_results.do

clear all
set more off

* set path for location of Replication_Files directory

global root "~/Dropbox/Penalties/Replication_Files"

********************************************************************************

* workspace structure set up

global datasets "$root/datasets"

global output "$root/output"

global dofiles "$root/dofiles"

global intermediate "$root/intermediate"

cd "$root"
********************************************************************************
* Install required packages

foreach p in ppmlhdfe reghdfe geonear unique estout estadd dataout ///
acreg acregpackcheck rdrobust ftools gtools blindschemes ///
ranktest hdfe {
		
	capture ssc install `p'
		
}

********************************************************************************
********************************************************************************
* log replication

log using "$dofiles/replicate_results_log.log", replace text

********************************************************************************
* run do-files to replicate:

* main tables
do $dofiles/table1.do
do $dofiles/table2
do $dofiles/table3.do
do $dofiles/table4.do 
do $dofiles/table5.do 

* main figures:
do $dofiles/fig3.do
do $dofiles/fig4.do

* appendix tables:
do $dofiles/tableA1.do
do $dofiles/tableA2.do
do $dofiles/tableA3.do
do $dofiles/tableA4.do 
do $dofiles/tableA5.do 
do $dofiles/tableA6.do

* appendix figures:
do $dofiles/figA1.do
do $dofiles/figA2.do
do $dofiles/figA4.do 
do $dofiles/figA5.do 

********************************************************************************
* clean up

*erase $intermediate/final_penalties_dataset_nearDF.dta
*erase $intermediate/drug_spp_df_by_year.txt
/*
foreach x in main PM wknds property violent {
	erase $intermediate/file_`x'.dta
}
*/

********************************************************************************
* log close

log close



