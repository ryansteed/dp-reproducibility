clear

#delimit;

*** CLEANING FILE ***;
** Input data file: illiterate_temp from IPUMS NHGIS;
** Creates analysis data file: illiterate_NHGIS to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/illiterate_temp";

rename county County;
rename state State;
rename statea State_FIPS;
rename countya County_FIPS;
** To match with later years;
replace State_FIPS = State_FIPS/10;
replace County_FIPS = County_FIPS/10;

generate fips = State_FIPS*1000+County_FIPS;

generate White_illiterate = a35001 + a35002; 
rename a35003 Black_illiterate;

keep fips County State Black_illiterate White_illiterate;

save "$outfile/illiterate_NHGIS", replace;
