clear all


#delimit;


** Input data file: sfp93 from the Southern Focus Poll;

global infile = "Analysis_data";
global outfile = "Latex_files";


use "$infile/sfp93";

** Merge with lynchingallstates and POP 1900/1910/1920 data to create lynching rate for all;
merge m:1 fips using "$infile/lynchallstates";
drop _merge;


** Black non-Hispanic;
regress pat lynchcapitamob i.State_FIPS [pweight =  TOTWT] if (RACE == 2 & HISPANIC == 2);
estimates store r1;
** White non-Hispanic;
regress pat lynchcapitamob i.State_FIPS [pweight =  TOTWT] if (RACE == 1 & HISPANIC == 2);
estimates store r2;

** Figure 11;
coefplot r1 || r2, vertical legend(off) ciopts(recast(rcap)) bycoefs byopts(yrescale) 
xlabel(1 "Blacks" 2 "Whites") keep(lynchcapitamob) yline(0) graphregion(color(white)) bgcolor(white)
title("Patriotism Important to Parents") subtitle("controlling for lynching rates"); 
gr export "$outfile\racepat.eps", as(eps) preview(off) replace;
