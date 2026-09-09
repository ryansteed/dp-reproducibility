
*** This do file generates the following results for the paper

*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

* Figure A8: Estimated Effect of Ending FPUC and PUA on State Employment-to-Population Ratios by Start of Pre period

* Figure A9: Estimated Effect of Ending FPUC and PUA on State UNemployment Rates by Start of Pre period


*** Last updated 8/16/2023

set more off
capture log close
clear all

* Load data
use "$wrkdir/aggregate-analysis.dta", clear

*** Post period is July or August 2021
cap drop post
gen post =.
replace post = 0
replace post = 1 if inrange(date,738,739)

*** Figure A8 DD EPOP. Test Different Start Months

est clear

forvalues i = 728(1)736 {

	di "start month = `i'"

	eststo m`i': reghdfe epop_cps_2554 i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_2554] if inrange(date,`i',739), absorb(i.statefip i.date) cluster(statefip) noconstant
	eststo n`i': reghdfe epop_cps_1664 i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_1664] if inrange(date,`i',739), absorb(i.statefip i.date) cluster(statefip) noconstant
	eststo l`i': reghdfe epop_cps_16plus i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_16plus] if inrange(date,`i',739), absorb(i.statefip i.date) cluster(statefip) noconstant
	 
}

*** Plot end FPUC and PUA X post period coefficients by preperiod length


* Panel A: Ages 25-54
coefplot (m728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (m729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (m730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (m731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (m732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (m733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (m734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (m735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (m736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(-2(1)2, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(0.670, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelA, replace) title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white))


* Panel B: Ages 16-64
coefplot (n728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (n729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (n730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (n731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (n732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (n733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (n734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (n735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (n736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(-2(1)2, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(0.678, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelB, replace) title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white))


* Panel C: Ages 16 and Over
coefplot  (l728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (l729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (l730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (l731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (l732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (l733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (l734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (l735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (l736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(-2(1)2, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(0.278, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelC, replace) title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white))

* Combined plot
grc1leg2 panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Effect of Ending FPUC and PUA in June 2021 (pp)", size(small)) ///
	b1("First Month of Preperiod", size(small)) ///
	loff lsize(small) graphregion(color(white)) ///
	margins(tiny) name(graphcombined, replace)
graph export "$figdir/figure-A8.pdf", as(pdf) replace 



*** Figure A9 DD UR. Test Different Start Months for Preperiod

est clear

forvalues i = 728(1)736 {

di "start month = `i'"

	eststo m`i': reghdfe ur_cps_2554 i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_2554] if inrange(date,`i',739), absorb(i.statefip i.date) cluster(statefip) noconstant
	eststo n`i': reghdfe ur_cps_1664 i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_1664] if inrange(date,`i',739), absorb(i.statefip i.date) cluster(statefip) noconstant
	eststo l`i': reghdfe ur_cps_16plus i.endfpucandpua##i.post i.endonlyfpuc##i.post [aw=statepop_16plus] if inrange(date,`i',739), absorb(i.statefip i.date) cluster(statefip) noconstant

}

*** Plot end FPUC and PUA X post period coefficients by preperiod length


* Panel A: Ages 25-54
coefplot  (m728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (m729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (m730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (m731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (m732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (m733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (m734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (m735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (m736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(-2(1)1, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(-0.722, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelA, replace) title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white))

* Panel B: Ages 16-64
coefplot  (n728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (n729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (n730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (n731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (n732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (n733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (n734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (n735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (n736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(-2(1)1, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(-0.829, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelB, replace) title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white))

* Panel C: Ages 16 and Over
coefplot (l728, aseq("9/20") mcolor(black) ciopts(lcolor(black)) ) (l729, aseq("10/20") mcolor(black) ciopts(lcolor(black)) ) (l730, aseq("11/20") mcolor(black) ciopts(lcolor(black)) ) (l731, aseq("12/20") mcolor(black) ciopts(lcolor(black)) ) (l732, aseq("1/21") mcolor(black) ciopts(lcolor(black)) ) (l733, aseq("2/21") mcolor(black) ciopts(lcolor(black)) ) (l734, aseq("3/21") mcolor(black) ciopts(lcolor(black)) ) (l735, aseq("4/21") mcolor(black) ciopts(lcolor(black)) ) (l736, aseq("5/21") mcolor(black) ciopts(lcolor(black)) ), ///
keep(1.endfpucandpua#1.post) vertical aseq swapnames legend(off) ylabel(-2(1)1, gmin gmax nogrid labsize(small)) xlabel(, labsize(small)) yline(-0.773, lpattern(dash) lcolor(black)) ///
ytitle("", size(medsmall)) xtitle("", size(medsmall)) name(panelC, replace) title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white))

* Combined plot
grc1leg2 panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Effect of Ending FPUC and PUA in June 2021 (pp)", size(small)) ///
	b1("First Month of Preperiod", size(small)) ///
	loff lsize(small) graphregion(color(white)) ///
	margins(tiny) name(graphcombined, replace)
graph export "$figdir/figure-A9.pdf", as(pdf) replace 