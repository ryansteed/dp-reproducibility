/*******************************************************************************
Program: School Board Elections Analysis
Purpose: Examine School Board Election Data: 

	     What did voter turnout look like pre-COVID? 
		 
		 What district and election factors predicted turnout? 

Programmer: Alvin Christain (Updating Brian Jacob Code)

Date: 03/20/23

Outline: 


Notes:
*******************************************************************************/
clear 

set more off

clear matrix

clear mata

set matsize 5000

clear 

global finaldata "../Final analysis data"
global out "../"

cd "."

program drop _all


/************************************************************
Table 1
*************************************************************/

use "$finaldata/SBE_base_data.dta", clear  

*** Now drop obs so you have data set with just one obs per LEA 
duplicates drop leaid, force  

*Now start creating table 
global vars "tot_enroll baplusall povertyall perblk perhsp perasn town rural agg_all miss_scores district_pct_trump  fordham_score  pct_inperson_distr_yr  pct_virtual_distr_yr  never_mask_req tot_pct_offtrend2021"


//table 1
estimates clear
estpost tabstat $vars [aw=tot_enroll],columns(statistics) //col1
esttab using "${out}/table1_col1.csv",  cells(mean) replace	

bys has_data: eststo: estpost tabstat $vars [aw=tot_enroll],columns(statistics) //col2-3
esttab using "${out}/table1_col2to3.csv",  cells(mean) replace	

estimates clear

// sum $vars [aw=tot_enroll] //col1
// sum $vars if has_data==0 [aw=tot_enroll] //col2
// sum $vars if has_data [aw=tot_enroll] //col3
//



***********************************************************
*** BRING BACK DATA SET WITH MULTIPLE OBS PER DISTRICT ****
*************************************************************

use "$finaldata/SBE_base_data.dta", clear  
*use `useforrestofanalysis',clear
keep if has_voting_data




 
/************************************************************
Table 2
*************************************************************/

* school district and election vars
gen sch_dist = (election_district_type=="School District")
gen sch_dist_sub = (election_district_type!="School District")
tab election_year,gen(election_year_)
tab el_month,gen(el_month_)
gen el_month_other = !inlist(el_month,4,5,6,8,11)
gen votes_per_seat_per_pop1k = votes_per_seat_per_pop * 1000
label var votes_per_seat_per_pop1k "Votes per seats up for election per 1k civ pop"

gen contested = (uncontested==0)
gen all = 1

global elect_char "votes_per_seat_per_pop1k num_cand_per_seat frac_incumbent_who_ran frac_incumbent_who_won sch_dist sch_dist_sub general pri_nonpart pri_partisan seats_up_for_election num_candidates_total any_incumbent contested election_year_1 election_year_2 election_year_3 election_year_4 election_year_5 el_month_4 el_month_5 el_month_6 el_month_8 el_month_11 el_month_other "

global dist_char "tot_enroll town rural urban perblk perhsp perfrl district_pct_trump baplusall agg_all miss_scores"

* orth_out $elect_char $dist_char using "$out/table2.csv" if regular == 1 & runoff==0 , by(all) bdec(2) count replace
* orth_out $elect_char $dist_char using "$out/table2.csv" if regular == 1 & runoff==0 , by(uncontested) bdec(2) count replace happend



/************************************************************
Figure A1
*************************************************************/


* FIGURE 

//plotting number of recall (unique districts and races)
preserve
keep if recal == 1
gen elections = 1
gen unique_dist = 0
bys leaid: replace unique_dist = 1 if _n == 1
collapse (sum) elections unique_dist, by(election_year)

gr bar unique_dist elections, over(election_year) ///
bar(1, color(navy*0.75)) bar(2, color(maroon*0.75))  ///
blabel(total, size(medium) format(%9.0f)) legend(pos(6) order (1 "Unique districts" 2 "Total races"))  ///
graphregion(color(white)) bgcolor(white)  ytitle("") //xline(2019.5 ,lcolor(red) lpattern(dash)) 
gr_edit plotregion1.AddLine added_lines editor 40 0 40 15.2
gr_edit plotregion1.added_lines_new = 1
gr_edit plotregion1.added_lines_rec = 1
gr_edit plotregion1.added_lines[1].style.editstyle  linestyle( width(sztype(relative) val(.2) allow_pct(1)) color(red) pattern(dash) align(inside)) headstyle( symbol(circle) linestyle( width( sztype(relative) val(.2) allow_pct(1)) color(black) pattern(solid) align(inside)) fillcolor(black) size( sztype(relative) val(1.52778) allow_pct(1)) angle(stdarrow) symangle(zero) backsymbol(none) backline( width( sztype(relative) val(.2) allow_pct(1)) color(black) pattern(solid) align(inside)) backcolor(black) backsize( sztype(relative) val(0) allow_pct(1)) backangle(stdarrow) backsymangle(zero)) headpos(neither) editcopy
gr save "$out/figure a1.gph",replace
gr export "$out//figure a1.pdf",replace 
restore


/************************************************************
Table A1
*************************************************************/

*Show characteristics of districts with recalls before and after
preserve
keep if recall==1
//duplicates drop leaid election_date, force  //drop dups
* orth_out rural suburb town urban tot_enroll baplusall perfrl perblk perhsp agg_all miss_scores fordham_score district_pct_trump using "$out/table a1.xlsx", by(post_covid) vce(cluster leaid) bdec(2) count compare replace stars test

//stars 
recode post_covid (0=1) (1=0)
estimates clear
local j = 1
foreach var of varlist rural suburb town urban tot_enroll baplusall perfrl perblk perhsp agg_all miss_scores fordham_score district_pct_trump  {
	
	qui eststo  :  reg `var' post_covid, vce(cluster leaid)
	
}
esttab * using "${out}/table a1 stars.csv",  drop(_cons) noconstant noabbrev cells(b(star fmt(2))) starlevel(* .1 ** .05 *** .01) noobs  lab replace	
restore


