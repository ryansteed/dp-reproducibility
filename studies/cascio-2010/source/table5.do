cap estimates clear
cap log close
log using "logs/table5.log", replace

* Table 5
* Unweighted. Changing dependent variable
foreach var in sch1ageshindnh_df2 shsch1nh_df lnodds1nh_df2 lngrth1nh_df2 {
                 
  * reduced form
  *regs data/popbyschage `var' inst_sca inst_sca "$fes" "if $samp&schage==1" "" "rf${`var'}"

  * IV
  regs data/popbyschage `var' arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "" "iv${`var'}"

  * OLS
  regs data/popbyschage `var' arhisesl_sdf arhisesl_sdf  "$fes" "if $samp&schage==1" "" "ols${`var'}"
}

* Weighted

foreach var in sch1ageshindnh_df2 lnodds1nh_df2 lngrth1nh_df2 {
                 
  * reduced form
  *regs data/popbyschage `var' inst_sca inst_sca "$fes" "if $samp&schage==1" "[w=sch1popnh1970]" "rfwgt${`var'}"

  * IV
  regs data/popbyschage `var' arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "[w=sch1popnh1970]" "ivwgt${`var'}"

  * OLS
  regs data/popbyschage `var' arhisesl_sdf arhisesl_sdf  "$fes" "if $samp&schage==1" "[w=sch1popnh1970]" "olswgt${`var'}"
}


foreach var in sch1ageshindnh_df2 {

  caldr iv${`var'}1  data/popbyschage "if $samp & schage==1 & inst_sca~=." 
  outreg2 arhisesl_sdf using output/tab5iv.xml, excel replace nocons nor2 addstat(# clusters,e(N_clust), RMSE, e(rmse),HHld DR:,$hhdr1) noaster ctitle("`var'", "unweighted") ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")
  
  estimates restore ols${`var'}1
  outreg2 arhisesl_sdf using output/tab5ols.xml, excel replace nocons nor2 addstat(# clusters,e(N_clust), RMSE, e(rmse)) noaster ctitle("`var'", "unweighted")  ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")

}

foreach var in lnodds1nh_df2 lngrth1nh_df2 shsch1nh_df {

  caldr iv${`var'}1  data/popbyschage "if $samp & schage==1 & inst_sca~=." 
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab5iv.xml, excel append nocons nor2 addstat(# clusters,e(N_clust),Marg Eff:,$mgeff, RMSE, e(rmse),HHld DR:,$hhdr1) noaster ctitle("`var'", "unweighted") 
  
  caldr ols${`var'}1  data/popbyschage "if $samp & schage==1 & inst_sca~=." 
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab5ols.xml, excel append nocons nor2 addstat(# clusters,e(N_clust),Marg Eff:,$mgeff, RMSE, e(rmse)) noaster ctitle("`var'", "unweighted") 
}


foreach var in sch1ageshindnh_df2 lnodds1nh_df2 {
 
  caldr ivwgt${`var'}1  data/popbyschage "if $samp & schage==1 & inst_sca~=." "[w=sch1popnh1970]"
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab5iv.xml, excel append nocons nor2 addstat(# clusters,e(N_clust),Marg Eff:,$mgeff, RMSE, e(rmse),HHld DR:,$hhdr1) noaster ctitle("`var'", "weighted") 
  
  caldr olswgt${`var'}1 data/popbyschage "if $samp & schage==1 & inst_sca~=." "[w=sch1popnh1970]"
  *estimates restore olswgt${`var'}1
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab5ols.xml, excel append nocons nor2 addstat(# clusters,e(N_clust),Marg Eff:,$mgeff, RMSE, e(rmse)) noaster ctitle("`var'", "weighted") 

}

erase "output/tab5iv.txt"
erase "output/tab5ols.txt"

log close
