clear

#delimit;

*** CLEANING FILE ***;
** Input data file: POP_1900_temp from IPUMS NHGIS;
** Creates analysis data file: POP_1900_ to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/POP_1900_temp";

rename statea State_FIPS;
rename countya County_FIPS;
** To match with later years;
replace State_FIPS = State_FIPS/10;
replace County_FIPS = County_FIPS/10;
generate fips = State_FIPS*1000 + County_FIPS;

generate Black_POP_1900 = az3003 + az3004;
rename az2001 White_POP_1900;

** Replace Dade fips which was later changed to Miami-Dade fips code for merge;
replace fips = 12086 if fips == 12025;
keep fips Black_POP_1900 White_POP_1900;

save "$outfile/POP_1900_NHGIS", replace;
