*==============================================================================
* Description: This do-file runs the regressions in Table A6
* Data: 2/7/2025
*===============================================================================
	
* Dataset
use "$datasets/final_penalties_dataset.dta", clear

* Variables of interest
gen high_p = spp 
gen high_f = drug_free
gen med_p = t_adj 

gen dist_2 = dist_drug
replace dist_2 = -dist_drug if drug_free==0
gen no_sc = (dist_2<=900)

* Estimation sample (observations within 1000ft of DF zone but beyond school grounds)
keep if dist_drug<=1000 & no_sc==1

* Singletons
bys block_id: egen temp1=count(block_id)
drop if temp1==1 //399 singletons
bys neighborhood year: egen temp2=count(block_id)
drop if temp2==1 //3 singletons in neighborhoodXyear
bys police_district year: egen temp3=count(block_id)
drop if temp3==1 //no singletons in police districtXyear

********************************************************
* Table 1: Main results
********************************************************
drop temp_year
gen temp=1 //use variable to get name right when exporting to table

estimates clear
set more off


* Panel OLS
foreach var in drug_AM {
	* Only fines
	reghdfe `var' drug_free##temp dist_drug [aw=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 
		gen sample=e(sample)
		
		sum `var' if sample==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF, SPP, and Adjacent blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store sim_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Fines interacted with monitoring intensity
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if sample==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store main_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Fines interacted with monitoring intensity
	* Police district by Year trends
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length], ///
		absorb(block_id year police_district#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if sample==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store trend_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd local nblocks=r(unique)
		estadd local NY "No"
		estadd local PY "Yes"
}
drop sample

* OLS restricted to Panel Poisson sample
qui:ppmlhdfe drug_AM drug_free##temp dist_drug [w=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 
		gen psample=e(sample)
		
		
foreach var in drug_AM {
	* Only fines
	reghdfe `var' drug_free##temp dist_drug [aw=block_length] if psample, ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 
		gen sample=e(sample)
		
		sum `var' if psample==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store simp_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"
		
	* Fines interacted with monitoring intensity
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length] if psample, ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if psample==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store mainp_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Fines interacted with monitoring intensity
	* Police district by Year trends
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length] if psample, ///
		absorb(block_id year police_district#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if psample==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store trendp_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd local nblocks=r(unique)
		estadd local NY "No"
		estadd local PY "Yes"
}

estout sim_drug_AM main_drug_AM trend_drug_AM simp_drug_AM mainp_drug_AM trendp_drug_AM ///
using "$output/table_ols_poisson_restriction.tex", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.drug_free 1.med_p 1.high_p 1.drug_free#1.med_p 1.drug_free#1.high_p) ///
varlabels(1.drug_free "Drug-free" 1.med_p "Adj. block" 1.high_p "SPP" ///
1.drug_free#1.med_p "Drug-free $\times$ Adj. block" 1.drug_free#1.high_p "Drug-free $\times$ SPP") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(Mean Obs nblocks N_clust NY PY p2, fmt(3 0 0 0 0 0 3) ///
labels("Mean" "Observations" "Blocks" "Neighborhoods" "Neighborhood $\times$ Year FE" "Police district $\times$ Year FE" ///
"P-value ($\beta_{Drug-free $\times$ Adj}=\beta_{Drug-free $\times$ SPP}$)"))




