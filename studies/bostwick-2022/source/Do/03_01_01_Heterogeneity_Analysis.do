***************************************************************************
*Run on-time graduation analysis separately by:
*1) gender
*2) URM
*3) income

*March 29, 2019
***************************************************************************


local outcomes "BAin4 BAin5"
local groups "female urm low_ses"

use $main, clear

*Calculate low/high SES
egen cutpoint=median(mean_income)
capture drop low_ses
gen low_ses=mean_income<cutpoint
replace low_ses=. if mean_income==.
*URM = black or hispanic
gen urm=race_ind2+race_ind3

foreach g of varlist `groups' {
	bysort `g': summ `outcomes'
	*Adjust covariates to omit variable defining the current sub-group
	if "`g'"=="female" {
		local covariates "age age2 international race_ind1-race_ind4"
	}
	else if "`g'"=="urm" {
		local covariates "female age age2"
	}
	else {
		local covariates "female age age2 international race_ind1-race_ind4"
	}

	foreach y of varlist `outcomes' {
		*Set partially treated group corresponding to outcome
		if "`y'"=="BAin4" {
			local G1 "G1_4"
		}
		else {
			local G1 "G1_5"
		}

		***For group g = 0***
		preserve
		drop if `g'==1 | missing(`g')
		*Multi-way clustering:
		reghdfe `y' `G1' G2 `covariates' $time_trends , absorb(campus_num first_term) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
		*Campus-level clustering:
		reg `y' `G1' G2 `covariates' $FEs $time_trends, cluster(campus_num)
		*Wild bootstrap:
		boottest {`G1'} {G2}, boott(wild) small

		***For group g = 1***
		restore
		preserve
		drop if `g'==0 | missing(`g')
		*Multi-way clustering:
		reghdfe `y' `G1' G2 `covariates' $time_trends , absorb(campus_num first_term) vce(cluster cluster_id1 cluster_id2 cluster_id3 cluster_id4 cluster_id5)
		*Campus-level clustering:
		reg `y' `G1' G2 `covariates' $FEs $time_trends, cluster(campus_num)
		*Wild bootstrap:
		boottest {`G1'} {G2}, boott(wild) small
		restore

		*Do test for equality of main coeffiecients across the 2 samples:
		*Just for campus-level clustering
		eststo clear
		quietly bysort `g': eststo: reg `y' `G1' G2 `covariates' $FEs $time_trends
		suest est*, cluster(campus_num)
		foreach var of varlist `G1' G2 {
			test [est1_mean]_b[`var'] = [est2_mean]_b[`var']
		}

	}

}



