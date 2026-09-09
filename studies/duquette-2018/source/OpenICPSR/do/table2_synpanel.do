/******************************************
* Create TABLE 2
* Regress giving per person from a
* synthetic panel of high-income groups
* on iequality, tax, other covariates
******************************************/


eststo clear

	// Call synthetic panel data
use "$data/synthetic_panel", clear

	// String of extra tax controls
local extrataxvars "drate1  drate0  tc_ap_y1 "

	// ================================
	// TABLE 2
eststo: xtpcse ln_CGI  ln_sht1   [iw=groupsize], correlation(ar1)  rhotype(regress)

eststo: xtpcse ln_CGI  ln_sht1 ln_rGIpc l1tau0  [iw=groupsize], correlation(ar1)  rhotype(regress)

eststo: xtpcse ln_CGI  ln_sht1 ln_rGIpc l1tau0 ln_rgdppc mkt_return ln_unemp ln_ndf  [iw=groupsize], correlation(ar1)  rhotype(regress)

eststo: xtpcse ln_CGI  ln_sht1 ln_rGIpc l1tau0 ln_rgdppc mkt_return ln_unemp ln_ndf  `extrataxvars' [iw=groupsize], correlation(ar1)  rhotype(regress)

	 // Word-formatted table, full list of variables
esttab using "$tables/table2.csv", 										///
	replace label csv r2 se  nonotes indicate(							///
		"Macro = ln_rgdppc mkt_return ln_unemp ln_ndf ")				///
	star(+ 0.10 * 0.05 ** 0.01) nogaps
	
eststo clear



	// ================
	// TABLE A7
	// Repeat regressions using giving/icnome and/or PSZ inequality

	
eststo: xtpcse ln_CGI  ln_psz_shpr_t1   [iw=groupsize], correlation(ar1)  rhotype(regress)

eststo: xtpcse ln_CGI  ln_psz_shpr_t1 ln_rGIpc l1tau0  [iw=groupsize], correlation(ar1)  rhotype(regress)

eststo: xtpcse ln_CGI  ln_psz_shpr_t1 ln_rGIpc l1tau0 ln_rgdppc mkt_return ln_unemp ln_ndf  [iw=groupsize], correlation(ar1)  rhotype(regress)

eststo: xtpcse ln_CGI  ln_psz_shpr_t1 ln_rGIpc l1tau0 ln_rgdppc mkt_return ln_unemp ln_ndf  `extrataxvars' [iw=groupsize], correlation(ar1)  rhotype(regress)

	 // Word-formatted table, full list of variables
esttab using "$tables/tableA7.csv", 						///
	replace label csv r2 se  nonotes indicate(							///
		"Macro = ln_rgdppc mkt_return ln_unemp ln_ndf ")				///
	star(+ 0.10 * 0.05 ** 0.01) nogaps
	
eststo clear
