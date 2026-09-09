***AER TABLE 6
clear all
*X*X*X*use AER_smallsample,clear***panel A: rerun unconditionalpreserve
replace fpm_hat=fpm_hat/10

foreach var in broad {
g interaction=before*`var'
g interaction2=before*fpm_hat
g superinteraction=interaction*fpm_hat

g pop_bc`var'=pop*before*`var'
g pop_2_bc`var'=pop_2*before*`var'
g pop_3_bc`var'=pop_3*before*`var'

g pop_c`var'=pop*`var'
g pop_2_c`var'=pop_2*`var'
g pop_3_c`var'=pop_3*`var'

g pop_b=pop*before
g pop_2_b=pop_2*before
g pop_3_b=pop_3*before

*column (1) - Broad corruption
xi: reg rerun superinteraction interaction interaction2 `var' before fpm_hat pop pop_2 pop_3 pop_bc`var' pop_2_bc`var' pop_3_bc`var' pop_c`var' pop_2_c`var' pop_3_c`var' pop_b pop_2_b pop_3_b i.regions i.term if noneligible==0,r cluster(id_city)
outreg2 superinteraction interaction interaction2 using PRC_AER_TABLE6_A, bdec(3) nocons tex(nopretty) replace
drop interaction* superinteraction
}
foreach var in narrow fraction_broad fraction_narrow {
g interaction=before*`var'
g interaction2=before*fpm_hat
g superinteraction=interaction*fpm_hat

g pop_bc`var'=pop*before*`var'
g pop_2_bc`var'=pop_2*before*`var'
g pop_3_bc`var'=pop_3*before*`var'

g pop_c`var'=pop*`var'
g pop_2_c`var'=pop_2*`var'
g pop_3_c`var'=pop_3*`var'

*column (2, 3 and 4) - Narrow corruption, Broad - fraction of the amount, and Narrow - fraction of the amount
xi: reg rerun superinteraction interaction interaction2 `var' before fpm_hat pop pop_2 pop_3 pop_bc`var' pop_2_bc`var' pop_3_bc`var' pop_c`var' pop_2_c`var' pop_3_c`var' pop_b pop_2_b pop_3_b i.regions i.term if noneligible==0,r cluster(id_city)
outreg2 superinteraction interaction interaction2 using PRC_AER_TABLE6_A, bdec(3) nocons tex(nopretty)append
drop interaction* superinteraction
}
restore***panel B: reelection conditional on rerunningpreservereplace fpm_hat=fpm_hat/10foreach var in broad {g interaction=before*`var'g interaction2=before*fpm_hatg superinteraction=interaction*fpm_hatg pop_bc`var'=pop*before*`var'g pop_2_bc`var'=pop_2*before*`var'g pop_3_bc`var'=pop_3*before*`var'g pop_c`var'=pop*`var'g pop_2_c`var'=pop_2*`var'g pop_3_c`var'=pop_3*`var'g pop_b=pop*beforeg pop_2_b=pop_2*beforeg pop_3_b=pop_3*before*column (1) - Broad corruptionxi: reg reelected superinteraction interaction interaction2 `var' before fpm_hat pop pop_2 pop_3 pop_bc`var' pop_2_bc`var' pop_3_bc`var' pop_c`var' pop_2_c`var' pop_3_c`var' pop_b pop_2_b pop_3_b i.regions i.term if noneligible==0&rerun==1,r cluster(id_city)outreg2 superinteraction interaction interaction2 using tab_punish2bisB, bdec(3) nocons tex(nopretty)replacedrop interaction* superinteraction}

*column (2, 3 and 4) - Narrow corruption, Broad - fraction of the amount, and Narrow - fraction of the amountforeach var in narrow fraction_broad fraction_narrow {g interaction=before*`var'g interaction2=before*fpm_hatg superinteraction=interaction*fpm_hatg pop_bc`var'=pop*before*`var'g pop_2_bc`var'=pop_2*before*`var'g pop_3_bc`var'=pop_3*before*`var'g pop_c`var'=pop*`var'g pop_2_c`var'=pop_2*`var'g pop_3_c`var'=pop_3*`var'xi: reg reelected superinteraction interaction interaction2 `var' before fpm_hat pop pop_2 pop_3 pop_bc`var' pop_2_bc`var' pop_3_bc`var' pop_c`var' pop_2_c`var' pop_3_c`var' pop_b pop_2_b pop_3_b i.regions i.term if noneligible==0&rerun==1,r cluster(id_city)outreg2 superinteraction interaction interaction2 using tab_punish2bisB, bdec(3) nocons tex(nopretty)appenddrop interaction* superinteraction}restore***panel C: reelection unconditionalpreservereplace fpm_hat=fpm_hat/10foreach var in broad {g interaction=before*`var'g interaction2=before*fpm_hatg superinteraction=interaction*fpm_hatg pop_bc`var'=pop*before*`var'g pop_2_bc`var'=pop_2*before*`var'g pop_3_bc`var'=pop_3*before*`var'g pop_c`var'=pop*`var'g pop_2_c`var'=pop_2*`var'g pop_3_c`var'=pop_3*`var'g pop_b=pop*beforeg pop_2_b=pop_2*beforeg pop_3_b=pop_3*before*column (1) - Broad corruptionxi: reg reelected superinteraction interaction interaction2 `var' before fpm_hat pop pop_2 pop_3 pop_bc`var' pop_2_bc`var' pop_3_bc`var' pop_c`var' pop_2_c`var' pop_3_c`var' pop_b pop_2_b pop_3_b i.regions i.term if noneligible==0,r cluster(id_city)outreg2 superinteraction interaction interaction2 using tab_punish2bisC, bdec(3) nocons tex(nopretty)replacedrop interaction* superinteraction}foreach var in narrow fraction_broad fraction_narrow {g interaction=before*`var'g interaction2=before*fpm_hatg superinteraction=interaction*fpm_hatg pop_bc`var'=pop*before*`var'g pop_2_bc`var'=pop_2*before*`var'g pop_3_bc`var'=pop_3*before*`var'g pop_c`var'=pop*`var'g pop_2_c`var'=pop_2*`var'g pop_3_c`var'=pop_3*`var'*column (2, 3 and 4) - Narrow corruption, Broad - fraction of the amount, and Narrow - fraction of the amountxi: reg reelected superinteraction interaction interaction2 `var' before fpm_hat pop pop_2 pop_3 pop_bc`var' pop_2_bc`var' pop_3_bc`var' pop_c`var' pop_2_c`var' pop_3_c`var' pop_b pop_2_b pop_3_b i.regions i.term if noneligible==0,r cluster(id_city)outreg2 superinteraction interaction interaction2 using tab_punish2bisC, bdec(3) nocons tex(nopretty)appenddrop interaction* superinteraction}
restore
