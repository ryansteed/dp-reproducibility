
#delimit;
clear;
version 8.0;
capture log close;
set more off;
set mem 60m;
set matsize 400;
set scheme s1mono;


*****************************************************************;
**** This file creates the non-parametric estimation results ****;
**** discussed in Section IV.C of the paper                  ****;
*****************************************************************;

log using regressions/main_results/logs/nonparametric_regressions.log,replace;

use regressions/main_results/data/RemotenessAER_Main.dta;
so city year;

*********************;
*** Drop Saarland ***;
*********************;

drop if laender_2000=="SL";

************************************;
**** Drop re-unification period ****;
************************************;

drop if year>1990;

****************************************;
**** Exclude WW2 difference 1939-50 ****;
****************************************;

gen sample=1;
replace sample=0 if year==1950;

***************************************;
**** Use Annual Growth Rates Rates ****;
***************************************;

sort city year;
quietly by city: gen lagyear=year[_n-1];
quietly by city: gen length=year-lagyear;

quietly by city: gen lagpop=pop[_n-1];
gen g_pop=((pop/lagpop)^(1/length)-1)*100;

gen lpop=ln(pop);
quietly by city: gen laglpop=lpop[_n-1];

*************************************************;
**** Time, Laender and City-Division Dummies ****;
*************************************************;

quietly tab year, gen(yy);
encode laender_2000, gen(land);

encode cities,gen(newcity);
tab newcity,gen(cc);
tab newcity,gen(dcc);

local x = 1;
while `x'<=119 {;
replace dcc`x'=0 if year<=1939;
local x = `x' + 1;
};

*******************************************;
**** Non-parametric Effect of Division ****;
*******************************************;

reg g_pop cc* dcc* if sample==1, noconstant robust;

**** Loop to evaluate fixed effects;

gen fe=.;
gen dfe=.;

local x = 1;

while `x' <=119 {;

