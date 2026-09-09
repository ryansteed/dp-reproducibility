
clear
clear matrix
clear mata

set maxvar 10000
est clear
set more off


do init.do


clear
use "./chn/msa_education_2000_2013_same.dta


capture drop _merge
sort metarea
capture drop region
merge metarea using chn/xwalk_metarea_to_state_and_region.dta, uniqusing
tab _merge, missing
drop if _merge == 2
drop _merge



sort metarea
merge metarea using chn/main_data.dta, uniqusing uniqmaster
tab metarea _merge ,missing
drop if _merge == 2
drop _merge




**
** TYPE: "_", "_men_", "_women_"
local type = "`1'"


local years = "2000 2007 2013 c1 c2"

foreach year of local years {

gen assoc_22_29`type'`year' = associate_22_25`type'`year' + associate_26_29`type'`year'
gen assoc_26_33`type'`year' = associate_26_29`type'`year' + associate_30_33`type'`year'
gen assoc_18_25`type'`year' = associate_22_25`type'`year' + associate_18_21`type'`year'

gen any_22_29`type'`year' = any_college_22_25`type'`year' + any_college_26_29`type'`year'
gen any_26_33`type'`year' = any_college_26_29`type'`year' + any_college_30_33`type'`year'
gen any_18_25`type'`year' = any_college_22_25`type'`year' + any_college_18_21`type'`year'

gen bachelor_22_29`type'`year' = bachelor_22_25`type'`year' + bachelor_26_29`type'`year'
gen bachelor_26_33`type'`year' = bachelor_26_29`type'`year' + bachelor_30_33`type'`year'
gen bachelor_18_25`type'`year' = bachelor_22_25`type'`year' + bachelor_18_21`type'`year'

gen pop_18_25`type'`year' = pop_22_25`type'`year' + pop_18_21`type'`year'
gen pop_22_29`type'`year' = pop_22_25`type'`year' + pop_26_29`type'`year'
gen pop_26_33`type'`year' = pop_30_33`type'`year' + pop_26_29`type'`year'

}





local first = "2000"
local last = "2007"
local num = "3"

if ("`3'" == "06_12") {
 local first = "2007"
 local last = "2013"
 local num = "7"
}
if ("`3'" == "00_12") {
 local first = "2000"
 local last = "2013"
 local num = "7"
}




local levels = "assoc bachelor any"

foreach level of local levels {

gen d_`level'_26_33`type'a1 = (`level'_26_33`type'`last')/(pop_26_33`type'`last')  - ///
 (`level'_26_33`type'`first')/(pop_26_33`type'`first') 

gen d_`level'_18_25`type'a1 = (`level'_18_25`type'`last')/(pop_18_25`type'`last')  - ///
 (`level'_18_25`type'`first')/(pop_18_25`type'`first') 

}

foreach var of varlist assoc_18_25* any_18_25* bachelor_18_25* assoc_26_33* any_26_33* bachelor_26_33* {
 if (strpos("`var'", "any_college") == 0) {
 local pop = subinstr("`var'", "assoc_", "pop_", .)
 local pop = subinstr("`pop'", "any_", "pop_", .)
 local pop = subinstr("`pop'", "bachelor_", "pop_", .)
 di "var: `var', pop: `pop'"
 gen sh_`var' = `var' / `pop'
 }
}


keep if housing_demand_shock < .

capture drop _merge
sort metarea 
merge metarea using ./chn/share_foreign.dta, uniqusing uniqmaster
keep if _merge == 3
drop _merge

drop college_share_2000 pop_prev female_employed_share_2000 statefip
capture drop _merge
sort metarea 
merge metarea using ./chn/controls.dta, uniqusing uniqmaster
keep if _merge == 3
drop _merge

global controls = "college_share_2000 female_employed_share_2000 pop_prev share_foreign_18_55_2000"
replace wgt = exp(pop_prev)


est clear

reg d_any_18_25`type'a1 housing_demand_shock $controls [aw=wgt], cluster(statefip)
est store ols1
ivreg2 d_any_18_25`type'a1 (housing_demand_shock = iv) $controls [aw=wgt], cluster(statefip)
post_param "Fstat" e(widstat)
est store iv1

** 
** Only report Bachelors for 00-06
**
if ("`3'" == "") {
reg d_bachelor_18_25`type'a1 housing_demand_shock $controls [aw=wgt], cluster(statefip)
est store ols2
ivreg2 d_bachelor_18_25`type'a1 (housing_demand_shock = iv) $controls [aw=wgt], cluster(statefip)
post_param "Fstat" e(widstat)
est store iv2
}

**
** Table 3 includes men+women for older age group
**
if ("`1'" == "_" & "`3'" == "") {
 reg d_any_26_33`type'a1 housing_demand_shock $controls [aw=wgt], cluster(statefip)
 est store ols3
 ivreg2 d_any_26_33`type'a1 (housing_demand_shock = iv) $controls [aw=wgt], cluster(statefip)
 post_param "Fstat" e(widstat)
 est store iv3

 reg d_bachelor_26_33`type'a1 housing_demand_shock $controls [aw=wgt], cluster(statefip)
 est store ols4
 ivreg2 d_bachelor_26_33`type'a1 (housing_demand_shock = iv) $controls [aw=wgt], cluster(statefip)
 post_param "Fstat" e(widstat)
 est store iv4
}

*estout iv* ///
*  using ./output/table`num'_educ`1'`2'_`3'iv.txt,  ///
*  stats(Fstat N r2, fmt(%9.3f)) modelwidth(7) varwidth(25) ///
*  keep(housing_demand_shock*) ///
*  cells(b( fmt(%9.3f)) se(par fmt(%9.3f)) p(par([ ]) fmt(%9.3f)) ) style(tab) replace notype mlabels(, numbers ) 

if (`num' == 3) {

*estout ols* ///
*  using ./output/tableOA28_educ`1'`2'_`3'ols.txt,  ///
*  stats(Fstat N r2, fmt(%9.3f)) modelwidth(7) varwidth(25) ///
*  keep(housing_demand_shock*) ///
*  cells(b( fmt(%9.3f)) se(par fmt(%9.3f)) p(par([ ]) fmt(%9.3f)) ) style(tab) replace notype mlabels(, numbers ) 
}
*** EDITED by Donna
estout ols1 iv1 ols2 iv2 ols3 iv3 ols4 iv4 using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save "post_replication.dta", replace
exit
