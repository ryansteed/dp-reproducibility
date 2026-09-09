*** EDITED BY Annie Qian  
version 16
***

*** EDITED BY Annie Qian 
*** Install these package before running
*ssc install outreg2
*ssc install binscatter
*ssc install xtabond2
***

#delimit ;
clear all;
set more off;


global data = ".";
global results = ".";


***************************************************************************************************************;
* REPLICATION FILE FOR RESULTS IN "POLICY EXPERIMENTATION";
*
* March 2020;
***************************************************************************************************************;

use "$data/experimentation_replicationdata.dta", clear;
sort state year;
xtset state year;

*------------------------------------------------------------------------------------------------;
*Main Tables;
*------------------------------------------------------------------------------------------------;

*Table 1: summary statistics; 
*-------------------------------------------------; 
log using "$results/Table1.log", replace;
sum experiment_waiver experiment_base reversal_base;
sum lmargin lameduck gov_age gov_rep governor_ideo;
sum ideology_citi pvi divided_gov up_dem_share low_dem_share polarization_senate polarization_house hvd_4yr; 
sum l2afdctanf_exp_r_1mio perc_l2afdctanf_exp_r_1mio pop_1000 aged kids pop_black perc_imm unmarried_birth p90p10_hhinc;
sum l.pop_neighbors_pooled l.geo_neighbors_pooled exp_pooled_govp_neighbors_lag1; 
log close;


