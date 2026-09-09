/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
File created:	12/28/2019
Last modified: 	12/28/2019
Modified by:	Dustin Swonder
Description:	This file processes raw BEA county income data in the file
				CAINC1__ALL_STATES_1969_2017.csv to yield the datafile 
				bea_countyinc.dta, which is an input for analysis datafiles.
*******************************************************************************/

/*******************************************************************************
	(1) Import data
*******************************************************************************/

import delimited using $rawdir/CAINC1__ALL_STATES_1969_2017.csv, ///
	stripquotes(yes) clear

* drop states
drop if regexm(geofips, "[0-9][0-9]000")

* Clean up county id
destring geofips, replace force
drop if geofips ==. 

rename geofips fipscounty

* Drop US total
drop if fipscounty==0

* Clean geoname
replace geoname = subinstr(geoname, "*", "", .)
split geoname, parse(", ")

/* COUNTIES/CITIES IN VA MERGED TOGETHER
	Augusta, Staunton + Waynesboro, VA           |          3       20.00       20.00
	Dinwiddie, Colonial Heights + Petersburg, VA |          3       20.00       40.00
	Fairfax, Fairfax City + Falls Church, VA     |          3       20.00       60.00
	Prince William, Manassas + Manassas Park, VA |          3       20.00       80.00
	Rockbridge, Buena Vista + Lexington, VA */

gen old_fipscounty = fipscounty

* Relabel some of the combined counties so that we can use the data
* Maui, HI
replace fipscounty = 15009 if geoname=="Maui + Kalawao, HI"

* Albemarle + Charlottesville, VA
replace fipscounty = 51003 if geoname == "Albemarle + Charlottesville, VA"

*Alleghany + Covington, VA
replace fipscounty = 51005 if geoname == "Alleghany + Covington, VA"

*Augusta, Staunton + Waynesboro, VA
replace fipscounty = 51015 if geoname == "Augusta, Staunton + Waynesboro, VA"

*Campbell + Lynchburg, VA
replace fipscounty = 51031 if geoname == "Campbell + Lynchburg, VA"

*Carroll + Galax, VA
replace fipscounty = 51035 if geoname == "Carroll + Galax, VA"

*Dinwiddie, Colonial Heights + Petersburg, VA
replace fipscounty = 51053 if geoname == "Dinwiddie, Colonial Heights + Petersburg, VA"

* Fairfax, Fairfax City + Falls Church, VA
replace fipscounty = 51059 if geoname=="Fairfax, Fairfax City + Falls Church, VA"

* Frederick + Winchester, VA
replace fipscounty = 51069 if geoname=="Frederick + Winchester, VA"

* Greensville + Emporia, VA
replace fipscounty = 51081 if geoname=="Greensville + Emporia, VA"

* Henry + Martinsville, VA
replace fipscounty = 51089 if geoname=="Henry + Martinsville, VA"

* James City + Williamsburg, VA
replace fipscounty = 51095 if geoname=="James City + Williamsburg, VA"

* Montgomery + Radford, VA
replace fipscounty = 51121 if geoname=="Montgomery + Radford, VA"

* Pittsylvania + Danville, VA
replace fipscounty = 51143 if geoname=="Pittsylvania + Danville, VA"

* Prince George + Hopewell, VA
replace fipscounty = 51149 if geoname=="Prince George + Hopewell, VA"

* Prince William, Manassas + Manassas Park, VA
replace fipscounty = 51153 if geoname=="Prince William, Manassas + Manassas Park, VA"

* Roanoke + Salem, VA
replace fipscounty = 51161 if geoname=="Roanoke + Salem, VA"

* Rockbridge, Buena Vista + Lexington, VA
replace fipscounty = 51163 if geoname=="Rockbridge, Buena Vista + Lexington, VA"

* Rockingham + Harrisonburg, VA
replace fipscounty = 51165 if geoname=="Rockingham + Harrisonburg, VA"

* Southampton + Franklin, VA
replace fipscounty = 51175 if geoname=="Southampton + Franklin, VA"

* Spotsylvania + Fredericksburg, VA
replace fipscounty = 51177 if geoname=="Spotsylvania + Fredericksburg, VA"

* Washington + Bristol, VA
replace fipscounty = 51191 if geoname=="Washington + Bristol, VA"

* York, VA
replace fipscounty = 51199 if geoname=="York + Poquoson, VA"

* Wise and Norton, VA
replace fipscounty = 51195 if geoname == "Wise + Norton, VA"


merge m:1 fipscounty using "$rawdir/alt_xwalk_countyfips_190305.dta", assert(2 3) keep(3) nogen

drop geoname*

* Rename variables pre-reshape
local yr = 1969
foreach var of varlist v9-v57{
	rename `var' var`yr'
	
	destring var`yr', replace ignore( "(NA)")
	
	local ++yr
}

* Reshape to get panel long on years
reshape long var, i(fipscounty linecode) j(year)
	
	
* Prep for Reshape wide
g lab = ""
replace lab = "_personal_inc" if linecode==1
replace lab = "_pop" if linecode==2
replace lab = "_personal_inc_pc" if linecode==3

drop linecode industryclassification description region tablename unit

* Reshape wide
reshape wide var, i(fipscounty year) j(lab, string)

* clean up vars
rename (var_personal_inc var_pop var_personal_inc_pc) (personal_inc pop personal_inc_pc) 

*label  
lab var personal_inc  "Personal income (thousands of dollars)"
lab var pop  "Population (persons)"
lab var personal_inc_pc  "Per capita personal income (dollars)"

* Clean up a bit
replace county = subinstr(county, " (Independent City)", " City", .)

compress

* Save
save  $processeddir/bea_countyinc.dta, replace