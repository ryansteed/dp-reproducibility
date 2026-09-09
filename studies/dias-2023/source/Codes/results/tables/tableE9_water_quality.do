********************************************************************************
** Regs Water Quality Measures and Main Spec in the Same Sample - Balanced Sample

foreach var in bod ammonia_nitrogen{
foreach n in 1 2 3{
	
* Identify balanced sample
gen nonmissing=0
replace nonmissing=1 if `var'`n'!=.&year==2003
bysort AMC: egen samp = max(nonmissing)
	
* RF
	xi: xtreg `var'`n' $instr $control if samp==1, fe cluster(basin)
		sum `var'`n' if year==2000 & samp==1
		eret2 scalar y_baseline_mean=r(mean)
		outreg2 using "$pathresults/$table_bod_balanced", ctitle("Reduced Form, `var'`n'") aster(se) dec(3) label nocons e(y_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr potentialAMC) 

	xi: xtreg IMR $instr $control if samp==1, fe cluster(basin)
		sum IMR if year==2000 & samp==1
		eret2 scalar y_baseline_mean=r(mean)
		outreg2 using "$pathresults/$table_main_bodsample", ctitle("Reduced Form, IMR, sample: `var'`n'") aster(se) dec(3) label nocons e(y_baseline_mean) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep($instr potentialAMC)
		
	drop nonmissing samp
}	
}

