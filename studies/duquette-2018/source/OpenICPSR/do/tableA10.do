use "$data/timeseries", clear


	// for cleaner output, create variables that can be
	// replaced with various definitions and income cutoffs
gen inequality=.
la var inequality "Top Income Share"
gen income=.
la var income "Top Income"
gen mtr=.
la var mtr "Tax Cost of Giving"


eststo clear

replace inequality=ln_sht1
replace income=ln_t1
replace mtr=ln(mtr_t1)
eststo: prais lnCGI0100 inequality  , robust 
eststo: prais lnCGI0100 inequality  mtr, robust 

replace inequality=ln_sht01
replace income=ln_t01
replace mtr=ln(mtr_t01)
eststo: prais lnCGI0010 inequality  , robust
eststo: prais lnCGI0010 inequality  mtr, robust

replace inequality=ln_sht001
replace income=ln_t001
replace mtr=ln(mtr_t001)
eststo: prais lnCGI0001 inequality  ,  robust
eststo: prais lnCGI0001 inequality  mtr,  robust


	 // Word-formatted table, full list of variables
esttab using "$tables/tableA10.csv", 						///
	replace label csv r2 se nogaps nonotes ///
	star(+ 0.10 * 0.05 ** 0.01)
