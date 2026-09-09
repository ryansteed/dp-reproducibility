clear
set more off 
set mem 5g

use analysis_teacher

keep if year<=1997

drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
replace treated_grades=0 if treated_grades==.

* See Which Grades New Teachers Teach in *

summ teach_1 teach_2 teach_3 teach_4 teach_5 teach_6 teach_7 teach_8 if exp_fix<=1 & year<1994
summ teach_1 teach_2 teach_3 teach_4 teach_5 teach_6 teach_7 teach_8 if exp_fix<=1 & (year==1994 | year==1995)

* Look at Grade Switching - Mean Experience by Grade and treatment status *

use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_1], by(yr)
list 
use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_2], by(yr)
list 
use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_3], by(yr)
list 
use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_4], by(yr)
list 
use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_5], by(yr)
list 
use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_6], by(yr)
list 
use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_7], by(yr)
list 
use analysis_teacher, clear
keep if year<=1995
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0
gen yr=year<1994
collapse (mean) exp_fix [aw=teach_8], by(yr)
list 

* Look at Grade Switching - Do Teachers Switch Grades? *

gen temp=year<1994
egen pre_tchr=max(temp), by(uniqueID)
drop temp

gen temp=year>=1994
egen post_tchr=max(temp), by(uniqueID)
drop temp

gen temp=1 if (teach_3~=0 | teach_6~=0 | teach_8~=0) & year<1994
replace temp=0 if temp==.
egen pre_tested=max(temp), by(uniqueID)
drop temp

gen temp=1 if (teach_3~=0 | teach_6~=0 | teach_8~=0) & year>=1994
replace temp=0 if temp==.
egen post_tested=max(temp), by(uniqueID)
drop temp

egen tchrflag=tag(uniqueID)
tab pre_tested post_tested if pre_tchr==1 & post_tchr==1 & tchrflag==1

gen temp=exp_fix if year<1994
egen exp_pre=max(exp_fix), by(uniqueID)
drop temp

summ exp_pre if pre_tested==1 & post_tested==0 & tchrflag==1 & pre_tchr==1 & post_tchr==1
summ exp_pre if pre_tested==0 & post_tested==1 & tchrflag==1 & pre_tchr==1 & post_tchr==1
summ exp_pre if ((pre_tested==1 & post_tested==1) | (pre_tested==0 & post_tested==0)) & tchrflag==1 & pre_tchr==1 & post_tchr==1

tab exp_pre if pre_tested==1 & post_tested==0 & tchrflag==1 & pre_tchr==1 & post_tchr==1
tab exp_pre if pre_tested==0 & post_tested==1 & tchrflag==1 & pre_tchr==1 & post_tchr==1
tab exp_pre if ((pre_tested==1 & post_tested==1) | (pre_tested==0 & post_tested==0)) & tchrflag==1 & pre_tchr==1 & post_tchr==1

* Look by Percent With 15 or more years experience *

gen temp=exp_fix if year<1994
gen above15=1 if exp_fix>=15 & exp_fix~=.
replace above15=0 if above15==. & exp_fix~=.
egen pctabove_yr=mean(above15), by(rcds_fix year)
egen pctabove=mean(pctabove_yr), by(rcds_fix)

tab exp_pre if pre_tested==1 & post_tested==0 & tchrflag==1 & pre_tchr==1 & post_tchr==1 & pctabove<.4240838 & pctabove~=.
tab exp_pre if pre_tested==0 & post_tested==1 & tchrflag==1 & pre_tchr==1 & post_tchr==1 & pctabove<.4240838 & pctabove~=.
tab exp_pre if ((pre_tested==1 & post_tested==1) | (pre_tested==0 & post_tested==0)) & tchrflag==1 & pre_tchr==1 & post_tchr==1 & pctabove<.4240838 & pctabove~=.

tab exp_pre if pre_tested==1 & post_tested==0 & tchrflag==1 & pre_tchr==1 & post_tchr==1 & pctabove>.632 & pctabove~=.
tab exp_pre if pre_tested==0 & post_tested==1 & tchrflag==1 & pre_tchr==1 & post_tchr==1 & pctabove>.632 & pctabove~=.
tab exp_pre if ((pre_tested==1 & post_tested==1) | (pre_tested==0 & post_tested==0)) & tchrflag==1 & pre_tchr==1 & post_tchr==1 & pctabove>.632 & pctabove~=.

* Look at Grade Switching - Experience Distributions by Grade and treatment status (These results are mentioned in the text) *

use analysis_teacher, clear
keep if year<=1997
drop if teach_1==0 & teach_2==0 & teach_3==0 & teach_4==0 & teach_5==0 & teach_6==0 & teach_7==0 & teach_8==0

tab exp_fix if year<1994 & teach_1~=0 [aw=teach_1]
tab exp_fix if (year==1994 | year==1995) & teach_1~=0 [aw=teach_1]

tab exp_fix if year<1994 & teach_2~=0 [aw=teach_2]
tab exp_fix if (year==1994 | year==1995) & teach_2~=0 [aw=teach_2]

tab exp_fix if year<1994 & teach_3~=0 [aw=teach_3]
tab exp_fix if (year==1994 | year==1995) & teach_3~=0 [aw=teach_3]

tab exp_fix if year<1994 & teach_4~=0 [aw=teach_4]
tab exp_fix if (year==1994 | year==1995) & teach_4~=0 [aw=teach_4]

tab exp_fix if year<1994 & teach_5~=0 [aw=teach_5]
tab exp_fix if (year==1994 | year==1995) & teach_5~=0 [aw=teach_5]

tab exp_fix if year<1994 & teach_6~=0 [aw=teach_1]
tab exp_fix if (year==1994 | year==1995) & teach_6~=0 [aw=teach_6]

tab exp_fix if year<1994 & teach_7~=0 [aw=teach_7]
tab exp_fix if (year==1994 | year==1995) & teach_7~=0 [aw=teach_7]

tab exp_fix if year<1994 & teach_8~=0 [aw=teach_8]
tab exp_fix if (year==1994 | year==1995) & teach_8~=0 [aw=teach_8]



