
* this stata program reproduces the results in Evans et al., 
* JAMA open network.  All of the data is public use and
* available in different folders

set more off
*clear

log using replication_code_program_1.log, replace

* generate control variables by district using data from the 1999 and 2022
* five year ACS.  There are three files per year, one for elementary, 
* secondary, and unified disristcs.  this produces a data set named
* all_demos_stacked.  this data set is district by year
do read_nhgis_stack_1


* read in data from the common core on enrollment and race of students
* data from NCES on chronic absenteeism by district, and data from 
* the COVID data hub on days in virtual instruction.  The data set is  
* also district by year and then merged with all_demos_stacked 
* to produce a data set called stacked_1
do read_long_data_v1



* these next two do files generate vax rates as of the end of dec 21 and 
* covid cases per capita during the 21/22 school year.  The vax and covid
* case data are at the county level.  to use this data
* we need to merge county to districts.  In most cases, districts are
* either within a district or co-determinous with a district (e.g., 
* VA, FL, MD, etc.).  However, some mostly rural districts may span counties.
* we use a mapping of counties to districts from the NCES
* available at https://nces.ed.gov/programs/edge/geographic/relationshipfiles
* when a district spans multiple counties we just take a simple average of
* all the counties it spans

do load_covid_data_1
do load_vaccination_data_1

* this next program produces all the results in the paper
* including the results in the online appendix.
log close