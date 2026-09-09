/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates Figure E1, which examines the external validity of 
Wisconsin's school finance system. Specifically, it examines deviations from 
the national average along multiple dimensions related to school finance.

DATA INPUTS: (1) External Validity WI
OUTPUT: Figure E1
*********************************/
clear
set more off

*Set globals

*Path
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"

*Import dataset
import excel using "${path}Data\Intermediate\external_validity.xlsx", firstrow

*Keep only needed variables
keep State Local_Rev Inst_Exp_Share Capital_Out_Share tot_exp_mem Current_Exp_Share
replace Capital = Capital*100
replace Current = Current*100

*Generate deviations from national average
gen dev_local_rev = abs(Local_Rev - 45)
gen dev_op_exp_sh = abs(Current_Exp - 88.358)
gen dev_capout_sh = abs(Capital_Out_Share - 7.78)
gen dev_tot_exp_pp = abs(tot_exp_mem - 12796)
drop if State=="United States"


*Deviation from "Total Exp per Pupil"
separate dev_tot_exp_pp, by(State=="Wisconsin")
sort dev_tot_exp_pp
graph bar (asis) dev_tot_exp_pp0 dev_tot_exp_pp1, nofill over(State, sort(dev_tot_exp_pp) ///
descending lab(nolab)) legend(off) ytitle(Absolute Deviation (Total Expenditure Per Pupil)) ///
bar(1, bfcolor(none) lcolor(black) lwidth(medium)) ///
bar(2, bfcolor(red)) lintensity(*4) ///
bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white)  ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none))
graph export "${path}Output\generaliz_1.pdf", replace 


*Deviation from "Share of Total Rev. from Local Sources"
separate dev_local_rev, by(State=="Wisconsin")
graph bar (asis) dev_local_rev0 dev_local_rev1, nofill over(State, sort(dev_local_rev) ///
descending lab(nolab)) legend(off) ytitle(Absolute Deviation (Percent of Rev. from Prop. Taxes)) ///
bar(1, bfcolor(none) lcolor(black) lwidth(medium)) ///
bar(2, bfcolor(red)) lintensity(*4) ///
bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white)  ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none))
graph export "${path}Output\generaliz_2.pdf", replace 

*Deviation from "Share of Total Exp. in Instruction"
separate dev_op_exp_sh, by(State=="Wisconsin")
graph bar (asis) dev_op_exp_sh0 dev_op_exp_sh1, nofill over(State, sort(dev_op_exp_sh) ///
descending lab(nolab)) legend(off) ytitle(Absolute Deviation (Percent of Total Exp. in Operations)) ///
bar(1, bfcolor(none) lcolor(black) lwidth(medium)) ///
bar(2, bfcolor(red)) lintensity(*4) ///
bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white)  ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none))
graph export "${path}Output\generaliz_3.pdf", replace 


***Deviation from "Share of Total Exp. in Capital"
separate dev_capout_sh, by(State=="Wisconsin")
graph bar (asis) dev_capout_sh0 dev_capout_sh1, nofill over(State, sort(dev_capout_sh) ///
descending lab(nolab)) legend(off) ytitle(Absolute Deviation (Percent of Total Exp. in Cap.)) ///
bar(1, bfcolor(none) lcolor(black) lwidth(medium)) ///
bar(2, bfcolor(red)) lintensity(*4) ///
bgcolor(white) graphregion(lcolor(white) ilcolor(white) fcolor(white)  ///
ifcolor(white)) plotregion(lcolor(none) ilcolor(white) style(none))
graph export "${path}Output\generaliz_4.pdf", replace 


