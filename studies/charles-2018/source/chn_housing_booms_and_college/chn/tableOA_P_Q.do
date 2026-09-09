
preserve
est clear

local vars = "d_emp d_wage d_wage_adj d_cons d_fire"
local depvars = "18_25_le_m 18_25_le_f 18_25_le"
local depvars = "18_33_le_m 18_33_le_f 18_33_le"

foreach depvar of local depvars {

local str = "`depvar'"

est clear
local k = 1

foreach var of local vars {

do ./chn/ols2.do hp_growth_real_00_06 `var'_`depvar' pop_18_33_00
est store ols`k'

local k = `k' + 1

}

estout ols* ///
  using ./output/tableOA23_`str'_P_Q_ols.txt,  ///
  stats(test_eq N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(deltaP units_growth*) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

}


restore


