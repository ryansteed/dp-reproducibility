
#delimit ;    
clear;
clear mata;
capture log close;
clear matrix;
set mem 500m;
set more off;
set matsize 800;
set maxvar 3000;

/**************************************************************************/
/* Define local paths                                                     */
/**************************************************************************/

local path ".";


/**************************************************************************/
/* Define log file                                                        */
/**************************************************************************/

global date 6-24-14;

log using `path'\Program4_AEJRegs_$date, replace t;


/*********************************************/
/*Open AEJ Regression Data.  This data combines 1997-2003 AHS Data and Merges with Federal Register and Census Data. 
  Only variables used in the final regressions are retained in the final regression data. Sample restricted
  to rental housing units in AHS with non-missing housing rent in 1997 and at least 1 other period in 1999, 2001, or 2003 */
/*********************************************/

use AEJEP_Regression_Data_6-24-14, clear;


/*********************************************/
/*********************************************/
/*Specify Regression Varibles*/
/*********************************************/
/*********************************************/

global depvar   lrent_ut;                          /*log of reported cash rent plus utilities from AHS*/

global vouchers lvouch;                            /*Log of Housing Vouchers at the MSA Level from the Federal Register*/

global cntrls   linc   ltotpop lvacancy              
                evrod  drywash cracks   ifsew;  /*Log of MSA annual income, population, and vacancy rates from Census Log of Unit-specific Attributes from AHS*/



/*********************************************/
/*Table 3. Summary Stats*/
/*********************************************/


local sumvars  rent_ut rent_ut2fmr bedrms baths evrod    drywash    cracks ifsew vouch vacancy_r totpop inc fmr;


/*Calculate Variation Net of Fixed Effects*/
foreach var of local sumvars {;
xi: xtreg `var' i.year, fe i(control);
predict `var'_yhat if e(sample), xbu;
gen `var'_resid = `var' - `var'_yhat;
};


sum  `sumvars' northeast south midwest west ;
sum *_resid ;



/********************************************************************************************/
/********************************************************************************************/
/*Table 4: Impact of Vouchers on 1997-2003 AHS Rent Levels with Fixed Effects. The variable "fmrratio" is the 
  unit-specific housing rent in 1997 divided by the MSA-Specific Fair Market Rent.  */
/********************************************************************************************/
/********************************************************************************************/

eststo: xi: xtreg $depvar $vouchers $cntrls  i.year 
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\FixedEffect_RegionxYear_97-03_$date.txt, replace bdec(3) ;
   
eststo: xi: xtreg $depvar $vouchers $cntrls  i.year 
    if fmrratio < 1.2 
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\FixedEffect_RegionxYear_97-03_$date.txt, append bdec(3) ;
 
eststo: xi: xtreg $depvar $vouchers $cntrls  i.year 
    if fmrratio >= 1.2 
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\FixedEffect_RegionxYear_97-03_$date.txt, append bdec(3) ;

/* EDITED by Donna */
estout using "../../results/table4.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;

/********************************************************************************************/
/********************************************************************************************/
/*Table 5: Hetero Effects by LFMR. the variable "lfmrratio" is the natural log of fmrratio. */
/********************************************************************************************/
/********************************************************************************************/

eststo clear;

gen fmrratio_low  = fmrratio <  .8;
gen fmrratio_mid  = fmrratio >= .8 & fmrratio < 1.2;
gen fmrratio_high = fmrratio >= 1.2;

gen INT_fmrlow = lvouch  * fmrratio_low;
gen INT_fmrmid = lvouch * fmrratio_mid;

gen fmrratio_bins     = fmrratio_low;
replace fmrratio_bins = 2 if fmrratio_mid == 1;


eststo: xi: xtreg $depvar $vouchers $cntrls  i.year*lfmrratio 
    if fmrratio < .8  
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\FixedEffect_LFMR_RegionxYear_97-03_$date.txt, replace bdec(3) ;

eststo: xi: xtreg $depvar $vouchers $cntrls  i.year*lfmrratio 
    if fmrratio >= .8 & fmrratio < 1.2 
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\FixedEffect_LFMR_RegionxYear_97-03_$date.txt, append bdec(3) ;

eststo: xi: xtreg $depvar $vouchers INT_fmrlow $cntrls  i.year*i.fmrratio_bins 
    if fmrratio < 1.2 
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\FixedEffect_LFMR_RegionxYear_97-03_$date.txt, append bdec(3) ;

