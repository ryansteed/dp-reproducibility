/****************
* Plot national-level data showing changes over long time span
* -- Giving/Income versus Top Income Share for high-income groups
*****************/

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

global color1 "black"
global color2 "blue"

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

	// Call time series used in charts
use "$data/ts_chart", clear



		// ===============================
		// FIGURE 2.
		// Giving/Income vs. Top income shares


twoway (connected gr0010 year, yaxis(1)							/// 
		msize($msizeall)												///
		msymbol($symbol1 )												///
		mcolor($color1 )												///
		lcolor($color1 )												///
		lpattern($pattern1)												///
		ytitle("Contributions / Income")								///											/// 
	)																	///
	(connected incsh_t01 year, yaxis(2)							///
		msize($msizeall )												///
		msymbol($symbol2)												///
		mcolor($color2)													///
		lcolor($color2)													///
		lpattern($pattern2)												///
		ytitle("Top Income Share",axis(2))							///
	),																	///
	scheme($schemetype)													///
	plotregion(style(none))												///
	legend(  nobox size(*0.65) rowgap(*0.3) symxsize(*0.5) 				///
		pos(6)  cols(1) ring(0)											///
		label(1 "Contributions / Income")								///
		label(2 "Top Income Share (right axis)")						///
		region(style(none))												///
	)																	///
	graphregion(margin(zero))											///
	xtitle("Year") yscale(axis(1) range(0) noline) 		///
	yscale(axis(2) range(0) noline)				///
	ylabel(0 "0" .02 "2" .04 "4" 				///
				.06 "6" .08 "8" 				///
				.1 "10%", angle(horizontal) ) 		///
	ylabel(0(2)8 8 "8%", axis(2) angle(horizontal) )		///
	xscale(noline)													///
	xlabel(1920(10)2010, labsize(*0.8) )		

graph display, $sizeopts
graph export "$charts/fig1.pdf", $outopts as(pdf) fontface("$mainfont")


