/*This dofile calculates the occupational employment share (based on rescaled oral scores) among working age low-education immigrants from non-English speaking countries and low-education natives, to plot the appendix figure A.2.1. The end data set is occ_concentration_graph.dta.  */

set more off
cd $ResultD
******************* split occupations into 5 quantiles based on rescaled oral scores *******************
use "occ1990_and_oral_rescale_score.dta", clear
xtile qtScore=oral_rescale, n(5)  // create the five quantile
save "occ1990_and_oral_rescale_score_temp.dta", replace

*********************** construct employment share for immigrants ***********************
use FBsampleCZ,  clear
* refine the inconsistent occ1990
replace occ1990=4 if occ1990==3
replace occ1990=22 if occ1990==16
replace occ1990=22 if occ1990==17
replace occ1990=22 if occ1990==21
replace occ1990=68 if occ1990==67
replace occ1990=154 if occ1990==113
replace occ1990=154 if occ1990==114
replace occ1990=154 if occ1990==115
replace occ1990=154 if occ1990==116
replace occ1990=154 if occ1990==118
replace occ1990=154 if occ1990==119
replace occ1990=154 if occ1990==123
replace occ1990=154 if occ1990==125
replace occ1990=154 if occ1990==127
replace occ1990=154 if occ1990==128
replace occ1990=154 if occ1990==139
replace occ1990=154 if occ1990==145
replace occ1990=154 if occ1990==147
replace occ1990=154 if occ1990==149
replace occ1990=154 if occ1990==150
replace occ1990=169 if occ1990==168
replace occ1990=178 if occ1990==179
replace occ1990=214 if occ1990==213
replace occ1990=214 if occ1990==215
replace occ1990=214 if occ1990==235
replace occ1990=379 if occ1990==314
replace occ1990=319 if occ1990==323
replace occ1990=344 if occ1990==343
replace occ1990=347 if occ1990==345
replace occ1990=159 if occ1990==387
replace occ1990=405 if occ1990==407
replace occ1990=443 if occ1990==438
replace occ1990=473 if occ1990==474
replace occ1990=473 if occ1990==475
replace occ1990=473 if occ1990==476
replace occ1990=479 if occ1990==483
replace occ1990=488 if occ1990==484
replace occ1990=525 if occ1990==538
replace occ1990=726 if occ1990==646
replace occ1990=596 if occ1990==653
replace occ1990=733 if occ1990==659
replace occ1990=666 if occ1990==667
replace occ1990=668 if occ1990==674
replace occ1990=785 if occ1990==717
replace occ1990=729 if occ1990==728
replace occ1990=736 if occ1990==734
replace occ1990=736 if occ1990==735
replace occ1990=756 if occ1990==768
replace occ1990=783 if occ1990==784
replace occ1990=759 if occ1990==789
replace occ1990=799 if occ1990==796
replace occ1990=883 if occ1990==834
replace occ1990=889 if occ1990==876
replace occ1990=889 if occ1990==877
merge m:1 occ1990 using "occ1990_and_oral_rescale_score_temp.dta"
* Not Matched: Those who are in military, unemployed, and unknown(not in labor force)  are not matched.  217373/(217373+ 790183)=21.574% not matched for low skilled immigrants. 
* 2 occupations reported in oral score data not matched:  
* (1) Atmospheric and space scientist; 
* (2) Optometrist. 
* No low education immigrants worked in these occupations in our sample years. 
drop if _merge ==2 
drop _merge 

tab qtScore, gen(scoreQt)
forvalues i = 1/5{
	replace scoreQt`i' = 0 if missing(scoreQt`i') 
}
collapse (mean) scoreQt* [pw = czperwt], by (year)
reshape long scoreQt, i(year) j(Qt)
save Occ_Concentration_Graph_temp.dta, replace


*********************** construct employment share for Natives ***********************
// NBsampleCZ created from 4c_NativeEnroll_table6.do
use NBsampleCZ,  clear
* refine the inconsistent occ1990
replace occ1990=4 if occ1990==3
replace occ1990=22 if occ1990==16
replace occ1990=22 if occ1990==17
replace occ1990=22 if occ1990==21
replace occ1990=68 if occ1990==67
replace occ1990=154 if occ1990==113
replace occ1990=154 if occ1990==114
replace occ1990=154 if occ1990==115
replace occ1990=154 if occ1990==116
replace occ1990=154 if occ1990==118
replace occ1990=154 if occ1990==119
replace occ1990=154 if occ1990==123
replace occ1990=154 if occ1990==125
replace occ1990=154 if occ1990==127
replace occ1990=154 if occ1990==128
replace occ1990=154 if occ1990==139
replace occ1990=154 if occ1990==145
replace occ1990=154 if occ1990==147
replace occ1990=154 if occ1990==149
replace occ1990=154 if occ1990==150
replace occ1990=169 if occ1990==168
replace occ1990=178 if occ1990==179
replace occ1990=214 if occ1990==213
replace occ1990=214 if occ1990==215
replace occ1990=214 if occ1990==235
replace occ1990=379 if occ1990==314
replace occ1990=319 if occ1990==323
replace occ1990=344 if occ1990==343
replace occ1990=347 if occ1990==345
replace occ1990=159 if occ1990==387
replace occ1990=405 if occ1990==407
replace occ1990=443 if occ1990==438
replace occ1990=473 if occ1990==474
replace occ1990=473 if occ1990==475
replace occ1990=473 if occ1990==476
replace occ1990=479 if occ1990==483
replace occ1990=488 if occ1990==484
replace occ1990=525 if occ1990==538
replace occ1990=726 if occ1990==646
replace occ1990=596 if occ1990==653
replace occ1990=733 if occ1990==659
replace occ1990=666 if occ1990==667
replace occ1990=668 if occ1990==674
replace occ1990=785 if occ1990==717
replace occ1990=729 if occ1990==728
replace occ1990=736 if occ1990==734
replace occ1990=736 if occ1990==735
replace occ1990=756 if occ1990==768
replace occ1990=783 if occ1990==784
replace occ1990=759 if occ1990==789
replace occ1990=799 if occ1990==796
replace occ1990=883 if occ1990==834
replace occ1990=889 if occ1990==876
replace occ1990=889 if occ1990==877
merge m:1 occ1990 using "occ1990_and_oral_rescale_score_temp.dta"
* Not Matched: Those who are in military, unemployed, and unknown(not in labor force)  are not matched.  
drop if _merge ==2 
drop _merge 

tab qtScore, gen(scoreQt)
forvalues i = 1/5{
	replace scoreQt`i' = 0 if missing(scoreQt`i') 
}
collapse (mean) scoreQt* [pw = czperwt], by (year)
reshape long scoreQt, i(year) j(Qt)
rename scoreQt scoreQtNB
save Occ_Concentration_Graph_temp_NB.dta, replace

use Occ_Concentration_Graph_temp_NB.dta, clear 
merge 1:1 year Qt using Occ_Concentration_Graph_temp
gen Qt1 = Qt-0.1
gen Qt2 = Qt+0.1  // manually offset the overtlapping issue
save occ_concentration_graph.dta, replace 


erase occ1990_and_oral_rescale_score_temp.dta
erase Occ_Concentration_Graph_temp.dta
erase Occ_Concentration_Graph_temp_NB.dta




