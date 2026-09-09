

	// ========================================
	// Setup: fix font and chart size options
	


	global mainfont "Times"
	graph set window fontface "$mainfont"
	graph set print fontface "$mainfont"
	graph set ps fontface "$mainfont"
	graph set eps fontface "$mainfont"

	global schemetype "s1mono"
	global sizeopts "xsize(9) ysize(6.5)"
	global outopts " replace"
	
	global color1 "midblue"
	global color2 "black"
	
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

use "$data/canada_usa_merged", clear

		// ===============================
		// FIGURE 2.
		// Giving/Income vs. Top income shares

		// Top 0.1%
twoway (connected usa0010 year, yaxis(1)							/// 
		msize($msizeall)												///
		msymbol($symbol1 )												///
		mcolor($color1 )												///
		lcolor($color1 )												///
		lpattern($pattern1)												///
		ytitle("Contributions / Income USA")							///
		xlabel(1920(20)2000)											/// 
		yscale(range(0))	///
		ylabel(0(.02).1)	///
	)																	///
	(connected canada0010 year, yaxis(2)							///
		msize($msizeall )												///
		msymbol($symbol2)												///
		mcolor($color2)													///
		ytitle("Contributions / Income Canada", axis(2))							///
		yscale(range(0) axis(2))		///
		ylabel(0(0.01)0.03, axis(2))	///
		lcolor($color2)													///
		lpattern($pattern2 )												///
	)																	///
	, scheme($schemetype)													///
	plotregion(style(none))												///
	legend(  nobox size(*0.65) rowgap(*0.3) symxsize(*0.5) 				///
		pos(11)  cols(1) ring(0)											///
		label(1 "USA (left axis)")								///
		label(2 "Canada (right axis)")										///
		order(1 2)	///
	)																	///
	graphregion(margin(zero))											///
	xtitle("Year")


graph display, $sizeopts


graph export "$charts/figA7.pdf", $outopts as(pdf) fontface("$mainfont")
