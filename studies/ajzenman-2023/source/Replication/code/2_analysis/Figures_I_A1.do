*------------------------------------------------------------------------------*
* 								Figures I and A1			 	 		  	   *
*------------------------------------------------------------------------------*

use "$rawdata/immigration_Correciones.dta", clear

*** Figure I
preserve
keep if year<=2017
collapse (sum) imm, by (year)
sort year
set obs 15
replace year = 2002 in 15
replace imm=imm/1000
sort year 
g cum_imm = sum(imm)
g censo =.
replace censo= 0.013 if year==2002
replace censo= 0.0204 if year==2012
replace censo= 0.044 if year==2017


twoway (bar censo year, lc(gs12) fc(gs12) ytitle(" # Immigrants/Population", size(large))) ///
		(line imm year, lw(med) lc(black) yaxis(2) ytitle("Inmigrant Inflow [Thousands]",  size(large) axis(2))), ///
		scheme(plotplainblind) legend(off) ///
		xtitle("") ylabel(,labsize(medlarge)) ylabel(,labsize(medlarge) axis(2)) xlabel(,labsize(medlarge)) 
graph export "$Graphs/Figure_I.pdf", as(pdf) replace

restore



*** Figure A1
preserve
keep if year>=2008 & year<=2017
collapse (sum) imm, by (year cat_pais)
bys year: egen imm_y= total(imm)
g prop_imm=imm/imm_y
		
		
twoway	(connect imm year if cat_pais=="peru", lc(gs4) mc(gs4) m(D) lp(solid) lwidth(medthick)) ///
		(connect imm year if cat_pais=="colombia", m(X) lc(gs10) mc(gs10)) ///
		(connect imm year if cat_pais=="bolivia", lp(dash) lc(gs6) mc() m(T) mc(gs6) lwidth(medthick)) ///
		(connect imm year if cat_pais=="venezuela", m(S) lc(gs8) mc(gs8)) ///
		(connect imm year if cat_pais=="haiti", m(O) lc(gs0) mc(gs0) ytitle("")), ///
		scheme(plotplainblind) legend(order(1 "Per" 2 "Col" 3 "Bol" 4 "Ven" 5 "Hai") size(large))  ///
		xtitle("") ylabel(,labsize(medlarge)) xlabel(,labsize(medlarge)) 
	graph export "$Graphs/Figure_A1.pdf", as(pdf) replace
	
restore 

