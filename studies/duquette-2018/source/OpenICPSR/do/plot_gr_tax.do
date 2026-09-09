/****************
* Plot national-level data showing changes over long time span
* -- Giving/Income versus Tax Incentives for high-income groups
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
global color2 "green"

global pattern1 "solid"
global pattern2 "longdash"

global symbol1 "Oh"
global symbol2 "Th"

global xlineopts "lwidth(vthin) lcolor(gs8)"

global msizeall "medsmall"

global colorlist2 "green  dkgreen emerald"
global symbollist2 "Th Sh Dh"
global patternlist2 "longdash dash dash_dot"



	// Call data
use "$data/ts_chart", clear

	// ==========================================================
	// FIGURE 3. 
	// Giving vs. tax, including more tax series
	
twoway (connected gr0010 year, yaxis(1)							///
		msize($msizeall )												///
		msymbol($symbol1)												///
		mcolor($color1 )												///
		lcolor($color1 )												///
		lpattern($pattern1)												///
		yscale(range(0) noline)												///  
		ytitle("Contributions / Income")								///
	)																	///
	(connected _1mtr_t01 tc_ap_20p_t01  year, yaxis(2)	/// tc_ap_limit_t01
		msize($msizeall $msizeall $msizeall )							///
		msymbol($symbollist2)											///
		mcolor($colorlist2)												///
		lcolor($colorlist2)												///
		ytitle("1-Tax Rate",axis(2))									///
		lpattern($patternlist2)											///
		ylabel(0(.2)0.8, 							///
			axis(2) angle(horizontal) format(%02.1f))					///
		yscale(noline axis(2))		///
	),																	///
	scheme($schemetype)													///
	plotregion(style(none))												///
	legend(  nobox size(*0.65) rowgap(*0.3) symxsize(*0.5) 				///
		pos(5)  cols(1) ring(0)											///
		label(1 "Contributions / Income")								///
		label(2 "Ordinary Tax Cost (right axis)")									///
		label(3 "20% Gain Tax Cost (right axis)")									///
		region(style(none))									///
	)																	///
	graphregion(margin(zero))											///
																		/// 
	xtitle("Year") 									///
	ylabel(0 "0" 0.02 "2" 0.04 "4" 0.06 "6" 0.08 "8" .1 "10%"			///
			, angle(horizontal))									///
	xlabel(1920(10)2010, labsize(*0.8) )								///
	xscale(noline)


graph display, $sizeopts

graph export "$charts/fig3.pdf", $outopts as(pdf) fontface("`mainfont'")
