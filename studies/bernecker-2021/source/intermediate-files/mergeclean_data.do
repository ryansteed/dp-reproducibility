# delimit;
set more off; 
*set matsize 2000;


global dem ="[Date for State Demographics]";
global pol ="[Data PoliticalVariables]";
global old ="[Earlier Data]";
global rules ="[Data on Welfare Rules]";

*-------------------------------------;
*-------------------------------------;
*PREPARE DATA FOR ANALYSIS;
*-------------------------------------;
*-------------------------------------;

*merge datasets;
*---------------------; 
use "$pol\polvars_022012.dta", clear;
sort state year;
save, replace; 

use "$rules\welfarerules_022012.dta, clear;
sort state year;
merge 1:1 state year using "$pol\polvars_022012.dta"; 
tab _merge; 
drop _merge; 
sort state year; 
save welfarereform_032012.dta, replace; 

use datacontrols_add.dta, clear;
sort state year;
save, replace; 
use "$dem\datacontrols_022012.dta", clear;
sort state year;
merge 1:1 state year using "$dem\datacontrols_add.dta", update;
tab _merge;
drop _merge;
save "$dem\demographics_032012", replace;

use welfarereform_032012.dta, clear; 
sort state year;
merge 1:1 state year using "$dem\demographics_032012.dta", update;
tab _merge; 
drop _merge; 
sort state year;
qui compress; 

cap replace workenroll = "." if workenroll ==",";
cap replace tlexemp_pre= "." if tlexemp_pre=="..";
cap replace tlexemp1_="." if tlexemp1==",";

*destring some variables;
*----------------------------;
for var womengov election gicrall lowind lowvac upind upvac blackgov limit slimit shortterm: destring X, replace;
for var govparty upcont lowcont aupcont ideology_gov leg_cont divpaymt mandjob workex_preg workex_age interdur: destring X, replace;
for var sen_dem_veto_proof sen_rep_veto_proof hs_dem_veto_proof hs_rep_veto_proof dem_veto_proof rep_veto_proof true_government_cont_a: destring X, replace;
for var alienpre* alienpost* schoolreq schoolbonus imreq healthreq othreq eligminor* eligpreg eligstparent: destring X, replace;
for var workex_age workex_* famcap government_cont sanctionben dsanction sanctiondur dsanctionini sanction1dur duration interdur: destring X, replace; 
for var tlexemp* tlext_* tlexemp1_ tlext twoparhours twoparwkhistory worklimit workenroll tlimit_lif* tlimit_int*: destring X, replace;
save, replace; 



*merge old welfare reform data (until 2008);
*----------------------------------------------;
use "$old\welfare_052011_updated.dta", clear;

*recoding error in that variable; 
drop pop_white; 
*drop created variables; 
drop *index* *lag*;
sort state year; 
save "$old\welfare_052011_updated1.dta", replace; 

use welfarereform_032012_updated, clear;
drop waiver_sanction sanction_impl waiver_earndis earndis_impl;
*merge to old data; 
merge 1:1 state year using "$old\welfare_052011_updated1.dta", update;

tab _merge; 
drop _merge; 


*clean up variables; 
*----------------------------;
for var tanf_fam_july tanf_rec_july: replace X = X/pop if year>=1999 & year<=2011;

replace infants = under5*100/pop if year>=2002 & year<=2011; 
replace kids = yrs517*100/pop if year>=2002 & year<=2011;
replace aged = yrs65older*100/pop if year>=2002 & year<=2011;

gen pop_white = whitepop*100/pop; 
replace pop_black = blackpop*100/pop if year>=2002&year<=2011; 
replace pop_latino = latinopop*100/pop if year>=2002&year<=2011; 

drop yrs65older yrs517 under5 whitepop blackpop latinopop; 
drop state_150; 
drop job_earngain job_retention job_retent; 


*update some variables for 2005-2011;
*-----------------------------------------;
replace governor_name = giname if year>=2005 & year<=2011;
drop giname; 

replace shortterm = shorterm if year<=2005; 
drop shorterm;

drop tlexemp1_; 

