clear

#delimit;

*** CLEANING FILE ***;
** Input data file: POP_2010_temp from IPUMS NHGIS;
** Creates analysis data file: POP_2010_NHGIS to be used in Createmain.do;


global infile = "Input_data";
global outfile = "Analysis_data";


use "$infile/POP_2010_temp";

rename statea State_FIPS;
rename countya County_FIPS;

generate fips = State_FIPS*1000+County_FIPS;

rename h7x002 White_POP_2010; 
rename h7x003 Black_POP_2010;

keep fips Black_POP_2010 White_POP_2010;

save "$outfile/POP_2010_NHGIS", replace;