/************************************************************
 FOCUS ON REGULAR ELECTIONS 
*************************************************************/


keep if regular==1 /* this drops recalls and special elections */
drop if runoff==1 /* this drops runoff elections */

gen el_month2=el_month
recode el_month2 3=2 7=8 9=8 10=11 12=11 

gen miss_imp_mode = mode_start_distr==. | mode_imp==1 


egen tagd=tag(leaid)
egen tagd2=tag(leaid) if no_election==0
 
egen tags=tag(fips_geo)
egen tago=tag(office_id)

pwcorr ln_enroll perblk perhsp perfrl district_pct_trump agg_all baplusall if tagd  

egen n_dist_per_stat=nvals(school_district_name), by(fips_geo)
tab n_dist_per_stat if tags, m  


gen post_general = post_covid*general

global elvar "subdivision pri_partisan pri_nonpart any_incumbent ib11.el_month"
global elvar2 "subdivision pri_partisan pri_nonpart ib11.el_month num_candidates_total num_incumbent"
global dem "town rural urban perfrl perblk perhsp agg_all miss_scores" 
global dem2 "town rural urban ln_enroll baplusall perfrl perblk perhsp agg_all miss_scores fordham_score district_pct_trump" 
global choice "some_ch_priv l_avg_ratio_ch_priv_10"
global outcome "recall canceled"
global outcome "num_cand_per_seat any_incumbent frac_incumbent frac_incumbent_winners l_votes_per_seat_per_pop" 