di "x is";
di `x' ;
replace fe=_b[cc`x'] if cc`x'==1;
replace dfe=_b[dcc`x'] if cc`x'==1;
local x = `x' + 1;
};

gen np_div=dfe;

egen mean_np_div=mean(np_div);
so city year;

replace np_div=np_div-mean_np_div;

*************************;
**** Label Variables ****;
*************************;

lab var np_div          " ";
lab var dist_gg_border  "Distance to the East-West German border (km)";

so city year;
sa regressions/main_results/temp/nonparametric_regressions.dta,replace;

******************************************************************;
**** Tests for Statistical Significance of the Non-parametric ****; 
**** division treatments reported in a footnote in the paper  ****;
******************************************************************;

clear;
use regressions/main_results/temp/nonparametric_regressions.dta;
so city year;

reg g_pop cc* dcc* if sample==1, noconstant robust;

* Statistical significance of the interactions between the;
* city fixed effects and division;

test dcc1 dcc2 dcc3 dcc4 dcc5 dcc6 dcc7 dcc8 dcc9 dcc10 , notest accumulate;
test dcc11 dcc12 dcc13 dcc14 dcc15 dcc16 dcc17 dcc18 dcc19 dcc20, notest accumulate;
test dcc21 dcc22 dcc23 dcc24 dcc25 dcc26 dcc27 dcc28 dcc29 dcc30, notest accumulate;
test dcc31 dcc32 dcc33 dcc34 dcc35 dcc36 dcc37 dcc38 dcc39 dcc40, notest accumulate;
test dcc41 dcc42 dcc43 dcc44 dcc45 dcc46 dcc47 dcc48 dcc49 dcc50, notest accumulate;
test dcc51 dcc52 dcc53 dcc54 dcc55 dcc56 dcc57 dcc58 dcc59 dcc60, notest accumulate;
test dcc61 dcc62 dcc63 dcc64 dcc65 dcc66 dcc67 dcc68 dcc69 dcc70, notest accumulate;
test dcc71 dcc72 dcc73 dcc74 dcc75 dcc76 dcc77 dcc78 dcc79 dcc80, notest accumulate;
test dcc81 dcc82 dcc83 dcc84 dcc85 dcc86 dcc87 dcc88 dcc89 dcc90, notest accumulate;
test dcc91 dcc92 dcc93 dcc94 dcc95 dcc96 dcc97 dcc98 dcc99 dcc100, notest accumulate;
test dcc101 dcc102 dcc103 dcc104 dcc105 dcc106 dcc107 dcc108 dcc109 dcc110, notest accumulate;
test dcc111 dcc112 dcc113 dcc114 dcc115 dcc116 dcc117 dcc118 dcc119, accumulate;

*************************************************;
**** Which cities are in each distance cell? ****;
*************************************************;

so city year;
quietly by city: gen steve=1 if _n==1;

**** Loop to evaluate;
**** Average fixed effect for all cities;

gen a_fe=0;

local x = 1;

while `x' <=119 {;

di "x is";
di `x' ;
replace a_fe=a_fe+_b[dcc`x'];

local x = `x' + 1;

};

replace a_fe=a_fe/119;
global ave_fe=a_fe;

**** Cities within 75km of the border;

egen noj_75=count(city) if dist_gg_border<75&steve==1;
egen temp=max(noj_75);
so city year;
replace noj_75=temp;
drop temp;

tab newcity if dist_gg_border<75,nol;

local a1 =8; 
local a2 =9;
local a3 =16;
local a4 =19;
local a5 =20;
local a6 =30; 
local a7 =39;
local a8 =44;
local a9 =45;
local a10=48;
local a11=52;
local a12=57;
local a13=58;
local a14=63;
local a15=65;
local a16=73;
local a17=75;
local a18=85;
local a19=101;
local a20=119;

global null75=$ave_fe*noj_75;

test dcc`a1'+dcc`a2'+dcc`a3'+dcc`a4'+dcc`a5'+dcc`a6'+dcc`a7'+dcc`a8'+dcc`a9'+dcc`a10'
+dcc`a11'+dcc`a12'+dcc`a13'+dcc`a14'+dcc`a15'+dcc`a16'+dcc`a17'+dcc`a18'+dcc`a19'+dcc`a20'
=$null75;

gen sum75=(_b[dcc`a1']+_b[dcc`a2']+_b[dcc`a3']+_b[dcc`a4']+_b[dcc`a5']+_b[dcc`a6']+_b[dcc`a7']+_b[dcc`a8']
+_b[dcc`a9']+_b[dcc`a10']+_b[dcc`a11']+_b[dcc`a12']+_b[dcc`a13']+_b[dcc`a14']+_b[dcc`a15']+_b[dcc`a16']
+_b[dcc`a17']+_b[dcc`a18']+_b[dcc`a19']+_b[dcc`a20']);
gen crit75=$ave_fe*noj_75;
su sum75 crit75;

**** Cities within 75-150km of the border;

egen noj_75150=count(city) if dist_gg_border>=75&dist_gg_border<150&steve==1;
egen temp=max(noj_75150);
so city year;
replace noj_75150=temp;
drop temp;

tab newcity if dist_gg_border>=75&dist_gg_border<150,nol;

local a1=2;
local a2=3;
local a3=4;
local a4=11;
local a5=17;
local a6=18;
local a7=21;
local a8=23;
local a9=34;
local a10=36;
local a11=38;
local a12=41;
local a13=46;
local a14=49;
local a15=51;
local a16=55;
local a17=76;
local a18=78;
local a19=79;
local a20=87;
local a21=89;
local a22=92;
local a23=97;
local a24=102;
local a25=103;
local a26=115;

global null75150=$ave_fe*noj_75150;

test dcc`a1'+dcc`a2'+dcc`a3'+dcc`a4'+dcc`a5'+dcc`a6'+dcc`a7'+dcc`a8'+dcc`a9'+dcc`a10'
+dcc`a11'+dcc`a12'+dcc`a13'+dcc`a14'+dcc`a15'+dcc`a16'+dcc`a17'+dcc`a18'+dcc`a19'+dcc`a20'
+dcc`a21'+dcc`a22'+dcc`a23'+dcc`a24'+dcc`a25'+dcc`a26'=$null75150;

gen sum75150=(_b[dcc`a1']+_b[dcc`a2']+_b[dcc`a3']+_b[dcc`a4']+_b[dcc`a5']+_b[dcc`a6']+_b[dcc`a7']+_b[dcc`a8']
+_b[dcc`a9']+_b[dcc`a10']+_b[dcc`a11']+_b[dcc`a12']+_b[dcc`a13']+_b[dcc`a14']+_b[dcc`a15']+_b[dcc`a16']
+_b[dcc`a17']+_b[dcc`a18']+_b[dcc`a19']+_b[dcc`a20']+_b[dcc`a21']+_b[dcc`a22']+_b[dcc`a23']+_b[dcc`a24']
+_b[dcc`a25']+_b[dcc`a26']);
gen crit75150=$ave_fe*noj_75150;
su sum75150 crit75150;
global null_75_75150=sum75150*(noj_75/noj_75150);

**** Cities within 150-225km of the border;

egen noj_150225=count(city) if dist_gg_border>=150&dist_gg_border<225&steve==1;
egen temp=max(noj_150225);
so city year;
replace noj_150225=temp;
drop temp;

tab newcity if dist_gg_border>=150&dist_gg_border<225,nol;

local a1=5;
local a2=6;
local a3=10;
local a4=13;
local a5=14;
local a6=15;
local a7=22;
local a8=25;
local a9=27;
local a10=28;
local a11=32;
local a12=33;
local a13=35;
local a14=40;
local a15=42;
local a16=43;
local a17=47;
local a18=50;
local a19=53;
local a20=54;
local a21=56;
local a22=59;
local a23=60;
local a24=61;
local a25=62;
local a26=66;
local a27=67;
local a28=70;
local a29=71;
local a30=72;
local a31=74;
local a32=77;
local a33=82;
local a34=84;
local a35=88;
local a36=90;
local a37=91;
local a38=93;
local a39=94;
local a40=96;
local a41=98;
local a42=99;
local a43=100;
local a44=104;
local a45=105;
local a46=106;
local a47=107;
local a48=109;
local a49=110;
local a50=111;
local a51=116;
local a52=117;
local a53=118;

global null150225=$ave_fe*noj_150225;

test dcc`a1'+dcc`a2'+dcc`a3'+dcc`a4'+dcc`a5'+dcc`a6'+dcc`a7'+dcc`a8'+dcc`a9'+dcc`a10'
+dcc`a11'+dcc`a12'+dcc`a13'+dcc`a14'+dcc`a15'+dcc`a16'+dcc`a17'+dcc`a18'+dcc`a19'+dcc`a20'
+dcc`a21'+dcc`a22'+dcc`a23'+dcc`a24'+dcc`a25'+dcc`a26'+dcc`a27'+dcc`a28'+dcc`a29'+dcc`a30'
+dcc`a31'+dcc`a32'+dcc`a33'+dcc`a34'+dcc`a35'+dcc`a36'+dcc`a37'+dcc`a38'+dcc`a39'+dcc`a40'
+dcc`a41'+dcc`a42'+dcc`a43'+dcc`a44'+dcc`a45'+dcc`a46'+dcc`a47'+dcc`a48'+dcc`a49'+dcc`a40'
+dcc`a51'+dcc`a52'+dcc`a53'=$null150225;

gen sum150225=(_b[dcc`a1']+_b[dcc`a2']+_b[dcc`a3']+_b[dcc`a4']+_b[dcc`a5']+_b[dcc`a6']+_b[dcc`a7']+_b[dcc`a8']
+_b[dcc`a9']+_b[dcc`a10']+_b[dcc`a11']+_b[dcc`a12']+_b[dcc`a13']+_b[dcc`a14']+_b[dcc`a15']+_b[dcc`a16']
+_b[dcc`a17']+_b[dcc`a18']+_b[dcc`a19']+_b[dcc`a20']+_b[dcc`a21']+_b[dcc`a22']+_b[dcc`a23']+_b[dcc`a24']
+_b[dcc`a25']+_b[dcc`a26']+_b[dcc`a27']+_b[dcc`a28']+_b[dcc`a29']+_b[dcc`a30']+_b[dcc`a31']+_b[dcc`a32']
+_b[dcc`a33']+_b[dcc`a34']+_b[dcc`a35']+_b[dcc`a36']+_b[dcc`a37']+_b[dcc`a38']+_b[dcc`a39']+_b[dcc`a40']
+_b[dcc`a41']+_b[dcc`a42']+_b[dcc`a43']+_b[dcc`a44']+_b[dcc`a45']+_b[dcc`a46']+_b[dcc`a47']+_b[dcc`a48']
+_b[dcc`a49']+_b[dcc`a40']+_b[dcc`a51']+_b[dcc`a52']+_b[dcc`a53']);
gen crit150225=$ave_fe*noj_150225;
su sum150225 crit150225;
global null_75_150225=sum150225*(noj_75/noj_150225);

**** Cities above 225km from the border;

egen noj_225=count(city) if dist_gg_border>=225&steve==1;
egen temp=max(noj_225);
so city year;
replace noj_225=temp;
drop temp;

tab newcity if dist_gg_border>=225,nol;

local a1 =1  ;
local a2 =7  ;
local a3 =12 ;
local a4 =24 ;
local a5 =26 ;
local a6 =29 ;
local a7 =31 ;
local a8 =37 ;
local a9 =64 ;
local a10=68 ;
local a11=69 ;
local a12=80 ;
local a13=81 ;
local a14=83 ;
local a15=86 ;
local a16=95 ;
local a17=108;
local a18=112;
local a19=113;
local a20=114;

global null225=$ave_fe*noj_225;

test dcc`a1'+dcc`a2'+dcc`a3'+dcc`a4'+dcc`a5'+dcc`a6'+dcc`a7'+dcc`a8'+dcc`a9'+dcc`a10'
+dcc`a11'+dcc`a12'+dcc`a13'+dcc`a14'+dcc`a15'+dcc`a16'+dcc`a17'+dcc`a18'+dcc`a19'+dcc`a20'
=$null225;

gen sum225=(_b[dcc`a1']+_b[dcc`a2']+_b[dcc`a3']+_b[dcc`a4']+_b[dcc`a5']+_b[dcc`a6']+_b[dcc`a7']+_b[dcc`a8']
+_b[dcc`a9']+_b[dcc`a10']+_b[dcc`a11']+_b[dcc`a12']+_b[dcc`a13']+_b[dcc`a14']+_b[dcc`a15']+_b[dcc`a16']
+_b[dcc`a17']+_b[dcc`a18']+_b[dcc`a19']+_b[dcc`a20']);
gen crit225=$ave_fe*noj_225;
su sum225 crit225;
global null_75_225=sum225*(noj_75/noj_225);

*** Bilateral tests of 0-75 against 75-150 and 150-225;

local a1 =8; 
local a2 =9;
local a3 =16;
local a4 =19;
local a5 =20;
local a6 =30; 
local a7 =39;
local a8 =44;
local a9 =45;
local a10=48;
local a11=52;
local a12=57;
local a13=58;
local a14=63;
local a15=65;
local a16=73;
local a17=75;
local a18=85;
local a19=101;
local a20=119;

test dcc`a1'+dcc`a2'+dcc`a3'+dcc`a4'+dcc`a5'+dcc`a6'+dcc`a7'+dcc`a8'+dcc`a9'+dcc`a10'
+dcc`a11'+dcc`a12'+dcc`a13'+dcc`a14'+dcc`a15'+dcc`a16'+dcc`a17'+dcc`a18'+dcc`a19'+dcc`a20'
=$null_75_75150;

test dcc`a1'+dcc`a2'+dcc`a3'+dcc`a4'+dcc`a5'+dcc`a6'+dcc`a7'+dcc`a8'+dcc`a9'+dcc`a10'
+dcc`a11'+dcc`a12'+dcc`a13'+dcc`a14'+dcc`a15'+dcc`a16'+dcc`a17'+dcc`a18'+dcc`a19'+dcc`a20'
=$null_75_150225;

test dcc`a1'+dcc`a2'+dcc`a3'+dcc`a4'+dcc`a5'+dcc`a6'+dcc`a7'+dcc`a8'+dcc`a9'+dcc`a10'
+dcc`a11'+dcc`a12'+dcc`a13'+dcc`a14'+dcc`a15'+dcc`a16'+dcc`a17'+dcc`a18'+dcc`a19'+dcc`a20'
=$null_75_225;

log close;

