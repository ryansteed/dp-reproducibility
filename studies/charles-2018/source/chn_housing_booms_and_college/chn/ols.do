
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

reg $depvar $housing $controls $sample [aw=$weight], cluster(statefip)

summ $housing
local hp_growth_se = r(sd)





