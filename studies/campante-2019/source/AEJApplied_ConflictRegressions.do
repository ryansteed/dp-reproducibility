clear all
set matsize 10000
*global Dropbox "C:\Users\quocanh.do\Dropbox"
global Dropbox "."
*global Dropbox "F:\Dropbox"
global DataFolder "."
cd "$DataFolder"


global gdpcontrols "avg_loggcppc avg_logpop"
global controls "avg_loggcppc avg_logpop imr logttime logcellarea avg_logdist_LNC"
global controls2 "${controls} mountain2000 ycoord avg_degtemper avg_prec" //not including forest2000


//--- Table 3: cross-cell regressions of time-average conflict probabilities and onset probabilities
global filename "Table3_crosscell.xls"
cap erase "$filename"
local v = subinstr("$filename","xls","txt",.)
cap erase `v'

/*use workingfile2, clear

egen tag_gid = tag(gid)
keep if tag_gid==1

save bygid_confdata, replace */

// Col 1
use bygid_confdata, clear

areg avg_ConfIntra avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", replace ctitle("With full controls") bracket title("Average probability of conflict - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

// Col 2, 3 & summary stats
use bygid_confdata, clear
keep if avg_polity2<=0

eststo: areg avg_ConfIntra avg_logcapdist ${controls2} , a(isocode) cluster(iso)
* outreg2 using "$filename", append ctitle("Polity <=0, full controls, ConfGov") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
	
cap drop sample
gen sample = e(sample)
global avg_Conf_list = "avg_ConfGov avg_ConfTerr avg_ConfType3 avg_ConfType4 avg_ConfIntense avg_ConfNonIntense avg_ConfInter"
qui outreg2 using sum_workingfile2_autoc.xls if sample, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90) keep(avg_ConfIntra $avg_Conf_list avg_logcapdist ${controls2}) excel

global controls2x = subinstr("$controls2","avg_logdist_LNC","",.)
areg avg_ConfIntra  avg_logdist_LNC ${controls2x} if sample, a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Placebo: dist LNC") bracket title("Average probability of conflict - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

/*
// Col 4 & summary stats
use bygid_confdata, clear

areg avg_ConfIntra avg_logcapdist ${controls2} if avg_polity2>0 , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity >0") bracket title("Average probability of conflict - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)
	
cap drop sample
gen sample = e(sample)
qui outreg2 using sum_workingfile2_democ.xls if sample, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90) keep(avg_ConfIntra avg_logcapdist ${controls2}) excel

// Test Col 2 - Col 4
use bygid_confdata, clear

qui xi i.isocode

qui reg avg_ConfIntra avg_logcapdist ${controls2} _Iisocode* if avg_polity2<=0
est sto EstAuto
qui reg avg_ConfIntra avg_logcapdist ${controls2} _Iisocode* if avg_polity2>0
est sto EstDemo

qui suest EstAuto EstDemo, vce(cluster iso)
test [EstAuto_mean=EstDemo_mean]: avg_logcapdist
estimates drop EstAuto EstDemo

cap drop _Iisocode*

** EDIT by Donna
/*

//code to draw effect by value -- used for Figure 1 
use bygid_confdata, clear

global N = 50
global band = 0.5 //0.1                    
cap drop Xvar
gen Xvar = avg_logdens
*xtile Xvar = avg_logcapdist, n(${N})
sum Xvar                     
global min = r(min)
global max = r(max)                                                                                                                                                                       
global range = $max-$min
global bandwidth = $band*$range
cap drop beta upper_bound lower_bound
gen beta = .
gen upper_bound = .
gen lower_bound = .
global k = $N-2
forval i = 2/$k {   //max range: 0 to $N
	local point = `i'*$range/$N + $min
	cap drop weight
	*gen weight = normalden((Xvar - `point')/$bandwidth)   //Gaussian kernel
	gen weight = max(0,1-( (Xvar - `point')/$bandwidth )^2)*3/4    //Epanechnikov kernel
	quietly areg avg_ConfIntra avg_logcapdist ${controls2} [aw=weight] if avg_polity2<=0, a(isocode) cluster(iso)
	mat B = e(b)
	mat V = e(V)
	local place = `i'+1
	qui {
		replace beta = B[1,1] in `place'
		replace upper_bound = 1.96*sqrt(V[1,1]) + B[1,1] in `place'
		replace lower_bound = -1.96*sqrt(V[1,1]) + B[1,1] in `place'
	}                    
}
cap drop axis
gen axis = $min + (_n-1)*$range/$N
twoway (line beta axis) (line upper_bound axis, lwidth(thin) lcolor(blue)) (line lower_bound axis, lwidth(thin) lcolor(blue)) if inrange(axis, floor($min), floor($max)+1)
// This graph will be used to explain that measurement errors cannot fully drive the results.

