	// call data
use "$data/nationalgiving", clear

	// Pick a nice font
graph set window fontface "Charter"


	// Top Giving / All Giving
#delimit;
twoway (connected t1_ind t1_tot t1corp_tot  year		
			if year>=1956 & year<=2012,										
			msize(small small small )						
			lpattern(dash solid   shortdash )			
			msymbol(Oh Sh Th)										
			 msymbol(T O Sh Th Sh S) 
			 mcolor(green blue purple green purple purple) 
			 lcolor(green blue purple green purple purple)			
		) 																	//
			, 																//
		ytitle("Giving % of High Earners") 									//
		xtitle("Year")														//
		scheme(`schemechoice') 												//	
		plotregion(style(none))												//	No box around the plot
		xlabel(1960(10)2010, labsize(*0.8))									//				
		ylabel(10 15 20 25 "25%", angle(horizontal) labsize(*0.8) format(%02.0f))		//
		legend(label(1 "Top 1% Individuals / All Individual Giving") 
				label(2 "Top 1% Individuals / Total Giving") 						
				label(3 "(Top 1% Individuals + Corporate Giving) / Total Giving")
				cols(1)
			ring(0) pos(11) size(*0.5) rowgap(*0.1) symxsize(*0.4) 			//
			region(style(none)) 											// No box around the legend
			)																//
		yscale(noline  titlegap(*1.1))	xscale(noline  titlegap(*4))		// No ugly axis lines
	;
#delimit cr		
graph export "$charts/figA1.pdf", as(pdf) replace 


	// Giving / National Income (top giving only)
twoway (connected cgni0100   year											/// 
			if year>=1917 & year<2013,										///
			msize(small small small small small small)						///
			lpattern(dash solid dot longdash shortdash dash_dot)			///
			lcolor(black) mcolor(black)										///
			msymbol(Oh Sh)													///
			 `opts_`schemechoice''											///
		) 																	///	
			, 																///	
																			/// 
		ytitle("Giving/National Income (%)") 								///
		xtitle("Year")														///
		scheme(`schemechoice') 												///	
		plotregion(style(none))												///	No box around the plot
		xlabel(1920(10)2010, labsize(*0.8))									///					
		ylabel(0(0.1)0.5, angle(horizontal) labsize(*0.8) format(%02.1f))	///
		legend(off label(1 "Top 1%") label(2 "Top 0.1%") 					///
			ring(0) pos(12) size(*0.8) rowgap(*0.8) symxsize(*0.5) 			///
			region(style(none)) 											/// No box around the legend
			)																///
		yscale(noline  titlegap(*1.1))	xscale(noline  titlegap(*4))		/// No ugly axis lines
		
		
	graph export "$charts/figA3.pdf", as(pdf) replace 
	
	
	// Giving / National Income (Including aggregates)
twoway (area tot_gni ind_corp_beq_gni ind_corp_gni ind_gni cgni0100   year	/// 
			if year>=1956 & year<=2012,										///
																			///
		) 																	///	
			, 																///	
		ytitle("Giving/National Income (%)") 								///
		xtitle("Year")														///
		scheme(s1color) 													///	
		plotregion(style(none))												///	
		xlabel(1960(10)2010, labsize(*0.8))									///	
		ylabel(0(0.5)2.5, angle(horizontal) labsize(*0.8) format(%02.1f))	///
		legend(label(1 "Foundations") 										///
			label(2 "Bequests") label(3 "Corporations")						///
			label(4 "Bottom 99% Individuals") 								///
			label(5 "Top 1% Individuals") 									/// 
			ring(0) pos(11) size(*0.8) rowgap(*0.8) symxsize(*0.5) 			///
			region(style(none)) 											/// No box around the legend
			)																///
		yscale(noline  titlegap(*1.1))	xscale(noline  titlegap(*4))		/// No ugly axis lines
		
	graph export "$charts/figureA2.pdf", as(pdf) replace 

	

	
