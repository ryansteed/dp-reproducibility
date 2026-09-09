/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off

global MainDir "/Users/liangbai/Dropbox/CR_Legacy/submissions/JEH/Submission_files/Data and replication files"


/*--------------------------------FIGURE 6 --------------------------------------*/
/*---------------------------1931-35 as base group-------------------------------*/
 
* Years of Education

use "$MainDir/data/results/1931-35_base/edu_coeff_2000_ipums_1of2.dta", clear

gen year = .
replace year = 1936 if var == "age3640deaths"
replace year = 1941 if var == "age4145deaths"
replace year = 1946 if var == "age4650deaths"
replace year = 1951 if var == "age5155deaths"
replace year = 1956 if var == "age5660deaths"
replace year = 1961 if var == "age6165deaths" 
replace year = 1966 if var == "age6670deaths"
replace year = 1971 if var == "age7175deaths"
replace year = 1976 if var == "age7680deaths" 
 
graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 text(0.7 1956 "Panel A: Years of Schooling", place(n)) legend(off) ///
			 ytitle("Coef.of CR Intensity*Birth Cohort") ///
			 xlabel(1936 1941 1946 1951 1956 1961 1966 1971 1976,labsize(small)) ///
			 ylabel(-0.5(0.2)0.9,labsize(small)) ///
			 xtitle("Birth Cohort") scheme(s1mono)							

graph export "$MainDir/data/results/1931-35_base/edu_gdid_5y_1of2.png", replace

* College Education

use "$MainDir/data/results/1931-35_base/edu_coeff_2000_ipums_2of2.dta", clear

gen year = .
replace year = 1936 if var == "college:age3640deaths"
replace year = 1941 if var == "college:age4145deaths"
replace year = 1946 if var == "college:age4650deaths"
replace year = 1951 if var == "college:age5155deaths"
replace year = 1956 if var == "college:age5660deaths"
replace year = 1961 if var == "college:age6165deaths" 
replace year = 1966 if var == "college:age6670deaths"
replace year = 1971 if var == "college:age7175deaths"
replace year = 1976 if var == "college:age7680deaths" 
 
graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 text(2 1956 "Panel B: College Education", place(n)) legend(off) ///
			 ytitle("Coef.of CR Intensity*Birth Cohort") ///
			 xlabel(1936 1941 1946 1951 1956 1961 1966 1971 1976,labsize(small)) ///
			 ylabel(-4(1)3,labsize(small)) ///
			 xtitle("Birth Cohort") scheme(s1mono)							

graph export "$MainDir/data/results/1931-35_base/edu_gdid_5y_2of2.png", replace

* Employment Status
 
use "$MainDir/data/results/1931-35_base/lab_coeff_2000_ipums_1of4.dta", clear

gen year = .
replace year = 1936 if var == "employed:age3640deaths"
replace year = 1941 if var == "employed:age4145deaths"
replace year = 1946 if var == "employed:age4650deaths"
replace year = 1951 if var == "employed:age5155deaths"
replace year = 1956 if var == "employed:age5660deaths"
replace year = 1961 if var == "employed:age6165deaths" 
replace year = 1966 if var == "employed:age6670deaths"
replace year = 1971 if var == "employed:age7175deaths"
replace year = 1976 if var == "employed:age7680deaths" 
 
graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 text(2 1956 "Panel A: Employment Status", place(n)) legend(off) ///
			 ytitle("Coef.of CR Intensity*Birth Cohort") ///
			 xlabel(1936 1941 1946 1951 1956 1961 1966 1971 1976,labsize(small)) ///
			 ylabel(-4(1)3,labsize(small)) ///
			 xtitle("Birth Cohort") scheme(s1mono)							

graph export "$MainDir/data/results/1931-35_base/lab_gdid_5y_1of4.png", replace

* Number of Days Worked
 
use "$MainDir/data/results/1931-35_base/lab_coeff_2000_ipums_2of4.dta", clear

gen year = .
replace year = 1936 if var == "age3640deaths"
replace year = 1941 if var == "age4145deaths"
replace year = 1946 if var == "age4650deaths"
replace year = 1951 if var == "age5155deaths"
replace year = 1956 if var == "age5660deaths"
replace year = 1961 if var == "age6165deaths" 
replace year = 1966 if var == "age6670deaths"
replace year = 1971 if var == "age7175deaths"
replace year = 1976 if var == "age7680deaths" 
 
graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 text(2 1956 "Panel B: Days Worked Last Week", place(n)) legend(off) ///
			 ytitle("Coef.of CR Intensity*Birth Cohort") ///
			 xlabel(1936 1941 1946 1951 1956 1961 1966 1971 1976,labsize(small)) ///
			 ylabel(-4(1)3,labsize(small)) ///
			 xtitle("Birth Cohort") scheme(s1mono)							

graph export "$MainDir/data/results/1931-35_base/lab_gdid_5y_2of4.png", replace

* Professional Occupation
 
use "$MainDir/data/results/1931-35_base/lab_coeff_2000_ipums_3of4.dta", clear

gen year = .
replace year = 1936 if var == "professional:age3640deaths"
replace year = 1941 if var == "professional:age4145deaths"
replace year = 1946 if var == "professional:age4650deaths"
replace year = 1951 if var == "professional:age5155deaths"
replace year = 1956 if var == "professional:age5660deaths"
replace year = 1961 if var == "professional:age6165deaths" 
replace year = 1966 if var == "professional:age6670deaths"
replace year = 1971 if var == "professional:age7175deaths"
replace year = 1976 if var == "professional:age7680deaths" 
 
graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 text(2 1956 "Panel C: Professional Occupation", place(n)) legend(off) ///
			 ytitle("Coef.of CR Intensity*Birth Cohort") ///
			 xlabel(1936 1941 1946 1951 1956 1961 1966 1971 1976,labsize(small)) ///
			 ylabel(-4(1)3,labsize(small)) ///
			 xtitle("Birth Cohort") scheme(s1mono)							

graph export "$MainDir/data/results/1931-35_base/lab_gdid_5y_3of4.png", replace

* Entrepreneur
 
use "$MainDir/data/results/1931-35_base/lab_coeff_2000_ipums_4of4.dta", clear

gen year = .
replace year = 1936 if var == "entrepreneur:age3640deaths"
replace year = 1941 if var == "entrepreneur:age4145deaths"
replace year = 1946 if var == "entrepreneur:age4650deaths"
replace year = 1951 if var == "entrepreneur:age5155deaths"
replace year = 1956 if var == "entrepreneur:age5660deaths"
replace year = 1961 if var == "entrepreneur:age6165deaths" 
replace year = 1966 if var == "entrepreneur:age6670deaths"
replace year = 1971 if var == "entrepreneur:age7175deaths"
replace year = 1976 if var == "entrepreneur:age7680deaths" 
 
graph twoway (connected coef year, clpattern(solid) clwidth(mthick) msymbol(th) mcolor(red)) ///
			 (rcap ci_upper ci_lower year, lcolor(blue)), ///
			 yline(0, lcolor(grey) lpattern(shortdash))  ///
			 text(2 1956 "Panel D: Entrepreneur", place(n)) legend(off) ///
			 ytitle("Coef.of CR Intensity*Birth Cohort") ///
			 xlabel(1936 1941 1946 1951 1956 1961 1966 1971 1976,labsize(small)) ///
			 ylabel(-6(1)3,labsize(small)) ///
			 xtitle("Birth Cohort") scheme(s1mono)							

graph export "$MainDir/data/results/1931-35_base/lab_gdid_5y_4of4.png", replace

