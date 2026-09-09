
global housing = "deltaP units_growth_alt"
global depvar = "`2'"

global weight = "msa_total_emp_all_2000"
if ("`3'" == "") {
 global weight = "msa_total_emp_all_2000"
}
else {
 global weight = "`3'"
}

global weight = "pop_18_33_00"

di "IV: housing: $housing, depvar: $depvar, wgt: $weight ..."

reg $depvar $housing $controls $sample [aw=$weight], cluster(statefip)

summ deltaP
local p_growth_se = r(sd)

summ units_growth
local q_growth_se = r(sd)

test _b[units_growth] == _b[deltaP] 
post_param "test_eq" r(p)

if ("`4'" != "off") {
 post_param "p_growth_se" _b[deltaP]*(`p_growth_se')
 post_param "q_growth_se" _b[units_growth]*(`q_growth_se')
}



