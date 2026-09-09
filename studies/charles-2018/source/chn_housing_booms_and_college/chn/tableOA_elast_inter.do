
preserve
est clear


global instruments = "iv"
global num = 1

local age = "`1'"

local depvars = "`age'_le `age'_le_m `age'_le_f"
local depvars = "`age'_le"

if ("`2'" == "dummy") {
summ elasticity [aw=pop_18_33_00]
replace elasticity = (elasticity > r(mean)) if elasticity < .
}

gen demandXelast = hp_growth_real_00_06 * elasticity
gen ivXelast = iv * elasticity

foreach depvar of local depvars {

est clear
local k = 1

local vars = "d_emp d_wage d_ewage d_cons d_fire"

foreach var of local vars {

reg `var'_`depvar' hp_growth_real_00_06 demandXelast $controls [aw=pop_18_33_00], cluster(statefip)
reg `var'_`depvar' hp_growth_real_00_06 demandXelast elasticity $controls [aw=pop_18_33_00], cluster(statefip)

est store ols`k'

ivreg2 `var'_`depvar' (hp_growth_real_00_06 demandXelast = iv ivXelast) $controls [aw=pop_18_33_00], cluster(statefip)
ivreg2 `var'_`depvar' (hp_growth_real_00_06 demandXelast = iv ivXelast) elasticity $controls [aw=pop_18_33_00], cluster(statefip)
ereturn list

post_param "Fstat" e(widstat)
est store iv`k'

local k = `k' + 1

}

estout ols* ///
  using ./output/tableOA22_elast_`2'_`depvar'_ols.txt,  ///
  stats(mean N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06 demandX*) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

estout iv* ///
  using ./output/tableOA22_elast_`2'_`depvar'_iv.txt,  ///
  stats(Fstat N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06 demandX*) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

}


restore


