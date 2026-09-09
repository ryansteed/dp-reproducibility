********************************************************************************
* Characterization & Heterogeneity: Rainfall
*

xi: xtreg IMR $instr rainOctMar_quartile2_instr rainOctMar_quartile3_instr rainOctMar_quartile4_instr i.rainOctMar_quart $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_heterogeneities", ctitle("Reduced Form") aster(se) dec(3) label nocons keep($instr rainOctMar_quartile2_instr rainOctMar_quartile3_instr rainOctMar_quartile4_instr potentialAMC) addtext(Rain, Oct-Mar, UF-Year FE, Yes, Controls, Yes) replace


********************************************************************************
* Characterization & Heterogeneity: Soil (PNE)

xi: xtreg IMR $instr int_pneP_c5_subbasin $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_heterogeneities", ctitle("Reduced Form") aster(se) dec(3) label nocons keep(int_pneP_c5_subbasin $instr potentialAMC) addtext(UF-Year FE, Yes, Controls, Yes) append

	
********************************************************************************
* Water Source

xi: xtreg IMR $instr surface_instr $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	outreg2 using "$pathresults/$table_heterogeneities", ctitle("Reduced Form") aster(se) dec(3) label nocons keep($instr surface_instr potentialAMC) addtext(UF-Year FE, Yes, Controls, Yes)

