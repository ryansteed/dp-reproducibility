/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates Fig B1, which shows annual adjustments by the state 
legislature to per-pupil revenue limits.

DATA INPUTS: (1) Adjustment History
OUTPUT: Figure B1
*********************************/
**Set Globals
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"

*Clear and import dataset on state allowable revenue limit adjustments
clear
import excel using "${path}\Data\Intermediate\adjustment_history.xls", firstrow 

*Clean up and make bar graph
*Rename variables of interest
rename Year school_year
rename PerPupilRevenueLim adjustment

*Take only first four digits of year variable
replace school_year = substr(school_year,1,4)

*Take only first four digits of adjustment
*For 1993 and 1994, school districts could do adjustment of inflation rate CPI, whichever was largest
replace adjustment = substr(adjustment,1,7)

*Get rid of dollar signs
replace adjustment = subinstr(adjustment,"$","",.)
drop if adjustment==""
keep school_year adjustment

*Destring variables
destring adjustment, replace
destring school_year, replace

*Round up to nearest whole number
replace adjustment = round(adjustment)

*Bar chart
twoway (bar adjustment school_year, barw(0.5) ///
legend(off) plotregion(margin(zero)))(scatter adjustment school_year if school_year!=2011, ytitle(Adjustment to Revenue Limits) ///
bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white) ifcolor(white)) ///
plotregion(lcolor(none) ilcolor(white) style(none)) yscale(range(-620(200)620)) ///
ytitle(Adjustment to Revenue Limits ($)) ylabel(-600 "-600" -400 "-400" -200 "-200" 0 "0" 200 "200" 400 "400" 600 "600") ///
xtitle(Academic Year) mlabel(adjustment) mlabposition(12) mlabangle(60) mlabsize(vsmall) msize(vsmall) ///
mlabcolor(black) mcolor(black) mlabgap(2)) (scatter adjustment school_year if school_year ==2011 ///
, mlabel(adjustment) mlabposition(12) mlabangle(60) mlabsize(vsmall) msize(vsmall) mlabgap(-3.5) ///
mlabcolor(black) mcolor(black))
graph export "${path}\Output\revlimadjustment.pdf", replace

