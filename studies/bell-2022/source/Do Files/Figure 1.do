*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"



********************************************************************************

*********************            Figure 1            ***************************

********************************************************************************


clear all
set more off

use "Data\Figures\Figure_1_data.dta", clear 


bysort agegroup (crime): gen cumulative_arrest=sum( arrest_rate)
replace cumulative_arrest= cumulative_arrest*1000

replace agegroup=26 if agegroup==30
replace agegroup=27 if agegroup==35

# delimit ;
tw	bar cumulative_arrest agegroup if crime_type==3, color(gs10) barwidth(0.8) fintensity(80) ||
	bar cumulative_arrest agegroup if crime_type==2, color(gs4) barwidth(0.8) fintensity(80) ||
	bar cumulative_arrest agegroup if crime_type==1, color(black) barwidth(0.8) fintensity(80)
	graphregion(color(white))
	ylab(0(20)100,nogrid angle(horizontal))
	xlab(15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25-29" 26 "30-34" 27 "35-39", labsize(small) labgap(1) )
	ytitle("Rate Per 1000 Population", size(medsmall))
	xtitle("Age", size(medsmall))
	legend( rows(1) cols(3) label(1 "Drugs") label(2 "Property") label(3 "Violent") region(lcolor(white)) );	
#d cr
