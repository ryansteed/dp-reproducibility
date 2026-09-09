clear

#delimit;

*** CLEANING FILE ***;
** Input data file: numslaves_temp from IPUMS NHGIS;
** Creates analysis data file: numslaves to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";


use "$infile/numslaves_temp";

rename statea State_FIPS;
rename countya County_FIPS;
** To match with later years;
replace State_FIPS = State_FIPS/10;
replace County_FIPS = County_FIPS/10;
generate fips = State_FIPS*1000+County_FIPS;

rename agu001 numslaves;

keep fips numslaves;

save "$outfile/numslaves", replace;
