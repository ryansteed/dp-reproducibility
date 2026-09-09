version 11

***************************************************************
*** Date: March, 2010
***************************************************************
*** This program  creates the tables for paper 
*** "Factor Immobility and Regional Impact of Trade Liberalization: Evidence from India"
*** Author: Petia Topalova (ptopalova@imf.org)
***************************************************************

***************************************************************
*** SETUP
***************************************************************
clear
capture log close
set memory 600m
set matsize 5000
set more off
# delimit;
tempfile a;

* do "e:\d\data\jmpprograms\aej\SentToJournal20100404\tables.do";
cd ".";

global cov2 "pcnt_litpost pcnt_scstpost  pcnt_mfgpost  pcnt_farmpost  pcnt_tradepost  pcnt_tranpost  pcnt_minpost  pcnt_servpost  post_law ";
global cov3 "minmfgmfdi minmfgmlicense bankpercap"  ;

local begin=1;
*********************************************************************************;
if `begin' {;
*********************************************************************************;
*** Table 1. Summary Statistics ;
*********************************************************************************;

use rural_data, replace;
*** Edited by Ryan Steed;
sort st_code43 dist_code43;
***;
for X in any inpov logmean : gen X43a = X if round==43 \
			     gen X38a = X if round==38;
						      
for X in any inpov logmean : 
		by st_code43 dist_code43 : egen X43 = max(X43a) \ 
		by st_code43 dist_code43 : egen X38 = max(X38a) \ 
					   gen Xtrend = X43-X38 \ drop X43a X38a ;
				

sum inpov logmean  tariff trallmtariff free minmfgmfdi minmfgmlicense bankpercap if round==43 & tariff!=.;
sum inpov logmean  tariff trallmtariff free minmfgmfdi minmfgmlicense bankpercap if round==55 & tariff!=.;
sum pcnt_lit pcnt_scst pcnt_farm pcnt_mfg pcnt_min pcnt_serv pcnt_trade pcnt_tran pcnt_constr inpovtrend logmeantrend if round==43 & tariff!=.;


use urban_data, replace;
*** Edited by Ryan Steed;
sort st_code43 regcod;
***;	
for X in any inpov logmean : gen X43a = X if round==43 \
			     gen X38a = X if round==38;
						      
for X in any inpov logmean : 
		by st_code43 regcod : egen X43 = max(X43a) \ 
		by st_code43 regcod : egen X38 = max(X38a) \ 
					   gen Xtrend = X43-X38 \ drop X43a X38a ;

sum inpov logmean  tariff trallmtariff free minmfgmfdi minmfgmlicense bankpercap if round==43 & tariff!=.;
sum inpov logmean  tariff trallmtariff free minmfgmfdi minmfgmlicense bankpercap if round==55 & tariff!=.;
sum pcnt_lit pcnt_scst pcnt_farm pcnt_mfg pcnt_min pcnt_serv pcnt_trade pcnt_tran pcnt_constr inpovtrend logmeantrend if round==43 & tariff!=.;

*********************************************************************************;
*** Table 2. First Stage. Relationship Between Scaled and Unscaled Tariffs ;
*********************************************************************************;

use rural_data, replace;	
	sort st_code43 dist_code43;
	gen trallmtariffinit = trallmtariff if round==43;
	by st_code43 dist_code43 : egen trallmtariff0init = max(trallmtariffinit);
	gen trallmtariffiv = post*trallmtariff0init;
	drop trallmtariff0init trallmtariffinit;

eststo: xi: areg tariff trallmtariff post if (round==43 | round==55) [aw=n], absorb(district) cluster(stateyear);
  estimates store v1;
eststo: xi: areg tariff trallmtariff trallmtariffiv post if (round==43 | round==55) [aw=n], absorb(district) cluster(stateyear);
  estimates store v2;

use urban_data, replace;		
	sort st_code43 regcod50;
	gen trallmtariffinit = trallmtariff if round==43;
	by st_code43 regcod50 : egen trallmtariff0init = max(trallmtariffinit);
	gen trallmtariffiv = post*trallmtariff0init;
	drop trallmtariff0init trallmtariffinit;

eststo: xi: areg tariff trallmtariff post if (round==43 | round==55) [aw=n], absorb(regcod) cluster(stateyear);
  estimates store v3;
eststo: xi: areg tariff trallmtariff trallmtariffiv post if (round==43 | round==55) [aw=n], absorb(regcod) cluster(stateyear);
  estimates store v4;

estout v1 v2 v3 v4
	using Tables.txt, append preh(" " "Table 2. First Stage. Relationship Between Scaled and Unscaled Tariffs")
		keep( trallmtariff trallmtariffiv post ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (r2 N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

*********************************************************************************;
*** Table 3a. Trade Liberalization, Poverty and Average Consumption in Rural India ;
*********************************************************************************;
use rural_data, replace;	
	sort st_code43 dist_code43;
	gen trallmtariffinit = trallmtariff if round==43;
	by st_code43 dist_code43 : egen trallmtariff0init = max(trallmtariffinit);
	gen trallmtariffiv = post*trallmtariff0init;
	drop trallmtariff0init trallmtariffinit;
for X in any inpov logmean : gen X43a = X if round==43 \
			     gen X38a = X if round==38 ;
						      
for X in any inpov logmean : 
		by st_code43 dist_code43 : egen X43 = max(X43a) \ 
		by st_code43 dist_code43 : egen X38 = max(X38a) \ 
					   gen Xtrend = X43-X38 \ drop X43a X38a \ 
			     		   gen Xtrendpost = Xtrend*post;

eststo: xi: areg inpov tariff post if (round==43 | round==55) [aw=n], absorb(district) cluster(stateyear);
		estimates store col1;
eststo: xi: areg inpov trallmtariff post if (round==43 | round==55) [aw=n], absorb(district) cluster(stateyear);
		estimates store col2;
eststo col3aa: xi: ivreg inpov (tariff=trallmtariff) post  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store col3aa;
eststo: xi: ivreg inpov (tariff=trallmtariff) post $cov2  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store col4;

*** place holder for region level regression and pre-only regressions;

eststo: xi: ivreg inpov (tariff  =trallmtariff ) free post $cov2   i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col6;
eststo: xi: ivreg inpov (tariff =trallmtariff ) post $cov2 $cov3   i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col7;
eststo: xi: ivreg inpov (tariff  =trallmtariff  trallmtariffiv) post $cov2 $cov3 i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col8;

/*
estout col1 col2 col3 col4  col6 col7 col8
	using Tables.txt, append preh(" " "Table 3a. Panel A. Poverty Rate")
		keep(tariff trallmtariff free ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
*/

*************************************************************************************
cap estimates drop col1 col2 col3 col4  col6 col7 col8 ;

eststo: xi: areg logmean tariff post if (round==43 | round==55) [aw=n], absorb(district) cluster(stateyear);
		estimates store col1;
eststo: xi: areg logmean trallmtariff post if (round==43 | round==55) [aw=n], absorb(district) cluster(stateyear);
		estimates store col2;
eststo col3ab: xi: ivreg logmean (tariff=trallmtariff) post  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);
*		estimates store col3ab;
eststo col4ab: xi: ivreg logmean (tariff=trallmtariff) post $cov2  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store col4;

*** place holder for region level regression and pre-only regressions;

eststo: xi: ivreg logmean (tariff  =trallmtariff ) free post $cov2   i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col6;
eststo: xi: ivreg logmean (tariff =trallmtariff ) post $cov2 $cov3   i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col7;
eststo: xi: ivreg logmean (tariff  =trallmtariff  trallmtariffiv) post $cov2 $cov3 i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col8;

/*
estout col1 col2 col3 col4  col6 col7 col8
	using Tables.txt, append preh(" " "Table 3a. Panel B. Log Average Per Capita Consumption")
		keep(tariff trallmtariff free ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
*/

*************************************************************************************;

use rural_region_data, replace;	
keep st_code43 regcod50 round tariff  trallmtariff pcnt_lit pcnt_scst pcnt_mfg
	pcnt_farm  pcnt_trade  pcnt_tran  pcnt_min  pcnt_serv logmean inpov
	goodlaw n stateyear;
	gen post=(round==43);
	sort st_code43 regcod50;
for X in any tariff trallmtariff  : gen X0post = X if round==55 \
	gen X0pre = X if round==43 \
	by st_code43 regcod50 : egen Xpost = max(X0post) \
	by st_code43 regcod50 : egen Xpre = max(X0pre) \
	drop X0post X0pre ;
	drop tariff trallmtariff;
for X in any tariff trallmtariff : gen X = Xpre if round==38 \
		replace X = Xpost if round==43 ;
		
for X in any pcnt_lit pcnt_scst pcnt_mfg pcnt_farm  pcnt_trade  pcnt_tran  pcnt_min  pcnt_serv : gen Xpost = X*post;
gen post_law = goodlaw*post;
replace post_law = 0 if post_law==.;


eststo: xi: ivreg inpov (tariff =trallmtariff) post $cov2 i.regcod50 if (round==43 | round==38) [aw=n],  cluster(stateyear);
	estimates store col5;
estout col5 using Tables.txt, append preh(" " "Table 3a. Panel A. Poverty Rate - Column 5 (Falsification)")
		keep(tariff ) 
		title ( "`dep'")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

