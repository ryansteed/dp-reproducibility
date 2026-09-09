
preserve
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
replace hp_growth_real_00_06 = deltaP + units_growth

local age = "`1'"

global baseline = "$controls"

local vars = "d_emp_18_25_le d_wage_18_25_le d_wage_adj_18_25_le diff_a2 diff_a34"

foreach var of local vars {

est clear
local k = 1

forvalues i = 1/8 {

if (`i' == 1) {
  global controls = "$baseline"
}
if (`i' == 2) {
  global controls = ""
}
if (`i' == 3) {
  xi i.region
  global controls = "_I*"
}
if (`i' == 4) {
  capture drop _I*
  gen _I0 = 0
  global controls = "$baseline _I* manuf_18_55_2000"
}
if (`i' == 5) {
  capture drop _I*
  gen _I0 = 0
  global controls = "$baseline _I* routine_share_2000"
}
if (`i' == 6) {
  capture drop _I*
  gen _I0 = 0
  global controls = "$baseline _I* unemp_18_55_2000"
}
if (`i' == 7) {
  capture drop _I*
  gen _I0 = 0
  global controls = "$baseline _I* manuf_18_55_2000 routine_share_2000 unemp_18_55_2000"
}
if (`i' == 8) {
  capture drop _I*
  xi i.region
  global controls = "$baseline _I* manuf_18_55_2000 routine_share_2000 unemp_18_55_2000"
}
if (`i' == 13) {
  capture drop _I*
  xi i.reg4
  global controls = "$baseline _I* manuf_18_55_2000 routine_share_2000 unemp_18_55_2000"
}
if (`i' == 10) {
  xi i.region
  global controls = "$baseline _I* routine_share_2000"
}
if (`i' == 11) {
  xi i.region
  global controls = "$baseline _I* unemp_18_55_2000"
}
if (`i' == 12) {
  xi i.region
  global controls = "$baseline _I* manuf_18_55_2000 routine_share_2000 unemp_18_55_2000"
}
if (`i' == 13) {
  xi i.region*college_share i.region*female_employ i.region*pop_prev i.region*share_foreign_18_55_2000
  global controls = "$baseline _I* manuf_18_55_2000 routine_share_2000 unemp_18_55_2000"
}


capture drop wgt
gen wgt = exp(pop_prev)

summ $controls hp_growth_real_00_06 wgt `var' diff_a2 [aw=wgt] if diff_a2 < .
do ./chn/iv.do hp_growth_real_00_06 `var' wgt
est store iv`k'

local k = `k' + 1

estout iv* ///
  using ./output/tableOA25_robust_`var'_iv.txt,  ///
  stats(Fstat N r2, fmt(%9.3f)) modelwidth(10) varwidth(25) ///
  keep(hp_growth_real_00_06) ///
  cells(b( fmt(%9.5f)) se( fmt(%9.3f)) p( fmt(%9.3f)) ) style(fixed) replace notype mlabels(, numbers ) 

}

}

restore


