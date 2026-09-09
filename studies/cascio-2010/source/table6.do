cap estimates clear

* Table 6: Private enrollment

* First stage
foreach var in privratenh_df {
  fsregs data/private `var' arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "" "fs${`var'}" privratenh1970
}

foreach var in privratenh_df {

  estimates restore fs${`var'}1
  testparm inst_sca
  global fsfall1=r(F)
  outreg2 inst_sca using output/tab6fs.xml, excel replace nocons /* nor2 */ addstat(# clusters,e(N_clust), F-stat, $fsfall1) noaster
  
	foreach spec in 2 3 4 {

	  estimates restore fs${`var'}`spec'
	  testparm inst_sca
	  global fsfall`spec'=r(F)
	  outreg2 inst_sca $controls1 ${controls2${`var'}} using output/tab6fs.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), F-stat, ${fsfall`spec'}) noaster

	}
erase "output/tab6fs.txt"
}

estimates clear

* Main regressions

foreach var in privratenh {
  means data/private `var' "if $samp" "" "mean${`var'}"
  estimates restore mean${`var'}0
  local cmean=_b[_cons]

}

foreach var in privratenh_df {
  * reduced form
  regs data/private `var' inst_sca inst_sca "$fes" "if $samp&schage==1" "" "rf${`var'}"

  * IV
  regs data/private `var' arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "" "iv${`var'}"

  * OLS
  regs data/private `var' arhisesl_sdf arhisesl_sdf  "$fes" "if $samp&schage==1" "" "ols${`var'}"
}


foreach var in privratenh_df {

  estimates restore rf${`var'}1
  outreg2 inst_sca using output/tab6.xml, excel replace nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), 1970 mean, `cmean') noaster ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")

  estimates restore iv${`var'}1
  outreg2 arhisesl_sdf using output/tab6iv.xml, excel replace nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, $fsfall1, 1970 mean, `cmean') noaster ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")
  
  estimates restore ols${`var'}1
  outreg2 arhisesl_sdf using output/tab6ols.xml, excel replace nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), 1970 mean, `cmean') noaster ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")
  
	foreach spec in 2 3 4 {

  estimates restore rf${`var'}`spec'
  outreg2 inst_sca $controls1 ${controls2${`var'}} using output/tab6.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), 1970 mean, `cmean') noaster

  estimates restore iv${`var'}`spec'
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab6iv.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, ${fsfall`spec'}, 1970 mean, `cmean') noaster
  
  estimates restore ols${`var'}`spec'
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab6ols.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), 1970 mean, `cmean') noaster
	}

erase "output/tab6.txt"
erase "output/tab6iv.txt"
erase "output/tab6ols.txt"

}

estimates clear


