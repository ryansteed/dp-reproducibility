
************************************************************************
************************************************************************
***** This program runs regressions on Brazilian 1997-1970AMC data *****
************************************************************************
************************************************************************


clear matrix

clear
set more 1
set mem 500m

local table = 0

************************
* Table: Summary stats *
************************

set more 1
local table = `table'+1

use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997
collapse (mean) gdpcap2002 mun_budget_revenue_cap2000 population2000 latitude longitude dist_federal_capital state_capital dist_state_capital oilandgasvalue2000_cap (p90) p90_oilandgasvalue2000_cap=oilandgasvalue2000_cap (p95) p95_oilandgasvalue2000_cap=oilandgasvalue2000_cap (max) max_oilandgasvalue2000_cap=oilandgasvalue2000_cap (count) count=iron if instrument==0 & coastal==1
save table`table'a, replace

use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997
collapse (mean) gdpcap2002 mun_budget_revenue_cap2000 population2000 latitude longitude dist_federal_capital state_capital dist_state_capital oilandgasvalue2000_cap (p90) p90_oilandgasvalue2000_cap=oilandgasvalue2000_cap (p95) p95_oilandgasvalue2000_cap=oilandgasvalue2000_cap (max) max_oilandgasvalue2000_cap=oilandgasvalue2000_cap (count) count=iron if (onshore==0 &  offshore==1)
save table`table'b, replace





**************************************************************************************************
* Table: Test of conditional random assignment: outcomes in 1970 regressed on oil output in 2000 *
**************************************************************************************************


set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997

gen cap_residential1970c =  cap_residential1970/population1970
gen cap_residential2000c =  cap_residential2000/population2000

* use literacy as opposed to illiteracy so all positive outcomes are "good"
gen lit_15plus_till91_pct1970 = 100 - illit_15plus_till91_pct1970

* For this table we'll use oilandgasvalue2000_cap in thousands of R$2000
replace oilandgasvalue2000_cap = oilandgasvalue2000_cap/(10^3)
replace gdpcap1970 = gdpcap1970/(10^3)

* "Family of outcomes" zscore as in Kling, Leibman, and Katz "EXPERIMENTAL ANALYSIS OF NEIGHBORHOOD EFFECTS" (Econometrica 2007)
gen zscore = 0
foreach var of varlist years_school_till91_avg1970 lit_15plus_till91_pct1970 cap_residential1970c p_households_elect_light1970 p_households_sanit_instal1970 p_households_canal_water1970 gdpcap1970 {
egen m`var' = mean(`var') if (onshore==0 | onshore==.)
egen s`var' = sd(`var') if (onshore==0 | onshore==.)
gen n`var' = (`var'-m`var')/s`var' if (onshore==0 | onshore==.)
replace zscore= zscore+ n`var'
drop m`var' s`var' n`var'
} 

xi i.sig

foreach num of numlist 1(1)8 {


if `num'==1 {
areg gdpcap1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==2 {
areg years_school_till91_avg1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==3 {
areg lit_15plus_till91_pct1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==4 {
areg cap_residential1970c oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==5 {
areg p_households_elect_light1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==6 {
areg p_households_sanit_instal1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==7 {
areg p_households_canal_water1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==8 {
areg zscore oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}


matrix c=e(b)'
svmat double c, name(bvector)
matrix d=e(V)
matrix v`table'=vecdiag(d)'
svmat double v`table', name(vvector)
gen reg`table'_`num'b=bvector1
gen reg`table'_`num'e=vvector1^.5
drop bvector1 vvector1
gen reg`table'_`num'N=e(N)
replace reg`table'_`num'N=. if _n>1
}

keep reg*
foreach num of numlist 1(1)8 {
 gen reg`table'_`num'= reg`table'_`num'b[_n/2] if int(_n/2)==_n/2
 replace reg`table'_`num'= reg`table'_`num'e[_n/2] if int(_n/2)~=_n/2
 replace reg`table'_`num'=reg`table'_`num'N if _n==1
* drop reg`table'_`num'b reg`table'_`num'e reg`table'_`num'N
}

keep reg`table'_1- reg`table'_8
save table`table', replace



**************************************************************************************************
* Table: GDP components per capita and oil and gas revenues per capita regressed on oil revenues *
**************************************************************************************************

set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997

xi i.sig

foreach num of numlist 2002(1)2002 {
 gen gdp_ind_cap`num' =  gdp_ind`num'/population`num'
 gen gdp_nonind_cap`num' =  (gdp`num'-gdp_ind`num')/population`num'
}

foreach num of numlist 1(1)3 {


if `num'==1 {
areg gdpcap2002 oilandgasvalue2002_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==2 {
areg gdp_ind_cap2002 oilandgasvalue2002_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==3 {
areg gdp_nonind_cap2002 oilandgasvalue2002_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}


matrix c=e(b)'
svmat double c, name(bvector)
matrix d=e(V)
matrix v`table'=vecdiag(d)'
svmat double v`table', name(vvector)
gen reg`table'_`num'b=bvector1
gen reg`table'_`num'e=vvector1^.5
drop bvector1 vvector1
gen reg`table'_`num'N=e(N)
replace reg`table'_`num'N=. if _n>1
}

keep reg*
foreach num of numlist 1(1)3 {
 gen reg`table'_`num'= reg`table'_`num'b[_n/2] if int(_n/2)==_n/2
 replace reg`table'_`num'= reg`table'_`num'e[_n/2] if int(_n/2)~=_n/2
 replace reg`table'_`num'=reg`table'_`num'N if _n==1
* drop reg`table'_`num'b reg`table'_`num'e reg`table'_`num'N
}

keep reg`table'_1- reg`table'_3

save table`table', replace










*************************************************************
* Table: oil revenues, royalites, and municipality revenues *
*************************************************************

set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997
*** EDIT BY Donna
sort new_code_1970_1997
* Predict municipality revenues per capita in 2000  
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
* Predict missing 1991 values using 1992
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000

areg mun_budget_revenue1991 mun_budget_revenue1992 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue1991 mun_budget_revenue1992, robust 
predict mun_budget_revenue1991_pred
replace mun_budget_revenue1991_pred =  mun_budget_revenue1991 if  mun_budget_revenue1991!=.
gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991

gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c

xi i.sig

foreach num of numlist 1(1)1 {

 if `num'==1 {
  local varcode = 0
  foreach var of varlist mun_budget_revenue_cap2000 mun_budget_revenue2000_pred_c pred_chmun_budget_revenue_cap {
   if `varcode'==2 {
   local varcode = `varcode'+1
   areg royalties2000_cap oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & mun_budget_revenue2000_pred_c!=. & coastal==1, robust a(sig)
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
   }
   local varcode = `varcode'+1
   eststo: areg `var' oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }


}

