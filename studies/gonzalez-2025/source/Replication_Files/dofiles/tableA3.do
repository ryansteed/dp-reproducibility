*==============================================================================
* Description: This do-file runs the regressions in Table A3
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
drop temp1 temp2 temp3


* Drug-free ever
bys block_id: egen tempmean = mean(drug_free)
drop if tempmean>0 & tempmean<1 //blocks where drug-free status changed
drop tempmean
		
* Panel OLS: Fines interacted with monitoring intensity
reghdfe drug_AM high_f##(med_p high_p) dist_drug [aw=block_length] ///
	if dist_drug<=1000 & no_sc==1, absorb(block_id year neighborhood#year) ///
	cluster(neighborhood) 
		test 1.high_f = 1.high_f#1.med_p
		estadd scalar p1=r(p)	
		test 1.high_f#1.high_p = 1.high_f#1.med_p
		estadd scalar p2=r(p)
		est store col1
		sum drug_AM if e(sample)==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local Bw = 1000

* Panel Poisson: Fines interacted with monitoring intensity		
ppmlhdfe drug_AM high_f##(med_p high_p) dist_drug [w=block_length] ///
	if dist_drug<=1000 & no_sc==1, absorb(block_id year neighborhood#year) ///
	cluster(neighborhood) 
		test 1.high_f = 1.high_f#1.med_p
		estadd scalar p1=r(p)	
		test 1.high_f#1.high_p = 1.high_f#1.med_p
		estadd scalar p2=r(p)
		est store col2
		sum drug_AM if e(sample)==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
		scalar mean_drug = r(mean)  
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local Bw = 1000

	
*===============================================================================
* Different bandwidths
*===============================================================================
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
drop temp1 temp2 temp3

* Different bandwidths
forv i=500(100)800 {
	reghdfe drug_AM high_f##(med_p high_p) dist_drug [aw=block_length] ///
		if dist_drug<=`i' & no_sc==1, absorb(block_id year neighborhood#year) ///
		cluster(neighborhood)
			test 1.high_f = 1.high_f#1.med_p
			estadd scalar p1=r(p)	
			test 1.high_f#1.high_p = 1.high_f#1.med_p
			estadd scalar p2=r(p)
			est store col`i'
			sum drug_AM if e(sample)==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
			scalar mean_drug = r(mean)  
			estadd scalar Mean  = mean_drug
			estadd scalar Obs = e(N)
			estadd scalar Clusters = e(N_clust)
			unique block_id if e(sample)
			estadd scalar nblocks=r(unique)
			estadd local NY "Yes"
			estadd local Bw = `i'
			
		ppmlhdfe drug_AM high_f##(med_p high_p) dist_drug [w=block_length] ///
		if dist_drug<=`i' & no_sc==1, absorb(block_id year neighborhood#year) ///
		cluster(neighborhood)
		test 1.high_f = 1.high_f#1.med_p
		estadd scalar p1=r(p)	
		test 1.high_f#1.high_p = 1.high_f#1.med_p
		estadd scalar p2=r(p)
			est store colp`i'
			sum drug_AM if e(sample)==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
			scalar mean_drug = r(mean)  
			estadd scalar Mean  = mean_drug
			estadd scalar Obs = e(N)
			estadd scalar Clusters = e(N_clust)
			unique block_id if e(sample)
			estadd scalar nblocks=r(unique)
			estadd local NY "Yes"
			estadd local Bw = `i'
}

			
* Export to Latex
estout col1 col2 col800 col700 col600 col500 colp800 colp700 colp600 colp500 ///
using "$output/robustness_bw.tex", style(tex) replace ///
label cells(b(star fmt(2)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.high_f 1.med_p 1.high_p 1.high_f#1.med_p 1.high_f#1.high_p) ///
varlabels(1.high_f "Drug-free" 1.med_p "Adj. block" 1.high_p "SPP" ///
1.high_f#1.med_p "Drug-free $\times$ Adj. block" 1.high_f#1.high_p "Drug-free $\times$ SPP") ///
mlabels(, none) collabels(, none) eqlabels(, none) numbers ///
stats(Mean Obs nblocks N_clust NY Bw p2, fmt(3 0 0 0 0 0 3) ///
labels("Mean" "Observations" "Blocks" "Neighborhoods" "Neighborhood $\times$ Year FE" "Bandwidth (ft)" ///
"P-value ($\beta_{Drug-free $\times$ Adj}=\beta_{Drug-free $\times$ SPP}$)"))



	
	