
*** This do file generates Figures A3, A4, A5, and A6 for the paper 
*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

*** Inputs: 

* DD-and-DDD-placebos-aggregate.dta


*** Outputs

* Figure A3. Bootstrapped Distribution of Placebo DD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Employment to Population Ratios Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021.  

*** Figure A4. Bootstrapped Distribution of Placebo DDD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Employment to Population Ratios Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 

* Figure A5. Bootstrapped Distribution of Placebo DD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State UNemplyment Rates Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021.  

* Figure A6. Bootstrapped Distribution of Placebo DDD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Unemployment Rates Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 

*** Last updated: 8/16/2023


set more off
capture log close
clear all





**** Figure A3. Bootstrapped Distribution of Placebo DD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Employment to Population Ratios Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 

	
* Panel A: Ages 25-54
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if controls == "covid" & outcome == "epop_cps_2554"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	

*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-2(1)2) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(0.998 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) ///
	xline(0.998, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelA, replace)
	

* Panel B: Ages 16-64
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if controls == "covid" & outcome == "epop_cps_1664"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-2(1)2) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(0.834 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(0.834, lpattern(solid) lwidth(thin) lcolor(black))  ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelB, replace)


* Panel C: Ages 16 and Over
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if controls == "covid" & outcome == "epop_cps_16plus"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-2(1)2) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xline(0.542, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xlabel(0.542 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelC, replace)



* Combined plot
graph combine panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Density", size(small)) b1("DD Estimate", size(small)) ///
	graphregion(color(white)) xcommon ycommon ///
	name(graphcombined, replace)
graph export "$figdir/figure-A3.pdf", as(pdf) replace





*** Figure A4. Bootstrapped Distribution of Placebo DDD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Employment to Population Ratios Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 


* Panel A: Ages 25-54
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if regression == "DDD" & outcome == "epop_cps_2554"

*** Bootstrap placebo DDD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	

*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did, xlabel(-2(1)2) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(1.156 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) ///
	xline(1.156, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelA, replace)	

	

* Panel B: Ages 16-64
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if regression == "DDD" & outcome == "epop_cps_1664"

*** Bootstrap placebo DDD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-2(1)2) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(1.516 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(1.516, lpattern(solid) lwidth(thin) lcolor(black))  ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelB, replace)


* Panel C: Ages 16 and Over
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if regression == "DDD" & outcome == "epop_cps_16plus"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did, xlabel(-2(1)2) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(1.011 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(1.011, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelC, replace)


* Combined plot
graph combine panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Density", size(small)) b1("DDD Estimate", size(small)) ///
	graphregion(color(white)) xcommon ycommon ///
	name(graphcombined, replace)
graph export "$figdir/figure-A4.pdf", as(pdf) replace




*** Figure A5. Bootstrapped Distribution of Placebo DD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Unemployment Rates Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 
	
* Ages 25-54
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if controls == "covid" & outcome == "ur_cps_2554"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	

*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-1.5(0.5)1.5) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(-0.915 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) ///
	xline(-0.915, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelA, replace)
	

* Ages 16-64
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if controls == "covid" & outcome == "ur_cps_1664"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	*estat bootstrap, all

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-1.5(0.5)1.5) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(-1.039 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(-1.039, lpattern(solid) lwidth(thin) lcolor(black))  ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelB, replace)


* Ages 16 and Over
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if controls == "covid" & outcome == "ur_cps_16plus"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-1.5(0.5)1.5) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xline(-1.001, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xlabel(-1.001 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelC, replace)



* Combined plot

graph combine panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Density", size(small)) b1("DD Estimate", size(small)) ///
	graphregion(color(white)) xcommon ycommon ///
	name(graphcombined, replace)
graph export "$figdir/figure-A5.pdf", as(pdf) replace




*** Figure A6. Bootstrapped Distribution of Placebo DDD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Unemployment Rates Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 


set trace off
	
*** Panel A: Ages 25-54
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if regression == "DDD" & outcome == "ur_cps_2554"

*** Bootstrap placebo DDD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	

*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did, xlabel(-1.5(0.5)1.5) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(-0.988 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) ///
	xline(-0.988, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelA, replace)	
	

* Panel B: Ages 16-64
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if regression == "DDD" & outcome == "ur_cps_1664"

*** Bootstrap placebo DDD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did, xlabel(-1.5(0.5)1.5) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(-0.889 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(-0.889, lpattern(solid) lwidth(thin) lcolor(black))  ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelB, replace)
*graph export "$figdir/placebo-DDD-UE-aggregate-ages-1664-covid-controls.pdf", as(pdf) replace	


* Panel C: Ages 16 and Over
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-aggregate.dta" , clear
	keep if regression == "DDD" & outcome == "ur_cps_16plus"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did, xlabel(-1.5(0.5)1.5) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xline(-0.825, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xlabel(-0.825 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelC, replace)



* Combined plot 
graph combine panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Density", size(small)) b1("DDD Estimate", size(small)) ///
	graphregion(color(white)) xcommon ycommon ///
	name(graphcombined, replace)
graph export "$figdir/figure-A6.pdf", as(pdf) replace

