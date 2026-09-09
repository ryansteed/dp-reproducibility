/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates all figures and tables in the paper that are derived
from the panel ITT estimator. These figures and tables include the following:

Tables C1 and C5, Figures B13, B14, and B15 in the Online Appendix

DATA INPUTS: (1) itt_panel
*********************************/
clear
set more off

*Set globals

*Path
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"

*Call cross-sectional ITT dataset
use "${path}\Data\Final\itt_panel", clear

*Use only two years before and five years after the referendum
tab dyear

preserve
keep if dyear>=-2 & dyear<=5
 
 *Drop other leads and lags
  foreach v in op_perc op_perc2 op_perc3 op_win bond_perc bond_perc2 bond_perc3 bond_win {
    forvalues y=6/21 {
      drop `v'_`y'
      }
    forvalues y=3/22 {
      drop `v'_m`y'
      }
    }

*****************************************
******SECTION I: TABLES
*****************************************

*****************************************
******TABLE C1 (COEFS ON OP. WIN VARIABLES)
*****************************************
areg rev_lim_mem yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code) 

areg tot_exp_mem yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code)

areg advprof_math10 yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code)

areg advprof_math8 yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code) 

areg advprof_math4 yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code)  

areg dropout_rate yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code) 

areg log_instate_enr yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
grade9lagged, absorb(refid) cluster(district_code)


*****************************************
******TABLE C5 (COEFS. ON BOND WIN VARIABLES)
*****************************************
areg tot_capout_mem yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code) 

areg LT_debt_out_mem yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code)

areg advprof_math10 yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code)

areg advprof_math8 yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code) 

areg advprof_math4 yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code)  

areg dropout_rate yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
, absorb(refid) cluster(district_code) 

areg log_instate_enr yrdums* dydums* op_win_? bond_win_? ///
op_perc_?  op_perc2_? op_perc3_? bond_perc_? bond_perc2_? bond_perc3_? ///
grade9lagged, absorb(refid) cluster(district_code)
restore


*****************************************
******FIGURES B13, B14, AND B15
*****************************************
*First, generate "diagonal" figures. These figures look at the relationship 
*between narroly passing an operational (bond) referendum in time t and the 
*number of subsequent operational (bond) measures. 

*Start with Measures Won

*Generate operational indicator
gen operational = (bond==0)

*Keep only relevant variables
keep district_name district_code yearref win operational bond refid perc

*Keep only one obs per refid
duplicates drop refid, force 

*Sort data
sort district_code yearref

*All referenda from 1996-2014
tab yearref

*Looking first at operational referenda
preserve
keep if bond==0
drop operational bond

*Generate loop to create variables "# of subsequent op. referenda wins" by 
*number of years: subs_op2 subs_op4 subs_op10
gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(win) if cum_dist<=2 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if win==1 & refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_op2

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(win) if cum_dist<=4 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if win==1 & refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_op4

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(win) if cum_dist<=10 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if win==1 & refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_op10

*Generate diagonal plots: operational on operational
replace perc = perc-50
*2 years
rdplot subs_op2 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\op_pass2.pdf", replace 


*4 years
rdplot subs_op4 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\op_pass4.pdf", replace


*10 years
rdplot subs_op10 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(1 2)) ylabel(0 1 2) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\op_pass10.pdf", replace
restore

*Looking now at bond referenda
preserve
keep if bond==1
drop operational bond

*Generate loop to create variables "# of subsequent bond referenda wins" by 
*number of years: subs_bond2 subs_bond4 subs_bond10
gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(win) if cum_dist<=2 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if win==1 & refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_bond2

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(win) if cum_dist<=4 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if win==1 & refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_bond4

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(win) if cum_dist<=10 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if win==1 & refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_bond10

*Generate diagonal plots: operational on operational
replace perc = perc-50
*2 years
rdplot subs_bond2 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bond_pass2.pdf", replace

*4 years
rdplot subs_bond4 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bond_pass4.pdf", replace

*10 years
rdplot subs_bond10 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(0 2)) ylabel(0 1 2) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bond_pass10.pdf", replace
restore

*Now, looking at measures proposed
*Operational Referenda:
preserve
keep if bond==0
drop bond 
drop win

*Generate loop to create variables "# of subsequent proposed op. referenda" by 
*number of years: subs_op2 subs_op4 subs_op10
gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(operational) if cum_dist<=2 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_op2

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(operational) if cum_dist<=4 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_op4

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(operational) if cum_dist<=10 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_op10

*Generate diagonal plots: operational on operational
replace perc = perc-50
*2 years
rdplot subs_op2 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\op_prop2.pdf", replace

*4 years
rdplot subs_op4 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(.5 1.5)) ylabel(0 .5 1 1.5) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\op_prop4.pdf", replace

