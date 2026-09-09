*==============================================================================
* Description: This do-file creates subfigures in Figure 4
* Data: 2/7/2025
*===============================================================================


*===============================================================================
* Figure 4a and 4b
*===============================================================================

use "$datasets/final_penalties_dataset.dta", clear

* Sample restrictions used in main results
drop if drug_free==1 & dist_drug>900 //blocks very close to schools
keep if dist_drug<=1000 //blocks within 1000ft of drug boundary


* Ever SPP
bys block_id: egen tempsd = sd(spp)
gen spp_all = (tempsd>0 & tempsd<.)
drop tempsd

* Ever Adjacent/nonSPP
replace adj=0 if spp_all==1

* Beyond adj
gen non_adj=(adj==0)
replace non_adj=0 if spp_all==1

* Drug-free ever
bys block_id: egen tempmean = mean(drug_free)
gen df_always=(tempmean==1)
gen df_temp=(tempmean>0 & tempmean<1)
drop tempmean

* No drug-free block
gen non_drug_free = 1- drug_free
replace non_drug_free=0 if df_temp==1 //make sure these are blocks that have never been DF

tempfile temp
save `temp'
	
	
foreach X in spp_all adj non_adj drug_free non_drug_free { 
	use `temp', clear
	keep if `X'==1
	gcollapse (mean) drug_AM [aw=block_length], by(year)
	gen sample="`X'"
	tempfile mean_`X'
	save `mean_`X''
}

use `mean_spp_all'
append using `mean_adj'
append using `mean_non_adj'
append using `mean_drug_free'
append using `mean_non_drug_free'


