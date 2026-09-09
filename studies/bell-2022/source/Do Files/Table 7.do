*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"


cap log c
log using "Do Files\Table7",replace t


************************************************************************

**********************          TABLE 7         ************************

************************************************************************


clear matrix
clear all
set more off


use "Data\arrest_data_dynamic_incap.dta", clear




*** Separate or Pooled RD Coefficients from Tables 3 and 4

* Total Crime Betas

local disc_b_young_18=-0.069
local disc_b_old_18=-0.040

* Crime Types Betas
local disc_b_young_vio_18=-0.055
local disc_b_old_vio_18=-0.041

local disc_b_young_prop_18=-0.056
local disc_b_old_prop_18=-0.040

local disc_b_young_drug_18=-0.129
local disc_b_old_drug_18=-0.045

* Reform Types Betas

local disc_b_young_below18=-0.070
local disc_b_old_below18=-0.038

local disc_b_young_above18=-0.069
local disc_b_old_above18=-0.042


 


*** Spec1 - Controls: Log Pop

* Regression
reghdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##crime) cl(disc_id)
qui: matrix A1 = (nullmat(A1),_b[log_arrest_rate_tot_15_18])
qui: matrix H1 = (nullmat(H1),e(N))

* % Dynamic Incapacitation Estimate
qui: matrix E1 = (nullmat(E1),`disc_b_young_18')
qui: matrix F1 = (nullmat(F1),`disc_b_old_18')
qui: matrix G1 = (nullmat(G1),100*(`disc_b_young_18'*(_b[log_arrest_rate_tot_15_18])/`disc_b_old_18'))

* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw=population_est_cell], a(c.log_pop##crime) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_log_arrest_rate_tot_15_18=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c1 = (nullmat(c1),r(CI))
qui: matrix B1 = (nullmat(B1),c1')
qui: matrix C1 = (nullmat(C1),r(p))

qui: distinct fstate
qui: matrix I1=r(ndistinct)
qui: distinct county_fips
qui: matrix J1=r(ndistinct)

drop r_*
restore


matrix T1=(A1\B1\C1\E1\F1\G1\H1\I1\J1)









*** Spec2 - Controls: Demographics

* Regression
reghdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##crime c.log_police##crime c.pop_share_black##crime c.pop_share_other##crime c.share_female_pop##crime) cl(disc_id)
qui: matrix A2 = (nullmat(A2),_b[log_arrest_rate_tot_15_18])
qui: matrix H2 = (nullmat(H2),e(N))

* % Dynamic Incapacitation Estimate
qui: matrix E2 = (nullmat(E2),`disc_b_young_18')
qui: matrix F2 = (nullmat(F2),`disc_b_old_18')
qui: matrix G2 = (nullmat(G2),100*(`disc_b_young_18'*(_b[log_arrest_rate_tot_15_18])/`disc_b_old_18'))

* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw=population_est_cell], a( c.log_pop##crime c.log_police##crime c.pop_share_black##crime c.pop_share_other##crime c.share_female_pop##crime) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_log_arrest_rate_tot_15_18=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c2 = (nullmat(c2),r(CI))
qui: matrix B2 = (nullmat(B2),c2')
qui: matrix C2 = (nullmat(C2),r(p))

qui: distinct fstate
qui: matrix I2=r(ndistinct)
qui: distinct county_fips
qui: matrix J2=r(ndistinct)

drop r_*
restore

matrix T2=(A2\B2\C2\E2\F2\G2\H2\I2\J2)












*** Spec3 - Controls: State FE

* Regression
reghdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##crime disc_id) cl(disc_id)
qui: matrix A3 = (nullmat(A3),_b[log_arrest_rate_tot_15_18])
qui: matrix H3 = (nullmat(H3),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E3 = (nullmat(E3),`disc_b_young_18')
qui: matrix F3 = (nullmat(F3),`disc_b_old_18')
qui: matrix G3 = (nullmat(G3),100*(`disc_b_young_18'*(_b[log_arrest_rate_tot_15_18])/`disc_b_old_18'))

* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw=population_est_cell], a( c.log_pop##crime disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_log_arrest_rate_tot_15_18=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c3 = (nullmat(c3),r(CI))
qui: matrix B3 = (nullmat(B3),c3')
qui: matrix C3 = (nullmat(C3),r(p))

qui: distinct fstate
qui: matrix I3=r(ndistinct)
qui: distinct county_fips
qui: matrix J3=r(ndistinct)

drop r_*
restore


matrix T3=(A3\B3\C3\E3\F3\G3\H3\I3\J3)










*** Spec4 - Controls: State FE + Demographics

* Regression
reghdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##crime c.log_police##crime c.pop_share_black##crime c.pop_share_other##crime c.share_female_pop##crime disc_id) cl(disc_id)
qui: matrix A4 = (nullmat(A4),_b[log_arrest_rate_tot_15_18])
qui: matrix H4 = (nullmat(H4),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E4 = (nullmat(E4),`disc_b_young_18')
qui: matrix F4 = (nullmat(F4),`disc_b_old_18')
qui: matrix G4 = (nullmat(G4),100*(`disc_b_young_18'*(_b[log_arrest_rate_tot_15_18])/`disc_b_old_18'))

* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw=population_est_cell], a(c.log_pop##crime c.log_police##crime c.pop_share_black##crime c.pop_share_other##crime c.share_female_pop##crime disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_log_arrest_rate_tot_15_18=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c4 = (nullmat(c4),r(CI))
qui: matrix B4 = (nullmat(B4),c4')
qui: matrix C4 = (nullmat(C4),r(p))

qui: distinct fstate
qui: matrix I4=r(ndistinct)
qui: distinct county_fips
qui: matrix J4=r(ndistinct)

drop r_*
restore


matrix T4=(A4\B4\C4\E4\F4\G4\H4\I4\J4)









*** Spec5 - Controls: State FE + Demographics*State FE

* Regression
reghdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) cl(disc_id)
qui: matrix A5 = (nullmat(A5),_b[log_arrest_rate_tot_15_18])
qui: matrix H5 = (nullmat(H5),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E5 = (nullmat(E5),`disc_b_young_18')
qui: matrix F5 = (nullmat(F5),`disc_b_old_18')
qui: matrix G5 = (nullmat(G5),100*(`disc_b_young_18'*(_b[log_arrest_rate_tot_15_18])/`disc_b_old_18'))

* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw=population_est_cell], a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_log_arrest_rate_tot_15_18=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c5 = (nullmat(c5),r(CI))
qui: matrix B5 = (nullmat(B5),c5')
qui: matrix C5 = (nullmat(C5),r(p))

qui: distinct fstate
qui: matrix I5=r(ndistinct)
qui: distinct county_fips
qui: matrix J5=r(ndistinct)

drop r_*
restore


matrix T5=(A5\B5\C5\E5\F5\G5\H5\I5\J5)





matrix T=(T1,T2,T3,T4,T5)

matrix colnames T = NoControls Dem StateFE StateFE+Dem StateFExDem 

matrix rownames T = Coefficient CI_l CI_u P-value Coef_Young Coef_Old DI_Ratio N_obs N_states N_county

matrix list T


log c