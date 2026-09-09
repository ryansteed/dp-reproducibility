
global input "D:\Input"
global output  "D:\Output" 


**************************************************************************************************************************************;
**Figure A.I is produced using Tableau;

**************************************************************************************************************************************;
**Table A.I Determinantes of stock market participation
use "$output\sample", clear

gen year_hq=year-4
merge 1:1 fips year_hq using "$input\cnty_head_count"
gen hq=0
replace hq=1 if head_count!=.

gen div_ratio=dividend_ratio*100
gen div_ratio1989=dividends1989/adjusted_gross_income_1989*100

reghdfe div_ratio div_ratio1989, noabsorb cluster(year)

reghdfe div_ratio div_ratio1989, a(state_year) cluster(year)

reghdfe div_ratio ipc_l4_ln pop_l4_ln white_ratio hispanic_ratio black_ratio under20_ratio above65_ratio, a(year) cluster(year)
reghdfe div_ratio ipc_l4_ln pop_l4_ln white_ratio hispanic_ratio black_ratio under20_ratio above65_ratio, a(state_year) cluster(year)
reghdfe div_ratio ipc_l4_ln pop_l4_ln white_ratio hispanic_ratio black_ratio under20_ratio above65_ratio bachelor_pct_1990, a(year) cluster(year)
reghdfe div_ratio ipc_l4_ln pop_l4_ln white_ratio hispanic_ratio black_ratio under20_ratio above65_ratio bachelor_pct_1990, a(state_year) cluster(year)
reghdfe div_ratio ipc_l4_ln pop_l4_ln white_ratio hispanic_ratio black_ratio under20_ratio above65_ratio hq, a(year) cluster(year)
reghdfe div_ratio ipc_l4_ln pop_l4_ln white_ratio hispanic_ratio black_ratio under20_ratio above65_ratio hq, a(state_year) cluster(year)


*************************************************************************************************************************************
*Table A.II: IV estimation;

use "$output\sample", clear

/*Controls*return*/
foreach var of varlist  white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}
global var_ret white_ratio_l4_ret-wage_l4_ln_ret natural-leisure natural_ret-other_service_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln


gen bach_return=bachelor_pct_1990*ret

tab year, gen(year)

foreach var of varlist natural- other_service{
replace `var'=0 if `var'==.
gen `var'_ret=`var'*ret
}

*Edu 1990;
ivreghdfe incum_d ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret  (dividend_ratio div_ret=bachelor_pct_1990 bach_return),  a(year) cluster(year) 
ivreghdfe incum_d ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret  (dividend_ratio div_ret=bachelor_pct_1990 bach_return),  a(state_year) cluster(year) 


*Heqdquarter;
gen year_hq=year-4
merge 1:1 fips year_hq using "$output\cnty_head_count" 
gen hq=0
replace hq=1 if head_count!=.
gen hq_ret=hq*ret

ivreghdfe incum_d ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret  (dividend_ratio div_ret=hq hq_ret),  a(year) cluster(year) 
ivreghdfe incum_d ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret  (dividend_ratio div_ret=hq hq_ret),  a(state_year) cluster(year) 


**************************************************************************************************************************************;
*Table A.III Alternative measures of stock participation;
use "$output\sample", clear

foreach var of varlist  white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}

global var_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret

gen div_year=year-4
sort fips year

merge 1:1 fips div_year using "$output\part_county0417" 
drop if _merge==2
drop _merge

/*Alternative measure of participation, use 2004 values for pre-2004 years and 2012 data for 2016 election*/
gsort fips -year
by fips: replace  no_report_ratio=no_report_ratio[_n-1] if missing(no_report_ratio)
tab year if no_report_ratio!=.

gen div_ret2=no_report_ratio*ret

/*dividend raito, excluding the top group, using 2006 values for elections in 2008 and prior*/
merge 1:1 fips div_year using "$output\div_ratio_excltop"  