drop govparty1 govparty2; 
replace upcont2 = "R" if upcont>=0 & upcont<0.5& year>=2005; replace upcont2 = "D" if upcont>0.5 & upcont<=1 & year>=2005; replace upcont2 = "S" if upcont==0.5 & year>=2005;
replace lowcont2 = "R" if lowcont>=0 & lowcont<0.5 & year>=2005; replace lowcont2 = "D" if lowcont>0.5 & lowcont<=1 & year>=2005; replace lowcont2 = "S" if lowcont==0.5 & year>=2005;
replace govpart2 = "R" if govparty>=0 & govparty<0.5 & year>=2005; replace govpart2 = "D" if govparty>0.5 & govparty<=1 & year>=2005; replace govpart2 = "S" if govparty==0.5 & year>=2005;
rename upcont2 upcont_lett; 
rename lowcont2 lowcont_lett; 
rename govpart2 govparty_lett; 

rename tanf_benfam_july afdc_benfam_july; 
rename tanf_benrec_july afdc_benrec_july;

replace tanf_exp=tanf_exp*1000 if year>2005 & year<=2011;
replace welfareregime = 3 if year>=2005 & year<=2011; 
qui replace policymaking=4 if year>=2005&year<=2011;

replace divided_legis = 0 if year>=2005&((upcont==1|upcont==0)&(lowcont==1|lowcont==0));
replace divided_legis = 1 if year>=2005&((upcont>0&upcont<1)|lowcont==0.5);
replace divided_gov = 1 if year>=2005&((govparty==1&(lowcont~=1|upcont~=1))|(govparty==0&(lowcont==1|upcont==1))|divided_legis==1); 
replace divided_gov = 0 if year>=2005&((govparty==1&lowcont==1&upcont==1)|(govparty==0&lowcont==0&upcont==0)&divided_legis==0);

replace house_percdem=lowdem*100/(lowtot-lowvac) if year>=2005 & year <=2011; 
replace senate_percdem=updem*100/(uptot-upvac) if year>=2005 & year <=2011; 
replace legis_percdem = (house_percdem+senate_percdem)/2 if year>=2005 & year <=2011;

replace lameduck = gicrall if year>=2005 & year<=2011; 
drop gicrall; 

drop perc_imm pop_imm; 
gen perc_imm = imm/pop if year<=1996; 
replace perc_imm = imm_alt/pop if year>=1996 & year<=2011;
label variable perc_imm "%Immigrants admitted last year (/pop)"; 


*reorder variables in dataset: political, rules, demographics; 
*--------------------------------------------------------------;
order state; 
order senate_term-house_nextele, before(blackgov);
order blackgov, after(change);
order childpov, after(povr); 
order interdur-earndis_month5, after(waiver_assets); 
order earndis_month5, after(earndis3_time); 
order state_name, after(st_name);
order state_code, after(state_name);
order lameduck-govparty_lett, before(divpaymt);
order personal_inc-gini_faminc, after(femalehead);
order divided_legis-legis_percdem, after(turnout_house_all);
order tanf_implement - waiver_tanf4, after(tanf_jobretention);
order region, after(state_code);
order division, after(state_code);
order tanf_fam_cy_n, after(tanf_fam_cy);
order pop_n, after(pop); 
order waiver_ever, after (waiver_tanf4); 
order cpi_base2002 statecpi, after(cpi);
order pop_white, after(pop_black); 
order perc_imm imm, before(imm_alt);



*label variables to make it easier to work with; 
*--------------------------------------------------;
label variable shortterm "=1 if 2-year term";
label variable mandjob "dummy whether mandatory job search upon application";
label variable divpaymt "dummy whether state offers diversion payment";

label variable assets "monetary value of maximum unrestricted assets to still be eligible for cash benefits";
label variable elthresh "initial eligibility threshold ($)";
label variable eligpreg "eligible if pregnant";
label variable eligpreg_mo "if eligpreg=1, month of pregnancy during which eligibility begins";
label variable eligminor "dummy whether minor parent eligible";
label variable eligstparent "whether step parents are included/prohibited from assistance unit";
label variable twoparhours "limit on #hours of work for eligibility of two-parent hoursholds";
label variable twoparwkhistory "eligible if principal earner worked #months over certain period";
label variable twoparwait "dummy whether two-parent households face waiting period";

label variable workenroll "1 if hours requirement required upon application/approval/benefit receipt, 0 if later";
label variable worklimit "Dummy whether adult has to work in unsubsidized job after certain #months";
label variable dsanction "1 if most severe sanction full removal of family benefit";
replace sanctionben = 0 if sanctionben==4; 

