*==============================================================================
* Description: This do-file creates subfigures in Figure A5
* Data: 2/7/2025
*===============================================================================
	
clear

* Dataset
use "$datasets/final_penalties_dataset.dta", clear


* Variables of interest
gen high_p = spp 
gen high_f = drug_free
gen med_p = t_adj 

gen dist_2 = dist_drug
replace dist_2 = -dist_drug if drug_free==0
gen no_sc = (dist_2<=900)

* Take drug crimes out of non-index crimes
gen nonindex_no_drugs_AM = nonindex_AM - drug_AM


* Margins
gen monit = .
replace monit=0 if high_p==1
replace monit=1 if med_p==1
replace monit=2 if monit==.
label values monit monit
label define monit 0 "Safe Passage" 1 "Adjacent" 2 "Non-monitored"


    qui:areg drug_AM drug_free##monit dist_drug i.year [w=block_length] ///
        if dist_drug<=1000 & no_sc==1, absorb(block_id) ///
        cluster(neighborhood)  
        margins, dydx(drug_free) at(monit=(0(1)2)) saving($intermediate/file_main, replace)

    qui:areg drug_PM drug_free##monit dist_drug i.year [w=block_length] ///
        if dist_drug<=1000 & no_sc==1, absorb(block_id) ///
        cluster(neighborhood)  
        margins, dydx(drug_free) at(monit=(0(1)2)) saving($intermediate/file_PM, replace)

    qui:areg drug_wknd drug_free##monit dist_drug i.year [w=block_length] ///
        if dist_drug<=1000 & no_sc==1, absorb(block_id) ///
        cluster(neighborhood)  
        margins, dydx(drug_free) at(monit=(0(1)2)) saving($intermediate/file_wknds, replace)

    qui:areg violent_AM drug_free##monit dist_drug i.year [w=block_length] ///
        if dist_drug<=1000 & no_sc==1, absorb(block_id) ///
        cluster(neighborhood)  
        margins, dydx(drug_free) at(monit=(0(1)2)) saving($intermediate/file_violent, replace)
    
    qui:areg property_AM drug_free##monit dist_drug i.year [w=block_length] ///
        if dist_drug<=1000 & no_sc==1, absorb(block_id) ///
        cluster(neighborhood)  
        margins, dydx(drug_free) at(monit=(0(1)2)) saving($intermediate/file_property, replace)
    


*** Graphs ****
use $intermediate/file_main, clear

* Main specification
gr tw (rcap _ci_lb _ci_ub _at2, lcolor(gs8)) ///
      (connected _margin _at2, ///
      lcolor(gs10) lpattern(dash) ///
      mcolor(gs3) msize(large) msymbol(square)), ///
      legend(off) xlabel(0(1)2.2, labsize(large) valuelabel nogrid) xtitle("") ///
      ytitle("Marginal Effect of Penalties", size(large)) ///
      ylabel(-.3(0.1)0.15,nogrid) yline(0, lpattern(solid)) ///
      scheme(plotplainblind)
      gr export "$output/margins_main1.eps", replace

* Falsification (other times)
foreach f in PM wknds {
    use $intermediate/file_`f', clear
    gr tw (rcap _ci_lb _ci_ub _at2, lcolor(gs8)) ///
      (connected _margin _at2, ///
      lcolor(gs10) lpattern(dash) ///
      mcolor(gs3) msize(large) msymbol(square)), ///
      legend(off) xlabel(0(1)2.2, labsize(large) valuelabel nogrid) xtitle("") ///
      ytitle("Marginal Effect of Penalties", size(large)) ///
      ylabel(-.3(0.1)0.15,nogrid) yline(0, lpattern(solid)) ///
      scheme(plotplainblind)
      gr export "$output/margins_`f'.eps", replace
}

* Falsification (other crime outcomes)
foreach f in violent property {
    use $intermediate/file_`f', clear
    gr tw (rcap _ci_lb _ci_ub _at2, lcolor(gs8)) ///
      (connected _margin _at2, ///
      lcolor(gs10) lpattern(dash) ///
      mcolor(gs3) msize(large) msymbol(square)), ///
      legend(off) xlabel(0(1)2.2, labsize(large) valuelabel nogrid) xtitle("") ///
      ytitle("Marginal Effect of Penalties", size(large)) ///
      ylabel(-.3(.1).15,nogrid) yline(0, lpattern(solid)) ///
      scheme(plotplainblind)
      gr export "$output/margins_`f'.eps", replace
}


