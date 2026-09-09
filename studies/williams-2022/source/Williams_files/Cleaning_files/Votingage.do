clear

#delimit;

*** CLEANING FILE ***;
** Input data file: votingage1910_temp from IPUMS NHGIS;
** Creates analysis data file: votingage1910 to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";


use "$infile/votingage1910_temp";

rename county County;
rename state State;
rename statea State_FIPS;
rename countya County_FIPS;
** To match with later years;
replace State_FIPS = State_FIPS/10;
replace County_FIPS = County_FIPS/10;

generate fips = State_FIPS*1000+County_FIPS;

generate White_votingage = a32001 + a32002 + a32003; 
rename a32005 Black_votingage;

keep fips County State Black_votingage White_votingage;

save "$outfile/votingage1910", replace;