lincom lvouch + INT_fmrlow;

/* EDITED by Donna */
estout using "../../results/table5.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;

/********************************************************************************************/
/*Figure 4: Interact 5th Order Polynomial of FMR Ratio interacted with Voucher Supply. Selected
  5th Order Poly Because Lowest AIC*/
/********************************************************************************************/

local cluster smsa;

local poly5 c.lvouch#c.lfmrratio 
           c.lvouch#c.lfmrratio#c.lfmrratio 
           c.lvouch#c.lfmrratio#c.lfmrratio#c.lfmrratio  
           c.lvouch#c.lfmrratio#c.lfmrratio#c.lfmrratio#c.lfmrratio 
           c.lvouch#c.lfmrratio#c.lfmrratio#c.lfmrratio#c.lfmrratio#c.lfmrratio  ;


xi: xtreg $depvar $vouchers  `poly5' $cntrls  i.year*lfmrratio  if fmrratio > .2 & fmrratio < 1.7, 
    fe i(control) cluster(`cluster') nonest;
    estat ic;
     margins,  dydx(lvouch) at(lfmrratio = (-.7(.01).4)) vsquish noestimcheck level(90) ;
     marginsplot, xlabel(-.7(.01).4) saving(poly5, replace);
    outreg2 `vouchers' `cntrls' using `path'\Results\Figure_LFMR_$date.txt, append bdec(8) ;


/********************************************************************************************/
/********************************************************************************************/
/*Table 6:  Check for Pre-Existing (1997-1999) Trends. The variable "lvouch03" is the natural log
  number of vouchers in 1997, with the natural log of vouchers in 1999 replaced with the natural
  log of vouchers at the end of 2003. */
/********************************************************************************************/
/********************************************************************************************/

/*Create Flag for To Create Balanced Panel for 1997-1999 Specification Pre-Test*/

sort control;
reg $depvar lvouch03 $cntrls if year == 1997 | year == 1999 & fmrratio ~= .;
gen flag = e(sample);
by control: egen flag_spectest = sum(flag) if year == 1997 | year == 1999;


xi: xtreg $depvar lvouch03 $cntrls  i.year*lfmr 
    if fmrratio < 1.2 & flag_spectest == 2
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\SpecTest_RegionxYear_97-99_$date.txt, replace bdec(3) ;

xi: xtreg $depvar lvouch03 $cntrls   i.year*lfmr 
   if fmrratio < .8 & flag_spectest == 2
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\SpecTest_RegionxYear_97-99_$date.txt, append bdec(3) ;
   
xi: xtreg $depvar lvouch03 $cntrls   i.year*lfmr 
    if fmrratio >= .8 & fmrratio < 1.2 & flag_spectest == 2
   , fe i(control) cluster(smsa) nonest;
   outreg2 `vouchers' `cntrls' using `path'\Results\SpecTest_RegionxYear_97-99_$date.txt, append bdec(3) ;


/********************************************************************************************/
/*Table 7 and 7b: Hetero Results by Housing Supply Elasticity. The variable "saiz" is housing 
  supply elasticity as estimated by Saiz (2011)*/
/********************************************************************************************/

eststo clear;

gen lsaiz = log(saiz);

gen saiz_g1 = saiz >= 1 & saiz ~= .;
gen saiz_l1 = saiz  < 1 & saiz ~= .;

gen INT_saizg1 = $vouchers * saiz_g1 if saiz ~= .;
gen INT_saizl1 = $vouchers * saiz_l1 if saiz ~= .;


gen INT_saizl1_fmrlow = INT_fmrlow*INT_saizl1;
gen INT_saizl1_fmrmid = INT_fmrmid*INT_saizl1;
gen INT_saizg1_fmrlow = INT_fmrlow*INT_saizg1;
gen INT_saizg1_fmrmid = INT_fmrmid*INT_saizg1;

local cluster smsa;


eststo: xi: xtreg $depvar $vouchers  $cntrls  i.year*lsaiz 
    if  saiz ~= . & fmrratio < 1.2 
   , fe i(control) cluster(smsa) nonest;
   outreg2  using `path'\Results\FixedEffect_Saiz_$date.txt, replace bdec(3) ;

eststo: xi: xtreg $depvar $vouchers INT_saizg1 $cntrls i.year*lsaiz 
    if  saiz ~= . & fmrratio < 1.2 
   , fe i(control) cluster(smsa) nonest;
   outreg2  using `path'\Results\FixedEffect_Saiz_$date.txt, append bdec(3) ;

