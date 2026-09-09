*** EDITED: Ryan Steed. Changed paths ***
global input "source/Input" /*Folder where the macro_vars_all.dta are contained*/

global output "source/Output"  /*Folder where the merged_data.dta  and msi_real.dta files are found after running program 01 - data_construction.sas */
 
global path_out "source/Output/bs"  /*Need a folder to hold all Boostrap samples for Table 3 SEs*/
***

global bs_runs=1000  /*set the number of bootstrap runs for Table 3 SEs*/

*** EDITED: Ryan Steed. All paths below already reference $output
/* cd "$output" */
***

 
/*********************************************
Generate additional variables used in analysis
***********************************************/

use "$output/merged_data.dta", clear

gen state_fips=int(fips/1000)

foreach v of varlist _all {
      capture rename `v' `=lower("`v'")'
   }

*Changes in incumbent share
gen dem_incum=1 if year==1996 | year==2000 | year==2012 | year==2016
replace dem_incum=0 if year==1988 | year==1992 | year==2004 | year==2008 | year==2020

gen incum_share=demvote/totalvotes if dem_incum==1
gen incum_share_last=demvote_last/totalvotes_last if dem_incum==1
gen opp_share=repvote/totalvotes if dem_incum==1
gen opp_share_last=repvote_last/totalvotes_last if dem_incum==1

replace incum_share=repvote/totalvotes if dem_incum==0
replace incum_share_last=repvote_last/totalvotes_last if dem_incum==0
replace opp_share=demvote/totalvotes if dem_incum==0
replace opp_share_last=demvote_last/totalvotes_last if dem_incum==0

gen incum_d = incum_share - incum_share_last

*Dividend ratio interacted with returns; dividend income ratio winsorized at the 99th percentile;
gen dividend_ratio=dividend/adjusted_gross_income
winsor2 dividend_ratio, cuts(0 99) replace
gen div_ret= dividend_ratio*ret

*Changes in age and race;  
gen white_ratio= pop_white/tot_pop
gen hispanic_ratio= pop_hispanic/tot_pop
gen black_ratio= pop_black/tot_pop
gen under20_ratio= pop_under20/tot_pop
gen above65_ratio= pop_above65/tot_pop

gen white_ratio_l4= pop_white_l4/tot_pop_l4
gen hispanic_ratio_l4= pop_hispanic_l4/tot_pop_l4
gen black_ratio_l4= pop_black_l4/tot_pop_l4
gen under20_ratio_l4= pop_under20_l4/tot_pop_l4
gen above65_ratio_l4= pop_above65_l4/tot_pop_l4

/*The demographic data start in 1990, for 1992 election, changes from 1990 to 1992 were used*/
gen white_ratio_d=white_ratio-white_ratio_l4
gen hispanic_ratio_d=hispanic_ratio-hispanic_ratio_l4
gen black_ratio_d=black_ratio-black_ratio_l4
gen under20_ratio_d=under20_ratio-under20_ratio_l4
gen above65_ratio_d=above65_ratio-above65_ratio_l4

*change in unemployment rate;
gen unemp_d=unemp_rate-unemp_rate_l4
replace unemp_d=unemp_rate-unemp_rate_1990 if year==1992 /*Unemployment rate data start in 1990, for 1992 election, use the change from 1990 to 1992*/
replace unemp_rate_l4=unemp_rate_1990 if year==1992

*wage, income per capita, and population growth
gen ipc_d=ipc/ipc_l4-1
gen pop_d=pop/pop_l4-1
gen wage_d=average_weekly_wage/average_weekly_wage_l4-1
replace wage_d=(average_weekly_wage/average_weekly_wage_1990)^2-1 if year==1992 & (fips==51685 | fips==51735 | fips==29227) /*These three counties' wage is missing in 1988, use the growth from 1990 to 1992*/
winsor2 ipc_d pop_d wage_d, cuts(1 99) replace

gen wage_l4_ln=ln(average_weekly_wage_l4)
replace wage_l4_ln=ln(average_weekly_wage_1990) if year==1992 & (fips==51685 | fips==51735 | fips==29227)

