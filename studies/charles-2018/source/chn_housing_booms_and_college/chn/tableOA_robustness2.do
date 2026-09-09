
est clear


global instruments = "iv"
global num = 1


capture drop diff*
sort metarea
merge metarea using ./chn/ipeds_long_diff2.dta
assert _merge != 2
tab _merge, missing
drop _merge

keep if hp_growth_real_00_06 < .

local age = "`1'"

global baseline = "$controls"

local vars = "d_emp_18_25_le d_wage_18_25_le d_wage_adj_18_25_le diff_a2 diff_a34"

foreach var of local vars {

est clear
local k = 1

forvalues i = 1/7 {

preserve

if (`i' == 1) {
}
if (`i' == 2) {
 replace iv = iv_sig
}
if (`i' == 3) {
 replace iv = iv_sig2
}
if (`i' == 4) {
 replace iv = iv2_poly3
}
if (`i' == 5) {

replace iv = price_rent_ratio

}
if (`i' == 6) {
 replace hp_growth_real_00_06 = deltaP
}
if (`i' == 7) {
 replace hp_growth_real_00_06 = deltaP * (1 + elasticity) * 0.57 / 1.33
}


capture drop wgt
gen wgt = exp(pop_prev)


do ./chn/iv.do hp_growth_real_00_06 `var' wgt
est store iv`k'

local k = `k' + 1

restore
}

estout iv* ///
  using ./outuput/tableOA26_robust2_`var'_iv.txt,  ///
  stats(Fstat N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

}

exit



