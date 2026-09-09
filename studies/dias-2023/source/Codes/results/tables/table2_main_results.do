********************************************************************************	
* Reduced Form & OLS & IV
*

eststo: xi: xtreg IMR $instr $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_main", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr) replace

eststo: xi: xtreg IMR $instr potentialAMC $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_main", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr potentialAMC) 
	
eststo: xi: xtreg IMR $instr $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_main", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr potentialAMC) 

eststo: xi: xtreg IMR $glyph_up $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_main", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up)

eststo: xi: xtreg IMR $glyph_up potentialAMC $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_main", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up potentialAMC) 
	
eststo: xi: xtreg IMR $glyph_up $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_main", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC) 

eststo: xi: xtivreg2 IMR ($glyph_up=$instr) $no_control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))	
	outreg2 using "$pathresults/$table_main", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up) 

eststo: xi: xtivreg2 IMR ($glyph_up=$instr) potentialAMC $no_control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_main", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up potentialAMC) 

eststo: xi: xtivreg2 IMR ($glyph_up=$instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	mat b=e(b)
	mat v=e(V)
	scalar tstat2 = (b[1,1]/sqrt(v[1,1]))^2
	scalar rejrate_Leeetal = 1 - normal(sqrt(`e(widstat)'*tstat2)/(sqrt(`e(widstat)')+sqrt(tstat2))) + normal((-sqrt(`e(widstat)'*tstat2)-2*`e(widstat)')/(sqrt(`e(widstat)')+sqrt(tstat2)))
	outreg2 using "$pathresults/$table_main", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)', Rejection Rate (Lee et al. 2020), rejrate_Leeetal) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up potentialAMC) 

eststo: xi: xtivreg2 IMR ($glyph_up $glyph_amc = $instr potentialAMC) $control_no_potential, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_main", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)') addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up $glyph_amc) 

*** EDITED by Ryan Steed
estout using "../../../results/Table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***