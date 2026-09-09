
#delimit;
clear;
set mem 400m;
set matsize 1200;
version 8.0;

**************************************************************************;
**** This file creates Table 3 and Figure 5 in the paper              ****; 
**** Data are read in from Output.csv which is created by             ****;
**** the Matlab program grid_search.m that undertakes the grid search ****;
**** across alternative parameter configurations                      ****;
**************************************************************************;

* Check simulation and calibration in Matlab converged to equilibrium;
* for all parameter configurations;
insheet calconverge simconverge using grid_search/data/ConvTest.csv;
tab calconverge;
tab simconverge;

******************************************;
**** Read in the data from Output.csv ****;
******************************************;

* Output.csv contains the simulated moments from;
* the calibration and simulation of the model; 
* for small and large cities for the 51,152 parameter configurations for; 
* which the model has a unique equilibrium;

* Output.csv has the following columns;

* Column 1 : elasticity of substitution : sigma;
* Column 2 : share of tradeables in expenditure : mu;
* Column 3 : elasticity of transport costs with respect to distance : eta;
* Column 4 : coefficient on distance : delta;
* Column 5 : dummy that equals one if every border city experiences a decline in its steady-state population in the simulation : sgn;
* Column 6 : mean decline in population growth across all border cities following division in the non-parametric estimates : npd_0_75;
* Column 7 : mean decline in population growth across all non-border cities following division in the non-parametric estimates : npd_75;
* Column 8 : mean decline in population growth across all border cities following division in the simulation : mod_0_75;
* Column 9 : mean decline in population growth across all non-border cities following division in the non-parametric estimates : mod_75;
* Column 10 : mean decline in population growth across small border cities following division in the non-parametric estimates : smnpd_0_75;
* Column 11 : mean decline in population growth across small non-border cities following division in the non-parametric estimates : smnpd_75;
* Column 12 : mean decline in population growth across small border cities following division in the simulation : smmod_0_75;
* Column 13 : mean decline in population growth across small non-border cities following division in the simulation : smmod_75;
* Column 14 : mean decline in population growth across large border cities following division in the non-parametric estimates : lanpd_0_75;
* Column 15 : mean decline in population growth across large non-border cities following division in the non-parametric estimates : lanpd_75;
* Column 16 : mean decline in population growth across large border cities following division in the simulation : lamod_0_75;
* Column 17 : mean decline in population growth across large non-border cities following division in the simulation : lamod_75;
* Column 18 : simulation order (from 1 to 51,152);

clear;
local paramlist = "sigma mu eta delta sgn npd_0_75 npd_75 mod_0_75 mod_75 
smnpd_0_75 smnpd_75 smmod_0_75 smmod_75 
lanpd_0_75 lanpd_75 lamod_0_75 lamod_75 simorder";
insheet `paramlist' using grid_search/data/output.csv;
so sigma mu eta;

* Parameters;

gen reta=eta*100;
replace reta=round(reta);
gen rmu=mu*100;
replace rmu=round(rmu);
gen rsigma=sigma*10;
replace rsigma=round(rsigma);

gen distance=(1-sigma)*eta;
gen stability=(1-mu)*sigma;

* Generate non-parametric and simulated division treatments;

gen nptreat=npd_0_75-npd_75;
su nptreat;

gen smtreat=mod_0_75-mod_75;
su smtreat;

* Generate non-parametric division treatments for small and large cities;

gen snptreat=smnpd_0_75-smnpd_75;
gen lnptreat=lanpd_0_75-lanpd_75;
su snptreat lnptreat;

* Generate simulated division treatments for small and large cities;

gen ssmtreat=smmod_0_75-smmod_75;
gen lsmtreat=lamod_0_75-lamod_75 ;
su ssmtreat lsmtreat;

********************************************************************;
**** Generate dummies to identify the simulations for which the ****;
**** simulated division treatments for small and large cities   ****;
**** lie within 0.05 percentage points of the estimated         ****;
**** division treatments                                        ****;
********************************************************************;

gen sdifftreat=ssmtreat-snptreat;
replace sdifftreat=abs(sdifftreat);

gen ldifftreat=lsmtreat-lnptreat;
replace ldifftreat=abs(ldifftreat);

gen onemoms=0;
replace onemoms=1 if sdifftreat<0.05;

gen onemoml=0;
replace onemoml=1 if ldifftreat<0.05;

gen twomom=0;
replace twomom=1 if sdifftreat<0.05&ldifftreat<0.05;

* Count the number of simulations for which these dummies are equal to one;

egen noj_onemoms=count(simorder) if onemoms==1;
egen noj_onemoml=count(simorder) if onemoml==1;
egen noj_twomom=count(simorder) if twomom==1;
so simorder;

* Generate the sum of squared deviations between the simulated and estimated;
* moments for small and large cities;

gen svar=(sdifftreat^2)+(ldifftreat^2);
gsort -twomom svar;
gen temp=1 if _n==1;
egen bestfit=max(temp),by(simorder);
gsort -twomom svar;
gen twomomorder=_n;
drop temp;

************************;
**** Create Table 3 ****;
************************;

* List the results for the simulations with the ten smallest sum of;
* squared deviations between the simulated and estimated moments;
* for small and large cities;

log using regressions/main_results/tables/table3.log,replace;
list distance stability sigma mu eta ssmtreat lsmtreat svar if twomomorder<=10;
log close;

*************************;
**** Create Figure 5 ****;
*************************;

* Graph of parameter configurations with a simulated division treatment within 0.05 percentage;
* points of the estimated division treatment for small and and large cities;

lab var distance "Distance Coefficient";

#delimit;
set scheme s1mono;
sort distance;
twoway (scatter stability distance if onemoms==1, msymbol(+) mcolor(gray))
(scatter stability distance if onemoml==1, msymbol(oh) mcolor(gray))
(scatter stability distance if bestfit==1, msymbol(d) mcolor(black) msize(medlarge)),
ytitle("Strength of Agglomeration", margin(medium))
title("Figure 5: Simulated Division Treatments", margin(medium))
legend(lab(1 "Small Cities") lab(2 "Large Cities") lab(3 "Best Fit") rows(1) cols(3))
note("Note: Figure displays parameter configurations with simulated division treatments within 0.05 percentage points of the"
"estimated division treatments for small or large cities. The best fit parameter configuration minimizes the sum of"
"squared deviations between the simulated and estimated division treatments for small and large cities."
, size(vsmall))
saving(grid_search/graphs/Figure5,replace);

graph export grid_search/graphs/Figure5.eps , replace as(eps);
