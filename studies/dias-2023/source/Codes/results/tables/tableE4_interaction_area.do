********************************************************************************
*** Appendix - Results Interacting with Area Upstream


* Create local with mean(area upstream)
sum area_upstream if year==2000
local area_up_mean = r(mean)

* Regs	
xi: xtreg IMR c.potentialUpstream##c.area_upstream $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum area_upstream if year==2000
	eret2 scalar area_upstream_mean=r(mean)
	eret2 scalar coef_sum = _b[potentialUpstream] + _b[c.potentialUpstream#c.area_upstream] * `area_up_mean'
	test (c.potentialUpstream#c.area_upstream)*`area_up_mean' + potentialUpstream = 0
	eret2 scalar pval = r(p)
	outreg2 using "$pathresults/$table_area_inter", ctitle("Reduced Form") aster(se) label nocons e(IMR_baseline_mean, area_upstream_mean, coef_sum, pval) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(potentialUpstream c.potentialUpstream#c.area_upstream) replace

xi: xtreg IMR c.potentialUpstream##c.area_upstream potentialAMC $no_control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum area_upstream if year==2000
	eret2 scalar area_upstream_mean=r(mean)
	eret2 scalar coef_sum = _b[potentialUpstream] + _b[c.potentialUpstream#c.area_upstream] * `area_up_mean'
	test (c.potentialUpstream#c.area_upstream)*`area_up_mean' + potentialUpstream = 0
	eret2 scalar pval = r(p)
	outreg2 using "$pathresults/$table_area_inter", ctitle("Reduced Form") aster(se) label nocons e(IMR_baseline_mean, area_upstream_mean, coef_sum, pval) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, No) keep(potentialUpstream c.potentialUpstream#c.area_upstream potentialAMC)

xi: xtreg IMR c.potentialUpstream##c.area_upstream $control, fe cluster(basin)
	sum IMR if year==2000
	eret2 scalar IMR_baseline_mean=r(mean)
	sum area_upstream if year==2000
	eret2 scalar area_upstream_mean=r(mean)
	eret2 scalar coef_sum = _b[potentialUpstream] + _b[c.potentialUpstream#c.area_upstream] * `area_up_mean'
	test (c.potentialUpstream#c.area_upstream)*`area_up_mean' + potentialUpstream = 0
	eret2 scalar pval = r(p)
	outreg2 using "$pathresults/$table_area_inter", ctitle("Reduced Form") aster(se) label nocons e(IMR_baseline_mean, area_upstream_mean, coef_sum, pval) addtext(AMC FE, Yes, UF-Year FE, Yes, Controls, Yes) keep(potentialUpstream c.potentialUpstream#c.area_upstream potentialAMC)
