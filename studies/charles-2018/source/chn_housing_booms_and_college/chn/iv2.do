
global housing = "deltaP units_growth"
global depvar = "`2'"

global weight = "msa_total_emp_all_2000"
if ("`3'" == "") {
 global weight = "msa_total_emp_all_2000"
}
else {
 global weight = "`3'"
}

global weight = "pop_18_44_00"

di "IV: housing: $housing, depvar: $depvar, wgt: $weight ..."

ivreg2 $depvar ($housing = $instruments) $controls $sample [aw=$weight], cluster(statefip)

post_param "Fstat" e(widstat)

if ($num > 10) {
 ereturn list
 post_param "overid" e(j)
 post_param "overid_p" e(jp)
}

summ deltaP
local p_growth_se = r(sd)

summ units_growth
local q_growth_se = r(sd)

if ("`4'" != "off") {
 post_param "p_growth_se" _b[deltaP]*(`p_growth_se')
 post_param "q_growth_se" _b[units_growth]*(`q_growth_se')
}

