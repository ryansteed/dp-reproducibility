***AER TABLE 9
clear all
*X*X*X*
use AER_largesample,clear
*thresholds 1-7:
eststo: xi: ivreg2 opp_college pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
* outreg2 fpm using tab_newiv_opponents0, bdec(3) nocons tex(nopretty)replace
foreach var in opp_yschool reele_inc {
eststo: xi: ivreg2 `var' pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
* outreg2 fpm using tab_newiv_opponents0, bdec(3) nocons tex(nopretty) append
}
*** EDITED by Donna
estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*thresholds 1-3 vs. 4-7:
xi: ivreg2 opp_college dumm100_1 dumm100_2 dumm100_3 dumm200_1 dumm200_2 dumm200_3 (fpm100 fpm200 = fpm100hat fpm200hat) i.term i.regions ,cluster(id_city)
outreg2 fpm100 fpm200 using tab_newiv_opponents1, bdec(3) nocons tex(nopretty)replace
foreach var in opp_yschool reele_inc {
xi: ivreg2 `var' dumm100_1 dumm100_2 dumm100_3 dumm200_1 dumm200_2 dumm200_3 (fpm100 fpm200 = fpm100hat fpm200hat) i.term i.regions ,cluster(id_city)
outreg2 fpm100 fpm200 using tab_newiv_opponents1, bdec(3) nocons tex(nopretty)append
}

*threshold-by-threshold:
xi: ivreg2 opp_college dumm0_1 dumm0_2 dumm0_3 dumm1_1 dumm1_2 dumm1_3 dumm2_1 dumm2_2 dumm2_3 dumm3_1 dumm3_2 dumm3_3 dumm4_1 dumm4_2 dumm4_3 dumm5_1 dumm5_2 dumm5_3 dumm6_1 dumm6_2 dumm6_3 (fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 = fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat) i.term i.regions ,cluster(id_city)
outreg2 fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 using tab_newiv_opponents2, bdec(3) nocons tex(nopretty)replace
foreach var in opp_yschool reele_inc {
xi: ivreg2 `var' dumm0_1 dumm0_2 dumm0_3 dumm1_1 dumm1_2 dumm1_3 dumm2_1 dumm2_2 dumm2_3 dumm3_1 dumm3_2 dumm3_3 dumm4_1 dumm4_2 dumm4_3 dumm5_1 dumm5_2 dumm5_3 dumm6_1 dumm6_2 dumm6_3 (fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 = fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat) i.term i.regions ,cluster(id_city)
outreg2 fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 using tab_newiv_opponents2, bdec(3) nocons tex(nopretty)append
}

