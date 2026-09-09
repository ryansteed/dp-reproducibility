********************************************************************************
* Characterization & Heterogeneity: Other Birth Outcomes
*

scalar first_reg=1

foreach y in r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_genito r_baby_death_illdef r_baby_death_others FMR sex_ratio IMR_masc IMR_fem s_birth_lowbirthw s_gesta_preterm s_gesta_below22 s_gesta_22_27 s_gesta_28_36 s_gesta_37_41 s_gesta_above42 s_lowapgar1 s_lowapgar5 birth_rate birth_motheredclow_mean birth_motheredcmid_mean birth_motheredchigh_mean birth_motherage_mean{
xi: xtreg `y' $instr $control, fe cluster(basin)

	sum `y' if e(sample)==1 & year==2000
	eret2 scalar y_mean_baseline=r(mean)
	
	
	if first_reg ==1 {
		outreg2 using "$pathresults/$table_other_outcomes",  aster(se) dec(3) label nocons e(y_mean_baseline) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr) replace
		scalar first_reg = 0
	}
	else{
		outreg2 using "$pathresults/$table_other_outcomes",  aster(se) dec(3) label nocons e(y_mean_baseline) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr) append
	}
}

foreach y in r_baby_death_infectious r_baby_death_respiratory r_baby_death_perinatal r_baby_death_congenital r_baby_death_external r_baby_death_endoc_nut r_baby_death_genito r_baby_death_illdef r_baby_death_others FMR sex_ratio IMR_masc IMR_fem s_birth_lowbirthw s_gesta_preterm s_gesta_below22 s_gesta_22_27 s_gesta_28_36 s_gesta_37_41 s_gesta_above42 s_lowapgar1 s_lowapgar5 birth_rate birth_motheredclow_mean birth_motheredcmid_mean birth_motheredchigh_mean birth_motherage_mean{
xi: xtivreg2 `y' ($glyph_up=$instr) $control, fe cluster(basin) partial(int_uf*)

	sum `y' if e(sample)==1 & year==2000
	eret2 scalar y_mean_baseline=r(mean)
	
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	
	outreg2 using "$pathresults/$table_other_outcomes",  aster(se) dec(3) label nocons e(y_mean_baseline) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up) append
}
