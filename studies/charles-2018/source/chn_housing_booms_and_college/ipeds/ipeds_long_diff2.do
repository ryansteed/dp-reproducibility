
clear
clear all

set more off
set matsize 11000


do ../init.do






use ./metarea_pop_female
rename pop_20_29 pop_20_29_f
sort metarea year
merge metarea year using  ./metarea_pop_male, uniqusing uniqmaster
assert _merge == 3
drop _merge
replace pop_20_29 = pop_20_29 + pop_20_29_f
keep metarea year pop_20_29
sort metarea year
save ./metarea_pop_all, replace







if ("`2'" == "completions") {

 clear
 use Degree_Completions_by_Institution_Type_Panel_v2.dta

 gen def_A2 = def_A2associates + def_A2bachelors
 gen def_A3 = def_A3bachelors
 gen def_A4 = def_A4bachelors + def_A3associates  + def_A4associates  
 gen def_A34= def_A3 + def_A4

 gen ft_pt = 0
 replace gender = "enrollment" if gender == "total"
 gen total_enrollment = def_A2 + def_A3 + def_A4 
 isid metarea year gender

 sort metarea year
 keep if year >= 1995



}
else {
 if ("`2'" == "residency") {
  use Enrollment_by_Residency_Long.dta

  gen gender = "enrollment"
  *keep if out_of_state == 0
  gen ft_pt = 0

  bys metarea year type: egen tot = sum(enrollment)
  bys metarea year type: egen out = sum(enrollment * (out_of_state == 1))
 
  gen share = out/tot

  bys metarea year: egen def_A2 = max((type == "A2") * share)
  bys metarea year: egen def_A34 = max((type == "A3" | type == "A4") * share)

 }
 else {

**
** Enrollment by metarea data **
**
use "Enrollment_by_metarea_v3_high.dta", clear

if ("`2'" == "all") {
 use "Enrollment_by_metarea_v3.dta", clear
}
else {
 if ("`2'" == "most") {
 use "Enrollment_by_metarea_v3_most.dta", clear
 }
}


tab year

* Total enrollment *
egen def_A34 = rowtotal(def_A3 def_A4)
egen total_enrollment = rowtotal(def_A2 def_A3 def_A4)


 }
}




keep if gender == "`1'"
keep if ft_pt == 0







preserve
clear
use seer_pop_data

local years = "1990 2000 2007 2011"
foreach year of local years {
 replace year = `year' if abs(year - `year') <= 1
}

keep if year == 1990 | year == 2000 | year == 2007 | year == 2011

collapse (mean) pop_18_25* pop_18_33*, by(metarea year)

rename pop_18_25 pop_18_25_

rename pop_18_25_m pop_18_25_men_
rename pop_18_25_f pop_18_25_women_

rename pop_18_33 pop_18_33_
rename pop_18_33_m pop_18_33_men_
rename pop_18_33_f pop_18_33_women_

reshape wide pop_18_25_ pop_18_25_men_ pop_18_25_women_ pop_18_33_ pop_18_33_men_ pop_18_33_women_, i(metarea) j(year)

keep pop_18_25* metarea
sort metarea

save ./pop_main, replace
restore



capture drop _merge
sort metarea 
merge metarea using ./pop_main, uniqusing
keep if _merge == 3








if ("`1'" == "women") {
 local type = "_women_"
}
if ("`1'" == "men") {
 local type = "_men_"
}
if ("`1'" == "enrollment") {
 local type = "_"
}


