#delimit;
clear;
set more off;
*set matsize 2000;

global data = "C:\Dropbox\PolicyInnovation\Data";

*-------------------------------------------------------------------------------------------------------;
*-------------------------------------------------------------------------------------------------------;
* ADD AND UPDATE SOME VARIABLES;
*_add NOMINATE scores as alternative measure for polarization;
*_update approval ratings for governor;
*_update TANF spending to 2010;
*_add preferences for redistribution from GSS;
*_correct some bugs in govparty variable;

* UPDATE DATASET (Dec 2016);
*-------------------------------------------------------------------------------------------------------;
*-------------------------------------------------------------------------------------------------------;

use "$data\welfarereform_102014_v48_finaldata.dta",clear; 

*merge information on polarization (based on NOMINATE scores);
sort state year;
merge 1:1 state year using "C:\Dropbox\PolicyInnovation\Data\PoliticalVariables\NOMINATE scores\nominate_polarization_122016";
drop if year <1960;
drop _merge;
sort state year; 
tsset state year;
bysort state: replace diff_nominate_house = diff_nominate_house[_n-1] if diff_nominate_house==. & state ==state[_n-1] & year ==year[_n-1] + 1;
bysort state: replace diff_nominate_senate = diff_nominate_senate[_n-1] if diff_nominate_senate==. & state ==state[_n-1] & year ==year[_n-1] + 1;

*merge new TANF spending data (2009-2011);
merge 1:1 state year using "C:\Dropbox\PolicyInnovation\Data\AFDC\afdc_exp_1978_2011.dta", update;
drop _merge;

*merge updated approval ratings governor; 
merge 1:1 state year using "$data\PoliticalVariables\GovernorData\Approval Ratings\governor_approvalrating_update2009_2010.dta", update; 
drop _merge;

bysort state: gen gov_yes_fill = gov_yes;
bysort state: replace gov_yes_fill = L.gov_yes if gov_yes_fill==.;

save "$data\welfarereform_122016_v49.dta", replace;


clear all;
set maxvar 20000; 

*add data on GSS (preferences for redistribution by census region);
use "C:\Dropbox\PolicyInnovation\Data\GSS_preferences\GSS7214_R6b.dta", clear;
*variable: eqwlth -> recode so that higher values = more redistribution;
gen pref_redistribute = 8 - eqwlth; 
  
*data not available each year -> use past values if missing;
keep year region pref_redistribute natfare; 
collapse pref_redistribute natfare, by(year region); 
tsset region year;
sort region year;
bysort region: replace pref_redistribute = L.pref_redistribute if pref_redistribute==.;
label variable pref_redistribute "8=more redistribution, 0=no"
save "C:\Dropbox\PolicyInnovation\Data\GSS_preferences\pref_redistribute", replace;



use "$data\welfarereform_122016_v49.dta", clear;
*calculate persinc_pc for 2005-2010;
gen personal_incpc_new = personal_inc/pop;
label variable personal_incpc_new "Personal income p.c. (1970-2010)";

/* Define 9 Census regions: 
New England = Maine, Vermont, New Hampshire, Massachusetts, Connecticut, Rhode Island
Middle Atlantic = New York, New Jersey, Pennsylvania 
East North Central = Wisconsin, Illinois, Indiana, Michigan, Ohio
West North Central = Minnesota, Iowa, Missouri, North Dakota, South Dakota, Nebraska, Kansas
South Atlantic = Delaware, Maryland, West Virginia, Virginia, North Carolina, South Carolina, Georgia, Florida, District of Columbia
East South Central = Kentucky, Tennessee, Alabama, Mississippi
West South Central = Arkansas, Oklahoma, Louisiana, Texas
Mountain = Montana, Idaho, Wyoming, Nevada, Utah, Colorado, Arizona, New Mexico
Pacific = Washington, Oregon, California, Alaska, Hawaii */;
rename region region_4;
gen region = 1 if state ==9 | state == 23 | state == 25 | state == 33| state==44| state == 50;
replace region = 2  if state ==34 | state == 36 | state == 42;
replace region = 3 if state ==17 | state == 18 | state == 26 | state ==39| state == 55;
replace region = 4 if state ==19| state == 20 | state == 27 | state == 29| state == 31 | state ==38| state == 46;
replace region = 5 if state ==10| state == 11 | state == 12 |state ==13| state == 24 | state == 37 | state ==45| state == 51 | state == 54;
replace region = 6 if state ==1 | state == 21 | state == 28 | state ==47;
replace region = 7 if state ==5 | state == 22 | state == 40 | state ==48;
replace region = 8 if state ==4 |state ==8 | state == 16| state == 30| state ==32| state == 35 |state == 49|state ==56 ;
replace region = 9 if state ==2 | state == 6 | state == 15 | state ==41| state == 53;
label define region 1 "New England" 2 "Middle Atlantic" 3 "East North Central" 4 "West North Central" 5 "South Atlantic" 6 "East South Central" 7 "West South Central" 8 "Mountain" 9 "Pacific";
label values region region;
sort region year;

