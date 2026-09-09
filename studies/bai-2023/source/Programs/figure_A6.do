/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"

cd "C:\CR_Legacy\files\data"

	
**************************************************************************************
/*Figure A6: Revolutionary Intensity and Sex Ratios*/
**************************************************************************************
	
use sexratio_data.dta, clear

	*BASE GROUP = [1951,1955]
	reg pop_sr yearcat_intensity2-yearcat_intensity10 i.Year i.provID, r cluster(provID)
			
	coefplot, label keep(yearcat_intensity2 yearcat_intensity3 yearcat_intensity4 yearcat_intensity5 yearcat_intensity6 yearcat_intensity7 yearcat_intensity8 yearcat_intensity9 yearcat_intensity10) ///
			vertical recast(connect) lcolor(red*0.45) ciopts(lcolor(edkblue*0.8))	mlcolor(gs6) ///
			ytitle("Coef. of CR Intensity * 5-Year Bin Dummy ") ///
			xtitle("5-year bins (range: 1951-2000; base = [1951,1955])",  margin(t=3)) ///
			yline(0, lpattern(dash) lcolor(blue)) ///
			xsize(6) ysize(4)

	graph export $results\\DID_sex_ratio.pdf, replace




