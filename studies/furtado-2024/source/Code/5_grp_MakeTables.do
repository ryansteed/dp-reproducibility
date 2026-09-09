/*This dofile creates all of the tables and figures in the paper.*/
* Stata version 17
* cd $ResultD
global path "."

global wkdir "$path/Code"
global OriginalD "$path/Raw"
global ResultD "$path/Data"
global ResultT "$path/Results"

cd $ResultD
set more off
**********************************************************************************************
* Table 1 Descriptive Statistics
**********************************************************************************************
use "Ready4RegressBaseline.dta", clear 
quietly eststo clear
quietly estpost tabstat d_tradeusch_pw_adh d_goodeng edu_hs age yrsusa female manu_d l_shind_manuf_cbp l_sh_popedu_c l_sh_empl_f ///
race_w race_b race_a race_h mard if heavy == 0 [aw=cell_wt], by ( year) stat(mean sd) column(statistics)
quietly est store A 
// A reports descriptive statistics for CZs with "d_tradeusch_pw" below the median in each year.

quietly estpost tabstat d_tradeusch_pw_adh d_goodeng edu_hs age yrsusa female manu_d l_shind_manuf_cbp l_sh_popedu_c l_sh_empl_f ///
race_w race_b race_a race_h mard  if heavy == 1 [aw=cell_wt], by ( year) stat(mean sd) column(statistics)
quietly est store B 
// B reports descriptive statistics for CZs with "d_tradeusch_pw" above the median in each year.

quietly estpost tabstat d_tradeusch_pw_adh d_goodeng edu_hs age yrsusa female manu_d l_shind_manuf_cbp l_sh_popedu_c l_sh_empl_f ///
race_w race_b race_a race_h mard [aw=cell_wt], by ( year) stat(mean sd) column(statistics)
quietly est store C 
// C reports descriptive statistics for all 716 CZs in each year.

*esttab A B C using $ResultT/Table1.csv, main(mean 2 co) aux(sd 2) label  noobs parentheses replace  

**********************************************************************************************
* Table 2 Baseline Regression (OLS)
**********************************************************************************************
use "Ready4RegressBaseline.dta", clear 

* Period FE
reg d_goodeng d_tradeusch_pw_adh  t2   [aw = cell_wt], cluster(statefip)
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table2.doc,  addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "N", Local Controls, "N", Whole Controls, "N")  keep(d_tradeusch_pw_adh) dec(3) replace

* Period FE + Local controls 
reg d_goodeng d_tradeusch_pw_adh  edu_hs age yrsusa race_b race_a race_m race_an race_h race_o  female t2   [aw = cell_wt], cluster(statefip)
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table2.doc,  addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "N",Local Controls, "Y", Whole Controls, "N")  keep(d_tradeusch_pw_adh) dec(3) 

* Period FE + Local controls +State FE + base period manufacturing 
reg d_goodeng d_tradeusch_pw_adh  edu_hs age yrsusa race_b race_a race_m race_an race_h race_o  female t2  i.statefip  l_shind_manuf_cbp [aw = cell_wt], cluster(statefip)
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table2.doc,  addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "N")  keep(d_tradeusch_pw_adh) dec(3) 

* Period FE + Local controls +State FE + base period manufacturing + whole population control
reg d_goodeng d_tradeusch_pw_adh  edu_hs age yrsusa race_b race_a race_m race_an race_h race_o female  t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table2.doc,  addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) dec(3) 

* model used: education + age + years in the US + race +gender+ whole population level characteristics, state FE, cluster on state.
*1) First stage 
reg d_tradeusch_pw_adh d_tradeotch_pw_lag_adh  edu_hs  age yrsusa   race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum d_tradeusch_pw_adh [aw = cell_wt]
    *outreg2 using $ResultT/Table2.doc,    addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")   keep(d_tradeotch_pw_lag_adh)  ctitle(First Stage) dec(3) 

*2) Second stage 
eststo: ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table2.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) append ctitle(Second Stage) dec(3) 

estout using "./../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
**********************************************************************************************
* Table 3 Different Occupations (manufacturing/service/farming sector) Employment Changes
**********************************************************************************************
* Data oral_emp_eff.dta is created by "4b_oralScore_table3&4.do"
use  "oral_emp_eff.dta", clear
ivreg2 d_manu_d (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum manu_d [aw = cell_wt]
    *outreg2 using $ResultT/Table3.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Manufacturing Sector) dec(3) replace

ivreg2 d_ser_d (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum ser_d [aw = cell_wt]
    *outreg2 using $ResultT/Table3.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Service Sector) dec(3)  

ivreg2 d_farm_d (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum farm_d [aw = cell_wt]
    *outreg2 using $ResultT/Table3.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Farming Sector) dec(3)  
	