* Graph
foreach var in drug_AM {
	gr tw (connected `var' year if sample=="spp_all") ///
	  (connected `var' year if sample=="adj") ///
	  (connected `var' year if sample=="non_adj"), ///
	  xlabel(2007(2)2017, nogrid) legend(cols(1) pos(8) ring(0) label(1 "SPP") ///
	  label(2 "Adjacent") label(3 "Other")) xtitle("Year") ///
	  xline(2010) ylabel(0(0.25)1.25, nogrid) ///
	  ytitle("Average drug crimes per block") scheme(plotplainblind)
	  gr export "$output/trends_spp_adj.eps", replace
}


foreach var in drug_AM {
	gr tw (connected `var' year if sample=="drug_free") ///
	  (connected `var' year if sample=="non_drug_free"), ///
	  xlabel(2007(2)2017, nogrid) legend(cols(1) pos(8) ring(0) label(1 "Drug-free") ///
	  label(2 "No Drug-free")) xtitle("Year") ///
	  xline(2010) ylabel(, nogrid) ///
	  ytitle("Average drug crimes per block") scheme(plotplainblind)
	  gr export "$output/trends_df.eps", replace
}






*===============================================================================
* Figure 4c and 4d
*===============================================================================
* Dataset
use "$datasets/final_penalties_dataset.dta", clear

* Outcome variables
label var drug_AM "Drug crimes"

* Sample restrictions used in main results
drop if drug_free==1 & dist_drug>900 //blocks very close to schools
keep if dist_drug<=1000 //blocks within 1000ft of drug boundary


* Create variable for year of SPP
gen spp_year=.
forval i=10(1)16 {
	replace spp_year=2000+`i'+1 if sp`i'==1 & spp_year==.
} 


bys block_id: egen tempsd = sd(spp)
gen spp_all = (tempsd>0 & tempsd<.)
drop tempsd
gen adj_nonspp=adj
replace adj_nonspp=0 if spp_all==1
* Beyond adj
gen non_adj=1-adj_nonspp


*********************************************	
* SPP/Adj Analysis by year	
*********************************************
* All years
	gen years_since=.
	replace years_since = year - (spp_year)
	
	* Year by year analysis
	* Pre-intervention (can be up to 10 years (2007-2017))
	forval val=1(1)10 { 
		gen pre_`val'=(years_since==-`val')
	}
	* Post-intervention (can be up to 6 years (2017-2011))
	forval val=0(1)6 {
		gen post_`val'=(years_since==`val')
	}	

	replace pre_6 = 1 if pre_7==1|pre_8==1|pre_9==1|pre_10==1

	estimates clear
		reghdfe drug_AM pre_6 pre_5 pre_4 pre_3 pre_2 post_0-post_6 [aw=block_length] ///
		if adj==1, absorb(year block_id) ///
		cluster(neighborhood) 
			eststo col1 
			estadd scalar Obs = e(N)
			estadd scalar Clusters = e(N_clust)
			test pre_6=pre_5=pre_4=pre_3=pre_2=0
			estadd scalar F_pval = r(p)
			local F_pval_spp_adj : display %3.2f = r(p)


		reghdfe drug_AM pre_6 pre_5 pre_4 pre_3 pre_2 post_0-post_6 [aw=block_length] ///
		if non_adj==1, absorb(year block_id) ///
		cluster(neighborhood) 
			eststo col2 
			estadd scalar Obs = e(N)
			estadd scalar Clusters = e(N_clust)
			test pre_6=pre_5=pre_4=pre_3=pre_2=0
			estadd scalar F_pval = r(p)
			local F_pval_spp_rest : display %3.2f = r(p)

		
		
*********************************************	
* Drug Free Analysis by year	
*********************************************
* All years
	replace years_since = year - 2011
	
	* Year by year analysis
	* Pre-intervention (can be up to 4 years (2007-2011))
	forval val=1(1)4 { 
		replace pre_`val'=drug_free*(years_since==-`val')
	}
	* Post-intervention (can be up to 6 years (2017-2011))
	forval val=0(1)6 {
		replace post_`val'=drug_free*(years_since==`val')
	}	

		reghdfe drug_AM pre_4 pre_3 pre_2 pre_1 post_0-post_6 [aw=block_length], ///
		absorb(year block_id) ///
		cluster(neighborhood) 
			eststo col3 
			estadd scalar Obs = e(N)
			estadd scalar Clusters = e(N_clust)
			test pre_4=pre_3=pre_2=0
			estadd scalar F_pval = r(p)
			local F_pval_df : display %3.2f = r(p)
				
*=======================================================================
* Graph 
*=======================================================================
estout col1 col2 col3 ///
using "$intermediate/drug_spp_df_by_year.txt", style(tab) replace ///
label cells((b ci_l ci_u))  ///
keep(/*pre_10 pre_9 pre_8 pre_7*/ pre_6 pre_5 pre_4 pre_3 pre_2 post_0 post_1 post_2 post_3 post_4 post_5 post_6) ///
varlabels(/*pre_10 "$ SPP_{-10}$" pre_9 "$ SPP_{-9}$" pre_8 "$ SPP_{-8}$" pre_7 "$ SPP_{-7}$"*/ ///
	pre_6 "-6" pre_5 "-5" pre_4 "-4" pre_3 "-3" pre_2 "-2" post_0 "0" post_1 "1" post_2 "2" ///
	post_3 "3" post_4 "4" post_5 "5" post_6 "6") ///
	collabels(, none) 

import delimited "$intermediate/drug_spp_df_by_year.txt", clear

rename v1 year
insobs 1, before(1)
replace year=-1 if year==.
foreach var of varlist col* v* {
	replace `var'=0 if `var'==.
}
sort year
foreach var of varlist col3 v9 v10 {
	replace `var'=. if `var'==0 & year!=-1
}

forval i=3(3)9 {
	rename v`i' ll_`i'
	local j=`i'+1
	rename v`j' ul_`i'
}

rename col1 spp_adj
rename ll_3 ll_spp_adj
rename ul_3 ul_spp_adj
rename col2 spp_rest
rename ll_6 ll_spp_rest
rename ul_6 ul_spp_rest
rename col3 df
rename ll_9 ll_df
rename ul_9 ul_df
label var spp_adj "SPP vs Adj (p-val=`F_pval_spp_adj')"
label var spp_rest "SPP vs Others (p-val=`F_pval_spp_rest')"
label var df "Drug-free vs Not drug-free (p-val=`F_pval_df')"


* Figure 4c: Graph of spp
	gr tw (line spp_adj year, lcolor(gs5) lpattern(dash)) ///
		  (rarea ll_spp_adj ul_spp_adj year, lwidth(none) color(%30)) ///
		  (scatter spp_adj year, msymbol(circle) msize(medium)) ///
		  (line spp_rest year, lcolor(gs5) lpattern(dash)) ///
		  (rarea ll_spp_rest ul_spp_rest year, lwidth(none) color(%30)) ///
		  (scatter spp_rest year, msymbol(circle) msize(medium)), ///
		   yline(0) xline(-1) ylabel(, nogrid) xlabel(-6(2)6, nogrid) xtitle("Years since SPP") ///
		   legend(cols(1) pos(8) ring(0) order(3 6)) ytitle("") scheme(plotplainblind)	
		   gr export "$output/by_year_spp.pdf", replace

* Figure 4d: Graph of Drug-Free	   
foreach var in df {
	gr tw (line `var' year, lcolor(gs5) lpattern(dash)) ///
		  (rarea ll_`var' ul_`var' year, color(%30) lwidth(none)) ///
		  (scatter `var' year, msize(medium) msymbol(circle)), ///
		   yline(0) xline(-1) ylabel(, nogrid) xlabel(-6(2)6, nogrid) xtitle("Years since SPP") ///
		   legend(cols(1) pos(8) ring(0) order(3)) ytitle("") scheme(plotplainblind)	
		   gr export "$output/by_year_df.pdf", replace
}



