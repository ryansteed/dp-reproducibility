#delimit ;
set more off;
clear;
capture clear matrix;
capture log close;
set scheme s1mono;
*****************************************************************;
* Program: BohnFreedmanOwens_AER-PP.do;
* Article: "The Criminal Justice Response to Policy Interventions"
* Authors: Bohn, Freedman, and Owens
* Journal: American Economic Review, Papers & Proceedings
* Date: January 5, 2015
*****************************************************************;
* Log;
*******************;
log using BohnFreedmanOwens_AER-PP_Results.txt, text replace;

*****************************************************************;
* Data;
*******************;
use BohnFreedmanOwens_AER-PP_Data;

*****************************************************************;
di as txt "Create Time (Year x Month) Dummies";
qui xi i.yearmonth;
*******************;

*****************************************************************;
di as txt "Table 1";
*******************;

foreach group in misdemeanor felony {;
	foreach demog in povrate pct_foreign {;
		di "Results for `group' arrests with `demog' interactions [Table 1]";
		sum arrests_hf if group=="`group'" & sample=="ALL";
		eststo r_`group'_`demog': areg ln_arrests_hf i_`demog'* _I* if group=="`group'" & sample=="ALL", absorb(bg) cluster(bg) robust;
		est store r_`group'_`demog';
	};
};
foreach group in assigned_mis assigned_fel {;
	foreach demog in povrate pct_foreign {;
		di "Results for `group' prosecutorial acceptance rates with `demog' interactions [Table 1]";
		sum assignment_rate if group=="`group'" & sample=="ALL";
		areg assignment_rate i_`demog'* _I* if group=="`group'" & sample=="ALL", absorb(bg) cluster(bg) robust;
		est store r_`group'_`demog';
	};
};
estout using "./../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace;

di "Table 1 Results";
estout r_misdemeanor_povrate r_assigned_mis_povrate r_felony_povrate r_assigned_fel_povrate, c(b(fmt(3) star) se(fmt(3) par([ ])) ) starlevels(* 0.10 ** 0.05 *** 0.01) keep(i_povrate_*);
estout r_misdemeanor_pct_foreign r_assigned_mis_pct_foreign r_felony_pct_foreign r_assigned_fel_pct_foreign, c(b(fmt(3) star) se(fmt(3) par([ ])) ) starlevels(* 0.10 ** 0.05 *** 0.01) keep(i_pct_foreign_*);
est clear;

*****************************************************************;
di as txt "Table 2";
*******************;
keep if sample=="HISP";

foreach group in misdemeanor felony {; 
	foreach demog in povrate pct_foreign {;
		di "Results for `group' arrests with Hispanic x `demog' interactions [Table 2]";
		sum arrests_hf if group=="`group'" & sample=="HISP";
		areg ln_arrests_hf hisp h_enacted h_exLAW h_exSAW 
		     o_`demog'* i_`demog'* h_`demog'* _I* if group=="`group'" & sample=="HISP", 
			 absorb(bg) cluster(bg) robust;
		est store r_`group'_`demog';
	};
};
foreach group in assigned_mis assigned_fel {; 
	foreach demog in povrate pct_foreign {;
		di "Results for `group' prosecutorial acceptance rates with Hispanic x `demog' interactions [Table 2]";
		sum assignment_rate if group=="`group'" & sample=="HISP";
		areg assignment_rate hisp h_enacted h_exLAW h_exSAW 
		     o_`demog'* i_`demog'* h_`demog'* _I* if group=="`group'" & sample=="HISP", 
			 absorb(bg) cluster(bg) robust;
		est store r_`group'_`demog';
	};
};
di "Table 2 Results";
estout r_misdemeanor_povrate r_assigned_mis_povrate r_felony_povrate r_assigned_fel_povrate, c(b(fmt(3) star) se(fmt(3) par([ ])) ) starlevels(* 0.10 ** 0.05 *** 0.01) keep(h_povrate_*);
estout r_misdemeanor_pct_foreign r_assigned_mis_pct_foreign r_felony_pct_foreign r_assigned_fel_pct_foreign, c(b(fmt(3) star) se(fmt(3) par([ ])) ) starlevels(* 0.10 ** 0.05 *** 0.01) keep(h_pct_foreign_*);
est clear;

*****************************************************************;
di as txt "Figure 1";
*******************;
keep if sample=="HISP";
collapse (sum) arrests, by(year yearmonth subgroup);
reshape wide arrests, i(yearmonth) j(subgroup) s;
gen feldiff=(arrestsfelony_h-arrestsfelony_nh)/arrestsfelony_h;
gen misdiff=(arrestsmisdemeanor_h-arrestsmisdemeanor_nh)/arrestsmisdemeanor_h;
by year, sort: egen anfelh=sum(arrestsfelony_h);
by year, sort: egen anfelnh=sum(arrestsfelony_nh);
by year, sort: egen anmish=sum(arrestsmisdemeanor_h);
by year, sort: egen anmisnh=sum(arrestsmisdemeanor_nh);
gen anfeldiff=(anfelh-anfelnh)/anfelh;
gen anmisddiff=(anmish-anmisnh)/anmish;

twoway (line feldiff yearmonth, lwidth(medthick) lcolor(black) yaxis(1))
	(line anfeldiff yearmonth, lcolor(black) lpattern(dash))
	(line misdiff yearmonth, yaxis(1) lwidth(medthick) lcolor(gray))
	(line anmisddiff yearmonth, lcolor(gray) lpattern(dash)),	
	legend(label(1 "Felonies") label(2 "Annual Felonies") label(3 "Misdemeanors") label(4 "Annual Misdemeanors") region(lstyle(none)))
	ytitle("Percent Difference") xtitle(" ") xline(322 340 347)	xlabel(318 330 342 354 366 374) xtick(318 330 342 354 366 374)
	text(0.36 322.2  "Enacted", place(e)) text(0.36 340.2  "LAW", place(e)) text(0.36 347.2  "SAW", place(e))
	saving(BohnFreedmanOwens_AER-PP_Figure1, replace); 

clear;
log close;	
	