foreach Y of varlist experiment_pooled {;

keep if state!=2 & state!=15 & state!=31; 
keep if year>=1978 & year<2008;


*Table 2: electoral incentives baseline; 
*-------------------------------------------------; 
xi: areg `Y' lmargin gov_age pop_1000 aged kids i.state, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table2.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("Margin") bdec(3) noaster;

eststo: xi: areg `Y' lmargin gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table2.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck gov_age pop_1000 aged kids i.state, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table2.xls", append addtext(Year FE, YES, State FE, YES) ctitle("interaction") bdec(3) noaster;

eststo: xi: areg `Y' lmargin int_lameduck_margin lameduck gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table2.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table2.xls", append addtext(Year FE, YES, State FE, YES) ctitle("gains") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table2.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;
*Table 3: electoral incentives robustness;
*-------------------------------------------------; 


xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year i.state*year2 i.state*year3, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("cubic trend") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*i.decade ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("decade FE") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio govparty_changes_last8years hvd_4yr gov_age  pop_1000 aged kids i.state*year ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

cap drop test; cap drop int_lameduck_test;
bysort gov_code: egen test=mean(lmargin); 
gen int_lameduck_test=lameduck*test;
xi: areg `Y' test int_lameduck_test lameduck l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("margin career") bdec(3) noaster;

egen testo =pctile(test), p(50);
gen test1 = 1 if test>testo;
replace test1 = 0 if test<testo;
cap drop int_lameduck_test1;
gen int_lameduck_test1 = lameduck*test1; 
xi: areg `Y' test1 int_lameduck_test1 lameduck l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("D(>median)") bdec(3) noaster;
cap drop test*; 

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year if slimit==0,  cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("limit>1") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year if limit==1,  cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("drop nolimit") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck perc_l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("growth") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids pop_black perc_imm unmarried_birth p90p10_hhinc i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("add X") bdec(3) noaster;


*Table 4: governor ideology;
*-------------------------------------------------; 
xi: areg `Y' gov_rep gov_age gov_age pop_1000 aged kids i.state*year , cluster(cluster_var) absorb(year);
outreg2 using "$results/Table4.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("Rep") bdec(3) noaster;

xi: areg `Y' governor_ideo gov_age pop_1000 aged kids i.state*year , cluster(cluster_var) absorb(year);
outreg2 using "$results/Table4.xls", append addtext(Year FE, YES, State FE, YES) ctitle("Ideo") bdec(3) noaster;

*split sample;
xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age gov_age pop_1000 aged kids i.state*year  if gov_rep==1, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table4.xls", append addtext(Year FE, YES, State FE, YES) ctitle("Rep=1") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age gov_age pop_1000 aged kids i.state*year  if gov_rep==0, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table4.xls", append addtext(Year FE, YES, State FE, YES) ctitle("Dem=1") bdec(3) noaster;


*Table 5: voter ideology;
*-------------------------------------------------; 
xi: areg `Y' ideology_citi lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table5.xls", replace addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

xi: areg `Y' pvi lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table5.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

cap drop test*;
egen test = pctile(pref_redistribute), p(50); 
gen testo =1 if pref_redistribute>test;   /*=1 if stronger pref for redistribution*/
replace testo =0 if pref_redistribute<=test;

xi: areg `Y' lmargin int_lameduck_margin lameduck i.testo*l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table5.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

drop test testo;
egen test = pctile(natfare), p(50); 
gen testo =1 if natfare<=test;  /*government spends too little on welfare*/
replace testo =0 if natfare>test;

xi: areg `Y' lmargin int_lameduck_margin lameduck i.testo*l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table5.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;


*Table 6: role of legislature;
*-------------------------------------------------; 
xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio up_dem_share low_dem_share gov_age pop_1000 aged kids i.state*year , cluster(cluster_var) absorb(year);
outreg2 using "$results/Table6.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("Dem share") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio polarization_senate polarization_house gov_age pop_1000 aged kids i.state*year , cluster(cluster_var) absorb(year);
outreg2 using "$results/Table6.xls", append addtext(Year FE, YES, State FE, YES) ctitle("polarize") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio divided_gov gov_age pop_1000 aged kids i.state*year , cluster(cluster_var) absorb(year);
outreg2 using "$results/Table6.xls", append addtext(Year FE, YES, State FE, YES) ctitle("divided") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio up_dem_share low_dem_share polarization_senate polarization_house divided_gov gov_age pop_1000 aged kids i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table6.xls", append addtext(Year FE, YES, State FE, YES) ctitle("all") bdec(3) noaster;


*Table 7: spillover effects;
*-------------------------------------------------; 
sort state year;
xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio l.pop_neighbors_pooled pop_1000 aged kids gov_age i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table7.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("pop") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio l.geo_neighbors_pooled pop_1000 aged kids gov_age  i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table7.xls", append addtext(Year FE, YES, State FE, YES) ctitle("geo") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio exp_pooled_govp_neighbors_lag1 pop_1000 aged kids gov_age  i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table7.xls", append addtext(Year FE, YES, State FE, YES) ctitle("ideo") bdec(3) noaster;

xi: areg `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio l.pop_neighbors_pooled l.geo_neighbors_pooled exp_pooled_govp_neighbors_lag1 pop_1000 aged kids gov_age  i.state*year, cluster(cluster_var) absorb(year);
outreg2 using "$results/Table7.xls", append addtext(Year FE, YES, State FE, YES) ctitle("all") bdec(3) noaster;
};


*Table 8: policy reversals;
*-------------------------------------------------; 
qui gen afdctanf_exp_r_10mio=afdctanf_exp_r_1mio/10;
foreach Y of varlist reversal_base {;

keep if state!=2 & state!=15 & state!=31; 
keep if year>=1978 & year<=2008;

xi: areg `Y' afdctanf_exp_r_10mio gov_age pop_1000 kids aged i.state, cluster(state) absorb(year);
outreg2 using "$results/Table8.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("gains") bdec(3) noaster;

xi: areg `Y' afdctanf_exp_r_10mio lameduck gov_age pop_1000 kids aged i.state, cluster(state) absorb(year);
outreg2 using "$results/Table8.xls", append addtext(Year FE, YES, State FE, YES) ctitle("lameduck") bdec(3) noaster;

xi: areg `Y' afdctanf_exp_r_10mio lameduck gov_rep gov_age pop_1000 kids aged i.state, cluster(state) absorb(year);
outreg2 using "$results/Table8.xls", append addtext(Year FE, YES, State FE, YES) ctitle("Rep") bdec(3) noaster;

xi: areg `Y' afdctanf_exp_r_10mio lmargin gov_age pop_1000 kids aged i.state, cluster(state) absorb(year);
outreg2 using "$results/Table8.xls", append addtext(Year FE, YES, State FE, YES) ctitle("margin") bdec(3) noaster;
};


