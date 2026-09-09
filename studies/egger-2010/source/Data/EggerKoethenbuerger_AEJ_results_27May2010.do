clear
set more off
capture log close
set mem 500m
set matsize 3000

version 13

log using EggerKoethenbuergerAEJ_results, replace 
use EggerKoethenbuerger_AEJ_Data.dta.dta, clear

****** Results Table 2 ******
gen exppc=exptot/pop
table rcsize, c(count exptot m exptot m exppc)

collapse exptot exppers expsach expsachinv debt tratea trateb tratep wpop rcsize, by(id phase)
foreach X in exptot exppers expsach expsachinv debt tratea trateb tratep wpop rcsize {
g l`X'=ln(`X')
}
foreach pp in 1 2 3 4 5 {
g lwpop_`pp'=lwpop^`pp'
}
foreach t in 1000 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
preserve
gen T`t'=(wpop>=0.65*`t'&wpop<=1.35*(`t'+1))
gen window05=(lwpop>=ln(`t')-0.05&lwpop<=ln(`t'+1)+0.05)
gen window10=(lwpop>=ln(`t')-0.1&lwpop<=ln(`t'+1)+0.1)
gen window15=(lwpop>=ln(`t')-0.15&lwpop<=ln(`t'+1)+0.15)
gen window20=(lwpop>=ln(`t')-0.2&lwpop<=ln(`t'+1)+0.2)
gen window25=(lwpop>=ln(`t')-0.25&lwpop<=ln(`t'+1)+0.25)
gen window30=(lwpop>=ln(`t')-0.3&lwpop<=ln(`t'+1)+0.3)
gen window35=(lwpop>=ln(`t')-0.35&lwpop<=ln(`t'+1)+0.35)
keep if T`t'==1
gen right=lwpop>ln(`t')
save phase_T`t', replace
restore
}

use phase_T1000, clear
gen thresh=1000
foreach t in 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
append using phase_T`t'
replace thresh=`t' if thresh==.
}
save phase_TALL.dta, replace

*** WPOP CENTRED AROUND THRESHOLD ***
use EggerKoethenbuerger_AEJ_Data.dta.dta, clear
collapse exptot exppers expsach expsachinv debt tratea trateb tratep wpop rcsize, by(id phase)
foreach X in exptot exppers expsach expsachinv debt tratea trateb tratep wpop rcsize {
g l`X'=ln(`X')
}
foreach t in 1000 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
preserve
gen T`t'=(lwpop>=ln(`t')-0.35&lwpop<=ln(`t')+0.35)
replace lwpop=lwpop-ln(`t')
gen window05=(lwpop>=-0.05&lwpop<=0.05)
gen window10=(lwpop>=-0.1&lwpop<=0.1)
gen window15=(lwpop>=-0.15&lwpop<=0.15)
gen window20=(lwpop>=-0.2&lwpop<=0.2)
gen window25=(lwpop>=-0.25&lwpop<=0.25)
gen window30=(lwpop>=-0.3&lwpop<=0.3)
gen window35=(lwpop>=-0.35&lwpop<=0.35)
keep if T`t'==1
gen right=lwpop>0
foreach pp in 1 2 3 4 5 {
g lwpop_`pp'=lwpop^`pp'
}
save phase_T`t'_wpopdem, replace
restore
}

use phase_T1000_wpopdem, clear
gen thresh=1000
foreach t in 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
append using phase_T`t'_wpopdem
replace thresh=`t' if thresh==.
}
save phase_TALL_wpopdem.dta, replace


*** WPOP CENTRED AROUND THRESHOLD ***
foreach t in 1000 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
foreach w in 15 20 25 30 {
use EggerKoethenbuerger_AEJ_Data.dta.dta, clear
keep exptot exppers expsach expsachinv debt tratea trateb tratep wpop rcsize id phase
foreach X in exptot exppers expsach expsachinv debt tratea trateb tratep wpop rcsize {
g l`X'=ln(`X')
}
replace lwpop=lwpop-ln(`t'+1)
sum lwpop
capture drop window*
keep if (lwpop>=-0.`w'&lwpop<=0.`w')
sum lwpop
save window`w'_thresh`t'_TALL_wpopdem.dta, replace
}
}


foreach w in 15 20 25 30 {
foreach t in 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
use  window`w'_thresh1000_TALL_wpopdem.dta, replace
append using  window`w'_thresh`t'_TALL_wpopdem.dta
}
gen right=lwpop>0
sum lwpop
gen clwpop=(int(150*lwpop))/150
egen class=group(clwpop)
collapse lexptot lexppers lexpsach lexpsachinv ldebt tratea trateb tratep lwpop clwpop, by(class right)
save  window`w'_TALL_wpopdem.dta, replace
}

****** Results Table 3 ******

foreach w in 15 20 25 30  {
use  window`w'_thresh1000_TALL_wpopdem.dta, replace
gen thresh=1000
foreach t in 2000 3000 5000 10000 20000 30000 50000 100000 200000 {

append using  window`w'_thresh`t'_TALL_wpopdem.dta
replace thresh=`t' if thresh==.
}
gen right=lwpop>0
sum lwpop
gen lwpop_2=lwpop^2
gen lwpop_3=lwpop^3
gen lwpop_r1=lwpop*right
gen lwpop_r2=lwpop_2*right
gen lwpop_r3=lwpop_3*right
tab right
table right, c(m rcsize) row

di as red "All" " " "window=`w'"
eststo w`w': reg lexptot right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
}

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save final.dta, replace

***** Results Table 4: PLACEBO REGRESSIONS *****

foreach w in 20 {
use  window`w'_thresh1000_TALL_wpopdem.dta, replace
gen thresh=1000
foreach t in 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
append using  window`w'_thresh`t'_TALL_wpopdem.dta
replace thresh=`t' if thresh==.
}

gen lwpop_2=lwpop^2
gen lwpop_3=lwpop^3
sum lwpop

foreach tt in 35 6 {
gen right`tt'=lwpop>0.0`tt'
gen lwpop_r1`tt'=lwpop*right`tt'
gen lwpop_r2`tt'=lwpop_2*right`tt'
gen lwpop_r3`tt'=lwpop_3*right`tt'
tab right`tt'
table right`tt', c(m rcsize) row

di as red "All" " " "window=`w'" " " "placebo threshold=0.0`tt'
reg lexptot right`tt' lwpop lwpop_2 lwpop_3 lwpop_r1`tt' lwpop_r2`tt' lwpop_r3`tt', robust
test lwpop lwpop_r1`tt' lwpop_2 lwpop_r2`tt' lwpop_3 lwpop_r3`tt'
test lwpop_2 lwpop_r2`tt' lwpop_3 lwpop_r3`tt'
test lwpop_3 lwpop_r3`tt'

gen rightm`tt'=lwpop>-0.0`tt'
gen lwpop_r1m`tt'=lwpop*rightm`tt'
gen lwpop_r2m`tt'=lwpop_2*rightm`tt'
gen lwpop_r3m`tt'=lwpop_3*rightm`tt'
tab rightm`tt'
table rightm`tt', c(m rcsize) row

di as red "All" " " "window=`w'" " " "placebo threshold=-0.0`tt'
reg lexptot rightm`tt' lwpop lwpop_2 lwpop_3 lwpop_r1m`tt' lwpop_r2m`tt' lwpop_r3m`tt', robust
test lwpop lwpop_r1m`tt' lwpop_2 lwpop_r2m`tt' lwpop_3 lwpop_r3m`tt'
test lwpop_2 lwpop_r2m`tt' lwpop_3 lwpop_r3m`tt'
test lwpop_3 lwpop_r3m`tt'
}
}


****** Results Tables 5 and 6 *****

foreach w in 15 {
use  window`w'_thresh1000_TALL_wpopdem.dta, replace
gen thresh=1000
foreach t in 2000 3000 5000 10000 20000 30000 50000 100000 200000 {
append using  window`w'_thresh`t'_TALL_wpopdem.dta
replace thresh=`t' if thresh==.
}
gen right=lwpop>0
sum lwpop
gen lwpop_2=lwpop^2
gen lwpop_3=lwpop^3
gen lwpop_r1=lwpop*right
gen lwpop_r2=lwpop_2*right
gen lwpop_r3=lwpop_3*right
tab right
table right, c(m rcsize) row
reg lexppers right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
reg lexpsach right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
reg lexpsachinv right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
reg ldebt right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
reg ltratea right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
reg ltrateb right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
reg ltratep right lwpop lwpop_2 lwpop_3 lwpop_r1 lwpop_r2 lwpop_r3, robust
test lwpop lwpop_r1 lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_2 lwpop_r2 lwpop_3 lwpop_r3
test lwpop_3 lwpop_r3
}



***** Polynomial Plots *****

***** Figures 1 and 2 *****

use  window15_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 1 - Log expenditures and log population" "around normalized thresholds" "window=15%, Epanechnikov kernel") scheme(s1color) saving( fig_W15_coll_allphases_paper.gph, replace)

use  window30_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 2 - Log expenditures and log population" "around normalized thresholds" "window=30%, Epanechnikov kernel") scheme(s1color) saving( fig_W30_coll_allphases_paper.gph, replace)


***** Appendix: Figures 1 and 2 (Data Plots) *****

use  EggerKoethenbuerger_AEJ_Data.dta.dta, clear
sort id

gen logpop=ln(pop)
gen logexptot=ln(exptot)
gen exppc=exptot/pop
gen logexppc=ln(exppc)
graph twoway scatter logexptot logpop, mc(black) legend(off) ytitle( "Log expenditure") xtitle( "Log population" )  title( "Figure 1 - Log expenditure and log population") scheme(s1color) saving( fig_logexptot_logpop.gph, replace)
graph twoway scatter logexppc logpop, mc(black) legend(off) ytitle( "Log per-capita expenditure") xtitle( "Log population" ) title( "Figure 2 - Log per-capita expenditure and log population") scheme(s1color) saving( fig_logexppc_logpop.gph, replace)


***** Appendix: Figure 4,5 and 6 *****

use  window20_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 4 - Log expenditures and log population" "around normalized thresholds" "window=20%, Epanechnikov kernel") scheme(s1color) saving( fig_W20_coll_allphases.gph, replace)

use  window25_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 5 - Log expenditures and log population" "around normalized thresholds" "window=25%, Epanechnikov kernel") scheme(s1color) saving( fig_W25_coll_allphases.gph, replace)

use  window30_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 6 - Log expenditures and log population" "around normalized thresholds" "window=30%, Epanechnikov kernel") scheme(s1color) saving( fig_W30_coll_allphases_paper.gph, replace)


***** Appendix: Figure 7,8 and 9 *****

use  window15_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) kernel(gaussian) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) kernel(gaussian) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 7 - Log expenditures and log population" "around normalized thresholds" "window=15%, Gaussian kernel") scheme(s1color) saving( fig_W15_coll_allphases_kgaussian.gph, replace)
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) kernel(parzen) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) kernel(parzen) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 8 - Log expenditures and log population" "around normalized thresholds" "window=15%, Parzen kernel") scheme(s1color) saving( fig_W15_coll_allphases_kparzen.gph, replace)
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) kernel(triangle) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) kernel(triangle) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 9 - Log expenditures and log population" "around normalized thresholds" "window=15%, Triangular kernel") scheme(s1color) saving( fig_W15_coll_allphases_ktriangle.gph, replace)


***** Appendix: Figure 10,11 and 12

use  window15_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) bwidth(0.1) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) bwidth(0.1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 10 - Log expenditures and log population" "around normalized thresholds" "window=15%, bandwidth=0.10") scheme(s1color) saving( fig_W15_coll_allphases_bw10.gph, replace)
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) bwidth(0.05) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) bwidth(0.05) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 11 - Log expenditures and log population" "around normalized thresholds" "window=15%, bandwidth=0.05") scheme(s1color) saving( fig_W15_coll_allphases_bw05.gph, replace)
graph twoway scatter lexptot clwpop if (right==0), mc(black)  ||  scatter  lexptot clwpop if (right==1), mc(black) || lpoly lexptot clwpop if (right==0), mc(black) deg(1) bwidth(0.02) ||  lpoly  lexptot clwpop if (right==1), mc(black) deg(1) bwidth(0.02) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 12 - Log expenditures and log population" "around normalized thresholds" "window=15%, bandwidth=0.02") scheme(s1color) saving( fig_W15_coll_allphases_bw02.gph, replace)


***** Appendix: Figure 13 - 16 (Placebo Effects) *****

use  window15_TALL_wpopdem.dta, clear
replace lexptot=lexptot-14.08
graph twoway scatter lexptot clwpop if (right==0&clwpop>-0.12&clwpop<=-0.06), mc(black)  ||  scatter  lexptot clwpop if (right==0&clwpop>-0.06), mc(black) || lpoly lexptot clwpop if (right==0&clwpop>-0.12&clwpop<=-0.06), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==0&clwpop>-0.06), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 13 - Log expenditures and log population" "placebo treatment to the left of normalized" "thresholds (-0.06) - Epanechnikov kernel") scheme(s1color) saving( fig_placa_W15_coll_allphases.gph, replace)
graph twoway scatter lexptot clwpop if (right==1&clwpop>0&clwpop<=0.06), mc(black)  ||  scatter  lexptot clwpop if (right==1&clwpop>0.06&clwpop<0.12), mc(black) || lpoly lexptot clwpop if (right==1&clwpop>0&clwpop<=0.06), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==1&clwpop>0.06&clwpop<0.12), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 14 - Log expenditures and log population" "placebo treatment to the right of normalized" "thresholds (+0.06) - Epanechnikov kernel") scheme(s1color) saving( fig_placb_W15_coll_allphases.gph, replace)
graph twoway scatter lexptot clwpop if (right==0&clwpop>-0.075&clwpop<=-0.03), mc(black)  ||  scatter  lexptot clwpop if (right==0&clwpop>=-0.035), mc(black) || lpoly lexptot clwpop if (right==0&clwpop>-0.075&clwpop<=-0.03), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==0&clwpop>=-0.035), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 15 - Log expenditures and log population" "placebo treatment to the left of normalized" "thresholds (-0.035) - Epanechnikov kernel") scheme(s1color) saving( fig_placc_W15_coll_allphases.gph, replace)
graph twoway scatter lexptot clwpop if (right==1&clwpop<=0.035), mc(black)  ||  scatter  lexptot clwpop if (right==1&clwpop>0.035&clwpop<0.075), mc(black) || lpoly lexptot clwpop if (right==1&clwpop<0.035), mc(black) deg(1) ||  lpoly  lexptot clwpop if (right==1&clwpop>0.03&clwpop<0.075), mc(black) deg(1) legend(off) ytitle( "Log total expenditures" " ") xtitle( "Log population" )  title( "Figure 16 - Log expenditures and log population" "placebo treatment to the right of normalized" "thresholds (+0.035) - Epanechnikov kernel") scheme(s1color) saving( fig_placd_W15_coll_allphases.gph, replace)


exit
