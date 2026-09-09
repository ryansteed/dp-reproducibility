/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"

cd "C:\CR_Legacy\files\data"


**************************************************************************************
/*Figure 5: Revolutionary Intensity and Industrialization*/
**************************************************************************************
	
clear

insheet using "industrialization_did_coeff_600.csv", clear

graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 xline(1966, lcolor(grey) lpattern(longdash)) xline(1976, lcolor(grey) lpattern(longdash)) ///
			 text(-1 1971 "Revolutionary", place(n)) text(-1.2 1971 "Years", place(n)) ///
			 text(1 1985 "Panel A: 1953 Base-year Sample", place(n)) legend(off) ///
			 legend(label(1 "Coefficients") label(2 "95% Confidence Interval")) ///
			 ytitle("Coefficient of Revolutionary Intensity") ///
			 xlabel(1964 1966 1976 1982 1990 2000,labsize(small)) ///
			 ylabel(-2(0.5)1.5,labsize(small)) ///
			 xtitle("Year") scheme(s1mono)							
			 
graph export "$results\ind_gdid_600.png", replace		
			 
			 
insheet using "industrialization_did_coeff_1486.csv", clear

graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 xline(1966, lcolor(grey) lpattern(longdash)) xline(1976, lcolor(grey) lpattern(longdash)) ///
			 text(-1 1971 "Revolutionary", place(n)) text(-1.2 1971 "Years", place(n)) ///
			 text(1 1985 "Panel B: 1964 Base-year Sample", place(n)) legend(off) ///
			 legend(label(1 "Coefficients") label(2 "95% Confidence Interval")) ///
			 ytitle("Coefficient of Revolutionary Intensity") ///
			 xlabel(1964 1966 1976 1982 1990 2000,labsize(small)) ///
			 ylabel(-2(0.5)1.5,labsize(small)) ///
			 xtitle("Year") scheme(s1mono)							
			 
graph export "$results\ind_gdid_1486.png", replace

