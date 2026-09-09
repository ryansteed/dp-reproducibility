/*this file merge monthly prison data to monthly national crime rates.  The file then estimates the regression models in
panel A of table 2 and in Table 4.  The file also generates the changes in crime along the post-pardon dynamic adjustment path
needed to generate some of the incapacitation effect estimates in Tables 3 and 5.  Finally, the file
generates IV estimates of the incapacitaiton effects using the discrete break in the prison time series in August 2006*/

clear all
set more off
set mem 500m
set matsize 1000
*** EDIT by Donna
cd "."

/*following lines merge the national prison times series and national crime time series data sets*/
use prisonertimeseries2 
sort ymonthrelative
save prisonertimeseries2, replace

log using rdregressionouput, replace
use monthnational0408
sort ymonthrelative
merge ymonthrelative using prisonertimeseries2
sort crecode ymonthrelative


gen post=ymonthrelative>0
gen postymonth=post*ymonthrelative
gen postymonth2=post*ymonthrelative2


/*
The following code estimates the regression models presents in Table 2 panel A and table 4.  The code
also estimates IV estimates of the incapacitation effects using the discrete break in the prison and crime time series at
August 2006.  The codes of the variable measuring the type of crime in the national level data
are

crecode values
12 - total crime
1 -  non-sexual violent crime
2 -  sexual assault/corruption of a minor
3 -  theft/receiving stolen property
4 -  robbery
5 -  extortion/usury/money laundering
6 -  kidnapping
7 -  Arson
8 -  Vandalism/property damage
9 -  Drugs/controband
10 - soliciting of prostitution
11-  associating with a delinquent/assocaiting with a mafiosa/information fraud/information crime/counterfeit products/intellectual property crime/other crime

these values are used in the foreach loop to estimate the regression models and the needed post-pardon changes.  The final
few lines of the foreach loop estimate the IV models.
*/

local crimes "12 1 2 3 4 5 6 7 8 9 10 11"
sort crecode ymonthrelative
tsset crecode ymonthrelative
foreach val of local crimes {  
tab crecode if crecode==`val'
eststo: reg crime2 ymonthrelative ymonthrelative2 post postymonth postymonth2 if crecode==`val'
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*6+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*12+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*18+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*24+1)
eststo: xi: reg crime2 ymonthrelative ymonthrelative2 post postymonth postymonth2 i.month if crecode==`val'
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*6+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*12+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*18+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*24+1)
eststo: xi: reg crime2 ymonthrelative ymonthrelative2 post postymonth postymonth2 i.month i.year if crecode==`val' 
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*6+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*12+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*18+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*24+1)
eststo: xi: arima  crime2 ymonthrelative ymonthrelative2 post postymonth postymonth2 i.month i.year if crecode==`val', ar(1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*6+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*12+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*18+1)
lincom ymonthrelative+postymonth+(ymonthrelative2+postymonth2)*(2*24+1)
eststo: ivreg crime2 (incrate=post) ymonthrelative ymonthrelative2 postymonth postymonth2 if crecode==`val'
eststo: xi: ivreg crime2 (incrate=post) ymonthrelative ymonthrelative2 postymonth postymonth2 i.month if crecode==`val'
eststo: xi: ivreg crime2 (incrate=post) ymonthrelative ymonthrelative2 postymonth postymonth2 i.month i.year if crecode==`val'
}
*** EDIT by Donna Zhu
estout using "../../results/table2a.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*** EDIT by Donna Zhu
capture log close