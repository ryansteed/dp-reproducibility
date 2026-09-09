/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "../../results"

cd "../data"

	
***********************************************************************************************************
/*Table B8: County-level Panel Results: Revolutionary Intensity and Industrialization: Non-Linear Effects*/
***********************************************************************************************************

use county_panel.dta, clear

*For 1953 Base-year Sample
	local gini       y1964Xln_gini y1982Xln_gini y1990Xln_gini y2000Xln_gini
	local ethf       y1964Xln_ethf y1982Xln_ethf y1990Xln_ethf y2000Xln_ethf
	local char       y1964Xln_charity y1982Xln_charity y1990Xln_charity y2000Xln_charity
	local terrain    y1964Xln_slp y1982Xln_slp y1990Xln_slp y2000Xln_slp
	local distborder y1964Xln_provdist y1982Xln_provdist y1990Xln_provdist y2000Xln_provdist
	local dist       y1964Xln_dist_pcap y1982Xln_dist_pcap  y1990Xln_dist_pcap  y2000Xln_dist_pcap 
	local words      y1964Xlnwords1 y1964Xlnwords2 y1982Xlnwords1 y1982Xlnwords2 y1990Xlnwords1 y1990Xlnwords2 y2000Xlnwords1 y2000Xlnwords2
	local deng       y1964Xdeng y1982Xdeng y1990Xdeng y2000Xdeng
	local famine     y1964Xfamine_severity  y1982Xfamine_severity  y1990Xfamine_severity  y2000Xfamine_severity  

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
	local famine1     y1982Xfamine_severity y1990Xfamine_severity y2000Xfamine_severity  


	gen lnfracdeaths_sq = lnfracdeaths^2
	gen y1953lnfracdeaths_sq = lnfracdeaths_sq*y1953
	gen y1964lnfracdeaths_sq = lnfracdeaths_sq*y1964	
	gen y1982lnfracdeaths_sq = lnfracdeaths_sq*y1982
	gen y1990lnfracdeaths_sq = lnfracdeaths_sq*y1990
	gen y2000lnfracdeaths_sq = lnfracdeaths_sq*y2000
	
	foreach i in 1964 1982 1990 2000{
	label var y`i'lnfracdeaths_sq "Deaths_sq (% of county pop.) x D`i'"
	}

	*1953 Base-year Sample
	areg lnpnapop  y1964 y1964lnfracdeaths y1964lnfracdeaths_sq y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000  y2000lnfracdeaths y2000lnfracdeaths_sq `char' `ethf'  `gini'  [aw=pop1964] if sample1953==1, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label replace
	
	areg lnpnapop  y1964 y1964lnfracdeaths y1964lnfracdeaths_sq y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000  y2000lnfracdeaths y2000lnfracdeaths_sq `char' `ethf'  `gini'  `terrain' `distborder' `dist' [aw=pop1964] if sample1953==1, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label append

	areg lnpnapop  y1964 y1964lnfracdeaths y1964lnfracdeaths_sq y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000  y2000lnfracdeaths y2000lnfracdeaths_sq `char' `ethf'  `gini'  `terrain' `distborder' `dist' `prov_t' [aw=pop1964] if sample1953==1, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label append
	
	areg lnpnapop  y1964 y1964lnfracdeaths y1964lnfracdeaths_sq y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000  y2000lnfracdeaths y2000lnfracdeaths_sq `char' `ethf'  `gini'  `terrain' `distborder' `dist' `prov_t' `words' `deng' [aw=pop1964]  if sample1953==1, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label append

	*1964 Base-year Sample
	areg lnpnapop  y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000 y2000lnfracdeaths y2000lnfracdeaths_sq `char1' `ethf1'  `gini1' [aw=pop1964] if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label append
	
	areg lnpnapop  y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000 y2000lnfracdeaths y2000lnfracdeaths_sq `char1' `ethf1'  `gini1'  `terrain1' `distborder1' `dist1' [aw=pop1964]  if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label append

	areg lnpnapop  y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000 y2000lnfracdeaths y2000lnfracdeaths_sq `char1' `ethf1'  `gini1'  `terrain1' `distborder1' `dist1' `prov_t' [aw=pop1964]  if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label append
	
	areg lnpnapop  y1982 y1982lnfracdeaths y1982lnfracdeaths_sq y1990 y1990lnfracdeaths y1990lnfracdeaths_sq y2000 y2000lnfracdeaths y2000lnfracdeaths_sq `char1' `ethf1'  `gini1'  `terrain1' `distborder1' `dist1' `prov_t' `words1' `deng1' [aw=pop1964]  if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_deaths_sq.xls, bdec(3) keep(y1964lnfracdeaths y1964lnfracdeaths_sq y1982lnfracdeaths y1982lnfracdeaths_sq y1990lnfracdeaths y1990lnfracdeaths_sq y2000lnfracdeaths y2000lnfracdeaths_sq) label append