drop unemployr1-change_caseload2; 
drop womenlegis2-prot_rel2 change_lcaseload change_employment change_lemployment lafdc1 lafdc2 lameduck2 lame_govparty2 minwage2;
drop inter_lamegovparty lafdc lemployment; 
drop totalrevownsources- workercompbenpaymtsy14; 

save welfarereform_032012_v1, replace;



*merge additional demographic data from WorkFamily.dta; 
*-----------------------------------------------------------------;
use "$dem\WorkFamily.dta", clear; 
rename state state_org; 
gen state = 1 if state_org==63;
replace state = 2 if state_org ==94; 
replace state = 4 if state_org ==86; 
replace state = 5 if state_org ==71; 
replace state = 6 if state_org ==93; 
replace state = 8 if state_org ==84; 
replace state = 9 if state_org ==16; 
replace state = 10 if state_org ==51; 
replace state = 11 if state_org ==53; 
replace state = 12 if state_org ==59; 
replace state = 13 if state_org ==58; 
replace state = 15 if state_org ==95; 
replace state = 16 if state_org ==82; 
replace state = 17 if state_org ==33; 
replace state = 18 if state_org ==32; 
replace state = 19 if state_org ==42; 
replace state = 20 if state_org ==47; 
replace state = 21 if state_org ==61; 
replace state = 22 if state_org ==72; 
replace state = 23 if state_org ==11; 
replace state = 24 if state_org ==52; 
replace state = 25 if state_org ==14; 
replace state = 26 if state_org ==34; 
replace state = 27 if state_org ==41; 
replace state = 28 if state_org ==64; 
replace state = 29 if state_org ==43; 
replace state = 30 if state_org ==81; 
replace state = 31 if state_org ==46; 
replace state = 32 if state_org ==88; 
replace state = 33 if state_org ==12; 
replace state = 34 if state_org ==22; 
replace state = 35 if state_org ==85; 
replace state = 36 if state_org ==21; 
replace state = 37 if state_org ==56; 
replace state = 38 if state_org ==44; 
replace state = 39 if state_org ==31; 
replace state = 40 if state_org ==73; 
replace state = 41 if state_org ==92; 
replace state = 42 if state_org ==23; 
replace state = 44 if state_org ==15; 
replace state = 45 if state_org ==57; 
replace state = 46 if state_org ==45; 
replace state = 47 if state_org ==62; 
replace state = 48 if state_org ==74; 
replace state = 49 if state_org ==87; 
replace state = 50 if state_org ==13; 
replace state = 51 if state_org ==54; 
replace state = 53 if state_org ==91; 
replace state = 54 if state_org ==55; 
replace state = 55 if state_org ==35; 
replace state = 56 if state_org ==83; 
sort state year; 
save workfamily1, replace; 

use welfarereform_032012_v1, clear;
drop childpov; drop afdc3; 
rename afdc afdc_old;
sort state year; 
merge 1:1 state year using "$dem\workfamily1.dta", keepusing(childpov state year pcap lnwage fs afdc welfare totbeft eitcmax adexpr tadexp subexp hsexp hsenroll);
tab _merge; 
drop _merge; 
 
*other state programs; 
rename fstamp fstamp_fam4; 
rename fs fstamp_fam3; 
rename tadexp chsup_totalexp;

order childpov-hsenroll, after(minwage); 
order foodstamp1-povthresh_6, after(hsenroll); 
order chsup chsup_totalexp, before(chsup_perchild);

gen caseload = tanf_fam_july*100;
gen caseload_rec = tanf_rec_july*100;
label variable caseload_rec "Recipients AFDC/TANF (% of pop)"; 
label variable caseload "Families on AFDC/TANF (% of pop)"; 
order caseload caseload_*, before(tanf_fam_july);

rename afdc_nominal afdc_fam4;
save welfarereform_032012_v2, replace;


*CPS-ORG data on educational attainment;
*--------------------------------------------------------------;
use welfarereform_032012_v2, clear;
merge 1:1 state year using "C:\Dokumente und Einstellungen\gathmann\Eigene Dateien\My Dropbox\Welfare1996\Data\CPS_ORG\cps_merged_new.dta", update replace; 
tab _merge;
drop _merge;
drop log_tanf_*;
drop log_unma* log_pop;
save welfarereform_032012_v3, replace;


*merge additional missing data (from Michael and Andreas); 
*---------------------------------------------------------;
*political vars + demographic data;

