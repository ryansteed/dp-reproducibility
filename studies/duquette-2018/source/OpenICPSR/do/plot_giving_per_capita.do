

	global mainfont "Charter Roman"
	graph set window fontface "$mainfont"
	graph set print fontface "$mainfont"
	graph set ps fontface "$mainfont"
	graph set eps fontface "$mainfont"

	global schemetype "s1color"
	global sizeopts "xsize(7) ysize(4)"
	global outopts " replace"
	
	global color1 "blue"
	global color2 "red"
	
	global pattern1 "solid"
	global pattern2 "longdash"
	
	global symbol1 "Oh"
	global symbol2 "Th"

	global xlineopts "lwidth(vthin) lcolor(gs8)"
	
	global msizeall "medsmall"
	

	// Tell Stata not to get clever with the export
set printcolor asis
set copycolor asis
set scheme $schemetype


	use "$data/ts_chart", clear	


		// ===============================
		// FIGURE X.
		// Real giving/person vs. real top income levels

twoway (connected rCpc_0010 year, yaxis(1) yscale(log noline)				/// 
		msize($msizeall)												///
		msymbol($symbol1 )												///
		mcolor($color1 )												///
		lcolor($color1 )												///
		lpattern($pattern1)												///
		ytitle("Real giving per tax unit ($1000 in 2016 dol.)")			///
		ylabel(25 50 100 200 "$200", 									///
			angle(horizontal))											///
		xlabel(1920(20)2000)											/// 
	)																	///
	(connected ravg_t01 year, yaxis(2) 									/// 
		msize($msizeall )												///
		msymbol($symbol2)												///
		mcolor($color2)													///
		lcolor($color2)													///
		lpattern($pattern2)												///
		ytitle("Top Income Average (\$1000 in 2016 dol.)",axis(2))		///
		ylabel(500 1000 2000 4000 "$4000",axis(2) 						///
			angle(horizontal))											///
		yscale(log axis(2) noline)												///
	)																	///
	,																	///
	scheme($schemetype)													///
	plotregion(style(none))												///
	legend(  nobox size(*0.65) rowgap(*0.3) symxsize(*0.5) 				///
		pos(11)  cols(1) ring(0)											///
		label(1 "Giving / Tax unit")									///
		label(2 "Top Income Average")									///
		region(style(none))												///
	)																	///
	graphregion(margin(zero))											///
	xtitle("Year")													///
	xscale(noline)													///
	xlabel(1920(10)2010, labsize(*0.8) )	

graph display, $sizeopts

graph export "$charts/figA9A.pdf", $outopts as(pdf) fontface("`mainfont'")


		// Top 0.01% and top 0.1-0.01%
twoway (connected rCpc_0001 year, yaxis(1) yscale(log)				/// 
		msize($msizeall)												///
		msymbol($symbol1 )												///
		mcolor($color1 )												///
		lcolor($color1 )												///
		lpattern($pattern1)												///
		ytitle("Real giving per tax unit ($1000 in 2016 dol.)")			///
		xlabel(1920(10)2010)											///
		ylabel(15 25 50 100 200 400 800 1600 "$1600",						///
			angle(horizontal))											///
	)																	///
	(connected rCpc_0010_0001 year, yaxis(1) 							///
		msize($msizeall )												///
		msymbol($symbol2)												///
		mcolor($color2)													///
		lcolor($color2)													///
		lpattern($pattern2)												///
	)																	///
	,																	///
	scheme($schemetype)													///
	plotregion(style(none))												///
	legend(  nobox size(*0.65) rowgap(*0.3) symxsize(*0.5) 				///
		pos(5)  cols(1) ring(0)											///
		label(1 "Giving / Tax unit top 0.01%")							///
		label(2 "Giving / Tax unit top 0.1-0.01%")						///
		region(style(none))												///
	)																	///
	graphregion(margin(zero))											///
	xscale(noline)														///
	yscale(noline)														///
	xtitle("Year")

graph display, $sizeopts

graph export "$charts/figA9B.pdf", $outopts as(pdf) fontface("`mainfont'")



	// =============================================
	// TABLE A4
	// Do a regression of absolute giving
	// on variables
	
	
	
	// Recharacterize panel nature of dataset
	// With respect to consecutive observations,
	// Not consecutive years. 
	
gen time=.
replace time=1 if year==1917
replace time=year-1920 if year>=1922 & year<=1942
replace time=year-1921 if year>=1944 & year<=1950
replace time=30 if year==1952
replace time=31 if year==1953
replace time=32 if year==1954
replace time=33 if year==1956
replace time=34 if year==1958
replace time=35 if year==1960
replace time=36 if year==1962
replace time=37 if year==1964
replace time=38 if year==1966
replace time=39 if year==1968
replace time=40 if year==1970
replace time=year-1931 if year>=1972 //& year<=2015
tsset time

eststo clear

	
foreach sfx in 1 01 001 {
	gen mtr`sfx'=ln(_1mtr_t`sfx')	
}

eststo clear

eststo: prais ln_rCpc_0010 ln_sht01 ln_incavg_t01  mtr01, robust
	
eststo: prais ln_rCpc_0100 ln_sht1 ln_incavg_t1  mtr1, robust
eststo: prais ln_rCpc_0001 ln_sht001 ln_incavg_t001  mtr001, robust


	 // Word-formatted table, 
esttab using "$tables/tableA4.csv", 					///
	replace label csv r2 se nogaps  nonotes 						///
	star(+ 0.10 * 0.05 ** 0.01)
	
