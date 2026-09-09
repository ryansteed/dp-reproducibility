clear

#delimit;

*** CLEANING FILE ***;
** Input file: lynching from Project HAL;
** Creates analysis data files: lynchcorrectblacksnomob and lynchcorrectwhites to be used in Createmain.do;

global infile = "Input_data";
global outfile = "Analysis_data";

use "$infile/lynching";

** Change state abbreviation to full spelling;
replace State = subinstr(State, "LA", "Louisiana", .);
replace State = subinstr(State, "GA", "Georgia", .);
replace State = subinstr(State, "NC", "North Carolina", .);
replace State = subinstr(State, "AL", "Alabama", .);
replace State = subinstr(State, "SC", "South Carolina", .);
replace State = subinstr(State, "FL", "Florida", .);
replace State = trim(State);

** Keep southern states for which voter registration data are separated by race;
keep if State == "Louisiana"|State =="Georgia"|State=="North Carolina"|State=="Alabama"|State=="South Carolina"|State=="Florida";

** Change counties/parishes that are mispelled (or need to match the spelling in voting data) in original data obtained from Project HAL;
replace County = subinstr(County, "Calcasiau", "Calcasieu", .);
replace County = subinstr(County, "Arcadia", "Bienville", .);
replace County = subinstr(County, "Cataloula", "Catahoula", .);
replace County = subinstr(County, "Northamption", "Northampton", .) ;
replace County = subinstr(County, "St. John", "St. John the Baptist", .) ;
replace County = subinstr(County, "E.", "East", .);
replace County = subinstr(County, "W.", "West", .);
replace County = subinstr(County, "Jeff.", "Jefferson", .) if State == "Louisiana";
replace County = subinstr(County, "Dade", "Miami-Dade", .) if State == "Florida";
replace County = subinstr(County, "Suwanee", "Suwannee", .) if State == "Florida";
replace County = subinstr(County, "St. John the Baptists", "St. Johns", .) if State == "Florida";

** Remove extra spaces from County names;
replace County = trim(County);


generate year = real(Year);
sort year;

** Create data set for black victims;
preserve;
** Only focus on black lynchings by non black mobs;
drop if Mob == "Blk";
keep if Race == "Blk";
collapse (count) year, by(County State);

drop if County == "Indeterminant";
** Create number of black lynchings variable;
rename year lynchingmob;

label variable lynchingmob "Number of black lynchings";
save "$outfile/lynchcorrectblacksnomob", replace;
restore;

preserve;
** Create data set for white victims;
keep if Race == "Wht";
collapse (count) year, by(County State);
rename year lynchingmobwhite;
drop if County == "Indeterminant";
label variable lynchingmobwhite "Number of white lynchings";

save "$outfile/lynchcorrectwhites", replace;
restore;
