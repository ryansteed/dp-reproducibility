/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"
global ks_fig  "C:\CR_Legacy\files\KS_fig"

cd "C:\CR_Legacy\files\data"

**************************************************************************************
/*Figure 4: Revolutionary Intensity and Industrialization*/
**************************************************************************************

use cross_sectional_countydata.dta, clear

keep if sample1953 == 1

sum lnfracdeaths, d
*25th percentile (lnfracdeaths) = 0, 75th percentile (lnfracdeaths) = 0.0313201 

gen HIGH = 0 
replace HIGH = 1 if lnfracdeaths >= 0.0313201

gen LOW = 0
replace LOW = 1 if lnfracdeaths == 0

gen DELETE = 0
replace DELETE = 1 if lnfracdeaths>0 & lnfracdeaths<0.0313201

drop if DELETE==1

gen VAR = 0
replace VAR = 1 if HIGH == 1

* YEAR = 1953
twoway kdensity pnapop1953 if HIGH == 1 & pnapop1953 < 50, clpat(dash) || ///
	   kdensity pnapop1953 if LOW == 1 & pnapop1953 < 50, 	///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1953") ///
	   legend(label(1 "Deaths (top quartile)") label(2 "Deaths (bottom quartile)")) /// 
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.124", size(medium) place(s)) ///
	   text(0.12  25 "1953", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))
	   
	   
graph export "$ks_fig\fig4_kdensity_1953.png", replace	   

ksmirnov pnapop1953, by(VAR) exact


* YEAR = 1964 
twoway kdensity pnapop1964 if HIGH == 1 & pnapop1964 < 50, clpat(dash) || ///
	   kdensity pnapop1964 if LOW == 1 & pnapop1964 < 50, 	///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1964") ///
	   legend(label(1 "Deaths (top quartile)") label(2 "Deaths (bottom quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.656", size(medium) place(s)) ///
	   text(0.12  25 "1964", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\fig4_kdensity_1964.png", replace	   
	   
ksmirnov pnapop1964, by(VAR) exact

* YEAR = 1982

twoway kdensity pnapop1982 if HIGH == 1 & pnapop1982 < 50, clpat(dash) || ///
	   kdensity pnapop1982 if LOW == 1 & pnapop1982 < 50, 	///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1982") ///
	   legend(label(1 "Deaths (top quartile)") label(2 "Deaths (bottom quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.022", size(medium) place(s)) ///
	   text(0.12  25 "1982", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\fig4_kdensity_1982.png", replace	   
	   
ksmirnov pnapop1982, by(VAR) exact

* YEAR = 1990

twoway kdensity pnapop1990 if HIGH == 1 & pnapop1990 < 50, clpat(dash) || ///
	   kdensity pnapop1990 if LOW == 1 & pnapop1990 < 50, 	///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 1990") ///
	   legend(label(1 "Deaths (top quartile)") label(2 "Deaths (bottom quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.042", size(medium) place(s)) ///
	   text(0.12  25 "1990", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\fig4_kdensity_1990.png", replace	   
	   
ksmirnov pnapop1990, by(VAR) exact

* YEAR = 2000

twoway kdensity pnapop2000 if HIGH == 1 & pnapop2000 < 50, clpat(dash) || ///
	   kdensity pnapop2000 if LOW == 1 & pnapop2000 < 50, 	 ///
	   ytitle("Kernel Density") xtitle("Percentage of Non-Agricultural Population in 2000") ///
	   legend(label(1 "Deaths (top quartile)") label(2 "Deaths (bottom quartile)"))  ///
	   yscale(range(0 0.12)) ylabel(0 0.03 0.06 0.09 0.12) ///
	   text(0.08 30 "Kolmogorov-Smirnov test", size(medium) place(s)) ///
	   text(0.07 30 "p-value = 0.143", size(medium) place(s)) ///
	   text(0.12  25 "2000", size(vlarge) place(s)) ///
	   graphregion(fcolor(white))

graph export "$ks_fig\fig4_kdensity_2000.png", replace	   
	   
ksmirnov pnapop2000, by(VAR) exact



