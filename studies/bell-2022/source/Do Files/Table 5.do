*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"

cap log c
log using "Do Files\Table5",replace t


************************************************************************

******************           TABLE 4              **********************

************************************************************************

clear all
set more off


*** Choose Exclude Fall
local nofall=1



********************     Pooled  Discontinuty Sample     ***********************

use "Data\arrest_data_discontinuity_states.dta", clear 


*** Drop Texas (1985) CSL 
gen fall=(old_max>new_max)


if `nofall'==1 {
drop if fall==1
}

keep if time>=-5 & time<=4



gen arrest_rate_tot=exp(log_arrest_rate_tot)
gen arrest_rate=exp(log_arrest_rate)


* TOTAL - COLUMN (1)

reghdfe log_arrest_rate_tot 1.disc#i.age [aw=population_est_cell] if crime==1, a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
matrix A1=(nullmat(A1),e(b)')
matrix B1=(nullmat(B1),e(V))
matrix B1=vecdiag(B1)'
matmap B1 B1, m(sqrt(@))
preserve
keep if crime==1
qui: hdfe  log_arrest_rate_tot 1.disc#ib0.age [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest {r___1__disc_X_15__age} {r___1__disc_X_16__age} {r___1__disc_X_17__age} {r___1__disc_X_18__age} {r___1__disc_X_19__age} {r___1__disc_X_20__age} {r___1__disc_X_21__age} {r___1__disc_X_22__age} {r___1__disc_X_23__age} {r___1__disc_X_24__age}, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
forvalues k=1/10 {
matrix C1=(nullmat(C1)\r(CI_`k'))
matrix D1=(nullmat(D1)\r(p_`k'))
}
drop r_*
tab age [aw=population_est_cell] if disc==0, sum(arrest_rate_tot) nost noobs nofreq
restore

matrix T1=(A1,B1,C1,D1)


* VIOLENT  - COLUMN (2)
preserve
keep if crime==1

reghdfe log_arrest_rate 1.disc#i.age [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
matrix A2=(nullmat(A2),e(b)')
matrix B2=(nullmat(B2),e(V))
matrix B2=vecdiag(B2)'
matmap B2 B2, m(sqrt(@))
qui: hdfe  log_arrest_rate 1.disc#ib0.age [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest {r___1__disc_X_15__age} {r___1__disc_X_16__age} {r___1__disc_X_17__age} {r___1__disc_X_18__age} {r___1__disc_X_19__age} {r___1__disc_X_20__age} {r___1__disc_X_21__age} {r___1__disc_X_22__age} {r___1__disc_X_23__age} {r___1__disc_X_24__age}, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
forvalues k=1/10 {
matrix C2=(nullmat(C2)\r(CI_`k'))
matrix D2=(nullmat(D2)\r(p_`k'))
}
drop r_*
tab age [aw=population_est_cell] if disc==0, sum(arrest_rate) nost noobs nofreq
restore

matrix T2=(A2,B2,C2,D2)




* PROPERTY - COLUMN (3)
preserve
keep if crime==2

reghdfe log_arrest_rate 1.disc#i.age [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
matrix A3=(nullmat(A3),e(b)')
matrix B3=(nullmat(B3),e(V))
matrix B3=vecdiag(B3)'
matmap B3 B3, m(sqrt(@))
qui: hdfe  log_arrest_rate 1.disc#ib0.age [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest {r___1__disc_X_15__age} {r___1__disc_X_16__age} {r___1__disc_X_17__age} {r___1__disc_X_18__age} {r___1__disc_X_19__age} {r___1__disc_X_20__age} {r___1__disc_X_21__age} {r___1__disc_X_22__age} {r___1__disc_X_23__age} {r___1__disc_X_24__age}, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
forvalues k=1/10 {
matrix C3=(nullmat(C3)\r(CI_`k'))
matrix D3=(nullmat(D3)\r(p_`k'))
}
drop r_*
tab age [aw=population_est_cell] if disc==0, sum(arrest_rate) nost noobs nofreq
restore

matrix T3=(A3,B3,C3,D3)



* DRUGS - COLUMN (4)
preserve
keep if crime==3

reghdfe log_arrest_rate 1.disc#i.age [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
matrix A4=(nullmat(A4),e(b)')
matrix B4=(nullmat(B4),e(V))
matrix B4=vecdiag(B4)'
matmap B4 B4, m(sqrt(@))
qui: hdfe  log_arrest_rate 1.disc#ib0.age [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest {r___1__disc_X_15__age} {r___1__disc_X_16__age} {r___1__disc_X_17__age} {r___1__disc_X_18__age} {r___1__disc_X_19__age} {r___1__disc_X_20__age} {r___1__disc_X_21__age} {r___1__disc_X_22__age} {r___1__disc_X_23__age} {r___1__disc_X_24__age}, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
forvalues k=1/10 {
matrix C4=(nullmat(C4)\r(CI_`k'))
matrix D4=(nullmat(D4)\r(p_`k'))
}
drop r_*
tab age [aw=population_est_cell] if disc==0, sum(arrest_rate) nost noobs nofreq
restore


matrix T4=(A4,B4,C4,D4)



* TOTAL

matrix colnames T1 = Coefficient SE_cluster CI_l CI_u P-value 

matrix rownames T1 = 15 16 17 18 19 20 21 22 23 24

matrix list T1

* VIOLENT

matrix colnames T2 = Coefficient SE_cluster CI_l CI_u P-value 

matrix rownames T2 = 15 16 17 18 19 20 21 22 23 24 

matrix list T2

* PROPERTY

matrix colnames T3 = Coefficient SE_cluster CI_l CI_u P-value 

matrix rownames T3 = 15 16 17 18 19 20 21 22 23 24 

matrix list T3

* DRUGS

matrix colnames T4 = Coefficient SE_cluster CI_l CI_u P-value 

matrix rownames T4 = 15 16 17 18 19 20 21 22 23 24 

matrix list T4


log c