drop if _merge==2
drop _merge

gsort fips -year
by fips: replace  div_ratio_exctop=div_ratio_exctop[_n-1] if missing(div_ratio_exctop)
tab year if div_ratio_exctop!=.

gen div_exctop_ret=div_ratio_exctop*ret

reghdfe incum_d div_exctop_ret div_ratio_exctop ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret, a(year) cluster(year)
reghdfe incum_d div_ret2 no_report_ratio ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret, a(year) cluster(year)

*Dividend divided by population;
gen div_pop=dividend/pop_l4
gen div_pop_ret=div_pop*ret

reghdfe incum_d div_pop_ret div_pop ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret, a(year) cluster(year)


*************************************************************************************************************************************
*Table A.IV Presidential elections and local stock returns;
use "$output\sample", clear

/*Controls*return*/
foreach var of varlist  white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}

gen ret_local=ret_ind_w
sum dividend_ratio
gen div_ret_local=(dividend_ratio-`r(mean)')*ret_ind_w

gen ipc_ret_local=ipc_l4_ln*ret_ind_w
gen pop_ret_local=pop_l4_ln*ret_ind_w

reghdfe incum_d dividend_ratio div_ret div_ret_local ret_local ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d ///
white_ratio_d_demIncum-unemp_d_demIncum white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret, a(year) cluster(year)

replace ret_local=ret_state
sum dividend_ratio
replace div_ret_local=(dividend_ratio-`r(mean)')*ret_state

reghdfe incum_d dividend_ratio div_ret div_ret_local ret_local ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d ///
white_ratio_d_demIncum-unemp_d_demIncum white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret, a(year) cluster(year)


**************************************************************************************************************************************;
*Table A.V Timing;

use "$output\sample", clear

merge m:1 year using "$output\election_ret_m" /*Produced by sas program 1&3month_return*/

gen div_ret2=dividend_ratio*ret4
reghdfe incum_d dividend_ratio div_ret div_ret2 ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

replace div_ret2=dividend_ratio*ret_3m_c
reghdfe incum_d dividend_ratio div_ret div_ret2 ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

replace div_ret2=dividend_ratio*ret_1m_c
reghdfe incum_d dividend_ratio div_ret div_ret2 ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

replace div_ret2=dividend_ratio*ret_w_c
reghdfe incum_d dividend_ratio div_ret2 div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

replace div_ret2=dividend_ratio*ret1
reghdfe incum_d dividend_ratio div_ret div_ret2 ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

replace div_ret2=dividend_ratio*ret_3m_l
reghdfe incum_d dividend_ratio div_ret div_ret2 ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

replace div_ret2=dividend_ratio*ret_1m_l
reghdfe incum_d dividend_ratio div_ret div_ret2 ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

replace div_ret2=dividend_ratio*ret_w_l
reghdfe incum_d dividend_ratio div_ret div_ret2 ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)


**************************************************************************************************************************************;
/*Table A.VI: Linearity of returns*/
use "$output\sample", clear
gen high_ret=0
replace high_ret=1 if  year==1996 | year==2000

gen low_ret=0
replace low_ret=1 if  year==2004 | year==2008

gen div_high_ret=dividend_ratio*high_ret
gen div_low_ret=dividend_ratio*low_ret

reghdfe incum_d dividend_ratio div_high_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_low_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_high_ret div_low_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)


**************************************************************************************************************************************;
*Table A.VII: Turnout;
use "$output\sample", clear

foreach var of varlist  white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}

global var_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret

reghdfe turnout_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret i.year, a(year) cluster(year)
reghdfe turnout_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret i.year, a(state_year) cluster(year)

gen div_ret_turnout_d=div_ret*turnout_d
gen div_turnout_d=dividend_ratio*turnout_d
gen ret_turnout_d=ret*turnout_d

