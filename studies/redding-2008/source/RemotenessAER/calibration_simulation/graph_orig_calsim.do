
#delimit ;
clear;
capture log close;
set mem 200m;
set matsize 400;
set more off;

**********************************************************************;
**** This file generates Figures 1 and 2 in the paper summarising ****;
**** the results of the calibration and simulation of the model   ****;
**** discussed in Section II.C of the paper                       ****;
**********************************************************************;

***************************************************;
* Read in and save in Stata format the city names *;
***************************************************;

insheet using calibration_simulation/data/MatlabLegend.csv;
ren v1 cities;
ren v2 city;
so city;
sa calibration_simulation/data/matlablegend.dta,replace;

******************************************************************;
* Read in and save in Stata format data from the calibration and *;
* simulation of the model created by the Matlab programs         *;
* Calibrate_original.m and Simulate_original.m                   *;
******************************************************************;

* The columns of data are as follows;

* Column 1 : population in 1939 : pop39;
* Column 2 : n_lat_deg; 
* Column 3 : e_long_deg; 
* Column 4 : brd; 
* Column 5 : city; 
* Column 6 : dist_gg_border; 
* Column 7 : population in 1970 : pop70; 
* Column 8 : population in 1960 : pop60; 
* Column 9 : population in 1980 : pop80; 
* Column 10 : population in 1988 : pop88; 
* Column 11 : non-parametric estimates of the division treatment (mean == zero) : np_div; 
* Column 12 : inf_div=(100+np_div)/100; 
* Column 13 : divpop=((pop39*(inf_div^38))-pop39)/pop39; 
* Column 14 : population in 1950 : pop50;
* Column 15 : population in 1919 : pop19;
* Column 16 : number of varieties in each city in the calibration : n_c;
* Column 17 : variety price in each city in the calibration : p_c;
* Column 18 : price index for tradeable varieties in each city in the calibration : PM_c;
* Column 19 : nominal wage in each city in the calibration : w_c;
* Column 20 : aggregate expenditure in each city in the calibration : E_c;
* Column 21 : price of the non-traded amenity in each city in the calibration : PH_c;
* Column 22 : real wage in each city in the calibration : om_c;
* Column 23 : stock of the non-traded amenity in each city in the calibration : H_c;
* Column 24 : simulated steady-state population of each city following division : L_s;
* Column 25 : simulated number of varieties in each city following division : n_s;
* Column 26 : simulated variety price in each city following division : p_s;
* Column 27 : simulated price index for tradeable varieties in each city following division : PM_s;
* Column 28 : simulated nominal wage in each city following division : w_s;
* Column 29 : simulated aggregate expenditure in each city following division : E_s;
* Column 30 : simulated price of the non-traded amenity in each city following division : PH_s;
* Column 31 : simulated real wage in each city following division : om_s;
* Column 32 : stock of the non-traded amenity in each city from the calibration : H_s == H_c;

clear;
insheet 
pop39 nlatdeg elongdeg brd city distggborder 
pop70 pop60 pop80 pop88 np_div inf_div divpop pop50 pop19
n_c p_c PM_c w_c E_c PH_c om_c H_c 
L_s n_s p_s PM_s w_s E_s PH_s om_s H_s using calibration_simulation/data/OrigSimData.csv;
order city;
so city;
sa calibration_simulation/data/StataOrigData.dta,replace;

********************************;
**** Now use the Stata data ****;
********************************;

clear;
use calibration_simulation/data/StataOrigData.dta;
so city;
merge city using calibration_simulation/data/matlablegend.dta, unique;
tab _m;
* Merge==3 corresponds to West German cities;
keep if _m==3;
drop _m;
so city;

*********************************************************************;
**** Define distance grid cells from the East-West German border ****;
*********************************************************************;

gen cell=1 if distggborder<25;
replace cell=2 if distggborder>=25&distggborder<50;
replace cell=3 if distggborder>=50&distggborder<75;
replace cell=4 if distggborder>=75&distggborder<100;
replace cell=5 if distggborder>=100&distggborder<150;
replace cell=6 if distggborder>=150&distggborder<200;
replace cell=7 if distggborder>=200;

lab def cell 1 "<25" 2 "25-50" 3 "50-75" 4 "75-100" 5 "100-150" 6 "150-200" 7 ">200";
lab val cell cell;

* Median 1919 population in the future West Germany is 44150 (including the three; 
* Saarland cities not present in these Matlab calibration and simulation data);
gen med_pop1919=44150;
so city;

gen scell=1 if pop19<med_pop19;
replace scell=2 if pop19>=med_pop19;

lab def scell 1 "Pop < 1919 median" 2 "Pop >= 1919 median";
lab val scell scell;

*****************************;
**** Transform variables ****;
*****************************;

egen m_pop39=mean(pop39);

gen d_pop=(l_s-pop39)/pop39;
replace d_pop=d_pop*100;

egen mn_d_pop=mean(d_pop);
so city;

egen temp=mean(d_pop) if pop19<med_pop19;
egen mns_d_pop=max(temp);
so city;
drop temp;

egen temp=mean(d_pop) if pop19>=med_pop19;
egen mnl_d_pop=max(temp);
so city;
drop temp;

gen n_d_pop=d_pop-mn_d_pop;
gen nn_d_pop=d_pop-mns_d_pop if pop19<med_pop19;
replace nn_d_pop=d_pop-mnl_d_pop if pop19>=med_pop19;

********************;
**** Graph data ****;
********************;

lab var d_pop "% Change Pop";
lab var distggborder "Distance to E-W Border (km)";

set scheme s1mono;
graph set print logo off;

graph bar (mean) n_d_pop , over(cell)
ytitle("Mean Simulated Change (%)", margin(medium))
title("Figure 1: Simulated Change in West German City Population")
subtitle("By distance in km from the East-West Border", margin(bottom))
saving(calibration_simulation/graphs/Figure1,replace);

graph export calibration_simulation/graphs/Figure1.eps , replace as(eps);

graph bar (mean) nn_d_pop if distggborder<=75, over(scell)
ytitle("Mean Simulated Difference (%)", margin(medium))
title("Figure 2: Differences in Simulated Population Changes")
subtitle("within and beyond 75km of E-W border for small and large West German cities",margin(bottom))
saving(calibration_simulation/graphs/Figure2,replace);

graph export calibration_simulation/graphs/Figure2.eps , replace as(eps);

