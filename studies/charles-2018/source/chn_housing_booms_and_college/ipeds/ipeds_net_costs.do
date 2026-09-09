
clear
clear all

set more off
set matsize 11000


do ../init.do



use "./Net_Cost_by_metarea.dta"
keep if gender == "enrollment"
keep if ft_pt == 0
keep if year >= 1995



* Total enrollment *
egen def_A34 = rowmean(def_A3 def_A4)



capture drop statefip
capture drop _merge
sort metarea 
merge metare using ../chn//main_data, uniqusing
keep if _merge == 3


local type = "_"

sort metarea
tab year, missing


replace year = 2000 if year >= 1996 & year <= 2000
replace year = 2006 if year >= 2002 & year <= 2006
replace def_A2 = . if def_A2 < 0
replace def_A34 = . if def_A34 < 0

egen def_A = rowmean(def_A2 def_A34)

gen num_nonmiss_A2  = def_A2 < .
gen num_nonmiss_A34 = def_A34 < .

keep if year == 2000 | year == 2006

collapse (sum) num_nonmiss_* (mean) def_A2 def_A34 def_A, by(metarea year)
keep if num_nonmiss_A2 > 1
keep if num_nonmiss_A34 > 1

** Log of cost
foreach var of varlist def* {
 gen ln_`var' = ln(`var')
}


capture drop statefip
capture drop _merge
sort metarea 
merge metare using ../chn/main_data, uniqusing
keep if _merge == 3

drop if missing(metarea)
capture drop _merge
sort metarea 
merge metarea using ../chn/share_foreign.dta, uniqusing 
keep if _merge == 3
drop _merge

capture drop _merge
sort metarea
merge metarea using ../chn/xwalk_metarea_to_state_and_region.dta
keep if _merge == 3

gen pop_18_33_2000 = wgt

xtset metarea year

replace def_A2 = . if def_A2 < 0
replace def_A34 = . if def_A34 < 0

gen diff_a2 = log(F6.def_A2 / def_A2)
gen diff_a34 = log(F6.def_A34 / def_A34)

local varlist = "diff_a2 diff_a34"
foreach var of local varlist{
summ `var' [aw=pop_18_33_2000], det
replace `var' = r(p1) if `var' < r(p1)
replace `var' = r(p99) if `var' > r(p99) & `var' < .
}


est clear

foreach var of varlist diff_a2 diff_a34 {

summ `var'

reg `var' housing_demand_shock female_employed college_share_2000 pop_prev share_foreign_18_55_2000 [aw=pop_18_33_2000], cluster(statefip)
est store ols_`var'

ivreg2 `var' (housing_demand_shock = iv) female_employed college_share_2000 pop_prev share_foreign_18_55_2000 [aw=pop_18_33_2000], cluster(statefip)
post_param "Fstat" e(widstat)
est store iv_`var'

}


estout ols* iv* ///
  using ../output/tableOA20_ipeds_net_cost`type'`2'.txt, ///
  stats(Fstat N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(housing_demand_shock) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

exit
