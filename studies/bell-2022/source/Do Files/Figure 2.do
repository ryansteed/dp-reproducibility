*** Directory ***
cd "C:\Users\ruimv\\`=c(username)'\Working Files\Male Crime\Replication\"




********************************************************************************

*********************            Figure 2            ***************************

********************************************************************************


clear all

set more off



* 1980

use "Data\Figures\maps_d.dta", clear
rename STATEFP bpl
destring bpl, replace
merge 1:m bpl using "Data\Figures\dropout_age_1980_2010.dta"
keep if year==1980
drop if _merge!=3
drop _merge
spmap dropage using "Data\Figures\maps_c.dta", id(id) clm(unique) fcolor(Greys2) ndfcolor(white ..) ocolor(white ..) moc(white ..) ndo(white ..)


clear


* 2010

use "Data\Figures\maps_d.dta", clear
rename STATEFP bpl
destring bpl, replace
merge 1:m bpl using "Data\Figures\dropout_age_1980_2010.dta"
keep if year==2010
drop if _merge!=3
drop _merge
spmap dropage using "Data\Figures\maps_c.dta", id(id) clm(unique) fcolor(Greys2) ndfcolor(white ..) ocolor(white ..) moc(white ..) ndo(white ..)
