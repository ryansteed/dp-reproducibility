clear

#delimit;

*** CLEANING FILE ***;
** Input data file: maritalcensus_temp from IPUMS NHGIS;
** Creates analysis data file: maritalcensus to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";


use "$infile/maritalcensus_temp";

rename statea State_FIPS;
rename countya County_FIPS;

generate fips = State_FIPS*1000+County_FIPS;

generate share_maritalblacks = (j0ye004 + j0ye005 + j0ye010 + j0ye011)/j0ye001;
generate share_maritalwhites = (j04e004 + j04e005 + j04e010 + j04e011)/j04e001;

keep fips State_FIPS County_FIPS share_maritalblacks share_maritalwhites;

save "$outfile/maritalcensus", replace;