//set vote vars to missing if No elec
foreach v in votes_per_seat votes_per_candidates votes_per_pop votes_per_school_enr votes_per_seat_per_pop l_votes_per_seat_per_pop {
	replace `v'=. if no_election==1
} 




/*******************************************************************************
table 3
*******************************************************************************/


estimates clear 

sum contested if election_date<mdy(3,10,2020) 
eststo: reg contested ln_enroll town rural urban perblk perhsp perfrl district_pct_trump baplusall agg_all miss_scores  ${elvar}  if election_date<mdy(3,10,2020), cl( office_id)

sum l_votes_per_seat_per_pop if election_date<mdy(3,10,2020) 
eststo: reg l_votes_per_seat_per_pop ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall ${elvar}  if election_date<mdy(3,10,2020) & no_election==0 , cl( office_id)

esttab * using "${out}/table3.csv",  drop(_cons) noconstant noabbrev cells(b(star fmt(3)) se(par fmt(3))) starlevel(* .1 ** .05 *** .01) stats(r2 N, ///
labels( "R-squared") fmt(  3 0 )) noobs lab replace	



/*******************************************************************************
table 4
*******************************************************************************/


*POST COVID CHANGE - uncontested - general and primary

bysort post_covid: sum general pri_nonpart pri_partisan

gen post_prinonpart = post_covid*pri_nonpart
gen post_pripartisan = post_covid*pri_partisan 
drop if missing(perfrl)
estimates clear

//post covid No cov
eststo: reg contested post_covid, cl( office_id)
estadd local fe No
estadd local cov No

//post covid cov
eststo: reg contested post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump baplusall agg_all miss_scores subdivision pri_nonpart pri_partisan i.el_month any_incumbent, cl( office_id)
estadd local fe No
estadd local cov Yes

//dist fixed effects
eststo: areg contested post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump baplusall agg_all miss_scores subdivision pri_nonpart pri_partisan i.el_month any_incumbent, a(leaid) cl( office_id)
estadd local fe Yes
estadd local cov Yes

//dif effect for general
eststo: reg contested post_covid general post_general ln_enroll town rural urban perblk perhsp perfrl district_pct_trump baplusall agg_all miss_scores subdivision i.el_month any_incumbent, cl( office_id)
estadd local fe No
estadd local cov Yes
lincom post_covid + post_general

//dif effect for general with fe
eststo: areg contested post_covid general post_general ln_enroll town rural urban perblk perhsp perfrl district_pct_trump baplusall agg_all miss_scores subdivision i.el_month any_incumbent, a(leaid) cl( office_id)
estadd local fe Yes
estadd local cov Yes


esttab * using "${out}/table4.csv",  drop(_cons ln_enroll town rural urban perblk perhsp perfrl district_pct_trump baplusall agg_all miss_scores subdivision pri_nonpart pri_partisan *el_month any_incumbent) noconstant noabbrev cells(b(star fmt(3)) se(par fmt(3))) starlevel(* .1 ** .05 *** .01) stats(cov fe r2 N, ///
labels("Covariates" "District FE" "R-squared") fmt(strL strL  3 0 )) noobs lab replace	


/**************************************
Figure 1
***********************************/
tempfile tmp
save `tmp'

* get month

gen month = month(election_date)
drop if inlist(month,2,3,7,9,10,12)

label define monthf 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sept" 10 "Oct" 11 "Nov"
label values month monthf
gen month_cat = 1 if inrange(month,4,5)
replace month_cat = 2 if inrange(month,6,8)
replace month_cat = 3 if inrange(month,11,11)

gen label = string(election_date, "%td")

tab el_yr_mn if regular==1 & no_election==0 & runoff==0 & inlist(month,4,5,6,8,11), m 


gen rel3_votes_per_seat_per_pop1k = votes_per_seat_per_pop1k if regular==1 & no_election==0 & runoff==0 & inlist(month,4,5,6,8,11) & el_yr_mn!=715 & el_yr_mn!=739 & general==1 //raw general


preserve 
collapse (mean) rel3_votes_per_seat_per_pop1k  if inlist(month,4,5,6,8,11), by(election_year month_cat)
gen election_date = string(election_year) + "q" + string(month_cat+1)
numdate q election_date2 = election_date, pattern(YQ) clean


format rel3_votes_per_seat_per_pop1k  %9.0f

forval i = 3/3 {
tw bar rel`i'_votes_per_seat_per_pop1k election_date2 if month_cat==1 , color(navy*0.25) mlabel(rel`i'_votes_per_seat_per_pop1k) mlabsize(small) mlabcolor(black) || ///
bar rel`i'_votes_per_seat_per_pop1k election_date2 if month_cat==2, color(navy*0.75) mlabel(rel`i'_votes_per_seat_per_pop1k) mlabsize(small) mlabcolor(black) || ///
bar rel`i'_votes_per_seat_per_pop1k election_date2 if month_cat==3 , color(navy*1.25) xlab(234 "2018" 238 "2019" 242 "2020" 246 "2021" 250 "2022", labsize(medium) notick) ///
legend(pos(6) order(1 "Spring" 2 "Summer" 3 "Fall") r(1)) graphregion(color(white)) bgcolor(white) ///
xtitle("Election Date") ytitle("Votes Per Seat Per 1K") xline( 240 ,lcolor(red) lpattern(dash)) ///
plotregion(margin(0)) mlabel(rel`i'_votes_per_seat_per_pop1k) mlabsize(small) mlabcolor(black) ylab(0(100)400, format(%9.0f))
gr save "$out/figure 1.gph",replace
gr export "$out//figure 1.pdf",replace
}
restore




/*******************************************************************************
table 5
********************************************************************************/

* use `tmp',clear
qui sum l_votes_per_seat_per_pop if no_election==0
local outcome_mean = round(`r(mean)',0.001)

qui sum l_votes_per_seat_per_pop if no_election==0 & el_month!=11
local outcome_mean2 =round(`r(mean)',0.001)

estimates clear

//simple correlation
eststo: reg l_votes_per_seat_per_pop post_covid if no_election==0 , cl(office_name)
estadd local out_mean `outcome_mean'
estadd local fe No
//estadd local cov Yes
estadd local cov No


//main chars
eststo main: reg l_votes_per_seat_per_pop post_covid  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 , cl(office_name)
estadd local fe No
//estadd local cov Yes
estadd local cov Yes
estadd local out_mean `outcome_mean'



//main chars  with other post-covid
eststo: reg l_votes_per_seat_per_pop summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 , cl(office_name)
estadd local fe No
//estadd local cov Yes
estadd local cov Yes
estadd local out_mean `outcome_mean'

//main chars  with other post-covid
eststo: reg l_votes_per_seat_per_pop summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & el_month!=11 , cl(office_name)
estadd local fe No
//estadd local cov No
estadd local cov Yes
estadd local out_mean `outcome_mean2'

//main chars  with other post-covid and office fe
eststo: areg l_votes_per_seat_per_pop summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 ,a(office_id) cl(office_name)
estadd local fe Yes
estadd local cov Yes
//estadd local cov Yes
estadd local out_mean `outcome_mean'

//main chars  with other post-covid and office fe and No nov
eststo: areg l_votes_per_seat_per_pop summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & el_month!=11,a(office_id) cl(office_name)
estadd local fe Yes
//estadd local cov No
estadd local cov Yes
estadd local out_mean `outcome_mean2'

*** EDITED by Donna
estout using "../../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

esttab * using "${out}/table5.csv",  keep(post_covid any_incumbent summer2020 ay2022 ) noconstant noabbrev cells(b(star fmt(3)) se(par fmt(3))) starlevel(* .1 ** .05 *** .01) stats(out_mean cov fe nov r2 N, ///
labels("Outcome mean" "Covariates" "Office FE" "Include Nov" "R-squared") fmt(3 strL strL strL  3 0 )) noobs nocons lab replace	



********************************************
*table a2
********************************************


qui sum l_votes_per_seat_per_pop if no_election==0 & general==1
local outcome_mean = round(`r(mean)',0.001)

qui sum l_votes_per_seat_per_pop if no_election==0 & el_month!=11 & general==0
local outcome_mean2 =round(`r(mean)',0.001)

estimates clear

eststo: reg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==1 , cl(office_name)
estadd local fe No
estadd local cov Yes
estadd local out_mean `outcome_mean'

eststo: reg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==1 & el_month!=11 , cl(office_name)
estadd local fe No
estadd local out_mean `outcome_mean'
estadd local cov Yes

eststo: areg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==1 , a(office_id) cl(office_name)
estadd local fe Yes
estadd local out_mean `outcome_mean'
estadd local cov Yes

eststo: areg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==1 & el_month!=11 , a(office_id) cl(office_name)
estadd local fe Yes
estadd local out_mean `outcome_mean'
estadd local cov Yes

eststo: reg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==0 , cl(office_name)
estadd local fe No
estadd local out_mean `outcome_mean2'
estadd local cov Yes

eststo: reg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==0 & el_month!=11 , cl(office_name)
estadd local fe No
estadd local out_mean `outcome_mean2'
estadd local cov Yes

eststo: areg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==0 , a(office_id) cl(office_name)
estadd local fe Yes
estadd local out_mean `outcome_mean2'
estadd local cov Yes

eststo: areg l_votes_per_seat_per_pop post_covid ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & general==0 & el_month!=11 , a(office_id) cl(office_name)
estadd local fe Yes
estadd local out_mean `outcome_mean2'
estadd local cov Yes


esttab * using "${out}/table a2.csv",  keep(post_covid) noconstant noabbrev cells(b(star fmt(3)) se(par fmt(3))) starlevel(* .1 ** .05 *** .01) stats(out_mean cov fe nov r2 N, ///
labels("Outcome mean" "Covariates" "District FE" "Include Nov" "R-squared") fmt(3 strL strL strL 3 0 )) noobs nocons lab replace
  

********************************************
*table a3
********************************************

sum l_votes_per_seat_per_pop num_cand_per_seat frac_incumbent_who_ran frac_incumbent_winners if no_election==0 

sum l_votes_per_seat_per_pop num_cand_per_seat frac_incumbent_who_ran frac_incumbent_winners if no_election==0 & el_month!=11 



sum l_votes_per_seat_per_pop num_cand_per_seat num_incumbent num_winners frac_incumbent runoff if no_election==0 & frac_incumbent_winners==. 


estimates clear

foreach y in num_cand_per_seat frac_incumbent_who_ran frac_incumbent_who_won {


//main and indicators for time and  nov
qui su `y' if no_election==0
local outcome_mean : di %4.3f `r(mean)'
local outcome_sd : di %4.3f `r(sd)'
local outcome_sd2 = "(" + "`outcome_sd'" + ")"

eststo: reg `y' summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 , cl(office_name)
estadd local fe No
estadd local cov Yes
estadd local nov Yes
estadd local out_mean `outcome_mean'
estadd local out_sd `outcome_sd2'


//main and indicators for time and office fe and nov
eststo: areg `y' summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 , a(office_id) cl(office_name)
estadd local fe Yes
estadd local cov Yes
estadd local nov Yes
estadd local out_mean `outcome_mean'
estadd local out_sd `outcome_sd2'

//main and indicators for time and No nov
qui su `y' if no_election==0 & el_month!=11
local outcome_mean : di %4.3f `r(mean)'
local outcome_sd : di %4.3f `r(sd)'
local outcome_sd2 = "(" + "`outcome_sd'" + ")"


eststo: reg `y' summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & el_month!=11, cl(office_name)
estadd local fe No
estadd local nov No
estadd local cov Yes
estadd local out_mean `outcome_mean'
estadd local out_sd `outcome_sd2'

//main and indicators for time and office fe and No nov
eststo: areg `y' summer2020 ay2022  ln_enroll town rural urban perblk perhsp perfrl district_pct_trump agg_all miss_scores baplusall $elvar if no_election==0 & el_month!=11, a(office_id) cl(office_name)
estadd local fe Yes
estadd local nov No
estadd local cov Yes
estadd local out_mean `outcome_mean'
estadd local out_sd `outcome_sd2'

}
esttab * using "${out}/table a3.csv", keep(summer2020 ay2022) noconstant noabbrev cells(b(star fmt(3)) se(par fmt(3))) starlevel(* .1 ** .05 *** .01) stats(out_mean out_sd cov fe  nov  r2 N, ///
labels("Outcome mean" "Outcome SD" "Covariates" "District FE" "Include Nov" "R-squared") ///
fmt(3  strL strL strL strL 3 0 )) noobs nocons lab replace	

/************************************************************
Table 6
*************************************************************/


use "$finaldata/SBE_base_data.dta", clear 


*************************************************
***** NOW SAVE ONLY OBS WITH VOTING DATA ******
*************************************************
keep if has_data  == 1 

 
/************************************************************
        Descriptives
*************************************************************/

gen sch_dist = (election_district_type=="School District")
gen sch_dist_sub = (election_district_type!="School District")
tab election_year,gen(election_year_)
tab el_month,gen(el_month_)
gen el_month_other = !inlist(el_month,4,5,6,8,11)
gen votes_per_seat_per_pop1k = votes_per_seat_per_pop * 1000
label var votes_per_seat_per_pop1k "Votes per seats up for election per 1k civ pop"



/************************************************************
 FOCUS ON REGULAR ELECTIONS 
*************************************************************/


keep if regular==1 /* this drops recalls and special elections */
drop if runoff==1 /* this drops runoff elections */

gen el_month2=el_month
recode el_month2 3=2 7=8 9=8 10=11 12=11 

gen miss_imp_mode = mode_start_distr==. | mode_imp==1 


egen tagd=tag(leaid)
egen tagd2=tag(leaid) if no_election==0
 
egen tags=tag(fips_geo)
egen tago=tag(office_id)

pwcorr ln_enroll perblk perhsp perfrl district_pct_trump agg_all baplusall if tagd  

egen n_dist_per_stat=nvals(school_district_name), by(fips_geo)
tab n_dist_per_stat if tags, m  


gen post_general = post_covid*general

global elvar "subdivision pri_partisan pri_nonpart any_incumbent ib11.el_month"
global elvar2 "subdivision pri_partisan pri_nonpart ib11.el_month num_candidates_total num_incumbent"
global dem "town rural urban perfrl perblk perhsp agg_all miss_scores" 
global dem2 "town rural urban ln_enroll baplusall perfrl perblk perhsp agg_all miss_scores fordham_score district_pct_trump" 
global choice "some_ch_priv l_avg_ratio_ch_priv_10"
global outcome "recall canceled"
global outcome "num_cand_per_seat any_incumbent frac_incumbent frac_incumbent_winners l_votes_per_seat_per_pop" 



//set vote vars to missing if No elec
foreach v in votes_per_seat votes_per_candidates votes_per_pop votes_per_school_enr votes_per_seat_per_pop l_votes_per_seat_per_pop {
	replace `v'=. if no_election==1
} 




*****************************************************************************
*** CREATE LEAID SPECIFIC CHANGE IN TURNOUT FOR HETEROGENEITY ANALYSES ***** 
******************************************************************************   

preserve 

keep if no_election==0 

 keep if both==1


tab leaid, gen(ll_)
foreach d of varlist ll_* {
	 gen pp_`d'=post_covid*`d' 
}
drop ll_* 


	
areg l_votes_per_seat_per_pop pp_ll_* $elvar, a(office_id) 
gen beta2=.
gen se2=.	
	
	
forvalues d = 1(1)255 {
	capture replace beta2=_b[pp_ll_`d'] if pp_ll_`d'==1 
	capture replace se2=_se[pp_ll_`d']  if pp_ll_`d'==1 
	}
	
	
	
	
keep leaid  beta2 se2 
keep if beta2!=.
sum 
duplicates drop leaid, force 	
tempfile  tmp_turnout
save `tmp_turnout'

 
restore 

merge m:1 leaid using `tmp_turnout', keepusing(beta2 se2) 

keep if beta!=.
duplicates drop leaid, force 
drop _merge 
capture drop tag 
egen tag=tag(leaid) 
sum beta2 se2 

gen wgt2=1/se2 


foreach x in hybrid inperson virtual {
	egen tmp=rmean(pct_`x'_distr_q1 pct_`x'_distr_q2 pct_`x'_distr_q3 pct_`x'_distr_q4)
	replace pct_`x'_distr_yr=tmp if pct_`x'_distr_yr==. 
	drop tmp 
}

foreach x in inperson virtual {
 impute pct_`x'_distr_yr  ln_enroll baplusall povertyall perfrl perblk perhsp urban suburb town rural district_pct_trump fordham_score mask_never mask_always pct_vax_2022 avg_deaths_per_month_per_1000, gen(i_pct_`x'_distr_yr) 
}

foreach x in inperson virtual {
 replace pct_`x'_distr_yr = i_pct_`x'_distr_yr if pct_`x'_distr_yr==. 
}
replace pct_hybrid_distr_yr = 1 - pct_inperson_distr_yr - pct_virtual_distr_yr if pct_hybrid_distr_yr==. 

replace inperson=0 if inperson==.
replace hybrid=1 if hybrid==.
replace remote=0 if remote==. 

replace never_mask_req=0 if state_name=="CALIFORNIA" & never_mask_req==.
replace never_mask_req=1 if state_name=="OKLAHOMA" & never_mask_req==.  

sum beta2 [aw=wgt2] 


egen town_rural=rsum(town rural) 


//table 6 col 1
estimates clear
foreach x in ln_enroll baplusall povertyall town_rural agg_all miss_scores fordham_score district_pct_trump state_vote_trump pct_virtual_distr_yr pct_inperson_distr_yr never_mask_req avg_deaths_per_month_per_1000 tot_pct_offtrend2021 {
eststo:  estpost tabstat `x' [aw=wgt2],columns(statistics) stat(mean sd) //col1 //col 1 (just copied and pasted this?)
//eststo:	reg beta2 `x' [aw=wgt2], r 
}
esttab using "${out}/table6_col1.csv",  cells(mean sd) replace	


//table 6 col 2
estimates clear
foreach x in ln_enroll baplusall povertyall town_rural agg_all miss_scores fordham_score district_pct_trump state_vote_trump pct_virtual_distr_yr pct_inperson_distr_yr never_mask_req avg_deaths_per_month_per_1000 tot_pct_offtrend2021 {
//sum `x' [aw=wgt2] //col 1 (just copied and pasted this?)
eststo:	reg beta2 `x' [aw=wgt2], r 
}
 
esttab * using "${out}/table 6 col2.csv",  noconstant noabbrev cells(b(star fmt(3)) se(par fmt(3))) starlevel(* .1 ** .05 *** .01) stats( r2 N, ///
labels("R-squared") fmt( 3 0 )) noobs nocons lab replace	

estimates clear
//table 6 col 3
eststo:	 reg beta ln_enroll baplusall povertyall town_rural agg_all miss_scores  district_pct_trump fordham_score [aw=wgt2], cl(state)

//table 6 col 4
eststo:	 reg beta ln_enroll baplusall povertyall town_rural agg_all miss_scores  fordham_score district_pct_trump /* state_vote_trump */  pct_virtual_distr_yr pct_inperson_distr_yr never_mask_req  [aw=wgt2], cl(state) 


//table 6 col 5
eststo:	 reg beta ln_enroll baplusall povertyall town_rural agg_all miss_scores  district_pct_trump fordham_score /* state_vote_trump */  pct_virtual_distr_yr pct_inperson_distr_yr never_mask_req  tot_pct_offtrend2021 [aw=wgt2], cl(state) 


esttab * using "${out}/table 6 col3to5.csv",  noconstant noabbrev cells(b(star fmt(3)) se(par fmt(3))) starlevel(* .1 ** .05 *** .01) stats( r2 N, ///
labels("R-squared") fmt( 3 0 )) noobs nocons lab replace	

