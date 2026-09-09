/*******************************************************************************
Project:		Evaluating State and Local Business Tax Incentives (JEP)
					Slattery and Zidar
File created:	12/28/2019
Last modified: 	12/28/2019
Modified by:	Dustin Swonder
Description:	This file processes state-level BEA raw datasets to yield the 
				dataset bea_statevars.dta, which is an input for analysis 
				datafiles.
*******************************************************************************/

set more off

*----- IMPORT 1963-1996 DATA ---------*

import delimited using "$rawdir/gdpstate_sic_all.csv", clear
rename (v1 v2 v4 v5) (fips statename outcomecat outcome)

keep if v6=="1" //Keeping all industries for now
drop if inlist(outcomecat, "1000", "900", "800")
drop in 1	
replace fips = subinstr(fips, "000", "", .)
destring fips, replace force

drop if fips==0|fips>56|fips==.

local yr = 1963
forv i = 9/42{
	rename v`i' var`yr'
	destring var`yr', force replace
	local ++yr
}

keep outcome* var* fips statename

//Reshape data
reshape long var, i(fips statename outcome*) j(year)

*Set up variable names to reshape data once more
g varname = ""
replace varname = "GDP" if regexm(outcome, "GDP")
replace varname = "GOS" if regexm(outcome, "Gross operating surplus")|regexm(outcome, "GOS")
replace varname = "comp" if regexm(outcome, "[Cc]ompensation")
replace varname = "tx_minus_sub" if regexm(outcome, "Taxes") & regexm(outcome, "less subsidies")
replace varname = "tx_pd" if regexm(outcome, "Taxes") & !regexm(outcome, "less subsidies")
replace varname = "sub" if regexm(outcome, "Subsidies")

drop outcome outcomecat

*Reshape data
reshape wide var, i(fips statename year) j(varname, string)
foreach var in GDP GOS comp tx_minus_sub tx_pd sub{
	rename var`var' `var'
}

lab var GDP "Gross domestic product (GDP) by state (M current dollars)"
lab var GOS "Gross operating surplus (GOS) by state (M current dollars)"
lab var comp "Compensation of employees by state (M current dollars)"
lab var tx_minus_sub "Taxes on production and imports less subsidies (M current dollars)"
lab var tx_pd "Taxes on production and imports (M current dollars)"
lab var sub "Subsidies (M current dollars)"

tempfile BEA_96
save `BEA_96'
	
*----- IMPORT 1997-2017 DATA ---------*

clear
set obs 1 
g temp=1
tempfile t
save `t'

qui fs $rawdir/SAG*.csv
foreach f in `r(files)' {
	import delimited using "$rawdir/`f'", clear stripquotes(yes)
	
	keep if industryid==1 //Keeping all industries for now

	qui destring v*, replace ignore(N A ( )) 
	qui append using `t'
	save `t', replace

}

drop temp

*Clean fips
rename (geofips geoname) (fips statename)
replace fips = subinstr(fips, "000", "", .)

destring fips, replace

drop if fips==0|fips>56|fips==.

* Rename years
local yr = 1997
forv i = 10/30{
	rename v`i' var`yr'
	destring var`yr', force replace
	local ++yr
}

keep componentname unit var* fips statename

//Reshape data
reshape long var, i(fips statename componentname unit) j(year)

*Set up variable names to reshape data once more
g varname = ""
replace varname = "GDP" if regexm(componentname, "GDP")
replace varname = "GOS" if regexm(componentname, "Gross operating surplus")|regexm(componentname, "GOS")
replace varname = "comp" if regexm(componentname, "[Cc]ompensation")
replace varname = "tx_minus_sub" if regexm(componentname, "Taxes") & regexm(componentname, "less subsidies")
replace varname = "tx_pd" if regexm(componentname, "Taxes") & !regexm(componentname, "less subsidies")
replace varname = "sub" if regexm(componentname, "Subsidies")

drop componentname unit

*Reshape data
reshape wide var, i(fips statename year) j(varname, string)
foreach var in GDP GOS comp tx_minus_sub tx_pd sub{
	rename var`var' `var'
}

foreach var of varlist GOS comp tx_* sub{
	replace `var' = `var'/10^3 //now in millions
}

lab var GDP "Gross domestic product (GDP) by state (M current dollars)"
lab var GOS "Gross operating surplus (GOS) by state (M current dollars)"
lab var comp "Compensation of employees by state (M current dollars)"
lab var tx_minus_sub "Taxes on production and imports less subsidies (M current dollars)"
lab var tx_pd "Taxes on production and imports (M current dollars)"
lab var sub "Subsidies (M current dollars)"
	
*----- APPEND DATA ---------*

append using `BEA_96'

sort fips year

save $processeddir/bea_statevars.dta, replace