foreach var of varlist incum_share dividend_ratio ret ipc_ln pop_ln ipc_l4_ln pop_l4_ln unemp_rate white_ratio black_ratio hispanic_ratio under20_ratio above65_ratio white_ratio_d-above65_ratio_d ipc_d pop_d wage_d unemp_d{
drop if `var'==.
}  /*A total of 25 observations dropped due to msissing values for miscellaneous reasons*/

replace dem_incum=-1 if dem_incum==0
foreach var of varlist  white_ratio_d-above65_ratio_d ipc_d pop_d wage_d unemp_d{
gen `var'_demIncum=`var'*dem_incum
}

*Aggregate variables;
gen agg_wage_d=ln(agg_weekly_wage)-ln(agg_weekly_wage_l4)
gen agg_unemp_rate_d=agg_unemployment_rate-agg_unemployment_rate_l4
gen ffrate_d=ffrate-ffrate_l4
gen spread_d=credit_spread-credit_spread_l4

*Turnout
gen turnout=totalvotes/(pop-pop_under20)
gen turnout_l4=totalvotes_last/(pop_l4-pop_under20_l4)
gen turnout_d=turnout-turnout_l4

drop st
gen st=int(fips/1000)
egen state_year=group(st year)

sort fips year

save $output/sample, replace



**************************************************************************************************************************************;

*Exhibits from paper

**************************************************************************************************************************************;
 

**************************************************************************************************************************************;
*Table 1 Summary stats;
use "$output/sample", clear

tabstat incum_share incum_d dividend_ratio ret ipc_ln pop_ln unemp_rate average_weekly_wage white_ratio black_ratio hispanic_ratio under20_ratio above65_ratio, stat(mean sd p10 p50 p90 N)

**************************************************************************************************************************************;
*Table 2 

/*Report controls*/
use "$output/sample", clear
eststo clear

eststo: reghdfe incum_d dividend_ratio div_ret, a(year) cluster(year)

/*Control, Control*Demincum*/
global cnty_controls ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum

eststo:  reghdfe incum_d dividend_ratio div_ret $cnty_controls, a(year) cluster(year)

/*Controls*return*/
foreach var of varlist white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln{
gen `var'_ret=`var'*ret
}

global var_ret white_ratio_l4 hispanic_ratio_l4 black_ratio_l4 under20_ratio_l4 above65_ratio_l4 ipc_l4_ln pop_l4_ln unemp_rate_l4 wage_l4_ln white_ratio_l4_ret-wage_l4_ln_ret

eststo:  reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret, a(year) cluster(year)

/*votes-weighted*/
eststo:  reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret [aw=totalvotes], a(year) cluster(year)

/*Trend*/
egen urban=rowmean(poppct_urban1990 poppct_urban2010)
xtile urban_group=urban,n(3)
egen urban_group_year=group(urban_group year)
egen education_mean=rowmean(bachelor_pct_1990 bachelor_pct_2010)
xtile edu_group=education_mean,n(3)
egen edu_group_year=group(edu_group year)

eststo: reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret [aw=totalvotes], a(urban_group_year edu_group_year) cluster(year)

gen dem_share=demvote/totalvotes
gen rep_share=repvote/totalvotes
forv i=1/3{
	reg dem_share year if urban_group==`i'
	predict res if e(sample), res
	replace dem_share=res if urban_group==`i'
	drop res
	reg rep_share year if urban_group==`i'
	predict res if e(sample), res
	replace rep_share=res if urban_group==`i'
	drop res
}

/*State by  year FE*/
drop st
drop state_year
gen st=int(fips/1000)
egen state_year=group(st year)

eststo: reghdfe incum_d dividend_ratio div_ret $cnty_controls $var_ret [aw=totalvotes], a(state_year) cluster(year)

/*win-lose*/
gen ltw=0
replace ltw=1 if incum_share_last<opp_share_last & incum_share>opp_share
replace ltw=-1 if incum_share_last>opp_share_last & incum_share<opp_share

eststo: reghdfe     ltw dividend_ratio div_ret $cnty_controls $var_ret, a(year) cluster(year)

esttab, b(2) p(3)
*** EDITED by Ryan Steed
estout using "results/Table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
***

**************************************************************************************************************************************;

**************************************************************************************************************************************;
*Calculation for McCain counterfactual reported in-line in Section 2.C.
use "$output/sample", clear
keep if year==2008
gen incum_share_counter=incum_share /*In 2008, incum_share=repvote/totalvotes*/
 
