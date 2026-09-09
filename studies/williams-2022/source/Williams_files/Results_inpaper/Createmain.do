clear
#delimit;

** Do file to create maindata;
** This file will take Input and Analysis data but mostly Analysis data;
** SOS/voting data;

global infile = "Input_data";
global infile2 = "Analysis_data";

use "$infile/SOS";
merge m:1 County State Election using "$infile/SEER_POP";
drop _merge;


generate Blackrate_regvoters = register_black/Black_POP*100;
generate Whiterate_regvoters = register_white/White_POP*100;


generate pop = Black_POP + White_POP;
generate shareblack = (Black_POP/pop)*10000;
generate sharewhite = (White_POP/pop)*10000;


merge m:1 County State using "$infile2/lynchcorrectblacksnomob";
replace lynchingmob = 0 if _merge == 1 & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida");
drop _merge;

merge m:1 County State using "$infile2/lynchcorrectwhites";
replace lynchingmobwhite = 0 if _merge == 1 & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida");
drop _merge;


** Merge with Stevenson data;
merge m:1 County State using "$infile/lynching_Stevenson";
replace lynch_steve= 0 if _merge == 1 & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida");
drop _merge;


merge m:1 fips using "$infile2/POP_1900_NHGIS";
drop _merge;
merge m:1 fips using "$infile2/POP_1910_NHGIS";
drop _merge;
merge m:1 fips using "$infile2/POP_1920_NHGIS";
drop _merge;
merge m:1 fips using "$infile2/POP_1930_NHGIS";
drop _merge;


* Create a flag if 1900 population is missing;
generate flag_POP_1910 = 1 if Black_POP_1910 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida") & Black_POP_1900 ==.;

* Create a flag if 1900 and 1910 population is missing;
generate flag_POP_1920 = 1 if Black_POP_1920 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida") & Black_POP_1910 ==.;

** Generate flag for whites;
generate wflag_POP_1910 = 1 if White_POP_1910 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida") & Black_POP_1900 ==.;

* Create a flag if 1900 and 1910 population is missing;
generate wflag_POP_1920 = 1 if White_POP_1920 != . & (State == "North Carolina"|State =="Louisiana"|State =="Georgia"|State =="Alabama"|State =="South Carolina"|State=="Florida") & Black_POP_1910 ==.;


egen state = group(State);

merge m:1 fips using "$infile2/censuseducation", force;
drop _merge;
merge m:1 fips using "$infile2/censusage";
drop _merge;
merge m:1 fips using "$infile/earnings_QWI";
drop _merge;

merge m:1 fips using "$infile/PartyDominance";
drop _merge;

merge m:1 County State using "$infile2/POP_1840_NHGIS";
drop _merge;

merge m:1 County State using "$infile2/news";
drop _merge;

generate Total_POP_1900 = Black_POP_1900 + White_POP_1900;
generate newscapita = (newspaper/Total_POP_1840)*10000;


merge m:1 fips using "$infile2/POP_2010_NHGIS", force;
drop _merge;

generate Total_POP_2010 = Black_POP_2010 + White_POP_2010;


merge m:1 fips using "$infile2/maritalcensus";
drop _merge;

merge m:1 fips using "$infile2/illiterate_NHGIS";
drop _merge;

merge m:1 fips using "$infile2/votingage1910";
drop _merge;

generate Black_share_illiterate = (Black_illiterate/Black_votingage)*10000;
generate White_share_illiterate = (White_illiterate/White_votingage)*10000;

merge m:1 fips using "$infile2/numslaves";
drop _merge;

merge m:1 fips using "$infile2/POP_1860_NHGIS";
drop _merge;

generate share_slaves =(numslaves/Total_POP_1860)*10000;

merge m:1 fips using "$infile2/religion";
drop _merge;

merge m:1 fips using "$infile/incarceration_2010";
drop _merge;
replace incarceration_2010 = incarceration_2010/10;


merge m:1 fips using "$infile/totalpollscounty";
drop _merge;
generate pollscapita = (polls/Total_POP_2010)*10000;



