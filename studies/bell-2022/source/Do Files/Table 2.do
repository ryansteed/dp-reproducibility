*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"

cap log c
log using "Do Files\Table2",replace t

************************************************************************

******************           TABLE 2              **********************

************************************************************************


*** COLUMN (1)

clear all
set more off

**********************       All States Sample       ***************************

use "Data\arrest_data_all_states.dta"


keep if crime==1


* Regression
qui:reghdfe log_arrest_rate_tot i.disc1 i.disc2 i.disc3  [aw=population_est_cell], a(crime##c.log_police crime##c.log_pop crime##c.pop_share_black crime##c.share_female_pop crime##c.pop_share_other age#crime year#crime crime#county_fips) cl(fstate) tol(1e-10)  nocons
est tab, b se p stats(N)


* Weighted average effect across multiple discontinuities (using margins)
margins [aw=population_est_cell], over(disc1) post grand
qui: matrix b1 = (nullmat(b1),e(b))
qui: matrix A1 = (nullmat(A1),b1[1,2])
qui: matrix D1 = (nullmat(D1),e(N))
lincom [1.disc1]-[0.disc1]


* Get weights to construct the weighted average effect across multiple discontinuities and bootstrap the CI
qui: sum disc1 [aw= population_est_cell ] if disc1==1
qui: local wgt_disc1=r(mean)
qui: sum disc2 [aw= population_est_cell ] if disc1==1
qui: local wgt_disc2=r(mean)
qui: sum disc3 [aw= population_est_cell ] if disc1==1
qui: local wgt_disc3=r(mean)


* Bootstrap
preserve
qui: hdfe log_arrest_rate_tot disc1 disc2 disc3  [aw=population_est_cell], a(crime##c.log_police crime##c.log_pop crime##c.pop_share_black crime##c.share_female_pop crime##c.pop_share_other age#crime year#crime crime#county_fips) tol(1e-10)  gen(r_)
reg r_* [aw=population_est_cell], cl(fstate) nocons
boottest `wgt_disc1'*r_disc1+`wgt_disc2'*r_disc2+`wgt_disc3'*r_disc3=0, reps(9999) boottype(wild) cl(fstate) bootcluster(fstate) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c1 = (nullmat(c1),r(CI))
qui: matrix B1 = (nullmat(B1),c1')
qui: matrix C1 = (nullmat(C1),r(p))

qui: distinct fstate
qui: matrix E1=r(ndistinct)
qui: distinct county_fips
qui: matrix F1=r(ndistinct)

restore

matrix T1=(A1\B1\C1\D1\E1\F1)















*** COLUMNS (2)-(6)

********************     Pooled  Discontinuty Sample     ***********************

use "Data\arrest_data_discontinuity_states.dta", clear 


* Revert Texas (1985) CSL Drop for pooled effect
qui: replace disc=(disc==0) if fstate==48 & new_max==16
qui: replace time=-time-1 if fstate==48 & new_max==16

keep if crime==1

* Quadratic and Cubic Running Variables
gen time_sq=time^2
gen time_cb=time^3

codebook county_fips


***********************          10 Year-Window         ************************


***************************
* Linear Running Variable *
***************************

* Regression
reghdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
qui: matrix A2 = (nullmat(A2),_b[disc])
qui: matrix D2 = (nullmat(D2),e(N))

* Bootstrap
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c2 = (nullmat(c2),r(CI))
qui: matrix B2 = (nullmat(B2),c2')
qui: matrix C2 = (nullmat(C2),r(p))
drop r_*

qui: distinct fstate
qui: matrix E2=r(ndistinct)
qui: distinct county_fips
qui: matrix F2=r(ndistinct)

matrix T2=(A2\B2\C2\D2\E2\F2)




******************************
* Quadratic Running Variable *
******************************

* Regression
reghdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id c.time_sq#disc#disc_id c.time_sq#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
qui: matrix A3 = (nullmat(A3),_b[disc])
qui: matrix D3 = (nullmat(D3),e(N))

* Bootstrap
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id c.time_sq#disc#disc_id c.time_sq#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c3 = (nullmat(c3),r(CI))
qui: matrix B3 = (nullmat(B3),c3')
qui: matrix C3 = (nullmat(C3),r(p))
drop r_*

qui: distinct fstate
qui: matrix E3=r(ndistinct)
qui: distinct county_fips
qui: matrix F3=r(ndistinct)

matrix T3=(A3\B3\C3\D3\E3\F3)







**************************
* Cubic Running Variable *
**************************

* Regression
reghdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id c.time_sq#disc#disc_id c.time_sq#disc_id c.time_cb#disc#disc_id c.time_cb#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
qui: matrix A4 = (nullmat(A4),_b[disc])
qui: matrix D4 = (nullmat(D4),e(N))

* Bootstrap
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id c.time_sq#disc#disc_id c.time_sq#disc_id c.time_cb#disc#disc_id c.time_cb#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c4 = (nullmat(c4),r(CI))
qui: matrix B4 = (nullmat(B4),c4')
qui: matrix C4 = (nullmat(C4),r(p))
drop r_*

qui: distinct fstate
qui: matrix E4=r(ndistinct)
qui: distinct county_fips
qui: matrix F4=r(ndistinct)

matrix T4=(A4\B4\C4\D4\E4\F4)





************************         7 Year-Window         *************************

keep if time>=-7 & time<=6


* Regression
reghdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
qui: matrix A5 = (nullmat(A5),_b[disc])
qui: matrix D5 = (nullmat(D5),e(N))

* Bootstrap
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c5 = (nullmat(c5),r(CI))
qui: matrix B5 = (nullmat(B5),c5')
qui: matrix C5 = (nullmat(C5),r(p))
drop r_*

qui: distinct fstate
qui: matrix E5=r(ndistinct)
qui: distinct county_fips
qui: matrix F5=r(ndistinct)

matrix T5=(A5\B5\C5\D5\E5\F5)







************************         5 Year-Window         *************************

keep if time>=-5 & time<=4

* Regression
reghdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
qui: matrix A6 = (nullmat(A6),_b[disc])
qui: matrix D6 = (nullmat(D6),e(N))

* Bootstrap
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c6 = (nullmat(c6),r(CI))
qui: matrix B6 = (nullmat(B6),c6')
qui: matrix C6 = (nullmat(C6),r(p))
drop r_*


qui: distinct fstate
qui: matrix E6=r(ndistinct)
qui: distinct county_fips
qui: matrix F6=r(ndistinct)


matrix T6=(A6\B6\C6\D6\E6\F6)

matrix T=(T1,T2,T3,T4,T5,T6)

matrix colnames T = OLS 10-Linear 10-Quad 10-Cubic 7-Linear 5-Linear 

matrix rownames T = Coefficient CI_l CI_u P-value N


* COLUMNS (1)-(6)

matrix list T




















********************     Pooled  Discontinuty Sample     ***********************

*** Local Linear Regression Design

/* Considering the limitations of CCT 2014 rdrobust in handling multiple fixed 
effects as controls, the alternative way to get the pooled effect across 
discontinuities is to estimate them individually at reform-state level using CCT
2014 rdrobust and average weight the coefficient and SEs */



* COLUMN (7)

*** Local Linear Regression - Individual Discontinuities

clear all
clear matrix
set more off


use "Data\arrest_data_discontinuity_states.dta", clear 

sort fstate disc_id
egen disc_id2=group(fstate disc_id)
drop disc_id
rename disc_id2 disc_id

keep if time>=-10 & time<=9

*Estimate Individual Discontinuities CCT 2014

qui{

forvalues i=1/30 {

preserve

keep if  disc_id==`i' & crime==1
tab year, gen(year_)
tab age, gen(age_)
tab fcounty, gen(fcounty_)
egen n_county=nvals(fcounty)
sum n_county
local max_county=r(max)
egen n_year=nvals(year)
sum n_year
local max_year=r(max)

local varlist="fcounty_1-fcounty_`max_county' year_1-year_`max_year' age_1-age_10"

xi: rdrobust log_arrest_rate_tot time if disc_id==`i' & crime==1, ///
		c(0) h(10) p(1) q(2) vce(hc3) weights(population_est_cell) masspoints(adjust) ///
		covs(log_police log_pop pop_share_black share_female_pop pop_share_other `varlist') covs_drop(on) all
		
matrix A = (nullmat(A)\e(tau_bc))
matrix B = (nullmat(B)\e(se_tau_rb))
matrix C = (nullmat(C)\\`i')

restore

}

matrix E=(C,A,B)


matrix rownames E = Arizona Arkansas Arkansas California Colorado Connecticut Illinois Indiana Indiana Iowa Kentucky Louisiana Louisiana Maine Michigan Michigan Mississippi Missouri Nebraska Nevada New_Hampshire New_Mexico Rhode_Island South_Dakota Texas Texas Texas Virginia Washington Wyoming

matrix colnames E = disc_id beta se

}

matrix list E

clear

svmat E, names(col)

tempfile local_linear_rd

save `local_linear_rd', replace



* Get weights to compute average effect

use "Data\arrest_data_discontinuity_states.dta", clear 

sort fstate disc_id
egen disc_id2=group(fstate disc_id)
drop disc_id
rename disc_id2 disc_id

keep if time>=-10 & time<=9


collapse (sum) population_est_cell, by(disc_id)

egen tot_pop=total(population_est_cell)
gen weight=population_est_cell/tot_pop


* Merge with coefficients and SEs
merge 1:1 disc_id using "`local_linear_rd'"

* Revert Texas (1985) CSL Drop for pooled effect
replace beta=- beta if _n==25

* Compute Wieghted Average Effect
egen average_beta=total(weight*beta)
egen average_se=total((weight*se)^2)
replace average_se=(average_se)^(1/2)
gen average_CI_u=average_beta+invttail(10000,0.025)*average_se
gen average_CI_l=average_beta-invttail(10000,0.025)*average_se
gen p_value=2*(1-ttail(10000,average_beta/average_se))
sum average_beta average_se average_CI_u average_CI_l p_value


log c