replace incum_share_counter=incum_share_counter+dividend_ratio*2.2*(0.855+0.158) 
 
gen dem_share=demvote/totalvotes
gen dem_share_counter=dem_share
replace dem_share_counter=dem_share-dividend_ratio*2.2*(0.855+0.158) 
 
/*Counterfactual counties*/
count if incum_share<dem_share & incum_share_counter>dem_share_counter
 
gen repvote_counter=repvote+totalvotes*dividend_ratio*2.2*(0.855+0.158)
gen demvote_counter=demvote-totalvotes*dividend_ratio*2.2*(0.855+0.158)
 
sort st
by st: egen repvote_st=sum(repvote)
by st: egen demvote_st=sum(demvote)
 
by st: egen repvote_st_counter=sum(repvote_counter)
by st: egen demvote_st_counter=sum(demvote_counter)
 
list st if repvote_st<demvote_st & repvote_st_counter>demvote_st_counter



**************************************************************************************************************************************;

*** EDITED by Ryan Steed. To save time, skipping non-important results ***
if 0 {
***


/*********************************************
Code that calculates orthogonilzed returns series and estimates macro var regressionfor
for bootstrap samples
 
Files used:
                msi_real.dta : CRSP Value Weighted Return Series
                macro_vars_all.dta  : dataset of all macro series used - created from the included RAW macro data CSVs
                sample.dta: Overall sample dataset used in analysis


*********************************************/
clear all
  
 
 
use $output/msi_real.dta  /*CRSP Value Weighted Return Series*/
gen year=year(date)
gen month =month(date)
gen yr_mo=ym(year ,month)
format yr_mo %tm
gen yr_qtr=yq(year, quarter(date))
format yr_qtr %tq
 
drop cpi cpi_l1
 
 
merge m:1 yr_qtr using "$input/macro_vars_all.dta", keep(match using) /*drops return obs from before macro series starts*/
tsset yr_mo
 
 
gen agg_wage_d=week/l3.week-1
gen credit_spread=BAA_AAA_moody
gen s3UNRATE=s3.UNRATE
gen s3FEDFUNDS=s3.FEDFUNDS
gen s3credit_spread=s3.credit_spread
 
*Generates 3-quarter ahead macro value
local vars s3UNRATE real_gdp_growth  agg_wage_d   s3FEDFUNDS s3credit_spread 
                foreach v of local vars {
                                gen f3`v'=f3.`v'
                }
 
/*********************************************
Generate Bootstrap samples perserving rolling window persistence
***********************************************/
gen rand = _n
drop _merge
save  "$path_out/true_data.dta", replace
des
local N=`r(N)'
set seed 01022014
quietly{
                forvalues b=1/$bs_runs{
                                ds 
                                drop `r(varlist)'
                                set obs `N'
 
                                
                                gen rand=round(runiform(1,360))  in 1/360
                                forvalues i=361/`N' {
                                                
                                                replace rand=round(runiform(1+(`i'-360),`i'))  in `i'
                                }
                                
                                keep rand
                                merge m:1 rand using "$path_out/true_data.dta"
                                keep if _merge==3
                                drop _merge
                                save "$path_out/data_bs_`b'.dta", replace
                                
                                
                }              
                                
}
/***********************************************/                        
                

/*********************************************
Run rolling regression  in true data to create orthogonilzed returns.
***********************************************/          
 
local vars s3UNRATE real_gdp_growth  agg_wage_d   s3FEDFUNDS s3credit_spread 
foreach v of local vars{
				quietly{
				use "$path_out/true_data.dta", replace
				gen t=_n
				tsset t
				sleep 100
				rolling _b _se, window(360) saving("$path_out/betas", replace) keep(rand): reg ret `v' f3`v' 
				use "$path_out/betas", clear
				gen rand=end+6
								
				
				merge 1:1 rand using "$path_out/true_data.dta", gen(merge_betas)
				
				sort yr_mo
				gen mkt_pred= _b_cons + _b_`v'* `v'+ _b_f3`v'*f3`v'
				gen orth=ret-mkt_pred 
								
				keep yr_qtr yr_mo orth ret mkt_pred month year _b_`v'  _b_f3`v'
				}
				saveold "$path_out/orth_`v'_bs_true", replace version(12)  /*files output used in SAS generation of main tables*/

}


				
				
/*********************************************
*Bootstrap SE's for Table 3 
***********************************************/               
/*********************************************
Run rolling regression of  in boostrap samples
***********************************************/          
                
forvalues b=1/$bs_runs{            
                local vars s3UNRATE real_gdp_growth  agg_wage_d   s3FEDFUNDS s3credit_spread 
                foreach v of local vars{
                                quietly{
 
                                use "$path_out/data_bs_`b'.dta", replace
                                gen t=_n
                                tsset t
                                sleep 100
                                rolling _b _se, window(360) saving("$path_out/betas", replace) keep(rand): reg ret `v' f3`v' 
                                
                                
                                use "$path_out/betas", clear
                                gen rand=end+6
                                                
                                
                                merge 1:1 rand using "$path_out/true_data.dta", gen(merge_betas)
                                
                                sort yr_mo
                                gen mkt_pred= _b_cons + _b_`v'* `v'+ _b_f3`v'*f3`v'
                                gen orth=ret-mkt_pred 
                                                
                                keep yr_qtr yr_mo orth ret mkt_pred month year _b_`v'  _b_f3`v'
                                }
                                save "$path_out/orth_`v'_bs_`b'", replace
 
                }
}
 
 
                
/*********************************************
*Create single file for each bootstrap run with all the return variables
*Cumulate returns for each boostrap run
***********************************************/          
forvalues b=0/$bs_runs{
                di "`b'"
                quietly{
                local vars s3UNRATE real_gdp_growth  agg_wage_d   s3FEDFUNDS s3credit_spread 
                clear 
                set obs 8
                sleep 100
                
                if `b' ==0 {
                                local b "true"
                }
                
                save "$path_out\orth_bs_`b'", replace emptyok
                
                *cumulate returns
                foreach v of local vars{
                
                                                use "$path_out/orth_`v'_bs_`b'", replace
                                                replace year =yofd(dofm(yr_mo))
                                                replace month =month(dofm(yr_mo))
                                
                                tsset yr_mo
                                sort yr_mo
 
                                gen ln_ret=log(1+ret)
                                gen ln_ret_orth=log(1+orth)
                                gen ln_ret_pred=log(1+mkt_pred)
 
 
                                rangestat (sum) ln_ret, interval(yr_mo -48 -1)
                                rangestat (sum) ln_ret_orth, interval(yr_mo -48 -1)
                                rangestat (sum) ln_ret_pred, interval(yr_mo -48 -1)
 
                                gen ret_cum=exp(ln_ret_sum)-1
                                gen ret_orth_`v'=exp(ln_ret_orth_sum)-1
                                gen ret_pred_`v'=exp(ln_ret_pred_sum)-1
                                
                                
 
                                keep if inlist(year, 1992,1996,2000,2004,2008,2012,2016,2020) & month==11
                                
                                keep year  ret_cum ret_orth ret_pred
                                
                                merge 1:1 _n using   "$path_out\orth_bs_`b'", gen(merge_`v')
                                sleep 500
                                save  "$path_out\orth_bs_`b'", replace
                                }
                }
}
 
 
 
 
/*********************************************
*Below is the second stage of the two-stage bootstrap procedure.
 
***********************************************/          
 
 
 
/*********************************************
*Create files for posting bootstrapped standard error results
***********************************************/          
 
eststo clear
tempname myresults_gdp 
postfile `myresults_gdp' b_sample div_ratio div_ratio_se div_inter div_inter_se using "$path_out/coeffs_gdp_bs.dta", replace
 
 
tempname myresults_agg_wage_d
postfile `myresults_agg_wage_d' b_sample div_ratio div_ratio_se div_inter div_inter_se using "$path_out/coeffs_agg_wage_d_bs.dta", replace
 
 
tempname myresults_UNRATE
postfile `myresults_UNRATE' b_sample div_ratio div_ratio_se div_inter div_inter_se using "$path_out/coeffs_UNRATE_bs.dta", replace
 
tempname myresults_FEDFUNDS
postfile `myresults_FEDFUNDS' b_sample div_ratio div_ratio_se div_inter div_inter_se using "$path_out/coeffs_FEDFUNDS_bs.dta", replace
 
 
tempname myresults_credit_spread
postfile `myresults_credit_spread' b_sample div_ratio div_ratio_se div_inter div_inter_se using "$path_out/coeffs_credit_spread_bs.dta", replace
 
 
/*********************************************
*Run regressions on 1st stage bootstrap samples, bootstrapping the second stage.
***********************************************/          
set seed 11062019
 
forvalues b=0/$bs_runs{
                
                use "$output/sample.dta", replace             /*Main Sample.dta file*/
                sort year
                if `b'==0{
                                merge m:1 year using   "$path_out/orth_bs_true.dta", gen(merge_`b')
 
                }
                else {
                                merge m:1 year using  "$path_out/orth_bs_`b'.dta", gen(merge_`b')
                }
                
                                *GDP growth;
                                quietly{
                                if `b'!=0 {
                                                bsample
                                                }
                                gen div_ret_orth=dividend_ratio*ret_orth_real_gdp_growth
                                eststo: reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)
                                post `myresults_gdp' (`b') (`=_b[dividend_ratio]') (`=_se[dividend_ratio]') (`=_b[div_ret_orth]') (`=_se[div_ret_orth]') 
                                
 
                                *Wage;
                                if `b'!=0 {
                                                bsample
                                                }
                                replace div_ret_orth=dividend_ratio*ret_orth_agg_wage_d
                                eststo: reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)
                                post `myresults_agg_wage_d' (`b') (`=_b[dividend_ratio]') (`=_se[dividend_ratio]') (`=_b[div_ret_orth]') (`=_se[div_ret_orth]') 
 
                                
                                *Change in unemployment rate;
                                if `b'!=0 {
                                                bsample
                                                }
                                replace div_ret_orth=dividend_ratio*ret_orth_s3UNRATE
                                eststo: reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)
                                post `myresults_UNRATE' (`b') (`=_b[dividend_ratio]') (`=_se[dividend_ratio]') (`=_b[div_ret_orth]') (`=_se[div_ret_orth]') 
 
 
                                *Federal funds rate;
                                if `b'!=0 {
                                                bsample
                                                }
                                replace div_ret_orth=dividend_ratio*ret_orth_s3FEDFUNDS
                                eststo: reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)
                                post `myresults_FEDFUNDS' (`b') (`=_b[dividend_ratio]') (`=_se[dividend_ratio]') (`=_b[div_ret_orth]') (`=_se[div_ret_orth]') 
 
 
                                *Change in credit spread;
                                if `b'!=0 {
                                                bsample
                                                }
                                replace div_ret_orth=dividend_ratio*ret_orth_s3credit_spread
                                eststo: reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)
                                post `myresults_credit_spread' (`b') (`=_b[dividend_ratio]') (`=_se[dividend_ratio]') (`=_b[div_ret_orth]') (`=_se[div_ret_orth]') 
                                }
 
 
 
eststo clear
}                              
postclose `myresults_gdp' 
postclose `myresults_agg_wage_d' 
postclose `myresults_UNRATE'
postclose `myresults_FEDFUNDS'
postclose `myresults_credit_spread'


 
/*********************************************
*Table 3 Stock orthogonalized returns with clustered SE's (bootstrap SE's Reported Below)
***********************************************/
use "$output\sample", clear

sort year
merge m:1 year using "$path_out\orth_bs_true"

*GDP growth;
gen div_ret_orth=dividend_ratio*ret_orth_real_gdp_growth

reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

*Wage;

replace div_ret_orth=dividend_ratio*ret_orth_agg_wage_d

reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

*Change in unemployment rate;

replace div_ret_orth=dividend_ratio*ret_orth_s3UNRATE

reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

*Federal funds rate;

replace div_ret_orth=dividend_ratio*ret_orth_s3FEDFUNDS

reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year)

