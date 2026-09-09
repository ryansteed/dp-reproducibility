*==============================================================================* 
* Project: CGVO and Rural Development in China                                 *
* Date:   December 2016                                                        *
* Please contact Guojun He (gjhe@ust.hk) for any coding errors                 * 
*==============================================================================* 

***** Wild Bootstrap for Standard Errors *****
***　Using Subsidized Population as an Example ***

*** Change to your own directory ***
cd C:\Users\pcadmin\Dropbox\Projects\Village_Officials\AEJ-Acceptance\Data_and_Codes\Data

cap log close 

* open log file
log using wild_bs_l_subsidy_rate.log , replace 

* set stata parameters
set more off 

* fix seed for replication purposes and
* set the number of bootstrap replications
set seed 365476247 
global bootreps = 999

tempfile main bootsave 

use workfile_AEJ, clear 
 
* summary stats of key covariates
sum l_subsidy_rate lag_cgvo

* construct the dummies used in analysis
xi i.village_id i.year

di 
* run ols without clustered std errors, just for comparison
qui reg l_subsidy_rate lag_cgvo _I* 

* now run ols and cluster at the prov level
qui reg l_subsidy_rate lag_cgvo _I*, cluster(prov) 
* save t-test as a global variable
global maint = _b[lag_cgvo] / _se[lag_cgvo] 

* now run OLS and impose null that lag_cgvo=0
qui reg l_subsidy_rate _I*

* output residuals
predict epshat , resid
predict yhat , xb 

* sort by prov, and temp save data
sort prov
qui save `main' , replace 

* get the number of provs
qui by prov: keep if _n == 1 
qui summ 
global numprovs = r(N) 


* output the t-statistics for lag_cgvo to a file
postfile bskeep t_wild using bs_results, replace


* iterate over the bootstrap replications
forvalues b = 1/$bootreps { 

/* wild bootstrap */
use `main', replace 

* with 50% probability constuct dummy
* that adds or substracts Radamaker error
qui by prov: gen temp = uniform() 
qui by prov: gen pos = (temp[1] < .5) 
gen wildresid = epshat * (2*pos - 1) 

* now construct y
gen wildy = yhat + wildresid 

* now regress y on all x variables
qui reg wildy _I* lag_cgvo, cluster(prov) 
* generate the t-stat
local bst_wild = _b[lag_cgvo] / _se[lag_cgvo] 

* add to the bottom of the post file
post bskeep (`bst_wild') 
}  

/* end of bootstrap reps */

* save the post file
postclose bskeep 

* clear the current data set
clear

* load up the wild t-stats
use bs_results

* figure out where the main-t is in the synthetic distribution
gen positive=$maint>0
gen pos=t_wild>$maint
gen neg=t_wild<$maint
gen reject=positive*pos + (1-positive)*neg
sum reject
local sumreject=r(sum)
local p_value_wild=2*`sumreject'/$bootreps
local p_value_main=2*(ttail(($numprovs-1),abs($maint)))


di "Number BS reps                         = $bootreps"
di "P-value from clustered standard errors = `p_value_main'"
di "P-value from wild boostrap             = `p_value_wild'"
log close 


*****　Bootstrapping takes a lot of time to run. Please repeat above process for other outcomes *****

