*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication"



********************************************************************************

***********************            Figure 6            *************************

********************************************************************************




clear all
clear matrix
set more off



* Estimates directly from Table 5

do "Do Files\Table 5.do"

clear



* Saved results in "Figures_5_6_data.dta"

use "Data\Figures\Figures_5_6_data.dta", clear



gen arrest_rate_base=exp( base_age)
gen arrest_rate_new=exp( base_age+ b_age)




***TOTAL

#delimit ;
tw	bar arrest_rate_base age if crime==4, color(black) barwidth(0.8) fintensity(90) || 
	bar arrest_rate_new age if crime==4, color(gs10) barwidth(0.7) fintensity(90) 
	legend( label(1 "Prior Arrest Rate") label(2 "Post Arrest Rate") region(lcolor(white)) ) 
	graphregion(color(white)) bgcolor(white)
	xlab(15(1)24)  
	ylab(0.040(0.020)0.120, nogrid angle(horizontal)) 
	ytitle("Estimated Arrest Rates", size(medsmall)) 
	xtitle("Age", size(medsmall)) 
	title("Total", color(black) size(medlarge));
#d cr



***VIOLENT


#delimit ;
tw 	bar arrest_rate_base age if crime==1, color(black) barwidth(0.8) fintensity(90) || 
	bar arrest_rate_new age if crime==1, color(gs10) barwidth(0.7) fintensity(90) 
	legend( label(1 "Prior Arrest Rate") label(2 "Post Arrest Rate") region(lcolor(white)) ) 
	graphregion(color(white)) bgcolor(white)
	xlab(15(1)24) 
	ylab(0(0.008)0.032, nogrid angle(horizontal)) 
	ytitle("Estimated Arrest Rates", size(medsmall)) 
	xtitle("Age", size(medsmall)) 
	title("Violent", color(black) size(medlarge));
#d cr





***PROPERTY


#delimit ;
tw 	bar arrest_rate_base age if crime==2, color(black) barwidth(0.8) fintensity(90) || 
	bar arrest_rate_new age if crime==2, color(gs10) barwidth(0.7) fintensity(90) 
	legend( label(1 "Prior Arrest Rate") label(2 "Post Arrest Rate") region(lcolor(white)) ) 
	graphregion(color(white)) bgcolor(white) 
	xlab(15(1)24)  
	ylab(0(0.015)0.060, nogrid angle(horizontal)) 
	ytitle("Estimated Arrest Rates", size(medsmall)) 
	xtitle("Age", size(medsmall)) 
	title("Property", color(black) size(medlarge));
#d cr



***DRUGS

#delimit ;
tw 	bar arrest_rate_base age if crime==3, color(black) barwidth(0.8) fintensity(90) || 
	bar arrest_rate_new age if crime==3, color(gs10) barwidth(0.7) fintensity(90) 
	legend( label(1 "Prior Arrest Rate") label(2 "Post Arrest Rate") region(lcolor(white)) ) 
	graphregion(color(white)) bgcolor(white) 
	xlab(15(1)24)  
	ylab(0.000(0.009)0.036, nogrid angle(horizontal)) 
	ytitle("Estimated Arrest Rates", size(medsmall)) 
	xtitle("Age", size(medsmall)) 
	title("Drugs", color(black) size(medlarge));
#d cr