use Ready4RegressBaseline, clear 

ivreg2 d_unemp (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum unemp [aw = cell_wt]
    *outreg2 using $ResultT/Table3.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Unemployment) dec(3) 

ivreg2 d_notlf (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum notlf [aw = cell_wt]
    *outreg2 using $ResultT/Table3.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Not Labor Force) dec(3) 
	
**********************************************************************************************
* Table 4 Different Oral Score Occupations Employment Changes
**********************************************************************************************
* Data oral_emp_eff.dta is created by "4b_oralScore_table3&4.do"


use  "oral_emp_eff.dta", clear
ivreg2 d_oral_all_p75 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum oral_all_p75 [aw = cell_wt]
    *outreg2 using $ResultT/Table4.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Higher P25 Oral Low Skilled Occ) dec(3) replace

ivreg2 d_oral_all_p50 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum oral_all_p50 [aw = cell_wt]
    *outreg2 using $ResultT/Table4.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle( P50-75 Oral Low Skilled Occ) dec(3) 
	
ivreg2 d_oral_all_p25_50 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum oral_all_p25_50 [aw = cell_wt]
    *outreg2 using $ResultT/Table4.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(P25-50 Oral Low Skilled Occ) dec(3) 

ivreg2 d_oral_all_p25 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum oral_all_p25 [aw = cell_wt]
    *outreg2 using $ResultT/Table4.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Lower P25 Oral Low Skilled Occ) dec(3) 

***********************************************
* Table 5 Heterogeneity
***********************************************
/* Panel A: Heterogeneity by English Fluency Major */
use Ready4RegressBaseline, clear 

ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table5_EnglishFluency.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3)  replace ctitle(Very Well)

ivreg2 d_goodeng_altr1 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female  t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum goodeng_altr1 [aw = cell_wt]
    *outreg2 using $ResultT/Table5_EnglishFluency.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Well) dec(3) 

ivreg2 d_goodeng_altr2 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum goodeng_altr2 [aw = cell_wt]
    *outreg2 using $ResultT/Table5_EnglishFluency.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) append ctitle(Speak English) dec(3) 

/* Panel B: heterogeniety by Race */
use "Ready4Regress_race_1_samplesize.dta", clear 
local totobs = tot_obs
local aveobs =  round(ave_obs,1)
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa  female   t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table5_Race.doc, addstat( Average Dependent Variable (Levels), r(mean), Total Sample Size, `totobs', Average Sample Size, `aveobs', F, e(widstat)) addtext(Race, 1, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3)  replace 

foreach i in 2 3 4 {
    use "Ready4Regress_race_`i'_samplesize.dta", clear  
	local totobs = tot_obs
    local aveobs =  round(ave_obs,1)
    ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa  female   t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
        sum goodeng [aw = cell_wt]
    	*outreg2 using $ResultT/Table5_Race.doc, addstat(Average Dependent Variable (Levels), r(mean),Total Sample Size, `totobs', Average Sample Size, `aveobs', F, e(widstat)) addtext(Race, `i', STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) 
	}

/* Panel C: Heterogeneity by Education (just in sample for now)*/
use Ready4Regress_eduLS_0.dta, clear  	
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)   age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table5_Edu.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Education, No HS, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3)  replace

use Ready4Regress_eduLS_1.dta, clear  
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)   age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table5_Edu.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Education, HS, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) 

***********************************************
* Table 6 Enrollment-- low education immigrant (non-English speaking) VS Natives
***********************************************
* Immigrants
use Ready4RegressBaseline.dta, clear 
eststo: ivreg2 d_enroll (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum enroll [aw = cell_wt]
    *outreg2 using $ResultT/Table6_Enroll.doc,  addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) replace 

estout using "./../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

* Natives, the dataset used is created by "4c_NativeEnroll.do"
use Ready4RegressBaseline_natives.dta, clear  
ivreg2 d_enroll (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age  race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum enroll [aw = cell_wt]
    *outreg2 using $ResultT/Table6_Enroll.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  dec(3)

***********************************************
* Table 7 Regressions: Changes in population  
***********************************************
* Data Ready4Regress_AllNEngImm.dta and Ready4Regress_oldEngImm.dta are created by "4d_popuChange_table7.do"
* Panel A, d_lnpop as dep var, with full our controls, as well as the lag log change in population
use Ready4Regress_AllNEngImm.dta, clear
ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f d_lnpopczyr_lag [aw = cell_wt], cluster(statefip)   
    sum lnpopczyr [aw = cell_wt]
    *outreg2 using $ResultT/Table7_CZPop_change_PanelA.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, AllNonEngImmig, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh )  dec(3) replace

