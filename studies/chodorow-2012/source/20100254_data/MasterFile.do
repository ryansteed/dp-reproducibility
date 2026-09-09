/*****************************************************************************

MASTER DO FILE:
This file contains links to all of the do-files needed to perform the analysis
in Chodorow-Reich, Feiveson, Liscow, and Woolston.

******************************************************************************/
version 10.1 
*FIRST, FILL IN THE MASTER DIRECTORY (which holds this file)
global dir = "."
cd "$dir"

do programs/MainTables
* Produces Tables 1,2,3,4,5i,Appendix Tables 2-3, and the "split government" statistics.

* do programs/QCEW_Table5ii
* Produces Table 5ii

* do programs/RainyDay_Table6
* Produces Table 6

* do programs/Placebo_Figure5
* Produces Figure 5

* do programs/TimingGraphs_Figures3_4
* Produces Figures 3 and 4

* do programs/GovEmploymentChanges
* Produces Appendix Table 1

* do programs/Forecasted_Employment
* Produces CES Forecasted Employment Variable

/**********************************************************************************
Note: to produce the QCEW imputed employment variables, one must first download the QCEW data from the BLS website, and prep the data.  The documentation
describing how to do this, as well as the program for prepping, is found in:

programs/imputed_employment/qcew_data.do

Once the data are downloaded, the program to produce the imputed employment data are found in:

programs/imputed_employment/Imputed_Employment.do

This file will create the data/Imputed_Employment2008-2009.dta and data/Imputed_Employment2007-2008.dta.

***********************************************************************************/