sort state year; 
save welfarereform_032012_v4, replace;
 

*some problem in college: use CPS_ORG from ceprdata instead;
*------------------------------------------------------------;
use welfarereform_032012_v4, clear;

drop college hsgrad dropout; 
sort state year; 
merge 1:1 state year using "$dem\cpsorg.dta";
tab _merge; 
drop _merge;
save "welfarereform_032012_v5", replace;


*missing years 1999, 2003 for some variables; 
*--------------------------------------------------------; 
use "$rules\adddata_fromMichael_1999_2003.dta", clear;  
sort st_name year;
save, replace;

use "welfarereform_032012_v5", clear;
sort st_name year;
merge 1:1 st_name year using "$rules\adddata_fromMichael_1999_2003.dta", update;
drop _merge;

save "welfarereform_042012_v1", replace;


*missing political variables in 2005 (from Andreas); 
*----------------------------------------------------------;
use "welfarereform_042012_v1", clear; 
sort state year;
merge 1:1 state year using "$pol\addData_fromAndreas_2005.dta", update;
drop _merge; 
sort state year;
save "welfarereform_042012_v2", replace; 
use "$pol\polvar_022012", clear; 
keep state year giname;
rename giname governor_name; 
sort state year; 
save temp, replace; 
use "welfarereform_042012_v2", clear; 
merge 1:1 state year using temp, update;
drop _merge;
sort state year;
save, replace;


*add data on vehicle exemptions for asset tests of applicants; 
*---------------------------------------------------------------;
*merge data for 1993-2005 from welfare_092009; 
use "welfare_092009", clear; 
keep state year vehexapp governor_name; 
sort state year; 
save temp.dta, replace; 

use "welfarereform_042012_v2", clear; 
sort state year; 
merge 1:1 state year using temp.dta;
drop _merge; 
erase temp.dta; 
save "welfarereform_042012_v3", replace;

*fix Massachusetts; 
replace vehexapp = 8.1 if st_name=="Massachusetts" & year>=2000 & year<=2005;
*update vehexapp for 2006-2010 from adddata_fromMichael_vehexapp; 
use "$rules\adddata_fromMichael_vehexapp.dta", clear;
sort st_name year;
save, replace; 
use "welfarereform_042012_v3", clear; 
sort st_name year; 
merge 1:1 st_name year using "$rules\adddata_fromMichael_vehexapp.dta", update replace; 
drop _merge; 
qui compress; 
save "welfarereform_042012_v4", replace;


*add behavioral requirements for 1999; 
*---------------------------------------------;
use "welfarereform_042012_v4", clear;
cap replace state_name="DC" if state_name=="Dist. of Col.";
cap replace state_name="DC" if state_name=="District of Columbia";
sort state_name year; 
merge 1:1 state year using "$rules\adddata_behavioralrequirements_1999.dta", update; 
drop _merge; 
save "welfarereform_042012_v5", replace;
 


*add waiver information 1978-1996; 
*---------------------------------------;

use "$rules\Waivers\DatabaseWaivers_GregShaw\Waiver_provision_set.dta", clear;
replace year = 1900 + year;

*create policy experiment variable;
sort id year; 
gen experiment = 0; 
replace experiment = 1 if year!=.; 
bysort state year: egen experiment_waiver= sum(experiment);
label variable experiment_waiver "State applied for waiver in year t";