** Initial Year County was formed (data from Grosjean's paper);
merge m:1 fips using "$infile/propscots_2000_initial";
drop _merge;


merge m:1 fips using "$infile/farmvalue", force;
drop _merge;

** Merge with Acharya et al data;
merge m:1 fips using "$infile/acharya", force;
drop _merge;
generate sfarmprop1860_2 = real(sfarmprop1860);
drop sfarmprop1860;
rename sfarmprop1860_2 sfarmprop1860;
generate fbprop1860_2 = real(fbprop1860);
drop fbprop1860;
rename fbprop1860_2 fbprop1860;
replace fbprop1860 = fbprop1860*10000;
generate landineq1860_2 = real(landineq1860);
drop landineq1860;
rename landineq1860_2 landineq1860;

merge m:1 fips using "$infile/voterreg_1867";
drop _merge;
generate total_reg_1867 = black_reg_1867 + white_reg_1867;
generate blackregshare_1867 = (black_reg_1867/total_reg_1867)*100;


generate blackshare_current = (Black_POP/pop)*100;


**  Calculate lynchings per capita;
generate lynchcapitamob = (lynchingmob/Black_POP_1900)*10000;
replace lynchcapitamob = (lynchingmob/Black_POP_1910)*10000 if flag_POP_1910 == 1;
replace lynchcapitamob = (lynchingmob/Black_POP_1920)*10000 if flag_POP_1920 == 1;
replace lynchcapitamob = 0 if lynchingmob == 0;

generate lynchcapitawhite = (lynchingmobwhite/White_POP_1900)*10000;
replace lynchcapitawhite = (lynchingmobwhite/White_POP_1910)*10000 if wflag_POP_1910 == 1;
replace lynchcapitawhite = (lynchingmobwhite/White_POP_1920)*10000 if wflag_POP_1920 == 1;
replace lynchcapitawhite = 0 if lynchingmobwhite == 0;


generate lynchcapitasteve = (lynch_steve/Black_POP_1900)*10000;
replace lynchcapitasteve = (lynch_steve/Black_POP_1910)*10000 if flag_POP_1910 == 1;
replace lynchcapitasteve = (lynch_steve/Black_POP_1920)*10000 if flag_POP_1920 == 1;
replace lynchcapitasteve = 0 if lynch_steve == 0;


** Create robust to denominator variables;
* 1910;
generate lynchcapitamob1910 = (lynchingmob/Black_POP_1910)*10000;
replace lynchcapitamob1910 = 0 if lynchingmob == 0;
replace lynchcapitamob1910 = (lynchingmob/Black_POP_1920)*10000 if flag_POP_1920 == 1;
* 1920;
generate lynchcapitamob1920 = (lynchingmob/Black_POP_1920)*10000;
replace lynchcapitamob1920 = 0 if lynchingmob == 0;
* 1930;
generate lynchcapitamob1930 = (lynchingmob/Black_POP_1930)*10000;
replace lynchcapitamob1930 = 0 if lynchingmob == 0;


** Global variables;
global ylist_blackturnout Black_turnoutreg;
global ylist_whiteturnout White_turnoutreg;
global ylist_black Blackrate_regvoters;
global ylist_white Whiterate_regvoters;


global historical c.Black_share_illiterate c.initial c.newscapita c.farmvalue c.sfarmprop1860 c.landineq1860 c.fbprop1860;
global cont_black c.Black_beyondhs c.Black_avgage c.Black_Earnings c.share_maritalblacks;
global cont_white c.White_beyondhs c.White_avgage c.White_Earnings c.share_maritalwhites; 

regress $ylist_black lynchcapitamob c.incarceration_2010 c.pollscapita c.share_slaves $historical $cont_black i.State_FIPS i.Election, cluster(fips); 

collapse (mean) Blackrate_regvoters Whiterate_regvoters lynchcapitamob lynchingmob Black_POP_1900 incarceration_2010 share_slaves Black_Earnings White_Earnings blackmemrate register_black register_white lynchcapitawhite pop Black_beyondhs White_beyondhs Black_avgage White_avgage share_maritalblacks share_maritalwhites County_FIPS State_FIPS blackshare_current shareblack pollscapita Black_share_illiterate White_share_illiterate initial newscapita farmvalue sfarmprop1860 landineq1860 fbprop1860 state flag_POP_1920 lynchcapitasteve lynchcapitamob1910 lynchcapitamob1920 lynchcapitamob1930, by(fips County State);


** Add labels;
label variable register_white "Voter registration white";
label variable register_black "Voter registration black";
label variable State_FIPS "State Fips";
label variable County_FIPS "County Fips";
label variable Blackrate_regvoters "Black registered voters";
label variable Whiterate_regvoters "White registered voters";
label variable pop "Population";
label variable shareblack "Voting age blacks (per 10k pop)";
label variable lynchingmob "Black lynchings";
label variable Black_POP_1900 "Black population in 1900";
label variable Black_beyondhs "Some college experience or more of blacks";
label variable White_beyondhs "Proportion of whites w/ at least some college experience";
label variable Black_avgage "Median age of blacks";
label variable White_avgage "Median age of whites";
label variable Black_Earnings "Monthly earnings of blacks";
label variable White_Earnings "Monthly earnings of whites";
label variable newscapita "Average newspapers rate";
label variable initial "County formation";
label variable share_maritalblacks "Black share married";
label variable share_maritalwhites "White share married";
label variable Black_share_illiterate "Proportion of black illiterate men in 1910";
label variable White_share_illiterate "Proportion of white illiterate men in 1910";
label variable share_slaves "Slaves in 1860 (per 10k pop)";
label variable blackmemrate "Black church member rate in 2010";
label variable lynchcapitamob "Black lynching rate";
label variable lynchcapitawhite "White lynching rate";
label variable incarceration_2010 "Incarceration rate of blacks (per 10k pop)";
label variable pollscapita "Polling place rate (per 10k pop)";
label variable blackmemrate "Black church member rate";
label variable farmvalue "Average farm value in 1860";
label variable sfarmprop1860 "Proportion of small farms in 1860";
label variable landineq1860 "Inequality of farmland in 1860";
label variable fbprop1860 "Proportion of free blacks in 1860";
label variable lynchcapitasteve "Black lynching rate (EJI)";
label variable lynchcapitamob1910 "Black lynching rate (in 1910)";
label variable lynchcapitamob1920 "Black lynching rate (in 1920)";
label variable lynchcapitamob1930 "Black lynching rate (in 1930)";

** Keep sample with controls;
regress $ylist_black lynchcapitamob c.incarceration_2010 c.pollscapita $historical $cont_black i.state; 
generate sample = e(sample);


** Restrict data to sample with all controls included to be used throughout analysis;
keep if sample == 1;
drop sample;

save "$infile2/maindata", replace;

