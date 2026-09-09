*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"

cap log c
log using "Do Files\Table4",replace t

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


gen teen=(age<=18)








*TOTAL - COLUMN (1)

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


reghdfe log_arrest_rate_tot disc [aw=population_est_cell] if  crime==1  & age<=18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
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








*VIOLENT - COLUMN (2)

reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==1 , a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A4 = (nullmat(A4),_b[disc])
qui: matrix D4 = (nullmat(D4),e(N))
preserve
qui: keep if   crime==1 
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
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


reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==1  & age<=18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A5 = (nullmat(A5),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age<=18
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c5 = (nullmat(c5),r(CI))
qui: matrix B5 = (nullmat(B5),c5')
qui: matrix C5 = (nullmat(C5),r(p))
drop r_*
restore

matrix T5=(A5\B5\C5\D4\E4\F4)

reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==1  & age>18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A6 = (nullmat(A6),_b[disc])
// qui: matrix D = (nullmat(D),e(N))
preserve
qui: keep if   crime==1  & age>18
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c6 = (nullmat(c6),r(CI))
qui: matrix B6 = (nullmat(B6),c6')
qui: matrix C6 = (nullmat(C6),r(p))
drop r_*
restore

matrix T6=(A6\B6\C6\D4\E4\F4)


matrix TA2=(T4\T5\T6)









*PROPERTY - COLUMN (3)

reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==2 , a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A7 = (nullmat(A7),_b[disc])
qui: matrix D7 = (nullmat(D7),e(N))
preserve
qui: keep if   crime==2 
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
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


reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==2  & age<=18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A8 = (nullmat(A8),_b[disc])
// qui: matrix D3 = (nullmat(D3),e(N))
preserve
qui: keep if   crime==2  & age<=18
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c8 = (nullmat(c8),r(CI))
qui: matrix B8 = (nullmat(B8),c8')
qui: matrix C8 = (nullmat(C8),r(p))
drop r_*
restore

matrix T8=(A8\B8\C8\D7\E7\F7)
 
 
reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==2  & age>18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A9 = (nullmat(A9),_b[disc])
// qui: matrix D3 = (nullmat(D3),e(N))
preserve
qui: keep if   crime==2  & age>18
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c9 = (nullmat(c9),r(CI))
qui: matrix B9 = (nullmat(B9),c9')
qui: matrix C9 = (nullmat(C9),r(p))
drop r_*
restore

matrix T9=(A9\B9\C9\D7\E7\F7)


matrix TA3=(T7\T8\T9)













*DRUGS - COLUMN (4)

reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==3 , a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A10 = (nullmat(A10),_b[disc])
qui: matrix D10 = (nullmat(D10),e(N))
preserve
qui: keep if   crime==3 
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c10 = (nullmat(c10),r(CI))
qui: matrix B10 = (nullmat(B10),c10')
qui: matrix C10 = (nullmat(C10),r(p))
drop r_*

qui: distinct fstate
qui: matrix E10=r(ndistinct)
qui: distinct county_fips
qui: matrix F10=r(ndistinct)

restore

matrix T10=(A10\B10\C10\D10\E10\F10)



reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==3  & age<=18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A11 = (nullmat(A11),_b[disc])
// qui: matrix D4 = (nullmat(D4),e(N))
preserve
qui: keep if  crime==3  & age<=18
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c11 = (nullmat(c11),r(CI))
qui: matrix B11 = (nullmat(B11),c11')
qui: matrix C11 = (nullmat(C11),r(p))
drop r_*
restore

matrix T11=(A11\B11\C11\D10\E10\F10)



reghdfe log_arrest_rate disc [aw=population_est_cell] if  crime==3  & age>18, a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age)   cl(disc_id)  nocons
qui: matrix A12 = (nullmat(A12),_b[disc])
// qui: matrix D4 = (nullmat(D4),e(N))
preserve
qui: keep if   crime==3  & age>18
qui: hdfe log_arrest_rate disc [aw=population_est_cell], a(c.time#disc#disc_id c.time#disc_id  (disc_id)##c.log_police (disc_id)##c.log_pop (disc_id)##c.pop_share_black (disc_id)##c.share_female_pop (disc_id)##c.pop_share_other year#disc_id fcounty#disc_id disc_id#age) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c12 = (nullmat(c12),r(CI))
qui: matrix B12 = (nullmat(B12),c12')
qui: matrix C12 = (nullmat(C12),r(p))
drop r_*
restore

matrix T12=(A12\B12\C12\D10\E10\F10)


matrix TA4=(T10\T11\T12)















matrix T=(TA1,TA2,TA3,TA4)

matrix colnames T = All Violent Property Drugs 

matrix rownames T = Coefficient CI_l CI_u P-value N_obs N_states N_counties Coefficient CI_l CI_u P-value N_obs N_states N_counties Coefficient CI_l CI_u P-value N_obs N_states N_counties

matrix list T



log c