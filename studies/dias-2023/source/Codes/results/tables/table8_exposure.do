********************************************************************************
*** Appendix - DiD results by exposure

xi: xtreg IMR_highexp $glyph_up $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_did_exposure", ctitle("High Exposure, OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC) replace 

xi: xtreg IMR_highexp $instr $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_did_exposure", ctitle("High Exposure, Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr potentialAMC) 	
	
xi: xtivreg2 IMR_highexp ($glyph_up=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))	
	outreg2 using "$pathresults/$table_did_exposure", ctitle("High Exposure, IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC)


xi: xtreg IMR_lowexp $glyph_up $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_did_exposure", ctitle("Low Exposure, OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC)

xi: xtreg IMR_lowexp $instr $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_did_exposure", ctitle("Low Exposure, Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr potentialAMC) 	
		
xi: xtivreg2 IMR_lowexp ($glyph_up=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults\$table_did_exposure", ctitle("Low Exposure, IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC)

