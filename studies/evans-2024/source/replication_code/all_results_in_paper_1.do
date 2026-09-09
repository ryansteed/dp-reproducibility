* July 8, 2024
* this program generates all the results in the paper including those in the 
* appendix

set more off
clear

*log using all_results_in_paper_1.log, replace

use stata_data_files/stacked_1
drop _merge

* delete obs w some missing data
drop if single_parent==.
drop if med_hh_income==.
drop if enroll_total==.
drop if medhhincwkids==.

* make percents for race variables
gen per_white=100*enroll_white/enroll_total
gen per_black=100*enroll_black/enroll_total
gen per_hispanic=100*enroll_hispanic/enroll_total
gen per_asian=100*enroll_asian/enroll_total
gen per_other=100*(enroll_total-enroll_white-enroll_hispanic-enroll_black-enroll_asian)/enroll_total

* turn share of days in mode into percents
gen share_alt=share_hybrid+share_virtual 
replace share_virtual=100*share_virtual
replace share_hybrid=100*share_hybrid
replace share_alt=100*share_alt
replace share_inperson=100*share_inperson

gen statefips=int(nces_id/100000)

* turn chronic absneteeism rate into percent
gen ca_rate=100*ca/enroll_total


* identify the districts with > 100 percent ca_rate
tab nces_id if ca_rate>100
* get their enrollment
sum enroll_total if ca_rate>100
drop if ca_rate>100



* balance the sample  -- only districts with 2 obs
gen c=1
sort nces_id

by nces_id: egen nobs=sum(c)
drop if nobs<2

*input cpi numbers
gen cpi=292.655
replace cpi=255.657 if year==1819

gen medhhincwkids_r=medhhincwkids*292.655/cpi
gen year2122=year==2122

*=========================================
*=========================================
*Numbers for Figure 1
*=========================================
*=========================================


gen virtualg=0
replace virtualg=1 if share_virtual>0 & share_virtual<=20
replace virtualg=2 if share_virtual>20 & share_virtual<=40
replace virtualg=3 if share_virtual>40 & share_virtual<=60
replace virtualg=4 if share_virtual>60 & share_virtual<=80
replace virtualg=5 if share_virtual>80 & share_virtual<100
replace virtualg=6 if share_virtual==100
* tab virtualg if year==2122 [fw=enroll_total]

gen hybridg=0 
replace hybridg=1 if share_hybrid>0 & share_hybrid<=20
replace hybridg=2 if share_hybrid>20 & share_hybrid<=40
replace hybridg=3 if share_hybrid>40 & share_hybrid<=60
replace hybridg=4 if share_hybrid>60 & share_hybrid<=80
replace hybridg=5 if share_hybrid>80 & share_hybrid<100
replace hybridg=6 if share_hybrid==100
* tab hybridg if year==2122 [fw=enroll_total]

gen inpersong=0
replace inpersong=1 if share_inperson>0 & share_inperson<=20
replace inpersong=2 if share_inperson>20 & share_inperson<=40
replace inpersong=3 if share_inperson>40 & share_inperson<=60
replace inpersong=4 if share_inperson>60 & share_inperson<=80
replace inpersong=5 if share_inperson>80 & share_inperson<100
replace inpersong=6 if share_inperson==100
* tab inpersong if year==2122 [fw=enroll_total]
save stata_data_files/temp1, replace

*=========================================
*=========================================
*get some numbers about use of mode by
*group level
*=========================================
*=========================================

keep if year==2122
format enroll_total %10.0g
save stata_data_files/temp2, replace

collapse (sum) enroll_total, by(inpersong)
outsheet using output_for_graphs\inpersong.csv, comma replace
clear
use stata_data_files/temp2
collapse (sum) enroll_total, by(hybridg)
outsheet using output_for_graphs\hybridg.csv, comma replace
clear
use stata_data_files/temp2
collapse (sum) enroll_total, by(virtualg)
outsheet using output_for_graphs\virtualg.csv, comma replace
clear


use stata_data_files/temp1
keep nces_id enroll_total ca_rate year inpersong
reshape wide enroll_total ca_rate inpersong, i(nces_id) j(year)
gen diff=ca_rate2122-ca_rate1819
gen enroll_total_m=(enroll_total2122+enroll_total1819)/2
sort inpersong2122
by inpersong2122: sum diff [aw=enroll_total_m]
clear

