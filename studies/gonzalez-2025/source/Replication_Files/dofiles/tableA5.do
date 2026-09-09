*==============================================================================
* Description: This do-file runs the regressions in Table A5
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


* Regression Discontinuity estimates
* Panel A: LLR
* All years
estimates clear
rdrobust drug_AM dist_2 if year<=2010, covs(block_length year) ///
	vce(cluster neighborhood)
	
	est store drug_all
	estadd scalar rd = e(tau_cl)
	estadd scalar h_opt = e(h_l)
	sum drug_AM if drug_free==0 & year<=2010 & dist_drug<=e(h_opt)
	estadd scalar Mean = r(mean) 
	estadd scalar Obs = e(N_h_l) + e(N_h_r)

* By year
forval i=2007(1)2010 {
	rdrobust drug_AM dist_2 if year==`i', covs(block_length) ///
	vce(cluster neighborhood)  

	est store drug_`i'
	estadd scalar rd = e(tau_cl)
	estadd scalar h_opt = e(h_l)
	sum drug_AM if year==`i' & drug_free==0 & dist_drug<=e(h_opt)
	estadd scalar Mean  = r(mean)
	estadd scalar Obs = e(N_h_l) + e(N_h_r)
}

estout drug_* ///
using "$output/crime_penalty_pre_spp.txt", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(h_opt Mean Obs N_clust, labels("Bandwidth" "Mean" "Observations" "Clusters") fmt(%9.3gc))


* Panel B: Polynomial RD
reg drug_AM high_f##c.dist_drug##c.dist_drug block_length year ///
	if year<=2010 & dist_drug<=1000 & no_sc==1, ///
	cluster(neighborhood)

	sum drug_AM if drug_free==0 & year<=2010 & dist_drug<=950
	scalar mean_drug = r(mean)  

	est store drug_all
	estadd scalar Mean  = mean_drug
	estadd scalar Obs = e(N)
	estadd scalar h_opt=950

forval i=2007(1)2010 {
	reg drug_AM high_f##c.dist_drug##c.dist_drug block_length ///
	if year==`i' & dist_drug<=1000 & no_sc==1, ///
	cluster(neighborhood)

	sum drug_AM if drug_free==0 & year==`i' & dist_drug<=950
	scalar mean_drug = r(mean)  

	est store drug_`i'
	estadd scalar Mean  = mean_drug
	estadd scalar Obs = e(N)
	estadd scalar h_opt=950
}

estout drug_* ///
using "$output/crime_penalty_pre_spp_poly.txt", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.high_f) varlabels(1.high_f "Drug-free") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(h_opt Mean Obs N_clust, labels("Bandwidth" "Mean" "Observations" "Clusters") fmt(%9.3gc))



* Panel C: Polynomial RD with Boundary FE
reg drug_AM high_f##c.dist_drug##c.dist_drug block_length year i.fid_drug ///
	if year<=2010 & dist_drug<=1000 & no_sc==1, ///
	cluster(neighborhood)

	sum drug_AM if drug_free==0 & year<=2010 & dist_drug<=950
	scalar mean_drug = r(mean)  

	est store drug_all
	estadd scalar Mean  = mean_drug
	estadd scalar Obs = e(N)
	estadd scalar h_opt=950

forval i=2007(1)2010 {
	reg drug_AM high_f##c.dist_drug##c.dist_drug block_length i.fid_drug ///
	if year==`i' & dist_drug<=1000 & no_sc==1, ///
	cluster(neighborhood)

	sum drug_AM if drug_free==0 & year==`i' & dist_drug<=950
	scalar mean_drug = r(mean)  

	est store drug_`i'
	estadd scalar Mean  = mean_drug
	estadd scalar Obs = e(N)
	estadd scalar h_opt=950
}

estout drug_* ///
using "$output/crime_penalty_pre_spp_poly_fe.txt", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.high_f) varlabels(1.high_f "Drug-free") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(h_opt Mean Obs N_clust, labels("Bandwidth" "Mean" "Observations" "Clusters") fmt(%9.3gc))
