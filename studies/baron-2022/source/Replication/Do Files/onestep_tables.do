/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates all tables in the paper that are derived
from the one-step estimator. These tables include the following:
Table 4, Table 5, Table 7, Table 8 in the main body of the paper.
Table B1, Table B3, Table B4, Table B5 in the online appendix.

DATA INPUTS: (1) onestep_panel_tables

*********************************/
clear
set more off

*Set globals

*Path
global path "../"

*The model is as follows:
*I control for both types of measures on the ballot, polynomial controls in both
*vote shares (op and capital), the number of elections in any given year for both
*types, whether the op. election is for recurring and nonrecurring purposes, and
*month during which the election was held. Finally, I include year & district FEs.

*Cubic Specification
global cubic op_win_prev* bond_win_prev* yrdums* ///
	op_ismeas_prev* bond_ismeas_prev* op_month_prev* bond_month_prev* ///
	op_percent_prev* op_percent2_prev* op_percent3_prev* ///
	bond_percent_prev* bond_percent2_prev* bond_percent3_prev* ///
	recurring_prev* op_numelec_prev* bond_numelec_prev*
	
*Quadratic Specification
global quadratic op_win_prev* bond_win_prev* yrdums* ///
	op_ismeas_prev* bond_ismeas_prev* op_month_prev* bond_month_prev* ///
	op_percent_prev* op_percent2_prev*  ///
	bond_percent_prev* bond_percent2_prev*  ///
	recurring_prev* op_numelec_prev* bond_numelec_prev*
*Linear Specification
global linear op_win_prev* bond_win_prev* yrdums* ///
	op_ismeas_prev* bond_ismeas_prev* op_month_prev* bond_month_prev* ///
	op_percent_prev* bond_percent_prev*  ///
	recurring_prev* op_numelec_prev* bond_numelec_prev*

*Post-Election 10 Year Avg. Effect Operational
global tenyr_op .10*(op_win_prev1 + op_win_prev2 + op_win_prev3 +op_win_prev4+ ///
op_win_prev5+op_win_prev6+op_win_prev7+op_win_prev8+op_win_prev9+op_win_prev10)

*Post-Election 10 Year Avg. Effect Bond
global tenyr_bond .10*(bond_win_prev1 + bond_win_prev2 + bond_win_prev3 +bond_win_prev4+ ///
bond_win_prev5+bond_win_prev6+bond_win_prev7+bond_win_prev8+bond_win_prev9+bond_win_prev10)

*Post-Election 5 Year Avg. Effect Operational
global fiveyr_op .20*(op_win_prev1 + op_win_prev2 + op_win_prev3 +op_win_prev4+op_win_prev5)

*Post-Election 5 Year Avg. Effect Bond
global fiveyr_bond .20*(bond_win_prev1 + bond_win_prev2 + bond_win_prev3 +bond_win_prev4+bond_win_prev5)

*Post-Election 5 Year Avg. Effect Interaction (in Equation 3)
global fiveyr_interaction (1/5)*(interaction_prev1 + interaction_prev2 + interaction_prev3 +interaction_prev4+interaction_prev5)

*Test of equal operational and capital impacts
global equality .10*(op_win_prev1 + op_win_prev2 + op_win_prev3 +op_win_prev4+op_win_prev5+ ///
op_win_prev6+op_win_prev7+op_win_prev8+op_win_prev9+op_win_prev10) = ///
.10*(bond_win_prev1 + bond_win_prev2 + bond_win_prev3 +bond_win_prev4+bond_win_prev5+ ///
bond_win_prev6+bond_win_prev7+bond_win_prev8+bond_win_prev9+bond_win_prev10)

*Import one-step estimator panel
use "${path}Data/Final/onestep_panel_tables"


*****************************************
******SECTION I: MAIN BODY TABLES
*****************************************


