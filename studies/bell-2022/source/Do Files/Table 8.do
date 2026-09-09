*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"


cap log c
log using "Do Files\Table8",replace t


************************************************************************

**********************          TABLE 8         ************************

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


 



***  State Dependence Total Crime By Reform Types (Below 18, Up to 18)




* Test Discontinuity Effect across Reform Type


* Reform Types
gen reform_type2=.
replace reform_type2=1 if (fstate!=48|new_max!=16) & new_max<18
replace reform_type2=2 if (fstate!=48|new_max!=16) & new_max==18










*** All

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



















***   Below 18

* Regression
reghdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw= population_est_cell ] if crime==1 & disc==0  & reform_type2==1, a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) cl(disc_id)
qui: matrix A15 = (nullmat(A15),_b[log_arrest_rate_tot_15_18])
qui: matrix H15 = (nullmat(H15),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E15 = (nullmat(E15),`disc_b_young_below18')
qui: matrix F15 = (nullmat(F15),`disc_b_old_below18')
qui: matrix G15 = (nullmat(G15),100*(`disc_b_young_below18'*(_b[log_arrest_rate_tot_15_18])/`disc_b_old_below18'))


* Bootstrap
preserve
qui: keep if crime==1 & disc==0   & reform_type2==1
qui: hdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw=population_est_cell], a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_log_arrest_rate_tot_15_18=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c15 = (nullmat(c15),r(CI))
qui: matrix B15 = (nullmat(B15),c15')
qui: matrix C15 = (nullmat(C15),r(p))

qui: distinct fstate
qui: matrix I15=r(ndistinct)
qui: distinct county_fips
qui: matrix J15=r(ndistinct)

drop r_*
restore


matrix T15=(A15\B15\C15\E15\F15\G15\H15\I15\J15)
















***   Up to 18

* Regression
reghdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw= population_est_cell ] if crime==1 & disc==0  & reform_type2==2, a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) cl(disc_id)
qui: matrix A16 = (nullmat(A16),_b[log_arrest_rate_tot_15_18])
qui: matrix H16 = (nullmat(H16),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E16 = (nullmat(E16),`disc_b_young_above18')
qui: matrix F16 = (nullmat(F16),`disc_b_old_above18')
qui: matrix G16 = (nullmat(G16),100*(`disc_b_young_above18'*(_b[log_arrest_rate_tot_15_18])/`disc_b_old_above18'))


* Bootstrap
preserve
qui: keep if crime==1 & disc==0   & reform_type2==2
qui: hdfe log_arrest_rate_tot_18_24 log_arrest_rate_tot_15_18 [aw=population_est_cell], a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_log_arrest_rate_tot_15_18=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c16 = (nullmat(c16),r(CI))
qui: matrix B16 = (nullmat(B16),c16')
qui: matrix C16 = (nullmat(C16),r(p))

qui: distinct fstate
qui: matrix I16=r(ndistinct)
qui: distinct county_fips
qui: matrix J16=r(ndistinct)

drop r_*
restore


matrix T16=(A16\B16\C16\E16\F16\G16\H16\I16\J16)



matrix T17=(T5,T15,T16)

matrix colnames T17 = All <18 >=18 

matrix rownames T17 = Coefficient CI_l CI_u P-value Coef_Young Coef_Old Ratio N_obs N_states N_county

matrix list T17



clear matrix



log c