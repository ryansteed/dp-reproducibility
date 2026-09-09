*==============================================================================
* Description: This do-file creates subfigures in Figure A4
* Data: 2/7/2025
*===============================================================================
	
* Dataset
use "$datasets/final_penalties_dataset.dta", clear


* Variables of interest
gen high_p = spp 
gen high_f = drug_free
gen med_p = t_adj 

gen dist_2 = dist_drug
replace dist_2 = -dist_drug if drug_free==0
gen no_sc = (dist_2<=900)
drop if c_drug >=7 & year<=2010 & dist_drug<=1000 //outliers


**********************************************************
* Effect of Fines only 
* Pre-SPP (to isolate fine effect rather than monitoring 
* and other potential confounders that enter after SPP)
**********************************************************

* RD plot
set more off
rdplot drug_AM dist_2 if year<=2010 & dist_drug<=1000 & no_sc==1, ///
    nbins(25 25) p(2) graph_options(legend(off) xtitle("Distance to Drug-free Boundary") ///
    ylabel(0(0.2)1,nogrid) xlabel(,nogrid) scheme(s2mono)) 
    graph export "$output/rdplot.eps", replace


* McCrary test and histogram
* Histogram
hist dist_2 if year<=2010 & dist_drug<=1000 & no_sc==1, width(50) ///
 	xline(0, lcolor(red)) xtitle("Distance to Boundary") ///
 	ylabel(0(.0005)0.001) scheme(s2mono)
    graph export "$output/hist_dist.eps", replace


		
		