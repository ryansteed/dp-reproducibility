/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates three tables: 
(1) Table 3, which checks for local balance b/w winning and losing districts
(2) Table 6, which checks for differences b/w districts that pass each type of ref
(3) Table B6, which checks for differences b/w districts that propose each type of ref
DATA INPUTS: (1) ITT Panel
OUTPUT: Table 3, Table 6, Table B6

*********************************/
**Set Globals
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"


*Call Recursive Panel
use "${path}\Data\Final\itt_panel", clear
sort refid school_year


*****************************************
******SECTION I: TABLE 3
*****************************************
***Generate local needed for variables
local z rev_lim_mem tot_exp_mem tot_exp_inst_mem tot_exp_ss_mem ///
tot_exp_oth_mem dropout_rate advprof_math10 wkce_math10 perc_instate

***Generate change from t-2 to t-1
foreach var in `z'{
	by refid: gen d`var' = `var' - `var'[_n-1]
}


***Column 1
eststo clear
foreach var in `z'{
	reg `var' win if dyear==-1, cluster(district_code)
	eststo `var'
}
esttab `var', k(win) b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01) 
mat list r(coefs)
esttab r(coefs, transpose), b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01)


***Column 2
eststo clear
foreach var in `z'{
	reg `var' win if dyear==-1&(perc>=44&perc<=56), cluster(district_code)
	eststo `var'
}
esttab `var', k(win) b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01) 
mat list r(coefs)
esttab r(coefs, transpose), b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01)


***Column 3
eststo clear
foreach var in `z'{
	reg d`var' win if dyear==0, cluster(district_code)
	eststo `var'
}
esttab `var', k(win) b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01) 
mat list r(coefs)
esttab r(coefs, transpose), b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01)


***Column 4
eststo clear
foreach var in `z'{
	reg d`var' win if dyear==0&(perc>=44&perc<=56), cluster(district_code)
	eststo `var'
}
esttab `var', k(win) b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01) 
mat list r(coefs)
esttab r(coefs, transpose), b(2) se(2) ///
star(* 0.10 ** 0.05 *** 0.01)

*****************************************
******SECTION II: TABLE 6
*****************************************
*Generate indicator for operational referendum
gen operational=(bond==0)

*Keep only the relevant year
keep if dyear==-1


preserve

*Keep only referenda that passed
keep if win==1

*Make a global of the relevant variables:
global vars dropout_rate advprof_math10 wkce_math10 perc_instate ratio_stdnts_to_staff_licensed ///
AverageLocalExp compensation turnover_LA prop_val_mem urban_centric_locale 

local z dropout_rate advprof_math10 wkce_math10 perc_instate ratio_stdnts_to_staff_licensed ///
AverageLocalExp compensation turnover_LA prop_val_mem urban_centric_locale 

*Summary stats for districts in t-1 that pass an operational ref in t
sum $vars [aw=membership] ///
if operational==1 & win==1
sum fall_enr if operational==1 & win==1
 
*Summary stats for districts in t-1 that propose a bond ref in t
sum $vars [aw=membership] ///
if bond==1 & win==1
sum fall_enr if bond==1 & win==1
 
*Differences in observables between each
foreach var in `z'{
reg `var' operational if win==1 [aw=membership], cluster(district_code)
 }
reg fall_enr operational if win==1, cluster(district_code)
restore


*****************************************
******SECTION III: TABLE B6
*****************************************
*Summary stats for districts in t-1 that propose an operational ref in t
sum $vars [aw=membership] ///
if operational==1
sum fall_enr if operational==1

*Summary stats for districts in t-1 that propose a bond ref in t
sum $vars [aw=membership] ///
if bond==1
sum fall_enr if bond==1
 
*Differences in observables between each
foreach var in `z'{
reg `var' operational [aw=membership], cluster(district_code)
 }
reg fall_enr operational, cluster(district_code)