*/

*global filename "Table3_crosscell.xls"
/*use workingfile2_onset, clear

egen tag_gid = tag(gid)
keep if tag_gid==1

save bygid_onsetdata, replace */

// Col 5
use bygid_onsetdata, clear

areg avg_onsetIntra avg_logcapdist ${controls2}, a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Intra-onset, no controls") bracket title("Average probability of conflict onset - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

// Col 6, 7 & summary stats
use bygid_onsetdata, clear
keep if avg_polity2<=0

areg avg_onsetIntra avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", ctitle("Polity <=0") bracket title("Average probability of conflict onset - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)
cap drop sample
gen sample = e(sample)
qui outreg2 using sum_workingfile2_onset_autoc.xls if sample, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90) keep(avg_onsetIntra avg_logcapdist ${controls2}) excel

global controls2x = subinstr("$controls2","avg_logdist_LNC","",.)
areg avg_onsetIntra avg_logdist_LNC ${controls2x} if sample, a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Placebo: dist LNC") bracket title("Average probability of conflict onset - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)
	
// Col 8 & summary stats
use bygid_onsetdata, clear

areg avg_onsetIntra avg_logcapdist ${controls2} if avg_polity2>0, a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Intra-onset, Polity>0, controls") bracket title("Average probability of conflict onset - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

cap drop sample
gen sample = e(sample)
qui outreg2 using sum_workingfile2_onset_democ.xls if sample, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90) keep(avg_onsetIntra avg_logcapdist ${controls2}) excel


use bygid_onsetdata, clear

qui xi i.isocode

qui reg avg_onsetIntra avg_logcapdist ${controls2} _Iisocode* if avg_polity2<=0
est sto EstAuto
qui reg avg_onsetIntra avg_logcapdist ${controls2} _Iisocode* if avg_polity2>0
est sto EstDemo

qui suest EstAuto EstDemo, vce(cluster iso)
test [EstAuto_mean=EstDemo_mean]: avg_logcapdist
estimates drop EstAuto EstDemo

cap drop _Iisocode*

