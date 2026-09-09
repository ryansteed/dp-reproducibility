clear all 

#delimit;

** Main data can be used to create Figures 5, 6, 7 Tables 1, 2, 3, 4, 5, 8, and Appendix Tables B2, B3, B4, B5;
global infile = "Analysis_data";
global outfile = "Latex_files";


use "$infile/maindata";


** Declare global variables;
global ylist_black Blackrate_regvoters;
global ylist_white Whiterate_regvoters;
global historical c.Black_share_illiterate c.initial c.newscapita c.farmvalue c.sfarmprop1860 c.landineq1860 c.fbprop1860;
global cont_black c.Black_beyondhs c.Black_avgage c.Black_Earnings c.share_maritalblacks;
global cont_white c.White_beyondhs c.White_avgage c.White_Earnings c.share_maritalwhites; 


** Table 1: Descriptive Statistics;
estpost sum Blackrate_regvoters Whiterate_regvoters 
lynchingmob lynchcapitamob Black_POP_1900 farmvalue sfarmprop1860 landineq1860 fbprop1860 newscapita initial share_slaves Black_share_illiterate
Black_beyondhs Black_Earnings blackmemrate incarceration_2010 pollscapita ;
esttab using "$outfile/stats.tex", label cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3)) count(fmt(0))") noobs replace;


** Figure 5 with no controls;
binscatter $ylist_black lynchcapitamob, absorb(State_FIPS) graphregion(color(white)) bgcolor(white)
ytitle("Percentage of black registered voters") xtitle("Black lynching rate") title("No Controls");
graph save "$outfile/nocontrols.gph", replace;

** Figure 5 with historical controls;
binscatter $ylist_black lynchcapitamob, controls($historical) absorb(State_FIPS) graphregion(color(white)) bgcolor(white) 
ytitle("Percentage of black registered voters") xtitle("Black lynching rate") title("Historical Controls");
graph save "$outfile/historical.gph", replace;

** Figure 5 that shows lynchings and voter reg with no controls and historical controls;
graph combine "$outfile/nocontrols.gph" "$outfile/historical.gph", xcommon ycommon graphregion(color(white)) cols(3) plotregion(style(none));
graph export "$outfile/baseline.eps", as(eps) preview(off) replace;



**************************************** ROBUSTNESS CHECKS ****************************************;
** Table 2: Falsification exercises;
regress $ylist_black lynchcapitamob $historical i.State_FIPS; 
estimates store b1;
regress $ylist_black lynchcapitawhite $historical i.State_FIPS; 
estimates store b2;
regress $ylist_white lynchcapitamob $historical i.State_FIPS;
estimates store w1;
regress $ylist_white lynchcapitawhite $historical i.State_FIPS;
estimates store w2;

