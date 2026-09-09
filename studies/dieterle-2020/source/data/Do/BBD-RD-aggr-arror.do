/*Generate Estimates for Table A.1
This do file requires access to resticted use ACS microdata- see the read me file

The data from the ACS must be at the indivdual level and include the indivduals
census tract, year, and the ESR employment variable which should be coded as 
follows:

	Employment status recode 
	b .N/A (less than 16 years old) 
	1 .Civilian employed, at work 
	2 .Civilian employed, with a job but not at work 
	3 .Unemployed 
	4 .Armed forces, at work 
	5 .Armed forces, with a job but not at work 
	6 .Not in labor force

We also require a frequency weight variable pwt
 
From this, we can generate the necessary tract and county level variables needed
to generate the aggregation error approximation

Here we have named the tract level geographic id variable "tract" based on the 
11 digit geo id


*/

*First Create Unemployment and Labor Force counts at tract level
gen u=esr==3
gen lf=esr==1|esr==2|esr==3
*Sum up frequency weights pwt for each observation type
bysort tract year: egen ucount=sum(pwt) if u==1
bysort tract year: egen lfcount=sum(pwt) if lf==1 

/**then fold the data set up to the tract*year level:**/

keep tract year ucount lfcount 
duplicates drop


/*create county code from tract level geo code 
	- needed to merge to RD data set
	- needed to calculate county level variables
*/
gen st_county_cd = substr(tract,1,5)

*create county level components of eq (A.4)
bysort st_county_cd year: egen sigma_U=sd( ucount)
gen sigma_sq_U=sigma_U^2
bysort st_county_cd: egen sigma_L=sd(lfcount)
gen sigma_sq_L=sigma_L^2
bysort st_county_cd: egen U_sq_bar=mean(ucount^2)
bysort st_county_cd: egen L_sq_bar=mean(lfcount^2)

*create county level aggregation error term form eq (A.4)
gen e=(sigma_sq_U/(2* U_sq_bar))-(sigma_sq_L/(2* L_sq_bar))

*collpase down to county-year data set with e
keep st_county_cd year e
duplicates drop

*merge to our RD data
merge 1:m st_county_cd year using BBD-RD.dta, nogen keep(match)

*generate average ui available by year
gen ui=exp(ln_ui)
bysort st_county_cd year: egen ui_m=mean(ui)

gen ln_ui_m=ln(ui_m)

*collpase to annual data
sort st_county_cd year quarter
by st_county_cd year: keep if _n==1


*Run RD Frish-Waugh code
egen st_bound_year_id=group(st_bound year)
sum st_bound
local s_min=r(min)
local s_max=r(max)
sum year
local y_min=r(min)
local y_max=r(max)

forvalues t=0/1{
forvalues r=0/6{
gen aicc_`t'_`r'=.
}
}

foreach y of varlist e ln_ui_m{
foreach r in 1 aicc{
gen double `y'_res_`r'=.
}
}


*Determine Polynomial length for each state-by-border-by-year using AICc

forvalues i=`s_min'/`s_max'{
forvalues j=`y_min'/`y_max'{
di "State Boundary `i' Year `j'"
forvalues t=0/1{
capture: sum e if treat==`t' & st_bound==`i' & year==`j'
if r(N)>0{
clear results
capture noisily: reg e [aweight=wgt]  if  treat==`t' &    st_bound==`i' & year==`j'
capture noisily: replace aicc_`t'_0=e(N)*ln(e(rss)/e(N))+2*(e(N)-e(df_r))+2*(e(df_m)+2)*(e(df_m)+3)/(e(N)-(e(df_m)+2)-1)+(e(N)+e(N)*ln(2*_pi))    if   st_bound==`i' & year==`j'


forvalues r=1/6{
clear results
capture noisily: reg e mu1-mu`r' [aweight=wgt]  if  treat==`t' &    st_bound==`i' & year==`j'
capture noisily: replace aicc_`t'_`r'=e(N)*ln(e(rss)/e(N))+2*(e(N)-e(df_r))+2*(e(df_m)+2)*(e(df_m)+3)/(e(N)-(e(df_m)+2)-1)+(e(N)+e(N)*ln(2*_pi))    if   st_bound==`i' & year==`j'
}
}
}
}
}


forvalues t=0/1{
gen spec_aicc_`t'=1  if  aicc_`t'_0<.
}

forvalues t=0/1{
forvalues j=2/6{
local r=`j'-1
replace spec_aicc_`t'=`j'  if aicc_`t'_`j'<aicc_`t'_`r' & aicc_`t'_`j'<. & spec_aicc_`t'==`r'
}
}
tab1 spec_aicc*

foreach x of varlist mu*{
gen `x'_t=`x'*treat
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


foreach y of varlist e ln_ui_m{
forvalues i=`s_min'/`s_max'{
di "State Boundary `i'"
capture: sum spec_aicc_0 if treat==`t' & st_bound==`i'
local s=r(mean)
clear results

capture noisily: areg `y' c.(mu1)#i.year c.(mu1_t)#i.year  [aweight=wgt]  if st_bound==`i' & spec_aicc_0<. & spec_aicc_1<., absorb(st_bound_yr_id) 
capture noisily: predict double temp, res
capture noisily: replace `y'_res_1=temp if  e(sample)==1
capture noisily: drop temp
clear results

forvalues s0=1/`s0max'{
forvalues s1=1/`s1max'{
clear results

quietly: sum e if spec_aicc_0==`s0' & spec_aicc_1==`s1' & st_bound==`i'
if r(N)>0{
capture noisily: areg `y' c.(mu1-mu`s0')#i.year c.(mu1_t-mu`s1'_t)#i.year  [aweight=wgt]  if spec_aicc_0==`s0' & spec_aicc_1==`s1' & st_bound==`i', absorb(st_bound_yr_id) 
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
areg e ln_ui_m [aweight=wgt]  if     e_res_1<., absorb(st_bound_yr_id) cluster(st_by_bound)
nlcom exp(ln(.05)+(_b[ln_ui_m])*(ln(82.5)-ln(26)))
nlcom exp(ln(.05)+(_b[ln_ui_m])*(ln(99)-ln(26)))

*Columns (2) and (3)
foreach r in 1 aicc{
areg e_res_`r' ln_ui_m_res_`r' [aweight=wgt] , absorb(st_bound_yr_id) cluster(st_by_bound)
nlcom exp(ln(.05)+(_b[ln_ui_m_res_`r'])*(ln(82.5)-ln(26)))
nlcom exp(ln(.05)+(_b[ln_ui_m_res_`r'])*(ln(99)-ln(26)))
}


/*Confirm point estimate from Frisch-Waugh for linear case
areg e ln_ui_m c.mu1#i.st_bound_yr_id#i.treat [aweight=wgt]  if     e_res_1<., absorb(st_bound_yr_id) cluster(st_by_bound)
*/


























