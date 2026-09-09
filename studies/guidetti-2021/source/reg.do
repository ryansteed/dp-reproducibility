cd "source/"

cap log close
log using "log_regressions.log", replace
use "main_data.dta", clear

global controls temp humid temp2 humid2 temphumid 


********************************************************************************
* TABLE 1
********************************************************************************
eststo clear
 
**2SLS

*Respiratory
foreach disease in resp asthma pneu influ { 
eststo: ivreghdfe hrate_`disease' ${controls} (pm = ws ws_1) [w = population], absorb(district dow month year) cluster(district date) 
estadd ysumm  
}

*Export table
esttab est1 est2 est3 est4 using "table1.tex", se replace b(2) se(3) ///
stats(ymean, labels("Dep. var. mean") fmt(%9.2f)) noobs nonotes nonumber fragment booktabs nolines mtitles("All" "Asthma" "Pneumonia" "Influenza" ) drop(${controls}) starlevels(* 0.1 ** 0.05 *** 0.01) coeflabel(pm "$ PM_{t}$") mgroup("Panel A: Respiratory Diseases" , pattern(1 0 0 0)prefix(\multicolumn{@span}{c}{) suffix(})span erepeat(\cmidrule(lr){@span})) substitute(\_ _) postfoot(\midrule \addlinespace) posthead(\hline \addlinespace)
**** EDITED: Ryan Steed
estout est1 est2 est3 est4 using "../results/table1a.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
****
eststo clear

*Others
foreach disease in epilep phimo append bonefrac{ 
eststo: ivreghdfe hrate_`disease' ${controls} (pm = ws ws_1) [w = population], absorb(district dow month year) cluster(district date) 
estadd ysumm  
}

*Export table
esttab est1 est2 est3 est4 using "table1.tex", se append b(2) se(3) ///
stats(ymean, labels("Dep. var. mean") fmt(%9.2f)) nonotes nonumber fragment booktabs nolines mtitles("Epilepsy" "Phimosis" "Appendicitis" "Fracture") drop(${controls}) starlevels(* 0.1 ** 0.05 *** 0.01) coeflabel(pm "$ PM_{t}$") mgroup("Panel B: Non-respiratory Diseases", pattern(1 0 0 0)prefix(\multicolumn{@span}{c}{) suffix(})span erepeat(\cmidrule(lr){@span})) substitute(\_ _) posthead(\hline \addlinespace) postfoot(\midrule)
**** EDITED: Ryan Steed
estout est1 est2 est3 est4 using "../results/table1b.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
****
*Export stats
esttab est1 est2 est3 est4 using "table1.tex", se append b(2) se(3) ///
stats(widstat N, labels("F-statistic" "Observations") fmt(%9.2f %11.0g)) nonotes nonumber fragment booktabs nolines nogaps nomtitles drop(${controls} pm) starlevels(* 0.1 ** 0.05 *** 0.01) 
eststo clear



********************************************************************************
* TABLE 2
********************************************************************************
eststo clear

*Heterogeneity
foreach disease in epilep phimo append bonefrac{ 
eststo: ivreghdfe hrate_`disease' ${controls} (pm pm_high_ped_beds = ws ws_1 ws_high_ped_beds ws1_high_ped_beds) [w=population], absorb(district dow month year) cluster(district date)
estadd ysumm  
}
 
*Export table
esttab est1 est2 est3 est4  using "table2.tex", se replace b(2) se(3) ///
stats(ymean widstat N, labels("Dep. var. mean" "F-statistic" "Observations") fmt(%9.2f %9.2f %11.0g)) nonotes nonumber fragment booktabs mtitles("Epilepsy" "Phimosis" "Appendicitis" "Fracture") drop(${controls}) starlevels(* 0.1 ** 0.05 *** 0.01) coeflabel(pm "$ PM_{t}$" pm_high_ped_beds "$ PM_{t}*1[\text{high}]$") substitute(\_ _)
eststo clear
 


********************************************************************************
* Appendix
********************************************************************************

**1st stage
eststo clear
eststo: reghdfe pm ${controls} ws ws_1 [w = population], absorb(district dow month year) cluster(district date) 
estadd ysumm
test (ws = 0) (ws_1 = 0) 
estadd scalar F_stat = r(F)

esttab est1 using "table1_appendix.tex", se replace b(2) se(3) ///
stats(ymean F_stat N_clust N_clust2 N, labels ("Dep. var. mean" "Kleibergen-Paap rk Wald F-statistic" "Number of districts" "Number of days" "Observations") fmt(%9.2f %9.2f 0 %9.0g %11.0g)) nonotes nonumber fragment booktabs drop(${controls} _cons)  ///
starlevels(* 0.1 ** 0.05 *** 0.01) mtitles("$ PM_{t}$") ///
coeflabel(ws "$ ws_{t}$" ws_1 "$ ws_{t-1}$") substitute(\_ _)
eststo clear


**OLS

*Respiratory
foreach disease in resp asthma pneu influ { 
eststo: reghdfe hrate_`disease' ${controls} pm [w = population] if ws != . & ws_1!= ., absorb(district dow month year) cluster(district date) 
estadd ysumm  
}

*Export table
esttab est1 est2 est3 est4 using "table2_appendix.tex", se replace b(2) se(3) ///
stats(ymean, labels("Dep. var. mean") fmt(%9.2f)) noobs nonotes nonumber fragment booktabs nolines mtitles("Respiratory" "Asthma" "Pneumonia" "Influenza" ) drop(${controls} _cons) starlevels(* 0.1 ** 0.05 *** 0.01) coeflabel(pm "$ PM_{t}$") mgroup("Panel A: Respiratory Diseases" , pattern(1 0 0 0)prefix(\multicolumn{@span}{c}{) suffix(})span erepeat(\cmidrule(lr){@span})) substitute(\_ _) postfoot(\midrule \addlinespace) posthead(\hline \addlinespace)
eststo clear

*Others
foreach disease in epilep phimo append bonefrac{ 
eststo: reghdfe hrate_`disease' ${controls} pm [w = population] if ws != . & ws_1!= ., absorb(district dow month year) cluster(district date) 
estadd ysumm  
}

*Export table
esttab est1 est2 est3 est4 using "table2_appendix.tex", se append b(2) se(3) ///
stats(ymean, labels("Dep. var. mean") fmt(%9.2f)) nonotes nonumber fragment booktabs nolines mtitles("Epilepsy" "Phimosis" "Appendicitis" "Fracture") drop(${controls} _cons) starlevels(* 0.1 ** 0.05 *** 0.01) coeflabel(pm "$ PM_{t}$") mgroup("Panel B: Non-respiratory Diseases", pattern(1 0 0 0)prefix(\multicolumn{@span}{c}{) suffix(})span erepeat(\cmidrule(lr){@span})) substitute(\_ _) posthead(\hline \addlinespace) postfoot(\midrule)

*Export stats
esttab est1 est2 est3 est4 using "table2_appendix.tex", se append b(2) se(3) ///
stats(N_clust N_clust2 N, labels("Number of districts" "Number of days" "Observations") fmt(0 %9.0g %11.0g)) nonotes nonumber fragment booktabs nolines nogaps nomtitles drop(${controls} _cons pm) starlevels(* 0.1 ** 0.05 *** 0.01) 
eststo clear


log close
