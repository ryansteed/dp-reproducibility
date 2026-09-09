/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off
set matsize 10000

global results "C:\CR_Legacy\files\results"

cd "C:\CR_Legacy\files\data"

**************************************************************************************
/*Table B6: Revolutionary Intensity and Industrialization: Controlling for Mean Reversion */
**************************************************************************************

use cross_sectional_countydata.dta, clear

local controls ln_slp ln_provdist ln_gini ln_ethf ln_charity ln_dist_pcap deng lnwords1 lnwords2

	reg diff6482 lnfracdeaths `controls' [w=pop1964] if sample1953 == 1, robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths `controls') label addtex(Weighted, Yes) replace

	reg diff6482 lnfracdeaths lnpnapop1964 `controls' [w=pop1964] if sample1953 == 1, robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths lnpnapop1964 `controls') label addtex(Weighted, Yes) append

	reg diff6482 lnfracdeaths `controls' [w=pop1964], robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths `controls') label addtex(Weighted, Yes) append

	reg diff6482 lnfracdeaths lnpnapop1964 `controls' [w=pop1964], robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths lnpnapop1964 `controls') label addtex(Weighted, Yes) append


	reg diff6490 lnfracdeaths `controls' [w=pop1964] if sample1953 == 1, robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths `controls') label addtex(Weighted, Yes) append

	reg diff6490 lnfracdeaths lnpnapop1964 `controls' [w=pop1964] if sample1953 == 1, robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths lnpnapop1964 `controls') label addtex(Weighted, Yes) append

	reg diff6490 lnfracdeaths `controls' [w=pop1964], robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths `controls') label addtex(Weighted, Yes) append

	reg diff6490 lnfracdeaths lnpnapop1964 `controls' [w=pop1964], robust
	outreg2 using $results//mean_reversion_diff.xls, bdec(3) keep(lnfracdeaths lnpnapop1964 `controls') label addtex(Weighted, Yes) append