lincom lvouch + INT_saizg1;

eststo: xi: xtreg $depvar $vouchers INT_saizg1 INT_fmrlow INT_saizg1_fmrlow $cntrls i.year*lsaiz i.year*fmrratio_bins 
    if  saiz ~= . & fmrratio < 1.2
   , fe i(control) cluster(smsa) nonest;
   outreg2  using `path'\Results\FixedEffect_Saiz_$date.txt, append bdec(3) ;

/* EDITED by Donna */
estout using "../../results/table7.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;
/********************************************************************************************/
/*Table 8: Summary of Saiz x Voucher Supply Effects*/
/********************************************************************************************/

lincom lvouch + INT_saizg1 + INT_fmrlow + INT_saizg1_fmrlow ;
lincom lvouch + INT_saizg1 ;
lincom lvouch + INT_fmrlow ;
lincom lvouch  ;


/********************************************************************************************/
/* Figure 5: Create Figure of Voucher Elasticity by MSA Supply Elasticity.   */
/********************************************************************************************/

local cluster smsa;

local poly5_lsaiz c.lvouch#c.lsaiz 
                 c.lvouch#c.lsaiz#c.lsaiz 
                 c.lvouch#c.lsaiz#c.lsaiz#c.lsaiz  
                 c.lvouch#c.lsaiz#c.lsaiz#c.lsaiz#c.lsaiz 
                 c.lvouch#c.lsaiz#c.lsaiz#c.lsaiz#c.lsaiz#c.lsaiz ; 


xi: xtreg $depvar $vouchers `poly5_lsaiz' $cntrls  i.year*lsaiz  
    , fe i(control) cluster(`cluster') nonest;
   estat ic;
   margins,  dydx(lvouch) at(lsaiz = (-.6(.01).9)) vsquish noestimcheck level(90);
   outreg2  using `path'\Results\Figure_Saiz_$date.txt, append bdec(3) ;



/********************************************************************************************/
/* Table 1. MSA Level Increase in Housing Vouchers   */
/********************************************************************************************/

save `path'\Temp\temp.dta, replace;

sort control year;
by control: gen tot = _N;
keep if tot == 4;


sort smsa year;
by smsa year: gen order = _n;
by smsa:      gen msaobs = _N;



gen lvouchers97 = log(vouchers97);


keep if year == 2003;
keep if order == 1;
order smsa  smsa_nm vouchers97 fair wtw00 newvouchperr;


gsort - newvouchperr;

list smsa  smsa_nm vouchers97 fair wtw00 newvouchperr;


/********************************************************************************************/
/* Table 2. MSA Level Regressions of Voucher Allocation Determinants.  ltotrent is the log of
   occupied rental housing units from the 2000 Decennial Census, lpov99 is the log of the MSA Poverty
   Rate in 1999, lv_elig is the log of the estimated total number of households eligible for a 
   housing vouchers as estimated by HUD's CHAS Database.    */
/********************************************************************************************/


use `path'\Temp\temp.dta, clear;


sort control year;
by control: gen tot = _N;
keep if tot == 4;


sort control year; 
by control: gen vouch03 = vouch[_n+2] if year == 1999;
gen lvouchers97   = log(vouchers97);

keep if year == 1999;


/* Only Keep 1 observation for each MSA & Year for Table*/

capture drop num;
sort smsa year;
by smsa: gen num = _n;
keep if num == 1;



/*Percent Increase in Voucher between 1999 and 2003*/
gen pvouch03 = (vouch03 - vouch) / vouch;


reg lvouch   ltotpop ltotrent linc lfmr lvac lpov99 lv_elig    northeast  west south  if year == 1999, robust;
 outreg2 using `path'\Results\DetAllocation_Vouchers.txt, replace bdec(3) ;

reg pvouch03  ltotpop ltotrent linc lfmr lvac  lpov99 lv_elig  northeast  west south  if year == 1999, robust;
 outreg2 using `path'\Results\DetAllocation_Vouchers.txt, append bdec(3) ;


log close;
