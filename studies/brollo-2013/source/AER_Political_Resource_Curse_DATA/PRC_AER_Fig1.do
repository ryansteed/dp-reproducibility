
***AER FIGURE 1
clear all
*X*X*X*
use AER_largesample,clear
gen pop_grouped1=1 if pop<100
forvalues i=1(1)500 {
replace pop_grouped1=1+`i' if pop>`i'*100 & pop<(`i'*100)+101
}
replace pop_grouped1=102 if pop>10100& pop<10102
replace pop_grouped1=103 if pop>10290& pop<10301
replace pop_grouped1=136 if pop>13500& pop<13502
replace pop_grouped1=137 if pop>13690& pop<13701
replace pop_grouped1=238 if pop>23700& pop<23710
replace pop_grouped1=239 if pop>23860& pop<23901
replace pop_grouped1=306 if pop>30500& pop<30510
replace pop_grouped1=307 if pop>30660& pop<30701

egen pop_bar1=mean(pop), by(pop_grouped1)
egen fpm_bar1=mean(fpm), by(pop_grouped1)
egen fpm_hat_bar1=mean(fpm_hat), by(pop_grouped1)

twoway (scatter fpm pop,msymbol(circle_hollow) msize(small) mcolor(gray))/*
*/ ,xlabel(10189 13585 16981 23773 30565 37356 44148,labsize(tiny)) xline(10189 13585 16981 23773 30565 37356 44148) legend(off) ylabel(20 40 60 80,labsize(tiny))/*
*/ xtitle(Population) ytitle(FPM transfers)
graph save fpm1.gph,replace

twoway (scatter fpm_bar1 pop_bar1,msymbol(circle_hollow) msize(small) mcolor(gray))/*
*/(lowess fpm pop if pop>6793&pop<10189,mean lcolor(blue) lwidth(thick))/*
*/(lowess fpm pop if pop>10189&pop<13585,mean lcolor(blue) lwidth(thick))/*
*/(lowess fpm pop if pop>13585&pop<16981,mean lcolor(blue) lwidth(thick))/*
*/(lowess fpm pop if pop>16981&pop<23773,mean lcolor(blue) lwidth(thick))/*
*/(lowess fpm pop if pop>23773&pop<30565,mean lcolor(blue) lwidth(thick))/*
*/(lowess fpm pop if pop>30565&pop<37356,mean lcolor(blue) lwidth(thick))/*
*/(lowess fpm pop if pop>37356&pop<44148,mean lcolor(blue) lwidth(thick))/*
*/(lowess fpm pop if pop>44148,mean lcolor(blue) lwidth(thick))/*
*/ ,xlabel(10189 13585 16981 23773 30565 37356 44148,labsize(tiny)) xline(10189 13585 16981 23773 30565 37356 44148) legend(off) ylabel(20 40 60 80,labsize(tiny))/*
*/ xtitle(Population) ytitle(FPM transfers)
graph save fpm2.gph,replace

