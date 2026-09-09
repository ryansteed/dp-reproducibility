/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
Last modified: 	03/02/2020
Modified by:	Dustin Swonder
Description:	This file builds QWI averages in a single do-file. This takes 
				quite a while. I conduct the build in two parts, first building
				collapses for the first half of 3-D NAICS codes then building
				the second. Finally I append these two.
*******************************************************************************/

/*******************************************************************************
	(0) Define objects to be used globally: filepath for QWI raw folder, labels 
		for firm size and noise signal variables
*******************************************************************************/

clear
set more off

gl qwi_raw "$datadir/qwi_prebuild"

capture label drop _all
#delimit ;
lab define firmsize 
	0	"All Firm Sizes"
	1	"0-19 Employees"
	2	"20-49 Employees"
	3	"50-249 Employees"
	4	"250-499 Employees"
	5	"500+ Employees"
;
lab define noise
	-2 "No data available"
	-1 "Data not available to compute this estimate"
	1 "OK, fuzzed value released"
	5 "Value suppressed because it does not meet US Census Bureau publication standards"
	9 "Data significantly distorted, distorted value released"
	10 "Aggregate of cells, no significant distortion"
	11 "Aggregate of cells not released because component cells do not
	meet US Census Bureau publication standards"
	12 "Aggregate of cells, some of which have significantly distorted data"
;
#delimit cr

/*******************************************************************************
	(1) Build first half of master QWI dataset by loading, appending, and 
		cleaning raw files for first half of FIPS codes
*******************************************************************************/

	/***************************************************************************
		(1.1) Cycling through first set of NAICS codes (111-482), FIPS codes, 
			and years, import, clean and append raw text files.
	***************************************************************************/

local iteration = 1
tempfile temp1

forv industry = 111 / 482 {
	forv state = 1 / 56 {
		forv year = 1990 / 2018 {
			if strlen("`state'") == 1 {
				local state = "0`state'"
			}
			qui cap import delimited "$qwi_raw/fips`state'_ind`industry'_`year'.txt", clear

			if _rc == 0 & `c(k)' != 0 {
				di "ind = `industry', state = `state', year = `year'"
				* Drop variables we don't need
				qui drop ownercode //all privately ownercode
				
				capture confirm variable sex
				if _rc == 0 {
					assert sex == 0 // Ensure we didn't download diff rows by sex
				}

				qui drop sex // all genders

				qui drop seasonadj //not seasonally adjusted
				capture drop v13 //drop if there's a weird last column

				* Clean county
				qui replace county = subinstr(county, "]", "", .)
				qui replace county = subinstr(county, "]", "", .)
				qui replace county = subinstr(county, `"""', "", .)
				qui destring county, replace

				* Clean state fips
				qui rename state fips
				qui g fipscounty = 1000 * fips + county
					
				*Clean employment
				qui replace emp = subinstr(emp, "null", ".", .)
				qui replace emp = subinstr(emp, "[", "", .)
				qui replace emp = subinstr(emp, `"""', "", .)
				qui destring emp, replace
				
				capture confirm string variable payroll 
				if !_rc {
					replace payroll = subinstr(payroll, "null", "", .)
					destring payroll, replace
				}
				if `iteration' != 1 {
					qui append using `temp1'
				}
				
				qui compress
				qui save `temp1', replace

				local iteration = `iteration' + 1
			}
		}
	}
}

	/***************************************************************************
		(1.2) Clean appended file slightly before saving into dump folder
	***************************************************************************/

use `temp1', clear

drop if missing(fips)

lab var emp "Employment"
lab var semp "Employment flag"
lab var payroll "Total Quarterly Payroll: Sum"
lab var firmsize "Firm size"
lab var industry "3-D naics"

lab value firmsize firmsize
lab value semp noise

save $dumpdir/qwi_master_half1.dta, replace

/*******************************************************************************
	(2) Repeat steps 1.1-1.2 for second batch of NAICS codes, 483-814
*******************************************************************************/

clear	
local iteration = 1
tempfile temp2

forv industry = 483 / 814 {
	forv state = 1 / 56 {
		forv year = 1990 / 2018 {
			if strlen("`state'") == 1 {
				local state = "0`state'"
			}

			qui capture import delimited "$qwi_raw/fips`state'_ind`industry'_`year'.txt", clear

			if _rc == 0 & `c(k)'!=0 {
				di "ind = `industry', state = `state', year = `year'"
				qui drop ownercode //all privately ownercode
				qui drop sex // all genders
				qui drop seasonadj //not seasonally adjusted
				capture drop v13 //drop if there's a weird last column

				* Clean county
				qui replace county = subinstr(county, "]", "", .)
				qui replace county = subinstr(county, "]", "", .)
				qui replace county = subinstr(county, `"""', "", .)
				qui destring county, replace

				* Clean state fips
				qui rename state fips
				qui g fipscounty = 1000*fips + county
					
				*Clean employment
				qui replace emp = subinstr(emp, "null", ".", .)
				qui replace emp = subinstr(emp, "[", "", .)
				qui replace emp = subinstr(emp, `"""', "", .)
				qui destring emp, replace
				
				qui capture confirm string variable payroll 

				if !_rc {
					qui replace payroll = subinstr(payroll, "null", "", .)
					qui destring payroll, replace
				}
				
				if `iteration' != 1 {
					qui append using `temp2'
				}
				
				qui compress
				qui save `temp2', replace

				local iteration = `iteration' + 1
			}
		}
	}
}


drop if missing(fips)

lab var emp "Employment"
lab var semp "Employment flag"
lab var payroll "Total Quarterly Payroll: Sum"
lab var firmsize "Firm size"
lab var industry "3-D naics"

lab value firmsize firmsize
lab value semp noise

save $dumpdir/qwi_master_half2.dta, replace

/*******************************************************************************
	(3) Append first half of data; count and collapse by firm size, year, 
		industry, fips, and county. Label variables, sort, and save.
*******************************************************************************/

append using $dumpdir/qwi_master_half1.dta

gen firm_count = 1 

collapse (mean) emp semp payroll (sum) firm_count, by(firmsize year industry fips county fipscounty)

replace semp = round(semp)

lab var emp "Employment"
lab var semp "Employment flag"
lab var payroll "Total Quarterly Payroll: Sum"
lab var firmsize "Firm size"
lab var industry "3-D naics"
lab var firm_count "number of firms"

lab value firmsize firmsize
lab value semp noise

sort year industry fips county firmsize

save $rawdir/qwi_avgs.dta, replace