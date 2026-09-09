********************************************************************************	
* Sum upstream-downstream, main results
*

xi: xtreg IMR sum_pot $instr $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr sum_pot) replace

xi: xtreg IMR sum_pot $instr potentialAMC $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr sum_pot potentialAMC) 
	
xi: xtreg IMR sum_pot $instr $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("Reduced Form") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr sum_pot potentialAMC) 

xi: xtreg IMR sum_glyph $glyph_up $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up sum_glyph)

xi: xtreg IMR sum_glyph $glyph_up potentialAMC $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($glyph_up sum_glyph potentialAMC) 
	
xi: xtreg IMR sum_glyph $glyph_up $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("OLS") aster(se) dec(3) label nocons e(IMR_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($glyph_up sum_glyph potentialAMC) 

xi: xtivreg2 IMR (sum_glyph $glyph_up = sum_pot $instr) $no_control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)') addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(sum_glyph $glyph_up) 

xi: xtivreg2 IMR (sum_glyph $glyph_up = sum_pot $instr) potentialAMC $no_control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)') addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(sum_glyph $glyph_up potentialAMC) 

xi: xtivreg2 IMR (sum_glyph $glyph_up = sum_pot $instr) $control, fe cluster(basin) partial(int_uf*)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_sum", ctitle("IV") aster(se) dec(3) label nocons e(IMR_baseline_mean) nor2 addstat(F-stat, `e(widstat)') addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(sum_glyph $glyph_up potentialAMC) 
	