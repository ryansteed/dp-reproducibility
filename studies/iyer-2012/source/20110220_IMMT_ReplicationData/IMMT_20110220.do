capture log close
set more off
clear
clear all
set mem 700m

*** EDITED BY Donna Zhu
version 11
***

/***Stata program to replicate tables in Iyer et al "The Power of Political Voice: Women's Political Representation and Crime in India"
AEJApp2011-0220; Data and programs are in Version Stata SE 11***/

/***setting graph export options***/
graph set ps orientation landscape 
graph set ps logo off
graph set ps pagesize letter 
graph set ps mag 150

* cd c:\crime\replication

gl tt1 "cells( b(star fmt(%-9.3f)) se(fmt(%-9.3f) par( [ ] )) blank) stats (r2 N, fmt(%9.2f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01) stardetach "
gl tt2 "cells( b(star fmt(%-9.4f)) se(fmt(%-9.4f) par( [ ] )) blank) stats (r2 N, fmt(%9.4f %9.0g)) style(fixed) starlevel ("*" 0.10 "**" 0.05 "***" 0.01) stardetach "
gl clstr "cluster(stateid)"

************************************************
* Table 1 - Dates of Panchayati Raj Implementation Across States of India
************************************************
capture log close
log using table1.txt, replace text
use tables1to5.dta, clear
tab year if yearofres==1 & majstate==1
log close

************************************************
* Table 2 - Summary statistics
************************************************
log using table2.txt, replace text
use tables1to5.dta, clear
summ pcr_womtot prape2 pwomgirl pkidmen pcr_prop pcr_order pcr_econ pmurder pmurder_love psuic_f psuic_m if year>=1985 & majstate==1
summ pscpoa pscpcr  pstpoa pstpcr if year>=1992 & elec_scres>=1995 & majstate==1
summ parrest_womcrime parrest_rape parrest_womgirl parrest_nonwomen parrest_kidmen if year>=1988 & majstate==1
summ charge_womcrime chargesheet_rate if year>=1991 & majstate==1
summ pfemale prural plit pfarm womancm ppol_strength pcgsdp if year>=1985 & majstate==1
log close

************************************************
* Table 3 - Political Representation and Crime against Women
************************************************