eststo: xi: ivreg logmean (tariff =trallmtariff) post $cov2 i.regcod50 if (round==43 | round==38) [aw=n],  cluster(stateyear);
	estimates store col5;
estout col5 using Tables.txt, append preh(" " "Table 3a. Panel A. Poverty Rate - Column 5  (Falsification)")
		keep(tariff ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

*********************************************************************************;
*** Table 3b. Trade Liberalization, Poverty and Average Consumption in Urban India ;
*********************************************************************************;
use urban_data, replace;	
	sort st_code43 regcod;
	gen trallmtariffinit = trallmtariff if round==43;
	by st_code43 regcod : egen trallmtariff0init = max(trallmtariffinit);
	gen trallmtariffiv = post*trallmtariff0init;
	drop trallmtariff0init trallmtariffinit;
for X in any inpov logmean : gen X43a = X if round==43 \
			     gen X38a = X if round==38 ;
						      
for X in any inpov logmean : 
		by st_code43 regcod : egen X43 = max(X43a) \ 
		by st_code43 regcod : egen X38 = max(X38a) \ 
					   gen Xtrend = X43-X38 \ drop X43a X38a \ 
			     		   gen Xtrendpost = Xtrend*post;

eststo: xi: areg inpov tariff post if (round==43 | round==55) [aw=n], absorb(regcod) cluster(stateyear);
		estimates store col1;
eststo: xi: areg inpov trallmtariff post if (round==43 | round==55) [aw=n], absorb(regcod) cluster(stateyear);
		estimates store col2;
eststo col3ba: xi: ivreg inpov (tariff=trallmtariff) post  i.regcod if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store col3ba;
eststo: xi: ivreg inpov (tariff=trallmtariff) post $cov2  i.regcod if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store col4;

*** place holder for pre-only regressions;

eststo: xi: ivreg inpov (tariff  =trallmtariff ) free post $cov2 inpovtrendpost  i.regcod  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col6;
eststo: xi: ivreg inpov (tariff =trallmtariff ) post $cov2 $cov3  inpovtrendpost i.regcod  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col7;
eststo: xi: ivreg inpov (tariff  =trallmtariff  trallmtariffiv) post $cov2 $cov3 inpovtrendpost i.regcod  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col8;
	
/*
estout col1 col2 col3 col4  col6 col7 col8  

	using Tables.txt, append preh(" " "Table 3b. Panel A. Poverty Rate. Urban India")
		keep(tariff trallmtariff free ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
*/

******************************************************************************************************;
eststo: xi: areg logmean tariff post if (round==43 | round==55) [aw=n], absorb(regcod) cluster(stateyear);
		estimates store col1;
eststo: xi: areg logmean trallmtariff post if (round==43 | round==55) [aw=n], absorb(regcod) cluster(stateyear);
		estimates store col2;
eststo col3bb: xi: ivreg logmean (tariff=trallmtariff) post  i.regcod if (round==43 | round==55) [aw=n],  cluster(stateyear);
		* estimates store col3bb;
eststo col4bb: xi: ivreg logmean (tariff=trallmtariff) post $cov2  i.regcod if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store col4;

*** place holder for pre-only regressions;

eststo: xi: ivreg logmean (tariff  =trallmtariff ) free post $cov2 logmeantrendpost  i.regcod  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col6;
eststo: xi: ivreg logmean (tariff =trallmtariff ) post $cov2 $cov3  logmeantrendpost i.regcod  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col7;
eststo: xi: ivreg logmean (tariff  =trallmtariff  trallmtariffiv) post $cov2 $cov3 logmeantrendpost i.regcod  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store col8;

/*
estout col1 col2 col3 col4 col6 col7 col8
	using Tables.txt, append preh(" " "Table 3b. Panel B. Log Average Per Capita Consumption. Urban India")
		keep(tariff trallmtariff free ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
*/

*** EDIT by Donna;
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;
estout col3bb using "../../results/table.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;
estout col3aa col3ab col3ba col3bb col4ab col4bb using "../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;
exit;
***;
******************************************************************************************************;
use urban_data, replace;
keep st_code43 regcod50 round tariff  trallmtariff pcnt_lit pcnt_scst pcnt_mfg
	pcnt_farm  pcnt_trade  pcnt_tran  pcnt_min  pcnt_serv logmean inpov
	goodlaw n stateyear;
	gen post=(round==43);
	sort st_code43 regcod50;
for X in any tariff trallmtariff  : gen X0post = X if round==55 \
	gen X0pre = X if round==43 \
	by st_code43 regcod50 : egen Xpost = max(X0post) \
	by st_code43 regcod50 : egen Xpre = max(X0pre) \
	drop X0post X0pre ;
	drop tariff trallmtariff;
for X in any tariff trallmtariff : gen X = Xpre if round==38 \
		replace X = Xpost if round==43 ;
		
for X in any pcnt_lit pcnt_scst pcnt_mfg pcnt_farm  pcnt_trade  pcnt_tran  pcnt_min  pcnt_serv : gen Xpost = X*post;
gen post_law = goodlaw*post;
replace post_law = 0 if post_law==.;


eststo: xi: ivreg inpov (tariff =trallmtariff) post $cov2 i.regcod50 if (round==43 | round==38) [aw=n],  cluster(stateyear);
	estimates store col5;
estout col6 using Tables.txt, append preh(" " "Table 3b. Panel A. Poverty Rate - Column 5 (Falsification)")
		keep(tariff ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

eststo: xi: ivreg logmean (tariff =trallmtariff) post $cov2 i.regcod50 if (round==43 | round==38) [aw=n],  cluster(stateyear);
	estimates store col5;
estout col5 using Tables.txt, append preh(" " "Table 3b. Panel A. Poverty Rate - Column 5  (Falsification)")
		keep(tariff ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

*********************************************************************************;
*** Table 4. Migration Patterns in Rural and Urban India ;
*********************************************************************************;

use migration_data, replace;
sort round sector sex;
log using Tables.txt, append ;
disp "Table 4. Migration Patterns in Rural and Urban India";
bys round sector: sum moved moved2 moved3 movedrur_ movedwork [aw=mult]  ;
bys round sector sex: sum moved moved2 moved3 movedrur_ movedwork [aw=mult]  ;
cap log close;

*********************************************************************************;
*** Table 5. Migration, Population and Tariffs in Rural India ;
*********************************************************************************;
use rural_data, replace;	

*** Panel A;
eststo: xi: ivreg moved_fromoutside (tariff=trallmtariff) post $cov2  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store v1;

eststo: xi: ivreg m_moved_fromoutside (tariff=trallmtariff) post $cov2  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store v2;
*** Panel B;		
eststo: xi: ivreg logtotalpop (tariff=trallmtariff) post $cov2  i.district if  (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store v3;

eststo: xi: ivreg logtotalpopmale (tariff=trallmtariff) post $cov2  i.district if (round==43 | round==55) [aw=n] ,  cluster(stateyear);
		estimates store v4;

estout v1 v2 v3 v4
	using Tables.txt, append preh(" " "Table 5.  Migration, Population and Tariffs in Rural India")
		keep(tariff ) 
		title ( "`dep'")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
		

*********************************************************************************;
*** Table 6. Trade Liberalization and Per Capita Household Consumption Across the Consumption Distribution in Rural India ;
*********************************************************************************;
use rural_data, replace;	

	drop n;
	gen n=.;
	replace n=n43 if round==43;
	replace n=n55 if round==55;

foreach Z in 10 20 40 60 80 90 {;

eststo: xi: ivreg logpce`Z' (tariff=trallmtariff) post $cov2  i.district if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store logpce_ac`Z';
};

estout logpce_ac10 logpce_ac20 logpce_ac40 logpce_ac60 logpce_ac80 logpce_ac90
	using Tables.txt, append 
		keep(tariff) preh(" " "Table 6. Panel A. Trade Liberalization and Per Capita Household Consumption Across the Consumption Distribution in Rural India")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

******************************************************************************************************;
use rural_region_data, replace;	
*** Edited by Ryan Steed;
sort st_code43 regcod;
***;	
	for X in any  inpov logmean : gen X43a = X if round==43 \
							      gen X38a = X if round==38;

	for X in any  inpov logmean: 
			by st_code43 regcod : egen X43 = max(X43a) \ 
			by st_code43 regcod : egen X38 = max(X38a) \ drop X43a X38a \
						   gen Xtrend = X43-X38 \ 
						   gen Xtrendpost = Xtrend*post;
	drop n;
	gen n=.;
	replace n=n43 if round==43;
	replace n=n55 if round==55;

foreach Z in 10 20 40 60 80 90 {;

eststo: xi: ivreg logpce`Z' (tariff=trallmtariff) post $cov2 i.regcod if (round==43 | round==55) [aw=n],  cluster(stateyear);
		estimates store logpce_ac`Z';
};

estout logpce_ac10 logpce_ac20 logpce_ac40 logpce_ac60 logpce_ac80 logpce_ac90
	using Tables.txt, append 
		keep(tariff) preh(" " "Table 6. Panel B. Trade Liberalization and Per Capita Household Consumption Across the Consumption Distribution in Rural India")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

*********************************************************************************;
*** Table 7. Reallocation, Prices and Tariffs ;
*********************************************************************************;

use asi_data, replace;

foreach Z in S S_K logemployment logK logoutput {;

eststo: xi: areg `Z' lagtariff i.yr  [aw=logemployment] , robust absorb(groupnic) cluster(groupnic);
	estimates store `Z';

};

estout S S_K logemployment logK logoutput
	using Tables.txt, append 
		keep(lagtariff) preh(" " "Table 7. Panel A. Reallocation, Prices and Tariffs")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);


**************************************************************************************;
*** Industrial Wages ;

foreach Z in  logrealwagework  {;

eststo: xi: areg `Z' lagtariff i.yr [aw=logemployment] , robust absorb(groupnic) cluster(groupnic);
	estimates store `Z';
};

estout  logrealwagework 
	using Tables.txt, append 
		keep(lagtariff) preh(" " "Table 7. Panel B. Reallocation, Prices and Tariffs - Column (2)")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

**************************************************************************************;
*** Prices - WPI;

use price_data, replace;


eststo: xi: areg logfiscprice lagtariff i.year , absorb(code80) cluster(code80);
	estimates store prices;

estout prices
	using Tables.txt, append 
		keep(lagtariff) preh(" " "Table 7. Panel B. Reallocation, Prices and Tariffs - Columns (1)")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

**************************************************************************************;
*** Industry Wage premia ;

use indpremia_data, replace;

*** wage data for the rural 43rd round is mostly missing, use 38th round wage data instead;
eststo: xi: areg premium tariff i.round if sector==1 & round!=43 [aw=w1] , absorb(pr_group98) cluster(pr_group98);
	estimates store pr_r;
	
eststo: xi: areg premium tariff i.round if sector==2  [aw=w1] , absorb(pr_group98) cluster(pr_group98);
	estimates store pr_u;

estout pr_r pr_u
	using Tables.txt, append 
		keep(tariff) preh(" " "Table 7. Panel B. Reallocation, Prices and Tariffs - Columns (3),(4)")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

**************************************************************************************;
*** Agricultural Wages ;

use agriwage_data, replace; 

eststo: xi: ivreg logrwage (lagtariff=lagtrallmtariff) i.code61 i.year , cluster(code61);
	estimates store logrwage;

estout logrwage
	using Tables.txt, append 
		keep(lagtariff) preh(" " "Table 7. Panel B. Reallocation, Prices and Tariffs - Column (5)")
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);


*********************************************************************************;
*** Table 8. Trade Liberalization, Labor Laws and Poverty in Rural India ;
*********************************************************************************;
use rural_data, replace;	
	sort st_code43 dist_code43;
	gen trallmtariffinit = trallmtariff if round==43;
	by st_code43 dist_code43 : egen trallmtariff0init = max(trallmtariffinit);
	gen trallmtariffiv = post*trallmtariff0init;
	drop trallmtariff0init trallmtariffinit;

for X in any inpov logmean : gen X43a = X if round==43 \
						      gen X38a = X if round==38;
for X in any inpov logmean  : 
		by st_code43 dist_code43 : egen X43 = max(X43a) \ 
		by st_code43 dist_code43 : egen X38 = max(X38a) \ drop X43a X38a \
					   gen Xtrend = X43-X38 \ 
					   gen Xtrendpost = Xtrend*post;

	replace goodlaw=0 if goodlaw==.;

	gen tr_gl = tariff*goodlaw;
	gen trallmt_gl = trallmtariff*goodlaw;
	gen trallmt_gliv = trallmtariffiv*goodlaw;

eststo: xi: ivreg inpov (tariff tr_gl =trallmtariff trallmt_gl ) post $cov2  i.district  if  (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v1;
eststo: xi: ivreg inpov (tariff tr_gl =trallmtariff trallmt_gl ) post $cov2  inpovtrendpost  i.district  if  (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v2;
eststo: xi: ivreg inpov (tariff tr_gl =trallmtariff trallmt_gl ) post $cov2 $cov3 inpovtrendpost  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v3;

eststo: xi: ivreg inpov (tariff tr_gl =trallmtariff  trallmtariffiv trallmt_gl trallmt_gliv) post $cov2  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v4;
eststo: xi: ivreg inpov (tariff tr_gl =trallmtariff  trallmtariffiv trallmt_gl trallmt_gliv) post $cov2 inpovtrendpost  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v5;
eststo: xi: ivreg inpov (tariff tr_gl =trallmtariff  trallmtariffiv trallmt_gl trallmt_gliv) post $cov2 $cov3 inpovtrendpost  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v6;

estout v1 v2 v3 v4 v5 v6
	using Tables.txt, append preh(" " "Table 8. Panel A. Trade Liberalization, Labor Laws and Poverty in Rural India")
		keep(tariff tr_gl ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);

******************************************************************************************************;

eststo: xi: ivreg logmean (tariff tr_gl =trallmtariff trallmt_gl ) post $cov2  i.district  if  (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v1;
eststo: xi: ivreg logmean (tariff tr_gl =trallmtariff trallmt_gl ) post $cov2  logmeantrendpost  i.district  if  (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v2;
eststo: xi: ivreg logmean (tariff tr_gl =trallmtariff trallmt_gl ) post $cov2 $cov3 logmeantrendpost  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v3;

eststo: xi: ivreg logmean (tariff tr_gl =trallmtariff  trallmtariffiv trallmt_gl trallmt_gliv) post $cov2  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v4;
eststo: xi: ivreg logmean (tariff tr_gl =trallmtariff  trallmtariffiv trallmt_gl trallmt_gliv) post $cov2 logmeantrendpost  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v5;
eststo: xi: ivreg logmean (tariff tr_gl =trallmtariff  trallmtariffiv trallmt_gl trallmt_gliv) post $cov2 $cov3 logmeantrendpost  i.district  if (round==43 | round==55) [aw=n], cluster(stateyear);
		estimates store v6;

estout v1 v2 v3 v4 v5 v6
	using Tables.txt, append preh(" " "Table 8. Panel B. Trade Liberalization, Labor Laws and Poverty in Rural India")
		keep(tariff tr_gl ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
		
*********************************************************************************;
*** Appendix Table 1. Sectoral Tariffs and Poverty in Rural and Urban India ;
*********************************************************************************;
		
use rural_region_data, replace;	
for X in any inpov logmean : gen X43a = X if round==43 \
						      gen X38a = X if round==38;
for X in any inpov logmean  : 
		by st_code43 regcod : egen X43 = max(X43a) \ 
		by st_code43 regcod : egen X38 = max(X38a) \ drop X43a X38a \
					   gen Xtrend = X43-X38 \ 
					   gen Xtrendpost = Xtrend*post;

eststo: xi: areg inpov agralltariff  minmfgmtariff $cov2 post   if  (round==43 | round==55) [aw=n],  absorb(regcod50) cluster(stateyear);
		estimates store v1;
eststo: xi: areg inpov agralltariff  minmfgmtariff $cov2 $cov3  post   if (round==43 | round==55) [aw=n],  absorb(regcod50) cluster(stateyear);
		estimates store v2;
eststo: xi: areg inpov agralltariff  minmfgmtariff $cov2 $cov3  inpovtrendpost post   if  (round==43 | round==55) [aw=n],  absorb(regcod50) cluster(stateyear);
		estimates store v3;


use urban_data, replace;	
*** Edited by Ryan Steed;
sort st_code43 regcod;
***;	
for X in any inpov logmean : gen X43a = X if round==43 \
						      gen X38a = X if round==38;
for X in any inpov logmean  : 
		by st_code43 regcod : egen X43 = max(X43a) \ 
		by st_code43 regcod : egen X38 = max(X38a) \ drop X43a X38a \
					   gen Xtrend = X43-X38 \ 
					   gen Xtrendpost = Xtrend*post;

eststo: xi: areg inpov agralltariff  minmfgmtariff $cov2 post   if  (round==43 | round==55) [aw=n],  absorb(regcod50) cluster(stateyear);
		estimates store v4;
eststo: xi: areg inpov agralltariff  minmfgmtariff $cov2 $cov3  post   if  (round==43 | round==55) [aw=n],  absorb(regcod50) cluster(stateyear);
		estimates store v5;
eststo: xi: areg inpov agralltariff  minmfgmtariff $cov2 $cov3  inpovtrendpost post   if  (round==43 | round==55) [aw=n],  absorb(regcod50) cluster(stateyear);
		estimates store v6;

estout v1 v2 v3 v4 v5 v6
	using Tables.txt, append preh(" " "Appendix Table 1. Sectoral Tariffs and Poverty in Rural and Urban India ")
		keep(agralltariff  minmfgmtariff ) 
		cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) 
		stats (N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01);
};	
