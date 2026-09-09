/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	03/06/2020
Modified by:	Dustin Swonder
Description:	This file replicates the exhibits in Slattery and Zidar: 
				Evaluating State and Local Business Tax Incentives.
*******************************************************************************/

clear
capture log close
set more off

/*******************************************************************************
******  PRELIMINARIES **********************************************************
*******************************************************************************/

/*******************************************************************************
	SET FILEPATHS
*******************************************************************************/
*** EDIT BY Donna
* global user "/Users/dswonder/Dropbox" // Change (or delete) this
global replication_root	"../" // Change this

global rawdir "$replication_root/data/raw"
global processeddir "$replication_root/data/processed"
global dodir "$replication_root/do"
global dumpdir "$replication_root/dump"

global outdir "$replication_root/out"

/*******************************************************************************
	DEFINE PROGRAMS WRITTEN BY US
*******************************************************************************/

do $dodir/programs/adjust_inflation.do
do $dodir/programs/correct_fipscounty.do 
do $dodir/programs/winzorize.do

/*******************************************************************************
	ENSURE NECESSARY PACKAGES INSTALLED
*******************************************************************************/

*** EDITED by Ryan
/* ssc install binscatter, replace
ssc install estout, replace
ssc install fs, replace
ssc install ftools, replace
ssc install gtools, replace
ssc install listtex, replace
ssc install reghdfe, replace
ssc install tabstatmat, replace
ssc install unique, replace */
***

/*******************************************************************************
	GRAPH SETTINGS
*******************************************************************************/

global gpr = "plotregion(color(white) margin(small)) graphregion(color(white))"

/*******************************************************************************
****** BUILD DATA FILES ********************************************************
*******************************************************************************/

	/***************************************************************************
		(Pre-)build QWI datasets from raw files downloaded via API; this takes
			several hours, so only run this section of code if necessary. Built 
			data file is already stored in raw folder.
	***************************************************************************/

* do $dodir/build/prebuild_qwi.do

	/***************************************************************************
		Build BEA datasets to incorporate in main analysis data sets.
	***************************************************************************/

/* do $dodir/build/build_bea_countyinc.do */
do $dodir/build/build_bea_statevars.do

	/***************************************************************************
		Build Census dataset to incorporate in main analysis data sets.
	***************************************************************************/

do $dodir/build/build_census.do

	/***************************************************************************
		Build housing prices dataset to incorporate in main analysis data sets.
	***************************************************************************/

do $dodir/build/build_HPI_AT_BDL_county.do

	/***************************************************************************
		Build analysis data sets.
	***************************************************************************/

* From our deals datasets
do $dodir/build/build_firm_level_subsidy_runnerup.do
do $dodir/build/build_deal_specific_analysis.do
do $dodir/build/build_deal_specific_tva_analysis.do
do $dodir/build/build_firm_location_analysis.do

* From Bloom et al. (2019) AER deals dataset
do $dodir/build/build_deal_specific_jvr_analysis.do

/*******************************************************************************
****** MAKE EXIHIBITS IN MAIN TEXT *********************************************
*******************************************************************************/

do $dodir/figures/figures.do
do $dodir/tables/tables.do

/*******************************************************************************
****** MAKE APPENDIX EXHIBITS **************************************************
*******************************************************************************/

do $dodir/figures/appx_figures.do
do $dodir/tables/appx_tables.do