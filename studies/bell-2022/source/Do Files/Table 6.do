*** Directory ***
/* cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\" */


cap log c
log using "Do Files/Table6",replace t


************************************************************************

**********************          TABLE 6         ************************

************************************************************************


clear matrix
clear all
set more off



*******************            CPS ATTENDANCE          *************************


**********************       All States Sample       ***************************


clear all
set more off


use "Data/cps_attendance_all_states.dta", clear



*** Attendance

* Regression
qui:reghdfe school_hs i.disc1 i.disc2 i.disc3 if age<=18 [aw=weight], a(age year school_year hispanic black fstate month) cl(fstate) tol(1e-10) nocons
est tab, b se p stats(N)

* Weighted average effect across multiple discontinuities (using margins)
margins [aw=weight], post over(disc1)
qui: matrix b4 = (nullmat(b4),e(b))
qui: matrix A4 = (nullmat(A4),b4[1,2])
qui: matrix D4 = (nullmat(D4),e(N))
lincom [1.disc1]-[0.disc1]

* Get weights to construct the weighted average effect across multiple discontinuities and bootstrap the CI
preserve
qui: keep if age<=18
qui: sum disc1 [aw= weight] if disc1==1
qui: local wgt_disc1=r(mean)
qui: sum disc2 [aw= weight] if disc1==1
qui: local wgt_disc2=r(mean)
qui: sum disc3 [aw= weight] if disc1==1
qui: local wgt_disc3=r(mean)

* Bootstrap
qui: hdfe school_hs disc1 disc2 disc3 [aw=weight], a(age year school_year hispanic black fstate month) gen(r_) clustervars(fstate)
qui: reg r_* [aw=weight], cl(fstate) nocons
boottest  `wgt_disc1'*r_disc1+`wgt_disc2'*r_disc2+`wgt_disc3'*r_disc3=0, reps(9999) boottype(wild) cl(fstate) bootcluster(fstate) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c4 = (nullmat(c4),r(CI))
qui: matrix B4 = (nullmat(B4),c4')
qui: matrix C4 = (nullmat(C4),r(p))

qui: distinct fstate
qui: matrix E4=r(ndistinct)

drop r_*
restore


matrix T4=(A4\B4\C4\D4\E4)

matrix colnames T4 = All_States

matrix rownames T4 = Attendance CI_l CI_u P-value N_obs N_states

matrix list T4














********************     Pooled  Discontinuty Sample     ***********************


use "Data/cps_attendance_discontinuity_states.dta", clear



* Pre-Reform Mean
sum school_hs [aw=weight] if time>=-10 & time<=9 & disc==0 & (fstate!=48|new_max!=16) & age<=18



* 10 Year

* Regression
reghdfe school_hs disc [aw=weight] if time>=-10 & time<=9 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 , a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) cl(disc_id)
qui: matrix A1 = (nullmat(A1),_b[disc])
qui: matrix D1 = (nullmat(D1),e(N))

* Bootstrap
preserve
qui: keep if time>=-10 & time<=9 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 
qui: hdfe school_hs disc [aw=weight], a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=weight], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c1 = (nullmat(c1),r(CI))
qui: matrix B1 = (nullmat(B1),c1')
qui: matrix C1 = (nullmat(C1),r(p))

qui: distinct fstate
qui: matrix E1=r(ndistinct)

restore


matrix T1=(A1\B1\C1\D1\E1)




* 7 Year

* Regression
reghdfe school_hs disc [aw=weight] if time>=-7 & time<=6 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 , a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) cl(disc_id)
qui: matrix A2 = (nullmat(A2),_b[disc])
qui: matrix D2 = (nullmat(D2),e(N))

* Bootstrap
preserve
qui: keep if time>=-7 & time<=6 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 
qui: hdfe school_hs disc [aw=weight], a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=weight], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c2 = (nullmat(c2),r(CI))
qui: matrix B2 = (nullmat(B2),c2')
qui: matrix C2 = (nullmat(C2),r(p))

qui: distinct fstate
qui: matrix E2=r(ndistinct)

restore


matrix T2=(A2\B2\C2\D2\E2)




* 5 Year

* Regression
reghdfe school_hs disc [aw=weight] if time>=-5 & time<=4 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 , a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) cl(disc_id)
qui: matrix A3 = (nullmat(A3),_b[disc])
qui: matrix D3 = (nullmat(D3),e(N))
preserve

