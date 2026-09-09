********************************************************************************
*** Appendix - Results with Alternate Glyph Measures


xi: xtivreg2 IMR ($glyph_up=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum $glyph_up if year<=2003
	local glyphpre=r(mean)
	sum $glyph_up if year>=2004
	local glyphpost=r(mean)
	eret2 scalar effect=(`glyphpost'-`glyphpre')*_b[$glyph_up]
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_alt_glyph", ctitle("Main Measure") aster(se) dec(3) label nocons e(IMR_baseline_mean effect) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC) replace 

	
xi: xtivreg2 IMR (glyph_soy_upstream_herbicides=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum glyph_soy_upstream_herbicides if year<=2003
	local glyphpre=r(mean)
	sum glyph_soy_upstream_herbicides if year>=2004
	local glyphpost=r(mean)
	eret2 scalar effect=(`glyphpost'-`glyphpre')*_b[glyph_soy_upstream_herbicides]
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_alt_glyph", ctitle("Alternate Imputation") aster(se) dec(3) label nocons e(IMR_baseline_mean effect) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(glyph_soy_upstream_herbicides potentialAMC) 

	
xi: xtivreg2 IMR (glyph_soy_upstream_0until2003=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum glyph_soy_upstream_0until2003 if year<=2003
	local glyphpre=r(mean)
	sum glyph_soy_upstream_0until2003 if year>=2004
	local glyphpost=r(mean)
	eret2 scalar effect=(`glyphpost'-`glyphpre')*_b[glyph_soy_upstream_0until2003]
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_alt_glyph", ctitle("0 until 2003, marg glyph" "distr w/ soy") aster(se) dec(3) label nocons e(IMR_baseline_mean effect) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(glyph_soy_upstream_0until2003 potentialAMC) 


xi: xtivreg2 IMR (glyph_soy_upstream_distrsoy=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum glyph_soy_upstream_distrsoy if year<=2003
	local glyphpre=r(mean)
	sum glyph_soy_upstream_distrsoy if year==2004
	local glyphpost=r(mean)
	eret2 scalar effect=(`glyphpost'-`glyphpre')*_b[glyph_soy_upstream_distrsoy]
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_alt_glyph", ctitle("total glyph" "distr w/ soy") aster(se) dec(3) label nocons e(IMR_baseline_mean effect) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(glyph_soy_upstream_distrsoy potentialAMC) 
	
	
xi: xtivreg2 IMR (glyph_soy_up_0til03distsoy=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum glyph_soy_up_0til03distsoy if year<=2003
	local glyphpre=r(mean)
	sum glyph_soy_up_0til03distsoy if year>=2004
	local glyphpost=r(mean)
	eret2 scalar effect=(`glyphpost'-`glyphpre')*_b[glyph_soy_up_0til03distsoy]
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_alt_glyph", ctitle("0 until 2003, total glyph" "distr w/ soy") aster(se) dec(3) label nocons e(IMR_baseline_mean effect) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(glyph_soy_up_0til03distsoy potentialAMC) 
