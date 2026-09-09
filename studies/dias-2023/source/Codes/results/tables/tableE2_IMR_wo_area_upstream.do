********************************************************************************
*** Appendix - Effects on IMR excluding AMCs without area upstream


* Main results

xi: xtreg IMR $instr $no_control if area_upstream_ha>0, fe cluster(basin)
	sum IMR if year==2000&area_upstream_ha>0
	eret2 scalar IMR_position_mean=r(mean)
	outreg2 using "$pathresults/$table_no_top", ctitle("Reduced w/o AMCs at the top") aster(se) dec(3) label nocons e(IMR_position_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr) replace

xi: xtreg IMR $instr potentialAMC $no_control if area_upstream_ha>0, fe cluster(basin)
	sum IMR if year==2000&area_upstream_ha>0
	eret2 scalar IMR_position_mean=r(mean)
	outreg2 using "$pathresults/$table_no_top", ctitle("Reduced w/o AMCs at the top") aster(se) dec(3) label nocons e(IMR_position_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr potentialAMC) 

xi: xtreg IMR $instr potentialAMC $control_no_potential if area_upstream_ha>0, fe cluster(basin)
	sum IMR if year==2000&area_upstream_ha>0
	eret2 scalar IMR_position_mean=r(mean)
	outreg2 using "$pathresults/$table_no_top", ctitle("Reduced w/o AMCs at the top") aster(se) dec(3) label nocons e(IMR_position_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr potentialAMC) 

xi: xtivreg2 IMR ($glyph_up=$instr) $no_control if area_upstream_ha>0, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000&area_upstream_ha>0
	eret2 scalar IMR_position_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_no_top", ctitle("IV w/o AMCs at the top") aster(se) dec(3) label nocons e(IMR_position_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up) 

xi: xtivreg2 IMR ($glyph_up=$instr) potentialAMC $no_control if area_upstream_ha>0, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000&area_upstream_ha>0
	eret2 scalar IMR_position_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_no_top", ctitle("IV w/o AMCs at the top") aster(se) dec(3) label nocons e(IMR_position_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up) 

xi: xtivreg2 IMR ($glyph_up=$instr) $control if area_upstream_ha>0, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000&area_upstream_ha>0
	eret2 scalar IMR_position_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_no_top", ctitle("IV w/o AMCs at the top") aster(se) dec(3) label nocons e(IMR_position_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC) 
