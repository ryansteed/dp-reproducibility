*** Directory ***
cd "C:\Users\\`=c(username)'\Dropbox\Working Files\Male Crime\Replication\"



********************************************************************************

***********************            Figure 3            *************************

********************************************************************************


clear all
set more off


********************     Pooled  Discontinuty Sample     ***********************


use "Data\arrest_data_discontinuity_states.dta", clear 


* Revert Texas (1985) CSL Drop for pooled effect
qui: replace disc=(disc==0) if fstate==48 & new_max==16
qui: replace time=-time-1 if fstate==48 & new_max==16


keep if time>=-5 & time<=4

gen arrest_rate_tot= exp(log_arrest_rate_tot)

keep if crime==1

* Keep Fully Balanced Counties
bysort age county_fips disc_id: egen balance=nvals(year)
bysort disc_id: egen max_balance=max(balance)
tab max_balance
keep if balance==max_balance


qui{
reghdfe arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc c.time#crime c.log_pop##crime disc_id#fcounty) cl(disc_id)
local b_disc2=round(_b[disc],0.001)
local se_disc2=round(_se[disc],0.001)
local mean_arrest_rate=_b[_cons]
qui: hdfe arrest_rate_tot disc [aw=population_est_cell], a(c.time#disc c.time#crime c.log_pop##crime disc_id#fcounty) gen(r_) clustervars(disc_id)
qui: reg r_* [aw=population_est_cell], cl(disc_id) nocons
boottest r_disc=0, reps(9999) boottype(wild) cl(disc_id) bootcluster(disc_id) nograph weight(webb) ptype(equaltail) seed(28102019)
qui: matrix c2 = (nullmat(c1),r(CI))
qui: local p_value2 = round(r(p),0.001) 
qui: local CI_l2 = c2[1,1]
qui: local CI_u2 = c2[1,2]
drop r_*

* Residual Adjust County and Log Population
reghdfe arrest_rate_tot [aw=population_est_cell], a(c.log_pop#crime disc_id#fcounty) res(arrest_rate_tot_res)
}




collapse (mean) arrest_rate_tot_res [aw=population_est_cell], by(time)


replace arrest_rate_tot_res=arrest_rate_tot_res+`mean_arrest_rate'

gen disc=(time>=0)

reg arrest_rate_tot_res disc disc##c.time

# delimit;
tw	scatter arrest_rate_tot_res time, color(black) ||
	lfit arrest_rate_tot_res time if time<0, color(black) lpattern(shortdash) ||
	lfit arrest_rate_tot_res time if time>=0, color(black) lpattern(shortdash)
	xlab(-5 "t-5" -4 "t-4" -3 "t-3" -2 "t-2" -1 "t-1" 0 "t" 1 "t+1" 2 "t+2" 3 "t+3" 4 "t+4")
	xline(-0.5, lcolor(black) lpattern(solid) lwidth(thin))
	graphregion(color(white)) bgcolor(white)
	ylab(0.082(0.002)0.090 , nogrid angle(horizontal) labsize(medsmall))
	legend(off)
	xtitle("Cohort Before/After Reform (t=0)", size(medsmall) )
	ytitle("Total Arrest Rate", size(medsmall))
	title( Pooled Reforms , color(black) size(medium))
	subtitle( "Reform (p-value) = `b_disc2' (`p_value2')", color(black) size(medsmall));
#d cr;

