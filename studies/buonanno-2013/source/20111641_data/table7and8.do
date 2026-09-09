/*this file produces all of our province level results.  It creates crime rates
for each province and measures of average crime rates before and after the pardon for the
time periods specified in the paper.  The file also tests for diminishing returns to
scale in incarceration. The file first reads the raw monthluy data file "monthly_data_0408"
into the program and creates province level crime rates. The file also adds data on the
total number of pardons for each province through December 2006 as well as a variable 
measuring the province-level incarceration rate prior to the pardon*/

clear all
set more off
set mem 500m
set matsize 1000

/*change the following directory to wherever you are storing the data*/
*** EDIT by Donna
cd "."


/*following commands sort the pardons-by-province and province population file
by codes used later for matching to crime rates*/


use pardonsbyprovince
sort idprov
save pardonsbyprovince, replace
use population
sort idprov year
save population, replace

use monthly_data_0408.dta
/*restricting data set to major categories*/
keep if crimeid==1|crimeid==2|crimeid==3|crimeid==7|crimeid==8|crimeid==12|crimeid==13|crimeid==16|crimeid==17|crimeid==18|crimeid==19|crimeid==20|crimeid==25|crimeid==26|crimeid==27|crimeid==39|crimeid==40|crimeid==50|crimeid==51|crimeid==52|crimeid==55|crimeid==56|crimeid==57|crimeid==58|crimeid==59|crimeid==61|crimeid==62|crimeid==63|crimeid==64|crimeid==69|crimeid==74|crimeid==75|crimeid==76|crimeid==77|crimeid==78

/*code into 11 larger crime categories*/
gen crecode=.
replace crecode=1 if crimeid==1|crimeid==2|crimeid==3|crimeid==7|crimeid==8|crimeid==12 |crimeid==13 |crimeid==16|crimeid==17|crimeid==18|crimeid==19/*violence less sexual assault*/
replace crecode=2 if crimeid==20|crimeid==25|crimeid==26 /*sexual assault/corruption of a minor*/
replace crecode=3 if crimeid==27|crimeid==39 /*theft/recieving stolen property*/
replace crecode=4 if crimeid==40 /*robbery*/
replace crecode=5 if crimeid==50|crimeid==51|crimeid==57  /*extortion/usury/money laundering*/
replace crecode=6 if crimeid==52 /*kidnapping*/
replace crecode=7 if crimeid==59 /*arson*/
replace crecode=8 if crimeid==61|crimeid==62 /*property damage*/
replace crecode=9 if crimeid==63|crimeid==64 /*contraband/drugs*/
replace crecode=10 if crimeid==69 /*soliciting a prostititue*/
replace crecode=11 if crimeid==55|crimeid==56|crimeid==58|crimeid==74|crimeid==75|crimeid==76|crimeid==77/*associating with a delinquent/assocaiting with a mafiosa/information fraud/information crime/counterfeit products/intellectual property crime/other crime*/
replace crecode=12 if crimeid==78 /*total reported crimes*/
keep if crecode ~=.
/*restict the data to monthly data for 2006 and 2007*/
keep if year>2005
keep if year<2008
/*creat a year-month variables, August 2006 equals 8*/
gen ymonth=.
replace ymonth=1 if year==2006 &month==1
replace ymonth=2 if year==2006 &month==2
replace ymonth=3 if year==2006 &month==3
replace ymonth=4 if year==2006 &month==4
replace ymonth=5 if year==2006 &month==5
replace ymonth=6 if year==2006 &month==6
replace ymonth=7 if year==2006 &month==7
replace ymonth=8 if year==2006 &month==8
replace ymonth=9 if year==2006 &month==9
replace ymonth=10 if year==2006 &month==10
replace ymonth=11 if year==2006 &month==11
replace ymonth=12 if year==2006 &month==12
replace ymonth=13 if year==2007 &month==1
replace ymonth=14 if year==2007 &month==2
replace ymonth=15 if year==2007 &month==3
replace ymonth=16 if year==2007 &month==4
replace ymonth=17 if year==2007 &month==5
replace ymonth=18 if year==2007 &month==6
replace ymonth=19 if year==2007 &month==7
replace ymonth=20 if year==2007 &month==8
replace ymonth=21 if year==2007 &month==9
replace ymonth=22 if year==2007 &month==10
replace ymonth=23 if year==2007 &month==11
replace ymonth=24 if year==2007 &month==12
sort idprov year ymonth crecode

