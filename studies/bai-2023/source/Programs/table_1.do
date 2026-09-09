/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

 ***************************************************************************************************/

clear
set more off

cd "../Data"


********************************
/* TABLE 1:Summary Statistics */
********************************

use cross_sectional_countydata.dta, clear

*1953 Base-year Sample, N=600

sum deaths lnfracdeaths ///
pnapop1953 pnapop1964 pnapop1982 pnapop1990 pnapop2000 ///
pop1964_unit gini ethf charity ln_provdist ln_dist_pcap ///
pubdate lnwords1 lnwords2 deng if sample1953==1, sep(100)		

*1964 Base-year Sample, N=1486

sum deaths lnfracdeaths ///
pnapop1964 pnapop1982 pnapop1990 pnapop2000 ///
pop1964_unit gini ethf charity ln_provdist ln_dist_pcap ///
pubdate lnwords1 lnwords2 deng, sep(100)		

*T-test	

gen sample = 1

preserve

keep if pnapop1953 != .
replace sample = 0
save temp_data.dta, replace

restore

append using temp_data.dta

*T-test by VAR=sample 
		qui{
		noi di "Table`=char(9)'N1`=char(9)'Mean1 `=char(9)'N2`=char(9)'Mean2`=char(9)'p-value"
		foreach var of varlist deaths lnfracdeaths ///
		pnapop1964 pnapop1982 pnapop1990 pnapop2000 ///
		pop1964_unit gini ethf charity ln_provdist ln_dist_pcap ///
		pubdate lnwords1 lnwords2 deng{
		cap ttest `var', by (sample)
		noi di as text "`var'`=char(9)'" as result %8.0f `r(N_1)' "`=char(9)'" %8.3f `r(mu_1)' "`=char(9)'" %8.0f `r(N_2)' "`=char(9)'" %8.3f `r(mu_2)' %8.2f `r(p)'
		}
		}

cd "../Programs"