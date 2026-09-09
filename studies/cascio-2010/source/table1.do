* Table 1: Means 

cap estimates clear

foreach var in arhisesl_sdf inst_sca sch1ageshindnh_df sch1ageshindnh_df2 sch1ageshindnh1970 sch1ageshindnh_702 ///
arDm_tot2_good1976 pprevprop ppexptot ptratio high hipub ccity drop_16t17 medfaminc {
  means0 data/popbyschage `var' "if $samp&schage==1&inst_sca~=." "" "mean1${`var'}"
	}

foreach var in sch1ageshindnh_df sch1ageshindnh1970 {
  	means0 data/popbyschage `var' "if $samp&schage==0&inst_sca~=." "" "mean0${`var'}"
	}

foreach var in privratenh_df privratenh1970 {
  means0 data/private `var' "if $samp&schage==1&inst_sca~=." "" "mean1${`var'}"
}

estimates restore mean1var10
local stdev=_se[_cons]*sqrt(e(N))

outreg2 `inst' using output/tab1.xml, excel replace nor2 addstat(stdev, `stdev') noaster

foreach var in arhisesl_sdf inst_sca sch1ageshindnh_df sch1ageshindnh_df2 privratenh_df sch1ageshindnh1970 sch1ageshindnh_702 privratenh1970 ///
arDm_tot2_good1976 pprevprop ppexptot ptratio high hipub ccity drop_16t17 medfaminc {
								
	estimates restore mean1${`var'}0
	local stdev=_se[_cons]*sqrt(e(N))
	outreg2 using output/tab1.xml, excel append nor2 addstat(stdev, `stdev') ctitle("`var'", "schage=1") noaster
}

foreach var in sch1ageshindnh_df sch1ageshindnh1970 {
  estimates restore mean0${`var'}0
	local stdev=_se[_cons]*sqrt(e(N))
	outreg2 using output/tab1.xml, excel append nor2 addstat(stdev, `stdev') ctitle("`var'", "schage=0") noaster
}

erase "output/tab1.txt"

