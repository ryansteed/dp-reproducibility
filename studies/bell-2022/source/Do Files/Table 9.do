*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"


cap log c
log using "Do Files\Table9",replace t


************************************************************************

**********************          TABLE 9         ************************

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












*** Get Log Arrest Rate Variables by Crime Type


bysort disc_id fcounty cohort (crime): gen log_arrest_rate_vio_15_18= log_arrest_rate_15_18[1]
bysort disc_id fcounty cohort (crime): gen log_arrest_rate_prop_15_18= log_arrest_rate_15_18[2]
bysort disc_id fcounty cohort (crime): gen log_arrest_rate_drug_15_18= log_arrest_rate_15_18[3]

bysort disc_id fcounty cohort (crime): gen log_arrest_rate_vio_18_24= log_arrest_rate_18_24[1]
bysort disc_id fcounty cohort (crime): gen log_arrest_rate_prop_18_24= log_arrest_rate_18_24[2]
bysort disc_id fcounty cohort (crime): gen log_arrest_rate_drug_18_24= log_arrest_rate_18_24[3]

















*** State Dependence Violent Crime Decompoing in Crime Types


* Regression
reghdfe log_arrest_rate_vio_18_24 log_arrest_rate_vio_15_18 log_arrest_rate_prop_15_18 log_arrest_rate_drug_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id ) cl(disc_id)
qui: matrix A7 = (nullmat(A7),_b[log_arrest_rate_vio_15_18],_b[log_arrest_rate_prop_15_18],_b[log_arrest_rate_drug_15_18])
qui: matrix H7 = (nullmat(H7),e(N),e(N),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E7 = (nullmat(E7),`disc_b_young_vio_18',`disc_b_young_vio_18',`disc_b_young_vio_18')
qui: matrix F7 = (nullmat(F7),`disc_b_old_vio_18',`disc_b_old_vio_18',`disc_b_old_vio_18')
qui: matrix G7 = (nullmat(G7),	(100*`disc_b_young_vio_18'*(_b[log_arrest_rate_vio_15_18])/`disc_b_old_vio_18'), ///
								(100*`disc_b_young_prop_18'*(_b[log_arrest_rate_prop_15_18])/`disc_b_old_vio_18'), ///
								(100*`disc_b_young_drug_18'*(_b[log_arrest_rate_drug_15_18])/`disc_b_old_vio_18'))

* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_vio_18_24 log_arrest_rate_vio_15_18 log_arrest_rate_prop_15_18 log_arrest_rate_drug_15_18 [aw=population_est_cell], a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest {r_log_arrest_rate_vio_15_18} {r_log_arrest_rate_prop_15_18} {r_log_arrest_rate_drug_15_18}, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)

forvalues k=1/3 {
matrix c7_`k' = (nullmat(c7),r(CI_`k'))
matrix B7=(nullmat(B7),c7_`k'')
matrix C7=(nullmat(C7),r(p_`k'))
}


qui: distinct fstate
qui: matrix I7=(nullmat(I7),r(ndistinct),r(ndistinct),r(ndistinct))
qui: distinct county_fips
qui: matrix J7=(nullmat(J7),r(ndistinct),r(ndistinct),r(ndistinct))

drop r_*
restore




matrix T7=(A7\B7\C7\E7\F7\G7\H7\I7\J7)

matrix colnames T7 = rho_vio rho_prop rho_drug

matrix rownames T7 = Coefficient CI_l CI_u P-value Coef_Young Coef_Old Ratio N_obs N_states N_county

* Column (1)
matrix list T7
















*** State Dependence Property Crime Decompoing in Crime Types



* Regression
reghdfe log_arrest_rate_prop_18_24 log_arrest_rate_vio_15_18 log_arrest_rate_prop_15_18 log_arrest_rate_drug_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id ) cl(disc_id)
qui: matrix A8 = (nullmat(A8),_b[log_arrest_rate_vio_15_18],_b[log_arrest_rate_prop_15_18],_b[log_arrest_rate_drug_15_18])
qui: matrix H8 = (nullmat(H8),e(N),e(N),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E8 = (nullmat(E8),`disc_b_young_prop_18',`disc_b_young_prop_18',`disc_b_young_prop_18')
qui: matrix F8 = (nullmat(F8),`disc_b_old_prop_18',`disc_b_old_prop_18',`disc_b_old_prop_18')
qui: matrix G8 = (nullmat(G8),	(100*`disc_b_young_vio_18'*(_b[log_arrest_rate_vio_15_18])/`disc_b_old_prop_18' ), ///
								(100*`disc_b_young_prop_18'*(_b[log_arrest_rate_prop_15_18])/`disc_b_old_prop_18' ), ///
								(100*`disc_b_young_drug_18'*(_b[log_arrest_rate_drug_15_18])/`disc_b_old_prop_18' ))


* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_prop_18_24 log_arrest_rate_vio_15_18 log_arrest_rate_prop_15_18 log_arrest_rate_drug_15_18 [aw=population_est_cell], a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest {r_log_arrest_rate_vio_15_18} {r_log_arrest_rate_prop_15_18} {r_log_arrest_rate_drug_15_18}, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)

forvalues k=1/3 {
matrix c8_`k' = (nullmat(c8),r(CI_`k'))
matrix B8=(nullmat(B8),c8_`k'')
matrix C8=(nullmat(C8),r(p_`k'))
}


qui: distinct fstate
qui: matrix I8=(nullmat(I8),r(ndistinct),r(ndistinct),r(ndistinct))
qui: distinct county_fips
qui: matrix J8=(nullmat(J8),r(ndistinct),r(ndistinct),r(ndistinct))

drop r_*
restore




matrix T8=(A8\B8\C8\E8\F8\G8\H8\I8\J8)

matrix colnames T8 = rho_vio rho_prop rho_drug

matrix rownames T8 = Coefficient CI_l CI_u P-value Coef_Young Coef_Old Ratio N_obs N_states N_county

* Column (2)
matrix list T8


















*** State Dependence Drug Crime Decompoing in Crime Types



* Regression
reghdfe log_arrest_rate_drug_18_24 log_arrest_rate_vio_15_18 log_arrest_rate_prop_15_18 log_arrest_rate_drug_15_18 [aw= population_est_cell ] if crime==1 & disc==0 , a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id ) cl(disc_id)
qui: matrix A9 = (nullmat(A9),_b[log_arrest_rate_vio_15_18],_b[log_arrest_rate_prop_15_18],_b[log_arrest_rate_drug_15_18])
qui: matrix H9 = (nullmat(H9),e(N),e(N),e(N))


* % Dynamic Incapacitation Estimate
qui: matrix E9 = (nullmat(E9),`disc_b_young_drug_18',`disc_b_young_drug_18',`disc_b_young_drug_18')
qui: matrix F9 = (nullmat(F9),`disc_b_old_drug_18',`disc_b_old_drug_18',`disc_b_old_drug_18')
qui: matrix G9 = (nullmat(G9),	(100*`disc_b_young_vio_18'*(_b[log_arrest_rate_vio_15_18])/`disc_b_old_drug_18'), ///
								(100*`disc_b_young_prop_18'*(_b[log_arrest_rate_prop_15_18])/`disc_b_old_drug_18'), ///
								(100*`disc_b_young_drug_18'*(_b[log_arrest_rate_drug_15_18])/`disc_b_old_drug_18'))

* Bootstrap
preserve
qui: keep if crime==1 & disc==0 
qui: hdfe log_arrest_rate_drug_18_24 log_arrest_rate_vio_15_18 log_arrest_rate_prop_15_18 log_arrest_rate_drug_15_18 [aw=population_est_cell], a( c.log_pop##(disc_id) c.log_police##(disc_id) c.pop_share_black##(disc_id) c.pop_share_other##(disc_id) c.share_female_pop##(disc_id) disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest {r_log_arrest_rate_vio_15_18} {r_log_arrest_rate_prop_15_18} {r_log_arrest_rate_drug_15_18}, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)

forvalues k=1/3 {
matrix c9_`k' = (nullmat(c9),r(CI_`k'))
matrix B9=(nullmat(B9),c9_`k'')
matrix C9=(nullmat(C9),r(p_`k'))
}


qui: distinct fstate
qui: matrix I9=(nullmat(I9),r(ndistinct),r(ndistinct),r(ndistinct))
qui: distinct county_fips
qui: matrix J9=(nullmat(J9),r(ndistinct),r(ndistinct),r(ndistinct))

drop r_*
restore




matrix T9=(A9\B9\C9\E9\F9\G9\H9\I9\J9)

matrix colnames T9 = rho_vio rho_prop rho_drug

matrix rownames T9 = Coefficient CI_l CI_u P-value Coef_Young Coef_Old Ratio N_obs N_states N_county



* Column (3)
matrix list T9


log c