*** EDIT by Donna
/*
//code to draw effect by value -- Appendix Figure E1
use bygid_onsetdata, clear

global N = 50
global band = 0.5 //0.1                    
cap drop Xvar
gen Xvar = avg_logdens
*xtile Xvar = avg_logcapdist, n(${N})
sum Xvar                     
global min = r(min)
global max = r(max)                                                                                                                                                                       
global range = $max-$min
global bandwidth = $band*$range
cap drop beta upper_bound lower_bound
gen beta = .
gen upper_bound = .
gen lower_bound = .
forval i = 0/$N {
	local point = `i'*$range/$N + $min
	cap drop weight
	
	*gen weight = normalden((Xvar - `point')/$bandwidth)   //Gaussian kernel
	gen weight = max(0,1-( (Xvar - `point')/$bandwidth )^2)*3/4    //Epanechnikov kernel
	
	quietly areg avg_onsetIntra avg_logcapdist ${controls2} [aw=weight] if avg_polity2<=0, a(isocode) cluster(iso)
	mat B = e(b)
	mat V = e(V)
	local place = `i'+1
	qui {
		replace beta = B[1,1] in `place'
		replace upper_bound = 1.96*sqrt(V[1,1]) + B[1,1] in `place'
		replace lower_bound = -1.96*sqrt(V[1,1]) + B[1,1] in `place'
	}                    
}
cap drop axis
gen axis = $min + (_n-1)*$range/$N
twoway (line beta axis) (line upper_bound axis, lwidth(thin) lcolor(blue)) (line lower_bound axis, lwidth(thin) lcolor(blue)) if inrange(axis, floor($min), floor($max)+1)
*/
	
	
//--- Table 4: cross-cell regressions of time-average conflict and onset probabilities, with different types of conflicts
global filename "Table4_crosscell_types.xls"
cap erase "$filename"
local v = subinstr("$filename","xls","txt",.)
cap erase `v'

//--- Panel A -- with conflict types
use bygid_confdata, clear
keep if avg_polity2<=0

areg avg_ConfGov avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", replace ctitle("Polity <=0, full controls, ConfGov") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)
	
cap drop sample
gen sample = e(sample)
global avg_Conf_list = "avg_ConfGov avg_ConfTerr avg_ConfType3 avg_ConfType4 avg_ConfIntense avg_ConfNonIntense avg_ConfInter"
qui outreg2 using sum_workingfile2_autoc.xls if sample, sum(detail) append eqkeep(N mean sd min max p10 p50 p90) keep(avg_ConfIntra $avg_Conf_list avg_logcapdist ${controls2}) excel

areg avg_ConfTerr avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, ConfTerr") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_ConfType3 avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, ConfType3") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_ConfType4 avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, ConfType4") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_ConfIntense avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, Intense") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_ConfNonIntense avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, NonIntense") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_ConfInter avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, Interstate") bracket title("Average probability of conflict types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

//--- Panel B -- now with onsets	

use bygid_onsetdata, clear
keep if avg_polity2<=0

areg avg_onsetGov avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, onset Gov") bracket title("Average probability of onset types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)
	
cap drop sample
gen sample = e(sample)
global avg_onset_list = "avg_onsetGov avg_onsetTerr avg_onsetType3 avg_onsetType4 avg_onsetIntense avg_onsetNonIntense avg_onsetInter"
qui outreg2 using sum_workingfile2_autoc.xls if sample, sum(detail) append eqkeep(N mean sd min max p10 p50 p90) keep($avg_onset_list avg_logcapdist ${controls2}) excel

areg avg_onsetTerr avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, onset Terr") bracket title("Average probability of onset types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_onsetType3 avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, onset Type3") bracket title("Average probability of onset types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_onsetType4 avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, onset Type4") bracket title("Average probability of onset types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_onsetIntense avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, onset Intense") bracket title("Average probability of onset types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_onsetNonIntense avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, onset NonIntense") bracket title("Average probability of onset types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)

areg avg_onsetInter avg_logcapdist ${controls2} , a(isocode) cluster(iso)
outreg2 using "$filename", append ctitle("Polity <=0, full controls, onset Interstate") bracket title("Average probability of onset types - cross-cells") nocons excel ///
	addtext(Country FEs, Yes)


//--- Table 5 in paper: list of countries with different types of variation in cell's distance to capital

//--- Table 6: within-cell regressions of intra-conflict onset events & summary stats
global filename "Table6_withincell_onset.xls"
cap erase "$filename"
local v = subinstr("$filename","xls","txt",.)
cap erase `v'

use workingfile2_onset, clear
drop if iso==""
set matsize 11000

global controls_tvar "logbdist2 degtemper prec "
global Cont = "logbdist2 degtemper prec i.year"

// avg_polity2>0
areg onsetIntra logcapdist ${Cont} if avg_polity2 >0 , a(gid) cluster(isocode)
outreg2 using "$filename", replace ctitle("Polity >0, controls") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)

cap drop sample
gen sample = e(sample)
global onset_list = "onsetIntra onsetGov onsetTerr onsetType3 onsetType4 onsetIntense onsetNonIntense onsetInter"
qui outreg2 using sum_workingfile2_onset_democ.xls if sample, sum(detail) append eqkeep(N mean sd min max p10 p50 p90) keep($onset_list logcapdist ${controls_tvar}) excel


