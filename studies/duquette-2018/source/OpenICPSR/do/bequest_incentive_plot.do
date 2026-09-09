

	use "$data/estate_rates", clear

	//================
	// Set up graph parameters

	global mainfont "Times"
	graph set window fontface "$mainfont"
	graph set print fontface "$mainfont"
	graph set ps fontface "$mainfont"
	graph set eps fontface "$mainfont"
	
	global msizeall "small"

	global schemetype "s1color"
	
	global color1 "black"
	global color2 "orange"
	global color3 "gs3"
	global color4 "gs6"
	global color5 "gs8"
	global color6 "blue"
	
	
	global sizeopts "xsize(4.5) ysize(2.75)"
	global outopts "as(pdf) replace"

	global xlineopts "lwidth(vthin) lcolor(gs8)"
	
	
	global symbol1 "Oh"
	global symbol2 "S"
	global symbol3 "Oh"
	global symbol4 "Sh"
	
	
	global pattern1 "solid"
	global pattern2 "longdash"
	global pattern3 "shortdash"
	



	// Tell Stata not to get clever with the export
set printcolor asis
set copycolor asis
set scheme $schemetype



twoway (connected top_marg  mtr_nocg_t001 mtr_nocg_t01 mtr_nocg_t1 estate_rate et_max year, yaxis(1)									/// 
		msize($msizeall $msizeall $msizeall $msizeall $msizeall  $msizeall  )													///
		msymbol($symbol1 $symbol3 $symbol3 $symbol3 $symbol2 $symbol4)													///
		mcolor($color1  $color3 $color4 $color5 $color2 $color6)													///
		lcolor($color1  $color3  $color4 $color5 $color2 $color6)													///
		lpattern($pattern1  $pattern3 $pattern3  $pattern3 $pattern2  $pattern2)												///
		xlabel(1920(10)2010)												/// 
	)																		///
	, scheme($schemetype)												///
	plotregion(style(none))												///
	legend(  nobox size(*0.65) rowgap(*0.02) symxsize(*0.65) 				///
		pos(6)  cols(1) ring(0)											///
		)														///			
	graphregion(margin(zero))											///
	xtitle("Year") ytitle("Tax Rate")
	


graph display, `sizeopts'

graph export "$charts/figA5.pdf", $outopts

