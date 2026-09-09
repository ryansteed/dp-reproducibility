
preserve
est clear

global controls  = "college_share_2000 female_employed_share_2000 pop_prev share_foreign_18_55_2000"

summ hp_growth_real_00_06
local hp_growth_se = r(sd)

global instruments = "land_aval"
global num = 1

local vars = "d_emp d_wage d_wage_adj d_ewage d_cons d_fire"

local age = "`1'"

local depvars = "`age'_le `age'_le_m `age'_le_f"

foreach var of local vars {

foreach depvar of local depvars {

est clear

local str = "`depvar'"

do ./chn/ols.do hp_growth_real_00_06 `var'_`depvar' pop_18_33_00
est store ols_boom
do ./chn/ols.do hp_growth_real_00_06 `var'_`depvar'_07_13 pop_18_33_00
est store ols_bust
do ./chn/ols.do hp_growth_real_00_06 `var'_`depvar'_00_13 pop_18_33_00
est store ols_lr

do ./chn/iv.do hp_growth_real_00_06 `var'_`depvar' pop_18_33_00
est store iv_boom
do ./chn/iv.do hp_growth_real_00_06 `var'_`depvar'_07_13 pop_18_33_00
est store iv_bust
do ./chn/iv.do hp_growth_real_00_06 `var'_`depvar'_00_13 pop_18_33_00
est store iv_lr

local k = `k' + 1

estout ols* ///
  using ./output/tableOA30_lr`str'_`var'_ols.txt,  ///
  stats(hp_growth_se N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

estout iv* ///
  using ./output/tableOA31_lr`str'_`var'_iv.txt,  ///
  stats(hp_growth_se Fstat N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

}

}


restore


