
*** This do file produces the following results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

* Figure 1: DD Event Studies of Changes in Robust Monthly Transitions into Employment from Unemployment Following the June 2021 Expiration of FPUC and PUA or Only FPUC UI Benefits Extended to September 2021. 

* Last updated: 8/14/2023

clear all 
capture log close 
set more off

* Load data
use "$wrkdir/individual-analysis.dta", replace


* Generate post variable after June
cap drop post
gen post =.
replace post = 0 if inrange(month,2,6)
replace post = 1 if inrange(month,7,8)

xtset cpsidp date, monthly


*********** Figure 1: Event Studies of Changes in Monthly Transitions into Employment from Unemployment Following the June 2021 Expiration of FPUC and PUA or Only FPUC. 

* Panel A: Ages 25-54
eststo: reghdfe UEtoE_2m i.endfpucandpua##b737.date i.endonlyfpuc##b737.date stringencyindex lnnewcases [aw=panlwt] if inrange(date,733,740) & inrange(age,25,54), absorb(statefip date age educ) cluster(statefip) noconstant

margins r.endfpucandpua@date r.endonlyfpuc@date, noestimcheck

mplotoffset, offset(0.2) yline(0, lcolor(black)) title("Panel A: Ages 25-54", size(medsmall)) ytitle("", size(small)) xtitle("") ///
bgcolor(white) graphregion(color(white)) ylabel(, gmin gmax) tlabel(2021m2(1)2021m9, format(%tmnn/YY) labsize(small)) recast(scatter) recastci(rspike) name(panelA, replace) ///
legend(order(3 "Both FPUC and PUA" 4 "Only FPUC") region(lstyle(none)) rows(1) size(small) symxsize(small) symysize(small)) 

* Panel B: Ages 16-64
eststo: reghdfe UEtoE_2m i.endfpucandpua##b737.date i.endonlyfpuc##b737.date stringencyindex lnnewcases [aw=panlwt] if inrange(date,733,740) & inrange(age,16,64), absorb(statefip date age educ) cluster(statefip) noconstant

margins r.endfpucandpua@date r.endonlyfpuc@date, noestimcheck

mplotoffset, offset(0.2) yline(0, lcolor(black)) title("Panel B: Ages 16-64", size(medsmall)) ytitle("", size(small)) xtitle("") ///
bgcolor(white) graphregion(color(white)) ylabel(, gmin gmax) tlabel(2021m2(1)2021m9, format(%tmnn/YY) labsize(small)) recast(scatter) recastci(rspike) name(panelB, replace) ///
legend(order(3 "Both FPUC and PUA" 4 "Only FPUC") region(lstyle(none)) rows(1) size(medsmall) symxsize(small) symysize(small))

* Panel C: Ages 16-64
eststo: reghdfe UEtoE_2m i.endfpucandpua##b737.date i.endonlyfpuc##b737.date stringencyindex lnnewcases [aw=panlwt] if inrange(date,733,740) & inrange(age,16,90), absorb(statefip date age educ) cluster(statefip) noconstant

margins r.endfpucandpua@date r.endonlyfpuc@date, noestimcheck

mplotoffset, offset(0.2) yline(0, lcolor(black)) title("Panel C: Ages 16 and Over", size(medsmall)) ytitle("", size(small)) xtitle("") ///
bgcolor(white) graphregion(color(white)) ylabel(, gmin gmax) tlabel(2021m2(1)2021m9, format(%tmnn/YY) labsize(small)) recast(scatter) recastci(rspike) name(panelC, replace) ///
legend(order(3 "Both FPUC and PUA" 4 "Only FPUC") region(lstyle(none)) rows(1) size(small) symxsize(small) symysize(small))

* Combined plot
grc1leg2 panelA panelB panelC, xsize(8) ysize(7) ///
	l1("Change (pp)", size(small)) ///
	legendfrom(panelA) lsize(small) graphregion(color(white)) ///
	name(graphcombined, replace)
graph export "$figdir/figure-1.pdf", as(pdf) replace 
