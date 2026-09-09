 
clear
set more off



use chn/housing_prices_time_series.dta
sort year
merge year using chn/permits_pctiles, uniqusing uniqmaster


gen d10 = (p10 + p10_permits) / 2
gen d50 = (pct + pct_permits) / 2
gen d90 = (p90 + p90_permits) / 2

twoway ///
 (connected d10 year if d10 < ., sort msymbol(i) lpattern(shortdash) lwidth(medthin) lcolor(navy*.9) ) ///
 (connected d50 year if d50 < ., sort msymbol(i) lpattern(solid) lwidth(medthin) lcolor(maroon*.9) ) ///
 (connected d90 year if d90 < ., sort msymbol(i) lpattern(longdash) lwidth(medthin) lcolor(forest_green*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(on) legend(cols(3) order(1 2 3)) legend(label(1 "10th Percentile") label(2 "Median") label(3 "90th Percentile")) ///
   xline(1997, lcolor(gs11)) xline(2006, lcolor(gs11)) ///
   xlabel(1990(5)2010) xscale(r(1989 2011)) ytitle("Housing Demand Index") xtitle("Year")
 graph export output/fig7_demand_pctiles.eps, replace
 !epstopdf output/fig7_demand_pctiles.eps
 *!sz output/fig7_demand_pctiles.pdf



 **
clear
insheet using chn/education_trends_cps_all.txt

replace smc_xb = .

twoway ///
 (connected smc  year , sort msymbol(i) lpattern(solid) lwidth(medium) lcolor(navy*.9) ) ///
 (connected smc_xb  year , sort msymbol(i) lpattern(dash) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Share Having Attended Any College (Men and Women, Age 18-33)") ) ///
   xline(1997, lcolor(gs11)) xline(2006, lcolor(gs11)) ///
   xlabel(1980(5)2010) xscale(r(1980 2013)) yscale(r(0.3999 0.6001)) ylabel(0.4(0.04)0.6) ytitle("Share of Population") ///
   xtitle("Year") 
graph export output/fig_educ_all.eps, replace
!epstopdf output/fig_educ_all.eps
*!sz output/fig_educ_all.pdf

clear
insheet using chn/education_trends_cps.txt

replace smc0_xb = .
replace smc1_xb = .

sort year
merge year using ./chn/fhfa_natl, uniqusing uniqmaster
tab _merge, missing
drop if _merge == 2

twoway ///
 (connected smc0  year , sort msymbol(i) lpattern(solid) lwidth(medium) lcolor(navy*.9) ) ///
 (connected smc0_xb  year , sort msymbol(i) lpattern(dash) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Share Having Attended Any College (Men, Age 18-33)") ) ///
   xline(1997, lcolor(gs11)) xline(2006, lcolor(gs11)) ///
   xlabel(1980(5)2010) xscale(r(1980 2013)) yscale(r(0.395 0.605)) ylabel(0.4(0.04)0.6) ytitle("Share of Population") ///
   xtitle("Year") 
graph export output/fig_educ_m.eps, replace
!epstopdf output/fig_educ_m.eps
*!sz output/fig_educ_m.pdf

twoway ///
 (connected smc1  year , sort msymbol(i) lpattern(solid) lwidth(medium) lcolor(navy*.9) ) ///
 (connected smc1_xb  year , sort msymbol(i) lpattern(dash) lwidth(medium) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(cols(1) order(1) colfirst) legend(label(1 "Share Having Attended Any College (Women, Age 18-33)") ) ///
   xline(1997, lcolor(gs11)) xline(2006, lcolor(gs11)) ///
   xlabel(1980(5)2010) xscale(r(1980 2013)) yscale(r(0.415 0.665)) ylabel(0.42(0.04)0.66) ytitle("Share of Population") ///
   xtitle("Year") 
graph export output/fig_educ_f.eps, replace
!epstopdf output/fig_educ_f.eps
*!sz output/fig_educ_f.pdf





**
clear
insheet using ./chn/units_natl.txt
sort year
gen units1 = units[1]
gen units_pct = units / units1
drop units1
sort year
save ./chn/units_natl.dta, replace




clear
insheet using ./chn/total_sales.txt
sort year
save ./chn/total_sales, replace

clear
insheet using ./chn/cpi_annual.txt
replace cpi = cpi / 82.4
sort year
save ./chn/cpi.dta, replace
list


clear
insheet using ./chn/fhfa_3q13hpi_reg.txt
desc, full
rename v1 area
rename v2 year
rename v3 q
rename v4 hpi
keep if area == "USA" & q == 1
collapse (mean) hpi, by(year)
sort year
merge year using ./chn/cpi.dta, uniqusing uniqmaster
keep if _merge == 3
drop _merge
sort year
gen year1985 = year - 1985
reg hpi year1985 if year < 1995
replace hpi = hpi / cpi 
save ./chn/fhfa_natl.dta, replace
list





clear
insheet using chn/intro_figures_data_only.txt

keep if year >= 1980

capture drop yearm miny maxy

sort year
gen yearm = .
replace yearm = 1997 if _n == 1
replace yearm = 2007 if _n == 2

gen miny = 8 if yearm < .
gen maxy = 18 if yearm < .

sort year
merge year using ./chn/fhfa_natl, uniqusing uniqmaster
tab _merge, missing
drop if _merge == 2
drop _merge

sort year
merge year using ./chn/total_sales, uniqusing uniqmaster
tab _merge, missing
keep if _merge == 3
drop _merge

sort year
merge year using ./chn/cps_figs/cons_fire_18_25, uniqusing uniqmaster
tab _merge, missing
keep if _merge == 3
drop _merge


sort year
twoway ///
 (connected hpi year, sort msymbol(i) lpattern(longdash) lwidth(medthin) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(on) legend(cols(1) order(1)) legend(label(1 "FHFA National Home Price Index")) ///
   xline(1997, lcolor(gs11)) xline(2006, lcolor(gs11)) ///
   xlabel(1980(5)2010) xscale(r(1980 2011)) ytitle("Home Price Index") xtitle("Year")
 graph export output/fig_hpi.eps, replace
 !epstopdf output/fig_hpi.eps
 !sz output/fig_hpi.pdf



sort year
gen hpi1 = hpi[1]
gen hpi_pct = hpi / hpi1
twoway ///
 (connected hpi_pct year, sort msymbol(i) lpattern(longdash) lwidth(medthin) lcolor(navy*.9) ), ///
   scheme(s2color) graphregion(fcolor(white)) ///
   legend(on) legend(cols(1) order(1)) legend(label(1 "Housing Permits Index")) ///
   xline(1997, lcolor(gs11)) xline(2006, lcolor(gs11)) ///
   xlabel(1990(5)2010) xscale(r(1988 2012)) ytitle("Home Price Index") xtitle("Year")
 graph export output/fig_hpi2.eps, replace
 !epstopdf output/fig_hpi2.eps
 !sz output/fig_hpi2.pdf



exit













