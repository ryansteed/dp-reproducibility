clear matrix
clear
set mem 500m
set matsize 800
set more off
cap log close

* Install/Update outreg2
*ssc install outreg2, replace

********************************************************************************
/*

					Replication of the main results of
					 
					 "Moderating Political Extremism: 
		  Single Round vs Runoff Elections under Plurality Rule"
						
						 American Economic Review

								   
							 Massimo Bordignon 
							 Tommaso Nannicini 
							  Guido Tabellini


*/
********************************************************************************
*** Edit by Donna
version 13

use dataset/dual_ballot_replication.dta

cap mkdir output
cd output

********************************************************************************
* TABLE 1 - RDD Estimates
********************************************************************************
cap mkdir table1
cd table1

* Panel A: Estimation w/o covariates

* Row 1 - Cols 1-6 *** number of candidates for mayor:
table t15000,c(m number_candidates)

foreach var in number_candidates {
reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r1_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r1_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 if pop_census>=14000&pop_census<=16000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=14500&pop_census<=15500,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=13000&pop_census<=17000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
}

* Row 2-5 - Cols 1-6 *** number of political parties (several definitions):
table t15000,c(m number_parties)
table t15000,c(m number_parties_oppcoal)
table t15000,c(m number_parties_maycoal)

local i = 2
foreach var in number_parties ratio number_parties_oppcoal number_parties_maycoal {
reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r`i'_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r`i'_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r`i'_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 if pop_census>=14000&pop_census<=16000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r`i'_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=14500&pop_census<=15500,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r`i'_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=13000&pop_census<=17000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelA_r`i'_`var', bdec(3) nocons tex(nopretty) append
local i = `i'+1
}


* Panel B: Estimation with covariates

* Row 1 - Cols 1-6 *** number of candidates for mayor:
local covariates north CE south area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit

foreach var in number_candidates {
eststo: reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r1`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r1`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r1`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14000&pop_census<=16000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r1`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14500&pop_census<=15500,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r1`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=13000&pop_census<=17000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r1`var', bdec(3) nocons tex(nopretty) append
}

*** EDIT BY Donna
estout using "../../../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

* Row 2-5 - Cols 1-6 *** number of political parties (several definitions):
local i = 2
foreach var in number_parties ratio number_parties_oppcoal number_parties_maycoal {
reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r`i'_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r`i'_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r`i'_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14000&pop_census<=16000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r`i'_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14500&pop_census<=15500,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r`i'_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=13000&pop_census<=17000,r cluster(id_city_istat)
outreg2 t15000 using tab1_panelB_r`i'_`var', bdec(3) nocons tex(nopretty) append
local i = `i'+1
}

cd ..
cd ..

********************************************************************************
* TABLE 2 - Falsification test on pre-treatment outcomes
********************************************************************************
use dataset/dual_ballot_falsification.dta, clear

cd output
cap mkdir table2
cd table2

table t15000,c(m number_parties)

* Panel A: Estimation w/o covariates
foreach var in number_parties {
reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelA_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelA_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelA_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 if pop_census>=14000&pop_census<=16000,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelA_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=14500&pop_census<=15500,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelA_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=13000&pop_census<=17000,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelA_`var', bdec(3) nocons tex(nopretty) append
}

* Panel B: Estimation with covariates
eststo clear
local covariates north CE south area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit

foreach var in number_parties {
eststo: reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelB_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelB_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2 `covariates',r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelB_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14000&pop_census<=16000,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelB_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14500&pop_census<=15500,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelB_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=13000&pop_census<=17000,r cluster(id_city_istat)
outreg2 t15000 using tab2_fals_panelB_`var', bdec(3) nocons tex(nopretty) append
}
*** EDIT BY Donna
estout using "../../../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
cd ..
cd ..

********************************************************************************
* TABLE 3 - Diff-in-diff Estimates
********************************************************************************
use dataset/dual_ballot_replication.dta, clear
*** EDIT by Donna
xtset id_city_istat year_election