*match state variable; 
rename state temp; 
gen state = 1 if temp=="al"; 
replace state = 5 if temp=="ar";
replace state = 4 if temp=="az";
replace state = 6 if temp=="ca";
replace state = 8 if temp=="co";
replace state = 9 if temp=="ct";
replace state = 10 if temp=="de";
replace state = 12 if temp=="fl";
replace state = 13 if temp=="ga";
replace state = 15 if temp=="hi";
replace state = 19 if temp=="ia";
replace state = 17 if temp=="il";
replace state = 18 if temp=="in";
replace state = 20 if temp=="ks";
replace state = 21 if temp=="ky";
replace state = 22 if temp=="la";
replace state = 25 if temp=="ma";
replace state = 24 if temp=="md";
replace state = 23 if temp=="me";
replace state = 26 if temp=="mi";
replace state = 27 if temp=="mn";
replace state = 29 if temp=="mo";
replace state = 28 if temp=="ms";
replace state = 30 if temp=="mt";
replace state = 37 if temp=="nc";
replace state = 38 if temp=="nd";
replace state = 5 if temp=="ne";
replace state = 33 if temp=="nh";
replace state = 34 if temp=="nj";
replace state = 35 if temp=="nm";
replace state = 36 if temp=="ny";
replace state = 39 if temp=="oh";
replace state = 40 if temp=="ok";
replace state = 41 if temp=="or";
replace state = 42 if temp=="pa";
replace state = 45 if temp=="sc";
replace state = 46 if temp=="sd";
replace state = 47 if temp=="tn";
replace state = 48 if temp=="tx";
replace state = 49 if temp=="ut";
replace state = 51 if temp=="va";
replace state = 50 if temp=="vt";
replace state = 53 if temp=="wa";
replace state = 55 if temp=="wi";
replace state = 54 if temp=="wv";
replace state = 56 if temp=="wy";
drop temp id; 
drop divided govparty;
rename timelimt timelimit;
rename chldsupc childsupc;
rename chldsups childsups;
for var educ earnings work famcomp famcompc famcomps timelimit medical childsup childsupc childsups other miscadmn: gen dwaiv_X = X;
drop educ earnings work famcomp famcompc famcomps timelimit medical childsup childsupc childsups other miscadmn;
keep experiment_waiver adjacent state appdate-dwaiv_miscadmn; 
drop INCOME1 - ideology; drop PERIOD3;
preserve; 
collapse appdate grntdate implemt hundred famcap legparty scope provis experiment_waiver dwaiv*, by(state year);
sort state year; 
save "$rules\Waivers\DatabaseWaivers_GregShaw\ShawWaivers_subset.dta", replace;
restore;
keep state adjacent; 
duplicates drop;
drop if state==56 & adjacent=="";
replace state=31 if adjacent=="sd,ia,mo,ks,co,wy" & state==5;
sort state;
save "$rules\Waivers\DatabaseWaivers_GregShaw\ShawWaivers_adjacent.dta", replace;


use "welfarereform_042012_v5", clear;
replace perc_urban =. if year>2000;
sort state year; 
merge 1:1 state year using "$rules\Waivers\DatabaseWaivers_GregShaw\ShawWaivers_subset.dta", update; 
drop _merge; 
replace experiment_waiver = 0 if experiment_waiver==. & year>=1978 & year<1997;
qui compress; 

save "welfarereform_042012_v6", replace;



*add missing unemployr (2005) + state expenditures;
*---------------------------------------------------;
use "welfarereform_042012_v6", clear;
cap rename afdc afdc_fam3; 
sort state year; 
merge 1:1 state year using 
	"C:\Dokumente und Einstellungen\gathmann\Eigene Dateien\My Dropbox\PolicyInnovation\Data\PubFinance_NBER\stateexprev_forwelfare.dta";
sum year state if _merge==2;
drop _merge; 	
save "welfarereform_042012_v7", replace;


use "C:\Dokumente und Einstellungen\gathmann\Eigene Dateien\My Dropbox\PolicyInnovation\Data\Demographics\unemploy2001-2005.dta", clear;
gen state=2 if state_code=="AK";
replace state=1 if state_code=="AL";
replace state=5 if state_code=="AR";
replace state=4 if state_code=="AZ";
replace state=6 if state_code=="CA";
replace state=8 if state_code=="CO";
replace state=9 if state_code=="CT";
replace state=11 if state_code=="DC";
replace state=10 if state_code=="DE";
replace state=12 if state_code=="FL";
replace state=13 if state_code=="GA";
replace state=15 if state_code=="HI";
replace state=19 if state_code=="IA";
replace state=16 if state_code=="ID";
replace state=17 if state_code=="IL";
replace state=18 if state_code=="IN";
replace state=20 if state_code=="KS";
replace state=21 if state_code=="KY";
replace state=22 if state_code=="LA";
replace state=25 if state_code=="MA";
replace state=24 if state_code=="MD";
replace state=23 if state_code=="ME";
replace state=26 if state_code=="MI";
replace state=27 if state_code=="MN";
replace state=29 if state_code=="MO";
replace state=28 if state_code=="MS";
replace state=30 if state_code=="MT";
replace state=37 if state_code=="NC";
replace state=38 if state_code=="ND";
replace state=31 if state_code=="NE";
replace state=33 if state_code=="NH";
replace state=34 if state_code=="NJ";
replace state=35 if state_code=="NM";
replace state=32 if state_code=="NV";
replace state=36 if state_code=="NY";
replace state=39 if state_code=="OH";
replace state=40 if state_code=="OK";
replace state=41 if state_code=="OR";
replace state=42 if state_code=="PA";
replace state=44 if state_code=="RI";
replace state=45 if state_code=="SC";
replace state=46 if state_code=="SD";
replace state=47 if state_code=="TN";
replace state=48 if state_code=="TX";
replace state=49 if state_code=="UT";
replace state=51 if state_code=="VA";
replace state=50 if state_code=="VT";
replace state=53 if state_code=="WA";
replace state=55 if state_code=="WI";
replace state=54 if state_code=="WV";
replace state=56 if state_code=="WY";
sort state year;
save, replace; 

