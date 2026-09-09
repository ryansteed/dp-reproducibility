clear

#delimit;

*** CLEANING FILE ***;
** Input data file: POP_1860_temp from IPUMS NHGIS;
** Creates analysis data file: POP_1860_NHGIS to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";


use "$infile/POP_1860_temp";

rename statea State_FIPS;
rename countya County_FIPS;
** To match with later years;
replace State_FIPS = State_FIPS/10;
replace County_FIPS = County_FIPS/10;
generate fips = State_FIPS*1000+County_FIPS;

rename ag3001 Total_POP_1860;

keep fips Total_POP_1860;

save "$outfile/POP_1860_NHGIS", replace;
