
	global schemetype "s1mono"
	global sizeopts "xsize(9) ysize(6.5)"
	global mainfont "Times"
	global outopts `"replace "'

	graph set window fontface "$mainfont"
	graph set print fontface "$mainfont"
	graph set ps fontface "$mainfont"
	graph set eps fontface "$mainfont"

	global xlineopts "lwidth(vthin) lcolor(gs8)"
	global colorlist "black forest_green  orange_red" //
	global symbollist "Oh Sh Th "
	global linelist "solid dash  shortdash"


	// Tell Stata not to get clever with the export
set printcolor asis
set copycolor asis
set scheme $schemetype

	// Call giving/income data
use "$data/giving_ratios", clear

	// Make the chart
twoway connected gr0001 gr0010_0001 gr0100_0010 year, 					///
	scheme($schemetype)													///
	msize(small small  small) msymbol($symbollist)						///
	mcolor($colorlist) lcolor($colorlist)								///
	lpattern($linelist)													///
	legend(  nobox size(*0.65) rowgap(*0.3) symxsize(*0.5) 				///
		pos(11)  cols(1) ring(0)										///
		label(1 "Top 0.01% by income")									///
		label(2 "Top 0.1% to 0.01%")									///
		label(3 "Top 1% to 0.1%")										///
		order(1 2 3)													///
		region(style(none))												///
	)																	///
	ytitle("Contributions / Income")									///
	plotregion(style(none))												///
	xtitle("Year")														///
	graphregion(margin(zero))											///
	yscale(range(0) noline) 											///
	ylabel(																///
			0 "0" .04 "4" .08 "8" .12 "12" .16 "16" .2 "20%"			///
				, angle(horizontal)	)									///
	xlabel(1920(10)2010, labsize(*0.8) )								///
	xscale(noline)
	
	
graph display, $sizeopts
graph export "$charts/fig2.pdf", $outopts as(pdf)  fontface("$mainfont")

