*** Directory ***
/* cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\" */


cap log c
log using "Do Files/Table3",replace t


************************************************************************

******************           TABLE 3              **********************

************************************************************************

clear all
set more off


*** Choose Exclude Fall
local nofall=1



********************     Pooled  Discontinuty Sample     ***********************

use "Data/arrest_data_discontinuity_states.dta", clear 



*** Drop Texas (1985) CSL 
gen fall=(old_max>new_max)


if `nofall'==1 {
drop if fall==1
}



keep if time>=-5 & time<=4
gen teen=(age<=18)


keep if crime==1


* Reform Types
gen reform_type2=.
replace reform_type2=1 if (fstate!=48|new_max!=16) & new_max<18 /* New Age < 18 */
replace reform_type2=2 if (fstate!=48|new_max!=16) & new_max==18 /* New Age = 18 */






* ALL REFORMS - COLUMN (1)

reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1 , a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A1 = (nullmat(A1),_b[disc])
qui: matrix D1 = (nullmat(D1),e(N))
preserve
qui: keep if   crime==1 
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c1 = (nullmat(c1),r(CI))
qui: matrix B1 = (nullmat(B1),c1')
qui: matrix C1 = (nullmat(C1),r(p))
drop r_*

qui: distinct fstate
qui: matrix E1=r(ndistinct)
qui: distinct county_fips
qui: matrix F1=r(ndistinct)

restore

matrix T1=(A1\B1\C1\D1\E1\F1)


reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if crime==1  & age<=18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A2 = (nullmat(A2),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age<=18
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c2 = (nullmat(c2),r(CI))
qui: matrix B2 = (nullmat(B2),c2')
qui: matrix C2 = (nullmat(C2),r(p))
drop r_*
restore

matrix T2=(A2\B2\C2\D1\E1\F1)


reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1  & age>18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A3 = (nullmat(A3),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age>18
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c3 = (nullmat(c3),r(CI))
qui: matrix B3 = (nullmat(B3),c3')
qui: matrix C3 = (nullmat(C3),r(p))
drop r_*
restore

matrix T3=(A3\B3\C3\D1\E1\F1)


matrix TA1=(T1\T2\T3)

*** EDITED by Ryan Steed
matrix T31=(T1, T2, T3)
matrix colnames T31 = All <18 >=18 
matrix rownames T31 = Coefficient CI_l CI_u P-value N_obs N_states N_counties
matrix list T31
mat2txt, matrix(T31) saving("../results/Table3.txt") replace

exit
***
















* REFORMS BELOW <18  - COLUMN (2)

reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1 & reform_type2==1, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A4 = (nullmat(A4),_b[disc])
qui: matrix D4 = (nullmat(D4),e(N))
preserve
qui: keep if   crime==1 & reform_type2==1
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
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

restore

matrix T4=(A4\B4\C4\D4\E4\F4)


reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if crime==1  & age<=18 & reform_type2==1, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A5 = (nullmat(A5),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age<=18  & reform_type2==1
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c5 = (nullmat(c5),r(CI))
qui: matrix B5 = (nullmat(B5),c5')
qui: matrix C5 = (nullmat(C5),r(p))
drop r_*
restore

matrix T5=(A5\B5\C5\D4\E4\F4)


reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1  & age>18 & reform_type2==1, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A6 = (nullmat(A6),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age>18 & reform_type2==1
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c6 = (nullmat(c6),r(CI))
qui: matrix B6 = (nullmat(B6),c6')
qui: matrix C6 = (nullmat(C6),r(p))
drop r_*
restore

matrix T6=(A6\B6\C6\D4\E4\F4)





matrix TA2=(T4\T5\T6)



















* REFORMS UP TO >=18  - COLUMN (3)

reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1 & reform_type2==2, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A7 = (nullmat(A7),_b[disc])
qui: matrix D7 = (nullmat(D7),e(N))
preserve
qui: keep if   crime==1  & reform_type2==2
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c7 = (nullmat(c7),r(CI))
qui: matrix B7 = (nullmat(B7),c7')
qui: matrix C7 = (nullmat(C7),r(p))
drop r_*

qui: distinct fstate
qui: matrix E7=r(ndistinct)
qui: distinct county_fips
qui: matrix F7=r(ndistinct)

restore

matrix T7=(A7\B7\C7\D7\E7\F7)


reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if crime==1  & age<=18 & reform_type2==2, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A8 = (nullmat(A8),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age<=18  & reform_type2==2
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c8 = (nullmat(c8),r(CI))
qui: matrix B8 = (nullmat(B8),c8')
qui: matrix C8 = (nullmat(C8),r(p))
drop r_*
restore

matrix T8=(A8\B8\C8\D7\E7\F7)


reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1  & age>18 & reform_type2==2, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A9 = (nullmat(A9),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age>18 & reform_type2==2
qui: hdfe log_arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c9 = (nullmat(c9),r(CI))
qui: matrix B9 = (nullmat(B9),c9')
qui: matrix C9 = (nullmat(C9),r(p))
drop r_*
restore

matrix T9=(A9\B9\C9\D7\E7\F7)





matrix TA3=(T7\T8\T9)








matrix T=(TA1,TA2,TA3)

matrix colnames T = All <18 >=18 

matrix rownames T = Coefficient CI_l CI_u P-value N_obs N_states N_counties Coefficient CI_l CI_u P-value N_obs N_states N_counties Coefficient CI_l CI_u P-value N_obs N_states N_counties

matrix list T















*** Test Coefficient (2)=(3)


* All Ages

reghdfe log_arrest_rate_tot 1.disc#ib0.reform_type2 [aw=population_est_cell] if reform_type2!=. & crime==1 , a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
preserve
qui: keep  if reform_type2!=. & crime==1 
qui: hdfe log_arrest_rate_tot 1.disc#ib0.reform_type2 [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl() nocons
boottest (r___1__disc_X_1__reform_type2=r___1__disc_X_2__reform_type2), reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
drop r_*
restore





* <= Incapacitation Age


reghdfe log_arrest_rate_tot 1.disc#ib0.reform_type2 [aw=population_est_cell] if reform_type2!=. & crime==1  & age<=18 , a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
preserve
qui: keep  if reform_type2!=. & crime==1  & age<=18
qui: hdfe log_arrest_rate_tot 1.disc#ib0.reform_type2 [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl() nocons
boottest (r___1__disc_X_1__reform_type2=r___1__disc_X_2__reform_type2), reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
drop r_*
restore








* > Incapacitation Age


reghdfe log_arrest_rate_tot 1.disc#ib0.reform_type2 [aw=population_est_cell] if reform_type2!=. & crime==1  & age>18 , a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) cl(disc_id)  nocons
preserve
qui: keep  if reform_type2!=. & crime==1  & age>18
qui: hdfe log_arrest_rate_tot 1.disc#ib0.reform_type2 [aw=population_est_cell], a(c.time#disc#disc_id (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl() nocons
boottest (r___1__disc_X_1__reform_type=r___1__disc_X_2__reform_type2), reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
drop r_*
restore



log c