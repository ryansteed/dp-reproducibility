*==============================================================================
* Description: This do-file creates subfigures in Figure A1
* Data: 2/7/2025
*===============================================================================
	
clear

set obs 4

gen dist=0
replace dist=999.9 if _n==2
replace dist=1000 if _n==3
replace dist=2000 if _n==4

* Sentence years
gen prison_X = 12 if dist<1000 
replace prison_X=6 if dist>=1000
gen prison_1 = 4 if dist>=1000
replace prison_1 = 8 if dist<1000
gen prison_2 = 3 if dist>=1000
replace prison_2 = 6 if dist<1000
gen prison_3 = 2 if dist>=1000
replace prison_3 = 4 if dist<1000
gen prison_4 = 1 if dist>=1000
replace prison_4 = 2 if dist<1000

gen prison_m_X = 120 if dist<1000 
replace prison_m_X=60 if dist>=1000
gen prison_m_1 = 15 if dist>=1000
replace prison_m_1 = 30 if dist<1000
gen prison_m_2 = 7 if dist>=1000
replace prison_m_2 = 14 if dist<1000
gen prison_m_3 = 5 if dist>=1000
replace prison_m_3 = 10 if dist<1000
gen prison_m_4 = 3 if dist>=1000
replace prison_m_4 = 6 if dist<1000


* Fines
gen fine_X_f = 500 if dist>=1000 
replace fine_X_f=1000 if dist<1000
gen fine_1_f = 250 if dist>=1000
replace fine_1_f = 500 if dist<1000
gen fine_2_f = 200 if dist>=1000
replace fine_2_f = 400 if dist<1000
gen fine_3_f = 150 if dist>=1000
replace fine_3_f = 300 if dist<1000
gen fine_4_f = 25 if dist>=1000
replace fine_4_f = 50 if dist<1000

foreach i in X 1 2 3 4 {
	label var prison_`i' "Class `i'"
	label var prison_m_`i' "Class `i'"
	label var fine_`i'_f "Class `i'"
}

* Graph for sentence
gr tw (line prison_X dist, lwidth(medthick)) ///
	  (line prison_1 dist, lwidth(medthick)) ///
	  (line prison_2 dist, lwidth(medthick) lpattern(dash_dot)) ///
	  (line prison_3 dist, lwidth(medthick) lpattern(dash)) ///
	  (line prison_4 dist, lwidth(medthick)), ///
	  ylabel(,nogrid) legend(ring(0) position(2)) ///
	  xlabel(0(1000)2000,nogrid) xtitle(Distance to schools (ft)) ///
	  ytitle(Minimum prison term (years)) scheme(plotplainblind)
	  graph export "$output/penalties_min.eps", replace

* Graph for fines
gr tw (line fine_X_f dist, lwidth(medthick)) ///
	  (line fine_1_f dist, lwidth(medthick)) ///
	  (line fine_2_f dist, lwidth(medthick) lpattern(dash_dot)) ///
	  (line fine_3_f dist, lwidth(medthick) lpattern(dash)) ///
	  (line fine_4_f dist, lwidth(medthick)), ///
	  ylabel(,nogrid) legend(ring(0) position(2)) ///
	  xlabel(0(1000)2000,nogrid) xtitle(Distance to schools (ft)) ///
	  ytitle(Maximum fine ($000's)) scheme(plotplainblind)
	  graph export "$output/fines.eps", replace

