
local num = 1
if ("`2'" != "" ) {
 local num = "`2'"
}

est clear

global instruments = "iv"

local age = "`1'"

local depvars = "`age'_le `age'_le_m `age'_le_f"

foreach depvar of local depvars {

est clear
local k = 1

local vars = "d_emp d_wage d_ewage d_cons d_fire"
foreach var of local vars {

do ./chn/ols.do hp_growth_real_00_06 `var'_`depvar' pop_18_33_00

capture drop `var'_`depvar'_2000

if ("`var'" == "d_emp") {
 gen `var'_`depvar'_2000 = emp_`depvar'_00 / pop_`depvar'_00
}
if ("`var'" == "d_wage" | "`var'" == "d_ewage") {
 gen `var'_`depvar'_2000 = wage_`depvar'_00 / full_`depvar'_00
}
if ("`var'" == "d_wage_adj") {
 gen `var'_`depvar'_2000 = wage_adj_`depvar'_00 / full_`depvar'_00
}
if ("`var'" == "d_cons") {
 gen `var'_`depvar'_2000 = cons_`depvar'_00 / pop_`depvar'_00
}
if ("`var'" == "d_fire") {
 gen `var'_`depvar'_2000 = fire_`depvar'_00 / pop_`depvar'_00
}

summ `var'_`depvar'_2000 [aw=pop_18_33_00] 
post_param "mean" r(mean)
est store ols`k'

do ./chn/iv.do hp_growth_real_00_06 `var'_`depvar' pop_18_33_00
est store iv`k'

local k = `k' + 1

}

estout ols* ///
  using ./output/table`num'_`depvar'_ols.txt,  ///
  stats(mean N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

estout iv* ///
  using ./output/table`num'_`depvar'_iv.txt,  ///
  stats(mean Fstat N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

}