use "welfarereform_042012_v7", clear;
sort state year; 
merge 1:1 state year using 
	"C:\Dokumente und Einstellungen\gathmann\Eigene Dateien\My Dropbox\PolicyInnovation\Data\Demographics\unemploy2001-2005.dta", update;
sum year if _merge==2;
drop _merge;	

replace cpi_base2002 = cpi/179.9 if year>=2005;

save "welfarereform_042012_v8", replace;



use "welfarereform_042012_v8", clear;

*add poverty and other vars from statistical abstract;
*------------------------------------------------------;
sort st_name year; 
merge 1:1 st_name year using "$dem/MissingVariables_fromMichael_052012.dta", update;
drop _merge;

drop earndis_month52_min earndis_month52_max earndis_month52 s_sanctionben_level s_sanctiondur s_dsanctionini s_reapply;
save "welfarereform_052012_v9", replace;



*add earnings disregards from 2006-2010 (from Tables by Year);
*----------------------------------------------------------------;
cap drop _merge;
cap drop earndis*_amt;
sort state year; 
merge 1:1 state year using "$rules/earndis_1992_2010.dta", update replace;
drop _merge;

save "welfarereform_052012_v10", replace;


*additional data from WRD for eligminor, schoolbonus etc.;
*-----------------------------------------------------------;
use "$rules/addrules_052012", clear;
for var schoolreq schoolbonus eligminor: destring X, replace;
sort state year;
save, replace;
use "$rules/addrules1_052012", clear;
for var  tlexemp_age tlexemp_chil tlexemp_ill tlexemp_cil tlexemp_vio tlexemp_job tlexemp_coo: destring X, replace; 
drop if state==. & year==.;
sort state year;
save, replace;


use "welfarereform_052012_v10", clear;
sort state year;
merge 1:1 state year using "$rules/addrules_052012.dta", update; 
drop _merge;
merge 1:1 state year using "$rules/addrules1_052012.dta", update;
drop _merge;

save "welfarereform_062012_v11", replace;


*add variable from GregShaw on adjacent states;
*-----------------------------------------------------------;
use "welfarereform_062012_v11", clear;
sort state;
merge m:1 state using "$rules\Waivers\DatabaseWaivers_GregShaw\ShawWaivers_adjacent.dta";
drop _merge;
*some states have adjacent missing -> add; 
replace adjacent = "md,va" if state==11 /*DC*/;
replace adjacent = "mt,nv,or,ut,wa,wy" if state==16 /*Idaho*/;
replace adjacent = "az,ca, id,or,ut" if state==32 /*Nevada*/;
replace adjacent = "ct,nh,ny,vt" if state==44 /*Rhode Island*/;

save "welfarereform_062012_v12", replace;

do "cleancoding_policyrules.do";


*merge variables for quality of governor;
*-----------------------------------------------;
use "$pol/govbios_cleaned_052012.dta", clear;
for var gov_female gov_nochildren gov_attorn gov_lieut gov_secre gov_state gov_congress: destring X, replace;
sort state year;
save, replace;


use "welfarereform_062012_v16", clear;
sort state year;
merge 1:1 state year using "$pol/govbios_cleaned_072012.dta", update replace; 
drop _merge;