*10 years
rdplot subs_op10 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(1 3)) ylabel(0 1 2 3) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\op_prop10.pdf", replace
restore


*Bond Referenda:
preserve
keep if bond==1
drop operational
drop win

*Generate loop to create variables "# of subsequent proposed bonds" by 
*number of years: subs_bond2 subs_bond4 subs_bond10
gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(bond) if cum_dist<=2 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_bond2

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(bond) if cum_dist<=4 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_bond4

gen x=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
bysort district_code: egen subs = sum(bond) if cum_dist<=10 & refid>=`i'
replace x = subs if refid==`i'
replace x = x-1 if refid==`i'
drop cum_dist subs distance	
}
bysort district_code: replace x=. if _n==_N
rename x subs_bond10

*Generate diagonal plots: operational on operational
replace perc = perc-50
*2 years
rdplot subs_bond2 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bond_prop2.pdf", replace

*4 years
rdplot subs_bond4 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(.5 1.5)) ylabel(0 .5 1 1.5) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bond_prop4.pdf", replace

*10 years
rdplot subs_bond10 perc if perc>=-10 & perc<=10, p(2) nbins(5 5) ///
graph_options(yscale(r(1 3)) ylabel(0 1 2 3) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bond_prop10.pdf", replace
restore


*Now, generate off-diagonal figures
preserve
duplicates drop district_code yearref, force

*First looking at subsequent measures passed
*Generate win variables
gen op_win = (operational==1&win==1)
gen bond_win = (bond==1&win==1)

*2 years
*Run Loop
gen x_op=.
gen x_bond=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
*operational
bysort district_code: egen subs_op = sum(op_win) if cum_dist<=2& refid>=`i'
replace x_op = subs_op if refid==`i'
replace x_op = x_op-1 if op_win==1&refid==`i'
*bond
bysort district_code: egen subs_bond = sum(bond_win) if cum_dist<=2& refid>=`i'
replace x_bond = subs_bond if refid==`i'
replace x_bond = x_bond-1 if bond_win==1&refid==`i'
drop cum_dist subs_op subs_bond distance
}
bysort district_code: replace x_op=. if _n==_N
bysort district_code: replace x_bond=. if _n==_N
bysort district_code: replace x_op=0 if _n!=_N & x_op==.
bysort district_code: replace x_bond=0 if _n!=_N & x_bond==.
rename x_op subs_op2 
rename x_bond subs_bond2

*4 years
*Run Loop
gen x_op=.
gen x_bond=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
*operational
bysort district_code: egen subs_op = sum(op_win) if cum_dist<=4& refid>=`i'
replace x_op = subs_op if refid==`i'
replace x_op = x_op-1 if op_win==1&refid==`i'
*bond
bysort district_code: egen subs_bond = sum(bond_win) if cum_dist<=4& refid>=`i'
replace x_bond = subs_bond if refid==`i'
replace x_bond = x_bond-1 if bond_win==1&refid==`i'
drop cum_dist subs_op subs_bond distance
}
bysort district_code: replace x_op=. if _n==_N
bysort district_code: replace x_bond=. if _n==_N
bysort district_code: replace x_op=0 if _n!=_N & x_op==.
bysort district_code: replace x_bond=0 if _n!=_N & x_bond==.
rename x_op subs_op4 
rename x_bond subs_bond4

*10 years
*Run Loop
gen x_op=.
gen x_bond=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
*operational
bysort district_code: egen subs_op = sum(op_win) if cum_dist<=10& refid>=`i'
replace x_op = subs_op if refid==`i'
replace x_op = x_op-1 if op_win==1&refid==`i'
*bond
bysort district_code: egen subs_bond = sum(bond_win) if cum_dist<=10& refid>=`i'
replace x_bond = subs_bond if refid==`i'
replace x_bond = x_bond-1 if bond_win==1&refid==`i'
drop cum_dist subs_op subs_bond distance
}
bysort district_code: replace x_op=. if _n==_N
bysort district_code: replace x_bond=. if _n==_N
bysort district_code: replace x_op=0 if _n!=_N & x_op==.
bysort district_code: replace x_bond=0 if _n!=_N & x_bond==.
rename x_op subs_op10
rename x_bond subs_bond10

*RD Plots
replace perc = perc-50

*Effect of passing an operational referendum on subsequent bond wins
*2 years
rdplot subs_bond2 perc if operational==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\opbond_pass2.pdf", replace

*4 years
rdplot subs_bond4 perc if operational==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\opbond_pass4.pdf", replace

*10 years
rdplot subs_bond10 perc if operational==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 1 2) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\opbond_pass10.pdf", replace


*Effect of passing a bond referendum on subsequent operational wins
*2 years
rdplot subs_op2 perc if bond==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bondop_pass2.pdf", replace

*4 years
rdplot subs_op4 perc if bond==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bondop_pass4.pdf", replace

*10 years
rdplot subs_op10 perc if bond==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 1 2) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bondop_pass10.pdf", replace
restore


*Now looking at measures proposed
preserve
duplicates drop district_code yearref, force


*First looking at subsequent measures passed
*Generate win variables
gen op_win = (operational==1&win==1)
gen bond_win = (bond==1&win==1)

*2 years
*Run Loop
gen x_op=.
gen x_bond=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
*operational
bysort district_code: egen subs_op = sum(operational) if cum_dist<=2& refid>=`i'
replace x_op = subs_op if refid==`i'
replace x_op = x_op-1 if operational==1&refid==`i'
*bond
bysort district_code: egen subs_bond = sum(bond) if cum_dist<=2& refid>=`i'
replace x_bond = subs_bond if refid==`i'
replace x_bond = x_bond-1 if bond==1&refid==`i'
drop cum_dist subs_op subs_bond distance
}
bysort district_code: replace x_op=. if _n==_N
bysort district_code: replace x_bond=. if _n==_N
bysort district_code: replace x_op=0 if _n!=_N & x_op==.
bysort district_code: replace x_bond=0 if _n!=_N & x_bond==.
rename x_op subs_op2 
rename x_bond subs_bond2

*4 years
*Run Loop
gen x_op=.
gen x_bond=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
*operational
bysort district_code: egen subs_op = sum(operational) if cum_dist<=4& refid>=`i'
replace x_op = subs_op if refid==`i'
replace x_op = x_op-1 if operational==1&refid==`i'
*bond
bysort district_code: egen subs_bond = sum(bond) if cum_dist<=4& refid>=`i'
replace x_bond = subs_bond if refid==`i'
replace x_bond = x_bond-1 if bond==1&refid==`i'
drop cum_dist subs_op subs_bond distance
}
bysort district_code: replace x_op=. if _n==_N
bysort district_code: replace x_bond=. if _n==_N
bysort district_code: replace x_op=0 if _n!=_N & x_op==.
bysort district_code: replace x_bond=0 if _n!=_N & x_bond==.
rename x_op subs_op4 
rename x_bond subs_bond4


*10 years
*Run Loop
gen x_op=.
gen x_bond=.
levelsof refid, local (levels)
foreach i of local levels{
bysort district_code: gen distance = yearref - yearref[_n-1] if refid>`i'
bysort district_code (yearref): gen cum_dist = sum(distance) if refid>=`i'
*operational
bysort district_code: egen subs_op = sum(operational) if cum_dist<=10& refid>=`i'
replace x_op = subs_op if refid==`i'
replace x_op = x_op-1 if operational==1&refid==`i'
*bond
bysort district_code: egen subs_bond = sum(bond) if cum_dist<=10& refid>=`i'
replace x_bond = subs_bond if refid==`i'
replace x_bond = x_bond-1 if bond==1&refid==`i'
drop cum_dist subs_op subs_bond distance
}
bysort district_code: replace x_op=. if _n==_N
bysort district_code: replace x_bond=. if _n==_N
bysort district_code: replace x_op=0 if _n!=_N & x_op==.
bysort district_code: replace x_bond=0 if _n!=_N & x_bond==.
rename x_op subs_op10
rename x_bond subs_bond10


*RD Plots
replace perc = perc-50

*Effect of passing an operational referendum on subsequent bond proposals
*2 years
rdplot subs_bond2 perc if operational==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\opbond_prop2.pdf", replace

*4 years
rdplot subs_bond4 perc if operational==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 .5 1 1.5) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\opbond_prop4.pdf", replace

*10 years
rdplot subs_bond10 perc if operational==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 1 2 3) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\opbond_prop10.pdf", replace


*Effect of passing a bond referendum on subsequent operational wins
*2 years
rdplot subs_op2 perc if bond==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 0.5 1) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bondop_prop2.pdf", replace

*4 years
rdplot subs_op4 perc if bond==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 1)) ylabel(0 .5 1 1.5) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bondop_prop4.pdf", replace

*10 years
rdplot subs_op10 perc if bond==1&(perc>=-10 & perc<=10), p(2) nbins(5 5) ///
graph_options(yscale(r(0 2)) ylabel(0 1 2 3) ///
xtitle(Vote Share Relative to Threshold (2 pp bins)) ///
ytitle(Avg. Number of Measures) bgcolor(white) ///
graphregion(lcolor(white) ilcolor(white) ///
fcolor(white) ifcolor(white)))
graph export "${path}\Output\bondop_prop10.pdf", replace

restore