/*collapse crime data into larger sub-categories that we employ
throughout the analysis*/
collapse(sum) crime_number, by(idprov year ymonth crecode)
sort idprov ymonth
save regionnational, replace

/*merge to pardons and pre-pardon prison totals variables*/
merge idprov using pardonsbyprovince
sort idprov ymonth
drop _merge
 

save regionnational, replace
sort idprov year

/*merge in province population variable*/
merge idprov year using population
keep if _merge==3

/*create crime rate, pardons per 100,000 and pre-pardon incarceration rate per 100,000*/
gen crate=crime_number/population*100000
gen pardonrate=pardoned/population*100000
gen incrate=prisoner_jail/population*100000
save regionnational, replace
clear all


/*the following routine generates the LATE results for provinces overall.  Teh 
coefficients on pardonrate as well as standard errors must be multiplied by 12
to match the annualized estimates reported in the paper*/

log using crossregional, replace
***EDIT by Donna
local crimes "1 2 3 4 5 6 7 8 9 10 11 12"
foreach val of local crimes {
use regionnational
keep if crecode==`val'
tab crecode
keep if ymonth== 7 | ymonth==9
tsset idprov ymonth
gen cdiff2= crate-l2.crate
eststo: reg cdiff2 pardonrate [aweight=population]
estout using "../../results/table6.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
clear all

use regionnational
keep if crecode==`val'
keep if ymonth==6|ymonth==7|ymonth==9|ymonth==10
gen after=ymonth>8
sort idprov after
collapse (mean) crate pardonrate population, by(idprov after)
tsset idprov after
gen cdiff2= crate-l.crate
reg cdiff2 pardonrate [aweight=population]
clear all

use regionnational
keep if crecode==`val'
keep if ymonth==5 |ymonth==6|ymonth==7|ymonth==9|ymonth==10|ymonth==11
gen after=ymonth>8
sort idprov after
collapse (mean) crate pardonrate population, by(idprov after)
tsset idprov after
gen cdiff2= crate-l.crate
reg cdiff2 pardonrate [aweight=population]
clear all

use regionnational
keep if crecode==`val'
keep if ymonth==4 | ymonth==5 |ymonth==6|ymonth==7|ymonth==9|ymonth==10|ymonth==11|ymonth==12
gen after=ymonth>8
sort idprov after
collapse (mean) crate pardonrate population, by(idprov after)
tsset idprov after
gen cdiff2= crate-l.crate
reg cdiff2 pardonrate [aweight=population]
clear all
}

log close

/*the following routine generates the results for our tests for diminshing returns to scale*/
 
log using crossregional2, replace
clear all
use regionnational
keep if crecode==12
keep if ymonth==6|ymonth==7|ymonth==9|ymonth==10
gen after=ymonth>8
sort idprov after
collapse (mean) crate pardonrate population incrate, by(idprov after)
tsset idprov after
gen cdiff2= crate-l.crate
gen pardonincrate=pardonrate*l.incrate
reg cdiff2 pardonrate [aweight=population]
reg cdiff2 pardonrate l.incrate l.crate [aweight=population]
eststo: reg cdiff2 pardonrate pardonincrate l.incrate l.crate [aweight=population]

lincom pardonrate+32.46019*pardonincrate
lincom pardonrate+58.86092*pardonincrate
lincom pardonrate+100.1021*pardonincrate
lincom pardonrate+160.0622*pardonincrate
lincom pardonrate+191.9295*pardonincrate

*** EDIT by Donna Zhu
estout using "../../results/table7.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace


gen above=incrate>100.1021
reg cdiff2 pardonrate [aweight=population] if above==0
reg cdiff2 pardonrate [aweight=population] if above==1


reg cdiff2 pardonrate l.crate l.incrate [aweight=population] if above==0
reg cdiff2 pardonrate l.crate l.incrate [aweight=population] if above==1


gen pardonrateabove=pardonrate*above
gen lcrateabove=l.crate*above
gen lincrateabove=l.incrate*above
reg cdiff2 pardonrate pardonrateabove l.crate lcrateabove l.incrate lincrateabove [aweight=population]
log close
