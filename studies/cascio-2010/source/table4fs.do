cap estimates clear

* Table 4: First stage

foreach var in sch1ageshindnh_df2 {
  fsregs data/popbyschage `var' arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "" "fs${`var'}" sch1ageshindnh_702
}

foreach var in sch1ageshindnh_df2 {

  estimates restore fs${`var'}1
  qui testparm inst_sca
  global fsfall1=r(F)
  
  outreg2 inst_sca using output/tab4fs.xml, excel replace nocons nor2 addstat(# clusters,e(N_clust), F-stat, $fsfall1) noaster ctitle("x=arhisesl_sdf", "y=`var'", "all") ///
  addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")
  
	foreach spec in 2 3 4 {

  estimates restore fs${`var'}`spec'
  qui testparm inst_sca
  global fsfall`spec'=r(F)
  outreg2 inst_sca $controls1 ${controls2${`var'}} using output/tab4fs.xml, excel append nocons nor2 addstat(# clusters,e(N_clust), F-stat, ${fsfall`spec'}) noaster ctitle("x=arhisesl_sdf", "y=`var'", "all") 

	}
}

estimates clear

* Table 4b: Results by subpop for share

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
			
	foreach var in sch1ageshindnh_df2 {
	dis "arhisesl_sdf", "y=`var'"
	  fsregs data/popbyschage `var' arhisesl_sdf inst_sca "`controls'" "if $samp&schage==1&`sub'==`i'" "" "fs${`var'}`sub'`i'" sch1ageshindnh_702	

	}

} /* forval i=0/1 */
} /* foreach sub */

foreach var in sch1ageshindnh_df2 {

	foreach spec in ccity0 ccity1 unif0 unif1 {

	  estimates restore fs${`var'}`spec'1
	  qui testparm inst_sca
	  global fsf`spec'=r(F)
	  outreg2 inst_sca using output/tab4fs.xml, excel append nocons nor2 addstat(# clusters,e(N_clust),F-stat, ${fsf`spec'}) noaster ctitle("x=arhisesl_sdf", "y=`var'", "${sub`spec'}")

	}
  erase "output/tab4fs.txt"
}

estimates clear

