
////////////////////////////////////////////////////////////////////////////////
/// 	
/// 	Replication for  "Do Police Maximize Arrests or Minimize Crime?"  
/// 	Allison Stashko  		
/// 	Created May 23, 2022
/// 							
////////////////////////////////////////////////////////////////////////////////

// See README.pdf
// The file 0_Main.do sets directories and calls this file


/// Load data, select sample

cd "../$InputPath/"

use city_sample.dta, clear

keep if sample==1 //final sample limited to cities with: population>=25000  & pblack>.01  & pblack!=. & pwhite>.01 & pwhite!=. &  population!=. & exp_police!=. & exp_police>0 & shrink!=.  & arr_drugsale_spread!=.


//set font size
	grstyle clear , erase
	grstyle init
	grstyle set size 16pt: axis_title

////////////////////////////////////////////////////////////////////////////////
/// 						  Figures   									 
////////////////////////////////////////////////////////////////////////////////


cd "../$FiguresPath/"
	

/// FIGURE 4. INTERFLEX FIGURES FOR INTERACTION EFFECTS AND BINNING ESTIMATES



//use median value of hprime if shrink=0, 1, and median value of hrpime if shrink=1 for three cutoff values (for 4 estimated coefficients)

 _pctile hprime if shrink==0
local cutoff1 `r(r1)' 

 _pctile hprime if shrink==1
local cutoff2 `r(r1)' 
 
