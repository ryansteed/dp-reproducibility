/*This file reads in monthyl crime data by provence, created a national level data set, and creates a subset of crime
categories that are used throughout the paper as dependent variables.  The file also generates the content of table
1 and figure 2*.  the data set monthy_data_0408.dta varies at the provence-crime categry level.  Each record shows the
Italian region, provence, crime category (using a numeric code), crimes total, year month, and a descriptive field in 
Italian describing the crime sub category*/
clear all
set more off
set mem 500m
set matsize 1000
/*change following directory to wherever your are storing the data*/
*** EDIT by Donna Zhu
cd "."
use monthly_data_0408.dta
/*restricting data set to major categories. These categories are cumulative totals for various subcategories included in the data*/
keep if crimeid==1|crimeid==2|crimeid==3|crimeid==7|crimeid==8|crimeid==12|crimeid==13|crimeid==16|crimeid==17|crimeid==18|crimeid==19|crimeid==20|crimeid==25|crimeid==26|crimeid==27|crimeid==39|crimeid==40|crimeid==50|crimeid==51|crimeid==52|crimeid==55|crimeid==56|crimeid==57|crimeid==58|crimeid==59|crimeid==61|crimeid==62|crimeid==63|crimeid==64|crimeid==69|crimeid==74|crimeid==75|crimeid==76|crimeid==77|crimeid==78 /*non-sexual violent crime*/

/*code into 11 larger crime categories.  See noted next to code for crime definition*/
gen crecode=.
replace crecode=1 if crimeid==1|crimeid==2|crimeid==3|crimeid==7|crimeid==8|crimeid==12 |crimeid==13 |crimeid==16|crimeid==17|crimeid==18|crimeid==19/*violence less sexual assault*/
replace crecode=2 if crimeid==20|crimeid==25|crimeid==26 /*sexual assault/corruption of a minor*/
replace crecode=3 if crimeid==27|crimeid==39 /*theft/recieving stolen property*/
replace crecode=4 if crimeid==40 /*robbery*/
replace crecode=5 if crimeid==50|crimeid==51|crimeid==57  /*extortion/usury/money laundering*/
replace crecode=6 if crimeid==52 /*kidnapping*/
replace crecode=7 if crimeid==59 /*arson*/
replace crecode=8 if crimeid==61|crimeid==62 /*vandalism/property damage*/
replace crecode=9 if crimeid==63|crimeid==64 /*contraband/drugs*/
replace crecode=10 if crimeid==69 /*soliciting a prostititue*/
replace crecode=11 if crimeid==55|crimeid==56|crimeid==58|crimeid==74|crimeid==75|crimeid==76|crimeid==77/*associating with a delinquent/assocaiting with a mafiosa/information fraud/information crime/counterfeit products/intellectual property crime/other crime*/
replace crecode=12 if crimeid==78 /*total reported crimes*/
keep if crecode ~=.

/*collapse to nation-month level*/
sort year month crecode
collapse (sum) crime_number, by(year month crecode)

/*setting annual national population by year*/
gen pop=.
replace pop=58462375 if year==2004
replace pop=58751711 if year==2005
replace pop=58691139 if year==2006
replace pop=59175633 if year==2007
replace pop=59832200 if year==2008
/*generating crime rate and year/month variable*/
gen crime2=crime_number/pop*100000
gen ymonth=ym(year, month)
/*generating year month relative to august 2006 (August 2006 equal to 559 in variable ymonth)
also generating quadratic time trend term*/
gen ymonthrelative=ymonth-559
gen ymonthrelative2=ymonthrelative*ymonthrelative


save monthnational0408, replace

tabulate crecode year, summarize(crime2) mean /*figures for table 1 showing the distribution of offenses by type and year*/



/*creating discountinuity graphs:  each graph shows a scatter of the data and quadratic functions fit up to August 2006 and after. The shaded areas are 95% confidence intervals for the prediction*/

twoway  qfitci crime2 ymonthrelative if crecode==12 & ymonthrelative<=0, legend(off) || qfitci crime2 ymonthrelative if crecode==12 & ymonthrelative>0 ||scatter crime2 ymonthrelative if crecode==12, xline(0) legend(off) ytitle("Crimes per 100,000") xtitle("Month Relative to August 2006")
 
