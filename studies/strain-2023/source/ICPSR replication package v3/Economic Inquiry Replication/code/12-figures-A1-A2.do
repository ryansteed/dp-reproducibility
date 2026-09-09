
*** This do file generates Figures A1 and A2 for the paper 
*** "Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"
*** by Harry Holzer, Glenn Hubbard, and Michael R. Strain 

*** Inputs:

* DD-and-DDD-placebos-individual.dta" 

*** Outputs:

* Figure A1. Bootstrapped Distribution of Placebo DD Estimated Effects of Ending Both FPUC and PUA in June 2021 on U-E Transitions Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 

* Figure A2. Bootstrapped Distribution of Placebo DDD Estimated Effects of Ending Both FPUC and PUA in June 2021 on U-E Transitions Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021.



*** Last updated: 8/16/2023

set more off
capture log close
clear all


*** Figure A1. Bootstrapped Distribution of Placebo DD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Employment to Population Ratios Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021. 

set trace off
	
* Ages 25-54
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-individual.dta" , clear
	keep if sample == "age2554" & controls == "covid" & outcome == "UEtoE_2m"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	

*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-20(5)20) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(14.316 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) ///
	xline(14.316, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelA, replace)
	

* Ages 16-64
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-individual.dta" , clear
	keep if sample == "age1664" & controls == "covid" & outcome == "UEtoE_2m"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	*estat bootstrap, all

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-20(5)20) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(13.060 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(13.060, lpattern(solid) lwidth(thin) lcolor(black))  ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelB, replace)

* Ages 16 and Over
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-individual.dta" , clear
	keep if sample == "age1664" & controls == "covid" & outcome == "UEtoE_2m"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DD statistic
twoway kdensity mean_did, xlabel(-20(5)20) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xline(12.893, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xlabel(12.893 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelC, replace)


* Combined plot
graph combine panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Density", size(small)) b1("DD Estimate", size(small)) ///
	graphregion(color(white)) xcommon ycommon ///
	name(graphcombined, replace)
graph export "$figdir/figure-A1.pdf", as(pdf) replace





*** Figure A2. Bootstrapped Distribution of Placebo DDD Estimated Effects of Ending Both FPUC and PUA in June 2021 on State Employment to Population Ratios Using States Not Ending Either FPUC or PUA Before September 2021 Compared with Actual Effect Estimated Using States Ending Both FPUC and PUA in June 2021.

set trace off
	
* Ages 25-54
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-individual.dta" , clear
	keep if sample == "age2554" & regression == "DDD" & outcome == "UEtoE_2m"

*** Bootstrap placebo DDD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	

*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did, xlabel(-20(5)20) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(19.122 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) ///
	xline(19.122, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel A: Ages 25-54", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelA, replace)	

	

* Ages 16-64
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-individual.dta" , clear
	keep if sample == "age1664"  & regression == "DDD" & outcome == "UEtoE_2m"

*** Bootstrap placebo DDD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did,xlabel(-20(5)20) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xlabel(15.526 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	xline(15.526, lpattern(solid) lwidth(thin) lcolor(black))  ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	title("Panel B: Ages 16-64", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelB, replace)


* Ages 16 and Over
	tempfile boot_emp
	use "$wrkdir/DD-and-DDD-placebos-individual.dta" , clear
	keep if sample == "age1664" & regression == "DDD" & outcome == "UEtoE_2m"

*** Bootstrap placebo DiD by sampling 18 observations and taking the mean. Use 100,000 replications
	bootstrap mean_did=r(mean), saving("`boot_emp'", replace) seed(123456) nodots nowarn reps(100000) size(18) bca: summarize beta
	estat bootstrap, all

	matrix cis = e(ci_bca)
	local ci_lower = cis[1,1]
	local ci_upper = cis[2,1]

	use "`boot_emp'", clear
	
*** Histogram of bootstraped DDD statistic
twoway kdensity mean_did, xlabel(-20(5)20) ylabel(, gmin gmax nogrid) ///
	xaxis(1 2) xla(0 "0", labcolor(black) noticks axis(2) grid glcolor(red)) xtitle("", axis(2)) ///
	xline(14.348, lpattern(solid) lwidth(thin) lcolor(black)) ///
	xline(`ci_lower', lpattern(dash) lcolor(black)) xline(`ci_upper', lpattern(dash) lcolor(black)) ///
	xlabel(14.348 "Ended FPUC & PUA", labsize(vsmall) labcolor(black) noticks axis(2) grid glcolor(black)) /// 
	title("Panel C: Ages 16 and Over", size(medsmall)) bgcolor(white) graphregion(color(white)) ///
	xtitle("", axis(1)) xscale(noline axis(2)) ytitle("") name(panelC, replace)


* Combined plot
graph combine panelA panelB panelC, xsize(20) ysize(11) ///
	l1("Density", size(small)) b1("DDD Estimate", size(small)) ///
	graphregion(color(white)) xcommon ycommon ///
	name(graphcombined, replace)
graph export "$figdir/figure-A2.pdf", as(pdf) replace


