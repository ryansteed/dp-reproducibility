
clear
clear all

set more off
set matsize 11000


do ../init.do




clear
use Alternative_Housing_Indicator_v4
desc, full

gen log_q = log(units)
gen log_p = log(hpi)
summ log_q
replace log_q = log_q - r(mean)
summ log_p
replace log_p = log_p - r(mean)
gen log_housing = log_p + log_q
keep metarea year log_housing log_q log_p units_prev hpi
rename units_prev units
sort metarea year
summ log_housing if year == 2000
save Alternative_Housing_Indicator_v4_FINAL, replace



**
** Enrollment by metarea data **
**
if ("`2'" == "high") {
 use "Enrollment_by_metarea_v3_high.dta", clear
}
else {
if ("`2'" == "most") {
 use "Enrollment_by_metarea_v3_most.dta", clear
}
else {
use "Enrollment_by_metarea_v3.dta", clear
}
}


** Total enrollment *
egen def_A34 = rowtotal(def_A3 def_A4)
egen total_enrollment = rowtotal(def_A2 def_A3 def_A4)
	
* Log of enrollment *
foreach var of varlist def* total_enrollment{
gen ln_`var' = ln(`var')
}



capture drop _merge
sort metarea year
merge metarea year using Alternative_Housing_Indicator_v4_FINAL, uniqusing 

tab year _merge, missing
keep if _merge == 3
keep if ft_pt == 0
keep if gender == "`1'"



capture drop iv
capture drop t_log
capture drop _merge
sort metarea 

**
** Structural break
**
merge metarea using ../chn/fhfa/new_iv7_log_p10_RAW.dta, uniqusing
rename diff1 iv
rename t1 t_log

tab year _merge, missing
keep if _merge == 3




capture drop statefip
capture drop _merge
sort metarea 
merge metarea using ../chn/main_data, uniqusing
tab year _merge, missing
keep if _merge == 3


capture drop _merge
sort metarea 
merge metarea using ./pop_main, uniqusing
capture drop if _merge == 2
keep if _merge == 3



sort metarea

capture drop _merge
sort metarea year

if ("`1'" == "women") {
 local type = "_women_"
}
if ("`1'" == "men") {
 local type = "_men_"
}
if ("`1'" == "enrollment") {
 local type = "_"
}
gen log_pop = log(  (pop_18_25`type'2007/3 - pop_18_25`type'2000)/6 * (year - 2000) + pop_18_25`type'2000) if year > 1995
replace log_pop =  log(  (pop_18_25`type'2000 - pop_18_25`type'1990)/10 * (year - 1990) + pop_18_25`type'1990 ) if year <= 1995



capture drop _merge
sort metarea year
merge metarea year using seer_pop_data, uniqusing
tab metarea _merge, missing
keep if _merge == 3




if ("`1'" == "women") {
 replace pop_18_25 = pop_18_25_f
}
if ("`1'" == "men") {
 replace pop_18_25 = pop_18_25_m
}
if ("`1'" == "enrollment") {
}

gen log_pop_alt = log(pop_18_25)
summ log_pop log_pop_alt
bys year: summ log_pop log_pop_alt
corr log_pop log_pop_alt
replace log_pop = log_pop_alt


replace ln_def_A34 = exp(ln_def_A34) / exp(log_pop) 
replace ln_def_A2 = exp(ln_def_A2) / exp(log_pop)






est clear
xtset metarea year

keep if year >= 1990 & year <= 2006
keep if ln_def_A2 < . 
bys metarea: keep if _N >= 2

sort metarea year
by metarea: gen pop_18_33_2000 = exp(log_pop[1])
replace wgt = pop_18_33_2000


xi i.year
summ ln_def_A2 ln_def_A34


gen boom = exp(4*iv)-1
gen yr =  1996 + floor( (t_log-3) / 4 ) 
tab t_log yr, missing

gen post = (year > yr)
gen boomXpost = (boom) * post 

gen diff = year - yr 
keep if diff >= -5 & diff <= 7

drop _merge
sort metarea
merge metarea using ../chn/xwalk_metarea_to_state_and_region.dta
keep if _merge == 3

xi i.year


summ ln_def_A2 [aw=pop_18_33_2000]
local mean = r(mean)

areg ln_def_A2 boomXpost _I* [aw=pop_18_33_2000], cluster(statefip) absorb(metarea)
post_param "mean" `mean'
est store assoc
areg ln_def_A2 boomXpost post _I* [aw=pop_18_33_2000], cluster(statefip) absorb(metarea)
post_param "mean" `mean'
est store assoc2

summ ln_def_A34 [aw=pop_18_33_2000]
local mean = r(mean)

areg ln_def_A34 boomXpost _I* [aw=pop_18_33_2000], cluster(statefip) absorb(metarea)
post_param "mean" `mean'
est store bach

areg ln_def_A34 boomXpost post _I* [aw=pop_18_33_2000], cluster(statefip) absorb(metarea)
post_param "mean" `mean'
est store bach2

estout assoc bach ///
  using ../output/table5_ipeds_event_study_`1'_`2'.txt, ///
  stats(mean N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  drop(_I* _cons) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers )

estout assoc2 bach2 ///
  using ../output/tableOA12_ipeds_event_study_`1'_`2'.txt, ///
  stats(mean N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  drop(_I* _cons) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers )












capture drop yr
*gen yr =  1995 + floor( (t_log-1) / 4 ) 
gen yr =  1996 + floor( (t_log-1) / 4 ) 
capture drop diff
gen diff = year - yr 
tab diff, missing


sort metarea year
by metarea: gen log_pop_init = log_pop[1]
by metarea: replace pop_18_33_2000 = exp(log_pop[1])

gen m__4 = (diff < -3) * boom
forvalues i = 3(-1)2 {
 gen m__`i' = (diff == -1 * `i') * boom
}

forvalues i = 0/4 {
 gen p__`i' = (diff == `i') * boom
 }
gen p__5 = (diff > 4) * boom

keep if diff >= -4 & diff <= 5

matrix results = J(10, 5, .)

matrix results[1,1] = -4
matrix results[2,1] = -3
matrix results[3,1] = -2
matrix results[4,1] = -1
matrix results[5,1] = 0
matrix results[6,1] = 1
matrix results[7,1] = 2
matrix results[8,1] = 3
matrix results[9,1] = 4
matrix results[10,1] = 5

areg ln_def_A2 m__* p__* _I* [aw=pop_18_33_2000], cluster(statefip) absorb(metarea)
do post_results.do "`1'" 2

areg ln_def_A34 m__* p__* _I* [aw=pop_18_33_2000], cluster(statefip) absorb(metarea)
do post_results.do "`1'" 4

preserve
drop _all
svmat results
rename results1 t
rename results2 assoc
rename results3 assoc_se
rename results4 bach
rename results5 bach_se
outsheet using ./ipeds_event_study_graph_`1'_`2'.txt, replace
restore

exit


