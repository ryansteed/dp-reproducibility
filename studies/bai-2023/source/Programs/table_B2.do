/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"

cd "C:\CR_Legacy\files\data"

**************************************************************************************
/*Table B2: County-level Panel Results: Revolutionary Intensity and Industrialization: Alternative Denominators*/
**************************************************************************************
	
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


/* COLUMN 1: 1953 Base-year Sample; ALTERNATIVE DENOM.: DEATHS IN 1966-76*/
	areg lnpnapop  y1964 y1964lnfracdeaths_ttl6676 y1982 y1982lnfracdeaths_ttl6676 y1990 y1990lnfracdeaths_ttl6676 y2000 y2000lnfracdeaths_ttl6676 `char' `ethf' `gini' `terrain' `distborder' `dist' `prov_t' `deng' `words' [aw=pop1964] if sample1953==1, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_denom.xls, bdec(3) keep(y1964lnfracdeaths_ttl6676 y1982lnfracdeaths_ttl6676 y1990lnfracdeaths_ttl6676 y2000lnfracdeaths_ttl6676 y1964lnfracdeaths y1982lnfracdeaths y1990lnfracdeaths y2000lnfracdeaths) label replace


/* COLUMN 2: 1964 Base-year Sample; ALTERNATIVE DENOM.: DEATHS IN 1966-76*/
	areg lnpnapop  y1982 y1982lnfracdeaths_ttl6676 y1990 y1990lnfracdeaths_ttl6676 y2000 y2000lnfracdeaths_ttl6676 `char1' `ethf1' `gini1' `terrain1' `distborder1' `dist1' `prov_t' `deng1' `words1' [aw=pop1964] if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_denom.xls, bdec(3) keep(y1964lnfracdeaths_ttl6676 y1982lnfracdeaths_ttl6676 y1990lnfracdeaths_ttl6676 y2000lnfracdeaths_ttl6676 y1964lnfracdeaths y1982lnfracdeaths y1990lnfracdeaths y2000lnfracdeaths) label append

	
/* COLUMN 3: 1953 Base-year Sample; ALTERNATIVE DENOM.: DEATHS IN 1966-71*/ 
	areg lnpnapop  y1964 y1964lnfracdeaths_ttl6671 y1982 y1982lnfracdeaths_ttl6671 y1990 y1990lnfracdeaths_ttl6671 y2000 y2000lnfracdeaths_ttl6671 `char' `ethf' `gini' `terrain' `distborder' `dist' `prov_t' `deng' `words' [aw=pop1964] if sample1953==1, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_denom.xls, bdec(3) keep(y1964lnfracdeaths_ttl6671 y1982lnfracdeaths_ttl6671 y1990lnfracdeaths_ttl6671 y2000lnfracdeaths_ttl6671 y1964lnfracdeaths y1982lnfracdeaths y1990lnfracdeaths y2000lnfracdeaths) label append


/* COLUMN 4: 1964 Base-year Sample; ALTERNATIVE DENOM.: DEATHS IN 1966-71*/
	areg lnpnapop  y1982 y1982lnfracdeaths_ttl6671 y1990 y1990lnfracdeaths_ttl6671 y2000 y2000lnfracdeaths_ttl6671 `char1' `ethf1' `gini1' `terrain1' `distborder1' `dist1' `prov_t' `deng1' `words1' [aw=pop1964] if year>=1964, absorb(cntygb) robust cluster(cntygb)
	outreg2 using $results\\dd_death_fullctrl_denom.xls, bdec(3) keep(y1964lnfracdeaths_ttl6671 y1982lnfracdeaths_ttl6671 y1990lnfracdeaths_ttl6671 y2000lnfracdeaths_ttl6671 y1964lnfracdeaths y1982lnfracdeaths y1990lnfracdeaths y2000lnfracdeaths) label append
	

