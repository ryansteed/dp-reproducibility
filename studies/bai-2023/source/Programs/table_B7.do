/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"

cd "C:\CR_Legacy\files\data"

*************************************************************************************************************
/*Table B7: County-level Panel Results: Revolutionary Intensity and Industrialization: Quantile Regressions*/
*************************************************************************************************************

use county_panel, clear

* Define variable lists
	local gini       y1964Xln_gini y1982Xln_gini y1990Xln_gini y2000Xln_gini
	local ethf       y1964Xln_ethf y1982Xln_ethf y1990Xln_ethf y2000Xln_ethf
	local char       y1964Xln_charity y1982Xln_charity y1990Xln_charity y2000Xln_charity
	local terrain    y1964Xln_slp y1982Xln_slp y1990Xln_slp y2000Xln_slp
	local distborder y1964Xln_provdist y1982Xln_provdist y1990Xln_provdist y2000Xln_provdist
	local dist       y1964Xln_dist_pcap y1982Xln_dist_pcap  y1990Xln_dist_pcap  y2000Xln_dist_pcap 
	local words      y1964Xlnwords1 y1964Xlnwords2 y1982Xlnwords1 y1982Xlnwords2 y1990Xlnwords1 y1990Xlnwords2 y2000Xlnwords1 y2000Xlnwords2
	local deng       y1964Xdeng y1982Xdeng y1990Xdeng y2000Xdeng
	local prov_t     t_prov*

* When using qreg2, first demean the dependent and independent variables
	foreach var of varlist lnpnapop y1964 y1964lnfracdeaths y1982 y1982lnfracdeaths y1990 y1990lnfracdeaths y2000 y2000lnfracdeaths ///
	`char' `ethf' `gini' `terrain' `distborder' `dist' `prov_t' `words' `deng' {
	
		egen `var'_bar = mean(`var'), by(cntygb)
		gen  `var'_dm = `var' - `var'_bar
	
	}
	
* Define demeaned variable lists
	global gini_dm    y1982Xln_gini_dm y1990Xln_gini_dm y2000Xln_gini_dm
	global ethf_dm    y1982Xln_ethf_dm y1990Xln_ethf_dm y2000Xln_ethf_dm
	global char_dm    y1982Xln_charity_dm y1990Xln_charity_dm y2000Xln_charity_dm
	global terrain_dm y1982Xln_slp_dm y1990Xln_slp_dm y2000Xln_slp_dm
	global dist_dm    y1982Xln_dist_pcap_dm  y1990Xln_dist_pcap_dm  y2000Xln_dist_pcap_dm
	global distborder_dm y1982Xln_provdist_dm y1990Xln_provdist_dm y2000Xln_provdist_dm
	global deng_dm    y1982Xdeng_dm y1990Xdeng_dm y2000Xdeng_dm
	global words_dm   y1982Xlnwords1_dm y1982Xlnwords2_dm y1990Xlnwords1_dm y1990Xlnwords2_dm y2000Xlnwords1_dm y2000Xlnwords2_dm	
	global prov_t_dm  t_provc1_dm t_provc2_dm t_provc3_dm t_provc4_dm t_provc5_dm t_provc6_dm t_provc7_dm t_provc8_dm t_provc9_dm ///
					  t_provc10_dm t_provc11_dm t_provc12_dm t_provc13_dm t_provc14_dm t_provc15_dm t_provc16_dm t_provc17_dm ///
					  t_provc18_dm t_provc19_dm t_provc20_dm t_provc21_dm t_provc22_dm t_provc23_dm t_provc24_dm t_provc25_dm ///
					  t_provc26_dm t_provc27_dm

*sample = 600	
	qreg2 lnpnapop_dm y1982_dm y1982lnfracdeaths_dm y1990_dm y1990lnfracdeaths_dm y2000_dm y2000lnfracdeaths_dm ///
	$char_dm $ethf_dm $gini_dm $terrain_dm $distborder_dm $dist_dm $prov_t_dm $words_dm $deng_dm if sample1953==1 & year>=1964, quantile(.1) cluster(cntygb)
	
	outreg2 using $results//dd_death_fullctrl_qreg_600.xls, bdec(3)   ///
	keep(y1964lnfracdeaths_dm y1982lnfracdeaths_dm y1990lnfracdeaths_dm y2000lnfracdeaths_dm)  ///
	label addtex(Quantile, .1, County FE, Yes, Year FE, Yes, Provincial Time Trend, Yes, Weighted, No) replace  
	
	forvalues i = .2(.1).9 {
	
	qreg2 lnpnapop_dm y1982_dm y1982lnfracdeaths_dm y1990_dm y1990lnfracdeaths_dm y2000_dm y2000lnfracdeaths_dm ///
	$char_dm $ethf_dm $gini_dm $terrain_dm $distborder_dm $dist_dm $prov_t_dm $words_dm $deng_dm if sample1953==1 & year>=1964, quantile(`i') cluster(cntygb)
	
	outreg2 using $results//dd_death_fullctrl_qreg_600.xls, bdec(3) ///
	keep(y1964lnfracdeaths_dm y1982lnfracdeaths_dm y1990lnfracdeaths_dm y2000lnfracdeaths_dm) ///
	label addtex(Quantile, `i', County FE, Yes, Year FE, Yes, Provincial Time Trend, Yes, Weighted, No) append
	
	}
	
*sample = 1486
	qreg2 lnpnapop_dm y1982_dm y1982lnfracdeaths_dm y1990_dm y1990lnfracdeaths_dm y2000_dm y2000lnfracdeaths_dm ///
	$char_dm $ethf_dm $gini_dm $terrain_dm $distborder_dm $dist_dm $prov_t_dm $words_dm $deng_dm if year>=1964, quantile(.1) cluster(cntygb)
	
	outreg2 using $results//dd_death_fullctrl_qreg_1486.xls, bdec(3)  ///
	keep(y1964lnfracdeaths_dm y1982lnfracdeaths_dm y1990lnfracdeaths_dm y2000lnfracdeaths_dm)  ///
	label addtex(Quantile, .1, County FE, Yes, Year FE, Yes, Provincial Time Trend, Yes, Weighted, No) replace
	
	forvalues i = .2(.1).9 {
	
	qreg2 lnpnapop_dm y1982_dm y1982lnfracdeaths_dm y1990_dm y1990lnfracdeaths_dm y2000_dm y2000lnfracdeaths_dm ///
	$char_dm $ethf_dm $gini_dm $terrain_dm $distborder_dm $dist_dm $prov_t_dm $words_dm $deng_dm if year>=1964, quantile(`i') cluster(cntygb)
	
	outreg2 using $results//dd_death_fullctrl_qreg_1486.xls, bdec(3)  ///
	keep(y1964lnfracdeaths_dm y1982lnfracdeaths_dm y1990lnfracdeaths_dm y2000lnfracdeaths_dm)  ///
	label addtex(Quantile, `i', County FE, Yes, Year FE, Yes, Provincial Time Trend, Yes, Weighted, No) append
	
	}
	