*fix some problems with governor names; 
replace governor_name="Tommy G. Thompson" if state==55 & year==2001;
replace governor_name="James S. Gilmore III" if state==51 & year==2001;
replace governor_name="Mike Leavitt" if state==49 & year>=2001 & year<=2003;
replace governor_name="Don Sundquist" if state==47 & year>=2000 & year<=2001;
replace governor_name="William J. Janklow" if state==46 & year==2001;
replace governor_name="Lincoln C. Almond" if state==44 & year>=2001 & year<=2002;
replace governor_name="Frank Keating" if state==40 & year==2001;
replace governor_name="Michael F. Easley" if state==37 & year==2001;
replace governor_name="George E. Pataki" if state==36 & year>=2001 & year<=2006;
replace governor_name="Kenny C. Guinn" if state==32 & year>=2002 & year<=2006;
replace governor_name="Argeo Paul Cellucci" if state==25 & year==2001;
replace governor_name="Parris N. Glendening" if state==24 & year==2001;
replace governor_name="Mike Foster" if state==22 & year>=2002 & year<=2003;
replace governor_name="Angus King Jr." if state==23 & year==2002;
replace governor_name="Frank L. O´Bannon" if state==18 & year>=2001 & year<=2003;
replace governor_name="Dirk Kempthorne" if state==16 & year>=2001 & year<=2005;
replace governor_name="Ruth Ann Minner" if state==10 & year>=2005 & year<=2008;
replace governor_name="Bill Owens" if state==8 & year>=2001 & year<=2006;
replace governor_name="Gray Davis" if state==6 & year==2002;
 
for var gov_code gov_female gov_yob gov_edu gov_marstat gov_nochildren gov_age1steo gov_attorney gov_lieutenant gov_secretary gov_state gov_congress gov_inaugural gov_religion gov_religious: destring X, replace;
sort state year;
for var gov_code gov_female gov_yob gov_edu gov_marstat gov_nochildren gov_age1steo gov_attorney gov_lieutenant gov_secretary gov_state gov_congress gov_inaugural gov_religion gov_religious: 
	replace X=X[_n-1] if state==state[_n-1] & X==. & governor_name==governor_name[_n-1];


save "welfarereform_072012_v17", replace;
save "welfarereform_062012_v13c", replace;



*CORRECT MORE CODING MISTAKES IN POLICY RULES;
*-----------------------------------------------;
use "welfarereform_062012_v13c", clear;

replace eligminor = 0 if year==1999 & (state==22 | state==30);
replace eligminor = 1 if year==1998 & state==40;
replace schoolreq = 1 if year==1999 & state==8;
replace schoolreq = 0 if year==1999 & state==30;
replace schoolreq = 0 if year==1999 & state==33;
replace schoolreq = 1 if year==1999 & state==54;

replace maxben = 364 if state==31 & year>=1998 & year<=1999;
replace maxben = 439 if state==35 & year==1999;

replace hrsreq=20 if year==1996 & state==16;
replace hrsreq= 10 if state==49 & year>=1996 & year<=1997;

replace limitadult=1 if state==36 & year>=2000 & year<=2001;

replace sanctionben = 3 if (year==1997|year==1999|year==2000|year==2003) & state==9;

replace sanctiondur =60 if state==37 & year==2000;

replace reapply=1 if year==2006 & state==34;

replace reapply =0 if state==35 & year>=1998 &year<=2005;
replace reapply =0 if state==41 & year==2000;

save "welfarereform_062012_v14c", replace;



*Governor approval rating;
*-----------------------------;
use "$pol\GovernorData\governor_approvalrating.dta", clear;
rename state state_code;
gen state=2 if state_code==2;
replace state=1 if state_code==1;
replace state=5 if state_code==4;
replace state=4 if state_code==3;
replace state=6 if state_code==5;
replace state=8 if state_code==6;
replace state=9 if state_code==7;
*replace state=11 if state_code=="DC";
replace state=10 if state_code==8;
replace state=12 if state_code==9;
replace state=13 if state_code==10;
replace state=15 if state_code==11;
replace state=19 if state_code==15;
replace state=16 if state_code==12;
replace state=17 if state_code==13;
replace state=18 if state_code==14;
replace state=20 if state_code==16;
replace state=21 if state_code==17;
replace state=22 if state_code==18;
replace state=25 if state_code==21;
replace state=24 if state_code==20;
replace state=23 if state_code==19;
replace state=26 if state_code==22;
replace state=27 if state_code==23;
replace state=29 if state_code==25;
replace state=28 if state_code==24;
replace state=30 if state_code==26;
replace state=37 if state_code==33;
replace state=38 if state_code==34;
replace state=31 if state_code==27;
replace state=33 if state_code==29;
replace state=34 if state_code==30;
replace state=35 if state_code==31;
replace state=32 if state_code==28;
replace state=36 if state_code==32;
replace state=39 if state_code==35;
replace state=40 if state_code==36;
replace state=41 if state_code==37;
replace state=42 if state_code==38;
replace state=44 if state_code==39;
replace state=45 if state_code==40;
replace state=46 if state_code==41;
replace state=47 if state_code==42;
replace state=48 if state_code==43;
replace state=49 if state_code==44;
replace state=51 if state_code==46;
replace state=50 if state_code==45;
replace state=53 if state_code==47;
replace state=55 if state_code==49;
replace state=54 if state_code==48;
replace state=56 if state_code==50;