use temp1
keep nces_id enroll_total ca_rate year hybridg
reshape wide enroll_total ca_rate hybridg, i(nces_id) j(year)
gen diff=ca_rate2122-ca_rate1819
gen enroll_total_m=(enroll_total2122+enroll_total1819)/2
sort hybridg2122
by hybridg2122: sum diff [aw=enroll_total_m]
clear

use temp1
keep nces_id enroll_total ca_rate year virtualg
reshape wide enroll_total ca_rate virtualg, i(nces_id) j(year)
gen diff=ca_rate2122-ca_rate1819
gen enroll_total_m=(enroll_total2122+enroll_total1819)/2
sort virtualg2122
by virtualg2122: sum diff [aw=enroll_total_m]
clear



* this section generates quintiles of some
* observed characteristics to produce
* the estimates in table 3 and appendix tables 
use stata_data_files/temp1
keep if year==1819

gen per_bh=per_black+per_hispanic

xtile povertyg=poverty, nq(5)
xtile hispanicg=per_hispanic, nq(5)
xtile blackg=per_black, nq(5)
xtile bhg=per_bh, nq(5)
xtile spg=single_parent, nq(5)
xtile collegeg=college_deg, nq(5)
xtile medhhincg=medhhincwkids_r, nq(5)


label var povertyg "quintiles of 2019 poverty"
label var hispanicg "quintiles of 2019 share Hispanic"
label var blackg "quintiles of 2019 share black"
label var bhg "quintiles of 2019 share black and hispanic"
label var spg "quntiles of 2019 share children that live with a single parent"
label var collegeg "quintiles of 2019 share of adults age 25+ with college degree"
label var medhhincg "quintiles of 2019 median hh income, real 2022 dollars"

xtile povertyg3=poverty, nq(3)
xtile hispanicg3=per_hispanic, nq(3)



keep nces_id povertyg hispanicg blackg bhg spg collegeg medhhincg povertyg3 hispanicg3
merge 1:m nces_id using stata_data_files/temp1

*=========================================
*=========================================
*Numbers for Table 1
*=========================================
*=========================================

sort year
by year: sum ca_rate share_inperson share_hybrid share_virtual ///
per_black per_asian per_other per_hispanic poverty high_school some_college college_deg ///
single_parent medhhincwkids_r  [aw=enroll_total]



*=========================================
*=========================================
*Results for Table 2
*=========================================
*=========================================

* basic regressions
areg ca_rate year2122 share_alt per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)

eststo: areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual

*** EDITED by Donna
estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear

*=========================================
*=========================================
*run log odds version of model -- talk about
*in appendix
*=========================================
*=========================================
* get zero rate frequency
gen ca_zero=ca_rate==0
tab year ca_zero, row col

*turn back into probability
gen p_ca=ca_rate/100

* replace zero rates with small probability
replace p_ca=0.0001 if p_ca==0

* get log off
gen ca_log_odd=ln(p_ca/(1-p_ca))


* run log odd version of Table 2
areg ca_log_odd year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual


*=========================================
*=========================================
*run fixed and random effects for basic model
*this does not cluster or anything
*get Hausman test statistic
*we talk about this in the appendix
*=========================================
*=========================================

sort nces_id

by nces_id:  egen enroll_total_m=mean(enroll_total)

xtset nces_id year

xtreg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r, re
estimates store random_effects

xtreg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r , fe
estimates store fixed_effects
hausman fixed_effects random_effects, sigmamore



* add state x year effects
* we add state x year 2122 effects in response to comments of a referee
* we talk about this in the appendix
xi i.state*i.year

