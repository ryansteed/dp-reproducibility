clear

#delimit;

*** CLEANING FILE ***;
** Input file:  censuseducation_temp from IPUMS NHGIS;
** Creates analysis data files: censuseducation to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/censuseducation_temp";

rename statea State_FIPS;
rename countya County_FIPS;
generate fips = State_FIPS*1000 + County_FIPS;

generate Black_beyondhs = (grw018 + grw019 + grw020 + grw021 + grw025 + grw026 + grw027 + grw028)/(grw015 + grw016 + grw017 + grw018 + grw019 + grw020 + grw021 + grw022 + grw023 + grw024 + grw025 + grw026 + grw027 + grw028);
generate White_beyondhs = (grw004 + grw005 + grw006 + grw007 + grw011 + grw012 + grw013 + grw014)/( grw001 + grw002 + grw003 + grw004 + grw005 + grw006 + grw007 + grw008 + grw009 + grw010 + grw011 + grw012 + grw013 + grw014);

keep fips State_FIPS County_FIPS Black_beyondhs White_beyondhs;
save "$outfile/censuseducation", replace;
