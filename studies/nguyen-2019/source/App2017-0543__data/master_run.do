/*******************************
master_run.do

Master do-file for replicating the results from "Are Credit Markets Still Local?
Evidence from Bank Branch Closings"
********************************/

** Install necessary packages
*** EDIT by Donna
ssc install outreg2, replace
ssc install regsave,replace
ssc install reghdfe,replace
ssc install eclplot, replace
ssc install ivreg2, replace
ssc install ranktest, replace
***


** Summary statistics: Tables 1-5
* do summary_stats.do


** Main results: Figures 2-5, Tables 6-7
do main_results.do


** Extensions: Figure 6, Tables 8-9
* do extensions.do


** Spillovers: Figure 7
* do spillovers.do

