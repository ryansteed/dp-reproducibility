*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication"



********************************************************************************

***********************            Figure 5            *************************

********************************************************************************





clear all
clear matrix
set more off



* Estimates directly from Table 5

do "Do Files\Table 5.do"

clear

* Saved results in "Figures_5_6_data.dta"

use "Data\Figures\Figures_5_6_data.dta", clear




***TOTAL

#delimit ;

tw 	rcap b_age_low b_age_upper age if crime==4, lcolor(black) ||
	scatter b_age age if crime==4, color(black) 
	xlab(15(1)24) 
	ylab(, nogrid angle(horizontal))
	graphregion(color(white)) bgcolor(white) 
	yline(0, lcolor(black))
	legend(off) 
	xtitle("Age", size(medsmall)) 
	ytitle("Reform Effect", size(medsmall))
	title("Total", color(black) size(medlarge));
#d cr




***VIOLENT

#delimit ;

tw	rcap b_age_low b_age_upper age if crime==1, lcolor(black) ||
	scatter b_age age if crime==1, color(black) 
	xlab(15(1)24) 
	ylab(, nogrid angle(horizontal)) 
	graphregion(color(white)) bgcolor(white)
	yline(0, lcolor(black)) 
	legend(off) 
	xtitle("Age", size(medsmall)) 
	ytitle("Reform Effect", size(medsmall))  
	title("Violent", color(black) size(medlarge));
#d cr






***PROPERTY

#delimit ;
tw 	rcap b_age_low b_age_upper age if crime==2, lcolor(black) || 
	scatter b_age age if crime==2, color(black) 
	xlab(15(1)24) 
	ylab(, nogrid angle(horizontal)) 
	graphregion(color(white)) bgcolor(white) legend(off)
	yline(0, lcolor(black)) 
	xtitle("Age", size(medsmall)) 
	ytitle("Reform Effect", size(medsmall)) 
	title("Property", color(black) size(medlarge));
#d cr




***DRUGS

#delimit ;
tw 	rcap b_age_low b_age_upper age if crime==3, lcolor(black) || 
	scatter b_age age if crime==3, color(black) 
	xlab(15(1)24) 
	ylab(, nogrid angle(horizontal)) 
	graphregion(color(white)) bgcolor(white) legend(off) 
	yline(0, lcolor(black)) 
	xtitle("Age", size(medsmall)) 
	ytitle("Reform Effect", size(medsmall)) 
	title("Drugs", color(black) size(medlarge));
#d cr



