***AER TABLE 8
clear all
*X*X*X*
use AER_largesample,clear
*thresholds 1-7:
xi: reg fpm fpm_hat pop pop_2 pop_3 i.term i.regions,r cluster(id_city)
outreg2 fpm_hat using tab_jumps_opponents0, bdec(3) nocons tex(nopretty)replace
foreach var in opp_college opp_yschool reele_inc {
xi: reg `var' fpm_hat pop pop_2 pop_3 i.term i.regions,r cluster(id_city)
outreg2 fpm_hat using tab_jumps_opponents0, bdec(3) nocons tex(nopretty)append
}

*thresholds 1-3 vs. 4-7:
xi: reg fpm fpm100hat dumm100_1 dumm100_2 dumm100_3 fpm200hat dumm200_1 dumm200_2 dumm200_3 i.term i.regions,cluster(id_city)
outreg2 fpm100hat fpm200hat using tab_jumps_opponents1, bdec(3) nocons tex(nopretty)replace
foreach var in opp_college opp_yschool reele_inc {
xi: reg `var' fpm100hat dumm100_1 dumm100_2 dumm100_3 fpm200hat dumm200_1 dumm200_2 dumm200_3 i.term i.regions,cluster(id_city)
outreg2 fpm100hat fpm200hat using tab_jumps_opponents1, bdec(3) nocons tex(nopretty)append
}

*threshold by threshold:
xi: reg fpm fpm0hat dumm0_1 dumm0_2 dumm0_3 fpm1hat dumm1_1 dumm1_2 dumm1_3 fpm2hat dumm2_1 dumm2_2 dumm2_3 fpm3hat dumm3_1 dumm3_2 dumm3_3 fpm4hat dumm4_1 dumm4_2 dumm4_3 fpm5hat dumm5_1 dumm5_2 dumm5_3 fpm6hat dumm6_1 dumm6_2 dumm6_3 i.term i.regions,cluster(id_city)
outreg2 fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat using tab_jumps_opponents2, bdec(3) nocons tex(nopretty)replace
foreach var in opp_college opp_yschool reele_inc {
xi: reg `var' fpm0hat dumm0_1 dumm0_2 dumm0_3 fpm1hat dumm1_1 dumm1_2 dumm1_3 fpm2hat dumm2_1 dumm2_2 dumm2_3 fpm3hat dumm3_1 dumm3_2 dumm3_3 fpm4hat dumm4_1 dumm4_2 dumm4_3 fpm5hat dumm5_1 dumm5_2 dumm5_3 fpm6hat dumm6_1 dumm6_2 dumm6_3 i.term i.regions,cluster(id_city)
outreg2 fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat using tab_jumps_opponents2, bdec(3) nocons tex(nopretty)append
}
