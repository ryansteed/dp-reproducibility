clear
set more off



use new_iv2_log.dta

desc, full

rename t_log break_yq
gen break_y = 2000 + floor((break_yq - 1)/4)
gen break_q = break_yq - 4*(break_y-2000)

gen break_magnitude = exp(4*iv2_log)-1

tab break_q

keep metarea break*
sort metarea
isid metarea
save structural_breaks_2000_2005.dta, replace



clear
use new_iv7_log_p10_RAW.dta

desc, full

rename t1 break_yq
gen break_y = 1995 + floor((break_yq - 1)/4)
gen break_q = break_yq - 4*(break_y-1995)

gen break_magnitude = exp(4*diff1)-1

tab break_q

keep metarea break*
sort metarea
isid metarea
save structural_breaks_1995_2005.dta, replace



!sz structural_breaks*dta



rename break_magnitude b2
rename break_yq tyq
rename break_y ty
rename break_q tq

sort metarea
merge metarea using structural_breaks_2000_2005
assert _merge == 3
