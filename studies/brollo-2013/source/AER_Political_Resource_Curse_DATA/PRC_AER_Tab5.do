
***AER TABLE 5
clear all
*X*X*X*
use AER_smallsample,clear

*thresholds 1-7:
*column (1) - Broad corruption
eststo: xi: ivreg2 broad pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
* outreg2 fpm using tab_newiv0, bdec(3) nocons tex(nopretty)replace
*column (2) - Narrow corruption
eststo: xi: ivreg2 narrow pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
* outreg2 fpm using tab_newiv0, bdec(3) nocons tex(nopretty) append
*column (3) - Broad, fraction of the amount
xi: ivreg2 fraction_broad pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
outreg2 fpm using tab_newiv0, bdec(3) nocons tex(nopretty) append
*column (4) - Narrow, fraction of the amount
xi: ivreg2 fraction_narrow pop pop_2 pop_3 (fpm=fpm_hat) i.term i.regions,r cluster(id_city)
outreg2 fpm using tab_newiv0, bdec(3) nocons tex(nopretty) append

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*thresholds 1-3 vs. 4-7:
*column (1) - Broad corruption
xi: ivreg2 broad dumm100_1 dumm100_2 dumm100_3 dumm200_1 dumm200_2 dumm200_3 (fpm100 fpm200 = fpm100hat fpm200hat) i.term i.regions ,cluster(id_city)
outreg2 fpm100 fpm200 using tab_newiv1, bdec(3) nocons tex(nopretty)replace
*column (2) - Narrow corruption
xi: ivreg2 narrow dumm100_1 dumm100_2 dumm100_3 dumm200_1 dumm200_2 dumm200_3 (fpm100 fpm200 = fpm100hat fpm200hat) i.term i.regions ,cluster(id_city)
outreg2 fpm100 fpm200 using tab_newiv1, bdec(3) nocons tex(nopretty)append
*column (3) - Broad, fraction of the amount
xi: ivreg2 fraction_broad dumm100_1 dumm100_2 dumm100_3 dumm200_1 dumm200_2 dumm200_3 (fpm100 fpm200 = fpm100hat fpm200hat) i.term i.regions ,cluster(id_city)
outreg2 fpm100 fpm200 using tab_newiv1, bdec(3) nocons tex(nopretty)append
*column (4) - Narrow, fraction of the amount
xi: ivreg2 fraction_narrow dumm100_1 dumm100_2 dumm100_3 dumm200_1 dumm200_2 dumm200_3 (fpm100 fpm200 = fpm100hat fpm200hat) i.term i.regions ,cluster(id_city)
outreg2 fpm100 fpm200 using tab_newiv1, bdec(3) nocons tex(nopretty)append

*threshold-by-threshold:
*column (1) - Broad corruption
xi: ivreg2 broad dumm0_1 dumm0_2 dumm0_3 dumm1_1 dumm1_2 dumm1_3 dumm2_1 dumm2_2 dumm2_3 dumm3_1 dumm3_2 dumm3_3 dumm4_1 dumm4_2 dumm4_3 dumm5_1 dumm5_2 dumm5_3 dumm6_1 dumm6_2 dumm6_3 (fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 = fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat) i.term i.regions ,cluster(id_city)
outreg2 fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 using tab_newiv2, bdec(3) nocons tex(nopretty)replace
*column (2) - Narrow corruption
xi: ivreg2 narrow dumm0_1 dumm0_2 dumm0_3 dumm1_1 dumm1_2 dumm1_3 dumm2_1 dumm2_2 dumm2_3 dumm3_1 dumm3_2 dumm3_3 dumm4_1 dumm4_2 dumm4_3 dumm5_1 dumm5_2 dumm5_3 dumm6_1 dumm6_2 dumm6_3 (fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 = fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat) i.term i.regions ,cluster(id_city)
outreg2 fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 using tab_newiv2, bdec(3) nocons tex(nopretty)append
*column (3) - Broad, fraction of the amount
xi: ivreg2 fraction_broad dumm0_1 dumm0_2 dumm0_3 dumm1_1 dumm1_2 dumm1_3 dumm2_1 dumm2_2 dumm2_3 dumm3_1 dumm3_2 dumm3_3 dumm4_1 dumm4_2 dumm4_3 dumm5_1 dumm5_2 dumm5_3 dumm6_1 dumm6_2 dumm6_3 (fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 = fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat) i.term i.regions ,cluster(id_city)
outreg2 fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 using tab_newiv2, bdec(3) nocons tex(nopretty)append
*column (4) - Narrow, fraction of the amount
xi: ivreg2 fraction_narrow dumm0_1 dumm0_2 dumm0_3 dumm1_1 dumm1_2 dumm1_3 dumm2_1 dumm2_2 dumm2_3 dumm3_1 dumm3_2 dumm3_3 dumm4_1 dumm4_2 dumm4_3 dumm5_1 dumm5_2 dumm5_3 dumm6_1 dumm6_2 dumm6_3 (fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 = fpm0hat fpm1hat fpm2hat fpm3hat fpm4hat fpm5hat fpm6hat) i.term i.regions ,cluster(id_city)
outreg2 fpm0 fpm1 fpm2 fpm3 fpm4 fpm5 fpm6 using tab_newiv2, bdec(3) nocons tex(nopretty)append
