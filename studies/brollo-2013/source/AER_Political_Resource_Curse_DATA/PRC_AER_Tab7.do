*X*X*X**TABLE 7*the impact of money on corruption as a function of opponents' type*controlling for city characteristics, such as urbanization, income & education

clear all

use AER_smallsample,clear*thresholds 1-7 (overall):

preserve

foreach z in urb literacy income {
g inter_`z'=fpm*`z'
}

*column (1) - Broad corruption
foreach x in opp_college opp_yschool {
foreach var in broad {
gen fonz1=fpm*`x'
gen fonz2=fpm_hat*`x'
xi: ivreg2 `var' fonz1 `x' pop pop_2 pop_3 (fpm=fpm_hat) urb literacy income inter_urb inter_literacy inter_income i.term i.regions,r cluster(id_city)
outreg2 fonz1 fpm  using PRC_AER_TABLE7_`x', bdec(3) nocons tex(nopretty)replace
drop fonz1 fonz2
}

*column (2, 3 and 4) - Narrow corruption, Broad - fraction of the amount, and Narrow - fraction of the amount
foreach var in narrow fraction_broad fraction_narrow {
gen fonz1=fpm*`x'
gen fonz2=fpm_hat*`x'
xi: ivreg2 `var' fonz1 `x' pop pop_2 pop_3 (fpm=fpm_hat) urb literacy income inter_urb inter_literacy inter_income i.term i.regions,r cluster(id_city)
outreg2 fonz1 fpm  using PRC_AER_TABLE7_`x', bdec(3) nocons tex(nopretty)append
drop fonz1 fonz2
}
}

restore

*thresholds 1-3:

preserve

foreach z in urb literacy income {
g inter_`z'=fpm*`z'
}

keep if pop<20377

*column (1) - Broad corruption
foreach x in opp_college opp_yschool {
foreach var in broad {
gen fonz1=fpm*`x'
gen fonz2=fpm_hat*`x'
xi: ivreg2 `var' fonz1 `x' pop pop_2 pop_3 (fpm=fpm_hat) urb literacy income inter_urb inter_literacy inter_income i.term i.regions,r cluster(id_city)
outreg2 fonz1 fpm  using PRC_AER_TABLE7_`x'_b, bdec(3) nocons tex(nopretty)replace
drop fonz1 fonz2
}

*column (2, 3 and 4) - Narrow corruption, Broad - fraction of the amount, and Narrow - fraction of the amount
foreach var in narrow fraction_broad fraction_narrow {
gen fonz1=fpm*`x'
gen fonz2=fpm_hat*`x'
xi: ivreg2 `var' fonz1 `x' pop pop_2 pop_3 (fpm=fpm_hat) urb literacy income inter_urb inter_literacy inter_income i.term i.regions,r cluster(id_city)
outreg2 fonz1 fpm  using PRC_AER_TABLE7_`x'_b, bdec(3) nocons tex(nopretty)append
drop fonz1 fonz2
}
}

restore

*thresholds 4-7:

preserve
foreach z in urb literacy income {
g inter_`z'=fpm*`z'
}
keep if pop>20377

*column (1) - Broad corruption
foreach x in opp_college opp_yschool {
foreach var in broad {
gen fonz1=fpm*`x'
gen fonz2=fpm_hat*`x'
xi: ivreg2 `var' fonz1 `x' pop pop_2 pop_3 (fpm=fpm_hat) urb literacy income inter_urb inter_literacy inter_income i.term i.regions,r cluster(id_city)
outreg2 fonz1 fpm  using PRC_AER_TABLE7_`x'_c, bdec(3) nocons tex(nopretty)replace
drop fonz1 fonz2
}

*column (2, 3 and 4) - Narrow corruption, Broad - fraction of the amount, and Narrow - fraction of the amount
foreach var in narrow fraction_broad fraction_narrow {
gen fonz1=fpm*`x'
gen fonz2=fpm_hat*`x'
xi: ivreg2 `var' fonz1 `x' pop pop_2 pop_3 (fpm=fpm_hat) urb literacy income inter_urb inter_literacy inter_income i.term i.regions,r cluster(id_city)
outreg2 fonz1 fpm  using PRC_AER_TABLE7_`x'_c, bdec(3) nocons tex(nopretty)append
drop fonz1 fonz2
}
}
restore
