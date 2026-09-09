/**************************************
* Before going any further, do my
* plotted correlations hold up as a
* multivariate association?
* Time series regressions of giving on 
* controls 
**************************************/

use "$data/timeseries", clear

	// for cleaner output, create variables that can be
	// replaced with various definitions and income cutoffs
gen inequality=.
la var inequality "Top Income Share"
gen income=.
la var income "Top Income"
gen mtr=.
la var mtr "Tax Cost of Giving"


	// =====================
	// TABLE 1
	// Basic time series regresions. PS 2003 inequality, income averages
eststo clear

replace inequality=ln_sht1
replace income=ln_incavg_t1
replace mtr=ln(avginc_1mtr_t1)
eststo: prais lnCGI0100 inequality income mtr, robust 

replace inequality=ln_sht01
replace income=ln_incavg_t01
replace mtr=ln(avginc_1mtr_t01)
eststo: prais lnCGI0010 inequality income mtr, robust

replace inequality=ln_sht001
replace income=ln_incavg_t001
replace mtr=ln(avginc_1mtr_t001)
eststo: prais lnCGI0001 inequality income mtr,  robust



	 // Word-formatted table, full list of variables
esttab using "$tables/table1.csv", 						///
	replace label csv r2 se nogaps nonotes ///
	star(+ 0.10 * 0.05 ** 0.01)
	

	// ===============================\
	// TABLE A6
	// Redo the table, but use PSZ inequality, average income, and tax rate

eststo clear

replace inequality=ln_psz_shpr_t1
replace income=ln_psz_aipr_t1
replace mtr=ln(psz_1mtr_t1)
eststo: prais lnCGI0100 inequality income mtr, robust 

replace inequality=ln_psz_shpr_t01
replace income=ln_psz_aipr_t01
replace mtr=ln(psz_1mtr_t01)
eststo: prais lnCGI0010 inequality income mtr, robust

replace inequality=ln_psz_shpr_t001
replace income=ln_psz_aipr_t001
replace mtr=ln(psz_1mtr_t001)
eststo: prais lnCGI0001 inequality income mtr,  robust

	 // Word-formatted table, full list of variables
esttab using "$tables/tableA6.csv", 						///
	replace label csv r2 se nogaps nonotes ///
	star(+ 0.10 * 0.05 ** 0.01)
	
	// ==============================
	// Table A5
	// Post-1939 only

eststo clear
	
replace inequality=ln_sht1
replace income=ln_incavg_t1
replace mtr=ln(avginc_1mtr_t1)
eststo: prais lnCGI0100 inequality income mtr if year>=1939, robust 

replace inequality=ln_sht01
replace income=ln_incavg_t01
replace mtr=ln(avginc_1mtr_t01)
eststo: prais lnCGI0010 inequality income mtr if year>=1939, robust twostep // need to use twostep for convergence

replace inequality=ln_sht001
replace income=ln_incavg_t001
replace mtr=ln(avginc_1mtr_t001)
eststo: prais lnCGI0001 inequality income mtr if year>=1939,  robust


	 // Word-formatted table, full list of variables
esttab using "$tables/tableA5.csv", 						///
	replace label csv r2 se nogaps nonotes ///
	star(+ 0.10 * 0.05 ** 0.01)
		
	
	// ===============================
	// TABLE A2
	// Assess robustness of model to alternate functional forms

eststo clear
	
replace inequality=ln_sht01
replace income=ln_t01
replace mtr=ln(_1mtr_t01)
gen decade=int(year/10)

	// Hack variable to get table formatting
gen byte prais_dumb=0

eststo: reg lnCGI0010 inequality income mtr i.decade, robust
eststo: reg lnCGI0010 inequality income mtr year, robust
eststo: reg lnCGI0010 inequality income mtr year i.decade, robust

	
gen GI=exp(lnCGI0010)

gen level_ineq=exp(ln_sht01)/100	// share not pct points

gen level_inc=exp(ln_t01)
gen level_mtr=exp(mtr_t01)

eststo: prais GI inequality prais_dumb, robust
eststo: prais GI inequality income mtr prais_dumb, robust
eststo: prais GI level_ineq prais_dumb, robust
eststo: prais GI level_ineq income mtr prais_dumb, robust

eststo: reg GI inequality year i.decade , robust
eststo: reg GI level_ineq year i.decade , robust


reg GI inequality, robust
reg GI inequality income mtr, robust
reg GI level_ineq, robust
reg GI level_ineq income mtr, robust

reg GI inequality year i.decade, robust
reg GI level_ineq year i.decade, robust
	
	
	 // Word-formatted table, 
esttab using "$tables/tableA2.csv", 					///
	replace label csv r2 se nogaps  nonotes 						///
	indicate("Decade Fixed Effects = ???.decade" "Prais-Winsten Correction = prais_dumb")	///
	star(+ 0.10 * 0.05 ** 0.01)
	
	