*****************************************
******TABLE 4
*****************************************
*** EDITED by Ryan
if 0 {
areg rev_lim_mem $cubic, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg tot_exp_mem $cubic, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg tot_exp_inst_mem $cubic, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg tot_exp_ss_mem $cubic, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg tot_exp_oth_mem $cubic, absorb(district_code) cluster(district_code)	
lincom $tenyr_op


*****************************************
******TABLE 5 (A)
*****************************************
areg dropout_rate $cubic [aw=student_count], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg advprof_math10 $cubic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg wkce_math10 $cubic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg log_instate_enr $cubic grade9lagged, absorb(district_code) cluster(district_code)
lincom $tenyr_op
}

*****************************************
******TABLE 5 (B)
*****************************************
eststo: areg dropout_rate $quadratic [aw=student_count], absorb(district_code) cluster(district_code)
lincom $tenyr_op

matrix new_row1 = (r(estimate), r(se), r(t), r(p), r(lb), r(ub))
* areg advprof_math10 $quadratic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
* lincom $tenyr_op

*** EDITED by Donna/Ryan
estout using "../../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

areg wkce_math10 $quadratic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_op

matrix new_row2 = (r(estimate), r(se), r(t), r(p), r(lb), r(ub))

areg log_instate_enr $quadratic grade9lagged, absorb(district_code) cluster(district_code)
lincom $tenyr_op

matrix new_row3 = (r(estimate), r(se), r(t), r(p), r(lb), r(ub))

matrix lincom_table = new_row1 \ new_row2 \ new_row3

matrix colnames lincom_table = est se t p lb ub

matrix rownames lincom_table = "dropout" "avg_math" "log_enrollment"

clear

svmat lincom_table, names(col)

gen str20 label = ""

replace label = "dropout" in 1

replace label = "avg_math" in 2

replace label = "log_enrollment" in 3

order label

rename label var
rename est* est
rename se* se
rename t* t
rename p* p
rename lb* lb
rename ub* ub

export delimited using "../../../results/lincom_result.csv", replace

exit
***

