* Table 3: Reduced form

foreach var in sch1ageshindnh_df {
	regs data/popbyschage `var' inst_sca inst_sca "$fes" "if $samp&schage==0" "" "tab3C${`var'}"
	regs data/popbyschage `var' inst_sca inst_sca "$fes" "if $samp&schage==1" "" "tab3T${`var'}"
	regs data/popbyschage `var'2 inst_sca inst_sca "$fes" "if $samp" "" "tab3d${`var'}"
}
foreach var in sch1ageshindnh_pre sch1ageshindnh_df {
	regs data/popbyschage `var' inst_sca inst_sca "$fes" "if $samp&schage==0&sch1ageshindnh_pre~=.&fracmiss<.05" "" "tab3C2${`var'}"
	regs data/popbyschage `var' inst_sca inst_sca "$fes" "if $samp&schage==1&sch1ageshindnh_pre~=.&fracmiss<.05" "" "tab3T2${`var'}"
	regs data/popbyschage `var'2 inst_sca inst_sca "$fes" "if $samp&sch1ageshindnh_pre~=.&fracmiss<.05" "" "tab3d2${`var'}"
}

local n 1
foreach var in sch1ageshindnh_df {
  foreach e in T C d {
    local append "append"
    if `n'==1 {
      local append "replace"
    }
    estimates restore tab3`e'${`var'}1
    outreg2 inst_sca using output/tab3.xml, excel `append' ctitle("`var'","`e'", "All districts") nocons nor2 noaster addstat(# clusters,e(N_clust)) ///
    addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")
    local n=`n'+1
  }
}
foreach var in sch1ageshindnh_df sch1ageshindnh_pre {
  foreach e in T C d {
    estimates restore tab3`e'2${`var'}1
    outreg2 inst_sca using output/tab3.xml, excel append ctitle("`var'","`e'", "Districts with 1960 data") nocons nor2 noaster addstat(# clusters,e(N_clust))
  }
}

erase "output/tab3.txt"