merge m:1 region year using "C:\Dropbox\PolicyInnovation\Data\GSS_preferences\pref_redistribute";
drop if _merge ==2;
drop _merge;
sort state year; 
bysort state: replace pref_redistribute = L.pref_redistribute if pref_redistribute==. & year-1==L.year; 
bysort state: replace natfare = L.natfare if natfare==. & year-1==L.year; 
save "$data\welfarereform_122016_v50.dta", replace;


use "$data\welfarereform_122016_v50.dta", clear;

*correct bugs in govparty;
replace govparty = 1 if (year==1993) & st_name=="Alabama";

replace govparty = 1 if (year==1988) & st_name=="Arizona";
replace govparty = 0 if (year==1991) & st_name=="Arizona";
replace governor_name ="Jane Hull" if year==2002 & st_name=="Arizona";
replace govparty = 0 if (year==2009) & st_name=="Arizona";

replace governor_name ="Gray Davis" if year==2003 & st_name=="California";
replace govparty = 0 if (year==2010) & st_name=="California";

replace govparty = 0 if (year==2006) & st_name=="Colorado";

replace govparty = 0 if year==2010 & st_name=="Connecticut";

replace govparty = 0 if year==2010 & st_name=="Hawaii";

replace govparty = 1 if year==2010 & st_name=="Kansas";

replace govparty = 0 if year==1991 & st_name=="Louisiana";

replace govparty = 1 if year==2010 & st_name=="Maine";

replace govparty = 1 if year==2010 & st_name=="Michigan";

replace govparty = 0 if year==2010 & st_name=="Minnesota";

replace govparty = 0 if year==2008 & st_name=="Missouri";

replace govparty = 1 if year>=2008 & year<=2009 & st_name=="New Jersey";

replace govparty = 1 if year==2010 & st_name=="New Mexico";

replace govparty = 1 if year==2010 & st_name=="Ohio";

replace govparty = 1 if (year>=2008 & year<=2010) & st_name=="Oklahoma";

replace govparty = 1 if year==2010 & st_name=="Pennsylvania";

replace govparty = 0 if year==2010 & st_name=="Rhode Island";

replace govparty = 1 if year==2010 & st_name=="Tennessee";

replace govparty = 0 if year==2010 & st_name=="Vermont";

replace govparty = 1 if year>=2008 & year<=2009 & st_name=="Virginia";

replace govparty = 1 if year==2010 & st_name=="Wisconsin";

replace govparty = 1 if year==2010 & st_name=="Wyoming";

replace govparty = 0 if govparty >0 & govparty<0.5;
replace govparty = 1 if govparty >0.5 & govparty<1;


*need to deflate and update tanf spending variables; 
replace afdctanf_exp = tanf_exp if year>2008; 
replace cpi_base2002 = cpi_base_1982_1984/1.799 if year>2004;
cap drop temp;
gen temp = afdctanf_exp/cpi_base2002; drop afdctanf_exp_r; 
gen afdctanf_exp_r = temp if afdctanf_exp_r==.;
drop afdctanf_exp_r_1000 afdctanf_exp_r_1mio;
gen afdctanf_exp_r_1000 = afdctanf_exp_r/1000;
gen afdctanf_exp_r_1mio = afdctanf_exp_r_1000/1000;
drop l2afdctanf_exp_r_1mio;
tsset state year;
bysort state: gen l2afdctanf_exp_r_1mio=L2.afdctanf_exp_r_1mio;

*generate whether state has higher than median preferences for redistribution in 1978;
egen temp = pctile(pref_redistribute) if year==1978, p(50);
gen temp1 = 1 if pref_redistribute >temp & year==1978;
replace temp1 = 0 if pref_redistribute <=temp & year==1978;
bysort state: egen highpref_redistribute1978 = mean(temp1);
drop temp temp1;
save "$data\welfarereform_122016_v50.dta", replace;


merge 1:1 state year using "welfarereform_012017_v44_experimentreversal_newmeasures.dta"
replace sanctiondur = 0.5 if year==1999 & st_name=="Rhode Island"; 
replace sanctiondur = 6 if year==1997 & st_name=="Nevada"; 


