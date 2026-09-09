
/*
* PURPOSE: Identity during a Crisis: COVID-19 and Ethnic Divisions in the United States - Replication Figures
* Data Source: Master_data_covid_EHI.dta
* AUTHORs: Jakina Debnam Guzman, Marie Christelle Mabeu, and Roland Pongou
DATE: 2022 January, 12
*/

*---------------------------------------------------------------------------*
*				 			SET YOUR DIRECTORY 	
*--------------------------------------------------------------------------*	
global CovidAndEthnic "YOUR DIRECTORY"

clear all 
set maxvar 32767
set matsize 10000

*---------------------------------------------------------------------------*
*				 			FIGURE 1
*--------------------------------------------------------------------------*

cd "${CovidAndEthnic}/"
use Master_data_covid_EHI.dta, clear

gen time= date2- county_lockdown_date 

xtile median_EHI = EHI, nq(2)
lab var median_EHI "Median of EFI"
label define median_EHI 1 "Low EFI" 2 "High EFI", replace

foreach y of varlist new_case new_death   {
bys time: egen mean_`y'_highEHI=mean(`y') if median_EHI==2
bys time: egen mean_`y'_lowEHI=mean(`y') if median_EHI==1

}

drop if time <-80 | time>80 

foreach y of varlist new_case  {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
title("All counties", color(red) justification(center)) ///
subtitle("(a) COVID-19 new cases", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(10)60) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'.gph" , replace 
}

foreach y of varlist new_death {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
title("(b) COVID-19 new deaths", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(0.5)3.5) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'.gph" , replace 
}



*---------------------------------------------------------------------------*
*				 			FIGURE 1 - Heterogeneity
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

xtile median_w = seg_index, nq(2)
lab var median_w "Median of White vs non-White racial residential segregation"
label define median_w 1 "Low W-NW res seg." 2 "High W-NW res seg.", replace

gen time= date2- county_lockdown_date 

xtile median_EHI = EHI, nq(2)
lab var median_EHI "Median of EFI"
label define median_EHI 1 "Low EFI" 2 "High EFI", replace

foreach median of varlist median_w {

foreach x of numlist  1 {
preserve 
keep if `median'==`x'

foreach y of varlist new_case new_death  {
bys time: egen mean_`y'_highEHI=mean(`y') if median_EHI==2
bys time: egen mean_`y'_lowEHI=mean(`y') if median_EHI==1

}

drop if time <-80 | time>80 

foreach y of varlist new_case {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
title("Low W-NW Residential Segregation", color(red) justification(center)) ///
subtitle("(c) COVID-19 new cases", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(10)60) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}


foreach y of varlist new_death {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
subtitle("(d) COVID-19 new deaths", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(0.5)3.5) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}

restore
}
}

foreach median of varlist median_w {

foreach x of numlist  2 {
preserve 
keep if `median'==`x'

foreach y of varlist new_case new_death  {
bys time: egen mean_`y'_highEHI=mean(`y') if median_EHI==2
bys time: egen mean_`y'_lowEHI=mean(`y') if median_EHI==1

}

drop if time <-80 | time>80 

foreach y of varlist new_case {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
title("High W-NW Residential Segregation", color(red) justification(center)) ///
subtitle("(e) COVID-19 new cases", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(10)60) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}


foreach y of varlist new_death {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
subtitle("(f) COVID-19 new deaths", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(0.5)3.5) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}

restore
}
}

*---------------------------------------------------------------------------*
*				 			FIGURE 1
*--------------------------------------------------------------------------*

**Figure 1: CSOE, ethnic fragmentation, ethnic divisions and COVID-19
graph combine Trendbygroup_new_case.gph Trendbygroup_new_case_1_median_w.gph Trendbygroup_new_case_2_median_w.gph Trendbygroup_new_death.gph  Trendbygroup_new_death_1_median_w.gph Trendbygroup_new_death_2_median_w.gph, ///
graphregion(color(white))  ysize(1) xsize(2) cols(3)
qui graph save "figure1.gph" , replace
graph export "figure1.png" , as(png) width(2000) replace
graph export "figure1.eps" , replace



*---------------------------------------------------------------------------*
*				 			FIGURE A1
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

gen time= date2- county_lockdown_date 

xtile median_w = seg_index, nq(2)
lab var median_w "Median of White vs non-White racial residential segregation"
label define median_w 1 "Low W-NW res seg." 2 "High W-NW res seg.", replace

