*==============================================================================
* Description: This do-file runs the regressions in Table A2
* Data: 2/7/2025
*===============================================================================
	
* Dataset
use "$datasets/final_penalties_dataset.dta", clear


gen full=1

* Ever SPP
bys block_id: egen tempsd = sd(spp)
gen spp_all = (tempsd>0 & tempsd<.)
drop tempsd

* Ever Adjacent/nonSPP
replace adj=0 if spp_all==1

* Beyond adj
gen non_adj=(adj==0)
replace non_adj=0 if spp_all==1

* Drug-free ever
bys block_id: egen tempmean = mean(drug_free)
gen df_always=(tempmean==1)
gen df_all=(tempmean>0)
gen df_temp=(tempmean>0 & tempmean<1)
drop tempmean

* No drug-free block
gen non_drug_free = 1- df_all

* Interactions
gen spp_df = (spp_all==1 & df_all==1)
gen spp_nodf = (spp_all==1 & df_all==0)
gen adj_df = (adj==1 & df_all==1)
gen adj_nodf = (adj==1 & df_all==0)
gen non_adj_df = (non_adj==1 & df_all==1)
gen non_adj_nodf = (non_adj==1 & df_all==0)

tempfile temp
save `temp'
	
foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	gcollapse (mean) drug_AM, by(full)
	rename drug_AM `X'
	tempfile mean_`X'
	save `mean_`X''
}

foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	gcollapse (sd) drug_AM, by(full)
	rename drug_AM `X'
	tempfile sd_`X'
	save `sd_`X''
}

foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	gcollapse (sum) `X', by(full)
	tempfile n_`X'
	save `n_`X''
}

foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	egen g`X'=group(block_id)
	gcollapse (max) g`X', by(full)
	rename g`X' `X'
	tempfile g_`X'
	save `g_`X''
}

use `mean_spp_df'
merge 1:1 full using `mean_spp_nodf', nogen
merge 1:1 full using `mean_adj_df', nogen
merge 1:1 full using `mean_adj_nodf', nogen
merge 1:1 full using `mean_non_adj_df', nogen
merge 1:1 full using `mean_non_adj_nodf', nogen
tempfile mean
save `mean'

use `sd_spp_df'
merge 1:1 full using `sd_spp_nodf', nogen
merge 1:1 full using `sd_adj_df', nogen
merge 1:1 full using `sd_adj_nodf', nogen
merge 1:1 full using `sd_non_adj_df', nogen
merge 1:1 full using `sd_non_adj_nodf', nogen
tempfile sd
save `sd'

use `n_spp_df'
merge 1:1 full using `n_spp_nodf', nogen
merge 1:1 full using `n_adj_df', nogen
merge 1:1 full using `n_adj_nodf', nogen
merge 1:1 full using `n_non_adj_df', nogen
merge 1:1 full using `n_non_adj_nodf', nogen
tempfile n
save `n'

use `g_spp_df'
merge 1:1 full using `g_spp_nodf', nogen
merge 1:1 full using `g_adj_df', nogen
merge 1:1 full using `g_adj_nodf', nogen
merge 1:1 full using `g_non_adj_df', nogen
merge 1:1 full using `g_non_adj_nodf', nogen
tempfile g
save `g'

use `mean'
append using `sd'
append using `n'
append using `g'

tempfile full
save `full'



* Estimation sample
use "$datasets/final_penalties_dataset.dta", clear
gen full=1

* Ever SPP
bys block_id: egen tempsd = sd(spp)
gen spp_all = (tempsd>0 & tempsd<.)
drop tempsd

* Ever Adjacent/nonSPP
replace adj=0 if spp_all==1

* Beyond adj
gen non_adj=(adj==0)
replace non_adj=0 if spp_all==1

* Drug-free ever
bys block_id: egen tempmean = mean(drug_free)
gen df_always=(tempmean==1)
gen df_all=(tempmean>0)
gen df_temp=(tempmean>0 & tempmean<1)
drop tempmean

* No drug-free block
gen non_drug_free = 1- df_all

* Interactions
gen spp_df = (spp_all==1 & df_all==1)
gen spp_nodf = (spp_all==1 & df_all==0)
gen adj_df = (adj==1 & df_all==1)
gen adj_nodf = (adj==1 & df_all==0)
gen non_adj_df = (non_adj==1 & df_all==1)
gen non_adj_nodf = (non_adj==1 & df_all==0)


* Estimation sample (observations within 1000ft of DF zone but beyond school grounds)
gen dist_2 = dist_drug
replace dist_2 = -dist_drug if drug_free==0
gen no_sc = (dist_2<=900)

keep if dist_drug<=1000 & no_sc==1

* Singletons
bys block_id: egen temp1=count(block_id)
drop if temp1==1 //399 singletons
bys neighborhood year: egen temp2=count(block_id)
drop if temp2==1 //3 singletons in neighborhoodXyear
bys police_district year: egen temp3=count(block_id)
drop if temp3==1 //no singletons in police districtXyear
drop temp1 temp2 temp3


tempfile temp
save `temp'
	
foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	gcollapse (mean) drug_AM, by(full)
	rename drug_AM `X'
	tempfile mean_`X'
	save `mean_`X''
}

foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	gcollapse (sd) drug_AM, by(full)
	rename drug_AM `X'
	tempfile sd_`X'
	save `sd_`X''
}

foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	gcollapse (sum) `X', by(full)
	tempfile n_`X'
	save `n_`X''
}

foreach X in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf { 
	use `temp', clear
	keep if `X'==1
	egen g`X'=group(block_id)
	gcollapse (max) g`X', by(full)
	rename g`X' `X'
	tempfile g_`X'
	save `g_`X''
}

use `mean_spp_df'
merge 1:1 full using `mean_spp_nodf', nogen
merge 1:1 full using `mean_adj_df', nogen
merge 1:1 full using `mean_adj_nodf', nogen
merge 1:1 full using `mean_non_adj_df', nogen
merge 1:1 full using `mean_non_adj_nodf', nogen
tempfile mean
save `mean'

use `sd_spp_df'
merge 1:1 full using `sd_spp_nodf', nogen
merge 1:1 full using `sd_adj_df', nogen
merge 1:1 full using `sd_adj_nodf', nogen
merge 1:1 full using `sd_non_adj_df', nogen
merge 1:1 full using `sd_non_adj_nodf', nogen
tempfile sd
save `sd'

use `n_spp_df'
merge 1:1 full using `n_spp_nodf', nogen
merge 1:1 full using `n_adj_df', nogen
merge 1:1 full using `n_adj_nodf', nogen
merge 1:1 full using `n_non_adj_df', nogen
merge 1:1 full using `n_non_adj_nodf', nogen
tempfile n
save `n'

use `g_spp_df'
merge 1:1 full using `g_spp_nodf', nogen
merge 1:1 full using `g_adj_df', nogen
merge 1:1 full using `g_adj_nodf', nogen
merge 1:1 full using `g_non_adj_df', nogen
merge 1:1 full using `g_non_adj_nodf', nogen
tempfile g
save `g'

use `mean'
append using `sd'
append using `n'
append using `g'

tempfile estim
save `estim'


use `estim'
append using `full'
foreach var in spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf {
	gen `var'_s = string(`var', "%4.3f")
	replace `var'_s = "("+`var'_s+")" if _n==2|_n==6
	replace `var'_s = string(`var', "%4.0f") if _n==3|_n==7
	replace `var'_s = string(`var', "%4.0f") if _n==4|_n==8
}

keep *_s
dataout, save("$output/Table_summary_stats_raw.txt") tex dec(3) replace 


