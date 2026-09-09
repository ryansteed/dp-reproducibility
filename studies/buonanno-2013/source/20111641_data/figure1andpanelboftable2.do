/*This file reads in data on the national prison population, creates figure 1 in the text,
estimates the regression models in Panel B of Table 2, and then generates the post-pardon changes in prison
along the dynamic adjusment path that serve as inputs for the incapacitaiton effect estimates in tables 3 and 5.
The file "prisonertimeseries.dta" contains national monthly data that varies from 2004 through 2008.  Included in this
file are the variables
ymonthrelative - a variable measuring month relative to August 2006 (set to zero for August 2006)
prisoners - total prison population for the monht
population - annual population (does not vary within year)
incrate - the number of prisoners per 100,000
month - a variable indicating calender month
year - a variable measureing year*/ 

clear all
set more off
set mem 500m
set matsize 1000
/*change following directory to wherever your data is stored*/
*** EDIT by Donna Zhu
cd "."
log using prisonfirststage, replace
use prisonertimeseries2
/*generating quadratic trend term, a dummy variable for the post-pardon period, and interaction terms*/
gen ymonthrelative2=ymonthrelative*ymonthrelative
gen post=ymonthrelative>0
gen postmonth=post*ymonthrelative
gen postmonth2=post*ymonthrelative2

/*generating figure 1*/ 
twoway  qfitci incrate ymonthrelative if ymonthrelative<=0, legend(off) || qfitci incrate ymonthrelative if ymonthrelative>0 ||scatter incrate ymonthrelative, xline(0) legend(off)  yscale(r(0 110)) ylabel(0(10)110)  ytitle("Monthly Incarceration Rate") xtitle("Month Relative to August 2006")



/*generating the regression results in Table 2, Panel B and the denominators for the incapacitation effect estimates
presented in Tables 3 and 5*/

tsset ymonthrelative
reg incrate ymonthrelative ymonthrelative2 post postmonth postmonth2
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*6+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*12+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*18+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*24+1)

xi: reg incrate ymonthrelative ymonthrelative2 post postmonth postmonth2 i.month
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*6+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*12+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*18+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*24+1)

xi: reg incrate ymonthrelative ymonthrelative2 post postmonth postmonth2 i.month i.year  
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*6+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*12+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*18+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*24+1)
 
eststo: xi: arima  incrate ymonthrelative ymonthrelative2 post postmonth postmonth2 i.month i.year, ar(1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*6+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*12+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*18+1)
lincom ymonthrelative+postmonth+(ymonthrelative2+postmonth2)*(2*24+1)

*** EDIT by Donna Zhu
estout using "../../results/table2b.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
log close