use Ready4Regress_AllNEngImm_goodeng0.dta, clear
ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f d_lnpopczyr_lag [aw = cell_wt], cluster(statefip)   
    sum lnpopczyr [aw = cell_wt]
    *outreg2 using $ResultT/Table7_CZPop_change_PanelA.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, BadEngImmig, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh ) dec(3) 

use Ready4Regress_AllNEngImm_goodeng1.dta, clear
ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f d_lnpopczyr_lag [aw = cell_wt], cluster(statefip)   
    sum lnpopczyr [aw = cell_wt]    
    *outreg2 using $ResultT/Table7_CZPop_change_PanelA.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, GoodEngImmig, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh ) dec(3) 		
	
use Ready4Regress_oldEngImm.dta, clear
ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f d_lnpopczyr_lag [aw = cell_wt], cluster(statefip)   
	sum lnpopczyr [aw = cell_wt]
	*outreg2 using $ResultT/Table7_CZPop_change_PanelA.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, AllEngImmig, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh ) dec(3) 

* Panel B, d_lnpop as dep var, without local demographic controls. 
use Ready4Regress_AllNEngImm.dta, clear
    ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  l_sh_popfborn d_lnpopczyr_lag [aw = cell_wt], cluster(statefip)   
    sum lnpopczyr [aw = cell_wt]
    *outreg2 using $ResultT/Table7_CZPop_change_PanelB.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, AllNonEngImmig, STATE FE, "Y", Controls, Y) keep(d_tradeusch_pw_adh  ) dec(3)  replace

use Ready4Regress_AllNEngImm_goodeng0.dta, clear
    ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  l_sh_popfborn d_lnpopczyr_lag  [aw = cell_wt], cluster(statefip)   
    sum lnpopczyr [aw = cell_wt]
    *outreg2 using  $ResultT/Table7_CZPop_change_PanelB.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, BadEngImmig, STATE FE, "Y", Controls, Y) keep(d_tradeusch_pw_adh ) dec(3) 
	
use Ready4Regress_AllNEngImm_goodeng1.dta, clear
    ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  l_sh_popfborn d_lnpopczyr_lag [aw = cell_wt], cluster(statefip)   
    sum lnpopczyr [aw = cell_wt]    
    *outreg2 using  $ResultT/Table7_CZPop_change_PanelB.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, GoodEngImmig, STATE FE, "Y", Controls, Y) keep(d_tradeusch_pw_adh ) dec(3) 

use Ready4Regress_oldEngImm.dta, clear
	ivreg2 d_lnpopczyr (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  l_sh_popfborn  d_lnpopczyr_lag [aw = cell_wt], cluster(statefip)   
	sum lnpopczyr [aw = cell_wt]
	*outreg2 using  $ResultT/Table7_CZPop_change_PanelB.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, AllEngImmig, STATE FE, "Y", Controls, Y) keep(d_tradeusch_pw_adh) dec(3) 
	
