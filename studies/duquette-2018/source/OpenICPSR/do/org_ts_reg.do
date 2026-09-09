/******************************
* Perform regressions on real per-capita gifts to
* famous charities over the long run.
******************************/


use "$data/org_data", clear

	// ==================================
	// TABLE A1
	// Regress organization received contributions
	// on inequality and other controls.


	// Sort for time series regression
drop if year<1900 | year>2020
sort year
tsset year


	// Use eststo to make formatted table output
eststo clear

local macro "ln_rgdppc mkt_return ln_unemp " 

eststo: prais ln_rpc_harvard ln_sht1 l1tau0_t1 ln_inct1 , rhotype(regress) robust

eststo: prais ln_rpc_harvard ln_sht1 l1tau0_t1 ln_inct1 `macro' , rhotype(regress) robust

eststo: prais ln_rpc_harvard ln_sht1 l1tau0_t1 ln_inct1  drate0_t1 drate1_t1 ln_tc_ap_y1_t1, rhotype(regress) robust

eststo: prais ln_rpc_harvard ln_sht1 l1tau0_t1 ln_inct1 `macro' drate0_t1 drate1_t1 ln_tc_ap_y1_t1, rhotype(regress) robust

eststo: prais ln_rpc_uww ln_sht1 l1tau0_t1 ln_inct1 `macro'  drate0_t1 drate1_t1 ln_tc_ap_y1_t1, rhotype(regress) robust

	// CSV for word (short variable list)
esttab using "$tables/tableA1.csv",							///
	replace  csv se r2 nonotes label 									///
	mtitles("Harvard p.c." "Harvard p.c." "Harvard p.c.")				///
	indicate("Macro Controls = `macro'")	///
	star(+ 0.10 * 0.05 ** 0.01)
