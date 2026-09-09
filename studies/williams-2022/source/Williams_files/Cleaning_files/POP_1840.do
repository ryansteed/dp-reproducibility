clear

#delimit;

*** CLEANING FILE ***;
** Input data file: POP_1840_temp from IPUMS NHGIS;
** Creates analysis data file: POP_1840_NHGIS to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/POP_1840_temp";

rename county County;
rename state State;
rename statea State_FIPS;
rename countya County_FIPS;
** To match with later years;
replace State_FIPS = State_FIPS/10;
replace County_FIPS = County_FIPS/10;
generate fips = State_FIPS*1000 + County_FIPS;

** Rename Florida Territory and counties for merge;
replace State = subinstr(State, "Florida Territory", "Florida", .);
replace County = subinstr(County, "St ", "St. ", .);
replace County = subinstr(County, "DeKalb", "Dekalb", .) if State == "Alabama";
replace County = subinstr(County, "St. John The Baptist", "St. John the Baptist", .) if State == "Louisiana";


rename acd001 Total_POP_1840;

keep fips County State Total_POP_1840;

save "$outfile/POP_1840_NHGIS", replace;
