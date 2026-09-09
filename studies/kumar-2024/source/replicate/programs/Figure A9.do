/*NOTE: 
(1) RUN "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\programs\Figures 2A, 2B, 4A, 4B, A2, A3, A4, A5, A6 Table 5.do" TO CREATE "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\results\synthoutput_energy_states.dta"
(2) RUN THE R CODE IN FILE "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\programs\mcpanel_for_credit_constraints_and_LFPR_models_with_placebo_v2_energystate.R" TO CREATE "C:\Users\k1ank00\OneDrive - FR Banks\anil\research\texas_home_equity\credit_constraints\AEJ_accept_replication_file\results\mcpanel_energystate.dta"
*/

use "$resultsdir\mcpanel_energystate.dta", clear 
tsset year
label var mcpanel "Matrix Completion"
label var elasticnet "Elastic Net"
label var DID "Diff-in-Diff"
label var ADH "SCM-ADH"

merge 1:1 year using "$resultsdir\synthoutput_energy_states.dta"
keep if _merge==1|_merge==3
drop _merge

**replace MCpanel ADH with regular synthetic control
drop ADH*
rename synth* ADH*
label var ADH "SCM-ADH"

tsline mcpanel elasticnet DID ADH, recast(connected) yline(0) xline(1997 2003, lp(dash)) xlab(1992(3)2007) title("Robustness to Alternative Synthetic Control Methods with Donor Pool Restricted to Energy States", size(small)) msymbol(s t oh o) saving("$resultsdir\Figure A9.gph", replace)