interflex arr_drugsale_spread pblack hprime $x  if sample==1 , cutoffs(`cutoff1' 1 `cutoff2') fe(city year) vce(cluster) cluster(city) xd(hist) xlab("{it:hprime}") dlab(Percent Black) ylab("Distance between Arrest Rates") yrange(-40(10)20)  sav(interflex_arr_city)

interflex arr_drugsale_spread pblack hprime $x if sample==1 , cutoffs(`cutoff1' 1 `cutoff2') fe(fstate year) vce(cluster) cluster(city) xd(hist) xlab("{it:hprime}") dlab(Percent Black) ylab("Distance between Arrest Rates") yrange(-40(10)20) sav(interflex_arr_state)


interflex exp_police pblack hprime $x  if sample==1 , cutoffs(`cutoff1' 1 `cutoff2') fe(city year) vce(cluster) cluster(city) xd(hist) xlab("{it:hprime}") dlab(Percent Black) ylab("Police Spending")  yrange(-200(10)100) sav(interflex_exp_city)

interflex exp_police pblack hprime $x if sample==1 , cutoffs(`cutoff1' 1 `cutoff2') fe(fstate year) vce(cluster) cluster(city) xd(hist) xlab("{it:hprime}") dlab(Percent Black) ylab("Police Spending") yrange(-200(10)100)  sav(interflex_exp_state)



// Figure C1. ASSESSING INTERACTION EFFECTS (Hainmueller, Mummolo and Xu (2018))
	 
// generate variables for box plot
egen hbin = cut(hprime) if sample==1, group(3)

foreach i in 0 1 2 {
	egen med_h`i'=median(pblack) if hbin==`i' & sample==1
	egen u_h`i'=pctile(pblack) if hbin==`i'   & sample==1, p(75)
	egen uu_h`i'=pctile(pblack) if hbin==`i'  & sample==1, p(95)
	egen l_h`i'=pctile(pblack) if hbin==`i'   & sample==1, p(25)
	egen ll_h`i'=pctile(pblack) if hbin==`i'  & sample==1, p(5)
}


foreach i in 0 1  {
	egen med_s`i'=median(pblack) if shrink==`i' & sample==1
	egen u_s`i'=pctile(pblack) if shrink==`i'   & sample==1, p(75)
	egen uu_s`i'=pctile(pblack) if shrink==`i'  & sample==1, p(95)
	egen l_s`i'=pctile(pblack) if shrink==`i'   & sample==1, p(25)
	egen ll_s`i'=pctile(pblack) if shrink==`i'  & sample==1, p(5)
}

//locate box plot for each group on y-axis

gen Y0=0
gen Y1=-5
gen Y2=-10
gen Ys0=-15
gen Ys1=-20

// retrieve hbin bounds
foreach i in 0 1 2 {
sum hprime if hbin==`i'
	local H`i'min `r(min)'
	local fmtH`i'min : display %4.3f `H`i'min'
	local H`i'max `r(max)'
	local fmtH`i'max : display %4.3f `H`i'max'
	}
	
// Boxplots of percent Black by shrink and hprime terciles
twoway  ///
(rbar med_s0 u_s0 Ys0, blc(black) bfc(gs14) barw(1.3) hor) /// Box plot 
(rbar med_s0 l_s0 Ys0, blc(black) bfc(gs14) barw(1.3) hor) ///
(rspike u_s0 uu_s0 Ys0 , blc(black) hor) ///
(rspike l_s0 ll_s0 Ys0 , blc(black) hor) ///
(rcap uu_s0 uu_s0 Ys0 , blc(black) msize(*1) hor) ///
(rcap ll_s0 ll_s0 Ys0 , blc(black) msize(*1) hor) ///
///
(rbar med_s1 u_s1 Ys1, blc(black) bfc(gs14) barw(1.3) hor) /// Box plot 
(rbar med_s1 l_s1 Ys1, blc(black) bfc(gs14) barw(1.3) hor) ///
(rspike u_s1 uu_s1 Ys1 , blc(black) hor) ///
(rspike l_s1 ll_s1 Ys1 , blc(black) hor) ///
(rcap uu_s1 uu_s1 Ys1 , blc(black) msize(*1) hor) ///
(rcap ll_s1 ll_s1 Ys1 , blc(black) msize(*1) hor) ///
///
(rbar med_h0 u_h0 Y0, blc(black) bfc(gs14) barw(1.3) hor) /// Box plot 
(rbar med_h0 l_h0 Y0, blc(black) bfc(gs14) barw(1.3) hor) ///
(rspike u_h0 uu_h0 Y0 , blc(black) hor) ///
(rspike l_h0 ll_h0 Y0 , blc(black) hor) ///
(rcap uu_h0 uu_h0 Y0 , blc(black) msize(*1) hor) ///
(rcap ll_h0 ll_h0 Y0 , blc(black) msize(*1) hor) ///
///
(rbar med_h1 u_h1 Y1, blc(black) bfc(gs14) barw(1.3) hor) /// Box plot 
(rbar med_h1 l_h1 Y1, blc(black) bfc(gs14) barw(1.3) hor) ///
(rspike u_h1 uu_h1 Y1 , blc(black) hor) ///
(rspike l_h1 ll_h1 Y1 , blc(black) hor) ///
(rcap uu_h1 uu_h1 Y1 , blc(black) msize(*1) hor) ///
(rcap ll_h1 ll_h1 Y1 , blc(black) msize(*1) hor) ///
///
(rbar med_h2 u_h2 Y2, blc(black) bfc(gs14) barw(1.3) hor) /// Box plot 
(rbar med_h2 l_h2 Y2, blc(black) bfc(gs14) barw(1.3) hor) ///
(rspike u_h2 uu_h2 Y2 , blc(black) hor) ///
(rspike l_h2 ll_h2 Y2 , blc(black) hor) ///
(rcap uu_h2 uu_h2 Y2 , blc(black) msize(*1) hor) ///
(rcap ll_h2 ll_h2 Y2 , blc(black) msize(*1) hor ///
///
 legend(off) mcolor(black%50)) ///
 , ylabel(0 "hprime: (`fmtH0min', `fmtH0max']" -5 "hprime: (`fmtH1min', `fmtH1max']" -10 "hprime: (`fmtH2min', `fmtH2max']" -15 "shrink=0, hprime<1" -20 "shrink=1, hprime>1" , noticks angle(horizontal) labsize(16pt) ) /// General plot controls
 xtitle(Percent Black, size(16pt)) xlabel(,labsize(16pt)) ///
 graphregion(color(white) lcolor(white) lwidth(vvvthick) lstyle(none)) plotregion(lstyle(none) lcolor(white) color(white) )
	graph export box_pblack.eps, replace 
 