drop if year==.;
keep gov_yes gov_no state year elecyr type;
gen gov_yes_adults=gov_yes if type==3;
gen gov_no_adults=gov_no if type==3;
collapse gov_yes* gov_no* elecyr, by(state year); 
sort state year; 
save "$pol\GovernorData\governor_jobapproval1.dta", replace;

use "welfarereform_062012_v14c", clear;
sort state year; 
merge 1:1 state year using "$pol\GovernorData\governor_jobapproval1.dta"; 
tab _merge; 
drop _merge;
save "welfarereform_062012_v15c", replace;
 

*Merge information on neighboring states; 
*see files in \Neighbors_WaivExpReverse;



*Governor ideology (from NOMINATE ideology measures); 
*------------------------------------------------------------;
use "$pol\SPPQ_2010_GovernorIdeology_Nominate.dta", clear; 
*redefine state variables; 
rename state state_old; 
gen state=1 if state_old==1;
replace state=2 if state_old==2;
replace state=4 if state_old==3;
replace state=5 if state_old==4;
replace state=6 if state_old==5;
replace state=8 if state_old==6;
replace state=9 if state_old==7;
replace state=10 if state_old==8;
replace state=12 if state_old==9;
replace state=13 if state_old==10;
replace state=15 if state_old==11;
replace state=16 if state_old==12;
replace state=17 if state_old==13;
replace state=18 if state_old==14;
replace state=19 if state_old==15;
replace state=20 if state_old==16;
replace state=21 if state_old==17;
replace state=22 if state_old==18;
replace state=23 if state_old==19;
replace state=24 if state_old==20;
replace state=25 if state_old==21;
replace state=26 if state_old==22;
replace state=27 if state_old==23;
replace state=28 if state_old==24;
replace state=29 if state_old==25;
replace state=30 if state_old==26;
replace state=31 if state_old==27;
replace state=32 if state_old==28;
replace state=33 if state_old==29;
replace state=34 if state_old==30;
replace state=35 if state_old==31;
replace state=36 if state_old==32;
replace state=37 if state_old==33;
replace state=38 if state_old==34;
replace state=39 if state_old==35;
replace state=40 if state_old==36;
replace state=41 if state_old==37;
replace state=42 if state_old==38;
replace state=44 if state_old==39;
replace state=45 if state_old==40;
replace state=46 if state_old==41;
replace state=47 if state_old==42;
replace state=48 if state_old==43;
replace state=49 if state_old==44;
replace state=50 if state_old==45;
replace state=51 if state_old==46;
replace state=53 if state_old==47;
replace state=54 if state_old==48;
replace state=55 if state_old==49;
replace state=56 if state_old==50;
sort state year;
save, replace; 


use "welfarereform_072012_v17", clear;
sort state year; 
merge 1:1 state year using "$pol\SPPQ_2010_GovernorIdeology_Nominate.dta"; 
tab _merge; 
drop _merge;
drop state_old demlo demup replo repup statename;
save "welfarereform_082012_v18", replace;



*Spatial Spillover Vars;
*------------------------;
*see separate do-file;


*AFDC Expenditures;
*------------------------;
use "welfarereform_082012_v19, clear;
sort state year;
merge 1:1 state year using afdc_exp_part1; 
drop _merge;
merge 1:1 state year using afdc_exp_part2; 
drop _merge;
gen afdctanf_exp = afdc_exp;
replace afdctanf_exp = tanf_exp if afdctanf_exp==.;
gen afdctanf_exp_r=afdctanf_exp/cpi_base2002;
sort state year;
save "welfarereform_082012_v20, replace;







