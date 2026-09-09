*==============================================================================
* Description: This do-file runs the regressions in Table A1
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
drop if temp1==1 //0 singletons
bys neighborhood year: egen temp2=count(block_id)
drop if temp2==1 //8 singletons in neighborhoodXyear
bys police_district year: egen temp3=count(block_id)
drop if temp3==1 //no singletons in police districtXyear
drop temp1 temp2 temp3


* Spillover estimates
foreach var in drug_AM violent_AM property_AM {
	reghdfe `var' spp t_adj [aw=block_length] if dist_drug<=1000 & no_sc==1, ///
       absorb(year block_id neighborhood#year) cluster(neighborhood)
	test spp=t_adj
	estadd scalar p1=r(p)
	est store `var'
	estadd scalar Obs = e(N)
	estadd scalar Clusters = e(N_clust)
	estadd local NY "Yes"
	sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF, SPP, and Adjacent blocks before getting SPP
	scalar mean_drug = r(mean)  
	estadd scalar Mean  = mean_drug
	
	
	reghdfe `var' spp t_adj t_qtr t_half [aw=block_length] if dist_drug<=1000 & no_sc==1, ///
       absorb(year block_id neighborhood#year) cluster(neighborhood)
	test spp=t_adj
	estadd scalar p1=r(p)
	test t_adj=t_qtr
	estadd scalar p2=r(p)
	test t_adj=t_half
	estadd scalar p3=r(p)
	est store all_`var'
	estadd scalar Obs = e(N)
	estadd scalar Clusters = e(N_clust)
	estadd local NY "Yes"
	sum `var' if e(sample) & drug_free==0 & (adj==1 & spp==0) //mean for nonDF, SPP, and Adjacent blocks before getting SPP
	scalar mean_drug = r(mean)  
	estadd scalar Mean  = mean_drug
}


	
estout drug_AM all_drug_AM violent_AM all_violent_AM property_AM all_property_AM ///
using "$output/crime_spatial_spillover.tex", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(spp t_adj t_qtr t_half) ///
varlabels(spp "SPP" t_adj "Adjacent" t_qtr "Qtr mile" t_half "Half mile") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(p1 p2 p3 Mean N N_clust,  fmt(3 3 3 3 0 0) ///
labels("P-value ($\beta_{SPP}=\beta_{Adj}$)" ///
"P-value ($\beta_{Adj}=\beta_{Qtr}$)" ///
"P-value ($\beta_{Adj}=\beta_{Half}$)" "Mean" "Observations" "Clusters"))





