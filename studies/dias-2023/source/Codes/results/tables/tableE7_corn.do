********************************************************************************
*** Appendix -- First Stage Using Maize

xi: xtreg area_corn_upstream potentialCornUpstream $no_control, fe cluster(basin)
	sum area_corn_upstream if year==2000
	eret2 scalar area_corn_upstream=r(mean)
	test potentialCornUpstream
	outreg2 using "$pathresults/$table_maize_first", ctitle("First Stage")  aster(se) dec(3) label nocons e(area_corn_upstream) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(potentialCornUpstream) addstat(Partial-F, `r(F)') replace

xi: xtreg area_corn_upstream potentialCornUpstream potentialCornAMC $no_control, fe cluster(basin)
	sum area_corn_upstream if year==2000
	eret2 scalar area_corn_upstream=r(mean)
	test potentialCornUpstream
	outreg2 using "$pathresults/$table_maize_first", ctitle("First Stage")  aster(se) dec(3) label nocons e(area_corn_upstream) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(potentialCornUpstream potentialCornAMC) addstat(Partial-F, `r(F)') append

xi: xtreg area_corn_upstream potentialCornUpstream potentialCornAMC $control_no_potential, fe cluster(basin)
	sum area_corn_upstream if year==2000
	eret2 scalar area_corn_upstream=r(mean)
	test potentialCornUpstream
	outreg2 using "$pathresults/$table_maize_first", ctitle("First Stage")  aster(se) dec(3) label nocons e(area_corn_upstream) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(potentialCornUpstream potentialCornAMC) addstat(Partial-F, `r(F)') append
