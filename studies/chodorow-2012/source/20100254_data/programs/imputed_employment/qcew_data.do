clear
set mem 200m
set more off
#delimit;

* Make sure that the global $dir path is set to the master folder:;
* global dir = "MASTER FOLDER PATH HERE";

/*************************************************************************************************************
This file reads in the QCEW 2007, 2008 and 2009 all-state flat files. It reads in December employment and Q4 wages. Files and documentation available at:
ftp://ftp.bls.gov/pub/special.requests/cew/yyyy/state.  
Documentation and record layout is available at:
ftp://ftp.bls.gov/pub/special.requests/cew/DOCUMENT/layout.txt
FIPS matching codes and NAICS industry descriptions available at:
ftp://ftp.bls.gov/pub/special.requests/cew/DOCUMENT/area.map
ftp://ftp.bls.gov/pub/special.requests/cew/DOCUMENT/industry.map

IMPORTANT:  For this file to run, save all of the QCEW data downloaded above into a new folder called $dir/data/QCEW
*************************************************************************************************************/

cd "$dir";

tempfile qcew07;
tempfile qcew08;
tempfile qcew09;
tempfile qcew;
global OutputPath C:\Users\gabe\Documents\CEA\FMAP\QCEW;

foreach yy in 07 08 09 {;
	qui infix str fips 4-8 size 10 ownership 11 str NAICS 12-17 year 18-21 aggregation 22-23 str disclosure 372 
	employment 312-320 wages 321-335 using allsta`yy'.enb, clear;
	qui save `qcew`yy'';
};

qui append using `qcew08';
qui append using `qcew07';

qui replace employment=. if disclosure=="N";
label define ownership_label 0 "Total Covered" 1 "Federal Govt" 2 "State Govt" 3 "Local Govt" 5 "Private" 8 "Total Govt";
label values ownership ownership_label;
label define size_label 0 "All establishments";
label values size size_label;
qui sort NAICS;
format employment wages %16.0fc;
qui save `qcew';

qui infix str NAICS 1-20 str industry 21-75 using "naics codes.txt", clear;
qui sort NAICS;
qui merge NAICS using `qcew', uniqmaster;
qui drop _m;
qui sort fips;
qui save `qcew', replace;

qui infix str fips 1-20 str state 21-60 using "fips codes.txt", clear;
qui sort fips;
qui merge fips using `qcew', uniqmaster;

qui egen state_name = ends(state), punct(" -- Statewide") head;
qui drop state;
qui drop _m;

qui sort state_name;
qui merge state_name using state_abbreviations;
qui drop _m;

qui sort fips NAICS year;
order year state_name state industry employment wages ownership disclosure;

qui drop if year==.;
qui drop if state=="VI" | state=="PR";
qui destring NAICS, force replace;

qui save "$dir\data\qcew", replace;


