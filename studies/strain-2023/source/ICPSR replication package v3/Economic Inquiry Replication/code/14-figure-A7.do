
*** This do file produces the following results in the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

* Figure A7: Estimated Effect of Ending FPUC and PUA on Robust U-E Transitions by Start of Pre period

* Last updated: 8/14/2023

clear all 
capture log close 
set more off

* Load data
use "$wrkdir/individual-analysis.dta", replace


* Generate post period dates for figure A7
cap drop post
gen post =.
replace post = 0
replace post = 1 if inrange(date,738,739)


*** Figure A7: DD regression estimates for U-E robust transitions by start of preperiod 

est clear

forvalues i = 728(1)736 {

di "start month = `i'"

	eststo m`i': reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=panlwt] if inrange(age,25,54) & inrange(date,`i',739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
	eststo n`i': reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=panlwt] if inrange(age,16,64) & inrange(date,`i',739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
	eststo l`i': reghdfe UEtoE_2m i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=panlwt] if inrange(age,16,90) & inrange(date,`i',739), absorb(i.statefip i.date i.age i.educ) cluster(statefip) noconstant
}


*** Plot end FPUC and PUA X post period coefficients by preperiod length


* Panel A: Ages 25-54
coefplot (m728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (m729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (m730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (m731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (m732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (m733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (m734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (m735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (m736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(0(5)20, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(14.013, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelA, replace) title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white))

* Panel B: Ages 16-64
coefplot (n728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (n729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (n730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (n731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (n732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (n733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (n734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (n735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (n736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(0(5)20, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(11.847, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelB, replace) title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white))

* Panel C: Ages 16 and Over
coefplot (l728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (l729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (l730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (l731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (l732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (l733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (l734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (l735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (l736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(0(5)20, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(11.641, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelC, replace) title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white))

* Combined plot
grc1leg2 panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Effect of Ending FPUC and PUA in June 2021 (pp)", size(small)) ///
	b1("First Month of Preperiod", size(small)) ///
	loff lsize(small) graphregion(color(white)) ///
	margins(tiny) name(graphcombined, replace)
graph export "$figdir/figure-A7.pdf", as(pdf) replace 


