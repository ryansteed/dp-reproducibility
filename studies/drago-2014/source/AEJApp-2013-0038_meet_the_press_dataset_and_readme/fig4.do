
***********
**FIGURE 4
**********

clear
use meet_the_press_data_readership, clear


*******LEADS AND LAGS PRINT NEWS TOT
sort provincia_ADS year
bys provincia_ADS: gen mean_entry_print_pc_m1=mean_entry_print_pc[_n-1]
bys provincia_ADS: gen mean_entry_print_pc_m2=mean_entry_print_pc[_n-2]
bys provincia_ADS: gen mean_entry_print_pc_m3=mean_entry_print_pc[_n-3]
bys provincia_ADS: gen mean_entry_print_pc_m4=mean_entry_print_pc[_n-4]


*sort provincia_ADS year
bys provincia_ADS: gen mean_entry_print_pc_p1=mean_entry_print_pc[_n+1]
bys provincia_ADS: gen mean_entry_print_pc_p2=mean_entry_print_pc[_n+2]
bys provincia_ADS: gen mean_entry_print_pc_p3=mean_entry_print_pc[_n+3]
bys provincia_ADS: gen mean_entry_print_pc_p4=mean_entry_print_pc[_n+4]



********LEADS AND LAGS WEB TOT
sort provincia_ADS year
bys provincia_ADS: gen mean_entry_web_pc_m1=mean_entry_web_pc[_n-1]
bys provincia_ADS: gen mean_entry_web_pc_m2=mean_entry_web_pc[_n-2]
bys provincia_ADS: gen mean_entry_web_pc_m3=mean_entry_web_pc[_n-3]
bys provincia_ADS: gen mean_entry_web_pc_m4=mean_entry_web_pc[_n-4]


*sort provincia_ADS year
bys provincia_ADS: gen mean_entry_web_pc_p1=mean_entry_web_pc[_n+1]
bys provincia_ADS: gen mean_entry_web_pc_p2=mean_entry_web_pc[_n+2]
bys provincia_ADS: gen mean_entry_web_pc_p3=mean_entry_web_pc[_n+3]
bys provincia_ADS: gen mean_entry_web_pc_p4=mean_entry_web_pc[_n+4]



***Analysis of on-impact change of newspaper readership with respect to (leads and lags) of entry of newspapers' print editions 
***(while controlling for (leads and lags) entry of online editions, macro-region by year fixed effects and all other controls of our main specification
foreach var of varlist diff_news_readership_pc     {
areg `var' mean_entry_print_pc_m* mean_entry_print_pc  mean_entry_print_pc_p*   mean_entry_web_pc_m* mean_entry_web_pc  mean_entry_web_pc_p*     diff_mean_own*    diff_log_unem diff_delta_log*    , r cluster( provincia_ADS) absorb(group_year_areageog)
}

parmest, saving(coeff_with_controls, replace)

*****Note: consistently with Gentzkow et al. (AER, 2011) we plot the coefficients t-k with k<0 on the left hand side and t-k with k>0 on the right hand side.
clear
use "coeff_with_controls.dta"
gen year=1 if parm=="mean_entry_print_pc_m1"
replace year=2 if parm=="mean_entry_print_pc_m2"
replace year=3 if parm=="mean_entry_print_pc_m3"
replace year=4 if parm=="mean_entry_print_pc_m4"

replace year=0 if parm=="mean_entry_print_pc"
replace year=-1 if parm=="mean_entry_print_pc_p1"
replace year=-2 if parm=="mean_entry_print_pc_p2"
replace year=-3 if parm=="mean_entry_print_pc_p3"
replace year=-4 if parm=="mean_entry_print_pc_p4"


eclplot  estimate  min95 max95 year

clear

erase "coeff_with_controls.dta"