reghdfe incum_d dividend_ratio div_ret div_ret_turnout_d div_turnout_d ret_turnout_d turnout_d ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d $var_ret, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret div_ret_turnout_d div_turnout_d ret_turnout_d turnout_d ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret, a(state_year) cluster(year)

**************************************************************************************************************************************;
*Table A.VIII Hetergeneity;
use "$output\sample", clear

/*Controls*return*/
foreach var of varlist  white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}

global var_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret

gen dem_share_twoparty=demvote_last/(demvote_last+repvote_last)
sort fips
by fips: egen dem_share_mean=mean(dem_share_twoparty)

xtile dem_share_rank=dem_share_mean, nq(10) 

gen polar=0
replace polar=1 if dem_share_rank==1 | dem_share_rank==10

reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if polar==1, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if polar==0, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if polar==1, a(state_year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if polar==0, a(state_year) cluster(year)

/*Ideology*/
gen dem_leaning=0
replace dem_leaning=1 if dem_share_rank>5

reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $$var_ret if dem_leaning==1, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if dem_leaning==0, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if dem_leaning==1, a(state_year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if dem_leaning==0, a(state_year) cluster(year)

/*Swing states*/
gen swing=0
replace swing=1 if inlist(st, 8, 12, 19, 26, 27, 39)
replace swing=1 if inlist(st, 32, 33, 37, 42, 51, 55)

reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if swing==1, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if swing==0, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if swing==1, a(state_year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if swing==0, a(state_year) cluster(year)

/*High vs low turnout states*/
sum turnout_l4,d
gen high_turnout=0
replace high_turnout=1 if turnout_l4>`r(p50)'

reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if high_turnout==1, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if high_turnout==0, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if high_turnout==1, a(state_year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if high_turnout==0, a(state_year) cluster(year)


**************************************************************************************************************************************;
*Table A.IX Difference across election characteristics;
use "$output\sample", clear

foreach var of varlist  white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}

global var_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret

*Incumbent president running?
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==1992 | year==1996 | year==2004 | year==2012 | year==2020, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==2000 | year==2008 | year==2016, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==1992 | year==1996 | year==2004 | year==2012 | year==2020, a(state_year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==2000 | year==2008 | year==2016, a(state_year) cluster(year)

*Dem won?
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==1992 | year==1996 | year==2008 | year==2012 | year==2020, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==2000 | year==2004 | year==2016, a(year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==1992 | year==1996 | year==2008 | year==2012 | year==2020, a(state_year) cluster(year)
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if year==2000 | year==2004 | year==2016, a(state_year) cluster(year)

***************************************************************************************************************;
*Table A.X: Aggregate controls

use "$output\sample", clear

gen ln_wage_l4=ln(average_weekly_wage_l)

*GDP growth;

gen div_agg=dividend_ratio*gdp_g
reghdfe incum_d dividend_ratio div_ret div_agg ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

*Wage;
replace div_agg=dividend_ratio*agg_wage_d
reghdfe incum_d dividend_ratio div_ret div_agg ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

*Change in unemployment rate;
replace div_agg=dividend_ratio*agg_unemp_rate_d
reghdfe incum_d dividend_ratio div_ret div_agg ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year) 

*Federal funds rate;
replace div_agg=dividend_ratio*ffrate_d
reghdfe incum_d dividend_ratio div_ret div_agg ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

*Change in credit spread;
replace div_agg=dividend_ratio*spread_d
reghdfe incum_d dividend_ratio div_ret div_agg ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

***********************************************************************************************
*Figure A.II: Dem share decile

use "$output\sample", clear

foreach var of varlist  white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}

global var_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret

gen dem_share_twoparty=demvote_last/(demvote_last+repvote_last)
sort fips
by fips: egen dem_share_mean=mean(dem_share_twoparty)

xtile dem_share_rank=dem_share_mean, nq(10)

tempname dem_share 
postfile `dem_share' iter coe1 se1 df using "$output\dem_share.dta" 

forvalues x=1/10{
reghdfe incum_d dividend_ratio div_ret ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum $var_ret if dem_share_rank==`x', a(year) cluster(year)
post `dem_share' (`x') (`=_b[div_ret]') (`=_se[div_ret]') (`=e(df_r)') 
}
postclose `dem_share' 

use "$output\dem_share.dta" , clear

gen co_u = coe1 + invttail(df,0.05)*se1
gen co_l = coe1 - invttail(df,0.05)*se1


label var iter	 "Democratic vote share decile"
twoway rcap co_u co_l iter || scatter coe1 iter,  legend(off)  ytitle(Coefficient of dividend ratio*ret) note("with 90% confidence interval") scheme(s1color) ylabel(-0.5(0.5)3.5)



***********************************************************************************************
*Figure A.III and AI.IV: Specification Curve Point Estimates
***Note:  The following two sections take substantial time to run and create a large number of files.
***********************************************************************************************
global path "$output"
capture mkdir "$path\specification_sims"



set seed 55555 


forvalues n=1/10{

	use "$path\sample.dta", replace
	cap mat drop C
	gen beta=.
	gen se=.
	gen inter=""
	gen str50 year_drop=""
	gen str100 control_list=""
	


	forvalues i=1/100{
		preserve
		di "`i'"
		quietly{
			use "$path\sample.dta", replace
			
			gen div_wage_d = dividend_ratio*agg_wage_d
			gen div_unemp_rate_d = dividend_ratio*agg_unemp_rate_d
			gen div_ffrate_d=dividend_ratio*ffrate_d
			gen div_spread_d= dividend_ratio*spread_d
			gen div_gdp_g=dividend_ratio*gdp_g

			
			ge ln_wage_l4=ln( average_weekly_wage_l )
			
			
			
			***** Randomly select control variables from list.  Will uniformly select n from 0 to N 
			****** and then randomly select a set of size n from the control list
			
		
			/*This is the set of controls*/
			local listtoselectfrom = "ipc_d pop_d wage_d unemp_d white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 white_ratio_d hispanic_ratio_d black_ratio_d under20_ratio_d above65_ratio_d white_ratio_d_demIncum hispanic_ratio_d_demIncum black_ratio_d_demIncum under20_ratio_d_demIncum above65_ratio_d_demIncum ipc_d_demIncum pop_d_demIncum "
			
			local numvars : list sizeof local(listtoselectfrom)
			di "`numvars'"
			local numcontrols = floor((`numvars'-0+1)*runiform()+0)
			di "`numcontrols'"
			
			local rnumbers
			foreach num of local listtoselectfrom { 
				local randomnumber = runiform()
				local rnumbers = "`rnumbers'`randomnumber' "
			}
			*di "`rnumbers'"
			local selection : list sort rnumbers
			*di "`selection'"

			local controls
			forvalues c=1/`numcontrols'{
				local posofselected = word("`selection'",`c') 
				*di "`posofselected'"
				local posinselectionlocal : list posof "`posofselected'" in rnumbers 
				*di "`posinselectionlocal'"
				local randomitem : word `posinselectionlocal' of `listtoselectfrom'
				local controls `controls' `randomitem'
			}
			dis "These are the selected controls: `controls'"
						
			
			
			
			if runiform()>.5{
			
			***** Randomly select a second aggregate TS variables from list.  Will select n_ag=0 or n_ag=1 
			***** additional variable and then randomly select the variable if n_ag=1.  Probability of including additional var is .9
				
			
				
				local agvars div_wage_d div_unemp_rate_d div_ffrate_d  div_spread_d div_gdp_g 
				local numvars : list sizeof local(agvars)
				di "`numvars'"

				local ui1 = floor((`numvars'-1+1)*runiform()+ 1)
				di "`ui1'"

				tokenize `agvars'
				local agg_var  "``ui1''"
				di "`agg_var'"
				gen interaction=`agg_var'
				scalar noag=0
				local interaction `agg_var'
				

				
			}
			else{
				**** Randomly select a different county var to interact with return.
				
				local countyvars  ln_wage_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 white_ratio_l4  hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 
				local numvars : list sizeof local(countyvars)
				di "`numvars'"

				local ui1 = floor((`numvars'-1+1)*runiform()+ 1)
				di "`ui1'"

				tokenize `countyvars'
				local countyvar  "``ui1''"
				di "`countyvar'"
				local agg_var  "``ui1''"
				di "`agg_var'"
				local interaction `countyvar'
				gen interaction=`countyvar'*ret
				
				scalar noag=0
			
			}
			
				
				
				
				
				
			***** Randomly select whether to drop a year and then randomly select a year to drop from list.  Will drop up to 4 years
			local election_years 1992 1996 2000 2004 2008 2012 2016 2020
			
			local numvars : list sizeof local(election_years)
			di "`numvars'"
			local numyears = floor((2-0+1)*runiform()+0)
			di "`numyears'"
			
			local ynumbers
			foreach num of local election_years { 
				local randomnumber = runiform()
				local ynumbers = "`ynumbers'`randomnumber' "
			}
			*di "`rnumbers'"
			local yselection : list sort ynumbers
			*di "`selection'"

			local yearsinsample
			forvalues c=1/`numyears'{
				local posofyselected = word("`yselection'",`c') 
				*di "`posofselected'"
				local posinyselectionlocal : list posof "`posofyselected'" in ynumbers 
				*di "`posinselectionlocal'"
				local randomyear : word `posinyselectionlocal' of `election_years'
				*local randomyear=real(`randomyear')
				di "`randomyear'"
				drop if year==real("`randomyear'")
				local yearsinsample `yearsinsample' `randomyear'
			}
			dis "These are the years dropped from sample: `yearsinsample'"
			
	
			
			****Use to randomly sample counties : There are 3056 counties total in the data.  This code always samples a fixed fraction.

			gen order=_n
			egen select= tag(fips)
			gen rnd=runiform()
			sort select rnd
			replace select=_n>(_N-2140) /*2445 is 80% of the counties*/ /*Changed to 2140 which is 70% of counties)*/
			bysort fips (select): replace select=select[_N]
			sort order
			drop order rnd

			reg incum_d dividend_ratio div_ret `interaction' `controls' /*`control_inter'*/ i.year, cluster(year)



		
			restore 
			
			replace beta=_b[div_ret] in `i'
			replace se=_se[div_ret] in `i'
			replace inter="`interaction'" in `i'
			replace year_drop="`yearsinsample'" in `i'
			replace control_list="`controls'" in `i'		
			
			
			}
		

		}
			save "$path\\specification_sims\sample_`n'.dta", replace
}
		

		
**********Combine sims
clear
save "$path\\specification_sims\sample_all.dta", replace emptyok

forvalues n=1/10 {
	di "`n'"
	quietly{
		use "$path\\specification_sims\sample_`n'.dta", clear
		keep beta se inter  year_drop control_list
		drop if mi(beta)
		append using "$path\\specification_sims\sample_all.dta"
		save "$path\\specification_sims\sample_all.dta", replace
		}
	}
	
	
*********

***********************************************************************************************
*Figure IA.III and IA.IV: Specification Curve Bootstrapped Confidence Intervals
***********************************************************************************************


program define randomseed
   version 7
   local seed = clock( c(current_time), "hms" )
   set seed  `seed'
   di "Clock based seed = " c(seed)
end     



forvalues b=1/1000{
	di "`b'"
	quietly{
	cap mkdir "$path\specification_sims\bs_`b'"

	use "$path\sample.dta", replace
			
	gen div_wage_d = dividend_ratio*agg_wage_d
	gen div_unemp_rate_d = dividend_ratio*agg_unemp_rate_d
	gen div_ffrate_d=dividend_ratio*ffrate_d
	gen div_spread_d= dividend_ratio*spread_d
	gen div_gdp_g=dividend_ratio*gdp_g

	
	ge ln_wage_l4=ln( average_weekly_wage_l )

	cap drop _merge
	
	
		preserve
		keep dividend_ratio div_ret
		randomseed
		gen rnd=runiform()
		sort rnd
		drop rnd
		tempfile temp`v'
		save `temp`v''
		restore
		merge 1:1 _n using `temp`v'', update replace
		drop _merge

		
	save "$path\specification_sims\bs_`b'\sample_`b'.dta", replace

}

	set seed 55555 
	forvalues n=1/10{
		quietly{
		use "$path\specification_sims\bs_`b'\sample_`b'.dta", replace
		cap mat drop C
		gen beta=.
		gen se=.

		}



		forvalues i=1/100{
		quietly{
			preserve
			di "`i'"
			
				use "$path\specification_sims\bs_`b'\sample_`b'.dta", replace
				
				
				
				
			***** Randomly select control variables from list.  Will uniformly select n from 0 to N 
			****** and then randomly select a set of size n from the control list
			
		
			/*This is the set of controls*/
			local listtoselectfrom = "ipc_d pop_d wage_d unemp_d white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 white_ratio_d hispanic_ratio_d black_ratio_d under20_ratio_d above65_ratio_d white_ratio_d_demIncum hispanic_ratio_d_demIncum black_ratio_d_demIncum under20_ratio_d_demIncum above65_ratio_d_demIncum ipc_d_demIncum pop_d_demIncum "
			
			local numvars : list sizeof local(listtoselectfrom)
			di "`numvars'"
			local numcontrols = floor((`numvars'-0+1)*runiform()+0)
			di "`numcontrols'"
			
			local rnumbers
			foreach num of local listtoselectfrom { 
				local randomnumber = runiform()
				local rnumbers = "`rnumbers'`randomnumber' "
			}
			*di "`rnumbers'"
			local selection : list sort rnumbers
			*di "`selection'"

			local controls
			forvalues c=1/`numcontrols'{
				local posofselected = word("`selection'",`c') 
				*di "`posofselected'"
				local posinselectionlocal : list posof "`posofselected'" in rnumbers 
				*di "`posinselectionlocal'"
				local randomitem : word `posinselectionlocal' of `listtoselectfrom'
				local controls `controls' `randomitem'
			}
			dis "These are the selected controls: `controls'"
						
			
			
			
			if runiform()>.5{
			
			***** Randomly select a second aggregate TS variables from list.  Will select n_ag=0 or n_ag=1 
			***** additional variable and then randomly select the variable if n_ag=1.  Probability of including additional var is .9
				
			
				
				local agvars div_wage_d div_unemp_rate_d div_ffrate_d  div_spread_d div_gdp_g 
				local numvars : list sizeof local(agvars)
				di "`numvars'"

				local ui1 = floor((`numvars'-1+1)*runiform()+ 1)
				di "`ui1'"

				tokenize `agvars'
				local agg_var  "``ui1''"
				di "`agg_var'"
				gen interaction=`agg_var'
				scalar noag=0
				local interaction `agg_var'
				

				
			}
			else{
				**** Randomly select a different county var to interact with return.
				
				local countyvars  ln_wage_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 white_ratio_l4  hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 
				local numvars : list sizeof local(countyvars)
				di "`numvars'"

				local ui1 = floor((`numvars'-1+1)*runiform()+ 1)
				di "`ui1'"

				tokenize `countyvars'
				local countyvar  "``ui1''"
				di "`countyvar'"
				local agg_var  "``ui1''"
				di "`agg_var'"
				local interaction `countyvar'
				gen interaction=`countyvar'*ret
				
				scalar noag=0
			
			}
			
				
				
				
				
				
			***** Randomly select whether to drop a year and then randomly select a year to drop from list.  Will drop up to 4 years
			local election_years 1992 1996 2000 2004 2008 2012 2016 2020
			
			local numvars : list sizeof local(election_years)
			di "`numvars'"
			local numyears = floor((2-0+1)*runiform()+0)
			di "`numyears'"
			
			local ynumbers
			foreach num of local election_years { 
				local randomnumber = runiform()
				local ynumbers = "`ynumbers'`randomnumber' "
			}
			*di "`rnumbers'"
			local yselection : list sort ynumbers
			*di "`selection'"

			local yearsinsample
			forvalues c=1/`numyears'{
				local posofyselected = word("`yselection'",`c') 
				*di "`posofselected'"
				local posinyselectionlocal : list posof "`posofyselected'" in ynumbers 
				*di "`posinselectionlocal'"
				local randomyear : word `posinyselectionlocal' of `election_years'
				*local randomyear=real(`randomyear')
				di "`randomyear'"
				drop if year==real("`randomyear'")
				local yearsinsample `yearsinsample' `randomyear'
			}
			dis "These are the years dropped from sample: `yearsinsample'"
			
	
			
			****Use to randomly sample counties : There are 3056 counties total in the data.  This code always samples a fixed fraction.

			gen order=_n
			egen select= tag(fips)
			gen rnd=runiform()
			sort select rnd
			replace select=_n>(_N-2140) /*2445 is 80% of the counties*/ /*Changed to 2140 which is 70% of counties)*/
			bysort fips (select): replace select=select[_N]
			sort order
			drop order rnd

			reg incum_d dividend_ratio div_ret `interaction' `controls' /*`control_inter'*/ i.year, cluster(year)
	
			
				restore 
				
				replace beta=_b[div_ret] in `i'
				replace se=_se[div_ret] in `i'

				
				}
			

			}
				keep beta se 
				save "$path\\specification_sims\bs_`b'\sample_`b'_`n'.dta", replace
	}
		
}
			
**********Combine sims
	
*********



clear
use "$path\\specification_sims\sample_all.dta"
save "$path\\specification_sims\sample_bs_all.dta", replace emptyok

forvalues b=1/1000{
	di "`b'"
	clear
	save "$path\\specification_sims\bs_`b'\sample_bs_`b'_all.dta", replace emptyok
	forvalues n=1/10 {
		di "`n'"
		quietly{
			use "$path\\specification_sims\bs_`b'\sample_`b'_`n'.dta", clear
			keep beta se 
			drop if mi(beta)
			rename beta beta_`b'
			rename se se_`b'
			append using "$path\\specification_sims\bs_`b'\sample_bs_`b'_all.dta"
			save "$path\\specification_sims\bs_`b'\sample_bs_`b'_all.dta", replace
			}
		}
		quietly{
		use   "$path\\specification_sims\bs_`b'\sample_bs_`b'_all.dta"
		merge 1:1 _n using "$path\\specification_sims\sample_bs_all.dta"
		drop _merge
		save "$path\\specification_sims\sample_bs_all.dta", replace
		}
	
}
*********
use "$path\\\specification_sims\sample_bs_all.dta" , clear
keep beta_*
merge 1:1 _n using "$path\\specification_sims\sample_all.dta"
drop _merge
gsort beta
order beta
rename beta beta_actual

forvalues i=1/1000{
	preserve
		keep beta_`i'
		gsort beta_`i'
		tempfile temp`v'
		save `temp`v''
		restore
		merge 1:1 _n using `temp`v'', update replace
		drop _merge
}

preserve 
use "$path\\specification_sims\sample_all.dta", clear


rename beta beta_actual
gsort beta_actual
tempfile temp
save `temp'
restore
merge 1:1 _n using `temp', 
 		drop _merge

gen coef_order =_n

egen simmin=rowmin(beta_1000-beta_1)
egen simmax=rowmax(beta_1000-beta_1)

order coef_order beta_actual simmin simmax 

save "$path\\specification_sims\sample_all_plus_bs_matched.dta", replace









