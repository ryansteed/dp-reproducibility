
preserve
est clear



capture drop diff*
sort metarea
merge metarea using ./chn/ipeds_long_diff2.dta
assert _merge != 2
tab _merge, missing
drop _merge




keep if hp_growth_real_00_06 < .



global summ_list1 = "deltaP units_growth hp_growth_real_00_06 iv"
global summ_list2 = "d_emp_18_25_le d_wage_18_25_le"
global summ_list3 = "diff_a2 diff_a34 init_a2 init_a34"



matrix table1 = J(38, 9, 0)

local i = 1
foreach var of varlist $summ_list1 $summ_list2 $summ_list3 {

 di " - - - - - - "
 di "summarizing variables `var' ..."
 di " - - - - - - "


 summ `var' [aw=pop_18_33_00], det


 matrix table1[`i', 1] = r(N)
 matrix table1[`i', 2] = r(mean)
 matrix table1[`i', 3] = r(sd)
 matrix table1[`i', 4] = r(p10)
 matrix table1[`i', 5] = r(p25)
 matrix table1[`i', 6] = r(p50)
 matrix table1[`i', 7] = r(p75)
 matrix table1[`i', 8] = r(p90)

 local i = `i' + 1
}

matrix list table1
drop _all
svmat table1
rename table11 N
rename table12 mean
rename table13 sd

rename table14 p10
rename table15 p25
rename table16 p50
rename table17 p75
rename table18 p90

outsheet using ./output/tableOA1_summ_stats.txt, replace

restore

exit


