*==============================================================================
* Description: This do-file runs the regressions in Table 2
* Data: 2/7/2025
* Packages needed: geonear
*===============================================================================
	
* Dataset
use "../datasets/final_penalties_dataset.dta", clear

* Variables of interest
gen high_p = spp 
gen high_f = drug_free
gen med_p = t_adj 

gen dist_2 = dist_drug
replace dist_2 = -dist_drug if drug_free==0
gen no_sc = (dist_2<=900)

********************************************************
* Calculate band around drug-free zone boundary
********************************************************
* Expanded version of drug_free
gen drug_free2 = drug_free
replace drug_free2 = 1 if drug_free==0 & dist_drug<=100

gen dist_drug2=dist_drug
replace dist_drug2=dist_drug+100 if drug_free2==1
replace dist_drug2=dist_drug-100 if drug_free2==0

* Indicator for observations within a n-feet distance of DF boundary
gen donut_in=(drug_free==1 & dist_drug<=100)
gen donut_out=(drug_free==0 & dist_drug<=100)


********************************************************
* Sample restrictions
********************************************************
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
* Table: Results
********************************************************
estimates clear
set more off
foreach var in drug_AM {
	* Expanding definition of Drug-free to 100ft out the boudnary
	* Fines interacted with monitoring intensity
	rename drug_free temp_drug_free
	rename drug_free2 drug_free
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col1
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Panel Poisson: Fines interacted with monitoring intensity
	ppmlhdfe `var' drug_free##(med_p high_p) dist_drug [w=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col2
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Dropping observations within band around boundary		
	* Fines interacted with monitoring intensity
	rename drug_free drug_free2
	rename temp_drug_free drug_free
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length] if (donut_out==0), ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col3
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Panel Poisson: Fines interacted with monitoring intensity
	ppmlhdfe `var' drug_free##(med_p high_p) dist_drug [w=block_length] if (donut_out==0), ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col4
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"				
}



********************************************************
* Calculating closest block to boundary
********************************************************
use "$datasets/final_penalties_dataset.dta", clear
sort block_id year
gen id=_n
merge m:1 block_id using "$datasets/blocks_treatment_latlon.dta"
drop _merge
keep id lat lon year drug_free dist_drug


* Files with no drug-free blocks
forv y=2007(1)2017 {
	preserve
	keep if year==`y' & drug_free==0
	keep id lat lon
	rename id id0
	tempfile df0_`y'
	save "`df0_`y''"
	restore
	
	* Files with nearest no drug-free block to drug-free block
	preserve
	keep if year==`y' & drug_free==1 & dist_drug<=100 //DF blocks within 100ft of boundary
	keep id lat lon
	geonear id lat lon using "`df0_`y''", n(id0 lat lon) ign //Distance to closest nonDF block
	collapse (first) km_to_nid, by(nid)
	rename nid id
	tempfile nn_`y'
	save "`nn_`y''"
	restore
}
	
	
use "$datasets/final_penalties_dataset.dta", clear
sort block_id year
gen id=_n
gen near_DF=0

forv y=2007(1)2017 {
	merge 1:1 id using "`nn_`y''"
	replace near_DF=1 if _merge==3
	drop _merge
}
save "$intermediate/final_penalties_dataset_nearDF.dta", replace



* Regressions using dataset created in previous step
use "$intermediate/final_penalties_dataset_nearDF.dta", clear
* Variables of interest
gen high_p = spp 
gen high_f = drug_free
gen med_p = t_adj 

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

gen drug_free2=drug_free
replace drug_free2=1 if near_DF==1


********************************************************
* Table: Results
********************************************************
foreach var in drug_AM {
	* Expanding definition of Drug-free to blocks nearest the boundary
	* Fines interacted with monitoring intensity
	rename drug_free temp_drug_free
	rename drug_free2 drug_free
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col5
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Panel Poisson: Fines interacted with monitoring intensity
	ppmlhdfe `var' drug_free##(med_p high_p) dist_drug [w=block_length], ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col6
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Dropping observations closest to boundary		
	* Fines interacted with monitoring intensity
	rename drug_free drug_free2
	rename temp_drug_free drug_free
	reghdfe `var' drug_free##(med_p high_p) dist_drug [aw=block_length] if (near_DF==0), ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col7
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"

	* Panel Poisson: Fines interacted with monitoring intensity
	ppmlhdfe `var' drug_free##(med_p high_p) dist_drug [w=block_length] if (near_DF==0), ///
		absorb(block_id year neighborhood#year) ///
		cluster(neighborhood) 

		test 1.drug_free = 1.drug_free#1.med_p
		estadd scalar p1=r(p)	
		test 1.drug_free#1.high_p = 1.drug_free#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		est store col8
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"				
}



estout col1 col2 col3 col4 col5 col6 col7 col8 ///
using "$output/table_other_DF-definitions.tex", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.drug_free 1.med_p 1.high_p 1.drug_free#1.med_p 1.drug_free#1.high_p) ///
varlabels(1.drug_free "Drug-free" 1.med_p "Adj. block" 1.high_p "SPP" ///
1.drug_free#1.med_p "Drug-free $\times$ Adj. block" 1.drug_free#1.high_p "Drug-free $\times$ SPP") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(Mean Obs nblocks N_clust NY PY p2, fmt(3 0 0 0 0 0 3) ///
labels("Mean" "Observations" "Blocks" "Neighborhoods" "Neighborhood $\times$ Year FE" "Police district $\times$ Year FE" ///
"P-value ($\beta_{Drug-free $\times$ Adj}=\beta_{Drug-free $\times$ SPP}$)"))







