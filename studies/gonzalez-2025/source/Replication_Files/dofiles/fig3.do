*==============================================================================
* Description: This do-file creates subfigures in Figure 3
* Data: 2/7/2025
*===============================================================================

* Dataset
use "$datasets/final_penalties_dataset.dta", clear


* Estimation sample (2007-2017)
gen non_adj=1-t_adj
replace non_adj=0 if spp==1

* Interactions
gen spp_df = (spp==1 & drug_free==1)
gen spp_nodf = (spp==1 & drug_free==0)
gen adj_df = (t_adj==1 & drug_free==1)
gen adj_nodf = (t_adj==1 & drug_free==0)
gen non_adj_df = (non_adj==1 & drug_free==1)
gen non_adj_nodf = (non_adj==1 & drug_free==0)
gen n=1


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

gcollapse (sum) spp t_adj drug_free spp_df spp_nodf adj_df adj_nodf non_adj_df non_adj_nodf n, by(year)
foreach var in spp t_adj {
	gen s_`var' = `var'/drug_free
}
gen s_other = (drug_free-spp-t_adj)/drug_free
gen s_spp_df = spp_df/spp
gen s_adj_df = adj_df/t_adj



gr tw (connected spp year) (connected t_adj year) ///
	(connected drug_free year, yaxis(2)), ///
	ylabel(15000(500)18000, nogrid axis(2)) ylabel(, nogrid axis(1)) ///
	xlabel(2007(1)2017, nogrid) scheme(plotplainblind) ///
	legend(cols(1) pos(11) ring(0) label(1 "SPP blocks") ///
	label(2 "Adjacent blocks") label(3 "Drug-free blocks")) xtitle("Year") ///
	ytitle("Number of SPP and Adjacent blocks", axis(1)) ///
	ytitle("Number of Drug-free blocks", axis(2))
	gr export "$output/spp_adj_df_blocks_restricted.eps", replace
	
gr tw (connected spp_df year) (connected spp_nodf year) ///
	(connected adj_df year) (connected adj_nodf year), ///
	ylabel(, nogrid) ///
	xlabel(2007(1)2017, nogrid) scheme(plotplainblind) ///
	legend(cols(1) pos(11) ring(0) label(1 "SPP-DF blocks") ///
	label(2 "SPP-No DF blocks") label(3 "Adj-DF blocks") ///
	label(4 "Adj-No DF blocks")) xtitle("Year") ///
	ytitle("Number of blocks") 
	gr export "$output/spp_by_df_blocks_restricted.eps", replace

gr tw (connected s_spp year) (connected s_t_adj year), ///
	ylabel(, nogrid) ///
	xlabel(2007(1)2017, nogrid) scheme(plotplainblind) ///
	legend(cols(1) pos(9) ring(0) label(1 "SPP") ///
	label(2 "Adj") label(3 "Beyond")) xtitle("Year") ///
	ytitle("Share of SPP and Adjacent blocks within DF zones") 
	gr export "$output/within_DF_blocks_restricted.eps", replace
	
gr tw (connected s_spp_df year) (connected s_adj_df year), ///
	ylabel(0.5(0.1)0.8, nogrid) ///
	xlabel(2007(1)2017, nogrid) scheme(plotplainblind) ///
	legend(cols(1) pos(11) ring(0) label(1 "SPP") ///
	label(2 "Adj") label(3 "Beyond")) xtitle("Year") ///
	ytitle("Share of Drug-Free blocks within SPP/Adj blocks") 
	gr export "$output/within_SPP_blocks_restricted.eps", replace
