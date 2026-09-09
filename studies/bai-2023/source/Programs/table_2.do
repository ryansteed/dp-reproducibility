/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

 ***************************************************************************************************/

clear
set more off

global results "../../results"

cd "../Data"
			 
*****************************************************************************
/*TABLE 2: Determinants of Revolutionary Intensity*/
*****************************************************************************
			 
use cross_sectional_countydata, clear
	
	reg lnfracdeaths lnpnapop1964 ln_slp  ln_provdist ln_dist_pcap i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_1486.xls, bdec(3) label addtex(Province FE, Yes) replace	
	reg lnfracdeaths lnpnapop1964 ln_slp  ln_provdist ln_dist_pcap ln_gini ln_ethf ln_char i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_1486.xls, bdec(3) label addtex(Province FE, Yes) append	
	reg lnfracdeaths lnpnapop1964 ln_slp  ln_provdist ln_dist_pcap ln_gini ln_ethf ln_char deng i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_1486.xls, bdec(3) label addtex(Province FE, Yes) append	
	reg lnfracdeaths lnpnapop1964 ln_slp  ln_provdist ln_dist_pcap ln_gini ln_ethf ln_char deng lnwords* i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_1486.xls, bdec(3) label addtex(Province FE, Yes) append		
	
	keep if sample1953==1
	
	reg lnfracdeaths lnpnapop1953 diff5364 ln_slp  ln_provdist ln_dist_pcap i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_600.xls, bdec(3) label addtex(Province FE, Yes) replace	
	reg lnfracdeaths lnpnapop1953 diff5364 ln_slp  ln_provdist ln_dist_pcap ln_gini ln_ethf ln_char i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_600.xls, bdec(3) label addtex(Province FE, Yes) append	
	reg lnfracdeaths lnpnapop1953 diff5364 ln_slp  ln_provdist ln_dist_pcap ln_gini ln_ethf ln_char deng i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_600.xls, bdec(3) label addtex(Province FE, Yes) append	
	reg lnfracdeaths lnpnapop1953 diff5364 ln_slp  ln_provdist ln_dist_pcap ln_gini ln_ethf ln_char deng lnwords* i.provgb, cluster(provgb)
	* outreg2 using $results\\explain_death_600.xls, bdec(3) label addtex(Province FE, Yes) append	

cd "../Programs"