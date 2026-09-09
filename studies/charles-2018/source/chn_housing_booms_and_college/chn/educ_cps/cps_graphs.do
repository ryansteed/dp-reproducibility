
clear
insheet using ./education_trends_cps_all.txt

if (`1' == 18) {

}
else {
 replace smc_xb = .
}

twoway ///
 (connected smc  year , sort msymbol(S) lcolor(navy*.9) lpattern(solid) lwidth(medium) lcolor(navy*.9) ) ///
 (connected smc_xb  year , sort msymbol(i) lpattern(dash) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Share Having Attended Any College (Men and Women, Age 18-33)") ) ///
   xlabel(1980(5)2010) xscale(r(1980 2013)) yscale(r(0.3999 0.6001)) ylabel(0.4(0.04)0.6) ytitle("Share of Population") ///
   xtitle("Year") 
graph export ./fig_educ_all_`1'_`2'.eps, replace
!epstopdf ./fig_educ_all_`1'_`2'.eps
!sz ./fig_educ_all_`1'_`2'.pdf

clear
insheet using ./education_trends_cps.txt

if (`1' == 18) {

}
else {
replace smc0_xb = .
replace smc1_xb = .
}

twoway ///
 (connected smc0  year , sort msymbol(S) mcolor(navy*0.9) lpattern(solid) lwidth(medium) lcolor(navy*.9) ) ///
 (connected smc0_xb  year , sort msymbol(i) lpattern(dash) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Share Having Attended Any College (Men, Age `1'-`2')") ) ///
   xlabel(1980(5)2010) xscale(r(1980 2013)) yscale(r(0.395 0.605)) ylabel(0.4(0.04)0.6) ytitle("Share of Population") ///
   xtitle("Year") 
graph export ./fig_educ_m_`1'_`2'.eps, replace
!epstopdf ./fig_educ_m_`1'_`2'.eps
!sz ./fig_educ_m_`1'_`2'.pdf

twoway ///
 (connected smc1  year , sort msymbol(S) mcolor(navy*0.9) lpattern(solid) lwidth(medium) lcolor(navy*.9) ) ///
 (connected smc1_xb  year , sort msymbol(i) lpattern(dash) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Share Having Attended Any College (Women, Age `1'-`2')") ) ///
   xlabel(1980(5)2010) xscale(r(1980 2013)) yscale(r(0.415 0.665)) ylabel(0.42(0.04)0.66) ytitle("Share of Population") ///
   xtitle("Year") 
graph export ./fig_educ_f_`1'_`2'.eps, replace
!epstopdf ./fig_educ_f_`1'_`2'.eps
!sz ./fig_educ_f_`1'_`2'.pdf


exit
