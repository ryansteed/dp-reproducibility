********************************************************************************
* Definition of macros used in other programs
********************************************************************************

set more off

*To install the packages used in the Stata programs, run the following code: 
*ssc install estout
*ssc install spmap
*ssc install unique
*ssc install coefplot
*ssc install did_multiplegt
*ssc install cgmwildboot
*ssc install asgen
*ssc install boottest
*ssc install clustse

* Set the root directory here 
*** EDIT by Donna
global root "../"

*-------------------------------------------------------------------------------
* Source (read only) datasets --------------------------------------------------
*-------------------------------------------------------------------------------

global source $root/data/source

*-------------------------------------------------------------------------------
* Pre-processed (read only) datasets -------------------------------------------
*-------------------------------------------------------------------------------

global preprocessed $root/data/preprocessed
global spillover $preprocessed/spillovers
global hospital $preprocessed/hospital

global data_upp_main $preprocessed/UPP_Data.csv
global data_upp_crime $preprocessed/UPP_Crime.csv
global data_socio $preprocessed/socio_favela_upp.csv

*-------------------------------------------------------------------------------
* Processed datasets -----------------------------------------------------------
*-------------------------------------------------------------------------------

global processed $root/data/processed

*-------------------------------------------------------------------------------
* Functions --------------------------------------------------------------------
*-------------------------------------------------------------------------------

global programs $root/code

*-------------------------------------------------------------------------------
* Results ----------------------------------------------------------------------
*-------------------------------------------------------------------------------

global results $root/results
