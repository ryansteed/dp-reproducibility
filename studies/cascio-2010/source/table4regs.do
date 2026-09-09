cap estimates clear
cap log close
log using "logs/table4regs.log", replace

* output/table 4: Main results for share

foreach var in sch1ageshindnh {
  * mean 
  means data/popbyschage `var' "if $samp&schage==0" "" "mean${`var'}"
  estimates restore mean${`var'}0
  local cmean=_b[_cons]
}


foreach var in sch1ageshindnh_df2 {

  * IV
  regs data/popbyschage `var' arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "" "iv${`var'}"

  * OLS
  regs data/popbyschage `var' arhisesl_sdf arhisesl_sdf  "$fes" "if $samp&schage==1" "" "ols${`var'}"
}


foreach var in sch1ageshindnh_df2 {

  caldr iv${`var'}1 data/popbyschage "if $samp&schage==1" 
  outreg2 arhisesl_sdf using output/tab4iv.xml, excel replace nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, $fsfall1, 1970 mean (C), `cmean',HHld DR:,$hhdr1) noaster ctitle("`var'", "all") ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")
  *** EDITED by Ryan Steed
  estout using ../results/tab4iv.csv, cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
  ***
  
  estimates restore ols${`var'}1
  outreg2 arhisesl_sdf using output/tab4ols.xml, excel replace nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, $fsfall1, 1970 mean (C), `cmean') noaster ctitle("`var'", "all") ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")

	foreach spec in 2 3 4 {

  caldr iv${`var'}`spec' data/popbyschage "if $samp&schage==1" 
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab4iv.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, ${fsfall`spec'}, 1970 mean (C), `cmean',HHld DR:,$hhdr1) noaster ctitle("`var'", "all")
  
  estimates restore ols${`var'}`spec'
  outreg2 arhisesl_sdf $controls1 ${controls2${`var'}} using output/tab4ols.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, ${fsfall`spec'}, 1970 mean (C), `cmean') noaster ctitle("`var'", "all")
	}
}

estimates clear

* output/table 4b: Results by subpop for share

* By center city status and by district type
foreach sub in ccity unif {                 
dis "`sub'"

   forval i=0/1 {
     dis `i'
     global sub`sub'`i' "`sub'==`i'"

     if "`sub'"=="ccity"&`i'==1 {
	 local controls "high"
     }	
     else {
	 local controls "$fes"
     }
			
     foreach var in sch1ageshindnh {             
  		means data/popbyschage `var' "if $samp&schage==0&`sub'==`i'" "" "mean${`var'}`sub'`i'"
		estimates restore mean${`var'}`sub'`i'0
		local cmean`sub'`i'=_b[_cons]
     }


     foreach var in sch1ageshindnh_df2 {
	  dis "`var'"

	  * IV
	  regs data/popbyschage `var' arhisesl_sdf inst_sca "`controls'" "if $samp&schage==1&`sub'==`i'" "" "iv${`var'}`sub'`i'"

	  * OLS
	  regs data/popbyschage `var' arhisesl_sdf arhisesl_sdf  "`controls'" "if $samp&schage==1&`sub'==`i'" "" "ols${`var'}`sub'`i'"
     }

   } /* forval i=0/1 */
} /* foreach sub */

foreach var in sch1ageshindnh_df2 {

foreach spec in ccity0 unif1 {

  caldr iv${`var'}`spec'1 data/popbyschage "if $samp&schage==1&${sub`spec'}" 
  outreg2 arhisesl_sdf using output/tab4iv.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, ${fsf`spec'}, 1970 mean (C), `cmean`spec'',HHld DR:,$hhdr1) noaster ctitle("`var'", "${sub`spec'}")
  
  estimates restore ols${`var'}`spec'1
  outreg2 arhisesl_sdf using output/tab4ols.xml, excel append nocons /* nor2 */ addstat(# clusters,e(N_clust), RMSE, e(rmse), F-stat, ${fsf`spec'}, 1970 mean (C), `cmean`spec'') noaster ctitle("`var'", "${sub`spec'}")

}

erase "output/tab4iv.txt"
erase "output/tab4ols.txt"

}

log close

estimates clear