gen pop_18_25 = (pop_18_25`type'2007 - pop_18_25`type'2000)/6 * (year - 2000) + pop_18_25`type'2000 if year > 1995
replace pop_18_25 =  (pop_18_25`type'2000 - pop_18_25`type'1990)/10 * (year - 1990) + pop_18_25`type'1990 if pop_18_25`type'1990 < . & year <= 1995


sort metarea
tab year, missing

if ("`2'" == "06_12") {
 replace year = 1999 if year == 2000
 replace year = 2000 if year >= 2002 & year <= 2006
 replace year = 2005 if year == 2006
 replace year = 2006 if year >= 2007 & year <= 2012
}

if ("`2'" == "00_12") {
 replace year = 2000 if year >= 1996 & year <= 2000
 replace year = 2005 if year == 2006
 replace year = 2006 if year >= 2007 & year <= 2012
}

if ("`2'" == "placebo") {
 drop if year == 2000
 drop if year == 2006

 ** backward-looking
 replace year = 2000 if year >= 1987 & year <= 1990
 replace year = 2006 if year >= 1991 & year <= 1996
}

if ("`2'" == "" | "`2'" == "all" | "`2'" == "most" | "`2'" == "high") {

** backward-looking
replace year = 2000 if year >= 1996 & year <= 2000
replace year = 2006 if year >= 2002 & year <= 2006
}


if ("`2'" == "completions") {
 tab year, missing
 replace year = 2000 if year >= 1996 & year <= 2003
 replace year = 2006 if year >= 2004 & year <= 2009
}


replace def_A2 = . if def_A2 == 0
replace def_A34 = . if def_A34 == 0

gen num_nonmiss_A2  = def_A2 < .
gen num_nonmiss_A34 = def_A34 < .

keep if year == 2000 | year == 2006

replace def_A2 = def_A2 / pop_18_25
replace def_A34 = def_A34 / pop_18_25

egen def_A = rowtotal(def_A2 def_A34)

collapse (sum) num_nonmiss_* (mean) def_A2 def_A34 def_A, by(metarea year)

keep if num_nonmiss_A2 > 0 | num_nonmiss_A34 > 0



if ("`2'" == "06_12" | "`2'" == "00_12") {
sort metarea
merge metarea using ipeds_long_diff2.dta
drop diff_* init_*
tab metarea _merge, missing
keep if _merge == 3
drop _merge
}



capture drop statefip
capture drop _merge
sort metarea 
merge metare using ../chn/main_data, uniqusing
keep if _merge == 3




capture drop _merge
sort metarea
merge metarea using ../chn/xwalk_metarea_to_state_and_region.dta
keep if _merge == 3

replace statefip = 47 if metarea == 156
replace statefip = 29 if metarea == 704
replace statefip = 17 if metarea == 160
replace statefip = 17 if metarea == 196
replace statefip = 29 if metarea == 376
replace statefip = 36 if metarea == 560
replace statefip = 11 if metarea == 884


gen pop_18_33_2000 = exp(pop_prev)
xtset metarea year




gen diff_a2 = (F6.def_A2 - def_A2)
gen diff_a34 = (F6.def_A34 - def_A34)
gen diff_a = F6.def_A - def_A
gen init_a2 = def_A2
gen init_a34 = def_A34




drop if missing(metarea)
capture drop _merge
sort metarea 
merge metarea using ../chn/share_foreign.dta, uniqusing 
assert _merge != 1
keep if _merge == 3
drop _merge




if ("`2'" == "placebo") {
replace share_foreign_18_55_2000 = 0
replace female_employed = 0
replace college_share_2000 = 0
replace pop_prev = 0
}



est clear
foreach var of varlist diff_a2 diff_a34 {

if ("`var'" == "diff_a2") {
 local yinit = "def_A2"
}
if ("`var'" == "diff_a34") {
 local yinit = "def_A34"
}
if ("`var'" == "diff_a") {
 local yinit = "def_A"
}

summ `var'

reg `var' housing_demand_shock female_employed college_share_2000 pop_prev share_foreign_18_55_2000 [aw=pop_18_33_2000], cluster(statefip)
summ `yinit' [aw=pop_18_33_2000] if year == 2000 
local mean = r(mean)
post_param "mean" `mean'
est store ols_`var'

ivreg2 `var' (housing_demand_shock = iv) female_employed college_share_2000 pop_prev share_foreign_18_55_2000 [aw=pop_18_33_2000], cluster(statefip)
post_param "mean" `mean'
post_param "Fstat" e(widstat)
est store iv_`var'

}

local num = 4
if ("`2'" == "06_12" | "`2'" == "00_12") {
 local num = 7
}

if ("`2'" == "completions") {
 local num = "OA14"
}
if ("`2'" == "costs") {
 local num = "OA20"
 local ols = "ols*" 
}

estout iv* `ols' ///
  using ../output/table`num'_ipeds_long_diff`type'`2'.txt, ///
  stats(mean Fstat N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(housing_demand_shock*) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 



if ("`num'" == "4" & "`2'" != "placebo") {
estout ols* ///
  using ../output/tableOA29_ipeds_long_diff`type'`2'.txt, ///
  stats(mean N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(housing_demand_shock*) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 
}






if ("`2'" == "placebo") {
 keep if diff_a2 < . 
 keep diff_a2 diff_a34 metarea init_a2 init_a34 housing_demand_shock iv
 sort metarea
 save ipeds_long_diff2_placebo.dta, replace
}





if ("`1'" == "enrollment" & "`2'" == "") {
 preserve
 keep if diff_a2 < .
 
 keep diff_a2 diff_a34 metarea init_a2 init_a34
 sort metarea
 save ipeds_long_diff2.dta, replace
 restore
}



exit
