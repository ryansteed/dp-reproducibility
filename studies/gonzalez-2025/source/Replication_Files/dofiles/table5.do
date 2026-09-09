*==============================================================================
* Description: This do-file runs the regressions in Table 5
* Data: 2/7/2025
*===============================================================================
	

* Dataset
use "$datasets/final_penalties_dataset_2018-2019.dta", clear

* Variables of interest
gen high_p = spp 
gen high_f = drug_free
gen med_p = t_adj 

gen dist_2 = dist_drug
replace dist_2 = -dist_drug if drug_free==0

* Omit crimes within 100ft of schools
gen no_sc = .
replace no_sc=1 if dist_2<=900 & year2==2017
replace no_sc=1 if dist_2<=400 & year2>2017

* Take drug crimes out of non-index crimes
gen nonindex_no_drugs_AM = nonindex_AM - drug_AM

* Estimation sample (observations within 1000ft of DF zone but beyond school grounds)
keep if dist_drug<=1000 & no_sc==1

* Singletons
bys block_id: egen temp1=count(block_id)
drop if temp1==1 //0 singletons
bys neighborhood ym: egen temp2=count(block_id)
drop if temp2==1 //8 singletons in neighborhoodXyear
bys police_district ym: egen temp3=count(block_id)
drop if temp3==1 //no singletons in police districtXyear
drop temp1 temp2 temp3



********************************************************
* Main results AND FALSIFICATION TESTS
********************************************************
g temp = 1

foreach var in drug_AM	{
	* Only fines
	reghdfe `var' drug_free##temp dist_drug [aw=block_length], ///
		absorb(block_id ym neighborhood#ym) ///
		cluster(neighborhood) 
		gen sample=e(sample)
		
		sum `var' if sample==1 & drug_free==0 & (adj==1 & spp==0) //mean for nonDF blocks before getting SPP
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
		absorb(block_id ym neighborhood#ym) ///
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
		absorb(block_id ym police_district#ym) ///
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


* Reclassify blocks
keep if df_17_1000 == 1 //keep only blocks that are drug-free in first half of 2017 SY
gen nondf17 = (df_17==0 & df_17_1000==1) //You were DF but lost status
gen nondf18 = (df_18==0 & df_17_1000==1) //You were DF but lost status
gen nondf19 = (df_19==0 & df_17_1000==1) //You were DF but lost status
//drop blocks in subsequent years that changed df status for reasons other than law change (i.e., )
drop if nondf18 == 1 & nondf17==0 
drop if nondf19 == 1 & nondf17==0
drop if nondf18 == 0 & nondf17==1
drop if nondf19 == 0 & nondf17==1
gen nondf=.
replace nondf = 1-df_17_1000 if year2==2017 //SY 17-18 first half
replace nondf = nondf17 if year==2018 & year2==2018 //SY 17-18 second half
replace nondf = nondf18 if year==2019 //SY 18-19
replace nondf = nondf19 if year==2020 //SY 19-20


* Regressions
foreach var in drug_AM	{
reghdfe `var' nondf##(med_p high_p) dist_drug [aw=block_length], absorb(block_id ym neighborhood#ym) cluster(neighborhood)
		test 1.nondf = 1.nondf#1.med_p
		estadd scalar p1=r(p)	
		test 1.nondf#1.high_p = 1.nondf#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample)==1 & nondf==1 & (adj==1 & spp==0) & year<=2018 //mean for switching blocks before switch and getting SPP
		scalar mean_drug = r(mean)  
		est store main_`var'_nondf
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd scalar nblocks=r(unique)
		estadd local NY "Yes"
		estadd local PY "No"
		
reghdfe `var' nondf##(med_p high_p) dist_drug [aw=block_length], absorb(block_id ym police_district#ym) cluster(neighborhood)
		test 1.nondf = 1.nondf#1.med_p
		estadd scalar p1=r(p)	
		test 1.nondf#1.high_p = 1.nondf#1.med_p
		estadd scalar p2=r(p)
		sum `var' if e(sample)==1 & nondf==1 & (adj==1 & spp==0) & year<=2018 //mean for switching blocks before switch and getting SPP
		scalar mean_drug = r(mean)  
		est store trend_`var'_nondf
		estadd scalar Mean  = mean_drug
		estadd scalar Obs = e(N)
		estadd scalar Clusters = e(N_clust)
		unique block_id if e(sample)
		estadd local nblocks=r(unique)
		estadd local NY "No"
		estadd local PY "Yes"
}



estout sim_drug_AM main_drug_AM trend_drug_AM main_drug_AM_nondf trend_drug_AM_nondf using "$output/table_natl_experiment.tex", style(tex) replace ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)  ///
keep(1.drug_free 1.med_p 1.high_p 1.drug_free#1.med_p 1.drug_free#1.high_p 1.nondf 1.nondf#1.med_p 1.nondf#1.high_p) ///
varlabels(1.drug_free "Drug-free" 1.med_p "Adj. block" 1.high_p "SPP" ///
1.drug_free#1.med_p "Drug-free $\times$ Adj. block" 1.drug_free#1.high_p "Drug-free $\times$ SPP" 1.nondf "(500-1,000)" 1.nondf#1.med_p "(500-1,000) $\times$ Adj. block" 1.nondf#1.high_p "(500-1,000) $\times$ SPP") ///
mlabels(, depvars) collabels(, none) eqlabels(, none) ///
stats(Mean Obs nblocks N_clust NY PY  p2, fmt(3 0 0 0 0 0 3) ///
labels("Mean" "Observations" "Blocks" "Neighborhoods" "Neighborhood $\times$ Year FE" "Police district $\times$ Year FE" ///
"P-value ($\beta_{Drug-free $\times$ Adj}=\beta_{Drug-free $\times$ SPP}$)"))

	
	
	
	


