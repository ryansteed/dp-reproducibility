
clear
insheet using educ_cps_cohort_all.txt

twoway ///
 (connected smc  byear , sort msymbol(S) lcolor(navy*.9) lpattern(solid) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Predicted Share Having Attended Any College At Age 25") ) ///
   xlabel(1960(5)1990) xscale(r(1960 1990)) yscale(r(0.3999 0.8001)) ylabel(0.4(0.05)0.8) ytitle("Predicted Share") ///
   xtitle("Birth Year") 
graph export fig_educ_cohort_all.eps, replace
!epstopdf fig_educ_cohort_all.eps
!sz fig_educ_cohort_all.pdf

clear
insheet using educ_cps_cohort_gender.txt

twoway ///
 (connected smc0  byear , sort msymbol(S) mcolor(navy*0.9) lpattern(solid) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Predicted Share Having Attended Any College At Age 25") ) ///
   xlabel(1960(5)1990) xscale(r(1960 1990)) yscale(r(0.2999 0.7001)) ylabel(0.3(0.05)0.7) ytitle("Predicted Share") ///
   xtitle("Birth Year") 
graph export fig_educ_cohort_m.eps, replace
!epstopdf fig_educ_cohort_m.eps
!sz fig_educ_cohort_m.pdf

twoway ///
 (connected smc1 byear , sort msymbol(S) mcolor(navy*0.9) lpattern(solid) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Predicted Share Having Attended Any College At Age 25") ) ///
   xlabel(1960(5)1990) xscale(r(1960 1990)) yscale(r(0.3499 0.7501)) ylabel(0.35(0.05)0.75) ytitle("Predicted Share") ///
   xtitle("Birth Year") 
graph export fig_educ_cohort_f.eps, replace
!epstopdf fig_educ_cohort_f.eps
!sz fig_educ_cohort_f.pdf

exit
