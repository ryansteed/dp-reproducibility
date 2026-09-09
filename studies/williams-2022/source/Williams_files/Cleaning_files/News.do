clear

#delimit;

*** CLEANING FILE ***;
** Input data file: news_temp from IPUMS NHGIS;
** Creates analysis data file: news to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";


use "$infile/news_temp";
generate State_FIPS = real(statea);
generate County_FIPS = real(countya);
rename county County;
rename state State;
** To match with later years;
replace State_FIPS = State_FIPS/10;
replace County_FIPS = County_FIPS/10;
generate fips = State_FIPS*1000 + County_FIPS;

** Rename Florida Territory and counties for merge;
replace State = subinstr(State, "Florida Territory", "Florida", .);
replace County = subinstr(County, "St ", "St. ", .);
replace County = subinstr(County, "DeKalb", "Dekalb", .) if State == "Alabama";
replace County = subinstr(County, "St. John The Baptist", "St. John the Baptist", .) if State == "Louisiana";


egen total = rowtotal(acm001 acm002 acm003 acm004);

** Dividing by four because of the 4 different types of newspapers;
generate newspaper = total/4;
keep County State newspaper;

save "$outfile/news", replace;
