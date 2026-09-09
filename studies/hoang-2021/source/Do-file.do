// change your directory

use "Data",clear
xtset id year

/* Table 1 Description */
sum v vg vc vg_res vg_com vg_ind vg_ag rates_op rates_cap I N P enrtot lunchfrpc ellpc blackpc aid_state aid_fed

/* Table 3 */
// column 1
eststo: xtreg v I N pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
// column 2
eststo: xtreg vg I N pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
estout using "../results/table.csv", varlabels(N Nvar) cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear
// column 3
xtreg vc I N pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 4
xtreg v I N P N_d pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 5
xtreg vg I N P N_d  pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 6
xtreg vc I N P N_d  pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 7
xtreg v I N P N_d pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1,fe cluster(id) robust

// column 8
xtreg vg I N P N_d  pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1,fe cluster(id) robust

// column 9
xtreg vc I N P N_d  pretrend posttrend lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1,fe cluster(id) robust

/* Table 4 */
// column 1
xtreg v Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
// column 2
xtreg vg Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 3
xtreg vc Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 4
eststo: xtreg vg_res Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear
// column 5
eststo:xtreg vg_com Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust
estout using "../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
// column 6
xtreg vg_ind Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 7
xtreg vg_ag Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 8
xtreg rates_op Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc lnaid_st lnaid_fed yeard1-yeard17 ,fe cluster(id) robust

// column 9
xtreg rates_cap Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_p1-Ir_p11 P lnenrtot ellpc blackpc lunchfrpc lnaid_st lnaid_fed yeard1-yeard17 ,fe cluster(id) robust


/* Table 5 */
// column 1
xtreg v Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_E_p1-Ir_E_p11 P_E  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 2
xtreg vg Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_E_p1-Ir_E_p11 P_E  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 3
xtreg vc Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_E_p1-Ir_E_p11 P_E  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 4
xtreg vg_res Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_E_p1-Ir_E_p11 P_E  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 5
xtreg vg_com Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_E_p1-Ir_E_p11 P_E  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 ,fe cluster(id) robust

// column 6
xtreg rates_op Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_E_p1-Ir_E_p11 P_E  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc  lnaid_st lnaid_fed yeard1-yeard17 ,fe cluster(id) robust

// column 7
xtreg rates_cap Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_E_p1-Ir_E_p11 P_E  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc  lnaid_st lnaid_fed  yeard1-yeard17 ,fe cluster(id) robust

/* Table 6 */
// column 1
xtreg v Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1 ,fe cluster(id) robust

// column 2
xtreg vg Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1 ,fe cluster(id) robust

// column 3
xtreg vc Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0  Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1,fe cluster(id) robust

// column 4
xtreg vg_res Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1,fe cluster(id) robust

// column 5
xtreg vg_com Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc yeard1-yeard17 if lateronly==1,fe cluster(id) robust

// column 6
xtreg rates_op Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc  lnaid_st lnaid_fed yeard1-yeard17 if lateronly==1,fe cluster(id) robust

// column 7
xtreg rates_cap Ir_n4 Ir_n3 Ir_n2 Ir_n1 Ir_n0 Ir_L_p1-Ir_L_p11 P_L lnenrtot ellpc blackpc lunchfrpc  lnaid_st lnaid_fed  yeard1-yeard17 if lateronly==1 ,fe cluster(id) robust
