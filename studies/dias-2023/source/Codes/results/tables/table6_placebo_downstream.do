********************************************************************************
* Placebo with Downstream
*

xi: xtreg IMR potentialDownstream $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_placebo_main", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(potentialDownstream) replace
xi: xtreg IMR potentialDownstream potentialAMC $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_placebo_main", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(potentialDownstream potentialAMC) 
xi: xtreg IMR potentialDownstream potentialAMC $control_no_potential, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_placebo_main", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(potentialDownstream potentialAMC) 

xi: xtreg IMR $glyph_down $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_placebo_main", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_down) 
xi: xtreg IMR $glyph_down potentialAMC $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_placebo_main", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_down potentialAMC) 
xi: xtreg IMR $glyph_down $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_placebo_main", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_down potentialAMC) 

	
xi: xtivreg2 IMR ($glyph_down=potentialDownstream) $no_control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_placebo_main", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_down) 

xi: xtivreg2 IMR ($glyph_down=potentialDownstream) potentialAMC $no_control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_placebo_main", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_down potentialAMC) 

xi: xtivreg2 IMR ($glyph_down=potentialDownstream) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_placebo_main", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_down potentialAMC) 