use tables1to5.dta, clear
*** EDIT by Donna - Change Sequence
foreach X in lprape2 lpwomgirl lpcr_womtot{

* no controls
xi: areg `X' postwres i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m1

* demographic and GDP controls
xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp  i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m2

* Police controls
xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m3

* female Literacy
xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt pwlit i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m4

* State specific Time trends
xi: areg `X' postwres i.stateid*year i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m5

* State specific Time trends + demographics
xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strength i.stateid*year i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m6

estout m1 m2 m3 m4 m5 m6 ///
	 using Table3.txt, append  $tt1  ///
	 keep(postwres) ///
	 title(Table 3 - Dependent Variable: `X')

*** EDIT by Donna
estout using "../../results/table3_`X'.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

}

************************************************
* Table 4 - Political Representation and Crime Not Targeted against Women
************************************************

use tables1to5.dta, clear
*** EDIT by Donna: Change sequence of variables
foreach X in  lpcr_prop lpcr_order lpcr_econ lpkidmen {
* no controls
xi: areg `X' postwres i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m1

* demographic and GDP controls
xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp  i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m2

* Police controls
xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m3

* State specific time trends + controls
eststo core6: xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.stateid*year i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m4

estout m1 m2 m3 m4 ///
	 using Table4.txt, append  $tt1  ///
	 keep(postwres ) ///
	 title(Table 4 - Dependent Variable: `X')

*** EDIT by Donna
estout core6 using "../../results/table4_`X'.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

}

***************************************************
*Table 5: Women's Representation and Crimes where Reporting Bias is Likely to be Least
***************************************************
use tables1to5.dta, clear

**column 1, panels A and B
eststo core3: xi: areg lpmurder postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m3
xi: areg lpmurder postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.stateid*year i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m4

estout m3 m4 ///
	 using Table5.txt, append  $tt1  ///
	 keep(postwres ) ///
	 title(Table 5, column 1, panels A and B, Log murders per 1000 pop)


***columns 2 and 3, panel A only
xi: areg lpmurder_f postwres i.year if elec_womres>1999 & majstate==1, absorb(stateid) robust
estimates store m1

xi: areg lpmurder_m postwres i.year if elec_womres>1999 & majstate==1, absorb(stateid) robust
estimates store m2 

estout m1 m2 ///
	 using Table5.txt, append  $tt1  ///
	 keep(postwres ) ///
	 title(Table 5, columns 2 and 3)
	 
***columns 4 and 5, panels A and B

foreach X in lpmurder_love sh_murder_love {

xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1988 & majstate==1, absorb(stateid) $clstr
estimates store m3

xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.stateid*year i.year if year>=1988 & majstate==1, absorb(stateid) $clstr
estimates store m4

estout m3 m4 ///
	 using Table5.txt, append  $tt1  ///
	 keep(postwres ) ///
	 title(Table 5, columns 4 and 5, panels A and B, dep var: `X')
}

***columns 6 and 7, panels A and B
foreach X in lpsuic_f lpsuic_m {

eststo: xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m5

estout core3 m5 using "../../results/table5_`X'.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.stateid*year i.year if year>=1985 & majstate==1, absorb(stateid) $clstr
estimates store m6

estout m5 m6 ///
	 using Table5.txt, append  $tt1  ///
	 keep(postwres ) ///
	 title(Table 5, columns 6 and 7, panels A and B, dep var: `X')
}



************************************************
* Table 6 -  Women's Political Representation and Crimes against Women: Evidence from a Victimization Survey
************************************************
capture log close
log using table6.txt, replace text

use table6.dta, clear

foreach X in  anycrime  s_molest s_evetease s_attack   {


* women
eststo: xi: areg `X' res_woman i.ident if female==1, absorb(district) cluster(gram_panchayat)
estimates store f_`X'

estout f_anycrime using "../../results/table6_`X'.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

xi: areg `X' res_woman i.ident if female==1 & ident=="base", absorb(district) cluster(gram_panchayat)
estimates store fb_`X'

xi: areg `X' res_woman i.ident if female==1 & ident=="end", absorb(district) cluster(gram_panchayat)
estimates store fe_`X'

}
estout  f_anycrime f_s_molest f_s_evetease f_s_attack  ///
	 using Table6.txt, append  $tt2  ///
	 keep(res_woman) ///
	 title(Victim of Crime - Rural sample)

estout fb_anycrime fb_s_molest fb_s_evetease fb_s_attack ///
	 using Table6.txt, append  $tt2  ///
	 keep(res_woman) ///
	 title(Victim of Crime - Rural Baseline )

estout fe_anycrime fe_s_molest fe_s_evetease fe_s_attack    ///
	 using Table6.txt, append  $tt2  ///
	 keep(res_woman) ///
	 title(Victim of Crime - Rural Endline)


cap log close

************************************************
* Table 7 -  Women's Political Representation adn Willingness to Report Crimes
************************************************
use table7.dta, clear

global fir_list  = "fir_evetease fir_bicycle fir_cell fir_beaten fir_motor"
global nfir_list  = "nfir_evetease nfir_bicycle nfir_cell nfir_beaten nfir_motor"

foreach var of varlist $fir_list {
	su `var' if res_woman==1
  	gen  m`var'=r(mean)
  	gen  sd`var'=r(sd)
  	gen  n`var'=( `var'-m`var' )/sd`var'
}
egen ave_fir = rowmean($nfir_list)


foreach X in ave_fir fir_evetease  fir_cell fir_beaten    {

	* men
	xi: areg `X' res_woman i.ident  if female==0, absorb(district) cluster(gram_panchayat)
	estimates store m_`X'

	xi: areg `X' res_woman i.ident  if female==0 & ident=="base", absorb(district) cluster(gram_panchayat)
	estimates store mb_`X'

	xi: areg `X' res_woman i.ident  if female==0 & ident=="end", absorb(district) cluster(gram_panchayat)
	estimates store me_`X'

	* women
	eststo: xi: areg `X' res_woman i.ident  if female==1, absorb(district) cluster(gram_panchayat)
	estimates store f_`X'

	xi: areg `X' res_woman i.ident  if female==1 & ident=="base", absorb(district) cluster(gram_panchayat)
	estimates store fb_`X'

	xi: areg `X' res_woman i.ident  if female==1 & ident=="end", absorb(district) cluster(gram_panchayat)
	estimates store fe_`X'

}
estout f_ave_fir using "../../results/table7.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

estout f_ave_fir m_ave_fir f_fir_evetease m_fir_evetease  f_fir_cell m_fir_cell f_fir_beaten  m_fir_beaten      ///
	 using Table7.txt, append  $tt1  ///
	 keep(res_woman) ///
	 title(Willingness to report different kinds of crime - Rural sample)

estout fb_ave_fir mb_ave_fir fb_fir_evetease mb_fir_evetease  fb_fir_cell mb_fir_cell  fb_fir_beaten mb_fir_beaten      ///
	 using Table7.txt, append  $tt1  ///
	 keep(res_woman) ///
	 title(Willingness to report different kinds of crime - Rural Baseline )

estout fe_ave_fir me_ave_fir fe_fir_evetease me_fir_evetease fe_fir_cell me_fir_cell  fe_fir_beaten me_fir_beaten      ///
	 using Table7.txt, append  $tt1  ///
	 keep(res_woman) ///
	 title(Willingness to report different kinds of crime - Rural Endline)
*** EDIT by Donna Zhu
cap log close

************************************************
* Table 8a -  Responses from State of the Nation survey
* Note: We did not obtain individual level response data from CSDS, only aggregates.
************************************************
capture log close
log using table8a.txt, replace text

use table8a1.dta, clear
gen pyes=frequency/ntot
list

use table8a2.dta, clear
gen pyes=frequency/ntot
list
log close

************************************************
* Table 8b -  Millennial survey data not allowed to be made public
************************************************


************************************************
* Table 9 -  Police activity
************************************************
use tables1to5.dta, clear

***Table 9, columns 1 to 5
foreach X in  lparrest_womcrime lparrest_rape lparrest_womgirl lparrest_nonwomen lparrest_kidmen  {

xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1988 & majstate==1, absorb(stateid) $clstr
estimates store m1

xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.stateid*year i.year if year>=1988 & majstate==1, absorb(stateid) $clstr
estimates store m2

estout m1 m2 ///
	 using Table9.txt, append  $tt1  ///
	 keep(postwres ) ///
	 title(Table 9- Arrest Rates, Panel A and B - Dependent Variable: `X')
}

****Table 9, columns 6 & 7
foreach X in charge_womcrime chargesheet_rate {	

xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1991 & majstate==1, absorb(stateid) $clstr
estimates store m1

xi: areg `X' postwres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.stateid*year i.year if year>=1991 & majstate==1, absorb(stateid) $clstr
estimates store m2

estout m1 m2  ///
	 using Table9.txt, append  $tt1  ///
	 keep(postwres ) ///
	 title(Table 9, Chargesheeting,  panels A and B, Dependent Variable: `X')
}


************************************************
* Table 10A - District level analysis
************************************************
use table10a.dta, clear

xi: areg lpcr_wom wdistres postwres pfemale purban plitf i.year, absorb(distid) cluster(distid)
estimates store m1

xi: areg lpcr_wom wdistres postwres pfemale purban plitf i.stateid*year i.year, absorb(distid) cluster(distid)
estimates store m1a

estout m1 m1a ///
	 using table10a.txt, append  $tt1  ///
	 keep(wdistres postwres ) ///
	 title(Table 10, Panel A: district results)


************************************************
* Table 10B - Women Legislators and Crimes Against Women
************************************************
use tables1to5.dta, clear

foreach X in pcr_womtot prape2 pwomgirl {

/****OLS results****/
xi: areg l`X' wwinner pfemale prural pwlit pfarm womancm pcgsdp ppol_strength i.year if year>=1985 & majstate==1, $clstr absorb(stateid)
estimates store m1

xi: areg l`X' wwinner pfemale prural pwlit pfarm womancm pcgsdp ppol_strength i.stateid*year i.year if year>=1985 & majstate==1, $clstr absorb(stateid)
estimates store m2

/***IV results***/
xi: ivreg l`X' (wwinner=wwinclose5)  pfemale prural pwlit pfarm womancm pcgsdp ppol_strength i.year i.stateid  if year>=1985 & majstate==1, $clstr 
estimates store m3

xi: ivreg l`X' (wwinner=wwinclose5)  pfemale prural pwlit pfarm womancm pcgsdp ppol_strength i.stateid*year i.year if year>=1985 & majstate==1, $clstr 
estimates store m4


estout m1 m2 m3 m4 ///
	 using Table10B.txt, append  $tt1  ///
	 keep(wwinner ) ///
	 title(Table 10B: dependent variable: l`X')

}



************************************************
* Table A1 -  Political Representation for SC/ST and crimes against them
************************************************
*** EDIT by Donna: Comment out command used to generate tables without primary result.
/*
foreach X in sctot scmurder scrape scpoa scpcr sttot stmurder strape stpoa stpcr {	
xi: areg lp`X' postscres i.year if year>=1985 & majstate==1 & elec_scres>=1995, absorb(stateid) $clstr
estimates store lm1

* demographic and GDP controls
xi: areg lp`X' postscres pfemale prural plit pfarm womancm pcgsdp  i.year if year>=1985 & majstate==1 & elec_scres>=1995, absorb(stateid) $clstr
estimates store lm2

* Police controls
xi: areg lp`X' postscres pfemale prural plit pfarm womancm pcgsdp ppol_strengt i.year if year>=1985 & majstate==1 & elec_scres>=1995, absorb(stateid) $clstr
estimates store lm3

estout lm1 lm2 lm3 ///
	 using TableA1.txt, append  $tt1  ///
	 keep(postscres ) ///
	 title(Table A1 - Dependent Variable: lp`X')
}

*/

