
#delimit;
clear;
set mem 400m;
set matsize 1200;
version 8.0;

**********************************************************************;
**** This file creates Figure 6 which displays the simulated and  ****;
**** estimated division treatments for individual West German     ****;
**** cities for the bestfit parameter configuration               ****;
**** Data are read in from Bestfitdata.csv which is created by    ****;
**** the Matlab program grid_search.m                             ****;
**********************************************************************;

* Bestfitdata.csv contains the grid search results for our sample of 119 West German cities for the; 
* parameter configuration with the smallest sum of squared deviations between; 
* the simulated and estimated division treatments for small and large cities;

* Bestfitdata.csv contains the following columns;

* Column 1 : simulation number (between 1 and 51,152);
* Column 2 : simulated steady-state population of each city following division : L_e;
* Column 3 : simulated number of varieties in each city following division : n_e;
* Column 4 : simulated variety price in each city following division : p_e;
* Column 5 : simulated price index for tradeable varieties in each city following division : PM_e;
* Column 6 : simulated nominal wage in each city following division : w_e;
* Column 7 : simulated aggregate expenditure in each city following division : E_e;
* Column 8 : simulated price of the non-traded amenity in each city following division : PH_e;
* Column 9 : simulated real wage in each city following division : om_s;
* Column 10 : stock of the non-traded amenity in each city from the calibration : H_e == H_c;
* Column 11 : coefficient on distance : delta
* Column 12 : elasticity of transport costs with respect to distance : eta;
* Column 13 : share of tradeables in expenditure : mu;
* Column 14 : elasticity of substitution : sigma;
* Column 15 : dist_gg_border; 
* Column 16 : city
* Column 17 : non-parametric estimates of the division treatment (mean == zero) : np_div;
* Column 18 : population in 1939 : l_c;
* Column 19 : population in 1919 : pop19;

local varlist = "simorder L_e n_e p_e PM_e w_e E_e PH_e om_e H_e delta eta mu sigma 
distgg city npdiv l_c pop1919";
insheet `varlist' using grid_search/data/BestfitData.csv;
so simorder city;

gen distance=(1-sigma)*eta;
gen stability=(1-mu)*sigma;

* Transform variables;

gen bzone=0;
replace bzone=1 if distgg<75;

gen smdiv=(((l_e/l_c)^(1/38))-1)*100;

egen mn_smdiv=mean(smdiv),by(simorder);
so simorder city;

replace smdiv=smdiv-mn_smdiv;

* Generate non-parametric and simulated treatments;

egen temp=mean(npdiv) if bzone==1,by(simorder);
egen bnpdiv=max(temp),by(simorder);
so simorder city;
drop temp;

egen temp=mean(npdiv) if bzone==0,by(simorder);
egen nbnpdiv=max(temp),by(simorder);
so simorder city;
drop temp;

gen nptreat=bnpdiv-nbnpdiv;
su nptreat;

egen temp=mean(smdiv) if bzone==1,by(simorder);
egen bsmdiv=max(temp),by(simorder);
so simorder city;
drop temp;

egen temp=mean(smdiv) if bzone==0,by(simorder);
egen nbsmdiv=max(temp),by(simorder);
so simorder city;
drop temp;

gen smtreat=bsmdiv-nbsmdiv;
su smtreat;

* Locally weighted linear least squares regressions;

lab var distgg "Distance to East-West German Border (km)";

lowess smdiv distgg , nograph gen(pmodel);
lowess npdiv distgg , nograph gen(pdata);

*******************************************************************************;
**** Figure 6 : Simulated Division Treatments for Bestfit Parameter Values ****;
**** and Estimated Division Treatments from the Non-parametric Estimation  ****;
**** for our sample of 119 West German cities                              ****;
*******************************************************************************;

set scheme s1mono;

sort distgg;
twoway
(scatter smdiv distgg, msymbol(+) mcolor(black))
(scatter npdiv distgg, msymbol(oh) mcolor(black))
(scatter pmodel distgg, msymbol(i) c(l) lpattern(solid) lwidth(thick))
(scatter pdata distgg, msymbol(i) c(l) lpattern(dash) lwidth(thick))
, yline(0) xline(75) ylabel(-4 -2 0 2 4) xlabel(#5)
ytitle("Division Treatment", margin(medium))
title("Figure 6: Simulated and Estimated Division Treatments", margin(medium))
legend(lab(1 "Simulated") lab(2 "Estimated") 
lab(3 "Lowess (Simulated)") lab(4 "Lowess (Estimated)")
rows(2) cols(2))
saving(grid_search/graphs/Figure6,replace)
note("Note: Simulated division treatments based on the parameter configuration that minimizes the sum of squared deviations"
"between the simulated and estimated division treatments for small and large cities. Lowess is a locally weighted linear"
"least squares regression of the division treatment against distance to the East-West German border (bandwidth 0.8).", size(vsmall));

graph export grid_search/graphs/Figure6.eps , replace as(eps);

gen diffsimest=abs(pmodel-pdata);
su diffsimest;
pwcorr pmodel pdata, sig;

