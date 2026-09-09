
global housing = "`1'"
global depvar = "`2'"

global weight = "msa_total_emp_all_2000"
if ("`3'" == "") {
 global weight = "msa_total_emp_all_2000"
}
else {
 global weight = "`3'"
}

di "IV: housing: $housing, depvar: $depvar, wgt: $weight ..."

ivreg2 $depvar ($housing = $instruments) $controls $sample [aw=$weight], cluster(statefip)

post_param "Fstat" e(widstat)

summ $housing
local hp_growth_se = r(sd)

if ("`4'" != "off") {
 post_param "hp_growth_se" _b[$housing]*(`hp_growth_se')
}
