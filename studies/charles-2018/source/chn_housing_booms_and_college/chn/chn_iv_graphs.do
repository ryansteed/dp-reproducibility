

capture drop xb
capture drop resid
reg deltaP_06_11 deltaP [aw=msa_total_emp_lowed_2000]
predict xb, xb
replace xb = -1*deltaP
gen resid = deltaP_06_11 + deltaP

replace xb = . if deltaP < 0

gsort -pop_prev
list metarea pop_prev

drop hpi2006
gen hpi2006 = exp(deltaP + log(hpi2000))
gen hpi2011 = exp(deltaP_06_11 + log(hpi2006))

gen test1 = (hpi2011 - hpi2000)/hpi2000
gen test2 = log(hpi2011) - log(hpi2000)
summ test1 test2 deltaP_00_11

twoway    (connected xb deltaP, sort msymbol(i) lpattern(solid) lcolor(black*.55) ) ///
   (scatter deltaP_06_11 deltaP [aw=msa_total_emp_lowed_2000], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (pcarrowi -0.75 0.58 -0.65 0.64 (9) "45-degree line", mcolor(gray*.9) lcolor(gray*.9) legend(off) mlwidth(vthin) mlabsize(small) mlabcolor(black*.55)) ///
   , ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(0(0.2)1.4) xscale(r(-0.06 1.04)) xtitle("House price growth, 2000-2007") ytitle("House price growth, 2007-2011") 
 graph export output/fig10_scatter.eps, replace
 !epstopdf output/fig10_scatter.eps







reg units_growth deltaP [aw=msa_total_emp_all_2000] if units_growth < 1.5
capture drop xb
predict xb, xb
twoway ///
 (scatter units_growth deltaP [aw=pop_18_33_00] if units_growth < 1.5, sort msize(small) mcolor(none) mlcolor(navy*0.8) mlwidth(vthin) ) ///
  (connected xb deltaP, sort msymbol(i) lcolor(navy*.8) ) , ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(off) ytitle("Change in housing permits, 2000-2006") xtitle("Change in home price index, 2000-2006")
 graph export output/fig6_scatter_dp_dq.eps, replace
 !epstopdf output/fig6_scatter_dp_dq.eps
 *!sz output/fig6_scatter_dp_dq.pdf





sort metarea
merge metarea using ./chn/ipeds_long_diff2_placebo.dta
assert _merge != 2
tab _merge, missing
drop _merge

keep if hp_growth_real_00_06 < .

gen hpi1990 = exp(log(hpi2000) - hp_growth_real_90_00)
gen hpi1995 = exp(hp_growth_real_90_95 + log(hpi1990))

foreach var of varlist diff_* init_* hpi1990 {
 reg `var' iv [aw=pop_18_33_00], cluster(statefip)
}

gen init_emp = emp_18_29_90 / pop_18_29_90
gen init_wage = wage_18_29_90 / full_18_29_90

foreach var of varlist hp_growth_real_90_95 hpi1990 init_emp  init_wage pop_prev college_share_2000 female_employed_share_2000 diff_a2 diff_a34 init_a2 init_a34 {
 capture drop xb
 reg `var' iv [aw=pop_18_33_00], cluster(statefip)
 reg `var' iv [aw=pop_18_33_00], robust
 predict `var'_xb, xb
 corr `var' iv [aw=pop_18_33_00]
}






capture drop _merge
sort metarea
merge metarea using ./chn/mayer_data.dta, uniqusing uniqmaster
tab _merge, missing
drop _merge

**
** Drop LA because not in Zillow or Dataquick
replace dis_diff = . if metarea == 448
**


replace dis_diff = dis_diff / 100

capture drop xb
reg dis_diff iv [aw=pop_18_33_00], cluster(statefip)
predict xb, xb
local r = sqrt(e(r2))
test iv
local p = r(p)

est clear

gen share = own_occ_sales / pop_18_33_00
sort share

sort metarea
merge metarea using ./chn/fhfa/Zillow_metareas
drop if _merge == 2

list metarea share iv dis_diff pop_prev dataquick turnover _merge if dis_diff < .

reg dis_diff iv [aw=pop_18_33_00], cluster(statefip)
est store mayer_base
reg dis_diff iv $controls [aw=pop_18_33_00], cluster(statefip)
est store mayer_cntrls
reg dis_diff iv $controls i.region [aw=pop_18_33_00], cluster(statefip)
est store mayer_cntrls_regFE

reg price_rent_ratio iv [aw=pop_18_33_00], cluster(statefip)
est store p_rent_base
reg price_rent iv $controls [aw=pop_18_33_00], cluster(statefip)
est store p_rent_cntrls
reg price_rent iv $controls i.region [aw=pop_18_33_00], cluster(statefip)
est store p_rent_cntrls_regFE

twoway (scatter dis_diff iv [aw=pop_18_33_00], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
       (connected xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.008 0.12 "slope = 0.15 (0.05), R{superscript:2} = 0.43", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(0(0.01)0.06) yscale(r(-0.005 0.065)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Change in Share of Out-of-Town Buyers")

 graph export output/fig12_corr_mayer.eps, replace
 !epstopdf output/fig12_1corr_mayer.eps
* !sz output/fig12_corr_mayer.pdf



capture drop xb
reg price_rent_ratio iv [aw=pop_18_33_00], cluster(statefip)
predict xb, xb

twoway (scatter price_rent_ratio iv [aw=pop_18_33_00], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
       (connected xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.08 0.1 "slope = 3.81 (0.71), R{superscript:2} = 0.54", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(-0.2(0.2)1.2) yscale(r(-0.25 1.25)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Growth in Price-to-Rent Ratio, 2000-2007")

 graph export output/fig12_price_rent_full.eps, replace
 !epstopdf output/fig12_price_rent_full.eps
* !sz output/fig12_price_rent_full.pdf





twoway (scatter hp_growth_real_90_95 iv [aw=pop_18_33_00], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected hp_growth_real_90_95_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(-0.6 0.1 "slope = -0.56 (0.47), R{superscript:2} = 0.06", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(-1.0(0.2)1.0) yscale(r(-1.03 1.03)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Lagged House Price Growth, 1990-1995") 
 graph export output/fig11_corr_lagged_hp.eps, replace
 !epstopdf output/fig11_corr_lagged_hp.eps
* !sz output/fig11_corr_lagged_hp.pdf


twoway (scatter hpi1990 iv [aw=pop_18_33_00], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected hpi1990_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.25 0.1 "slope = 0.50 (0.35), R{superscript:2} = 0.09", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(0.2(0.2)1.2) yscale(r(0.17 1.23)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("House Price Index, 1990")
 graph export output/fig11_corr_hpi1990.eps, replace
 !epstopdf output/fig11_corr_hpi1990.eps
* !sz output/fig11_corr_hpi1990.pdf



twoway (scatter init_emp iv [aw=pop_18_33_00], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected init_emp_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.54 0.1 "slope = -0.04 (0.08) R{superscript:2} = 0.003", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(0.5(0.1)0.9) yscale(r(0.49 0.91)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Employment Rate in 2000") 
 graph export output/fig11_corr_init_emp.eps, replace
 !epstopdf output/fig11_corr_init_emp.eps
* !sz output/fig11_corr_init_emp.pdf


twoway (scatter init_wage iv [aw=pop_18_33_00], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected init_wage_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(7.3 0.1 "slope = 0.57 (3.01), R{superscript:2} = 0.001", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(5(5)20) yscale(r(4.99 20.01)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Average Wage in 1990") 
 graph export output/fig11_corr_init_wage.eps, replace
 !epstopdf output/fig11_corr_init_wage.eps
* !sz output/fig11_corr_init_wage.pdf


twoway (scatter diff_a2 iv [aw=pop_18_33_00] if (diff_a2 > -0.15 & diff_a2 < 0.15), msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected diff_a2_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.05 0.1 "slope = 0.01 (0.04), R{superscript:2} = 0.0003", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(-0.15(0.05)0.15) yscale(r(-0.151 0.151)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Two-year college enrollment per capita, 1990-1996 change")
 graph export output/fig11_corr_diff_a2.eps, replace
 !epstopdf output/fig11_corr_diff_a2.eps
* !sz output/fig11_corr_diff_a2.pdf

twoway (scatter diff_a34 iv [aw=pop_18_33_00] if (diff_a34 > -0.1 & diff_a34 < 0.1), msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected diff_a34_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.05 0.1 "slope = 0.003 (0.01), R{superscript:2} = 0.0004", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(-0.10(0.05)0.10) yscale(r(-0.101 0.101)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Four-year college enrollment per capita, 1990-1996 change")
 graph export output/fig11_corr_diff_a34.eps, replace
 !epstopdf output/fig11_corr_diff_a34.eps
* !sz output/fig11_corr_diff_a34.pdf




twoway (scatter init_a2 iv [aw=pop_18_33_00] if (init_a2 < 0.3), msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected init_a2_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.20 0.1 "slope = 0.08 (0.06), R{superscript:2} = 0.02", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(0.0(0.05)0.30) yscale(r(-0.001 0.301)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Two-year college enrollment per capita, 1990 level")
 graph export output/fig11_corr_init_a2.eps, replace
 !epstopdf output/fig11_corr_init_a2.eps
* !sz output/fig11_corr_init_a2.pdf

twoway (scatter init_a34 iv [aw=pop_18_33_00], msize(small) mcolor(none) mlcolor(navy*.8) mlwidth(vthin) ) ///
   (connected init_a34_xb iv, sort msymbol(i) lcolor(navy*.8) ) , ///
   text(0.20 0.1 "slope = 0.07 (0.04), R{superscript:2} = 0.02", place(e) size(small)) ///
   scheme(s2color) graphregion(fcolor(white)) legend(off) ///
   xlabel(-0.1(0.1)0.3) ylabel(0.0(0.05)0.30) yscale(r(-0.001 0.301)) ///
   xtitle("Magnitude of Structural Break (Housing Demand Instrument)") ///
   ytitle("Four-year college enrollment per capita, 1990 level")
 graph export output/fig11_corr_init_a34.eps, replace
 !epstopdf output/fig11_corr_init_a34.eps
* !sz output/fig11_corr_init_a34.pdf



