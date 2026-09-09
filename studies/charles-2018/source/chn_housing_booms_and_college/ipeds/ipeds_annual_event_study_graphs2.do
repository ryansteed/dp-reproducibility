
clear
set more off

graph set eps fontface "Times New Roman"
graph set eps logo off
graph set eps

insheet using ./ipeds_event_study_graph_`1'_`2'.txt

local inv_golden_ratio = 2 / ( sqrt(5) + 1 )
rename t time

gen zero = 0
local N = _N + 2
set obs `N'
gen vline = .
replace time = -0.4999 if _n == _N - 1
replace time = -0.5001 if _n == _N

if ("`1'" == "enrollment") {
 local type = "total"
}
if ("`1'" == "men") {
 local type = "male"
}
if ("`1'" == "women") {
 local type = "female"
}

foreach var of varlist assoc {

if ("`var'" == "assoc") {
 local ylabel = "-0.15(0.05)0.05"
 local yscale = "-0.171 0.059"
 replace vline = -0.169 if _n == _N - 1
 replace vline =  0.057 if _n == _N
}
 
capture drop lower
capture drop upper
gen lower = `var' - 1.96 * `var'_se
gen upper = `var' + 1.96 * `var'_se

format `var' upper lower %-4.2f

twoway ///
 (scatter zero time, sort connect(l) symbol(i) lcolor(black) ) ///
 (scatter vline time, sort connect(l) symbol(i) lcolor(red) ) ///
 (scatter `var' time , sort connect(l) symbol(o) mcolor(navy) lcolor(navy) ) ///
 (scatter upper time if time < -1, sort connect(l) lpattern(dash) symbol(i) lcolor(navy*.3) ) ///
 (scatter upper time if time >= 0, sort connect(l) lpattern(dash) symbol(i) lcolor(navy*.3) ) ///
 (scatter lower time if time < -1, sort connect(l) lpattern(dash) symbol(i) lcolor(navy*.3) )  ///
 (scatter lower time if time >= 0, sort connect(l) lpattern(dash) symbol(i) lcolor(navy*.3) ) ///
     , ///
     scheme(s2color) graphregion(fcolor(white)) ///
     aspectratio(`inv_golden_ratio') ///
     legend(off) xlabel(-4(1)5) ///
     xtitle("Years before/after structural break") ///     		 
     subtitle("Change in `type' enrollment per capita") ///
     ytitle("") ///  
     ylabel(`ylabel') yscale(r(`yscale'))
graph export ../output/fig13_ipeds_evt_study_`var'_`1'.eps, replace
!epstopdf ../output/fig13_ipeds_evt_study_`var'_`1'.eps
!sz ../output/fig13_ipeds_evt_study_`var'_`1'.pdf

}

