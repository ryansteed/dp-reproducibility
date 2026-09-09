
preserve



macro drop _all
global instruments = "iv"
global num = 1





local age = "`1'"



local depvars = "26_55_mhl 26_55_mhl_m 26_55_mhl_f"
local vars = "d_emp d_wage d_ewage"




foreach depvar of local depvars {


est clear
local k = 1

foreach var of local vars {

do ./chn/ols.do hp_growth_real_00_06 `var'_`depvar' pop_18_33_00
est store ols`k'

do ./chn/iv.do hp_growth_real_00_06 `var'_`depvar' pop_18_33_00
est store iv`k'

local k = `k' + 1

}



estout iv* ///
  using ./output/table2_`depvar'_iv.txt,  ///
  modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 


estout ols* ///
  using ./output/tableOA27_`depvar'_ols.txt,  ///
  modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 



}


restore