cd output
cap mkdir table3
cd table3
eststo clear
local i = 1
* Panel A - rows 1 - 5 - Estimations w/o covariates
foreach var in number_candidates number_parties ratio number_parties_oppcoal number_parties_maycoal {
xi: xtreg `var' t15000 i.year_election,fe
outreg2 t15000 using tab3_r`i'_`var', bdec(3) nocons tex(nopretty) replace

* Panel B - rows 1 - 5 - Estimation with covariates
local covariates north CE south area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit
eststo: xi: xtreg `var' t15000 i.year_election `covariates',fe
outreg2 t15000 using tab3_r`i'_`var', bdec(3) nocons tex(nopretty) append
local i = `i'+1
}

*** EDIT BY Donna
estout using "../../../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

cd ..

********************************************************************************
* TABLE 4 - Runoff and Policy Volatility, RDD Estimates
********************************************************************************
cap mkdir table4
cd table4
eststo clear
* Intertemporal variation
preserve
capture drop auxiliary
replace avg_ordinaria=beg_ordinaria if avg_ordinaria==.
egen auxiliary=sd(avg_ordinaria),by(id_city_istat)
capture drop var_ord
gen var_ord=auxiliary^2
drop auxiliary

foreach var in area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit {
egen tmp=mean(`var'),by(id_city_istat)
replace `var'=tmp
drop tmp
}

bysort id_city_istat t15000: gen nbis=_n
keep if nbis==1
bysort id_city_istat: gen ntris=_n
tab ntris
tab ntris if var_ord!=.

drop t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4
replace pop_census=pop_census1991

foreach x in 15000 {
gen pop`x'=pop_census-`x'
gen pop`x'_2=pop`x'^2
gen pop`x'_3=pop`x'^3
gen pop`x'_4=pop`x'^4
gen t`x'= pop_census>`x'
gen t`x'_int1=t`x'*pop`x'
gen t`x'_int2=t`x'*pop`x'_2
gen t`x'_int3=t`x'*pop`x'_3
gen t`x'_int4=t`x'*pop`x'_4
}

* Panel A - Estimations w/o covariates
foreach var in var_ord {
reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelA_r1_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelA_r1_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 if pop_census>=14000&pop_census<=16000, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=14500&pop_census<=15500, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 if pop_census>=13000&pop_census<=17000, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelA_r1_`var', bdec(3) nocons tex(nopretty) append
}

* Panel B - Estimation with covariates
local covariates north CE area alt_max end_rev_transf_pc income_pc elderly_index active_pop family_size duration term_limit

foreach var in var_ord {
eststo: reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates', r cluster(id_city_istat)
outreg2 t15000 using tab4_panelB_r1_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4 `covariates', r cluster(id_city_istat)
outreg2 t15000 using tab4_panelB_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2 `covariates', r cluster(id_city_istat)
outreg2 t15000 using tab4_panelB_r1_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14000&pop_census<=16000, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelB_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=14500&pop_census<=15500, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelB_r1_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' if pop_census>=13000&pop_census<=17000, r cluster(id_city_istat)
outreg2 t15000 using tab4_panelB_r1_`var', bdec(3) nocons tex(nopretty) append
}
restore


* Cross sectional variation
preserve

g bin100=.
forvalues i=-5000(100)4900 {
qui replace bin100=`i' if pop15000>=`i'&pop15000<`i'+100
}

egen size100=count(id_city_istat),by(bin100)

