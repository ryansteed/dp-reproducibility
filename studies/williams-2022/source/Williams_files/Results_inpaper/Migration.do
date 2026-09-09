clear all

#delimit;

** Note: This do file will produce Table 6;
global infile = "Input_data";
global infile2 = "Analysis_data";
global outfile = "Latex_files";


use "$infile/migrationrace";

** Recode to missing using IPUMS codes;
replace migplac5 = . if migplac5 == 000 | migplac5 == 999;
replace educ = . if educ == 00 | educ == 99;
replace nativity = . if nativity == 0;
replace bpl = . if bpl == 950 | bpl == 990;
replace statefip = . if statefip == 99;
replace rent = . if rent == 0000|rent == 9997|rent == 9998|rent == 9999;
replace incwage = . if incwage == 999998| incwage == 999999;
replace wkswork1 = . if wkswork1 == 0;
rename statefip State_FIPS;
generate fipsICP = State_FIPS*10000 +county;


generate confederate40 = .;
replace confederate40 = 1 if State_FIPS == 01|State_FIPS == 12|State_FIPS == 13|State_FIPS == 22|State_FIPS == 37|State_FIPS == 45;
replace confederate40 = 0 if State_FIPS != 01&State_FIPS != 12&State_FIPS != 13&State_FIPS != 22&State_FIPS != 37&State_FIPS != 45;
generate confederate35 = .;
replace confederate35 = 1 if migplac5 == 01|migplac5 == 12|migplac5 == 13|migplac5 == 22|migplac5 == 37|migplac5 == 45;
replace confederate35 = 0 if migplac5 != 01&migplac5 != 12&migplac5 != 13&migplac5 != 22&migplac5 != 37&migplac5 != 45;


generate outmigrant = 1 if confederate35 == 1 & confederate40 == 0 & migcounty != 9999;
replace outmigrant = 0 if confederate35 == 1 & confederate40 == 1 & migcounty != 9999; 


** Make educ an binary variable;
generate educcollapsed = .;
replace educcollapsed = 1 if educ == 3|educ == 4|educ == 5|educ == 6|educ == 7|educ == 8|educ == 9|educ == 10|educ == 11;
replace educcollapsed = 0 if educ == 1|educ == 2;

generate female = .;
replace female = 1 if sex == 2;
replace female = 0 if sex == 1;

generate fulltime = .;
replace fulltime = 0 if wkswork1 < 40;
replace fulltime = 1 if wkswork1 >= 40;


egen state = group(State);
generate ln_wage = ln(incwage);


** Match streets to the fipsICP code 5 years earlier;
** Note: Less than or equal to 56 since the last state's code is 56;
generate migfipsICP = migplac5*10000 + migcounty if migplac5 <=56 & migcounty!=9999;


** Drop outmigrant if missing since I have over 12 million observations;
drop if outmigrant == .;
** Note: It is an m:m merge because Hawaii has multiple migfipsICP codes for different County but Hawaii isn't needed for analysis;
merge m:m migfipsICP using "$infile/migICPcodes";
drop _merge;


merge m:1 County State using "$infile2/maindata";
drop _merge;

** Analysis for outmigrants;

global historical c.Black_share_illiterate c.initial c.newscapita c.farmvalue c.sfarmprop1860 c.landineq1860 c.fbprop1860;
* Income;
regress ln_wage i.outmigrant##c.lynchcapitamob $historical i.migplac5 [pweight = perwt], cluster(migplac5);
estimates store logwage;
* Age;
regress age i.outmigrant##c.lynchcapitamob $historical i.migplac5 [pweight = perwt], cluster(migplac5);
estimates store age;
* Female dummy;
regress female i.outmigrant##c.lynchcapitamob $historical i.migplac5 [pweight = perwt], cluster(migplac5);
estimates store female;
* Education dummy (more than high school);
regress educcollapsed i.outmigrant##c.lynchcapitamob $historical i.migplac5 [pweight = perwt], cluster(migplac5);
estimates store education;
* Full-time dummy;
regress fulltime i.outmigrant##c.lynchcapitamob $historical i.migplac5 [pweight = perwt], cluster(migplac5);
estimates store fulltime;
* Rent;
regress rent i.outmigrant##c.lynchcapitamob $historical i.migplac5 [pweight = perwt], cluster(migplac5);
estimates store rent;

label variable lynchcapitamob "Black lynching rate";
label variable outmigrant "Outmigrant";

*Table 6;
esttab logwage age female education fulltime rent using "$outfile/Iners14.tex", keep(1.outmigrant#c.lynchcapitamob 1.outmigrant lynchcapitamob) 
order(1.outmigrant#c.lynchcapitamob 1.outmigrant lynchcapitamob) 
indicate("Historical Controls = newscapita" "State Fixed Effects = *.migplac5")
mlabels(Log(wage) Age Female Ninth-grade Full-time Rent, lhs("\makecell[l]{Out-Migrants vs.\\Stayers}")) 
nomtitles collabels(none) varlabels(_cons "Constant" 1.outmigrant "Outmigrant" 1.outmigrant#c.lynchcapitamob "\makecell[l]{Black lynching rate*\\Outmigrant Status}") 
label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) stats(N r2, labels("\# of observations" "R-Squared") 
fmt(%11.0gc %9.3f)) replace;