foreach y of varlist new_case new_death  {
bys time: egen mean_`y'_highRS=mean(`y') if median_w==2
bys time: egen mean_`y'_lowRS=mean(`y') if median_w==1
}

drop if time <-80 | time>80 

foreach y of varlist new_case {
twoway line mean_`y'_lowRS time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highRS time, lwidth(medthick) lcolor(orange) ///
title("(a) COVID-19 new cases", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(10)40) ///
legend( label(1 "Low W-NW res seg.") label(2 "High W-NW res seg.") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_RS_W.gph" , replace 
}

foreach y of varlist  new_death{
twoway line mean_`y'_lowRS time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highRS time, lwidth(medthick) lcolor(orange) ///
title("(b) COVID-19 new deaths", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(0.5)3) ///
legend( label(1 "Low W-NW res seg.") label(2 "High W-NW res seg.") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_RS_W.gph" , replace 
}

*---------------------------------------------------------------------------*
*				 			FIGURE A1
*--------------------------------------------------------------------------*

**Figure A1: COVID-19 and county-level emergency declaration by level of White/non-White residential segregation 
graph combine Trendbygroup_new_case_RS_W.gph Trendbygroup_new_death_RS_W.gph, ///
graphregion(color(white))  ysize(1) xsize(2) cols(2)
qui graph save "figureA1.gph" , replace
graph export "figureA1.png" , as(png) width(2000) replace
graph export "figureA1.eps" ,  replace



*---------------------------------------------------------------------------*
*				 			FIGURE A2
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

gen time= date2- county_lockdown_date 

xtile median_bw = seg_index_bw, nq(2)
lab var median_bw "Median of Black-White racial residential segregation"
label define median_bw 1 "Low B-W res seg." 2 "High B-W res seg.", replace

foreach y of varlist new_case new_death  {
bys time: egen mean_`y'_highRS=mean(`y') if median_bw==2
bys time: egen mean_`y'_lowRS=mean(`y') if median_bw==1
}

drop if time <-80 | time>80 

foreach y of varlist new_case {
twoway line mean_`y'_lowRS time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highRS time, lwidth(medthick) lcolor(orange) ///
title("(a) COVID-19 new cases", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(10)40) ///
legend( label(1 "Low B-W res seg.") label(2 "High B-W res seg.") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_RS_BW.gph" , replace 
}

foreach y of varlist  new_death{
twoway line mean_`y'_lowRS time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highRS time, lwidth(medthick) lcolor(orange) ///
title("(b) COVID-19 new deaths", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(0.5)3) ///
legend( label(1 "Low B-W res seg.") label(2 "High B-W res seg.") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_RS_BW.gph" , replace 
}

*---------------------------------------------------------------------------*
*				 			FIGURE A2
*--------------------------------------------------------------------------*

**Figure A2: COVID-19 and county-level emergency declaration by level of Black/White residential segregation 
graph combine Trendbygroup_new_case_RS_BW.gph Trendbygroup_new_death_RS_BW.gph, ///
graphregion(color(white))  ysize(1) xsize(2) cols(2)
qui graph save "figureA2.gph" , replace
graph export "figureA2.png" , as(png) width(2000) replace
graph export "figureA2.png" ,  replace



*---------------------------------------------------------------------------*
*				 			FIGURE A3
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

xtile median_bw = seg_index_bw, nq(2)
lab var median_bw "Median of Black-White racial residential segregation"
label define median_bw 1 "Low B-W res seg." 2 "High B-W res seg.", replace

gen time= date2- county_lockdown_date 

xtile median_EHI = EHI, nq(2)
lab var median_EHI "Median of EFI"
label define median_EHI 1 "Low EFI" 2 "High EFI", replace

foreach median of varlist median_bw {

foreach x of numlist  1 {
preserve 
keep if `median'==`x'

foreach y of varlist new_case new_death  {
bys time: egen mean_`y'_highEHI=mean(`y') if median_EHI==2
bys time: egen mean_`y'_lowEHI=mean(`y') if median_EHI==1

}

drop if time <-80 | time>80 

foreach y of varlist new_case {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
title("Low B-W Residential Segregation", color(red) justification(center)) ///
subtitle("(a) COVID-19 new cases", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(10)60) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}


foreach y of varlist new_death {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
subtitle("(c) COVID-19 new deaths", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(0.5)5.5) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}

restore
}
}

foreach median of varlist median_bw {

foreach x of numlist  2 {
preserve 
keep if `median'==`x'

foreach y of varlist new_case new_death  {
bys time: egen mean_`y'_highEHI=mean(`y') if median_EHI==2
bys time: egen mean_`y'_lowEHI=mean(`y') if median_EHI==1

}

drop if time <-80 | time>80 

foreach y of varlist new_case {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
title("High B-W Residential Segregation", color(red) justification(center)) ///
subtitle("(b) COVID-19 new cases", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(10)60) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}


foreach y of varlist new_death {
twoway line mean_`y'_lowEHI time, lwidth(medthick) lpattern(dash) lcolor(green) || ///
line mean_`y'_highEHI time, lwidth(medthick) lcolor(orange) ///
subtitle("(d) COVID-19 new deaths", justification(center)) ///
xtitle("Day to county emergency declaration") ///
xline(0, lcolor(blue) lpattern(solid)) ///
xlabel(-80(20)80) ///
ylabel(0(0.5)5.5) ///
legend( label(1 "Low EFI") label(2 "High EFI") cols(2) ) ///
graphregion(color(white)) 
qui graph save "Trendbygroup_`y'_`x'_`median'.gph" , replace 
}

restore
}
}

*---------------------------------------------------------------------------*
*				 			FIGURE A3
*--------------------------------------------------------------------------*

**Figure A3: COVID-19 and county-level emergency declaration by level of ethnic fragmentation and level of Black/White residential segregation
graph combine Trendbygroup_new_case_1_median_bw.gph Trendbygroup_new_case_2_median_bw.gph Trendbygroup_new_death_1_median_bw.gph Trendbygroup_new_death_2_median_bw.gph, ///
graphregion(color(white))  ysize(1.5) xsize(2.5) scale(0.75)  cols(2)
qui graph save "figureA3.gph" , replace 
graph export "figureA3.png" , as(png) width(2000) replace
graph export "figureA3.eps" ,  replace



*---------------------------------------------------------------------------*
*				 			FIGURE A4
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

rename day_national_lockdown day_P1
rename day_county_lockdown day_P2

rename national_lockdown P1
rename county_lockdown P2

eststo clear
local clear

*gen area=density_2018/pop

*global controls "area male age poverty educ urban immig share"
global controls "density_2018 male age poverty educ urban immig"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"

set more off

foreach index of varlist  EHI {

foreach y of varlist new_case new_death{

foreach policy of varlist  P1 P2  {

qui postfile bskeep days beta_`y'_`policy' ci_l95_`y'_`policy' ci_u95_`y'_`policy' using fig_`y'_`policy'_dynamic, replace

foreach x of numlist  5(5)50 {


****Columns 5
eststo reg5_`x'_`y'_`policy': reghdfe `y'  i.`policy'##c.`index' if day_`policy'>=-`x' & day_`policy'<=`x', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 

	local cil95 = _b[1.`policy'#c.`index'] - _se[1.`policy'#c.`index']*invttail(25, 0.025)
	local ciu95 = _b[1.`policy'#c.`index'] + _se[1.`policy'#c.`index']*invttail(25, 0.025)
	post bskeep (`x') (_b[1.`policy'#c.`index']) (`cil95') (`ciu95')

}
qui postclose bskeep

}
}
}

use fig_new_case_P1_dynamic.dta, clear
sort days 
merge 1:1 days using fig_new_death_P1_dynamic.dta
drop _merge

merge 1:1 days using fig_new_case_P2_dynamic.dta
drop _merge

merge 1:1 days using fig_new_death_P2_dynamic.dta
drop _merge

save fig_new_dynamic, replace


*drop decileP1
gen daysP1=1
replace daysP1=daysP1[_n-1]+2 in 2/10
gen daysP2=daysP1+0.25


twoway (rcap ci_l95_new_case_P1 ci_u95_new_case_P1 daysP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_new_case_P1 daysP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_new_case_P2 ci_u95_new_case_P2 daysP2, lcolor(red)) /// code for 95% CI
(scatter  beta_new_case_P2 daysP2 , msize(1pt) mcolor(red)), ///
ytitle("Coef of the interaction between" "State of Emergency and EFI", size(small) justification(center)) ///
xtitle("Bandwidths (days before and after" "State of Emergency declaration)", size(small) justification(center)) /// 
xlabel( 1.25 "5" 3.25 "10" 5.25 "15" 7.25 "20" 9.25 "25" 11.25 "30" 13.25 "35" 15.25 "40" 17.25 "45" 19.25 "50" , noticks) ///
title("(a) COVID-19 new cases") yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "dynamic_new_case.gph" , replace 


twoway (rcap ci_l95_new_death_P1 ci_u95_new_death_P1 daysP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_new_death_P1 daysP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_new_death_P2 ci_u95_new_death_P2 daysP2, lcolor(red)) /// code for 95% CI
(scatter  beta_new_death_P2 daysP2 , msize(1pt) mcolor(red)), ///
title("(b) COVID-19 new deaths") ytitle("Coef of the interaction between" "State of Emergency and EFI", size(small) justification(center)) ///
xtitle("Bandwidths (days before and after" "State of Emergency declaration)", size(small) justification(center)) /// 
xlabel( 1.25 "5" 3.25 "10" 5.25 "15" 7.25 "20" 9.25 "25" 11.25 "30" 13.25 "35" 15.25 "40" 17.25 "45" 19.25 "50" , noticks) ///
yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "dynamic_new_death.gph" , replace 


*---------------------------------------------------------------------------*
*				 			FIGURE A4
*--------------------------------------------------------------------------*

**Figure A4: Dynamic of the effect of the interaction between emergency declarations and EFI on COVID-19 outcomes
graph combine dynamic_new_case.gph dynamic_new_death.gph, ///
graphregion(color(white))  ysize(1.5) xsize(2.5) cols(2)
qui graph save "figureA4.gph" , replace 
qui graph export "figureA4.png" , as(png)  width(2000) replace
qui graph export "figureA4.eps" , replace


*---------------------------------------------------------------------------*
*				 			FIGURE A5
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

set more off

** Indicator for counties with a state of emergency **
gen county_treat=1 
replace county_treat=0 if day_county_lockdown==.

***Create year-wise dummies for how many years have passed since emergency declaration***

foreach x of numlist  10(10)80 {

gen byte treat`x' = day_county_lockdown>=`x'-9 & day_county_lockdown<=`x' & county_treat == 1
}

foreach x of numlist  10(10)30 {

gen byte pre`x' = day_county_lockdown>=-`x' & day_county_lockdown<=-`x'+9 & county_treat == 1
}

gen byte pre0 = day_county_lockdown==0 & county_treat == 1

drop if day_county_lockdown>80

rename day_national_lockdown day_P1
rename day_county_lockdown day_P2

rename national_lockdown P1
rename county_lockdown P2

eststo clear
local clear

*gen area=density_2018/pop

*global controls "area male age poverty educ urban immig share"
global controls "density_2018 male age poverty educ urban immig"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"


set more off

foreach index of varlist  EHI {

foreach y of varlist  case   {

foreach policy of varlist  P2   {


****Columns 5
eststo reg5_`y'_`policy': reghdfe `y'   i.pre30##c.`index' i.pre20##c.`index' i.pre10##c.`index' i.pre0##c.`index' i.treat10##c.`index' i.treat20##c.`index' i.treat30##c.`index' i.treat40##c.`index' i.treat50##c.`index' i.treat60##c.`index' i.treat70##c.`index' i.treat80##c.`index', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 
}
}
}


foreach index of varlist  EHI {

qui postfile bskeep yr beta ci_l95 ci_u95 using event_study_case_county.dta, replace

/* Fill each cell for years before democratization */
foreach num of numlist 30(-10)0 { 
	local cil95 = _b[1.pre`num'#c.`index'] - _se[1.pre`num'#c.`index']*invttail(25, 0.025)
	local ciu95 = _b[1.pre`num'#c.`index'] + _se[1.pre`num'#c.`index']*invttail(25, 0.025)
	post bskeep (-`num') (_b[1.pre`num'#c.`index']) (`cil95') (`ciu95')
	}
/* Fill each cell for years after democratization */
foreach num of numlist 10(10)80 {
	local cil95 = _b[1.treat`num'#c.`index'] - _se[1.treat`num'#c.`index']*invttail(25, 0.025)
	local ciu95 = _b[1.treat`num'#c.`index'] + _se[1.treat`num'#c.`index']*invttail(25, 0.025)
	post bskeep (`num') (_b[1.treat`num'#c.`index']) (`cil95') (`ciu95')
	}
/* Save the Stata data file */
qui postclose bskeep
}


*****Deaths
eststo clear
local clear

set more off

foreach index of varlist  EHI {

foreach y of varlist  death   {

foreach policy of varlist  P2   {


****Columns 5
eststo reg5_`y'_`policy': reghdfe `y'   i.pre30##c.`index' i.pre20##c.`index' i.pre10##c.`index' i.pre0##c.`index' i.treat10##c.`index' i.treat20##c.`index' i.treat30##c.`index' i.treat40##c.`index' i.treat50##c.`index' i.treat60##c.`index' i.treat70##c.`index' i.treat80##c.`index', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 
}
}
}


foreach index of varlist  EHI {

qui postfile bskeep yr beta ci_l95 ci_u95 using event_study_death_county.dta, replace

/* Fill each cell for years before democratization */
foreach num of numlist 30(-10)0 { 
	local cil95 = _b[1.pre`num'#c.`index'] - _se[1.pre`num'#c.`index']*invttail(25, 0.025)
	local ciu95 = _b[1.pre`num'#c.`index'] + _se[1.pre`num'#c.`index']*invttail(25, 0.025)
	post bskeep (-`num') (_b[1.pre`num'#c.`index']) (`cil95') (`ciu95')
	}
/* Fill each cell for years after democratization */
foreach num of numlist 10(10)80 {
	local cil95 = _b[1.treat`num'#c.`index'] - _se[1.treat`num'#c.`index']*invttail(25, 0.025)
	local ciu95 = _b[1.treat`num'#c.`index'] + _se[1.treat`num'#c.`index']*invttail(25, 0.025)
	post bskeep (`num') (_b[1.treat`num'#c.`index']) (`cil95') (`ciu95')
	}
/* Save the Stata data file */
qui postclose bskeep
}



use event_study_case_county, clear

twoway (rcap ci_l95 ci_u95 yr, lcolor(blue)) /// code for 95% CI
(scatter  beta yr , msize(1pt) mcolor(blue)), ///
ytitle("Effect of EFI x days before/after emergency declaration" "compared to until 30 days before emergency declaration", size(small) justification(center)) ///
xtitle("Days since declaration of emergency") /// 
xlabel( -30 -20 -10 0 10 20 30 40 50 60 70 80, noticks) ///
title("COVID-19 cases") yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI CSOE") label(2 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "eventstudy_case.gph" , replace 



use event_study_death_county, clear

twoway (rcap ci_l95 ci_u95 yr, lcolor(blue)) /// code for 95% CI
(scatter  beta yr , msize(1pt) mcolor(blue)), ///
ytitle("Effect of EFI x days before/after emergency declaration" "compared to until 30 days before emergency declaration", size(small) justification(center)) ///
xtitle("Days since declaration of emergency") /// 
xlabel( -30 -20 -10 0 10 20 30 40 50 60 70 80, noticks) ///
title("COVID-19 deaths") yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI CSOE") label(2 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "eventstudy_death.gph" , replace 


*---------------------------------------------------------------------------*
*				 			FIGURE A5
*--------------------------------------------------------------------------*

**Figure A5: Event-study estimates of the effect of the interaction between county-level emergency declaration and EFI on COVID-19 outcomes
graph combine eventstudy_case.gph eventstudy_death.gph, ///
graphregion(color(white))  ysize(1.5) xsize(2.5) cols(2)
qui graph save "figureA5.gph" , replace 
qui graph export "figureA5.png" , as(png)  width(2000) replace
qui graph export "figureA5.eps" , replace


*---------------------------------------------------------------------------*
*				 			FIGURE A6
*--------------------------------------------------------------------------*
use Master_data_covid_EHI.dta, clear

rename day_national_lockdown day_P1
rename day_county_lockdown day_P2

rename national_lockdown P1
rename county_lockdown P2

gen placebo_P1= P1
replace placebo_P1=0 if day_P1>=0 & day_P1<=45

gen placebo_P2= P2
replace placebo_P2=0 if day_P2>=0 & day_P2<=45

gen day_placebo_P1= day_P1-45
gen day_placebo_P2= day_P2-45

*edit P1 day_P1 placebo_P1 day_placebo_P1
eststo clear
local clear

*gen area=density_2018/pop

*global controls "area male age poverty educ urban immig share"
global controls "density_2018 male age poverty educ urban immig"
global controls2 "fairorpoorhealth smokers adultswithobesity adultswithdiabetes"

drop case death 
rename new_case case 
rename new_death death 

set more off

foreach index of varlist  EHI {

foreach y of varlist  case death  {

foreach policy of varlist  placebo_P1 placebo_P2  {

qui postfile bskeep days beta_`y'_`policy' ci_l95_`y'_`policy' ci_u95_`y'_`policy' using fig_`y'_`policy'_dynamic_placebo, replace

foreach x of numlist  5(5)50 {


****Columns 5
eststo reg5_`x'_`y'_`policy': reghdfe `y'  i.`policy'##c.`index' if day_`policy'>=-`x' & day_`policy'<=`x', absorb(fips date2) cluster(istate)
gen sample=e(sample)
sum `y' if sample==1
estadd scalar mean=r(mean)
estadd scalar sd=r(sd)
estadd local sfe 
estadd local cfe "\checkmark"
estadd local dfe "\checkmark"
estadd local control  
drop sample 

	local cil95 = _b[1.`policy'#c.`index'] - _se[1.`policy'#c.`index']*invttail(25, 0.025)
	local ciu95 = _b[1.`policy'#c.`index'] + _se[1.`policy'#c.`index']*invttail(25, 0.025)
	post bskeep (`x') (_b[1.`policy'#c.`index']) (`cil95') (`ciu95')

}
qui postclose bskeep

}
}
}

use fig_case_placebo_P1_dynamic_placebo.dta, clear
sort days 
merge 1:1 days using fig_death_placebo_P1_dynamic_placebo.dta
drop _merge

merge 1:1 days using fig_case_placebo_P2_dynamic_placebo.dta
drop _merge

merge 1:1 days using fig_death_placebo_P2_dynamic_placebo.dta
drop _merge

save fig_dynamic_placebo, replace

*drop decileP1
gen daysP1=1
replace daysP1=daysP1[_n-1]+2 in 2/10
gen daysP2=daysP1+0.25



twoway (rcap ci_l95_case_placebo_P1 ci_u95_case_placebo_P1 daysP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_case_placebo_P1 daysP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_case_placebo_P2 ci_u95_case_placebo_P2 daysP2, lcolor(red)) /// code for 95% CI
(scatter  beta_case_placebo_P2 daysP2 , msize(1pt) mcolor(red)), ///
ytitle("Coef of the interaction between placebo policy and EFI", size(small) justification(center)) ///
xtitle("Bandwidths (days before and after emergency declaration)", size(small) justification(center)) /// 
xlabel( 1.25 "5" 3.25 "10" 5.25 "15" 7.25 "20" 9.25 "25" 11.25 "30" 13.25 "35" 15.25 "40" 17.25 "45" 19.25 "50", noticks) ///
title("(a) Placebo test: New COVID-19 cases") yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "dynamic_case_placebo.gph" , replace 


twoway (rcap ci_l95_death_placebo_P1 ci_u95_death_placebo_P1 daysP1, lcolor(blue)) /// code for 95% CI
(scatter  beta_death_placebo_P1 daysP1 , msize(1pt) mcolor(blue)) ///
(rcap ci_l95_death_placebo_P2 ci_u95_death_placebo_P2 daysP2, lcolor(red)) /// code for 95% CI
(scatter  beta_death_placebo_P2 daysP2 , msize(1pt) mcolor(red)), ///
title("(b) Placebo test: New COVID-19 deaths") ytitle("Coef of the interaction between placebo policy and EFI", size(small) justification(center)) ///
xtitle("Bandwidths (days before and after emergency declaration)", size(small) justification(center)) /// 
xlabel( 1.25 "5" 3.25 "10" 5.25 "15" 7.25 "20" 9.25 "25" 11.25 "30" 13.25 "35" 15.25 "40" 17.25 "45" 19.25 "50" , noticks) ///
yline(0, lpattern(dash) lcolor(black)) ///
legend( label(1 "CI FSOE") label(2 "Beta FSOE") label(3 "CI CSOE") label(4 "Beta CSOE") cols(2) ) ///
graphregion(color(white)) 
qui graph save "dynamic_death_placebo.gph" , replace 

*---------------------------------------------------------------------------*
*				 			FIGURE A6
*--------------------------------------------------------------------------*

**Figure A6: Placebo test: Dynamic effect of the interaction between fictitious emergency declarations and EFI on COVID-19 outcome
graph combine dynamic_case_placebo.gph dynamic_death_placebo.gph, ///
graphregion(color(white))  ysize(1.5) xsize(2.5) cols(2)
qui graph save "figureA6.gph" , replace 
qui graph export "figureA6.png" , as(png)  width(2000) replace
qui graph export "figureA6.eps" ,  replace