foreach x in ordinaria_cs {
egen auxiliary2=sd(`x'),by(bin100 year_election)
g var2_`x'=auxiliary2^2
drop auxiliary2
egen var3_`x'=mean(var2_`x'),by(bin100)
sort bin100
}

replace pop15000=bin100
replace pop15000_2=bin100^2
replace pop15000_3=bin100^3
replace pop15000_4=bin100^4
replace t15000_int1=t15000*pop15000
replace t15000_int2=t15000*pop15000_2
replace t15000_int3=t15000*pop15000_3
replace t15000_int4=t15000*pop15000_4

foreach var in north CE area alt_max {
egen tmp=mean(`var'),by(bin100)
replace `var'=tmp
drop tmp
}

bys bin100: g n=_n
keep if n==1
g w= 1/size100

* Panel A - Estimations w/o covariates
foreach var in var3_ordinaria {
reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 [aw=w],r
outreg2 t15000 using tab4_panelA_r2_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4 [aw=w],r
outreg2 t15000 using tab4_panelA_r2_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2 [aw=w],r
outreg2 t15000 using tab4_panelA_r2_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 [aw=w] if pop_census>=14000&pop_census<=16000,r
outreg2 t15000 using tab4_panelA_r2_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 [aw=w] if pop_census>=14500&pop_census<=15500,r
outreg2 t15000 using tab4_panelA_r2_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 [aw=w] if pop_census>=13000&pop_census<=17000,r
outreg2 t15000 using tab4_panelA_r2_`var', bdec(3) nocons tex(nopretty) append
}

* Panel B - Estimation with covariates
local covariates north CE area alt_max
foreach var in var3_ordinaria {
eststo: reg `var' t15000 pop15000 pop15000_2 pop15000_3 t15000_int1 t15000_int2 t15000_int3 `covariates' [aw=w],r
outreg2 t15000 using tab4_panelB_r2_`var', bdec(3) nocons tex(nopretty) replace
reg `var' t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4 `covariates' [aw=w],r
outreg2 t15000 using tab4_panelB_r2_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 pop15000_2 t15000_int1 t15000_int2 `covariates' [aw=w],r
outreg2 t15000 using tab4_panelB_r2_`var', bdec(3) nocons tex(nopretty) append

reg `var' t15000 pop15000 t15000_int1 `covariates' [aw=w] if pop_census>=14000&pop_census<=16000,r
outreg2 t15000 using tab4_panelB_r2_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' [aw=w] if pop_census>=14500&pop_census<=15500,r
outreg2 t15000 using tab4_panelB_r2_`var', bdec(3) nocons tex(nopretty) append
reg `var' t15000 pop15000 t15000_int1 `covariates' [aw=w] if pop_census>=13000&pop_census<=17000,r
outreg2 t15000 using tab4_panelB_r2_`var', bdec(3) nocons tex(nopretty) append
}

*** EDIT BY Donna
estout using "../../../../results/table4.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

restore

cd ..

********************************************************************************
* FIGURE 1 
********************************************************************************
cap mkdir figure1
cd figure1

* Graph 1. Number of candidates
preserve
gen mv2=pop15000

foreach i in 250 {
 gen mv_grp`i' = `i'*int((mv2)/`i')
 replace mv_grp`i'=-125 if mv_grp`i'==0&mv2<0
 replace mv_grp`i'=125 if mv_grp`i'==0&mv2>0
 egen  mean_mv`i' = mean(mv2), by(mv_grp`i')
 foreach var of varlist number_candidates number_parties number_parties_oppcoal number_parties_maycoal {
 egen `var'_mean`i' = mean(`var'), by(mv_grp`i')
}
}

reg number_candidates pop15000 pop15000_2 pop15000_3 if pop15000<0, r cluster(id_city_istat)
predict yhat_left
predict SE_left if pop15000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)
reg number_candidates pop15000 pop15000_2 pop15000_3 if pop15000>0, r cluster(id_city_istat)
predict yhat_right
predict SE_right if pop15000>0, stdp
gen low_right = yhat_right - 2*(SE_right)
gen high_right = yhat_right + 2*(SE_right)

twoway (scatter number_candidates_mean250 mv_grp250,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left low_left high_left pop15000 if pop15000<0, pstyle(p p3 p3) sort) /* 
*/ (line yhat_right low_right high_right pop15000 if pop15000>0, pstyle (p p3 p3) sort), /*
*/ xtitle(Normalized population) ytitle(Number of candidates) legend(off) xline(0) xscale(range(-25,25)) graphregion(fcolor(white) color(white))
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save g1_dual_candidates,replace
graph export g1_dual_candidates.eps, replace


* Graph 2. Number of parties
reg number_parties pop15000 pop15000_2 pop15000_3 if pop15000<0, r cluster(id_city_istat)
predict yhat_left
predict SE_left if pop15000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)
reg number_parties pop15000 pop15000_2 pop15000_3 if pop15000>0, r cluster(id_city_istat)
predict yhat_right
predict SE_right if pop15000>0, stdp
gen low_right = yhat_right - 2*(SE_right)
gen high_right = yhat_right + 2*(SE_right)

twoway (scatter number_parties_mean250 mv_grp250,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left low_left high_left pop15000 if pop15000<0, pstyle(p p3 p3) sort) /* 
*/ (line yhat_right low_right high_right pop15000 if pop15000>0, pstyle (p p3 p3) sort), /*
*/ xtitle(Normalized population) ytitle(Number of parties) legend(off) xline(0) xscale(range(-25,25)) graphregion(fcolor(white) color(white))
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save g2_dual_parties,replace
graph export g2_dual_parties.eps, replace


* Graph 3. Number of opposition parties
reg number_parties_oppcoal pop15000 pop15000_2 pop15000_3 if pop15000<0, r cluster(id_city_istat)
predict yhat_left
predict SE_left if pop15000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)
reg number_parties_oppcoal pop15000 pop15000_2 pop15000_3 if pop15000>0, r cluster(id_city_istat)
predict yhat_right
predict SE_right if pop15000>0, stdp
gen low_right = yhat_right - 2*(SE_right)
gen high_right = yhat_right + 2*(SE_right)

twoway (scatter number_parties_oppcoal_mean250 mv_grp250,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left low_left high_left pop15000 if pop15000<0, pstyle(p p3 p3) sort) /* 
*/ (line yhat_right low_right high_right pop15000 if pop15000>0, pstyle (p p3 p3) sort), /*
*/ xtitle(Normalized population) ytitle(Opposition parties) legend(off) xline(0) xscale(range(-25,25)) graphregion(fcolor(white) color(white))
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save g3_dual_parties_oppcoal,replace
graph export g3_dual_parties_oppcoal.eps, replace


* Graph 4. Number of parties in the Mayor's coalition
reg number_parties_maycoal pop15000 pop15000_2 pop15000_3 if pop15000<0, r cluster(id_city_istat)
predict yhat_left
predict SE_left if pop15000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)
reg number_parties_maycoal pop15000 pop15000_2 pop15000_3 if pop15000>0, r cluster(id_city_istat)
predict yhat_right
predict SE_right if pop15000>0, stdp
gen low_right = yhat_right - 2*(SE_right)
gen high_right = yhat_right + 2*(SE_right)

twoway (scatter number_parties_maycoal_mean250 mv_grp250,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left low_left high_left pop15000 if pop15000<0, pstyle(p p3 p3) sort) /* 
*/ (line yhat_right low_right high_right pop15000 if pop15000>0, pstyle (p p3 p3) sort), /*
*/ xtitle(Normalized population) ytitle(Mayor's parties) legend(off) xline(0) xscale(range(-25,25)) graphregion(fcolor(white) color(white))
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right 
graph save g4_dual_parties_maycoal,replace
graph export g4_dual_parties_maycoal.eps, replace

restore
* Graph 5. Time Variance of business property tax
preserve
capture drop auxiliary
replace avg_ordinaria=beg_ordinaria if avg_ordinaria==.
egen auxiliary=sd(avg_ordinaria),by(id_city_istat)
capture drop var_ord
gen var_ord=auxiliary^2
drop auxiliary

bysort id_city_istat t15000: gen nbis=_n
keep if nbis==1
bysort id_city_istat: gen ntris=_n
tab ntris
tab ntris if var_ord!=.

drop t15000 pop15000 pop15000_2 pop15000_3 pop15000_4 t15000_int1 t15000_int2 t15000_int3 t15000_int4
replace pop_census=pop_census1991

foreach x in 15000 {
gen pop`x'=pop_census-`x'
gen pop`x'_2=pop`x'^2
gen pop`x'_3=pop`x'^3
gen pop`x'_4=pop`x'^4
gen t`x'= pop_census>`x'
gen t`x'_int1=t`x'*pop`x'
gen t`x'_int2=t`x'*pop`x'_2
gen t`x'_int3=t`x'*pop`x'_3
gen t`x'_int4=t`x'*pop`x'_4
}

cap drop mv2
gen mv2=pop15000
foreach i in 250 {
 gen mv_grp`i' = `i'*int((mv2)/`i')
 replace mv_grp`i'=-125 if mv_grp`i'==0&mv2<0
 replace mv_grp`i'=125 if mv_grp`i'==0&mv2>0
 egen  mean_mv`i' = mean(mv2), by(mv_grp`i')
 foreach var of varlist var_ord {
 egen `var'_mean`i' = mean(`var'), by(mv_grp`i')
 }
}


reg var_ord pop15000 pop15000_2 pop15000_3 if pop15000<0, r cluster(id_city_istat)
predict yhat_left
predict SE_left if pop15000<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg var_ord pop15000 pop15000_2 pop15000_3 if pop15000>0, r cluster(id_city_istat)
predict yhat_right
predict SE_right if pop15000>0, stdp
gen low_right = yhat_right - 2*(SE_right)
gen high_right = yhat_right + 2*(SE_right)

twoway (scatter var_ord_mean250 mean_mv250 if pop15000>=-5000&pop15000<=5000,msymbol(circle_hollow) mcolor(gray)) /*
*/ (line yhat_left low_left high_left pop15000 if pop15000<0&pop15000>=-5000, pstyle(p p3 p3) sort) /* 
*/ (line yhat_right low_right high_right pop15000 if pop15000>0&pop15000<=5000, pstyle (p p3 p3) sort), /*
*/ xtitle("Normalized population") ytitle("Time variance") legend(off) xline(0) xscale(range(-25,25)) graphregion(fcolor(white) color(white))
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right
graph save g5_dual_property_tax,replace
graph export g5_dual_property_tax.eps, replace
restore


*Graph 6. Cross-sectional variance of business property tax
preserve
g bin100=.
forvalues i=-5000(100)4900 {
qui replace bin100=`i' if pop15000>=`i'&pop15000<`i'+100
}
egen size100=count(id_city_istat),by(bin100)

foreach x in ordinaria_cs {
egen auxiliary2=sd(`x'),by(bin100 year_election)
g var2_`x'=auxiliary2^2
drop auxiliary2
egen var3_`x'=mean(var2_`x'),by(bin100)
sort bin100
}

replace pop15000=bin100
replace pop15000_2=bin100^2
replace pop15000_3=bin100^3
replace pop15000_4=bin100^4
replace t15000_int1=t15000*pop15000
replace t15000_int2=t15000*pop15000_2
replace t15000_int3=t15000*pop15000_3
replace t15000_int4=t15000*pop15000_4

bys bin100: g n=_n
keep if n==1
g w= 1/size100

g bin100_grp=.
forvalues i=-5000(500)4500 {
qui replace bin100_grp=`i' if bin100>=`i'&bin100<`i'+500
}
qui replace bin100_grp=bin100_grp+250

foreach x of varlist var3_ordinaria {
egen `x'_grp = mean(`x'), by(bin100_grp)

reg `x' pop15000 pop15000_2 pop15000_3 [aw=w] if bin100<0
predict yhat_left
predict SE_left if bin100<0, stdp
gen low_left = yhat_left - 1.96*(SE_left)
gen high_left = yhat_left + 1.96*(SE_left)

reg `x' pop15000 pop15000_2 pop15000_3 [aw=w] if bin100>=0
predict yhat_right
predict SE_right if bin100>=0, stdp
gen low_right = yhat_right - 1.96*(SE_right)
gen high_right = yhat_right + 1.96*(SE_right)

twoway (scatter `x'_grp bin100_grp,msymbol(circle_hollow) msize(medium) mcolor(gray)) /*
*/ (line yhat_left low_left high_left bin100 if bin100<0, pstyle(p p3 p3) sort) /* 
*/ (line yhat_right low_right high_right bin100 if bin100>=0, pstyle (p p3 p3) sort), /*
*/ xtitle("Normalized population",margin(medsmall)) ytitle("Cross-sectional variance",margin(medsmall)) legend(off) xline(0) graphregion(fcolor(white) color(white))
drop yhat_left low_left high_left SE_left yhat_right low_right high_right SE_right

graph save g6_var2.gph,replace
graph export g6_var2.eps,replace
}
restore

* Combine single graphs into figure1
graph combine g1_dual_candidates.gph g2_dual_parties.gph g3_dual_parties_oppcoal.gph g4_dual_parties_maycoal.gph g5_dual_property_tax.gph g6_var2.gph , c(3) graphregion(fcolor(white) color(white))
graph save figure1, replace
graph export figure1.eps, replace
graph export figure1.png, replace
graph export figure1.pdf, replace