*** EDITED by Ryan
save final1.dta, replace
***

keep r1*

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear

foreach num of numlist 1(1)1 {
 foreach num2 of numlist 1(1)4 {
  gen reg`num'_`num2'= r`num'_`num2'b[_n/2] if int(_n/2)==_n/2
  replace reg`num'_`num2'= r`num'_`num2'e[_n/2] if int(_n/2)~=_n/2
  replace reg`num'_`num2'= r`num'_`num2'N if _n==1
 }
}

keep reg*

order reg1_1 reg1_2 reg1_3 reg1_4    

save table`table', replace

  
 
 


***********************************************************************************
* Table: oil revenues, municipal revenues, and municipal expenditures by category *
***********************************************************************************
eststo clear
set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997
*** EDIT BY Donna
sort new_code_1970_1997
* Predict municipality revenues per capita in 2000  
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
* Predict missing 1991 values using 1992
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000

areg mun_budget_revenue1991 mun_budget_revenue1992 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue1991 mun_budget_revenue1992, robust 
predict mun_budget_revenue1991_pred
replace mun_budget_revenue1991_pred =  mun_budget_revenue1991 if  mun_budget_revenue1991!=.
gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991

gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c




* Predict municipality expenditures per capita in 2000 in each expenditure category
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of expenditures in 2001 on expenditures in 2000
* Predict missing 1991 values using 1992 values

foreach var of newlist educ_cult health_sanit hous_urban transport welf {
 reg mun_exp_funct_`var'2000 mun_exp_funct_`var'2001
 predict pmun_exp_funct_`var'2000
 replace pmun_exp_funct_`var'2000 = mun_exp_funct_`var'2000 if mun_exp_funct_`var'2000!=.
 gen pmun_exp_funct_`var'2000c = pmun_exp_funct_`var'2000 / population2000

 reg mun_exp_funct_`var'1991 mun_exp_funct_`var'1992
 predict pmun_exp_funct_`var'1991
 replace pmun_exp_funct_`var'1991 = mun_exp_funct_`var'1991 if mun_exp_funct_`var'1991!=.
 gen pmun_exp_funct_`var'1991c = pmun_exp_funct_`var'1991 / population1991

 gen ch_pmun_exp_funct_`var'_c = pmun_exp_funct_`var'2000c-pmun_exp_funct_`var'1991c
}


 reg mun_exp_funct2000 mun_exp_funct2001
 predict pmun_exp_funct2000
 replace pmun_exp_funct2000 = mun_exp_funct2000 if mun_exp_funct2000!=.
 gen pmun_exp_funct2000c = pmun_exp_funct2000 / population2000
 reg mun_exp_funct1991 mun_exp_funct1992
 predict pmun_exp_funct1991
 replace pmun_exp_funct1991 = mun_exp_funct1991 if mun_exp_funct1991!=.
 gen pmun_exp_funct1991c = pmun_exp_funct1991 / population1991
 gen ch_pmun_exp_funct_c = pmun_exp_funct2000c-pmun_exp_funct1991c

xi i.sig

foreach num of numlist 1(1)4 {

 if `num'==1 {
  local varcode = 0
  foreach var of varlist pmun*2000c {
   local varcode = `varcode'+1
   reg `var' mun_budget_revenue2000_pred_c longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust 
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 if `num'==2 {
  local varcode = 0
   reg mun_budget_revenue2000_pred_c oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust 
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1

  foreach var of varlist pmun*2000c {
   local varcode = `varcode'+1
   eststo: ivreg `var' (mun_budget_revenue2000_pred_c=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust 
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 
 if `num'==3 {
  local varcode = 0
  foreach var of varlist ch_pmun*exp*_c {
   local varcode = `varcode'+1
   reg `var' pred_chmun_budget_revenue_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust 
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 if `num'==4 {
  local varcode = 0
   reg pred_chmun_budget_revenue_cap oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & ch_pmun_exp_funct_educ_cult!=. & coastal==1, robust 
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1

  foreach var of varlist ch_pmun*exp*_c {
   local varcode = `varcode'+1
   ivreg `var' (pred_chmun_budget_revenue_cap=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust 
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }


}

*** EDITED by Ryan
save final2.dta, replace
***
keep r1* r2* r3* r4*

*** EDITED by Donna
estout using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
exit

foreach num of numlist 1(1)4 {
 foreach num2 of numlist 1(1)6 {
  if (`num'==2 | `num'==4) & `num2'==1 {
   gen reg`num'_0= r`num'_0b[_n/2] if int(_n/2)==_n/2
   replace reg`num'_0= r`num'_0e[_n/2] if int(_n/2)~=_n/2
   replace reg`num'_0= r`num'_0N if _n==1
  }
  gen reg`num'_`num2'= r`num'_`num2'b[_n/2] if int(_n/2)==_n/2
  replace reg`num'_`num2'= r`num'_`num2'e[_n/2] if int(_n/2)~=_n/2
  replace reg`num'_`num2'= r`num'_`num2'N if _n==1
 }
}

keep reg*
drop reg*_0
save table`table', replace






***********************************************************************************
* Table: effect of local government revenues from offshore oil on housing quality *
***********************************************************************************


set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997

* Add number of rooms data
use domicile2000.dta, clear
keep new_code_1970_1997 rooms* people*
foreach var of varlist rooms people rooms_municipal people_municipal rooms_16to64 people_16to64 {
 rename `var' `var'_2000
}
sort new_code_1970_1997
merge new_code_1970_1997 using domicile1991.dta
keep new_code_1970_1997 rooms* people*
foreach var of varlist rooms people rooms_municipal people_municipal rooms_16to64 people_16to64 {
 rename `var' `var'_1991
}
sort new_code_1970_1997
merge new_code_1970_1997 using amc9770.dta
drop _m


* Predict municipality revenues per capita in 2000  
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
* Predict missing 1991 values using 1992
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000

areg mun_budget_revenue1991 mun_budget_revenue1992 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue1991 mun_budget_revenue1992, robust 
predict mun_budget_revenue1991_pred
replace mun_budget_revenue1991_pred =  mun_budget_revenue1991 if  mun_budget_revenue1991!=.
gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991

gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c


gen rooms_2000_16to64 = rooms_16to64_2000/people_16to64_2000
gen rooms_1991_16to64 = rooms_16to64_1991/people_16to64_1991
gen ch_rooms_16to64 = rooms_2000_16to64 - rooms_1991_16to64


gen cap_residential2000_c =  cap_residential2000/population2000
gen cap_residential1991_c =  cap_residential1991/population1991
gen ch_cap_residential_c = cap_residential2000_c - cap_residential1991_c

foreach var of varlist rooms_2000_16to64 rooms_1991_16to64 ch_rooms_16to64 {
 replace `var' = `var'*1000
}


gen zero=0

foreach var of varlist km* {
replace `var' = `var'*1000000
}


xi i.sig

gen  p_hhld_abovestrandard_ppl_1991 = 100- prc_hhld_substandard_ppl_1991
gen  p_hhld_abovestrandard_ppl_2000 = 100- prc_hhld_substandard_ppl_2000

foreach var of new p_hhld_abovestrandard_ppl_ prc_hhld_with_power_ prc_hhld_garbage_serv_  prc_hhld_pipedwater_ p_households_sanit_instal p_households_canal_water {
 gen ch_`var' = `var'2000 - `var'1991
}


* "Family of outcomes" zscore as in Kling, Leibman, and Katz "EXPERIMENTAL ANALYSIS OF NEIGHBORHOOD EFFECTS" (Econometrica 2007)
gen zscore = 0
foreach var of varlist cap_residential2000_c rooms_2000_16to64 p_hhld_abovestrandard_ppl_2000 prc_hhld_with_power_2000 prc_hhld_garbage_serv_2000 prc_hhld_pipedwater_2000 p_households_canal_water2000 p_households_sanit_instal2000 km_paved_munic_c {
egen m`var' = mean(`var') if (onshore==0 | onshore==.)
egen s`var' = sd(`var') if (onshore==0 | onshore==.)
gen n`var' = (`var'-m`var')/s`var' if (onshore==0 | onshore==.)
replace zscore= zscore+ n`var'
drop m`var' s`var' n`var'
} 


gen chzscore = 0
foreach var of var ch_cap_residential_c ch_rooms_16to64 ch_p_hhld_abovestrandard_ppl_ ch_prc_hhld_with_power_ ch_prc_hhld_garbage_serv_ ch_prc_hhld_pipedwater_ ch_p_households_canal_water ch_p_households_sanit_instal {
egen m`var' = mean(`var') if (onshore==0 | onshore==.)
egen s`var' = sd(`var') if (onshore==0 | onshore==.)
gen n`var' = (`var'-m`var')/s`var' if (onshore==0 | onshore==.)
replace chzscore= chzscore+ n`var'
drop m`var' s`var' n`var'
} 


foreach num of numlist 1(1)6 {

 if `num'==1 {
  local varcode = 0
  foreach var of varlist cap_residential2000_c rooms_2000_16to64 p_hhld_abovestrandard_ppl_2000 prc_hhld_with_power_2000 prc_hhld_garbage_serv_2000 prc_hhld_pipedwater_2000 p_households_canal_water2000 p_households_sanit_instal2000 km_paved_munic_c zscore {
   local varcode = `varcode'+1
   reg `var' mun_budget_revenue2000_pred_c longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }

 if `num'==2 {
  local varcode = 0
   reg mun_budget_revenue2000_pred_c oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of varlist cap_residential2000_c rooms_2000_16to64 p_hhld_abovestrandard_ppl_2000 prc_hhld_with_power_2000 prc_hhld_garbage_serv_2000 prc_hhld_pipedwater_2000 p_households_canal_water2000 p_households_sanit_instal2000 km_paved_munic_c zscore {
   local varcode = `varcode'+1
   ivreg `var' (mun_budget_revenue2000_pred_c=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }

 
 if `num'==3 {
  local varcode = 0
  foreach var of var ch_cap_residential_c ch_rooms_16to64 ch_p_hhld_abovestrandard_ppl_ ch_prc_hhld_with_power_ ch_prc_hhld_garbage_serv_ ch_prc_hhld_pipedwater_ ch_p_households_canal_water ch_p_households_sanit_instal zero chzscore {
   local varcode = `varcode'+1
   reg `var' pred_chmun_budget longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }

 if `num'==4 {
  local varcode = 0
   reg pred_chmun_budget oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of var ch_cap_residential_c ch_rooms_16to64 ch_p_hhld_abovestrandard_ppl_ ch_prc_hhld_with_power_ ch_prc_hhld_garbage_serv_ ch_prc_hhld_pipedwater_ ch_p_households_canal_water ch_p_households_sanit_instal zero chzscore {
   local varcode = `varcode'+1
   ivreg `var' (pred_chmun_budget=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }

}
keep r1* r2* r3* r4*



foreach num of numlist 1(1)4 {
 foreach num2 of numlist 0(1)10 {
  if (`num'!=1 & `num'!=3) | `num2'!=0 {
   gen reg`num'_`num2'= r`num'_`num2'b[_n/2] if int(_n/2)==_n/2
   replace reg`num'_`num2'= r`num'_`num2'e[_n/2] if int(_n/2)~=_n/2
   replace reg`num'_`num2'= r`num'_`num2'N if _n==1
  }
 }
}

keep reg*
drop reg*_0
save table`table', replace







**************************************************************************************
* Table: effect oil revenues on provision of education and health inputs and welfare *
**************************************************************************************

set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997

* Predict municipality revenues per capita in 2000  
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
* Predict missing 1991 values using 1992
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000

areg mun_budget_revenue1991 mun_budget_revenue1992 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue1991 mun_budget_revenue1992, robust 
predict mun_budget_revenue1991_pred
replace mun_budget_revenue1991_pred =  mun_budget_revenue1991 if  mun_budget_revenue1991!=.
gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991

gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c


* Municipal teachers, classrooms, and health establishments per million residents
foreach var of varlist clroomsMunicipal_pop* teachersMunicipal_pop* estab_mun*_with* {
 replace `var' = `var'*1000000
}

gen ch_teachersMunicipal_pop2000 = teachersMunicipal_pop2000 - teachersMunicipal_pop1996
gen ch_clroomsMunicipal_pop2000 = clroomsMunicipal_pop2000 - clroomsMunicipal_pop1996
gen ch_teachersMunicipal_pop2005 = teachersMunicipal_pop2005 - teachersMunicipal_pop1996
gen ch_clroomsMunicipal_pop2005 = clroomsMunicipal_pop2005 - clroomsMunicipal_pop1996
gen ch_estab_mun_with_pop = estab_mun2002_with_pop - estab_mun1992_with_pop
gen ch_estab_mun_without_pop = estab_mun2002_without_pop - estab_mun1992_without_pop
gen one = 1


xi i.sig

* "Family of outcomes" zscore as in Kling, Leibman, and Katz "EXPERIMENTAL ANALYSIS OF NEIGHBORHOOD EFFECTS" (Econometrica 2007)
gen zscore = 0
  foreach var of varlist teachersMunicipal_pop2000 clroomsMunicipal_pop2000 teachersMunicipal_pop2005 clroomsMunicipal_pop2005 estab_mun2002_with_pop estab_mun2002_without_pop welfare_2000_c {
egen m`var' = mean(`var') if (onshore==0 | onshore==.)
egen s`var' = sd(`var') if (onshore==0 | onshore==.)
gen n`var' = (`var'-m`var')/s`var' if (onshore==0 | onshore==.)
replace zscore= zscore+ n`var'
drop m`var' s`var' n`var'
} 

gen chzscore = 0
foreach var of var ch_teachersMunicipal_pop2000 ch_clroomsMunicipal_pop2000 ch_teachersMunicipal_pop2005 ch_clroomsMunicipal_pop2005 ch_estab_mun_with_pop ch_estab_mun_without_pop {
egen m`var' = mean(`var') if (onshore==0 | onshore==.)
egen s`var' = sd(`var') if (onshore==0 | onshore==.)
gen n`var' = (`var'-m`var')/s`var' if (onshore==0 | onshore==.)
replace chzscore= chzscore+ n`var'
drop m`var' s`var' n`var'
} 


foreach num of numlist 1(1)6 {

 if `num'==1 {
  local varcode = 0
  foreach var of varlist teachersMunicipal_pop2000 clroomsMunicipal_pop2000 teachersMunicipal_pop2005 clroomsMunicipal_pop2005 estab_mun2002_with_pop estab_mun2002_without_pop welfare_2000_c zscore {
   local varcode = `varcode'+1
   reg `var' mun_budget_revenue2000_pred_c longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }

 if `num'==2 {
  local varcode = 0
   reg mun_budget_revenue2000_pred_c oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of varlist teachersMunicipal_pop2000 clroomsMunicipal_pop2000 teachersMunicipal_pop2005 clroomsMunicipal_pop2005 estab_mun2002_with_pop estab_mun2002_without_pop welfare_2000_c zscore {
   local varcode = `varcode'+1
   ivreg `var' (mun_budget_revenue2000_pred_c=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 
 if `num'==3 {
  local varcode = 0
  foreach var of var ch_teachersMunicipal_pop2000 ch_clroomsMunicipal_pop2000 ch_teachersMunicipal_pop2005 ch_clroomsMunicipal_pop2005 ch_estab_mun_with_pop ch_estab_mun_without_pop one chzscore {
   local varcode = `varcode'+1
   reg `var' pred_chmun_budget longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 
 if `num'==4 {
  local varcode = 0
   reg pred_chmun_budget oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of var ch_teachersMunicipal_pop2000 ch_clroomsMunicipal_pop2000 ch_teachersMunicipal_pop2005 ch_clroomsMunicipal_pop2005 ch_estab_mun_with_pop ch_estab_mun_without_pop one chzscore {
   local varcode = `varcode'+1
   ivreg `var' (pred_chmun_budget=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }


}
keep r1* r2* r3* r4*


foreach num of numlist 1(1)4 {
 foreach num2 of numlist 0(1)8 {
  if (`num'!=1 & `num'!=3) | `num2'!=0 {
   gen reg`num'_`num2'= r`num'_`num2'b[_n/2] if int(_n/2)==_n/2
   replace reg`num'_`num2'= r`num'_`num2'e[_n/2] if int(_n/2)~=_n/2
   replace reg`num'_`num2'= r`num'_`num2'N if _n==1
  }
 }
}

keep reg*
drop reg*_0
save table`table', replace











*************************************************************************************
* Table: effect of local government revenues from offshore oil on household income  *
*************************************************************************************


set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997

xi i.sig
gen chpercent_very_poor = percent_very_poor2000 - percent_very_poor1991
gen chpercent_poor = percent_poor2000 - percent_poor1991

* Predict municipality revenues per capita in 2000 (and change relative to 1991) 
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000
gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue_cap1991


gen ch_incomeall_c = incomeall_2000_c - incomeall_1991_c
gen ch_n_incomeall_c = n_incomeall_2000_c - n_incomeall_1991_c
foreach num of numlist 1/5 {
 gen ch_domincome_pc`num' = domincome_pc`num'_2000 -  domincome_pc`num'_1991
 gen ch_n_domincome_pc`num' = n_domincome_pc`num'_2000 - n_domincome_pc`num'_1991
}


gen p_poor2000 = 100*poor_dom_2000/pop_2000
gen p_poor1991 = 100*poor_dom_1991/pop_1991
gen p_n_poor2000 = 100*n_poor_dom_2000/n_pop_2000
gen p_n_poor1991 = 100*n_poor_dom_1991/n_pop_1991
gen ch_p_poor =  p_poor2000- p_poor1991
gen ch_p_n_poor =  p_n_poor2000- p_n_poor1991


foreach num of numlist 1(1)6 {

 if `num'==1 {
  local varcode = 0
  foreach var of varlist incomeall_2000_c domincome_pc*2000 p_poor2000 {
   local varcode = `varcode'+1
   reg `var' mun_budget_revenue2000_pred_c longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 
 if `num'==2 {
  local varcode = 0
   reg mun_budget_revenue2000_pred_c oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of varlist incomeall_2000_c domincome_pc*2000 p_poor2000 {
   local varcode = `varcode'+1
   ivreg `var' (mun_budget_revenue2000_pred_c=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 
 if `num'==3 {
  local varcode = 0
  foreach var of varlist ch_incomeall_c ch_domincome_pc* ch_p_poor {
   local varcode = `varcode'+1
   reg `var' pred_chmun_budget longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 
 if `num'==4 {
  local varcode = 0
   reg pred_chmun_budget oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of varlist ch_incomeall_c ch_domincome_pc* ch_p_poor {
   local varcode = `varcode'+1
   ivreg `var' (pred_chmun_budget=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }



}
keep r1* r2* r3* r4*


foreach num of numlist 1(1)4 {
 foreach num2 of numlist 0(1)7 {
  if (`num'!=1 & `num'!=3) | `num2'!=0 {
   gen reg`num'_`num2'= r`num'_`num2'b[_n/2] if int(_n/2)==_n/2
   replace reg`num'_`num2'= r`num'_`num2'e[_n/2] if int(_n/2)~=_n/2
   replace reg`num'_`num2'= r`num'_`num2'N if _n==1
  }
 }
}

keep reg*
drop reg*_0
save table`table', replace




***************************
***************************
***** Appendix Tables *****
***************************
***************************


local table = 0



**************************************
* Table: extended summary statistics *
**************************************

set more 1
local table = `table'+1

* Number of rooms data
use domicile2000.dta, clear
keep new_code_1970_1997 rooms* people*
foreach var of varlist rooms people rooms_municipal people_municipal rooms_16to64 people_16to64 {
 rename `var' `var'_2000
}
sort new_code_1970_1997
merge new_code_1970_1997 using domicile1991.dta
keep new_code_1970_1997 rooms* people*
foreach var of varlist rooms people rooms_municipal people_municipal rooms_16to64 people_16to64 {
 rename `var' `var'_1991
}
sort new_code_1970_1997
merge new_code_1970_1997 using amc9770.dta
drop _m


* Predict municipality revenues per capita in 2000  
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
* Predict missing 1991 values using 1992
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000

areg mun_budget_revenue1991 mun_budget_revenue1992 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue1991 mun_budget_revenue1992, robust 
predict mun_budget_revenue1991_pred
replace mun_budget_revenue1991_pred =  mun_budget_revenue1991 if  mun_budget_revenue1991!=.
gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991

gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c


gen rooms_2000_16to64 = rooms_16to64_2000/people_16to64_2000
gen rooms_1991_16to64 = rooms_16to64_1991/people_16to64_1991
gen ch_rooms_16to64 = rooms_2000_16to64 - rooms_1991_16to64


gen cap_residential2000_c =  cap_residential2000/population2000
gen cap_residential1991_c =  cap_residential1991/population1991
gen ch_cap_residential_c = cap_residential2000_c - cap_residential1991_c

foreach var of varlist rooms_2000_16to64 rooms_1991_16to64 ch_rooms_16to64 {
 replace `var' = `var'*1000
}

foreach var of varlist km*_munic* {
replace `var' = `var'*1000000
}



gen  p_hhld_abovestrandard_ppl_1991 = 100- prc_hhld_substandard_ppl_1991
gen  p_hhld_abovestrandard_ppl_2000 = 100- prc_hhld_substandard_ppl_2000

foreach var of new p_hhld_abovestrandard_ppl_ prc_hhld_with_power_ prc_hhld_garbage_serv_  prc_hhld_pipedwater_ p_households_sanit_instal p_households_canal_water {
 gen ch_`var' = `var'2000 - `var'1991
}


gen cap_residential1970c =  cap_residential1970/population1970
gen cap_residential2000c =  cap_residential2000/population2000

* use literacy as opposed to illiteracy so all positive outcomes are "good"
gen lit_15plus_till91_pct1970 = 100 - illit_15plus_till91_pct1970


foreach num of numlist 2002(1)2002 {
 gen gdp_ind_cap`num' =  gdp_ind`num'/population`num'
 gen gdp_nonind_cap`num' =  (gdp`num'-gdp_ind`num')/population`num'
}



* Predict municipality expenditures per capita in 2000 in each expenditure category
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of expenditures in 2001 on expenditures in 2000
* Predict missing 1991 values using 1992 values

foreach var of newlist educ_cult health_sanit hous_urban transport welf {
 reg mun_exp_funct_`var'2000 mun_exp_funct_`var'2001
 predict pmun_exp_funct_`var'2000
 replace pmun_exp_funct_`var'2000 = mun_exp_funct_`var'2000 if mun_exp_funct_`var'2000!=.
 gen pmun_exp_funct_`var'2000c = pmun_exp_funct_`var'2000 / population2000

 reg mun_exp_funct_`var'1991 mun_exp_funct_`var'1992
 predict pmun_exp_funct_`var'1991
 replace pmun_exp_funct_`var'1991 = mun_exp_funct_`var'1991 if mun_exp_funct_`var'1991!=.
 gen pmun_exp_funct_`var'1991c = pmun_exp_funct_`var'1991 / population1991

 gen ch_pmun_exp_funct_`var'_c = pmun_exp_funct_`var'2000c-pmun_exp_funct_`var'1991c
}


 reg mun_exp_funct2000 mun_exp_funct2001
 predict pmun_exp_funct2000
 replace pmun_exp_funct2000 = mun_exp_funct2000 if mun_exp_funct2000!=.
 gen pmun_exp_funct2000c = pmun_exp_funct2000 / population2000
 reg mun_exp_funct1991 mun_exp_funct1992
 predict pmun_exp_funct1991
 replace pmun_exp_funct1991 = mun_exp_funct1991 if mun_exp_funct1991!=.
 gen pmun_exp_funct1991c = pmun_exp_funct1991 / population1991
 gen ch_pmun_exp_funct_c = pmun_exp_funct2000c-pmun_exp_funct1991c
 
 
 
* Municipal teachers, classrooms, and health establishments per million residents
foreach var of varlist clroomsMunicipal_pop* teachersMunicipal_pop* estab_mun*_with* {
 replace `var' = `var'*1000000
}

gen ch_teachersMunicipal_pop2000 = teachersMunicipal_pop2000 - teachersMunicipal_pop1996
gen ch_clroomsMunicipal_pop2000 = clroomsMunicipal_pop2000 - clroomsMunicipal_pop1996
gen ch_teachersMunicipal_pop2005 = teachersMunicipal_pop2005 - teachersMunicipal_pop1996
gen ch_clroomsMunicipal_pop2005 = clroomsMunicipal_pop2005 - clroomsMunicipal_pop1996
gen ch_estab_mun_with_pop = estab_mun2002_with_pop - estab_mun1992_with_pop
gen ch_estab_mun_without_pop = estab_mun2002_without_pop - estab_mun1992_without_pop


* Household income

gen ch_incomeall_c = incomeall_2000_c - incomeall_1991_c
gen ch_n_incomeall_c = n_incomeall_2000_c - n_incomeall_1991_c
foreach num of numlist 1/5 {
 gen ch_domincome_pc`num' = domincome_pc`num'_2000 -  domincome_pc`num'_1991
 gen ch_n_domincome_pc`num' = n_domincome_pc`num'_2000 - n_domincome_pc`num'_1991
}

gen p_poor2000 = 100*poor_dom_2000/pop_2000
gen p_poor1991 = 100*poor_dom_1991/pop_1991
gen p_n_poor2000 = 100*n_poor_dom_2000/n_pop_2000
gen p_n_poor1991 = 100*n_poor_dom_1991/n_pop_1991
gen ch_p_poor =  p_poor2000- p_poor1991
gen ch_p_n_poor =  p_n_poor2000- p_n_poor1991


sort new_code_1970_1997
save temp, replace


* Federal contracts data
use ipeadata_municipios_x_amcs.dta, clear
keep ufmun new_code_1970_1997
sort ufmun
save federal_contracts_temp, replace
use federal_contracts.dta, clear
keep if pub_year==2000
rename cod_ibge6 ufmun
sort ufmun
merge ufmun using federal_contracts_temp
rm federal_contracts_temp.dta
collapse (sum) tvalor_liberado_n tvalor_convenio_n, by( new_code_1970_1997)
drop if new_code_1970_1997==""
sort new_code_1970_1997
merge new_code_1970_1997 using temp


* Outcomes: education, health, infrastructure, federal contracts

foreach num of numlist 1996 2000 2005 {
 gen teachers_nonmunic_c`num' = teachers`num' - teachersMunicipal`num'
 replace teachers_nonmunic_c`num' = teachers_nonmunic_c`num' - teachersPrivate`num' if teachersPrivate`num'!=.
 replace teachers_nonmunic_c`num' = teachers_nonmunic_c`num'/population`num'
 gen clrooms_nonmunic_c`num' = clrooms`num' - clroomsMunicipal`num'
 replace clrooms_nonmunic_c`num' = clrooms_nonmunic_c`num' - clroomsPrivate`num' if clroomsPrivate`num'!=.
 replace clrooms_nonmunic_c`num' = clrooms_nonmunic_c`num'/population`num'
}


foreach num of numlist 1992 2002 {
 gen estab_statefed_with_pop`num' = estab_fed`num'_with_pop + estab_sta`num'_with_pop
 gen estab_statefed_without_pop`num' = estab_fed`num'_without_pop + estab_sta`num'_without_pop
}

* Federal contracts - amount liberated per capita
gen fed_contracts_liberated2000_c = tvalor_liberado_n/population2000


* Municipal teachers, classrooms, and health establishments per million residents
foreach var of varlist *nonmunic* estab_statefed_with* {
 replace `var' = `var'*1000000
}

* changes in outcomes over time

foreach num of numlist 2000 2005 {
 gen ch_teachers_nonmunic_c`num' = teachers_nonmunic_c`num'-teachers_nonmunic_c1996
 gen ch_clrooms_nonmunic_c`num' = clrooms_nonmunic_c`num'-clrooms_nonmunic_c1996
}

gen ch_estab_statefed_with_pop = estab_statefed_with_pop2002 - estab_statefed_with_pop1992
gen ch_estab_statefed_without_pop = estab_statefed_without_pop2002 - estab_statefed_without_pop1992


save temp, replace

use temp, clear
collapse (mean) gdpcap2002 mun_budget_revenue_cap2000 population2000 latitude longitude dist_federal_capital state_capital dist_state_capital oilandgasvalue2000_cap gdpcap1970 years_school_till91_avg1970 lit_15plus_till91_pct1970 cap_residential1970c p_households_elect_light1970 p_households_sanit_instal1970 p_households_canal_water1970 gdp_ind_cap2002 gdp_nonind_cap2002 mun_budget_revenue2000_pred_c royalties2000_cap pmun*2000c cap_residential2000_c rooms_2000_16to64 p_hhld_abovestrandard_ppl_2000 prc_hhld_with_power_2000 prc_hhld_garbage_serv_2000 prc_hhld_pipedwater_2000 p_households_canal_water2000 p_households_sanit_instal2000 km_paved_munic_c teachersMunicipal_pop2000 clroomsMunicipal_pop2000 teachersMunicipal_pop2005 clroomsMunicipal_pop2005 estab_mun2002_with_pop estab_mun2002_without_pop welfare_2000_c incomeall_2000_c domincome_pc*2000 p_poor2000 lnpopulation1970 lnpopulation1980 lnpopulation1991 lnpopulation1996 lnpopulation2000 lnpopulation2005 population1970 population1980 population1991 population1996 population2005 teachers_nonmunic_c2000 clrooms_nonmunic_c2000 teachers_nonmunic_c2005 clrooms_nonmunic_c2005 estab_statefed_with_pop2002 estab_statefed_without_pop2002 km_paved_nonmunic_c fed_contracts_liberated2000_c (count) count=iron if (instrument==0 & coastal==1) | (onshore==0 &  offshore==1) 
save tableA`table'a, replace

use temp, clear
collapse (sd) gdpcap2002 mun_budget_revenue_cap2000 population2000 latitude longitude dist_federal_capital state_capital dist_state_capital oilandgasvalue2000_cap gdpcap1970 years_school_till91_avg1970 lit_15plus_till91_pct1970 cap_residential1970c p_households_elect_light1970 p_households_sanit_instal1970 p_households_canal_water1970 gdp_ind_cap2002 gdp_nonind_cap2002 mun_budget_revenue2000_pred_c royalties2000_cap pmun*2000c cap_residential2000_c rooms_2000_16to64 p_hhld_abovestrandard_ppl_2000 prc_hhld_with_power_2000 prc_hhld_garbage_serv_2000 prc_hhld_pipedwater_2000 p_households_canal_water2000 p_households_sanit_instal2000 km_paved_munic_c teachersMunicipal_pop2000 clroomsMunicipal_pop2000 teachersMunicipal_pop2005 clroomsMunicipal_pop2005 estab_mun2002_with_pop estab_mun2002_without_pop welfare_2000_c incomeall_2000_c domincome_pc*2000 p_poor2000 lnpopulation1970 lnpopulation1980 lnpopulation1991 lnpopulation1996 lnpopulation2000 lnpopulation2005 population1970 population1980 population1991 population1996 population2005 teachers_nonmunic_c2000 clrooms_nonmunic_c2000 teachers_nonmunic_c2005 clrooms_nonmunic_c2005 estab_statefed_with_pop2002 estab_statefed_without_pop2002 km_paved_nonmunic_c fed_contracts_liberated2000_c (count) count=iron if (instrument==0 & coastal==1) | (onshore==0 &  offshore==1) 
save tableA`table'b, replace


rm temp.dta




**************************************
* Table: effect of oil on population *
**************************************

set more 1
local table = `table'+1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997

* using 1000000*ln(population) instead of ln(population) to fit into table
foreach var of varlist lnpopulation* {
 replace `var' = `var'*1000000
}

foreach num of numlist 1(1)12 {

if `num'==1 {
areg lnpopulation1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==2 {
areg lnpopulation1980 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==3 {
areg lnpopulation1991 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==4 {
areg lnpopulation1996 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==5 {
areg lnpopulation2000 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==6 {
areg lnpopulation2005 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}

if `num'==7 {
areg population1970 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==8 {
areg population1980 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==9 {
areg population1991 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==10 {
areg population1996 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==11 {
areg population2000 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}
if `num'==12 {
areg population2005 oilandgasvalue2000_cap longitude latitude coast dist* state_capital if (onshore==0 | onshore==.) & coastal==1, robust a(sig)
}

matrix c=e(b)'
svmat double c, name(bvector)
matrix d=e(V)
matrix v`table'=vecdiag(d)'
svmat double v`table', name(vvector)
gen reg`table'_`num'b=bvector1
gen reg`table'_`num'e=vvector1^.5
drop bvector1 vvector1
gen reg`table'_`num'N=e(N)
replace reg`table'_`num'N=. if _n>1
}

keep reg*
foreach num of numlist 1(1)12 {
 gen reg`table'_`num'= reg`table'_`num'b[_n/2] if int(_n/2)==_n/2
 replace reg`table'_`num'= reg`table'_`num'e[_n/2] if int(_n/2)~=_n/2
 replace reg`table'_`num'=reg`table'_`num'N if _n==1
* drop reg`table'_`num'b reg`table'_`num'e reg`table'_`num'N
}

keep reg`table'_1- reg`table'_12


save tableA`table', replace




*********************************************************************
* Table:  Testing for Crowding Out of State and Federal Investments *
*********************************************************************

set more 1
local table = `table'+1
* Federal contracts data
use ipeadata_municipios_x_amcs.dta, clear
keep ufmun new_code_1970_1997
sort ufmun
save federal_contracts_temp, replace
use federal_contracts.dta, clear
keep if pub_year==2000
rename cod_ibge6 ufmun
sort ufmun
merge ufmun using federal_contracts_temp
rm federal_contracts_temp.dta
collapse (sum) tvalor_liberado_n tvalor_convenio_n, by( new_code_1970_1997)
drop if new_code_1970_1997==""
sort new_code_1970_1997
merge new_code_1970_1997 using amc9770

* Predict municipality revenues per capita in 2000  
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
* Predict missing 1991 values using 1992
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000

areg mun_budget_revenue1991 mun_budget_revenue1992 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue1991 mun_budget_revenue1992, robust 
predict mun_budget_revenue1991_pred
replace mun_budget_revenue1991_pred =  mun_budget_revenue1991 if  mun_budget_revenue1991!=.
gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991

gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c


* Outcomes: education, health, infrastructure, federal contracts

foreach num of numlist 1996 2000 2005 {
 gen teachers_nonmunic_c`num' = teachers`num' - teachersMunicipal`num'
 replace teachers_nonmunic_c`num' = teachers_nonmunic_c`num' - teachersPrivate`num' if teachersPrivate`num'!=.
 replace teachers_nonmunic_c`num' = teachers_nonmunic_c`num'/population`num'
 gen clrooms_nonmunic_c`num' = clrooms`num' - clroomsMunicipal`num'
 replace clrooms_nonmunic_c`num' = clrooms_nonmunic_c`num' - clroomsPrivate`num' if clroomsPrivate`num'!=.
 replace clrooms_nonmunic_c`num' = clrooms_nonmunic_c`num'/population`num'

}


foreach num of numlist 1992 2002 {
 gen estab_statefed_with_pop`num' = estab_fed`num'_with_pop + estab_sta`num'_with_pop
 gen estab_statefed_without_pop`num' = estab_fed`num'_without_pop + estab_sta`num'_without_pop
}

* Federal contracts - amount liberated per capita
gen fed_contracts_liberated2000_c = tvalor_liberado_n/population2000


* Municipal teachers, classrooms, and health establishments per million residents
foreach var of varlist *nonmunic* estab_statefed_with* {
 replace `var' = `var'*1000000
}

* changes in outcomes over time

foreach num of numlist 2000 2005 {
 gen ch_teachers_nonmunic_c`num' = teachers_nonmunic_c`num'-teachers_nonmunic_c1996
 gen ch_clrooms_nonmunic_c`num' = clrooms_nonmunic_c`num'-clrooms_nonmunic_c1996
}

gen ch_estab_statefed_with_pop = estab_statefed_with_pop2002 - estab_statefed_with_pop1992
gen ch_estab_statefed_without_pop = estab_statefed_without_pop2002 - estab_statefed_without_pop1992


gen one = 1

* "Family of outcomes" zscore as in Kling, Leibman, and Katz "EXPERIMENTAL ANALYSIS OF NEIGHBORHOOD EFFECTS" (Econometrica 2007)
gen zscore = 0
foreach var of varlist teachers_nonmunic_c2000 clrooms_nonmunic_c2000 teachers_nonmunic_c2005 clrooms_nonmunic_c2005 estab_statefed_with_pop2002 estab_statefed_without_pop2002 km_paved_nonmunic_c fed_contracts_liberated2000_c {
egen m`var' = mean(`var') if (onshore==0 | onshore==.)
egen s`var' = sd(`var') if (onshore==0 | onshore==.)
gen n`var' = (`var'-m`var')/s`var' if (onshore==0 | onshore==.)
replace zscore= zscore+ n`var'
drop m`var' s`var' n`var'
}

gen chzscore = 0
  foreach var of varlist ch_teachers_nonmunic_c2000 ch_clrooms_nonmunic_c2000 ch_teachers_nonmunic_c2005 ch_clrooms_nonmunic_c2005 ch_estab_statefed_with_pop ch_estab_statefed_without_pop {
egen m`var' = mean(`var') if (onshore==0 | onshore==.)
egen s`var' = sd(`var') if (onshore==0 | onshore==.)
gen n`var' = (`var'-m`var')/s`var' if (onshore==0 | onshore==.)
replace chzscore= chzscore+ n`var'
drop m`var' s`var' n`var'
} 

xi i.sig

foreach num of numlist 1(1)4 {

 if `num'==1 {
  local varcode = 0
  foreach var of varlist teachers_nonmunic_c2000 clrooms_nonmunic_c2000 teachers_nonmunic_c2005 clrooms_nonmunic_c2005 estab_statefed_with_pop2002 estab_statefed_without_pop2002 km_paved_nonmunic_c fed_contracts_liberated2000_c zscore {
   local varcode = `varcode'+1
   reg `var' mun_budget_revenue2000_pred_c longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }

 if `num'==2 {
  local varcode = 0
   reg mun_budget_revenue2000_pred_c oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of varlist teachers_nonmunic_c2000 clrooms_nonmunic_c2000 teachers_nonmunic_c2005 clrooms_nonmunic_c2005 estab_statefed_with_pop2002 estab_statefed_without_pop2002 km_paved_nonmunic_c fed_contracts_liberated2000_c zscore {
   local varcode = `varcode'+1
   ivreg `var' (mun_budget_revenue2000_pred_c=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }
 
 if `num'==3 {
  local varcode = 0
  foreach var of varlist ch_teachers_nonmunic_c2000 ch_clrooms_nonmunic_c2000 ch_teachers_nonmunic_c2005 ch_clrooms_nonmunic_c2005 ch_estab_statefed_with_pop ch_estab_statefed_without_pop one one chzscore {
   local varcode = `varcode'+1
   reg `var' pred_chmun_budget longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }

 if `num'==4 {
  local varcode = 0
   reg pred_chmun_budget oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  foreach var of varlist ch_teachers_nonmunic_c2000 ch_clrooms_nonmunic_c2000 ch_teachers_nonmunic_c2005 ch_clrooms_nonmunic_c2005 ch_estab_statefed_with_pop ch_estab_statefed_without_pop one one chzscore {
   local varcode = `varcode'+1
   ivreg `var' (pred_chmun_budget=oilandgasvalue2000_cap) longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1 ,robust
   matrix c=e(b)'
   svmat double c, name(bvector)
   matrix d=e(V)
   matrix v`table'=vecdiag(d)'
   svmat double v`table', name(vvector)
   gen r`num'_`varcode'b=bvector1
   gen r`num'_`varcode'e=vvector1^.5
   drop bvector1 vvector1
   gen r`num'_`varcode'N=e(N)
   replace r`num'_`varcode'N=. if _n>1
  }
 }


}
keep r1* r2* r3* r4*


foreach num of numlist 1(1)4 {
 foreach num2 of numlist 0(1)9 {
  if (`num'!=1 & `num'!=3) | `num2'!=0 {
   gen reg`num'_`num2'= r`num'_`num2'b[_n/2] if int(_n/2)==_n/2
   replace reg`num'_`num2'= r`num'_`num2'e[_n/2] if int(_n/2)~=_n/2
   replace reg`num'_`num2'= r`num'_`num2'N if _n==1
  }
 }
}

keep reg*
drop reg*_0
save tableA`table', replace





*******************
*******************
***** Figures *****
*******************
*******************

set more 1
local figure = 0




********************************************
* Figure: Decade of discovery of oilfields *
********************************************

local figure = `figure'+1

use oilfields_gis_clean, clear
gen yeardisc = substr( dat_descob,7,4)
destring yeardisc, replace
gen perioddisc = int( yeardisc/10)*10
collapse (count) fid_1, by(  perioddisc onsh)
rename fid_1 count
reshape wide count, i(  perioddisc) j( onshore)
foreach var of varlist count* {
 replace `var'=0 if `var'==.
}

save figure`figure'data, replace



***********************
* Figure: Map from GIS*
***********************

local figure = `figure'+1


*************************************************************************
* Appendix Figure: Frisch-Waugh figure for first stage in cross-section *
*************************************************************************



set more 1
local figure = 1
use amc9770, clear
*** EDIT BY Donna
sort new_code_1970_1997

* Predict municipality revenues per capita in 2000  
* For municipalities that have municipality revenues in 2001 but not in 2000
* Using a simple linear regression of municipality revenues in 2001 on municipality revenues in 2000
* Predict missing 1991 values using 1992
areg mun_budget_revenue2000 mun_budget_revenue2001 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue2000 mun_budget_revenue2001, robust 
predict mun_budget_revenue2000_pred
replace mun_budget_revenue2000_pred =  mun_budget_revenue2000 if  mun_budget_revenue2000!=.
gen mun_budget_revenue2000_pred_c =  mun_budget_revenue2000_pred/population2000

areg mun_budget_revenue1991 mun_budget_revenue1992 longitude latitude coast dist* state_capital, robust a(sig)
reg mun_budget_revenue1991 mun_budget_revenue1992, robust 
predict mun_budget_revenue1991_pred
replace mun_budget_revenue1991_pred =  mun_budget_revenue1991 if  mun_budget_revenue1991!=.
gen mun_budget_revenue1991_pred_c =  mun_budget_revenue1991_pred/population1991

gen pred_chmun_budget_revenue_cap =  mun_budget_revenue2000_pred_c- mun_budget_revenue1991_pred_c

xi i.sig
reg pred_chmun_budget_revenue_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust
predict y_res, res
reg oilandgasvalue2000_cap longitude latitude coast dist* state_capital _I* if (onshore==0 | onshore==.) & coastal==1, robust
predict x_res, res
scatter  y_res x_res if (onshore==0 | onshore==.) & coastal==1, msymbol(Oh) title("Appendix Figure A1: Frisch-Waugh diagram of first stage") b1title("Residuals from regressing each variable on same controls as in tables")  b2title("Sample: coastal AMCs without oil and coastal AMCs with offshore oil only") t1title("All values are in Brazilian R$2000") xtitle("Oil output per capita in 2000 (residuals)") ytitle("Municipal revenues per capita in 2000 (residuals)")
scatter  y_res x_res if (onshore==0 | onshore==.) & coastal==1, msymbol(Oh) xtitle("Oil output per capita in 2000 (residuals)") ytitle("Municipal revenues per capita in 2000 (residuals)")
keep if (onshore==0 | onshore==.) & coastal==1
keep y_res x_res

save figureA`figure'data, replace










