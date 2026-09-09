clear
set more off
set logtype text
capture log close
log using "MMS_MA_analysis.txt", replace

*** EDIT by Donna
version 13
cd "."

********************************************************************************************
* Table A-1: Descriptive statistics
********************************************************************************************
use MA_state_data.dta, clear
gen treat=1 if state=="MA"
replace treat=2 if treat==.
collapse allapps DIonly SSItotal ue unin [aw=wapop], by(q_fld treat)
reshape wide allapps DIonly SSItotal ue unin, i(q_fld) j(treat)
gen fy=2003 if q_fld>=171 & q_fld<=174
replace fy=2004 if q_fld>=175 & q_fld<=178
replace fy=2005 if q_fld>=179 & q_fld<=182
replace fy=2006 if q_fld>=183 & q_fld<=186
replace fy=2007 if q_fld>=187 & q_fld<=190
replace fy=2008 if q_fld>=191 & q_fld<=194
replace fy=2009 if q_fld>=195 & q_fld<=198
table fy, c(mean allapps1 mean allapps2)
table fy, c(mean DIonly1 mean DIonly2)
table fy, c(mean SSItotal1 mean SSItotal2)
table fy, c(mean ue1 mean ue2)
sum unin* if q_fld==180
sum unin* if q_fld==196

********************************************************************************************
* Table 1, Panel A: State level regressions (applications)
********************************************************************************************
use MA_state_data.dta, clear
qui tab state, gen(stnum)
gen qnum=qofd(dofq(q_fld))
gen MA=state=="MA"
gen post1=(qnum>=187 & qnum<=190)
gen post2=(qnum>=191 & qnum<=194)
gen post3=(qnum>=195 & qnum<=198)
gen MAXpost1=MA*post1
gen MAXpost2=MA*post2
gen MAXpost3=MA*post3

*** EDIT by Donna
eststo m_allapps: reg allapps MAXpost* post* ue stnum1 stnum3-stnum9 i.qnum [aw=wapop], cluster(state)
* outreg2 MAXpost* using stateresults.txt, replace
eststo m_DIonly: reg DIonly MAXpost* post* ue stnum1 stnum3-stnum9 i.qnum [aw=wapop], cluster(state)
* outreg2 MAXpost* using stateresults.txt, append
eststo m_SSItotal: reg SSItotal MAXpost* post* ue stnum1 stnum3-stnum9 i.qnum [aw=wapop], cluster(state)
* outreg2 MAXpost* using stateresults.txt, append
eststo m_SSDItotal: reg SSDItotal MAXpost* post* ue stnum1 stnum3-stnum9 i.qnum [aw=wapop], cluster(state)
* outreg2 MAXpost* using stateresults.txt, append
estout m_allapps m_DIonly m_SSItotal m_SSDItotal using "../../results/table0.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

********************************************************************************************
* Table 1, Panels B-D (applications) and Table 2 (time to filing): County level regressions
********************************************************************************************
use MA_county_data.dta, clear
gen anymissing=(DIonly==0 | SSIonly==0 | concurrent==0)
tab county if anymissing==1
*** Edited by Ryan
egen anymissing_by_county = sum(anymissing), by(county)
drop if anymissing_by_county > 0
/* #delimit;
drop if county==23015
|	county==	23021
|	county==	23023
|	county==	25007
|	county==	25019
|	county==	33003
|	county==	33007
|	county==	33019
|	county==	34019
|	county==	36041
|	county==	36049
|	county==	36095
|	county==	36097
|	county==	36099
|	county==	36123
|	county==	42023
|	county==	42053
|	county==	42057
|	county==	42067
|	county==	42093
|	county==	42099
|	county==	42105
|	county==	42113
|	county==	42119
|	county==	50001
|	county==	50005
|	county==	50009
|	county==	50013
|	county==	50015
|	county==	50017
;
#delimit cr */
***

sort nohi05
sum nohi05 if state=="MA" & q_fld==187 [aw=wapop],d
gen lowHI=(nohi05>=.12)
sum lowHI if state=="MA" & q_fld==187 [aw=wapop]
gen MA=state=="MA"
qui tab q_fld, gen(qnum)
gen post1=(q_fld>=187 & q_fld<=190)
gen post2=(q_fld>=191 & q_fld<=194)
gen MAXpost1=MA*post1
gen MAXpost2=MA*post2

* Outcome: application rates
eststo m1_allapps: reg allapps MAX* post* ue qnum* i.county [aw=wapop], cluster(state)
* outreg2 MAX* using countyresults.txt, replace

foreach var of varlist DIonly SSItotal SSDItotal {
	eststo m1_`var': reg `var' MAX* post* ue qnum* i.county [aw=wapop], cluster(state)
	* outreg2 MAX* using countyresults.txt, append
}
estout m1_allapps m1_DIonly m1_SSItotal m1_SSDItotal using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

foreach var of varlist allapps DIonly SSItotal SSDItotal {
	eststo m2_`var': reg `var' MAX* post* ue qnum* i.county [aw=wapop] if lowHI==1, cluster(state)
	* outreg2 MAX* using countyresults.txt, append
}
estout m2_allapps m2_DIonly m2_SSItotal m2_SSDItotal using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

foreach var of varlist allapps DIonly SSItotal SSDItotal {
	eststo m3_`var': reg `var' MAX* post* ue qnum* i.county [aw=wapop] if lowHI==0, cluster(state)
	outreg2 MAX* using countyresults.txt, append	
}
estout m3_allapps m3_DIonly m3_SSItotal m3_SSDItotal using "../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

* Outcome: mean time to filing
reg DIonly_mntime MAX* post* ue qnum* i.county [aw=wapop] if lowHI==1, cluster(state)
outreg2 MAX* using countyresults2.txt, replace
reg SSItotal_mntime MAX* post* ue qnum* i.county [aw=wapop] if lowHI==1, cluster(state)
outreg2 MAX* using countyresults2.txt, append
foreach var of varlist DIonly_mntime SSItotal_mntime {
	reg `var' MAX* post* ue qnum* i.county [aw=wapop] if lowHI==0, cluster(state)
	outreg2 MAX* using countyresults2.txt, append	
}