esttab b1 b2 w1 w2 using "$outfile/falsifications.tex", keep(lynchcapitamob lynchcapitawhite) order(lynchcapitamob lynchcapitawhite) 
nonum indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS") 
mlabels((1) (2) (3) (4))
mgroups("\makecell{Black Voter\\Registration Rate}" "\makecell{White Voter\\Registration Rate}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("\# of counties" "R-Squared") fmt(%11.0gc %9.3f)) replace;

*** EDITED by Ryan Steed;
estout b1 b2 w1 w2 using "../../results/Table2.csv", keep(lynchcapitamob lynchcapitawhite) order(lynchcapitamob lynchcapitawhite) cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;
***;

** Table 3: Baseline and slavery as a control;
regress $ylist_black lynchcapitamob $historical i.State_FIPS;
estimates store s1;
regress $ylist_black lynchcapitamob share_slaves $historical i.State_FIPS; 
estimates store s2;


esttab s1 s2 using "$outfile/slaves.tex", keep(lynchcapitamob share_slaves)  order(lynchcapitamob share_slaves)
nonum indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS") 
mlabels((1) (2)) nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) mgroups("\makecell{Black Voter\\Registration Rate}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
stats(N r2, labels("\# of counties" "R-Squared") fmt(%11.0gc %9.3f)) replace;

** Rescale shareslaves for Figures 6 and 7;
generate share_slaves2 = share_slaves/10000;
** Figure 6;
twoway scatter shareblack share_slaves2, ytitle("Voting age blacks (per 10k pop)") xtitle("Share of Slaves");
graph export "$outfile/scatblackslaves.eps", as(eps) preview(off) replace;

** Figure 7;
binscatter shareblack share_slaves2, ytitle("Voting age blacks (per 10k pop)")
xtitle("Share of Slaves") absorb(State_FIPS);
gr export "$outfile/binblackslaves.eps", as(eps) preview(off) replace;



** Table 4: Registered black voters and lynching rate with share slaves and share blacks;
regress register_black lynchcapitamob c.share_slaves shareblack $historical i.State_FIPS;
estimates store r1;

esttab r1 using "$outfile/regblack.tex", keep(lynchcapitamob share_slaves shareblack) 
order(lynchcapitamob share_slaves shareblack) 
nonum indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS") 
mgroups("\makecell{Number of Black\\Registered Voters}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("\# of counties" "R-Squared") fmt(%11.0gc %9.3f)) replace;



** Table 5: Black registration and lynching rate with comtemporary controls;
regress $ylist_black lynchcapitamob Black_beyondhs $historical i.State_FIPS; 
estimates store t1;
regress $ylist_black lynchcapitamob Black_Earnings $historical i.State_FIPS; 
estimates store t2;
regress $ylist_black lynchcapitamob c.incarceration_2010 $historical i.State_FIPS; 
estimates store t3;
regress $ylist_black lynchcapitamob c.pollscapita $historical i.State_FIPS; 
estimates store t4;
regress $ylist_black lynchcapitamob c.incarceration_2010 c.pollscapita $historical $cont_black i.State_FIPS; 
estimates store t5;

preserve;
label variable Black_beyondhs "\makecell[l]{Some college exp.\\or more of blacks}";
label variable Black_Earnings "\makecell[l]{Monthly earnings\\of blacks}";
label variable incarceration_2010 "\makecell[l]{Incarceration rate\\of blacks\\(per 10k pop)}";
label variable pollscapita "\makecell[l]{Polling place rate\\(per 10k pop)}";


esttab t1 t2 t3 t4 t5 using "$outfile/lynchmob.tex", keep(lynchcapitamob incarceration_2010 pollscapita
Black_beyondhs Black_Earnings) order(lynchcapitamob Black_beyondhs Black_Earnings incarceration_2010 pollscapita) nonum indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS") 
mlabels((1) (2) (3) (4) (5)) mgroups("\makecell{Black Voter\\Registration Rate}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("\# of counties " "R-Squared") fmt(%11.0gc %9.3f)) replace;

*** EDITED by Ryan Steed;
estout t1 t2 t3 t4 t5 using "../../results/Table5.csv", keep(lynchcapitamob incarceration_2010 pollscapita
Black_beyondhs Black_Earnings) order(lynchcapitamob Black_beyondhs Black_Earnings incarceration_2010 pollscapita) cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;
***;

restore;


** Table 8: Heterogenous effects;
generate log_bearnings = log(Black_Earnings);
generate perBlack_beyondhs = (Black_beyondhs)*100;

** Rescale lynching variable so that coefficients aren't 0.000;
generate lynchcapitamob2 = lynchcapitamob/10;
label variable log_bearnings "Log monthly earnings of blacks";
label variable lynchcapitamob2 "Black lynching rate";

regress $ylist_black c.lynchcapitamob2#c.perBlack_beyondhs lynchcapitamob2 $historical i.State_FIPS;
estimates store Education;

regress $ylist_black c.lynchcapitamob2#c.Black_Earnings lynchcapitamob2 $historical i.State_FIPS;
estimates store Earnings;

regress $ylist_black c.lynchcapitamob2#c.blackmemrate lynchcapitamob2 $historical i.State_FIPS;
estimates store Blackchurches;

esttab Education Earnings Blackchurches using "$outfile/persistence.tex", 
keep(c.lynchcapitamob2#c.perBlack_beyondhs c.lynchcapitamob2#c.Black_Earnings c.lynchcapitamob2#c.blackmemrate lynchcapitamob2)
order(c.lynchcapitamob2#c.perBlack_beyondhs c.lynchcapitamob2#c.Black_Earnings c.lynchcapitamob2#c.blackmemrate lynchcapitamob2) 
indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS")
mlabels((1) (2) (3)) mgroups("\makecell{Black Voter\\Registration Rate}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant" c.lynchcapitamob2#c.perBlack_beyondhs "\makecell[l]{Black lynching rate*\\Some college experience of blacks}" c.lynchcapitamob2#c.Black_Earnings "\makecell[l]{Black lynching rate*\\Monthly earnings of blacks}" c.lynchcapitamob2#c.blackmemrate "\makecell[l]{Black lynching rate*\\Black member rate in 2010}") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) nonum stats(N r2, labels("\# of counties" "R-Squared") fmt(%11.0gc %9.3f)) replace;




**************************************** APPENDIX TABLES ****************************************;

** Table B2: Lynching rate in using 1910, 1920, and 1930 black population;
regress $ylist_black lynchcapitamob1910 $historical i.State_FIPS; 
estimates store y1;
regress $ylist_black lynchcapitamob1920 $historical i.State_FIPS; 
estimates store y2;
regress $ylist_black lynchcapitamob1930 $historical i.State_FIPS; 
estimates store y3;

esttab y1 y2 y3 using "$outfile/denominator.tex", keep(lynchcapitamob1910 lynchcapitamob1920 lynchcapitamob1930) 
order(lynchcapitamob1910 lynchcapitamob1920 lynchcapitamob1930) 
nonum indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS") 
mlabels((1) (2) (3)) mgroups("\makecell{Black Voter\\Registration Rate}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("\# of counties" "R-Squared") fmt(%11.0gc %9.3f)) replace;



** Table B4: Lynching rate from Stevenson's data;
regress $ylist_black lynchcapitasteve $historical i.State_FIPS; 
estimates store s1;


esttab s1 using "$outfile/stevenson.tex", keep(lynchcapitasteve) order(lynchcapitasteve) 
nonum indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS") 
mlabels((1)) mgroups("\makecell{Black Voter\\Registration Rate}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("\# of counties" "R-Squared") fmt(%11.0gc %9.3f)) replace;



** Table B5: Selection on Observables to Access the Bias from Unobservables;
** Selection on observables;
** No controls;
regress $ylist_black lynchcapitamob i.State_FIPS;
scalar r1 = _b[lynchcapitamob];

** Contemporary controls;
regress $ylist_black lynchcapitamob $cont_black i.State_FIPS; 
scalar r2 = _b[lynchcapitamob];

** Baseline;
regress $ylist_black lynchcapitamob $historical i.State_FIPS; 
scalar f1 = _b[lynchcapitamob];

** Full set of controls;
regress $ylist_black lynchcapitamob c.incarceration_2010 c.pollscapita $historical $cont_black i.State_FIPS; 
scalar f2 = _b[lynchcapitamob];

psacalc beta lynchcapitamob;

** Compute ratios: beta^f/(beta^r-beta^f);
** Restricted = no controls & Full = baseline;
display f1/(r1-f1);


** Restricted = no controls & Full = confounders (contemporary);
display f2/(r1-f2);

** Restricted = contemporary & Full = baseline;
display f1/(r2-f1);

** Restricted = contemporary & Full = confounders;
display f2/(r2-f2);


** Table: B3: Convert lynching rates larger than 100 to 100 and use reg that are less than 100;
replace Blackrate_regvoters = 100 if Blackrate_regvoters > 100 & Blackrate_regvoters !=.;
regress Blackrate_regvoters lynchcapitamob $historical i.State_FIPS; 
estimates store s1;
regress Blackrate_regvoters lynchcapitamob $historical i.State_FIPS if Blackrate_regvoters < 100; 
estimates store s2;

esttab s1 s2 using "$outfile/regconveted.tex", keep(lynchcapitamob ) order(lynchcapitamob) nonum indicate("Historical Controls = newscapita" "State Fixed Effects = *.State_FIPS") 
mlabels("Black reg converted to 100" "Black reg less than 100") mgroups("\makecell{Black Voter\\Registration Rate}", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span)
nomtitles collabels(none) varlabels(_cons "Constant") label cells(b(fmt(3)) se(par(`"("'`")"') fmt(3))) 
stats(N r2, labels("\# of counties" "R-Squared") fmt(%11.0gc %9.3f)) replace;
