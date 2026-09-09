
capture log close
macro drop _all
setdate
setdirectory

log using "Logs/3-ccd-lea_${date}", replace text
********************************************************************************
*ccd-lea_$date: get msc code for urbanicity indicator
*Victoria Sosina (vsosina@stanford.edu)
di "Date: $date"
********************************************************************************
/*Retrieve the msc code for urbanicity indicator*/
********************************************************************************

version 13
set linesize 82
set more off, perm

********************************************************************************
*RENAME FILES BY FISCAL YEAR
********************************************************************************
*List of original district level CCD files
local years 94dis_clean 95dis_clean 96dis_clean 97dis_clean 98dis_clean ///
99dis_clean 00dis_clean 01dis_clean 02dis_clean 03dis_clean 04dis_clean ///
05dis_clean 06dis_clean 07dis_clean 08dis_clean 09dis_clean 10dis_clean ///
11dis_clean 12dis_clean 13dis_clean 14dis_clean
/* NOTE: For these district CCD files, the year of the survey is one year 
before fiscal year. Therefore, the year needs to be changed to match 
the F33 */

*List of correct fiscal years
local fiscalyr 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 ///
2006 2007 2008 2009 2010 2011 2012 2013 2014 2015

*Verify list of original CCD files & list of new file names are same length 
local n_files : word count `years'
assert `n_files'==`: word count `fiscalyr''

local nyc ///
	3600076 3600077 3600078 3600079 3600081 3600083 3600084 3600085 ///
	3600086 3600087 3600088 3600090 3600091 3600119 3600092 3600094 ///
	3600095 3600096 3600120 3600151 3600152 3600153 3600121 3600098 ///
	3600122 3600099 3600123 3600100 3600101 3600102 3600103 3600097
	//NYC geographic district leaids

	
*Loop to rename files by correct fiscal year
forval i=1/`n_files' {
	local old_name `: word `i' of `years''
	local new_year `:word `i' of `fiscalyr''
	use "Source/CCD/`old_name'.dta", clear

	*leaid needs to be string
	tostring leaid, replace
	
	*leading zeros get dropped when making it a string
	tab fips if strlen(leaid)<7
	
	*add back leading zeros
	replace leaid = "0"+leaid if strlen(leaid)==6
	count if strlen(leaid)<7
	di "SHORT LEAIDS in FY`new_year': `r(N)'"
	
	*create year variable
	gen year_fall = `new_year'-1
	gen year_spring = `new_year'
	gen year = year_spring
	label variable year "Fiscal year (spring of school year)"
	
	*rename 2014-15 ulocal variable
	if year_spring == 2015{
		rename ulocal14 ulocal
	}
		
	*generate variables for missing years
	local variables ulocal locale msc
	foreach v of local variables{
		capture confirm variable `v'
			if !_rc {
				di "`v' present in `new_year'"
			}
			else {
					gen `v' = .
			}
	}
	*keep year, ulocal, locale, msc, leaid	
	keep year ulocal locale msc leaid
	
	*make vartype consistent across years
	cap _strip_labels msc
	tostring msc, replace
	
	*nyc indicator
	gen nycps = 0
	gen nyc_geo = 0
	
	replace nycps = 1 if leaid=="3620580"
	//this is the leaid for aggregated NYC Public Schools
	
	foreach id of local nyc {
		qui replace nyc_geo = 1 if leaid=="`id'"
	}
	
	save "Derived/CCD_FY`new_year'.dta",replace
}

********************************************************************************
*APPENDING YEARS: DO IT
********************************************************************************
clear
set obs 1

*Append fiscal years 1995-2014
local newlist 	///
	FY1995 FY1996 FY1997 FY1998 FY1999 FY2000 FY2001 FY2002 FY2003 ///
	FY2004 FY2005 FY2006 FY2007 FY2008 FY2009 FY2010 FY2011 FY2012 ///
	FY2013 FY2014 FY2015
	
foreach item of local newlist {						
	qui append using "Derived/CCD_`item'.dta" 
	rm "Derived/CCD_`item'.dta"
}

drop if missing(year)

replace msc = "." if msc=="M" | msc=="N"
destring msc, replace

rename msc msc_ccd
rename ulocal ulocal_ccd
rename locale local_ccd

order leaid year 

********************************************************************************
*COLLAPSE NYC GEOGRAPHIC DISTRICTS POST 2004
********************************************************************************

preserve
	keep if nyc_geo == 1 |nycps==1

	tab year
	
	*check to make sure that msc, ulocal, local_ccd doesn't vary across nyc schs
	egen sdmsc = sd(msc_ccd), by(year)
	egen sdulocal = sd(ulocal_ccd), by(year)
	egen sdlocal = sd(local_ccd), by(year)
	
	*check standard deviation
	su sd*
	//should be zero and it is
	drop sd*
	
	collapse 	(mean) msc_ccd ulocal_ccd local_ccd, by(year nyc_geo)
	collapse 	(mean) msc_ccd ulocal_ccd local_ccd, by(year)
	
	gen leaid = "3620580"
	
	tempfile t
	save `t', replace	
restore

drop if nyc_geo == 1 | nycps==1
append using `t'

drop nycps nyc_geo	

********************************************************************************
*SAVE
********************************************************************************

save "Derived/3-clean_ccd-lea_${date}.dta", replace

********************************************************************************
*END MATTER
********************************************************************************

capture log close
