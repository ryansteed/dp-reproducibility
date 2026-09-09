/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"
global ks_fig "C:\CR_Legacy\files\KS_fig"

cd "C:\CR_Legacy\files\data"

	
**************************************************************************************
/*Figure A5: Revolutionary Intensity and Industrialization: 1964-2000*/
**************************************************************************************
use cross_sectional_countydata.dta, clear


*Multiply by 100 for 1 percent
gen deathspc100 = (deaths/pop1964)*100

sum deathspc100, d
*25th percentile = 0, 75th percentile = 0.0301081 

gen VAR = .
replace VAR = 0 if lnfracdeaths == 0
replace VAR = 1 if lnfracdeaths >= 0.0301081 


* Panel 1964

twoway kdensity pnapop1964 if VAR == 0 & pnapop1964 < 50, clpat(dash) || ///
	   kdensity pnapop1964 if VAR == 1 & pnapop1964 < 50,	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1964") ///
	   legend(label(1 "Deaths (bottom quartile)") label(2 "Deaths (top quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.114", size(medium) place(s)) ///
	   text(0.12  25 "1964", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\largersample_kdensity_pnapop1964.png", replace	 	   
	   
ksmirnov pnapop1964, by(VAR) exact

* Panel 1982

twoway kdensity pnapop1982 if VAR == 0 & pnapop1982 < 50, clpat(dash) || ///
	   kdensity pnapop1982 if VAR == 1 & pnapop1982 < 50, 	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1982") ///
	   legend(label(1 "Deaths (bottom quartile)") label(2 "Deaths (top quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.049", size(medium) place(s)) ///
	   text(0.12  25 "1982", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\largersample_kdensity_pnapop1982.png", replace	 	   
	   
ksmirnov pnapop1982, by(VAR) exact

* Panel 1990

twoway kdensity pnapop1990 if VAR == 0 & pnapop1990 < 50, clpat(dash) || ///
	   kdensity pnapop1990 if VAR == 1 & pnapop1990 < 50, 	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1990") ///
	   legend(label(1 "Deaths (bottom quartile)") label(2 "Deaths (top quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.367", size(medium) place(s)) ///
	   text(0.12  25 "1990", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\largersample_kdensity_pnapop1990.png", replace	 	   

ksmirnov pnapop1990, by(VAR) exact

* Panel 2000

twoway kdensity pnapop2000 if VAR == 0 & pnapop2000 < 50, clpat(dash) || ///
	   kdensity pnapop2000 if VAR == 1 & pnapop2000 < 50, 	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 2000") ///
	   legend(label(1 "Deaths (bottom quartile)") label(2 "Deaths (top quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.016", size(medium) place(s)) ///
	   text(0.12  25 "2000", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\largersample_kdensity_pnapop2000.png", replace	 	   

ksmirnov pnapop2000, by(VAR) exact


 