areg ca_rate _I* share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r ///
  [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual


* now allow the demographc effects to vary by year
* first add one variable at a time then all at once
* these are found in appendix table 1
* this is in response to a referees comment that the results could be driven
* by changing impact of demographics on chronic absenteeism
gen per_black_2=per_black*year2122
gen per_asian_2=per_asian*year2122
gen per_hispanic_2=per_hispanic*year2122
gen per_other_2=per_other*year2122
gen single_parent_2=single_parent*year2122
gen high_school_2=high_school*year2122
gen some_college_2=some_college*year2122
gen college_deg_2=college_deg*year2122
gen poverty_2=poverty*year2122
gen medhhincwkids_r_2=medhhincwkids_r*year2122


local interaction "per_black_2 per_asian_2 per_hispanic_2 per_other_2 single_parent_2 high_school_2 some_college_2 college_deg_2 poverty_2 medhhincwkids_r_2"

foreach x of local interaction{
areg ca_rate year2122 `x' share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
}

areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r ///
  per_black_2 per_asian_2 per_hispanic_2 per_other_2 ///
  single_parent_2 high_school_2 some_college_2 college_deg_2 poverty_2  medhhincwkids_r_2 ///
 [aw=enroll_total], absorb(nces_id) cluster(nces_id)

***********************
***********************
* the most senitive results are those that
* interact hispanic with year -- we check
* to see if the basic results are driven by hispanics
* by running models only for districts with small
* fraction of hispanics
* we walk about this in the appendix
***********************
***********************


* calculate is a district is < 5% hispanic in both years
gen low_hispanic_05=per_hispanic<5
gen low_hispanic_01=per_hispanic<1
sort nces_id
by nces_id: egen n_low_hispanic_05=sum(low_hispanic_05)
by nces_id: egen n_low_hispanic_01=sum(low_hispanic_01)



* rerun regression deleting all schools with < 5% hispanic in both years
areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r [aw=enroll_total] ///
  if n_low_hispanic_05==2 , absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual


* rerun regression deleting all schools with < 1% hispanic in both years
areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty  medhhincwkids_r [aw=enroll_total] ///
  if n_low_hispanic_01==2 , absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual



*=========================================
*=========================================
*Results for Table 3
*=========================================
*=========================================


 
local quintiles "povertyg collegeg spg medhhincg blackg hispanicg"
*** EDIT BY Donna
eststo clear
foreach i of local quintiles {
sort `i'
by `i': eststo: areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual
by `i': sum ca_rate [aw=enroll_total] if year==1819
by `i': sum share_inperson share_hybrid share_virtual [aw=enroll_total] if year==2122
}
estout using "../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace



save stata_data_files/temp4, replace

*=========================================
*=========================================
*sensitivity test merge in vax and covid rate
*=========================================
*=========================================


drop _merge
merge m:1 nces_id using stata_data_files/vax_rate_by_district
replace vax_rate=0 if year==1819 & vax_rate~=.

drop _merge
merge m:1 nces_id using stata_data_files/covid_rate_by_district
replace covid_rate_sy=0 if year==1819 & covid_rate_sy~=.
drop _merge

drop if covid_rate_sy==. | vax_rate==.



*=========================================
*=========================================
*Results comparable to Table 2 with new
*sample
*=========================================
*=========================================


areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual

*=========================================
*=========================================
*Results comparable to Table 2 with new
*sample add on vax and covid rate
*=========================================
*=========================================


areg ca_rate year2122 share_hybrid share_virtual covid_rate_sy vax_rate per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual


*=========================================
*=========================================
*For completeness table 3 results with
* vax and covid entered
*=========================================
*=========================================


foreach i of local quintiles {
sort `i'
by `i': areg ca_rate year2122 share_hybrid share_virtual per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual

by `i': areg ca_rate year2122 share_hybrid share_virtual  covid_rate_sy vax_rate per_black per_asian per_hispanic per_other ///
  single_parent high_school some_college college_deg poverty medhhincwkids_r [aw=enroll_total], absorb(nces_id) cluster(nces_id)
test share_hybrid=share_virtual

by `i': sum ca_rate [aw=enroll_total] if year==1819
by `i': sum share_inperson share_hybrid share_virtual [aw=enroll_total] if year==2122
}

clear

* generate numbers for Figure 2

use stata_data_files/temp4
keep nces_id year ca_rate virtualg collegeg povertyg enroll_total 
replace virtualg=5 if virtualg==6
reshape wide ca_rate virtualg collegeg povertyg enroll_total , i(nces_id) j(year)
gen delta_ca= ca_rate2122- ca_rate1819
gen enroll_mean=(enroll_total1819+enroll_total2122)/2
collapse (mean) delta_ca [aw=enroll_mean], by(povertyg1819 virtualg2122)
outsheet using delta_ca_by_poverty_virtual.csv, comma replace
clear

use temp4
keep nces_id year ca_rate virtualg collegeg povertyg enroll_total 
replace virtualg=5 if virtualg==6
reshape wide ca_rate virtualg collegeg povertyg enroll_total , i(nces_id) j(year)
gen delta_ca= ca_rate2122- ca_rate1819
gen enroll_mean=(enroll_total1819+enroll_total2122)/2
collapse (mean) delta_ca [aw=enroll_mean], by(collegeg1819 virtualg2122)
outsheet using delta_ca_by_college_virtual.csv, comma replace
clear

