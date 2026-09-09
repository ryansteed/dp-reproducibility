********************************************************************************	
* Sum upstream-downstream, other outcomes
*

scalar first_reg=1

foreach y in r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_genito r_baby_death_illdef r_baby_death_others FMR sex_ratio IMR_masc IMR_fem s_birth_lowbirthw s_gesta_preterm s_gesta_below22 s_gesta_22_27 s_gesta_28_36 s_gesta_37_41 s_gesta_above42 s_lowapgar1 s_lowapgar5 birth_rate birth_motheredclow_mean birth_motheredcmid_mean birth_motheredchigh_mean birth_motherage_mean{
xi: xtreg `y' sum_pot $instr $control, fe cluster(basin)

	sum `y' if e(sample)==1 & year==2000
	eret2 scalar y_mean_baseline=r(mean)
	
	if first_reg ==1 {
		outreg2 using "$pathresults/$table_sum_other",  aster(se) dec(3) label nocons e(y_mean_baseline) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr sum_pot) replace
		scalar first_reg = 0
	}
	else{
		outreg2 using "$pathresults/$table_sum_other",  aster(se) dec(3) label nocons e(y_mean_baseline) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr sum_pot) append
	}
}
