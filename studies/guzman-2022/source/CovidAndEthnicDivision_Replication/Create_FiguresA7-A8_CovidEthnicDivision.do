
/*
* PURPOSE: Identity during a Crisis: COVID-19 and Ethnic Divisions in the United States - Replication Figures
* Data Source: Master_data_covid_EHI.dta
* AUTHORs: Jakina Debnam Guzman, Marie Christelle Mabeu, and Roland Pongou
DATE: 2022 January, 12
*/

*---------------------------------------------------------------------------*
*				 			SET YOUR DIRECTORY 	
*--------------------------------------------------------------------------*	
global CovidAndEthnic "YOUR DIRECTORY"

clear all 
set maxvar 32767
set matsize 10000

*---------------------------------------------------------------------------*
*				 			FIGURE A7
*--------------------------------------------------------------------------*
cd "${CovidAndEthnic}/"
use fig_case1_P1_decilew.dta, clear
sort decile 
merge 1:1 decile using fig_death1_P1_decilew.dta
drop _merge

merge 1:1 decile using fig_case1_P2_decilew.dta
drop _merge

merge 1:1 decile using fig_death1_P2_decilew.dta
drop _merge

save fig_decilew, replace

*drop decileP1
gen decileP1=1
replace decileP1=decileP1[_n-1]+2 in 2/10
gen decileP2=decileP1+0.25
gen decileP3=decileP1+0.5
gen decileP4=decileP1+0.75



twoway (rcap ci_l95_case1_P1 ci_u95_case1_P1 decileP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_case1_P1 decileP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_case1_P2 ci_u95_case1_P2 decileP2, lcolor(red)) /// code for 95% CI
(scatter  beta_case1_P2 decileP2 , msize(1pt) mcolor(red)), ///
ytitle("Coef of the interaction term between policy and EFI", size(small) justification(center)) ///
xtitle("Deciles of W-NW residential segregation") ///
title("(a) COVID-19 cases" , justification(center)) ///  
xlabel( 1.25 "1" 3.25 "2" 5.25 "3" 7.25 "4" 9.25 "5" 11.25 "6" 13.25 "7" 15.25 "8" 17.25 "9" 19.25 "10", noticks) ///
yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "decilew_case.gph" , replace 


twoway (rcap ci_l95_death1_P1 ci_u95_death1_P1 decileP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_death1_P1 decileP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_death1_P2 ci_u95_death1_P2 decileP2, lcolor(red)) /// code for 95% CI
(scatter  beta_death1_P2 decileP2 , msize(1pt) mcolor(red)), ///
ytitle("Coef of the interaction term between policy and EFI", size(small) justification(center)) ///
xtitle("Deciles of W-NW  residential segregation") /// 
title("(b) COVID-19 deaths" , justification(center)) ///  
xlabel( 1.25 "1" 3.25 "2" 5.25 "3" 7.25 "4" 9.25 "5" 11.25 "6" 13.25 "7" 15.25 "8" 17.25 "9" 19.25 "10", noticks) ///
yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "decilew_death.gph" , replace 


*---------------------------------------------------------------------------*
*				 			FIGURE A7
*--------------------------------------------------------------------------*

**Figure A7: Effect of the interaction between emergency declarations and EFI on COVID-19 outcomes by decile of W-NW racial segregation
graph combine decilew_case.gph decilew_death.gph, ///
graphregion(color(white))  ysize(1.5) xsize(2.5) cols(2)
qui graph save "figureA7.gph" , replace 
qui graph export "figureA7.png" , as(png)  width(2000) replace
qui graph export "figureA7.eps" , replace



*---------------------------------------------------------------------------*
*				 			FIGURE A8
*--------------------------------------------------------------------------*
use fig_case1_P1_decilew.dta, clear
sort decile 
merge 1:1 decile using fig_death1_P1_decile_bw.dta
drop _merge

merge 1:1 decile using fig_case1_P2_decile_bw.dta
drop _merge

merge 1:1 decile using fig_death1_P2_decile_bw.dta
drop _merge

save fig_decile_bw, replace

*drop decileP1
gen decileP1=1
replace decileP1=decileP1[_n-1]+2 in 2/10
gen decileP2=decileP1+0.25
gen decileP3=decileP1+0.5
gen decileP4=decileP1+0.75



twoway (rcap ci_l95_case1_P1 ci_u95_case1_P1 decileP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_case1_P1 decileP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_case1_P2 ci_u95_case1_P2 decileP2, lcolor(red)) /// code for 95% CI
(scatter  beta_case1_P2 decileP2 , msize(1pt) mcolor(red)), ///
ytitle("Coef of the interaction term between policy and EFI", size(small) justification(center)) ///
xtitle("Deciles of B-W residential segregation") ///
title("(a) COVID-19 cases" , justification(center)) ///  
xlabel( 1.25 "1" 3.25 "2" 5.25 "3" 7.25 "4" 9.25 "5" 11.25 "6" 13.25 "7" 15.25 "8" 17.25 "9" 19.25 "10", noticks) ///
yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "decile_bw_case.gph" , replace 


twoway (rcap ci_l95_death1_P1 ci_u95_death1_P1 decileP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_death1_P1 decileP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_death1_P2 ci_u95_death1_P2 decileP2, lcolor(red)) /// code for 95% CI
(scatter  beta_death1_P2 decileP2 , msize(1pt) mcolor(red)), ///
ytitle("Coef of the interaction term between policy and EFI", size(small) justification(center)) ///
xtitle("Deciles of B-W residential segregation") /// 
title("(b) COVID-19 deaths" , justification(center)) ///  
xlabel( 1.25 "1" 3.25 "2" 5.25 "3" 7.25 "4" 9.25 "5" 11.25 "6" 13.25 "7" 15.25 "8" 17.25 "9" 19.25 "10", noticks) ///
yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "decile_bw_death.gph" , replace 

*---------------------------------------------------------------------------*
*				 			FIGURE A8
*--------------------------------------------------------------------------*

**Figure A8: Effect of the interaction between emergency declarations and EFI on COVID-19 outcomes by decile of B-W racial segregation
graph combine decile_bw_case.gph decile_bw_death.gph, ///
graphregion(color(white))  ysize(1.5) xsize(2.5) cols(2)
qui graph save "figureA8.gph" , replace 
qui graph export "figureA8.png" , as(png)  width(2000) replace
qui graph export "figureA8.eps" ,  replace
