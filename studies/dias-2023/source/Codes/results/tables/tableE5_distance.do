********************************************************************************
*** Regs Distance 

* Reduced Form - normalized measures - control
xi: xtreg IMR potentialUpstream $control, fe cluster(basin)
		sum IMR if year==2000
		eret2 scalar IMR_baseline_mean=r(mean)
		outreg2 using "$pathresults/$table_distance", ctitle("Reduced Form, Full Sample") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(potentialUpstream potentialAMC) replace

xi: xtreg IMR potentialUpstream $control if a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0, fe cluster(basin)
		sum IMR if year==2000 & a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0
		eret2 scalar IMR_baseline_mean=r(mean)
		outreg2 using "$pathresults/$table_distance", ctitle("Reduced Form, with 50km 100km 150km 200km") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(potentialUpstream potentialAMC)

foreach x in 50 100 150 200{		
xi: xtreg IMR potentialUpstream`x'km $control if a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0, fe cluster(basin)
		sum IMR if year==2000 & a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0
		eret2 scalar IMR_baseline_mean=r(mean)
		outreg2 using "$pathresults/$table_distance", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(potentialUpstream`x'km potentialAMC)
}
xi: xtreg IMR potentialUpstream50km potentialUpstream100km potentialUpstream150km potentialUpstream200km $control if a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0, fe cluster(basin)
	sum IMR if year==2000 & a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_distance", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(potentialUpstream50km potentialUpstream100km potentialUpstream150km potentialUpstream200km potentialAMC)

	
* IV - normalized measures - control
xi: xtivreg2 IMR ($glyph_up = $instr) $control , fe cluster(basin) partial(int_uf*)
		sum IMR if year==2000
		eret2 scalar IMR_baseline_mean=r(mean)
		mat b=e(b)
		mat v=e(V)
		scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
		scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
		outreg2 using "$pathresults/$table_distance_iv", ctitle("IV, Full Sample") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC) replace

xi: xtivreg2 IMR ($glyph_up = $instr) $control if a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0, fe cluster(basin) partial(int_uf*)
		sum IMR if year==2000 & a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0
		eret2 scalar IMR_baseline_mean=r(mean)
		mat b=e(b)
		mat v=e(V)
		scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
		scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
		outreg2 using "$pathresults/$table_distance_iv", ctitle("IV, with 50km 100km 150km 200km") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC)

foreach x in 50 100 150 200{		
	xi: xtivreg2 IMR (glyph_up`x'km=potentialUpstream`x'km) $control if a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0, fe cluster(basin) partial(int_uf*)
		sum IMR if year==2000 & a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0
		eret2 scalar IMR_baseline_mean=r(mean)
		mat b=e(b)
		mat v=e(V)
		scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
		scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
		outreg2 using "$pathresults/$table_distance_iv", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(glyph_up`x'km potentialAMC)
}
xi: xtivreg2 IMR (glyph_up50km glyph_up100km glyph_up150km glyph_up200km = potentialUpstream50km potentialUpstream100km potentialUpstream150km potentialUpstream200km) $control if a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000 & a_up_radius_50km>0 & a_up_radius_100km>0 & a_up_radius_150km>0 & a_up_radius_200km>0
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_distance_iv", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)') addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(glyph_up50km glyph_up100km glyph_up150km glyph_up200km potentialAMC)

