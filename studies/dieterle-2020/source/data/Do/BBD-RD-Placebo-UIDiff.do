* Generate Estimates for Table C.1 row (2)
use BBD-RD.dta if diff_samp==0, clear


sum st_bound
local s_min=r(min)
local s_max=r(max)
sum qtr
local q_min=r(min)
local q_max=r(max)

forvalues t=0/1{
forvalues r=0/6{
gen aic_`t'_`r'=.
gen aicc_`t'_`r'=.
}
}

foreach y of varlist ln_unemp treat_puidiff{
foreach r in 1 aicc{
gen double `y'_res_`r'=.
}
}

*Determine Polynomial length for each state-by-border-by-quarter using AICc

forvalues i=`s_min'/`s_max'{
forvalues j=`q_min'/`q_max'{
di "State Boundary `i' Qtr `j'"
forvalues t=0/1{
capture: sum ln_unemp if treat_puidiff==`t' & st_bound==`i' & qtr==`j'
if r(N)>0{
clear results
capture noisily: reg ln_unemp [aweight=wgt]  if  treat_puidiff==`t' &    st_bound==`i' & qtr==`j'
capture noisily: replace aic_`t'_0=-2*e(ll)+2*(e(df_m)+1) if  st_bound==`i' & qtr==`j'
capture noisily: replace aicc_`t'_0=e(N)*ln(e(rss)/e(N))+2*(e(N)-e(df_r))+2*(e(df_m)+2)*(e(df_m)+3)/(e(N)-(e(df_m)+2)-1)+(e(N)+e(N)*ln(2*_pi))    if   st_bound==`i' & qtr==`j'


forvalues r=1/6{
clear results
capture noisily: reg ln_unemp mu1-mu`r' [aweight=wgt]  if  treat_puidiff==`t' &    st_bound==`i' & qtr==`j'
capture noisily: replace aic_`t'_`r'=-2*e(ll)+2*(e(df_m)+1) if  st_bound==`i' & qtr==`j'
capture noisily: replace aicc_`t'_`r'=e(N)*ln(e(rss)/e(N))+2*(e(N)-e(df_r))+2*(e(df_m)+2)*(e(df_m)+3)/(e(N)-(e(df_m)+2)-1)+(e(N)+e(N)*ln(2*_pi))    if   st_bound==`i' & qtr==`j'
}
}
}
}
}


forvalues t=0/1{
gen spec_aic_`t'=1   if  aic_`t'_0<.
gen spec_aicc_`t'=1  if  aicc_`t'_0<.
}

forvalues t=0/1{
forvalues j=2/6{
local r=`j'-1
replace spec_aic_`t'=`j'  if aic_`t'_`j'<aic_`t'_`r' & aic_`t'_`j'<. & spec_aicc_`t'==`r'
replace spec_aicc_`t'=`j'  if aicc_`t'_`j'<aicc_`t'_`r' & aicc_`t'_`j'<. & spec_aicc_`t'==`r'
}
}
tab1 spec_aicc*

foreach x of varlist mu*{
gen `x'_t=`x'*treat_puidiff
}

/*Use Frisch-Waugh Partitioned Regression to estimate effects:
1. Regress Outcome on distance controls, save residuals 
2. Regress UI avialable on distance controls, save residuals
3. Regress residuals from 1 on residuals from 2
*/

sum spec_aicc_0
local s0max=r(max)
sum spec_aicc_1
local s1max=r(max)


sum st_bound
local s_min=r(min)
local s_max=r(max)


foreach y of varlist ln_unemp treat_puidiff{
forvalues i=`s_min'/`s_max'{
di "State Boundary `i'"
capture: sum spec_aicc_0 if treat_puidiff==`t' & st_bound==`i'
local s=r(mean)
clear results

capture noisily: areg `y' c.(mu1)#i.qtr c.(mu1_t)#i.qtr  [aweight=wgt]  if st_bound==`i' & spec_aicc_0<. & spec_aicc_1<., absorb(st_bound_qtr_id) 
capture noisily: predict double temp, res
capture noisily: replace `y'_res_1=temp if  e(sample)==1
capture noisily: drop temp
clear results

forvalues s0=1/`s0max'{
forvalues s1=1/`s1max'{
clear results

quietly: sum ln_unemp if spec_aicc_0==`s0' & spec_aicc_1==`s1' & st_bound==`i'
if r(N)>0{
capture noisily: areg `y' c.(mu1-mu`s0')#i.qtr c.(mu1_t-mu`s1'_t)#i.qtr  [aweight=wgt]  if spec_aicc_0==`s0' & spec_aicc_1==`s1' & st_bound==`i', absorb(st_bound_qtr_id) 
capture noisily: predict double temp, res
capture noisily: replace `y'_res_aicc=temp if  e(sample)==1
capture noisily: drop temp
clear results
}
}
}

}
}




*Column (1): No distance control
areg ln_unemp treat_puidiff [aweight=wgt]  if     ln_unemp_res_1<., absorb(st_bound_qtr_id) cluster(st_by_bound)
nlcom exp(ln(.05)+(_b[treat_puidiff]))


*Columns (2) and (3)
areg ln_unemp_res_`r' treat_puidiff_res_`r' [aweight=wgt] , absorb(st_bound_qtr_id) cluster(st_by_bound)
nlcom exp(ln(.05)+(_b[treat_puidiff_res_`r']))
}


/*Confirm point estimate from Frisch-Waugh for linear case
areg ln_unemp treat_puidiff c.mu1#i.st_bound_qtr_id#i.treat_puidiff [aweight=wgt]  if     ln_unemp_res_1<., absorb(st_bound_qtr_id) cluster(st_by_bound)
*/





