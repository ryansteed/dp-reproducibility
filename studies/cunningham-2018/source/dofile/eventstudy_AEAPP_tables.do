clear 
clear matrix
clear mata
set mat 11000
set memory 4g
set maxvar 11000
set more off
cap log close

log using "$output/AEAPP_Tables.log", replace
*********************************
*								*
*	group treatment effects		*
*   Use 1960 Population Wgts	*
*	Urban by Year Fixed Effects	*
*  								*
*********************************	
use "$data/aeapp_protests_table_1.dta", clear
*** EDIT BY Donna
xtset fips year
xi i.year
xi, prefix(_U) i._urban*i.year
drop _U_urban_* _Uyear_* _urban

xi, prefix(_S) i.stfips*i.year
drop _Sstfips_* _Syear_*
********************************************************************************************
********************************************************************************************
****************										  **********************************
****************  		STATE BY YEAR EFFECTS			  **********************************
****************			  BASELINE					  **********************************
****************										  **********************************
********************************************************************************************
********************************************************************************************
*non-white deaths 1) year effects  2) region by year effects  3) region by year  and covariates
xtreg deaths_nw_police _I* _U* _O* [w=_popwgt_nw], cluster(fips) fe
*outreg2 using "$output/AEAPP_Table1.xls", keep( _Ojoint_2-_Ojoint_6 ) replace bracket nocons 
xtreg deaths_nw_police _S* _U* _O* [w=_popwgt_nw], cluster(fips) fe
*outreg2 using "$output/AEAPP_Table1.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
eststo: xtreg deaths_nw_police _S* _U*  x_* _O* [w=_popwgt_nw], cluster(fips) fe
*outreg2 using "$output/AEAPP_Table1.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

********************************************************************************************
*white deaths 1) year effects  2) region by year effects  3) region by year  and covariates
/*
xtreg deaths_w_police _I* _U* _O* [w=_popwgt_w], cluster(fips) fe
outreg2 using "$output/AEAPP_Table1.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
xtreg deaths_w_police _S* _U* _O* [w=_popwgt_w], cluster(fips) fe
outreg2 using "$output/AEAPP_Table1.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
xtreg deaths_w_police _S* _U*  x_* _O* [w=_popwgt_w], cluster(fips) fe
outreg2 using "$output/AEAPP_Table1.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
*/
********************************************************************************************
********************************************************************************************
****************										  **********************************
****************  		Crime Regressions 				  **********************************
****************										  **********************************
********************************************************************************************
********************************************************************************************
/*
use "$data/aeapp_protests_table_2.dta", clear

xi i.year
xi, prefix(_U) i._urban*i.year
drop _U_urban_* _Uyear_* _urban

xi, prefix(_S) i.stfips*i.year
drop _Sstfips_* _Syear_*

*log of Total Crime per 100K 1) year effects   2) state by year effects   3) state by year and covariates
xtreg lP_tot _I* _U* _O*  report_crime full_crime [w=_popwgt], cluster(fips) fe
outreg2 using "$output/AEAPP_Table2.xls", keep( _Ojoint_2-_Ojoint_6 ) replace bracket nocons 
xtreg lP_tot _S* _U* _O*  report_crime full_crime [w=_popwgt], cluster(fips) fe
outreg2 using "$output/AEAPP_Table2.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
xtreg lP_tot _S* _U*  x_* _O*  report_crime full_crime [w=_popwgt], cluster(fips) fe
outreg2 using "$output/AEAPP_Table2.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
********************************************************************************************
*log of Sworn Officers per 1K 1) year effects   2) state by year effects   3) state by year and covariates
xtreg lP_sworn _I* _U* _O* report_pol [w=_popwgt], cluster(fips) fe
outreg2 using "$output/AEAPP_Table2.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
xtreg lP_sworn _S* _U* _O* report_pol [w=_popwgt], cluster(fips) fe
outreg2 using "$output/AEAPP_Table2.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
xtreg lP_sworn _S* _U*  x_* _O* report_pol [w=_popwgt], cluster(fips) fe
outreg2 using "$output/AEAPP_Table2.xls", keep( _Ojoint_2-_Ojoint_6 ) append bracket nocons 
*/