*************************************************************
*Table 2: initial level variables correlation with instrument
*full sample
*************************************************************

foreach var in arhisesl_sdf sch1ageshindnh1970 sch1ageshindnh_702 lnartot21976 ///
pprevprop ppexptot hipub ccity drop_16t17 ptratio medfaminc {  
	regs data/popbyschage `var' inst_sca inst_sca "$fes" "if $samp&schage==1" "" "tab2${`var'}1"
}

foreach var in privratenh1970 {
	regs data/private `var' inst_sca inst_sca "$fes" "if $samp&schage==1" "" "tab2${`var'}1"
}



sum inst_sca if $samp&schage==1
global instsd=r(sd)
dis $instsd

estimates restore tab2var111
local onesd=$instsd*_b[inst_sca]
outreg2 inst_sca using output/tab2.xml, excel replace nocons nor2 addstat(# clusters,e(N_clust), onesd, `onesd') noaster ctitle("`var'", "schage=1") ///
addnote("All regressions include MSA by district type fixed effects. Standard errors clustered on MSA.")

foreach var in sch1ageshindnh_702 privratenh1970 lnartot21976 ///
pprevprop ppexptot ptratio hipub ccity drop_16t17 medfaminc  {  							
	estimates restore tab2${`var'}11
	local onesd=$instsd*_b[inst_sca]
        outreg2 inst_sca using output/tab2.xml, excel append nocons nor2 addstat(# clusters,e(N_clust), onesd, `onesd') ctitle("`var'", "schage=1") noaster
}

erase "output/tab2.txt"
cap estimates clear
