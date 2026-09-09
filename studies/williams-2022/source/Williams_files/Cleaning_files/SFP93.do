clear all

*** CLEANING FILE ***;
** Input data file: sfp93_temp from the Southern Focus Poll;
** Creates analysis data file: sfp93 to be used in __.do;

#delimit;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/sfp93_temp";

** Create fips code;
rename STFIPS State_FIPS;
rename CNTY County_FIPS;
generate fips = State_FIPS*1000+County_FIPS;


** PATRIOT is when you were growing up, how important was it to your parents that you be patriotic;
** Note: This variable is available in other years but is a different question;
** 5 = dont know or no answer/ this is in reverse order i.e. 1 = important 4 = not at all important;
replace PATRIOT = . if PATRIOT == 5 & year == 1993;
** The variable pat will rescale patriot so that highest value means really patriotic;
generate pat = .;
replace pat = 1 if PATRIOT == 4;
replace pat = 2 if PATRIOT == 3;
replace pat = 3 if PATRIOT == 2;
replace pat = 4 if PATRIOT == 1;

save "$outfile/sfp93", replace;