*****************************************
******TABLE 5 (C)
*****************************************
areg dropout_rate $linear [aw=student_count], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg advprof_math10 $linear [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg wkce_math10 $linear [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg log_instate_enr $linear grade9lagged, absorb(district_code) cluster(district_code)
lincom $tenyr_op


*****************************************
******TABLE 7 (A)
*****************************************
*Unrestricted
areg dropout_rate $cubic [aw=student_count], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg advprof_math10 $cubic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg wkce_math10 $cubic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg log_instate_enr $cubic grade9lagged, absorb(district_code) cluster(district_code)
lincom $tenyr_op


*Proposed Both
areg dropout_rate $cubic [aw=student_count] if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg advprof_math10 $cubic [aw=num_takers_math10] if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg wkce_math10 $cubic [aw=num_takers_math10] if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg log_instate_enr $cubic grade9lagged if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op


*Passed Both
areg dropout_rate $cubic [aw=student_count] if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg advprof_math10 $cubic [aw=num_takers_math10] if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg wkce_math10 $cubic [aw=num_takers_math10] if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op

areg log_instate_enr $cubic grade9lagged if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_op


*****************************************
******TABLE 7 (B)
*****************************************
*Unrestricted
areg dropout_rate $cubic [aw=student_count], absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg advprof_math10 $cubic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg wkce_math10 $cubic [aw=num_takers_math10], absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg log_instate_enr $cubic grade9lagged, absorb(district_code) cluster(district_code)
lincom $tenyr_bond


*Proposed Both
areg dropout_rate $cubic [aw=student_count] if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg advprof_math10 $cubic [aw=num_takers_math10] if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg wkce_math10 $cubic [aw=num_takers_math10] if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg log_instate_enr $cubic grade9lagged if tried_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond


*Passed Both
areg dropout_rate $cubic [aw=student_count] if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg advprof_math10 $cubic [aw=num_takers_math10] if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg wkce_math10 $cubic [aw=num_takers_math10] if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond

areg log_instate_enr $cubic grade9lagged if passed_both==1, absorb(district_code) cluster(district_code)
lincom $tenyr_bond


*****************************************
******TABLE 8
*****************************************
areg advprof_math10 op_win_prev* bond_win_prev* interaction_prev* yrdums* ///
	op_ismeas_prev* bond_ismeas_prev* op_month_prev* bond_month_prev* ///
	op_percent_prev* op_percent2_prev* op_percent3_prev* ///
	bond_percent_prev* bond_percent2_prev* bond_percent3_prev* ///
	recurring_prev* op_numelec_prev* bond_numelec_prev* [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
	
*Operational Referenda
lincom $fiveyr_op

*Bond Referenda
lincom $fiveyr_bond

*Interaction Term
lincom $fiveyr_interaction


areg rev_lim_mem op_win_prev* bond_win_prev* interaction_prev* yrdums* ///
	op_ismeas_prev* bond_ismeas_prev* op_month_prev* bond_month_prev* ///
	op_percent_prev* op_percent2_prev* op_percent3_prev* ///
	bond_percent_prev* bond_percent2_prev* bond_percent3_prev* ///
	recurring_prev* op_numelec_prev* bond_numelec_prev*, ///
	absorb(district_code) cluster(district_code)

*Operational Referenda
lincom $fiveyr_op

*Bond Referenda
lincom $fiveyr_bond

*Interaction Term
lincom $fiveyr_interaction



areg wkce_math10 op_win_prev* bond_win_prev* interaction_prev* yrdums* ///
	op_ismeas_prev* bond_ismeas_prev* op_month_prev* bond_month_prev* ///
	op_percent_prev* op_percent2_prev* op_percent3_prev* ///
	bond_percent_prev* bond_percent2_prev* bond_percent3_prev* ///
	recurring_prev* op_numelec_prev* bond_numelec_prev* [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
	
*Operational Referenda
lincom $fiveyr_op

*Bond Referenda
lincom $fiveyr_bond

*Interaction Term
lincom $fiveyr_interaction



*****************************************
******TABLE B1 (A)
*****************************************
*Mathematics
areg advprof_math10 $cubic [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Quadratic
areg advprof_math10 $quadratic [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Linear
areg advprof_math10 $linear [aw=num_takers_math10], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Reading
*Cubic
areg advprof_reading10 $cubic [aw=num_takers_reading10], ///
	absorb(district_code) cluster(district_code)	
lincom $tenyr_op

*Quadratic
areg advprof_reading10 $quadratic [aw=num_takers_reading10], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Linear
areg advprof_reading10 $linear [aw=num_takers_reading10], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op



*****************************************
******TABLE B1 (B)
*****************************************
*Mathematics
areg advprof_math8 $cubic [aw=num_takers_math8], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Quadratic
areg advprof_math8 $quadratic [aw=num_takers_math8], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Linear
areg advprof_math8 $linear [aw=num_takers_math8], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Reading
*Cubic
areg advprof_reading8 $cubic [aw=num_takers_reading8], ///
	absorb(district_code) cluster(district_code)	
lincom $tenyr_op

*Quadratic
areg advprof_reading8 $quadratic [aw=num_takers_reading8], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Linear
areg advprof_reading8 $linear [aw=num_takers_reading8], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op


*****************************************
******TABLE B1 (C)
*****************************************
*Mathematics
areg advprof_math4 $cubic [aw=num_takers_math4], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Quadratic
areg advprof_math4 $quadratic [aw=num_takers_math4], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Linear
areg advprof_math4 $linear [aw=num_takers_math4], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Reading
*Cubic
areg advprof_reading4 $cubic [aw=num_takers_reading4], ///
	absorb(district_code) cluster(district_code)	
lincom $tenyr_op

*Quadratic
areg advprof_reading4 $quadratic [aw=num_takers_reading4], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op

*Linear
areg advprof_reading4 $linear [aw=num_takers_reading4], ///
	absorb(district_code) cluster(district_code)
lincom $tenyr_op



*****************************************
******TABLE B3 (A)
*****************************************
areg ratio_stdnts_to_staff_licensed $cubic ///
	[aw=number_fte_staff_licensed], absorb(district_code) cluster(district_code)
lincom $fiveyr_op
lincom $tenyr_op
sum ratio_stdnts_to_staff_licensed	

areg AverageLocalExp $cubic, absorb(district_code) cluster(district_code)
lincom $fiveyr_op
lincom $tenyr_op
sum AverageLocalExp [aw=fall_enr]

areg turnover_LA $cubic, absorb(district_code) cluster(district_code)
lincom $fiveyr_op
lincom $tenyr_op
sum turnover_LA [aw=fall_enr]

areg logcomp $cubic, absorb(district_code) cluster(district_code)
lincom $fiveyr_op
lincom $tenyr_op
sum compensation [aw=fall_enr]


*****************************************
******TABLE B3 (B)
*****************************************
areg hi_str $cubic [aw=hi_numteach], absorb(district_code) cluster(district_code)
lincom $fiveyr_op
lincom $tenyr_op
sum hi_str

areg log_hi_avgsal $cubic, absorb(district_code) cluster(district_code)	
lincom $fiveyr_op
lincom $tenyr_op
sum hi_avgsal


*****************************************
******TABLE B3 (C)
*****************************************
areg mid_str $cubic [aw=middle_numteach], absorb(district_code) cluster(district_code)
lincom $fiveyr_op
lincom $tenyr_op
sum mid_str

areg log_middle_avgsal $cubic, absorb(district_code) cluster(district_code)	
lincom $fiveyr_op
lincom $tenyr_op
sum middle_avgsal


*****************************************
******TABLE B3 (D)
*****************************************
areg el_str $cubic [aw=el_numteach], absorb(district_code) cluster(district_code)
lincom $fiveyr_op
lincom $tenyr_op
sum el_str

areg log_el_avgsal $cubic, absorb(district_code) cluster(district_code)	
lincom $fiveyr_op
lincom $tenyr_op
sum el_avgsal



*****************************************
******TABLE B4
*****************************************
areg ratio_stdnts_to_staff_licensed $cubic ///
	[aw=number_fte_staff_licensed], absorb(district_code) cluster(district_code)
lincom $fiveyr_bond
lincom $tenyr_bond
sum ratio_stdnts_to_staff_licensed	

areg AverageLocalExp $cubic, absorb(district_code) cluster(district_code)
lincom $fiveyr_bond
lincom $tenyr_bond
sum AverageLocalExp [aw=fall_enr]

areg turnover_LA $cubic, absorb(district_code) cluster(district_code)
lincom $fiveyr_bond
lincom $tenyr_bond
sum turnover_LA [aw=fall_enr]

areg logcomp $cubic, absorb(district_code) cluster(district_code)
lincom $fiveyr_bond
lincom $tenyr_bond
sum compensation [aw=fall_enr]



*****************************************
******TABLE B5 (A)
*****************************************
areg dropout_rate $linear [aw=student_count], absorb(district_code) cluster(district_code)
test $equality

areg advprof_math10 $linear [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
test $equality

areg wkce_math10 $linear [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
test $equality

areg log_instate_enr $linear grade9lagged, absorb(district_code) cluster(district_code)
test $equality


*****************************************
******TABLE B5 (B)
*****************************************
areg dropout_rate $quadratic [aw=student_count], absorb(district_code) cluster(district_code)
test $equality

areg advprof_math10 $quadratic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
test $equality

areg wkce_math10 $quadratic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
test $equality

areg log_instate_enr $quadratic grade9lagged, absorb(district_code) cluster(district_code)
test $equality


*****************************************
******TABLE B5 (C)
*****************************************
areg dropout_rate $cubic [aw=student_count], absorb(district_code) cluster(district_code)
test $equality

areg advprof_math10 $cubic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
test $equality

areg wkce_math10 $cubic [aw=num_takers_math10], ///
absorb(district_code) cluster(district_code)
test $equality

areg log_instate_enr $cubic grade9lagged, absorb(district_code) cluster(district_code)
test $equality
*/