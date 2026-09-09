/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"

cd "C:\CR_Legacy\files\data"

**************************************************************************************
/*Table B5: County-level Panel Results: Controlling for Migration and Population Density */
**************************************************************************************
 use county_panel.dta, clear
	
*For 1964 Base-year Sample
	local gini1       y1982Xln_gini y1990Xln_gini y2000Xln_gini
	local ethf1       y1982Xln_ethf y1990Xln_ethf y2000Xln_ethf
	local char1       y1982Xln_charity y1990Xln_charity y2000Xln_charity
	local terrain1    y1982Xln_slp y1990Xln_slp y2000Xln_slp
	local distborder1 y1982Xln_provdist y1990Xln_provdist y2000Xln_provdist
	local dist1       y1982Xln_dist_pcap  y1990Xln_dist_pcap  y2000Xln_dist_pcap 
	local words1      y1982Xlnwords1 y1982Xlnwords2 y1990Xlnwords1 y1990Xlnwords2 y2000Xlnwords1 y2000Xlnwords2
	local deng1       y1982Xdeng y1990Xdeng y2000Xdeng
	local prov_t      t_prov*

	areg lnpnapop  y1982 y1982lnfracdeaths y1990 y1990lnfracdeaths y2000 y2000lnfracdeaths `char1' `ethf1'  `gini1'  `terrain1' `distborder1' `dist1' `prov_t' `words1' `deng1' ln_mig  [aw=pop1964]  if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_mig_popden.xls, bdec(3) keep(y1964lnfracdeaths y1982lnfracdeaths y1990lnfracdeaths y2000lnfracdeaths ) label replace

	areg lnpnapop  y1982 y1982lnfracdeaths y1990 y1990lnfracdeaths y2000 y2000lnfracdeaths `char1' `ethf1'  `gini1'  `terrain1' `distborder1' `dist1' `prov_t' `words1' `deng1' ln_popden [aw=pop1964]  if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_mig_popden.xls, bdec(3) keep(y1964lnfracdeaths y1982lnfracdeaths y1990lnfracdeaths y2000lnfracdeaths ) label append
	
	areg lnpnapop  y1982 y1982lnfracdeaths y1990 y1990lnfracdeaths y2000 y2000lnfracdeaths `char1' `ethf1'  `gini1'  `terrain1' `distborder1' `dist1' `prov_t' `words1' `deng1' ln_mig ln_popden [aw=pop1964]  if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_mig_popden.xls, bdec(3) keep(y1964lnfracdeaths y1982lnfracdeaths y1990lnfracdeaths y2000lnfracdeaths  ) label append


