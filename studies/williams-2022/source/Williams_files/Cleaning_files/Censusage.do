clear

#delimit;

*** CLEANING FILE ***;
** Input file:  censusage_temp from IPUMS NHGIS;
** Creates analysis data files: censusage to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/censusage_temp";

rename statea State_FIPS;
rename countya County_FIPS;

generate fips = State_FIPS*1000 + County_FIPS;

rename fm8002 Black_avgage;
rename fm8001 White_avgage;

keep fips State_FIPS County_FIPS Black_avgage White_avgage;
save "$outfile\censusage", replace;