*Figures 1+2: experimentation and vote margin by lameduck;
*--------------------------------------------------------------; 
binscatter experiment_pooled lmargin, nquantiles(20) by(lameduck) xtitle("Past Vote Margin (in percentage points)") msymbols(O T) ///
	ytitle("# Experiments by State and Year") legend(label(1 "No Lame duck") label(2 "Lame duck"))  savegraph("$results/Figure1.gph") replace;
graph export "$results/Figure1.eps", replace;

binscatter experiment_pooled lmargin, nquantiles(20) by(gov_rep) xtitle("Past Vote Margin (in percentage points)") msymbols(O T)  ///
	ytitle("# Experiments by State and Year") legend(label(1 "Democrat") label(2 "Republican")) savegraph("$results/Figure2.gph") replace;
graph export "$results/Figure2.eps", replace;
	
*------------------------------------------------------------------------------------------------;
*Appendix Tables and Figures;
*------------------------------------------------------------------------------------------------;

foreach Y of varlist experiment_pooled {;

keep if state!=2 & state!=15 & state!=31; 
keep if year>=1978 & year<2008;

*Table A1: Description of Policy Rules; 
*-------------------------------------------------;
*this table provides a short description of the welfare rules that define policy experiments and reversals;
*The information in this table is not based on any calculation or estimation;


*Table A2: Arellano-Bond, Poisson, Probit;
*-------------------------------------------------;
xi: poisson `Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year i.year, vce(robust);
outreg2 using "$results/TableA2.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("poisson") bdec(3) noaster;

xi: dprobit dexperiment_pooled lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids i.state*year i.year, cluster(cluster_var);
outreg2 using "$results/TableA2.xls", append addtext(Year FE, YES, State FE, YES) ctitle("probit") bdec(3) noaster;

qui tab year, gen(dyear);
log using "$results/TableA2.log", replace;

xtabond2 `Y' L.`Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids dyear*, gmm(L.`Y' lmargin int_lameduck_margin lameduck l2afdctanf_exp_r_1mio gov_age pop_1000 aged kids, laglimits(1 4)) artests(3);
outreg2 using "$results/TableA2.xls", append addtext(Year FE, YES, State FE, YES) ctitle("Abond") bdec(3) noaster;
log close; 
drop dyear*;


*Table A3: Proxies for Competence;
*-------------------------------------------------;
xi: areg `Y' i.gov_lowedu lameduck lmargin int_lameduck_margin l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/TableA3.xls", replace addtext(Year FE, YES, State FE, YES) ctitle("low edu") bdec(3) noaster;

xi: areg `Y' i.gov_lowedu*i.lameduck lmargin int_lameduck_margin l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/TableA3.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;

xi: areg `Y' i.gov_quality1_low lameduck lmargin int_lameduck_margin l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/TableA3.xls", append addtext(Year FE, YES, State FE, YES) ctitle("low exp") bdec(3) noaster;

xi: areg `Y' i.gov_quality1_low*i.lameduck lmargin int_lameduck_margin l2afdctanf_exp_r_1mio gov_age  pop_1000 aged kids i.state*year ,  cluster(cluster_var) absorb(year);
outreg2 using "$results/TableA3.xls", append addtext(Year FE, YES, State FE, YES) ctitle(" ") bdec(3) noaster;
};


*Table A4: Descriptives on Reversals; 
*-------------------------------------------------;
cap log close;

log using "$results/TableA4.log", replace;
log off; 

local xvar "famcap hrsreq enroll limit tl_duration interdur limitadult sanctionben sanctiondur reapply dsanctionini"; 
 
