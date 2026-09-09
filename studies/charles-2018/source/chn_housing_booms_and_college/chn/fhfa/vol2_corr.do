clear
set more off


use metarea_vol.dta
collapse (sum) total_vol, by(year q)
gen log_vol = log(total_vol)
summ log_vol
replace log_vol = 100 * (log_vol + 1 - r(min))

gen yq = year + (q - 0.5) / 4

twoway (connected log_vol yq, sort msymbol(i) lcolor(navy*.8) ) , ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xtitle("Year") ///
   ytitle("Housing volume index")

 graph export ./season_all.eps, replace
 !epstopdf ./season_all.eps
 !sz ./season_all.pdf


clear
use ../housing_demand_shock.dta
sort metarea
save ../housing_demand_shock.dta, replace

clear
use ./new_iv2_log.dta
*use ./new_iv2_turnover

sort metarea
merge metarea using ./new_iv2_vol2
*merge metarea using ./new_iv2_vol
drop _merge

sort metarea
merge metarea using ../housing_demand_shock.dta


summ t_* [aw=wgt]

reg t_* [aw=wgt]
replace t_vol2 = t_vol2 - 8
reg t_* [aw=wgt]



corr iv2* [aw=wgt]
reg iv2_vol iv2_log [aw=wgt]


reg iv2*

corr t_*

reg housing_demand_shock iv2_log [aw=wgt]
reg housing_demand_shock iv2_vol [aw=wgt]
replace iv = iv2_log + iv2_vol
reg housing_demand_shock iv [aw=wgt]
reg housing_demand_shock iv2_log iv2_vol [aw=wgt]

gen diff = t_vol - t_log

twoway ///
   (histogram diff, start(-20) width(1) gap(20) color(navy*.8) fraction ),  ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xtitle("Difference (in Quarters) Between Timing of Volume and Price Structural Break") ///
   xlabel(-20(4)20)

 graph export ./corr_t.eps, replace
 !epstopdf ./corr_t.eps
 !sz ./corr_t.pdf

twoway ///
   (histogram diff, start(-20) width(2) gap(10) color(navy*.8) fraction ),  ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xtitle("Difference (in Quarters) Between Timing of Volume+Price and Price Structural Break") ///
   xlabel(-20(4)20)

 graph export ./corr_t2.eps, replace
 !epstopdf ./corr_t2.eps
 !sz ./corr_t2.pdf




*gen wgt_old = wgt
drop wgt
capture drop _merge*
sort metarea
merge metarea using ../main_data.dta
keep if _merge == 3
keep if iv2_log < .
keep if iv2_vol < .

replace iv2_log = exp(4*iv2_log)-1
replace iv2_vol = exp(4*iv2_vol)-1

reg iv2_vol iv2_log [aw=wgt]
*reg iv2_vol iv2_log [aw=wgt_old]
predict xb, xb


local r = sqrt(e(r2))
test iv
local p = r(p)


twoway (scatter iv2_vol iv2_log [aw = wgt], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
       (connected xb iv2_log, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(-0.12 0.12 "slope = 1.06 (0.14), R{superscript:2} = 0.43", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.2(0.1)0.4) ylabel(-0.2(0.1)0.4) yscale(r(-0.23 0.43)) xscale(r(-0.23 0.43)) ///
   xtitle("Magnitude of Structural Break (Price only)") ///
   ytitle("Magnitude of Structural Break (log Price + log Volume)")

 graph export ./corr_vol2.eps, replace
 !epstopdf ./corr_vol2.eps
 !sz ./corr_vol2.pdf





