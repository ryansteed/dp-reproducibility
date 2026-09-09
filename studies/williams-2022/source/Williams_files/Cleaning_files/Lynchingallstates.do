clear

#delimit;

*** CLEANING FILE ***;
** Input file: lynching from Project HAL;
** Creates analysis data files: lynchallstates to be used in Southernfocus.do;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/lynching";

replace State = subinstr(State, "LA", "Louisiana", .);
replace State = subinstr(State, "GA", "Georgia", .);
replace State = subinstr(State, "NC", "North Carolina", .);
replace State = subinstr(State, "AL", "Alabama", .);
replace State = subinstr(State, "SC", "South Carolina", .);
replace State = subinstr(State, "FL", "Florida", .);
replace State = subinstr(State, "AR", "Arkansas", .);
replace State = subinstr(State, "KY", "Kentucky", .);
replace State = subinstr(State, "MS", "Mississippi", .);
replace State = subinstr(State, "TN", "Tennessee", .);
replace State = trim(State);
replace County = subinstr(County, "Calcasiau", "Calcasieu", .);
replace County = subinstr(County, "Arcadia", "Bienville", .);
replace County = subinstr(County, "Cataloula", "Catahoula", .);
replace County = subinstr(County, "Northamption", "Northampton", .);
replace County = subinstr(County, "St. John", "St. John the Baptist", .);
replace County = subinstr(County, "E.", "East", .);
replace County = subinstr(County, "W.", "West", .);
replace County = subinstr(County, "Jeff.", "Jefferson", .) if State == "Louisiana";
replace County = subinstr(County, "Dade", "Miami-Dade", .) if State == "Florida";
replace County = subinstr(County, "Suwanee", "Suwannee", .) if State == "Florida";
replace County = subinstr(County, "St. John the Baptists", "St. Johns", .) if State == "Florida";
replace County = subinstr(County, "Crittendon", "Crittenden", .) if State == "Arkansas";
replace County = subinstr(County, "Issequena", "Issaquena", .) if State == "Mississippi";
replace County = subinstr(County, "Tallahatichie", "Tallahatchie", .) if State == "Mississippi";
replace County = subinstr(County, "Jeff. Davis", "Jefferson Davis", .) if State == "Mississippi";
replace County = trim(County);

generate year = real(Year);
sort year;
drop if Mob == "Blk";
keep if Race == "Blk";
collapse (count) year, by(County State);
rename year lynchingmob;


merge 1:1 County State using "$infile/censusfipscodes";
keep if State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"
|State=="Florida"|State=="Arkansas"|State=="Kentucky"|State=="Mississippi"|State=="Tennessee";
replace lynchingmob = 0 if _merge == 2;
drop _merge;

** Drop counties that are Indeterminant/Undecided/don't exist;
drop if fips == .;

merge m:1 fips using "$outfile/POP_1900_NHGIS";
drop _merge;
merge m:1 fips using "$outfile/POP_1910_NHGIS";
drop _merge;
merge m:1 fips using "$outfile/POP_1920_NHGIS";
drop _merge;
merge m:1 fips using "$outfile/POP_1930_NHGIS";
drop _merge;




* Create a flag if 1900 population is missing;
generate flag_POP_1910 = 1 if Black_POP_1910 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida"|State=="Arkansas"|State=="Kentucky"|State=="Mississippi"|State=="Tennessee") & Black_POP_1900 ==.;

* Create a flag if 1900 and 1910 population is missing;
generate flag_POP_1920 = 1 if Black_POP_1920 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida"|State=="Arkansas"|State=="Kentucky"|State=="Mississippi"|State=="Tennessee") & Black_POP_1910 ==.;

** Generate flag for whites;
generate wflag_POP_1910 = 1 if White_POP_1910 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida"|State=="Arkansas"|State=="Kentucky"|State=="Mississippi"|State=="Tennessee") & Black_POP_1900 ==.;

* Create a flag if 1900 and 1910 population is missing;
generate wflag_POP_1920 = 1 if White_POP_1920 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida"|State=="Arkansas"|State=="Kentucky"|State=="Mississippi"|State=="Tennessee") & Black_POP_1910 ==.;

**  Calculate lynchings per capita;
generate lynchcapitamob = (lynchingmob/Black_POP_1900)*10000;
replace lynchcapitamob = (lynchingmob/Black_POP_1910)*10000 if flag_POP_1910 == 1;
replace lynchcapitamob = (lynchingmob/Black_POP_1920)*10000 if flag_POP_1920 == 1;
replace lynchcapitamob = 0 if lynchingmob == 0;
save "$outfile/lynchallstates", replace;