foreach X of local xvar {; 
cap drop no_`X' nor_`X';
qui egen no_`X' = total(temp_`X'); 		/*experiments*/
qui egen nor_`X' = total(tempr_`X');	/*reversals*/

*difference reversal and adoption year; 
cap drop diff_`X';
qui gen test_`X' = year if temp_`X' == 1; 
bysort state: egen diff_`X' = min(test_`X');
*replace diff_`X' = (-1)*diff_`X' if diff_`X'<0 & diff_`X'!=.;
qui replace diff_`X' = year - diff_`X' if tempr_`X'==1 & year>=diff_`X';
qui replace diff_`X' =. if tempr_`X'==. | tempr_`X'==0;
qui drop test_`X'; 

*#electoral cycles between adoption and reversal of a policy experiment; 
cap drop eleccycle_`X';
qui gen test_`X' = eleccycle if temp_`X' == 1; 
bysort state: egen testo_`X' = min(test_`X');
qui replace testo_`X' = eleccycle - testo_`X' if tempr_`X'==1; 
qui replace testo_`X' =. if tempr_`X'==0 | tempr_`X'==.;
qui rename testo_`X' eleccycle_`X';
qui gen deleccycle_`X' = (eleccycle_`X'==0);
qui replace deleccycle_`X'=. if eleccycle_`X'==.;
qui drop test_`X'; 

*whether adoption and reversal by same party (0: yes, >0: no); 
cap drop diffparty_`X';
qui gen test_`X' = govparty if temp_`X' == 1; 
bysort state: egen testo_`X' = mean(test_`X');
qui replace testo_`X' = govparty - testo_`X' if tempr_`X'==1; 
qui replace testo_`X' =. if tempr_`X'==0 | tempr_`X'==.;
qui rename testo_`X' diffparty_`X';
qui gen dsameparty_`X'=(diffparty_`X'==0);
qui replace dsameparty_`X'=. if diffparty_`X'==.;
qui drop test_`X';

*indicator whether adoption and reversal by same governor (0: yes, >0: no); 
cap drop diffgov_`X';
qui gen test_`X' = gov_code if temp_`X' == 1; 
bysort state: egen testo_`X' = mean(test_`X');
qui replace testo_`X' = gov_code - testo_`X' if tempr_`X'==1; 
qui replace testo_`X' =. if tempr_`X'==0 | tempr_`X'==.;
qui rename testo_`X' diffgov_`X';
qui gen dsamegov_`X'=(diffgov_`X'==0);
qui replace dsamegov_`X'=. if diffgov_`X'==.;
qui drop test_`X';
};


log on;
di "No. Experiments and Reversals";
di "------------------------------";
sum no_* nor_*; 

egen testcase =rsum(no_*);
egen testcaser =rsum(nor_*);
qui gen share_reversed = testcaser/testcase;

di "Reversals on Average"; 
sum share_reversed;
 
di "Reversal in Same Electoral Cycle (1= yes, 0 = no)";
di "-----------------------------------------------------------------------";
sum deleccycle_*;

di "Time Lag between Adoption and Reversal (measured in years)";
di "-----------------------------------------------------------------------";
sum diff_*; 

di "Reversal by Same Party? (1 =yes, 0 =no)";
di "-----------------------------------------------------------------------";
sum dsameparty_*;

di "Reversal by Same Governor? (1=yes, 0 = no)";
di "-----------------------------------------------------------------------";
sum dsamegov_*;
log close;


*Figures A1 and A2: Time Series of Waivers, Experiments and Reversals;
*----------------------------------------------------------------------------------------;
bysort year: egen mean_waiver =mean(experiment_waiver);
graph twoway line mean_waiver year if year>=1978 & year<=1996, ytitle("# Waiver Applications") saving("$results/FigureA1.gph", replace);
graph export "$results/FigureA1.eps", replace;


bysort year: egen mean_experiment = mean(experiment_base);
bysort year: egen mean_reversal = mean(reversal_base);
graph twoway line mean_experiment year if year>=1996 & year<2008, lpattern(solid) || line mean_reversal year if year>=1996 & year<2008, lpattern(dash) ytitle("Number")  legend(label(1 "Experiments") label(2 "Reversals")) saving("$results/FigureA2.gph", replace);
graph export "$results/FigureA2.eps", replace;
