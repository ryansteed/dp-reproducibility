********************************************************************************	
* First Stage
*
	
xi: xtreg $glyph_up $instr $no_control, fe cluster(basin)
	sum $glyph_up if year==2000
	eret2 scalar glyph_up_baseline_mean=r(mean)
	test $instr
	outreg2 using "$pathresults/$table_first", aster(se) dec(3) label nocons e(glyph_up_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr) addstat(Partial-F, `r(F)') replace
xi: xtreg $glyph_up $instr potentialAMC $no_control, fe cluster(basin)
	sum $glyph_up if year==2000
	eret2 scalar glyph_up_baseline_mean=r(mean)
	test $instr
	outreg2 using "$pathresults/$table_first", aster(se) dec(3) label nocons e(glyph_up_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep($instr potentialAMC) addstat(Partial-F, `r(F)') 	
xi: xtreg $glyph_up $instr $control, fe cluster(basin)
	sum $glyph_up if year==2000
	eret2 scalar glyph_up_baseline_mean=r(mean)
	test $instr
	outreg2 using "$pathresults/$table_first", aster(se) dec(3) label nocons e(glyph_up_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr potentialAMC) addstat(Partial-F, `r(F)')