// avg_polity2 <=0
keep if avg_polity2 <=0

areg onsetIntra logcapdist ${Cont} , a(gid) cluster(isocode) //avg_polity2 <=0
outreg2 using "$filename", append ctitle("Polity <=0, controls") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)

cap drop sample
gen sample = e(sample)
* global onset_list = "onsetIntra onsetGov onsetTerr onsetType3 onsetType4 onsetIntense onsetNonIntense onsetInter"
*** EDIT by Donna
global onset_list "onsetIntra onsetGov onsetTerr onsetType3 onsetType4 onsetIntense onsetNonIntense onsetInter"
qui outreg2 using sum_workingfile2_onset_autoc.xls if sample, sum(detail) append eqkeep(N mean sd min max p10 p50 p90) keep($onset_list logcapdist ${controls_tvar}) excel


areg onsetGov logcapdist ${Cont} , a(gid) cluster(isocode) //avg_polity2 <=0
outreg2 using "$filename", append ctitle("Polity <=0, Gov, controls") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)
areg onsetTerr logcapdist ${Cont} , a(gid) cluster(isocode) //avg_polity2 <=0
outreg2 using "$filename", append ctitle("Polity <=0, Terr, controls") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)
areg onsetType3 logcapdist ${Cont} , a(gid) cluster(isocode) //avg_polity2 <=0
outreg2 using "$filename", append ctitle("Polity <=0, Type 3, controls") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)
areg onsetType4 logcapdist ${Cont} , a(gid) cluster(isocode) //avg_polity2 <=0
outreg2 using "$filename", append ctitle("Polity <=0, Type 4, controls") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)

areg onsetInter logcapdist ${Cont} , a(gid) cluster(isocode) //avg_polity2 <=0
outreg2 using "$filename", append ctitle("Polity <=0, Inter, controls") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)


	
// Cols 8-9 only variations within 5 years of capital change

global filename "Table6_withincell_onset.xls"

use workingfile2_onset, clear

sort gid year isocode
cap drop capchange
bysort gid: egen minyear=min(year)
bysort gid: gen capchange = 1 if year~=minyear & logcapdist~=logcapdist[_n-1]
bysort gid: egen logcapdistmin = min(logcapdist)

bysort isocode year: egen avglogcapdist = mean(logcapdist)

cap drop temp*

sort gid year isocode

gen temp5=.

