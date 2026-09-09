*==============================================================================
* Description: This do-file runs the regressions in Table A4
* Data: 2/7/2025
*===============================================================================

* Dataset
use "$datasets/final_penalties_dataset.dta", clear

* Merge with lat/lon data
merge m:1 block_id using "$datasets/blocks_treatment_latlon.dta" //This dataset has decimal degrees lat/lon
drop _merge


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
* Table 1: Main results
********************************************************
drop temp_year
gen temp=1 //use variable to get name right when exporting to table


gen df_m = drug_free*med_p
gen df_spp = drug_free*high_p


timer clear
timer on 1

* Column 1

reghdfe drug_AM drug_free med_p high_p df_m df_spp dist_drug [aw=block_length], absorb(block_id year) cluster(neighborhood)
		est store none
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local cutoff "."
		estadd local NY "No"
		estadd local PY "No"

* Column 2
	acreg drug_AM drug_free med_p high_p df_m df_spp dist_drug [pw=block_length], id(block_id) time(year) latitude(lat) longitude(lon) distcutoff(1) pfe1(block_id) pfe2(year) spatial
		est store conley_1km
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local cutoff "1"
		estadd local NY "No"
		estadd local PY "No"
		
* Column 3
	acreg drug_AM drug_free med_p high_p df_m df_spp dist_drug [pw=block_length], id(block_id) time(year) latitude(lat) longitude(lon) distcutoff(3) pfe1(block_id) pfe2(year) spatial
		est store conley_3km
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local cutoff "3"	
		estadd local NY "No"
		estadd local PY "No"
		
* Column 4
	acreg drug_AM drug_free med_p high_p df_m df_spp dist_drug [pw=block_length], id(block_id) time(year) latitude(lat) longitude(lon) distcutoff(5) pfe1(block_id) pfe2(year) spatial	
		est store conley_5km
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local cutoff "5"
		estadd local NY "No"
		estadd local PY "No"
	
timer off 1
timer list

estout none conley_1km conley_3km conley_5km ///
using "$output/table1_conley.tex", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(drug_free med_p high_p df_m df_spp) ///
varlabels(drug_free "Drug-free" med_p "Adj. block" high_p "SPP" ///
df_m "Drug-free $\times$ Adj. block" df_spp "Drug-free $\times$ SPP") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(Obs nblocks N_clust NY PY cutoff, fmt(0 0 0 0 0 0) ///
labels("Observations" "Blocks" "Neighborhoods" "Neighborhood $\times$ Year FE" "Police district $\times$ Year FE" "Distance cutoff"))
		
		
		
		
		


	
	
	
	
	
	
		
		