* Bootstrap
qui: keep if time>=-5 & time<=4 & (fstate!=48|new_max!=16) & old_max>=16 & age<=18 
qui: hdfe school_hs disc [aw=weight], a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id school_year#disc_id black#disc_id hispanic#disc_id month#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=weight], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c3 = (nullmat(c3),r(CI))
qui: matrix B3 = (nullmat(B3),c3')
qui: matrix C3 = (nullmat(C3),r(p))

qui: distinct fstate
qui: matrix E3=r(ndistinct)

restore

matrix T3=(A3\B3\C3\D3\E3)



*** Table 6 - Panel A

matrix T6=(T4,T1,T2,T3)

matrix colnames T6 = All_States 10-year 7-year 5-year

matrix rownames T6 = Coefficient CI_l CI_u P-value N_obs N_states


matrix list T6


*** EDITED by Ryan Steed
mat2txt, matrix(T6) saving("../results/Table6A.txt") replace

exit
***





























































































*****************          ACS - Dropout, Work, Wages        *******************


clear matrix
clear all
set more off


**********************       All States Sample       ***************************


use "Data/acs_all_states.dta", clear




*** DROPOUT

* Regression
qui:reghdfe edu_lths 1.disc1 1.disc2 1.disc3  [aw=perwt] if age>=19, a(age year hispanic black bpl) cl(bpl) tol(1e-10) nocons
est tab, b se p stats(N)

* Weighted average effect across multiple discontinuities (using margins)
margins [aw=perwt], post over(disc1)
qui: matrix b15 = (nullmat(b15),e(b))
qui: matrix A15 = (nullmat(A15),b15[1,2])
qui: matrix D15 = (nullmat(D15),e(N))
lincom [1.disc1]-[0.disc1]

* Get weights to construct the weighted average effect across multiple discontinuities and bootstrap the CI
preserve
qui: keep if age>=19
qui: sum disc1 [aw= perwt] if disc1==1
qui: local wgt_disc1=r(mean)
qui: sum disc2 [aw= perwt] if disc1==1
qui: local wgt_disc2=r(mean)
qui: sum disc3 [aw= perwt ] if disc1==1
qui: local wgt_disc3=r(mean)

* Bootstrap
qui: hdfe edu_lths disc1 disc2 disc3 [aw=perwt], a(age year hispanic black bpl) gen(r_) clustervars(bpl)
qui: reg r_* [aw=perwt], cl(bpl) nocons
boottest  `wgt_disc1'*r_disc1+`wgt_disc2'*r_disc2+`wgt_disc3'*r_disc3=0, reps(9999) boottype(wild) cl(bpl) bootcluster(bpl) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c15 = (nullmat(c15),r(CI))
qui: matrix B15 = (nullmat(B15),c15')
qui: matrix C15 = (nullmat(C15),r(p))

qui: distinct fstate
qui: matrix E15=r(ndistinct)



drop r_*
restore

matrix T15=(A15\B15\C15\D15\E15)









*** WORK OR SCHOOL

* Regression
qui:reghdfe school_or_work 1.disc1 1.disc2 1.disc3  [aw=perwt] if age>=19, a(age year hispanic black bpl) cl(bpl) tol(1e-10) nocons
est tab, b se p stats(N)

* Weighted average effect across multiple discontinuities (using margins)
margins [aw=perwt], post over(disc1)
qui: matrix b16 = (nullmat(b16),e(b))
qui: matrix A16 = (nullmat(A16),b16[1,2])
qui: matrix D16 = (nullmat(D16),e(N))
lincom [1.disc1]-[0.disc1]

* Get weights to construct the weighted average effect across multiple discontinuities and bootstrap the CI
preserve
qui: keep if age>=19
qui: sum disc1 [aw= perwt] if disc1==1
qui: local wgt_disc1=r(mean)
qui: sum disc2 [aw= perwt] if disc1==1
qui: local wgt_disc2=r(mean)
qui: sum disc3 [aw= perwt ] if disc1==1
qui: local wgt_disc3=r(mean)

* Bootstrap
qui: hdfe school_or_work disc1 disc2 disc3 [aw=perwt], a(age year hispanic black bpl) gen(r_) clustervars(bpl)
qui: reg r_* [aw=perwt], cl(bpl) nocons
boottest  `wgt_disc1'*r_disc1+`wgt_disc2'*r_disc2+`wgt_disc3'*r_disc3=0, reps(9999) boottype(wild) cl(bpl) bootcluster(bpl) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c16 = (nullmat(c16),r(CI))
qui: matrix B16 = (nullmat(B16),c16')
qui: matrix C16 = (nullmat(C16),r(p))

qui: distinct fstate
qui: matrix E16=r(ndistinct)


drop r_*
restore

matrix T16=(A16\B16\C16\D16\E16)







*** WAGES

* Regression
qui:reghdfe ln_wkwage 1.disc1 1.disc2 1.disc3  [aw=earn_weight] if age>=19 & earnsam==1, a(age year hispanic black bpl) cl(bpl) tol(1e-10) nocons
est tab, b se p stats(N)

* Weighted average effect across multiple discontinuities (using margins)
margins [aw=perwt], post over(disc1)
qui: matrix b17 = (nullmat(b17),e(b))
qui: matrix A17 = (nullmat(A17),b17[1,2])
qui: matrix D17 = (nullmat(D17),e(N))
lincom [1.disc1]-[0.disc1]

* Get weights to construct the weighted average effect across multiple discontinuities and bootstrap the CI
preserve
qui: keep if age>=19 & earnsam==1
qui: sum disc1 [aw= earn_weight] if disc1==1
qui: local wgt_disc1=r(mean)
qui: sum disc2 [aw= earn_weight] if disc1==1
qui: local wgt_disc2=r(mean)
qui: sum disc3 [aw= earn_weight] if disc1==1
qui: local wgt_disc3=r(mean)

* Bootstrap
qui: hdfe ln_wkwage disc1 disc2 disc3 [aw=earn_weight], a(age year hispanic black bpl) gen(r_) clustervars(bpl)
qui: reg r_* [aw=earn_weight], cl(bpl) nocons
boottest  `wgt_disc1'*r_disc1+`wgt_disc2'*r_disc2+`wgt_disc3'*r_disc3=0, reps(9999) boottype(wild) cl(bpl) bootcluster(bpl) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c17 = (nullmat(c17),r(CI))
qui: matrix B17 = (nullmat(B17),c17')
qui: matrix C17 = (nullmat(C17),r(p))

qui: distinct fstate
qui: matrix E17=r(ndistinct)


drop r_*
restore

matrix T17=(A17\B17\C17\D17\E17)





matrix T6_1=(T15\T16\T17)

































********************     Pooled  Discontinuty Sample     ***********************

clear

use "Data/acs_discontinuity_states.dta", clear


* Pre-Reform Mean
sum edu_lths school_or_work [aw=perwt] if disc==0 & age>=19 & (fstate!=48|new_max!=16)

sum ln_wkwage [aw=earn_weight] if disc==0 & age>=19 & (fstate!=48|new_max!=16)




*** DROPOUT

* 10 Year

* Regression
reghdfe edu_lths disc [pw=perwt] if age>=19 & (fstate!=48|new_max!=16) & time>=-10 & time<=9 , a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A1 = (nullmat(A1),_b[disc])
matrix D1 = (nullmat(D1),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-10 & time<=9  
qui: hdfe edu_lths disc [pw=perwt], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=perwt], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c1 = (nullmat(c1),r(CI))
qui: matrix B1 = (nullmat(B1),c1')
qui: matrix C1 = (nullmat(C1),r(p))

qui: distinct fstate
qui: matrix E1=r(ndistinct)

restore

matrix T1=(A1\B1\C1\D1\E1)



* 7 Year

* Regression
reghdfe edu_lths disc [pw=perwt] if age>=19 & (fstate!=48|new_max!=16) & time>=-7 & time<=6  , a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A2 = (nullmat(A2),_b[disc])
matrix D2 = (nullmat(D2),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-7 & time<=6  
qui: hdfe edu_lths disc [pw=perwt], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=perwt], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c2 = (nullmat(c2),r(CI))
qui: matrix B2 = (nullmat(B2),c2')
qui: matrix C2 = (nullmat(C2),r(p))

qui: distinct fstate
qui: matrix E2=r(ndistinct)

restore

matrix T2=(A2\B2\C2\D2\E2)



* 5 Year

* Regression
reghdfe edu_lths disc [pw=perwt] if age>=19 & (fstate!=48|new_max!=16) & time>=-5 & time<=4  , a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A3 = (nullmat(A3),_b[disc])
matrix D3 = (nullmat(D3),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-5 & time<=4  
qui: hdfe edu_lths disc [pw=perwt], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=perwt], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c3 = (nullmat(c3),r(CI))
qui: matrix B3 = (nullmat(B3),c3')
qui: matrix C3 = (nullmat(C3),r(p))

qui: distinct fstate
qui: matrix E3=r(ndistinct)

restore

matrix T3=(A3\B3\C3\D3\E3)


matrix T6_2=(T1,T2,T3)








*** WORK OR SCHOOL

* 10 Year

* Regression
reghdfe school_or_work disc [pw=perwt] if age>=19 & (fstate!=48|new_max!=16) & time>=-10 & time<=9  , a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A7 = (nullmat(A7),_b[disc])
matrix D7 = (nullmat(D7),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-10 & time<=9  
qui: hdfe school_or_work disc [pw=perwt], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=perwt], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c7 = (nullmat(c7),r(CI))
qui: matrix B7 = (nullmat(B7),c7')
qui: matrix C7 = (nullmat(C7),r(p))

qui: distinct fstate
qui: matrix E7=r(ndistinct)

restore

matrix T7=(A7\B7\C7\D7\E7)



* 7 Year

* Regression
reghdfe school_or_work disc [pw=perwt] if age>=19 & (fstate!=48|new_max!=16) & time>=-7 & time<=6  , a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A8 = (nullmat(A8),_b[disc])
matrix D8 = (nullmat(D8),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-7 & time<=6  
qui: hdfe school_or_work disc [pw=perwt], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=perwt], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c8 = (nullmat(c8),r(CI))
qui: matrix B8 = (nullmat(B8),c8')
qui: matrix C8 = (nullmat(C8),r(p))

qui: distinct fstate
qui: matrix E8=r(ndistinct)

restore

matrix T8=(A8\B8\C8\D8\E8)



* 5 Year

* Regression
reghdfe school_or_work disc [pw=perwt] if age>=19 & (fstate!=48|new_max!=16) & time>=-5 & time<=4  , a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A9 = (nullmat(A9),_b[disc])
matrix D9 = (nullmat(D9),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-5 & time<=4  
qui: hdfe school_or_work disc [pw=perwt], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=perwt], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c9 = (nullmat(c9),r(CI))
qui: matrix B9 = (nullmat(B9),c9')
qui: matrix C9 = (nullmat(C9),r(p))

qui: distinct fstate
qui: matrix E9=r(ndistinct)

restore

matrix T9=(A9\B9\C9\D9\E9)

matrix T6_4=(T7,T8,T9)









*** WAGES

* 10 Year

* Regression
reghdfe ln_wkwage disc [pw=earn_weight] if age>=19 & (fstate!=48|new_max!=16) & time>=-10 & time<=9 & earnsam==1  , a(c.time#disc#disc_id c.time#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A10 = (nullmat(A10),_b[disc])
matrix D10 = (nullmat(D10),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-10 & time<=9 & earnsam==1  
qui: hdfe ln_wkwage disc [pw=earn_weight], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=earn_weight], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c10 = (nullmat(c10),r(CI))
qui: matrix B10 = (nullmat(B10),c10')
qui: matrix C10 = (nullmat(C10),r(p))

qui: distinct fstate
qui: matrix E10=r(ndistinct)

restore

matrix T10=(A10\B10\C10\D10\E10)



* 7 Year

* Regression
reghdfe ln_wkwage disc [pw=earn_weight] if age>=19 & (fstate!=48|new_max!=16) & time>=-7 & time<=6 & earnsam==1  , a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A11 = (nullmat(A11),_b[disc])
matrix D11 = (nullmat(D11),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-7 & time<=6 & earnsam==1  
qui: hdfe ln_wkwage disc [pw=earn_weight], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=earn_weight], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c11 = (nullmat(c11),r(CI))
qui: matrix B11 = (nullmat(B11),c11')
qui: matrix C11 = (nullmat(C11),r(p))

qui: distinct fstate
qui: matrix E11=r(ndistinct)

restore

matrix T11=(A11\B11\C11\D11\E11)



* 5 Year

* Regression
reghdfe ln_wkwage disc [pw=earn_weight] if age>=19 & (fstate!=48|new_max!=16) & time>=-5 & time<=4 & earnsam==1  , a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) cl(disc_id) nocons
matrix A12 = (nullmat(A12),_b[disc])
matrix D12 = (nullmat(D12),e(N))

* Bootstrap
preserve
qui: keep if age>=19 & (fstate!=48|new_max!=16) & time>=-5 & time<=4 & earnsam==1  
qui: hdfe ln_wkwage disc [pw=earn_weight], a(c.time#disc#disc_id age#disc_id year#disc_id black#disc_id hispanic#disc_id) gen(r_) clustervars(disc_id)
qui: reg r_* [pw=earn_weight], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c12 = (nullmat(c12),r(CI))
qui: matrix B12 = (nullmat(B12),c12')
qui: matrix C12 = (nullmat(C12),r(p))

qui: distinct fstate
qui: matrix E12=r(ndistinct)

restore

matrix T12=(A12\B12\C12\D12\E12)

matrix T6_5=(T10,T11,T12)









*** Table 6 - Panels B to D

matrix T6_6=(T6_2\T6_4\T6_5)
matrix T6_7=(T6_1,T6_6)

matrix colnames T6_7 = All 10_year 7_year 5_year

matrix rownames T6_7 = edu_lths CI_l CI_u P-value N_obs N_states school_work CI_l CI_u P-value N_obs N_states ln_wkwage CI_l CI_u P-value N_obs N_states 

matrix list T6_7




log c