	/*-----------------------------------------------
	|  Plot the giving/asset ratio for high-wealth  |
	|  estates over time                            |
	-----------------------------------------------*/

	// call data
use "$data/bequests_bysize", clear

	// Set fonts for plotting
global mainfont "Times"
graph set window fontface "$mainfont"
graph set print fontface "$mainfont"
graph set ps fontface "$mainfont"
graph set eps fontface "$mainfont"

	// Make plot
sort year
twoway connected bqst* year if year<2015, 					///
	scheme(s1color) xlabel(1920(20)2000) 					///
	msymbol(Oh Sh Th) cmissing(no no no)					///
	mcolor(red blue green) lcolor(red blue green)			///
	msize(medsmall medsmall medsmall)						///
	ytitle("Charitable Bequests / Gross Estate (%)")			///
	lpattern(solid dash longdash)							///
	legend(  nobox size(*0.65) rowgap(*0.3) symxsize(*0.5) 	///
	pos(11)  cols(1)  ring(0)								///
)															///
xtitle("Year")

graph display, ysize(5) xsize(6.5)
graph export "$charts/figA6.pdf", as(pdf) replace
