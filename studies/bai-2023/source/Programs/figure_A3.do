/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off

global ks_fig  "C:\CR_Legacy\files\KS_fig"

cd "C:\CR_Legacy\files\data"


**************************************************************************************
/*Figure A3: Comparison between 1953 and 1964 Base Year Samples*/
**************************************************************************************

use cross_sectional_countydata.dta, clear

gen sample = 1

preserve

keep if pnapop1953 != .
replace sample = 0
save temp_data.dta, replace

restore

append using temp_data.dta

* Panel 1
twoway kdensity lnfracdeaths if sample == 0 & lnfracdeaths < 0.2, clpat(dash) || ///
	   kdensity lnfracdeaths if sample == 1 & lnfracdeaths < 0.2, 	///
	   ytitle("Kernel Density") xtitle("Revolutionary Intensity") ///
	   legend(label(1 "1953 Base Year Sample") label(2 "1964 Base Year Sample"))  ///
	   text(45 0.1 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(40 0.1 "p-value = 0.775", size(medium) place(s)) ///
	   yscale(range(0 60)) ylabel(0 10 20 30 40 50 60) ///
	   graphregion(fcolor(white))	  

graph export "$ks_fig\figa3_kdensity_rev_intensity.png", replace
	   
ksmirnov lnfracdeaths, by(sample)


* Panel 2

twoway kdensity pnapop1953 if sample == 0 & pnapop1953 < 50, clpat(dash) ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1953") ///
	   legend(label(1 "1953 Base Year Sample") on)  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   xscale(range(0 50)) xlabel(0 10 20 30 40 50) ///
	   text(0.12 25 "1953", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))	  

graph export "$ks_fig\figa3_kdensity_pnapop1953.png", replace	   
	   
* Panel 3

twoway kdensity pnapop1964 if sample == 0 & pnapop1964 < 50, clpat(dash) || ///
	   kdensity pnapop1964 if sample == 1 & pnapop1964 < 50, 	///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1964") ///
	   legend(label(1 "1953 Base Year Sample") label(2 "1964 Base Year Sample"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   xscale(range(0 50)) xlabel(0 10 20 30 40 50) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.298", size(medium) place(s)) ///
	   text(0.12 25 "1964", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))	  

graph export "$ks_fig\figa3_kdensity_pnapop1964.png", replace	 	   
	   
ksmirnov pnapop1964, by(sample)	   

********************************************************************************

* Panel 4

twoway kdensity pnapop1982 if sample == 0 & pnapop1982 < 50, clpat(dash) || ///
	   kdensity pnapop1982 if sample == 1 & pnapop1982 < 50, 	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1982") ///
	   legend(label(1 "1953 Base Year Sample") label(2 "1964 Base Year Sample"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   xscale(range(0 50)) xlabel(0 10 20 30 40 50) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.165", size(medium) place(s)) ///
	   text(0.12 25 "1982", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))	  
	   
graph export "$ks_fig\figa3_kdensity_pnapop1982.png", replace	 	   

ksmirnov pnapop1982, by(sample)	   

********************************************************************************

* Panel 5

twoway kdensity pnapop1990 if sample == 0 & pnapop1990 < 50, clpat(dash) || ///
	   kdensity pnapop1990 if sample == 1 & pnapop1990 < 50, 	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1990") ///
	   legend(label(1 "1953 Base Year Sample") label(2 "1964 Base Year Sample"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   xscale(range(0 50)) xlabel(0 10 20 30 40 50) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.581", size(medium) place(s)) ///
	   text(0.12 25 "1990", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))	  

graph export "$ks_fig\figa3_kdensity_pnapop1990.png", replace	 	   
	   
ksmirnov pnapop1990, by(sample)	   

********************************************************************************

* Panel 6

twoway kdensity pnapop2000 if sample == 0 & pnapop2000 < 50, clpat(dash) || ///
	   kdensity pnapop2000 if sample == 1 & pnapop2000 < 50, 	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 2000") ///
	   legend(label(1 "1953 Base Year Sample") label(2 "1964 Base Year Sample"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   xscale(range(0 50)) xlabel(0 10 20 30 40 50) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.660", size(medium) place(s)) ///
	   text(0.12 25 "2000", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))	  

graph export "$ks_fig\figa3_kdensity_pnapop2000.png", replace	 	   
	   
ksmirnov pnapop2000, by(sample)	   



