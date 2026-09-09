/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
File created:	09/20/2019
Last modified: 	12/28/2019
Modified by:	Dustin Swonder
Description:	This file takes raw county-level revenues data from the Census
				of Gov and builds a county-year-level .dta file containing 
				property tax revenues.
*******************************************************************************/

clear
cd $rawdir/censusofgov_proptax_raw

	/***************************************************************************
		(1) Append data files together from 1990-2012
	***************************************************************************/

clear
forv i = 0/99 {
	if `i' < 12 | `i' > 89 { 
		if `i' < 10 {
			local year = "0`i'" // Add a padding zero if applicable
		}
		else {
			local year = "`i'"
		}

		preserve
		
		import delimited using "$rawdir/censusofgov_proptax_raw/_IndFin_1967-2012/IndFin`year'a.txt", ///
			delimiter(",") clear
		
		capture tostring yearofdata, replace // So that it's uniform across files
		capture destring fipscodestate, replace // So that it's uniform across files
		
		keep if typecode == 1 // Only keep records at county geography level
		
		keep year4 fipscodestate name county propertytax
			
		tempfile data`year'
		save `data`year''
		
		restore
		
		append using `data`year''
	}
}

* Clean up
drop if county == 0 /* refers to state */ | missing(fipscodestate) /* refers to fed govt. */
foreach designation in COUNTY PARISH {
	replace name = subinstr(name, " `designation'", "", .)
}
drop county

replace name = proper(name)

rename (year4 fipscodestate name) (year fips county)

replace county = "DeSoto" if county == "De Soto" & fips == 22
replace county = "DuPage" if county == "Du Page"
replace county = "DuPage" if county == "Dupage"
replace county = "Kanai Peninsula Borough" if county == "Kenai Peninsula Borough"
replace county = "Ketchikan-Gateway Borough" if county == "Ketchikan Gateway Borough"
replace county = "O'Brien" if county == "O Brien"
replace county = "Yakutat City And Borough" if county == "Yakutat Borough"
replace county = "Miami-Dade" if county == "Metropolitan Dade"
replace county = subinstr(county, "Mcc", "McC", 1)

merge m:1 fips county using $rawdir/alt_xwalk_countyfips_190305.dta, ///
	keep(3) keepusing(fipscounty) nogen
drop county
	
tempfile early
save `early'
	
	/***************************************************************************
		(2) Prepare the raw data 2012-2016, which is in fixed-length ASCII 
			format
	***************************************************************************/

forv year = 2012/2016 {
	if `year' < 2015 {
		infile using `year'FinEstDAT_07242018modp_pu, clear // import the base data with rev. info
	}
	else {
		infile using `year'FinEstDAT_12042018modp_pu, clear
	}
	
	gen type = substr(id, 3, 1) // type of geographic unit
	
	destring amt type, replace force
	rename amt propertytax
	
	drop if item != "T01" // Only interested in property tax line item
	drop item
	
	preserve
	
	infile using Fin_GID_`year', clear // Import area-level info which can help us identify counties
	tempfile info`year'
	save `info`year''
	
	restore
	
	* Merge area-level info onto main data file for year
	merge 1:1 id using `info`year'', keepusing(fips fipscounty) assert(2 3) nogen
	
	drop if type != 1 // only interested in county-level
	
	keep fips fipscounty propertytax
	
	destring fips fipscounty, replace
	replace fipscounty = (fips * 1000) + fipscounty
	
	gen year = `year'
	
	tempfile data`year'
	save `data`year''
}	

	/***************************************************************************
		(3) Put all the data together and save
	***************************************************************************/


use `early', clear

forv i = 2012/2016 { // Tack on the later years
	append using `data`i''
}
	
keep fipscounty propertytax year

adjust_inflation propertytax, year(2017)
label variable propertytax "Property taxes collected (2017 thousands USD)"

sort year fipscounty

save $processeddir/censusofgov_proptax.dta, replace