forval i = -5/0 {
	replace temp5 = 1 if gid==gid[_n+`i'] & capchange[_n+`i']==1  // after capchange
}
forval i = 1/5 {
	replace temp5 = 0 if gid==gid[_n+`i'] & capchange[_n+`i']==1 & temp5==.  // before capchange
}



*cap log close
*log using heoconbeongoan.smcl, replace

global Cont = "logbdist2 degtemper prec i.year" 


areg onsetGov logcapdist ${Cont} if avg_polity2 <=0 & temp5~=., a(gid) cluster(isocode) // *.
outreg2 using "$filename", append ctitle("Polity <=0, Gov, +/- 5 years") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)

areg onsetGov logcapdist ${Cont} temp5 c.avglogcapdist##temp5 if avg_polity2 <=0, a(gid) cluster(isocode) // *.
outreg2 using "$filename", append ctitle("Polity <=0, Gov, +/- 5 yrs, avglogcapdist*post_capchange") bracket title("Yearly probability of conflict onset, within-cells") nocons excel ///
	addtext(Cell FEs, Yes)


//--- Table 7: with fixed effects of cell * onset status

*cap log close
*log using heoconngoan3.smcl, replace
// good ones

set matsize 11000
use workingfile2_onset, clear
drop if iso=="" //this actually drops pre-independence observations, many of which contain conflicts (such as independence conflicts)

global controls_tvar "logbdist2 degtemper prec"

global filename "Table7_regime_cell_distance.xls"
cap erase "$filename"
local v = subinstr("$filename","xls","txt",.)
cap erase `v'

egen grIntra = group(onset gid)
egen grGov = group(onsetGov gid)
egen grTerr = group(onsetTerr gid)
egen grInter = group(onsetInter gid)
egen grIntense = group(onsetIntense gid)

egen griso = group(gid _isocode)
egen grisoIntra = group(onset gid _isocode)
egen grisoGov = group(onsetGov gid _isocode)
egen grisoTerr = group(onsetTerr gid _isocode)
egen grisoInter = group(onsetInter gid _isocode)
egen grisoIntense = group(onsetIntense gid _isocode)

*cap noi areg transi_5max i.onsetIntra##(c.logcapdist) i.year if avg_polity2<=0, a(grIntra) cluster(isocode)
*outreg2 using "$filename", replace ctitle("Onset Intra, Cell-FE, Polity <=0") drop(*.year*) bracket title("Regime change, within cells") nocons excel ///

cap noi areg transi_5max i.onsetGov##(c.logcapdist) i.year $controls_tvar if avg_polity2<=0, a(grGov) cluster(isocode) //
outreg2 using "$filename", replace ctitle("Onset Gov, Cell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

cap noi areg transi_5max i.onsetGov##(c.logcapdist) i.year $controls_tvar i._isocode##c.year if avg_polity2<=0, a(grGov) cluster(isocode)
outreg2 using "$filename", append ctitle("Trend control, Cell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

cap noi areg transi_5max i.onsetGov##(c.logcapdist) i.year $controls_tvar if avg_polity2<=0, a(grisoGov) cluster(isocode)
outreg2 using "$filename", append ctitle("IsoXCell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

cap noi areg transi_5MA i.onsetGov##(c.logcapdist) i.year $controls_tvar if avg_polity2<=0, a(grGov) cluster(isocode)
outreg2 using "$filename", append ctitle("transition 5MA, Cell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

cap noi areg transi_5max i.onsetIntense##(c.logcapdist) i.year $controls_tvar if avg_polity2<=0, a(grIntense) cluster(isocode)
outreg2 using "$filename", append ctitle("Cell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

cap noi areg transi_5max i.onsetTerr##(c.logcapdist) i.year $controls_tvar if avg_polity2<=0, a(grTerr) cluster(isocode)
outreg2 using "$filename", append ctitle("Cell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

*cap noi areg transi_5max i.onsetInter##(c.logcapdist) i.year $controls_tvar if avg_polity2<=0, a(grInter) cluster(isocode)
*outreg2 using "$filename", append ctitle("Cell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

*cap noi areg transi_5max i.onsetGov##(c.logcapdist) i.year $controls_tvar if avg_polity2>0, a(grGov) cluster(isocode)
*outreg2 using "$filename", append ctitle("Cell-FE, Polity <=0") drop(*year*) bracket title("Regime change, within cells") nocons excel ///

	
//----- Summary statistics

global gdpcontrols "avg_loggcppc avg_logpop"
global controls "avg_loggcppc avg_logpop imr logttime logcellarea"
global controls2 "${controls} mountain2000 ycoord avg_degtemper avg_prec" //not including forest2000


cd "$DataFolder"

use bygid_confdata, clear

preserve
keep if avg_polity2<=0
outreg2 using sum_workingfile2_autoc, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90)
restore

preserve
keep if avg_polity2>0
outreg2 using sum_workingfile2_democ, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90)
restore

use workingfile2_onset, clear
egen tag_gid = tag(gid)
keep if tag_gid==1

preserve
keep if avg_polity2<=0
qui areg avg_onsetIntra avg_logcapdist ${controls2}, a(isocode) 
gen sample = e(sample)
outreg2 using sum_workingfile2_onset_autoc if sample, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90)
restore

preserve
keep if avg_polity2>0
qui areg avg_onsetIntra avg_logcapdist ${controls2}, a(isocode) 
gen sample = e(sample)
outreg2 using sum_workingfile2_onset_democ if sample, sum(detail) replace eqkeep(N mean sd min max p10 p50 p90)
restore

*/

* //----- END