*Change in credit spread;
replace div_ret_orth=dividend_ratio*ret_orth_s3credit_spread

reghdfe incum_d dividend_ratio div_ret_orth ipc_d pop_d wage_d unemp_d white_ratio_d-above65_ratio_d white_ratio_d_demIncum-unemp_d_demIncum, a(year) cluster(year) 
 
 
/*********************************************
*Report bootstrap p-values for Table 3 Results
***********************************************/
 
 
use "$path_out/coeffs_gdp_bs.dta", replace 
*list 
su div_inter if b!=0
local gdp_se = `r(sd)'
use "$path_out/coeffs_agg_wage_d_bs.dta", replace 
*list 
su div_inter if b!=0
local wage_se = `r(sd)'
use "$path_out/coeffs_UNRATE_bs.dta", replace 
*list 
su div_inter if b!=0
local unrate_se = `r(sd)'
use "$path_out/coeffs_FEDFUNDS_bs.dta", replace 
*list 
su div_inter if b!=0
local fedfunds_se = `r(sd)'
use "$path_out/coeffs_credit_spread_bs.dta", replace 
*list 
su div_inter if b!=0          
local credit_spread_se = `r(sd)'
 
 
**Output Coefficients under true data
use "$path_out/coeffs_gdp_bs.dta", replace 
*list 
su div_inter if b==0, meanonly
di "Coeff: `r(mean)'"
di "SE: `gdp_se' "
di "t-stat: " `r(mean)'/`gdp_se'
di "p-val:" (1-t(7,(`r(mean)'/`gdp_se')))*2
di "p-val: " ttail(7,abs(`r(mean)'/`gdp_se'))*2
 
use "$path_out/coeffs_agg_wage_d_bs.dta", replace 
*list 
su div_inter if b==0, meanonly
di "Coeff: `r(mean)'"
di "SE: `wage_se' "
di "t-stat: " `r(mean)'/`wage_se'
di "p-val: "(1-t(7,(`r(mean)'/`wage_se')))*2
di "p-val: " ttail(7,abs(`r(mean)'/`wage_se'))*2
 
 
use "$path_out/coeffs_UNRATE_bs.dta", replace 
*list 
su div_inter if b==0, meanonly
di "Coeff: `r(mean)'"
di "SE: `wage_se' "
di "t-stat:" `r(mean)'/`unrate_se'
di "p-val: "(1-t(7,(`r(mean)'/`unrate_se')))*2
di "p-val: " ttail(7,abs(`r(mean)'/`unrate_se'))*2
 
 
use "$path_out/coeffs_FEDFUNDS_bs.dta", replace 
*list 
su div_inter if b==0, meanonly
di "Coeff: `r(mean)'"
di "SE: `wage_se' "
di "t-stat: " `r(mean)'/`fedfunds_se'
di "p-val: "(1-t(7,(`r(mean)'/`fedfunds_se')))*2
di "p-val: " ttail(7,abs(`r(mean)'/`fedfunds_se'))*2
 
use "$path_out/coeffs_credit_spread_bs.dta", replace 
*list 
su div_inter if b==0, meanonly
di "Coeff: `r(mean)'"
di "SE: `wage_se' "
di "t-stat: "`r(mean)'/`credit_spread_se'
di "p-val: "(1-t(7,(`r(mean)'/`credit_spread_se')))*2
di "p-val: " ttail(7,abs(`r(mean)'/`credit_spread_se'))*2
 



**************************************************************************************************************************************;
*Figure 1
use sample, clear
sort year
by year: egen incum_d_m=mean(incum_d)
replace incum_d=incum_d-incum_d_m
sort fips year
drop if incum_d==. | ret==.
by fips: gen x=_N
drop if x!=8
gen co=0
gen se=0
gen df=0
xtile pct = dividend_ratio, nq(10)

forvalues x=1/10{
reg incum_d ret if pct==`x', cluster(year)
mat b = e(b)
mat V= e(V)
local df=`e(df_r)'
local bw = b[1,1]
local se=V[1,1]
replace co=`bw' if  pct==`x'
replace se=sqrt(`se') if  pct==`x'
replace df=`df' if  pct==`x'
}

keep pct co se df
duplicates drop

gen co_u = co + invttail(df,0.05)*se
gen co_l = co - invttail(df,0.05)*se

label var pct "Dividend-income ratio decile"
label var co "Sensitivity of change in vote share to stock returns"
twoway rcap co_u co_l pct || scatter co pct,  legend(off)  ytitle(Sensitivity of change in vote share to stock returns) note("with 90% confidence interval") scheme(s1color) 
 
*** EDITED by Ryan Steed ***
}
***