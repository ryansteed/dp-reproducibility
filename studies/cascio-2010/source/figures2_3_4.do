clear
cap clear matrix
set mem 500m
set more off

do defgphs.do

*rfscat arguments
*	local data `1'
*	local yvar `2'
*	local zvar `3'
*	local controls `4'
*	local if `5'
*	local wt `6'
*	local name `7'
*	local title `8'
* 	local out `9'
*	local label `10'
*	local thresh `11'* _


rfscat data/popbyschage arhisesl_sdf inst_sca "$fes" "if $samp&schage==1" "" "Change in Low-English Hispanic Share" "" "output/fig2" 1 .2
rfscat data/popbyschage sch1ageshindnh_df2 inst_sca "$fes" "if $samp&schage==1" "" "Change in Share of MSA's Non-Hispanic Population" "" "output/fig3" 1 0.036

rfscat data/popbyschage sch1ageshindnh_df2 inst_sca "$fes" "if $samp&schage==1&sch1ageshindnh_pre2~=." "" "Change in Share of MSA's Non-Hispanic Population" "A. 1970-2000" "output/fig4a" 0 
rfscat data/popbyschage sch1ageshindnh_pre2 inst_sca "$fes" "if $samp&schage==1&sch1ageshindnh_pre2~=." "" "Change in Share of MSA's Non-Hispanic Population" "B. 1960-1970" "output/fig4b" 0


gr combine output/fig2.gph, c(1) fxsize(97) 
gr export output/fig2.eps, as(eps) replace

gr combine output/fig3.gph, c(1) fxsize(97) 
gr export output/fig3.eps, as(eps) replace

gr combine output/fig4a.gph output/fig4b.gph, c(2) fysize(75) 
gr export output/fig4.eps, as(eps) replace


erase output/fig2.gph
erase output/fig3.gph
erase output/fig4a.gph
erase output/fig4b.gph