***********************************************
* Table 8 Placebo Regressions
***********************************************
use Ready4RegressBaseline, clear 
*col 1: edu 
ivreg2 d_edu_hs (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)    age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum edu_hs [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,  addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(edu) dec(3)  replace

*col 2: years in the us 
ivreg2 d_yrsusa (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum yrsusa [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,    addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(yrsusa) dec(3) 

*col 3: age 
ivreg2 d_age (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum age [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(age)  dec(3) 

*col 4: race-black 
ivreg2 d_race_b (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa    female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum race_b [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,    addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(black)  dec(3) 
	
*col 5: race-asian 
ivreg2 d_race_a (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa    female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum race_a [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,    addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(asian)  dec(3) 

*col 6: race-hisp 
ivreg2 d_race_h (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa    female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum race_h  [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,    addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(hisp)  dec(3) 

*col 7: race-white 
ivreg2 d_race_w (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum race_w  [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(white) dec(3) 

*col 8: race-other 
ivreg2 d_race_all_other (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum race_all_other  [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(other) dec(3) 

*col 9: female 
ivreg2 d_female (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa  race_b race_a  race_h race_m race_an race_o t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum female  [aw = cell_wt]
    *outreg2 using $ResultT/Table8.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  ctitle(female) dec(3) 

***********************************************
* Table 9. Migration between Commuting zones
***********************************************
* Data are created by "4e_migrationIndiv_table9.do"
***********Panel A Move Out of Past CZ***************
* keep both good and bad English speakers, check if they are more likely to move out facing the rsing local import competition
* cd $ResultD
use Ready4Regress_czmigpast_moveout_80_00.dta, clear
    ivreg2 d_mig (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum mig [aw = cell_wt]
    *outreg2 using $ResultT/Table9_PanelA_80_00.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, All, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) replace


* keep only bad English speakers, check if they are more likely to move out with the rsing import competition
use Ready4Regress_czmigpast_moveout_80_00_goodeng0.dta, clear
    ivreg2 d_mig (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum mig [aw = cell_wt]
    *outreg2 using $ResultT/Table9_PanelA_80_00.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, All BadSpeaker,STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) 
	
* keep only good English speakers, check if they are more likely to move out with the rsing import competition
use  Ready4Regress_czmigpast_moveout_80_00_goodeng1.dta, clear
    eststo: ivreg2 d_mig (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum mig [aw = cell_wt]
    *outreg2 using $ResultT/Table9_PanelA_80_00.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, All GoodSpeaker, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) 

* 	coefficient comparison across good and bad speakers
use Ready4Regress_czmigpast_moveout_80_00_goodeng0.dta, clear
gen good = 0
append using Ready4Regress_czmigpast_moveout_80_00_goodeng1.dta
replace good = 1 if good != 0
gen cons=1
ivreg2 d_mig c.cons#i.good (c.d_tradeusch_pw_adh#i.good = c.d_tradeotch_pw_lag_adh#i.good)  c.edu_hs#i.good c.age#i.good c.yrsusa#i.good   c.race_b#i.good c.race_a#i.good  c.race_h#i.good c.race_m#i.good c.race_an#i.good c.race_o#i.good c.female#i.good c.t2#i.good c.l_shind_manuf_cbp#i.good i.statefip#i.good  c.l_sh_popedu_c#i.good c.l_sh_empl_f#i.good  [aw = cell_wt], nocons cluster(statefip)    
test 0.good#c.d_tradeusch_pw_adh =  1.good#c.d_tradeusch_pw_adh	

estout using "./../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***********Panel B Move In Current CZ***************
* keep both good and bad English speakers, check if they are more likely to move out with the rsing import competition
use Ready4Regress_czmigcurrent_moveout_80_00.dta, clear
    ivreg2 d_mig (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum mig [aw = cell_wt]
    *outreg2 using $ResultT/Table9_PanelB_80_00.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, All, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3)  replace

*  keep only bad English speakers, check if they are more likely to move out with the rsing import competition
use Ready4Regress_czmigcurrent_moveout_80_00_goodeng0.dta, clear
    ivreg2 d_mig (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum mig [aw = cell_wt]
    *outreg2 using $ResultT/Table9_PanelB_80_00.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, BadSpeaker,STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) 

*  keep only good English speakers, check if they are more likely to move out with the rsing import competition
use  Ready4Regress_czmigcurrent_moveout_80_00_goodeng1.dta, clear
    ivreg2 d_mig (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum mig [aw = cell_wt]
    *outreg2 using $ResultT/Table9_PanelB_80_00.doc,  addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Sample, GoodSpeaker, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) 

* 	coefficient comparison across good and bad speakers
use Ready4Regress_czmigcurrent_moveout_80_00_goodeng0.dta, clear
gen good = 0
append using Ready4Regress_czmigcurrent_moveout_80_00_goodeng1.dta
replace good = 1 if good != 0
gen cons=1
ivreg2 d_mig c.cons#i.good (c.d_tradeusch_pw_adh#i.good = c.d_tradeotch_pw_lag_adh#i.good)  c.edu_hs#i.good c.age#i.good c.yrsusa#i.good   c.race_b#i.good c.race_a#i.good  c.race_h#i.good c.race_m#i.good c.race_an#i.good c.race_o#i.good c.female#i.good t2#i.good c.l_shind_manuf_cbp#i.good i.statefip#i.good  c.l_sh_popedu_c#i.good c.l_sh_empl_f#i.good  [aw = cell_wt], nocons cluster(statefip)    
test 0.good#c.d_tradeusch_pw_adh =  1.good#c.d_tradeusch_pw_adh

***********************************************
* Table 10. Split by years in the US
***********************************************
use Ready4Regress_yrusintvl_1.dta, clear
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age    race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/Table10_YrsUSA.doc,   addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Yrs in US, yrusintvl_1, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) replace

foreach i in  yrusintvl_5 yrusintvl_7 yrusintvl_9 yrusintvl_10plus{ 
	use Ready4Regress_`i'.dta, clear 
    ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age    race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)   
        sum goodeng [aw = cell_wt]
    	*outreg2 using $ResultT/Table10_YrsUSA.doc,   addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Yrs in US, `i', STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3)
	}
***********************************************
* Table 11 Heterogeneity by Recent Migration History 
***********************************************	
*1. Same house, 2. Same state 3. Different state 4. Different country 
/* Panel A: heterogeniety by Migrate5 in terms of language*/
set more off 
use "Ready4Regress_migrate_1_80", clear  
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa  race_b race_a  race_h race_m race_an race_o female   t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum goodeng  [aw = cell_wt]
    *outreg2 using $ResultT/Table11_migrate_80.doc, addstat( Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(migrate, 1, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) replace 
foreach i in 2 3 4 {
    use "Ready4Regress_migrate_`i'_80.dta", clear  
    ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa  race_b race_a  race_h race_m race_an race_o female   t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
        sum goodeng  [aw = cell_wt]
    	*outreg2 using $ResultT/Table11_migrate_80.doc,   addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(migrate, `i', STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3)
	}
/*
***********************************************
***********************************************
* Appendix Tables 
***********************************************
***********************************************	

***********************************************
* Appendix Table A.1.1 share of immigrants from different country of origin in our sample
***********************************************
* Data is created by 4h_appendixA11&A22.do

***********************************************
* Appendix Table A.1.2 different weight
***********************************************	
use Ready4RegressBaseline, clear 
* Period FE + Local controls +State FE + base period manufacturing + whole population control
reg d_goodeng d_tradeusch_pw_adh  edu_hs age yrsusa race_b race_a race_m race_an race_h race_o female  t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip) 
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_2.doc,  addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) dec(3) replace

* model used: education + age + years in the US + race +gender+ whole population level characteristics, state FE, cluster on state.
*2) Second stage 
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_2.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) append ctitle(Second Stage) dec(3) 

*1) First stage 
reg d_tradeusch_pw_adh d_tradeotch_pw_lag_adh  edu_hs  age yrsusa   race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum d_tradeusch_pw_adh [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_2.doc,    addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")   keep(d_tradeotch_pw_lag_adh)  ctitle(First Stage) dec(3) 
********************** ADH weight X our weight ***********************************
gen adhXcell = timepwt48*cell_wt
* Period FE + Local controls +State FE + base period manufacturing + whole population control
reg d_goodeng d_tradeusch_pw_adh  edu_hs age yrsusa race_b race_a race_m race_an race_h race_o female  t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = adhXcell], cluster(statefip)
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_2.doc,  addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) dec(3) 

* model used: education + age + years in the US + race +gender+ whole population level characteristics, state FE, cluster on state.
*2) Second stage 
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = adhXcell], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_2.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) append ctitle(Second Stage) dec(3) 

*1) First stage 
reg d_tradeusch_pw_adh d_tradeotch_pw_lag_adh  edu_hs  age yrsusa   race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = adhXcell], cluster(statefip)  
    sum d_tradeusch_pw_adh [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_2.doc,    addstat(Average Dependent Variable (Levels), r(mean))  addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")   keep(d_tradeotch_pw_lag_adh)  ctitle(First Stage) dec(3) 

	
***********************************************
* Appendix Table A.1.3 Alternative Import Exposure Measures
***********************************************	
use Ready4RegressBaseline, clear 
* Baseline Regression
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_3.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) append ctitle(Baseline) dec(3)  replace

* Gravity Residual, Reduced Form OLS
reg d_goodeng d_traderes_pw_lag   edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_3.doc,   addstat(Average Dependent Variable (Levels),r(mean)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_traderes_pw_lag) append ctitle(Gravity) dec(3) 
	
* Domestic plus International Exposure
ivreg2 d_goodeng (d_tradex_usch_pw=d_tradex_otch_pw_lag)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_3.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradex_usch_pw) append ctitle(D&I Exposure) dec(3) 

* Final Goods and Intermediate Imports
ivreg2 d_goodeng (d_tradeusch_netinput_pw=d_tradeotch_pw_lag d_inputotch_pw_lag)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_3.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_netinput_pw) append ctitle(Final&Intermediate) dec(3) 

* Net Imports
ivreg2 d_goodeng (d_netimpusch_pw=d_tradeotch_pw_lag d_expotch_pw_lag)   edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_3.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_netimpusch_pw) append ctitle(Net Import) dec(3) 

* Factor Content of Net Imports
ivreg2 d_goodeng (d_nettradefactor_usch_io=d_tradefactor_otch_lag_io d_expfactor_otch_lag_io) edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_3.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_nettradefactor_usch_io) append ctitle(Factor Content) dec(3) 
	
***********************************************
* Appendix Table A.1.4 Placebo
***********************************************
use "placebo_90_10_cz_character_ready_reg.dta", clear 
ivreg2 d_goodeng (d_tradeusch_pw_adh_future=d_tradeotch_pw_lag_adh_future)  edu_hs age yrsusa  race_a race_b race_h race_m race_an   race_o  female  l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt]  , cluster(statefip) 
    sum goodeng
    *outreg2 using $ResultT/TableA_1_4placebo.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(State FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh_future)  dec(3) replace

***********************************************
* Appendix Table A.1.5 effect on manufacturing employment
*********************************************** 
* Data is created by 4f_native_immig_manuEmp.do

******************************** Panal A Manufacturing Effect ***********************************
* all skills, manufacturing emp effect
use All_Manu_All_Edu_Ready4RegressBaseline, clear 
ivreg2 d_manu_d (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum manu_d [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelA_ManuEff.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  dec(3) replace ctitle(All Sample)

use Native_Manu_All_Edu_Ready4RegressBaseline, clear 
ivreg2 d_manu_d (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum manu_d [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelA_ManuEff.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) append ctitle(Native)
* low skill, manufacturing emp effect
use Native_Manu_Low_Edu_Ready4RegressBaseline, clear 
ivreg2 d_manu_d (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum manu_d [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelA_ManuEff.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) append ctitle(low skilled Native)

use NonEng_Immig_Manu_Low_Edu_Ready4RegressBaseline, clear 
ivreg2 d_manu_d (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum manu_d [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelA_ManuEff.doc,  addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) append ctitle(low skilled Non-Eng-Speaking Cty Imigrant)

************************** Panal B Low Oral Occupation Employment Effect *****************************
* all skills, manufacturing emp effect
use All_Manu_All_Edu_Ready4RegressBaseline, clear 
ivreg2 d_oral_all_p25 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh) edu_hs  age race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum oral_all_p25 [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelB_ManuEff.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh)  dec(3) replace ctitle(All Sample)

use Native_Manu_All_Edu_Ready4RegressBaseline, clear 
ivreg2 d_oral_all_p25 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum oral_all_p25 [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelB_ManuEff.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) append ctitle(Native)
* low skill, manufacturing emp effect
use Native_Manu_Low_Edu_Ready4RegressBaseline, clear 
ivreg2 d_oral_all_p25 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum oral_all_p25 [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelB_ManuEff.doc, addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) append ctitle(low skilled Native)

use NonEng_Immig_Manu_Low_Edu_Ready4RegressBaseline, clear 
ivreg2 d_oral_all_p25 (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa race_b race_a race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f   [aw = cell_wt], cluster(statefip)  
    sum oral_all_p25 [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_5_PanelB_ManuEff.doc,  addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) append ctitle(low skilled Non-Eng-Speaking Cty Imigrant)

***********************************************
* Appendix Table A.1.6 Gender
***********************************************
use  Ready4Regress_female_0.dta, replace 
    ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_a race_b race_h race_m race_an   race_o    t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum goodeng  [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_6_gender.doc,  addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Gender, male, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3) replace 

use  Ready4Regress_female_1.dta, replace 
    ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs age yrsusa   race_a race_b race_h race_m race_an   race_o    t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f  [aw = cell_wt], cluster(statefip)  
    sum goodeng  [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_6_gender.doc,  addstat(Average Dependent Variable (Levels), r(mean), F, e(widstat)) addtext(Gender, female, STATE FE, "Y", Controls, Y)  keep(d_tradeusch_pw_adh) dec(3)

***********************************************
* Appendix Table A.1.7 Robustness with Different Sample Size 
***********************************************	
use Ready4RegressBaseline.dta
ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_7_drop_fewObs.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) append ctitle(Original 2SLS) dec(3) replace

foreach i in 5 10 50 100{
    use "Ready4RegressBaseline_fewobs_wt_`i'"
	ivreg2 d_goodeng (d_tradeusch_pw_adh=d_tradeotch_pw_lag_adh)  edu_hs  age yrsusa   race_b race_a  race_h race_m race_an race_o female t2 l_shind_manuf_cbp i.statefip  l_sh_popedu_c l_sh_empl_f [aw = cell_wt], cluster(statefip)  
    sum goodeng [aw = cell_wt]
    *outreg2 using $ResultT/TableA_1_7_drop_fewObs.doc,   addstat(Average Dependent Variable (Levels),r(mean),F, e(widstat)) addtext(State FE, "Y", Local Controls, "Y", Whole Controls, "Y")  keep(d_tradeusch_pw_adh) append ctitle(Fewer than `i') dec(3) 
	}
***********************************************
* Appendix Figure A.2.1 Occupational Distribution of Low Education Immigrants vs. Low Education Natives
***********************************************
* Data is created by 4f_native_immig_manuEmp.do

use occ_concentration_graph.dta, clear 
twoway (bar scoreQt Qt1, barw(.3))  ///
	   (bar scoreQtNB Qt2, barw(.3)), ///
	   xtitle("Oral Score Quintiles") ///
	   ytitle("Employment Share") ///
	   xlabel(1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th") ///
       legend(lab (1 "Immigrants") lab(2 "Natives") ) ///
	   by(year)
graph save $ResultT/FigureA_2_1, replace
***********************************************
* Appendix Figure A.2.2 Non-Hispanics White Characteristics
***********************************************
* Data is created by 4h_appendixA11&A22.do

********* continent *********
use FigureA_2_2_1_data.dta, clear
graph pie share, over(continent) pie(1,explode) pie(2,explode)  pie(3,explode) pie(4,explode) plabel(_all name, gap(10) ) plabel(_all percent, gap(20) ) legend(off)
graph save $ResultT/FigureA_2_2_1, replace

********* country of origin *********
use FigureA_2_2_2_data.dta, clear
graph pie share, over(bpld) sort plabel(_all name, gap() ) plabel(_all percent, gap(20) ) legend(off)
graph save $ResultT/FigureA_2_2_2, replace


***********************************************
* Appendix Figure A.2.3 immigrangts with different educational attainments employment share comparison 
***********************************************
* Data is created by 4a_grp_CreateAggDataforTables.do

use hs_nhs_occu_change.dta, clear
graph bar occu0 occu1, over(ind, relabel(1 "Manufacturing" 2 "Management, Sales & Service" 3 "Farming")) ///
                       bargap(-20) ///
                       legend(label(1 "Less than High School") label(2 "High School Graduate")) ///
                       ytitle("Employment Share") ///
					   blabel(bar, position(outside) format(%9.3f) color(black))
graph save $ResultT/FigureA_2_3, replace
***********************************************
* Appendix Table A.3.1 
***********************************************
* Data is created by 4a_grp_CreateAggDataforTables.do

use industry_level_ext, clear  
gsort -sic87dd year // correct the sorting here, otherwise table will bev randomly assigned every time bysort or sort.
gen table1_var="."
replace table1_var="mean" in 1
replace table1_var="s.d." in 2
replace table1_var="IQR"  in 3
replace table1_var="1/HHI"  in 4
replace table1_var="1/HHI_sic3"  in 5
replace table1_var="Largest_emp_share"  in 6
replace table1_var="Largest_emp_share_sic3"  in 7
replace table1_var="# shocks" in 8
replace table1_var="# industries" in 9
replace table1_var="# SIC3 groups" in 10

gen Col1=.
gen Col2=.
gen Col3=.

* Statistics on sample:
* all
replace Col1 = _N in 8
distinct sic87dd
	replace Col1 = r(ndistinct) in 9
distinct sic3
	replace Col1 = r(ndistinct) in 10
	
* drop services
count if sic87dd!=0
	replace Col2 = r(N) in 8
distinct sic87dd if sic87dd!=0
	replace Col2 = r(ndistinct) in 9
distinct sic3 if sic87dd!=0
	replace Col2 = r(ndistinct) in 10
	
*** Col. 1, all shocks including services ***

* create relevant employment shares, across all observations by periods
egen share_col1=pc(s_n), prop

sum g [aw=share_col1], d
	replace Col1 = r(mean) in 1
	replace Col1 = r(sd) in 2
	replace Col1 = r(p75)-r(p25) in 3

egen temp = sum(share_col1^2)
replace Col1 = 1/temp in 4
drop temp

bysort sic3: egen sic3_share_col1=sum(share_col1)
sort sic3 sic87dd
by sic3: replace sic3_share_col1=0 if _n>1
gsort -sic3
egen temp = sum(sic3_share_col1^2)
gsort -sic87dd year
replace Col1 = 1/temp in 5
drop temp 

sum share_col1
	replace Col1 = r(max) in 6

sum sic3_share_col1
	replace Col1 = r(max)  in 7

*** Col. 2, no services ***
drop if sic87dd==0
gsort -sic87dd year

* create relevant employment shares, across all observations by periods
egen share_col2=pc(s_n), prop

sum g [aw=share_col2], d
	replace Col2 = r(mean) in 1
	replace Col2 = r(sd) in 2
	replace Col2 = r(p75)-r(p25) in 3

egen temp = sum(share_col2^2)
replace Col2 = 1/temp in 4
drop temp

bysort sic3: egen sic3_share_col2=sum(share_col2)
sort sic3 sic87dd
by sic3: replace sic3_share_col2=0 if _n>1
gsort -sic3
egen temp = sum(sic3_share_col2^2)
gsort -sic87dd year
replace Col2 = 1/temp in 5
drop temp 

sum share_col2
	replace Col2 = r(max) in 6

	sum sic3_share_col2
	replace Col2 = r(max)  in 7

*** Col. 3, no services with period F.E. ***
gsort -sic87dd year

* since we have excluded services, this is implicitly manufacturing by year
reg g i.year [aw=s_n]
predict double gres3, resid

sum gres3 [aw=s_n], d
	replace Col3 = r(mean) in 1
	replace Col3 = r(sd) in 2
	replace Col3 = r(p75)-r(p25) in 3

keep table1 Col*
drop if table1=="."
format Col* %8.3f
save $ResultT/TableA_3_1, replace

***********************************************
* Appendix Table A.3.2
***********************************************

local outcomes d_goodeng

local adhcontrols edu_hs age yrsusa race_b race_a race_m race_an race_h race_o female   i.statefip  l_sh_popedu_c l_sh_empl_f  
local aadhp_czcontrols cz_prode_share1991 cz_cap_va1991 cz_log_avg_wage1991 cz_ind_ci_1990 cz_ind_htsh1_1990
local aadhpcontrols prode_share1991 cap_va1991 log_avg_wage1991 ind_ci_1990 ind_htsh1_1990
local aadhp_czpretrends cz_d_ind_shemp_7691 cz_d_ind_lnavgw_7691 
local aadhp_pretrends d_ind_shemp_7691 d_ind_lnavgw_7691 

// the first seven control sets are for Table 4, the last four are for Table C4
local controls1 t2 l_shind_manuf_cbp `adhcontrols'  // including service, start-period manu,  compare to SSIV
local controls2 t2 l_shind_manuf_cbp `adhcontrols' // excluding service, start-period manu, compare to control 1
local controls3 t2 Lsh_manuf  `adhcontrols'  // test including service industry , use lagged manu share , conmpare to control1 
local controls4 t2 Lsh_manuf `adhcontrols'  // excluding service industry, use lagged manu manu, compare to control 2

local controls5 t2 Lsh_manuf `adhcontrols' Lsh_sicgroup*  // like Acemoglu et al. (2016, AADHP) col 2
local controls6 t2 Lsh_manuf `adhcontrols' `aadhp_czcontrols' // AADHP col 3
local controls7 t2 Lsh_manuf ind_share* `adhcontrols' // AADHP col 8
local controls8 t2 Lsh_manuf `aadhp_czpretrends' `adhcontrols' // AADHP col 4
local controls9 t2 Lsh_manuf Lsh_sicgroup* `aadhp_czcontrols' `adhcontrols' // AADHP col 5
local controls10 t2 Lsh_manuf Lsh_sicgroup* `aadhp_czpretrends' `adhcontrols' // AADHP col 6
local controls11 t2 Lsh_manuf Lsh_sicgroup* `aadhp_czpretrends' `aadhp_czcontrols' `adhcontrols' // AADHP col 7

local indcontrols1
local indcontrols2 
local indcontrols3  
local indcontrols4  
local indcontrols5   i.sicgroup
local indcontrols6   `aadhpcontrols'
local indcontrols7   			// note: here also have ind FE
local indcontrols8   `aadhp_pretrends'
local indcontrols9   i.sicgroup `aadhpcontrols' 
local indcontrols10  i.sicgroup `aadhp_pretrends' 
local indcontrols11  i.sicgroup `aadhp_pretrends' `aadhpcontrols' 

// industry level regressions
use "industry_level_ext", clear // the extended industry-level file (which includes non-manuf. industry) is for col.1 only
tab sic87dd if sic87dd!=0, gen(ind_)
drop ind_1
tsset, clear // necessary for ivreg2 to work with the partial option
eststo clear
foreach v of local outcomes {
	forvalues r=1/11 {
		if (`r'==1 | `r'==3) local iff = ""
			else local iff = "if sic87dd!=0"
			
		* produce and save SSIV F-stat
		if (`r'!=7) ivreg2 x`r' (z`r'=g) `indcontrols`r'' `iff' [aw=s_n], cluster(sic3) 
			else ivreghdfe x`r' (z`r'=g) `iff' [aw=s_n], cluster(sic3) absorb(sic87dd year)
		local fs_f = (_b[z`r']/_se[z`r'])^2
		
		* now main industry-level regressions
		if (`r'!=7) eststo : ivreg2 `v'`r' (x`r'=g) `indcontrols`r'' `iff' [aw=s_n], cluster(sic3) 
			else eststo : ivreghdfe `v'`r' (x`r'=g) `iff' [aw=s_n], cluster(sic3) absorb(sic87dd year)
		estadd local controlset = "`r'"
		estadd scalar fs_f = `fs_f'
	}
}

esttab using $ResultT/TableA_3_2.csv, b(%9.7f) se(%9.7f)  ///
	rename(x1 x x2 x x3 x x4 x x5 x x6 x x7 x x8 x x9 x x10 x x11 x prode_share1991 aadhp_controls d_ind_shemp_7691 aadhp_pretrends) ///
	scalars( fs_f controlset) ///
	replace obslast indicate( *sicgroup* aadhp_controls aadhp_pretrends ) ///
	drop(_cons cap_va1991 log_avg_wage1991 ind_ci_1990 ind_htsh1_1990 d_ind_lnavgw_7691)
*/