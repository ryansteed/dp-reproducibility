
#delimit;
clear;
capture log close;
log using regressions/main_results/logs/Bordergraphs.log,replace;
set mem 100m;
set matsize 400;
set more off;
version 8.0;
set scheme s1mono;
graph set print logo off;

*******************************************************************************
**** This file creates the border and non-border graphs in Figures 3 and 4 ****
**** of the paper                                                          ****
*******************************************************************************

** Define local variables;

local tocol "collapse (sum) pop ,by(year)";
local lkm=75;
local ukm=75;

** Create total population in West German non-border cities > 75km from the E-W German border;
** by collapsing the city-level data;

clear;
u regressions/main_results/data/RemotenessAER_Main.dta;
keep if year==1919|year==1925|year==1933|year==1939|year==1950|year==1960|year==1970
|year==1980|year==1988|year==1992|year==2002;
so city year;
keep if dist_gg_border>`ukm';
`tocol';
so year;
ren pop popnb;
sa regressions/main_results/temp/nonbord.dta,replace;

** Create total population in West German border cities < 75 km from the E-W German border;
** by collapsing the city-level data;

clear;
u regressions/main_results/data/RemotenessAER_Main.dta;
keep if year==1919|year==1925|year==1933|year==1939|year==1950|year==1960|year==1970
|year==1980|year==1988|year==1992|year==2002;
so city year;
keep if dist_gg_border<=`lkm';
`tocol';
so year;
ren pop popb;

** Merge the total population datasets for the border and non-border areas;

merge year using regressions/main_results/temp/nonbord.dta;
tab _m;
drop _m;
so year;

** Transform variables;

replace popnb=float(popnb);
replace popb =float(popb);

gen lpopnb=ln(popnb);
gen lpopb =ln(popb);

gen temp=popnb if year==1919;
egen popnb_1919=max(temp);
so year;
drop temp;

gen temp=popb if year==1919;
egen popb_1919=max(temp);
so year;
drop temp;

** Create indices of border and non-border population;

gen index_nb =popnb/popnb_1919;
gen index_b  =popb/popb_1919;
gen d_index  =index_b-index_nb;

lab var index_nb  " ";
lab var index_b   " ";
lab var year;

lab var d_index   " ";

lab var year "Year";

format d_index %8.1f;

gen totpop=popb+popnb;
gen popshareb=popb/totpop;
gen popsharenb=popnb/totpop;

** Graph the population indices;

scatter index_b index_nb year , c(l l) xlabel(1920 1930 1940 1950 1960 1970 1980 1990 2000) 
ylabel(#5) xline(1949 1990) msymbol(i i)
l1title("Index (1919=1)", margin(medium))
legend(label(1 Treatment Group) label(2 Control Group)) 
title("Figure 3: Indices of Treatment & Control City Population", margin(medium))
saving(regressions/main_results/graphs/Figure3,replace);

graph export regressions/main_results/graphs/Figure3.eps , replace as(eps);

scatter d_index year , c(l) xlabel(1920 1930 1940 1950 1960 1970 1980 1990 2000) 
ylabel(#5) xline(1949 1990) msymbol(i)
l1title("Treatment Group - Control Group", margin(medium))
title("Figure 4: Difference in Population Indices, Treatment - Control", margin(medium))
saving(regressions/main_results/graphs/Figure4,replace);

graph export regressions/main_results/graphs/Figure4.eps , replace as(eps);

** List the population indices;

format popb popnb totpop d_index %14.2fc;
list year popb popnb totpop d_index;

log close;



