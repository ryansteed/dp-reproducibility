*==============================================================================
* Description: This do-file runs the regressions in Table 4
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

drop temp_year
gen temp=1 //use variable to get name right when exporting to table


* Regressions 
estimates clear
set more off

 foreach var in drug_PM drug_wknd violent_PM property_PM {
	* Fines interacted with monitoring intensity
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store main_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"

	* Panel Poisson: Fines interacted with monitoring intensity
	ppmlhdfe `var' drug_free##(med_p high_p) dist_drug [w=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store mainp_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
}


estout main_* mainp* ///
using "$output/table_falsifications.tex", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.drug_free 1.med_p 1.high_p 1.drug_free#1.med_p 1.drug_free#1.high_p) ///
varlabels(1.drug_free "Drug-free" 1.med_p "Adj. block" 1.high_p "SPP" ///
1.drug_free#1.med_p "Drug-free $\times$ Adj. block" 1.drug_free#1.high_p "Drug-free $\times$ SPP") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(Mean Obs nblocks N_clust NY, fmt(3 0 0 0 0) ///
labels("Mean" "Observations" "Blocks" "Neighborhoods" "Neighborhood $\times$ Year FE"))




*======================================================================= 
*P-values from testing coefficients 
*=======================================================================

use "$datasets/final_penalties_dataset.dta", clear
append using "$datasets/final_penalties_dataset.dta", gen(source)

* Creating combined outcome variable
foreach var in drug_PM drug_wknd violent_PM property_PM {
	gen `var'_all = drug_AM if source==0
	replace `var'_all = `var' if source==1
}
gen am=1-source
drop source


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
drop temp1 temp2 temp3

********************************************************
* Table: Main vs Falsification results
********************************************************
estimates clear
set more off

foreach var in drug_PM drug_wknd violent_PM property_PM {
	* Fines interacted with monitoring intensity
	reghdfe `var'_all (drug_free##(med_p high_p) c.dist_drug)##am ///
	[aw=block_length], ///
	absorb(block_id year block_id#am year#am neighborhood#year#am) ///
	cluster(neighborhood)
		test 1.drug_free#1.med_p#1.am
		estadd scalar p1=r(p)	
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store main_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"

	* Panel Poisson: Fines interacted with monitoring intensity
	ppmlhdfe `var'_all (drug_free##(med_p high_p) c.dist_drug)##am ///
	[w=block_length], ///
	absorb(block_id year block_id#am year#am neighborhood#year#am) ///
	cluster(neighborhood)
		test 1.drug_free#1.med_p#1.am
		estadd scalar p1=r(p)	
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store mainp_`var'
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
}


estout main_* mainp* ///
using "$output/table_falsifications_test.tex", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.drug_free 1.med_p 1.high_p 1.drug_free#1.med_p 1.drug_free#1.high_p 1.drug_free#1.am 1.med_p#1.am 1.high_p#1.am 1.drug_free#1.med_p#1.am 1.drug_free#1.high_p#1.am) ///
varlabels(1.drug_free "Drug-free" 1.med_p "Adj. block" 1.high_p "SPP" ///
1.drug_free#1.med_p "Drug-free $\times$ Adj. block" 1.drug_free#1.high_p "Drug-free $\times$ SPP" 1.drug_free#1.am "Drug-free $\times$ AM" 1.med_p#1.am "Adj. block $\times$ AM" 1.high_p#1.am "SPP $\times$ AM" 1.drug_free#1.med_p#1.am "Drug-free $\times$ Adj. block $\times$ AM" 1.drug_free#1.high_p#1.am "Drug-free $\times$ SPP $\times$ AM") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(Mean Obs nblocks N_clust NY p1, fmt(3 0 0 0 0 3) ///
labels("Mean" "Observations" "Blocks" "Neighborhoods" "Neighborhood $\times$ Year FE" "P-value ($\beta_{Drug-free $\times$ Adj_{0}}=\beta_{Drug-free $\times$ Adj_{1}}$)"))



