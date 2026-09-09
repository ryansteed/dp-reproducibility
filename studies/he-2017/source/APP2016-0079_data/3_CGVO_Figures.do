*=====================================================================================================* 
* Project: CGVO and Rural Development in China                                                        *
* Date:   December 2016                                                               	              *
* Please contact Guojun He (gjhe@ust.hk) for any coding errors                           	          * 
*=====================================================================================================* 

*** Change to your own directories ***
global path C:\Users\pcadmin\Dropbox\Projects\Village_Officials\AEJ-Acceptance\Data_and_Codes\Data
global result C:\Users\pcadmin\Dropbox\Projects\Village_Officials\AEJ-Acceptance\Data_and_Codes\Results
global graph C:\Users\pcadmin\Dropbox\Projects\Village_Officials\AEJ-Acceptance\Data_and_Codes\Graphs




use $path/workfile_AEJ, clear

** Figure 1. Share of villages with CGVO
gen cgvo_share = . 

tab t0 cgvo if t0==1
replace cgvo_share = 1/234 if t0== 1 

tab t1 cgvo if t1==1
replace cgvo_share = 1/232 if t1== 1 

tab t2 cgvo if t2==1
replace cgvo_share = 1/246 if t2== 1 

tab t3 cgvo if t3==1
replace cgvo_share = 1/246 if t3== 1 

tab t4 cgvo if t4==1
replace cgvo_share = 3/247 if t4== 1 

tab t5 cgvo if t5==1
replace cgvo_share = 3/251 if t5== 1 

tab t6 cgvo if t6==1
replace cgvo_share = 3/242 if t6== 1 

tab t7 cgvo if t7==1
replace cgvo_share = 14/222 if t7== 1 

tab t8 cgvo if t8==1
replace cgvo_share = 40/224 if t8== 1 

tab t9 cgvo if t9==1
replace cgvo_share = 60/228 if t9== 1 

tab t10 cgvo if t10==1
replace cgvo_share = 71/234 if t10== 1 

tab t11 cgvo if t11==1
replace cgvo_share = 60/202 if t11== 1 


*** Figure 1. Share of Villages with CGVO
preserve
keep if village_id ==1 
scatter cgvo_share year, c(l) xtitle("Year") ytitle("Share of Villages with CGVOs") scheme(sj) graphregion(color(white) icolor(white) fcolor(white)) saving($graph/CGVO_share, replace)
graph export $graph/CGVO_share.png, replace
restore 



*** Figure 2. Pre-trends Tests
eststo: quietly xi: reg l_subsidy_rate i.v_id i.year Lead_D4_plus Lead_D3 Lead_D2 D0 Lag_D1 Lag_D2 Lag_D3_plus, cluster(v_id)
plotbeta Lead_D4_plus | Lead_D3 | Lead_D2 | D0  | Lag_D1| Lag_D2 | Lag_D3_plus, ///
		vertical level(90) xlab(1 "≤ -4" 2 "-3" 3 "-2" 4 "0" 5 "1" 6 "2" 7 "≥ 3", labsize(medsmall) labcolor(black) axis(1)) ///
		subtitle("Panel A. Effect on Subsidized Population") xlab(none, axis(2)) xtitle("") ytitle("Estimated Coefficients") yline(0, lp(dash)) xline(3.5, lp(dash)) scheme(s1mono)
graph save $graph/trend_l_subsidy_rate, replace 

eststo: quietly xi: reg l_poor_housing_rate i.v_id i.year Lead_D4_plus Lead_D3 Lead_D2 D0 Lag_D1 Lag_D2 Lag_D3_plus, cluster(v_id)
plotbeta Lead_D4_plus | Lead_D3 | Lead_D2 | D0  | Lag_D1| Lag_D2 | Lag_D3_plus, ///
		vertical level(90) xlab(1 "≤ -4" 2 "-3" 3 "-2" 4 "0" 5 "1" 6 "2" 7 "≥ 3", labsize(medsmall) labcolor(black) axis(1)) ///
		subtitle("Panel B. Effect on Poor-Quality Housing") xlab(none, axis(2)) xtitle("") ytitle("Estimated Coefficients") yline(0, lp(dash)) xline(3.5, lp(dash)) scheme(s1mono)
graph save $graph/trend_l_poor_housing_rate, replace 


eststo: quietly xi: reg l_poor_reg_rate i.v_id i.year Lead_D4_plus Lead_D3 Lead_D2 D0 Lag_D1 Lag_D2 Lag_D3_plus, cluster(v_id)
plotbeta Lead_D4_plus | Lead_D3 | Lead_D2 | D0  | Lag_D1| Lag_D2 | Lag_D3_plus, ///
		vertical level(90) xlab(1 "≤ -4" 2 "-3" 3 "-2" 4 "0" 5 "1" 6 "2" 7 "≥ 3", labsize(medsmall) labcolor(black) axis(1)) ///
		subtitle("Panel C. Effect on Registered Poor Households") xlab(none, axis(2)) xtitle("") ytitle("Estimated Coefficients") yline(0, lp(dash)) xline(3.5, lp(dash)) scheme(s1mono)
graph save $graph/trend_l_poor_reg_rate, replace 


eststo: quietly xi: reg l_disability_rate i.v_id i.year Lead_D4_plus Lead_D3 Lead_D2 D0 Lag_D1 Lag_D2 Lag_D3_plus, cluster(v_id)
plotbeta Lead_D4_plus | Lead_D3 | Lead_D2 | D0  | Lag_D1| Lag_D2 | Lag_D3_plus, ///
		vertical level(90) xlab(1 "≤ -4" 2 "-3" 3 "-2" 4 "0" 5 "1" 6 "2" 7 "≥ 3", labsize(medsmall) labcolor(black) axis(1)) ///
		subtitle("Panel D. Effect on People with Diabilities") xlab(none, axis(2)) xtitle("") ytitle("Estimated Coefficients") yline(0, lp(dash)) xline(3.5, lp(dash)) scheme(s1mono)
graph save $graph/trend_l_disability_rate, replace 


graph combine $graph/trend_l_subsidy_rate.gph $graph/trend_l_poor_housing_rate.gph $graph/trend_l_poor_reg_rate.gph $graph/trend_l_disability_rate.gph, ///
		 iscale(0.7) ysize(14) xsize(18) scheme(sj) graphregion(color(white) icolor(white) fcolor(white)) saving($graph/even_study, replace)
graph export $graph/even_study.png, replace

