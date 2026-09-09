clear

cd "."

use "Gridlock-main-data-for-analysis.dta"


**************************************************
* Table 1a: Sum Stats -- Council characteristics *
**************************************************
	gen numother=numeth_5+numeth_4+numeth_6 //Group Middle_Eastern, Indian, and Native American as "other"

	estpost tabstat fract polar totcand numeth_7 numeth_3 numeth_2 numeth_1  numother if a_pg_pc!=., statistics(mean min max sd count) 
	esttab . using "T1 Sum stats", cells("fract polar totcand numeth_7 numeth_3 numeth_2 numeth_1  numother") nonum noobs title("Council characteristics") csv plain replace 

*****************************************************************
* Table 1b and c: City-level demographics and spendign patterns *
*****************************************************************
	gen share_other= share_pop_nh_natam+share_pop_nh_other //pool native american with other group

	*Column 1: All of CA
		estpost tabstat totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc if a_pg_pc!=., statistics(mean sd n)
		esttab . using "T1 Sum stats", cells("totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc  non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc") nonum noobs title("all cities") csv plain append

	*Column 2: Cities with complete councils
		estpost tabstat totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc if a_pg_pc!=. & frac!=., statistics(mean sd n)
		esttab . using "T1 Sum stats", cells("totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc  non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc") nonum noobs title("Completed council cities") csv plain append

	*Column 3: RD sample
		estpost tabstat totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc if inmainsample==1, statistics(mean sd)
		esttab . using "T1 Sum stats", cells("totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc  non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc") nonum noobs title("Completed council cities") csv plain append

	*Column 4: cities with incomplete elections
		estpost tabstat totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc if hasanincompleteelection==1, statistics(mean sd)
		esttab . using "T1 Sum stats", cells("totpop share_pop_nh_white share_pop_h share_pop_nh_asian share_pop_nh_black share_other cityfract citypolar a_pg_pc  non_pg_pc GENREV_TAXES_pc GENREV_INT_GOV_STATE_pc") nonum noobs title("Completed council cities") csv plain append


*********************************************************************************************
* Figure 1: Distribution of per-capita expenditures and year-to-year change in expenditures *
*********************************************************************************************
	sort ENTITY_ID datayear
	gen pg_change = a_pg_pc-a_pg_pc[_n-1] if ENTITY_ID==ENTITY_ID[_n-1] & datayear==datayear[_n-1] + 1

	kdensity a_pg_pc   if inmainsample==1, title("Spending") xtitle("Per-capita public good spending") name(pg_1, replace)
	kdensity pg_change if inmainsample==1, title("Year-to-year change in spending") xtitle("Per-capita public good spending") name(pg_2, replace)

	graph combine pg_1 pg_2,  xsize(10) ysize(6)
		graph export "F1 Spending distribution RD sample.pdf", replace

/*** Figure that is referenced in text: Full Sample distribution truncated at 99th percentile
kdensity a_pg_pc if a_pg_pc<6000, title("Spending") xtitle("Per-capita public good spending (full sample)") name(full_pg_1, replace)
kdensity pg_change if a_pg_pc<6000, title("Year-to-year change in spending") xtitle("Per-capita public good spending (full sample)") name(full_pg_2, replace)
*/

**********************************
* Regression sample restrictions *
**********************************

	*Restrict to cities that expereince an election between a modal and non-modal candidate
		gen relevantelectionyear=datayear if election_occurs==1 & modalVnonmodal==1  	 //mVnm=1 for all years after (and including) an election between a modal and non-modal candidate
		bysort ENTITY_ID: egen float earliest_relevantelection=min(relevantelectionyear) //Identify first year where there is an mVnm election
		keep if earliest_relevantelection!=.  											 //Drop cities that NEVER experience a relevant election.


	*Some cities have more than one mVnm election. Need to truncate those panels.
		gen rel_mVnm=modalVnonmodal if election_occurs==1 & relevantelectionyear==datayear & relevantelectionyear!=. //Indicator identifying years with mVnm elections
		
		sort ENTITY_ID datayear
		bysort ENTITY_ID: gen float rel_order_mVnm=sum(rel_mVnm) 
		keep if rel_order_mVnm<=1									//drop all observations coincinding (and following) the second mVnm election


******************************************
* Generate variables needed for analysis *
******************************************

	*Generate winner and loser vote shares
		gen winner_share=ceda_votes/ceda_totvotes
		gen loser_share=countervotes/ceda_totvotes
		gen margin=winner_share-loser_share

	*Assign margin from relevant mVnm election to all years in panel
		gen relevant_margin=margin if relevantelectionyear==datayear
		sort ENTITY_ID datayear
		by ENTITY_ID: egen float Margin=max(relevant_margin)


	*Generate treatment indicator
		gen DD_nonmodal_wins=nonmodal_wins  									//nonmodal_wins =1 if the winner is a non-modal candidate.
		replace DD_nonmodal_wins=0 if DD_nonmodal_wins==1 & modalVnonmodal==0	//Only want to treat indicator to turn on if non-modal candidate wins a mVnm election
		replace DD_nonmodal_wins=0 if datayear==2006							//2006 is the base year, so no one is treated. Set all obs equal to zero. 

		sort ENTITY_ID datayear
		replace DD_nonmodal_wins=1 if DD_nonmodal_wins[_n-1]==1 & ENTITY_ID==ENTITY_ID[_n-1] //Once treatment occurs, carry that forward.
		replace DD_nonmodal_wins=0  if rel_order_mVnm<1 & modalVnonmodal!=. //Make sure all pre-relevant election observations are zero.


	*Construct council identifiers since that is where we cluster
		sort ENTITY_ID datayear
		by ENTITY_ID: replace raceid=raceid[_n-1] if raceid==.
		egen float raceid4 = group(raceid ENTITY_ID), missing




***********************************************************************
* Table 2a: Impact of a non-modal win on the diveristy of the council *
***********************************************************************
	eststo T2a_1: areg fract DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)
	eststo T2a_2: areg polar DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)
	esttab T2a_* using "T2 RD validity", keep(1.DD_nonmodal_wins) stats(N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv replace

	
**************************************************************************	
* Table 2b: Are other characteristics balanced when the election occurs? *
**************************************************************************

	gen DemShare= Democratic/ TotalRegistered	//Share of registered voters registered as Democrat
	gen RegShare=TotalReg/totpop				//Share of population that are registered voters
	gen comp=-abs(0.5-DemShare)					//Besley political competition measure
	
	*Need to identify average PG spending before mVnm election
		sort ENTITY_ID datayear
		gen  _tempprevote_pgpc=a_pg_pc if rel_order_mVnm==0 & rel_order_mVnm[_n+1]==1 & ENTITY_ID==ENTITY_ID[_n+1]
		bysort ENTITY_ID: egen float prevote_pg_pc=mean(_tempprevote_pgpc)
	
	*Need to identify diversity of the rest of the council
		gen roc_fract=1
			foreach x in white black asian hisp ind mena natam {
			replace roc_fract=roc_fract-roc_`x'_prop^2
			}

	*Grab means and standard deviations for table
		estpost tabstat cityfract citypolar MGdis theil DemShare RegShare comp prevote_pg_pc roc_fract female   if rel_order_mVnm==1 & election_occurs==1 & Margin<.071, statistics(mean sd)
		esttab . using "T2 RD validity", cells("cityfract citypolar MGdis theil DemShare RegShare comp prevote_pg_pc roc_fract female") csv append
	
	*Balance test
		foreach x in cityfract citypolar MGdis theil DemShare RegShare comp prevote_pg_pc roc_fract female prevote_pg_pc roc_fract female {
			eststo T2b_`x': reg `x' i.DD_nonmodal_wins##c.Margin if rel_order_mVnm==1 & election_occurs==1 & Margin<.071
		}
		esttab T2b_* using "T2 RD validity", keep(1.DD_nonmodal_wins) stats(N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv append


**********************************************
* Figure 2 is produced in a separate do file *
**********************************************

****************************
* Figure 3: Binned-RD plot *
****************************
	
	gen nm_margin=Margin if DD_nonmodal_wins==1		//Will want to have a non-modal margin of victory for RD graphs
	replace nm_margin=-Margin if DD_nonmodal_wins==0	//Non-modal margin of victory should be negative if non-modal lost.


	*Level panels 
	rdplot ln_a_pg nm_margin 	  	  if rel_order_mVnm==1 , p(1) upperend(0.071) lowerend(-0.071) graph_options(title("Ln public goods exp.") legend(off) xtitle("Non-modal win margin") name(PG, replace))
	rdplot ln_non_pg_pc nm_margin 	  if rel_order_mVnm==1 , p(1) upperend(0.071) lowerend(-0.071) graph_options(title("Ln non-public goods exp.") legend(off) xtitle("Non-modal win margin")  name(nonPG, replace) )

	*Percent change panels

	*First generate changes
	bysort ENTITY_ID rel_order_mVnm: egen float mean_ln_pg=mean(ln_a_pg_pc) 								  //Generate pre and post PG averages
	by ENTITY_ID: gen change_ln_pg=mean_ln_pg-mean_ln_pg[_n-1] if rel_order_mVnm==1 & rel_order_mVnm[_n-1]==0 //take the difference

	bysort ENTITY_ID rel_order_mVnm: egen float mean_ln_non_pg=mean(ln_non_pg_pc)										  //Generate pre and post non-PG averages
	by ENTITY_ID: gen change_ln_non_pg=mean_ln_non_pg-mean_ln_non_pg[_n-1] if rel_order_mVnm==1 & rel_order_mVnm[_n-1]==0 //take the difference

	*** EDIT by Donna
	*rdplot change_ln_pg nm_margin 	  if rel_order_mVnm==1 , p(1) upperend(0.071) lowerend(-0.071) graph_options(title("Percent change in p.g. exp.") legend(off) xtitle("Non-modal win margin")  name(PG_change, replace) )
	*rdplot change_ln_non_pg nm_margin if rel_order_mVnm==1 , p(1) upperend(0.071) lowerend(-0.071) graph_options(title("Percent change in non-p.g. exp.") legend(off) xtitle("Non-modal win margin")  name(nonPG_change, replace) )

	*graph combine PG PG_change nonPG  nonPG_change
	*graph export "F3 Main.pdf", replace

*** EDITED by Donna
eststo clear
*************************
* Table 3: Main results *
*************************
	*Cols 1-3: PG spending
	eststo m1: rdrobust ln_a_pg_pc   nm_margin if rel_order_mVnm==1
	eststo m2: rdrobust change_ln_pg nm_margin if rel_order_mVnm==1
	eststo m3: areg ln_a_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)

	*Cols 4-6: Non-PG spending
	rdrobust ln_non_pg_pc nm_margin if rel_order_mVnm==1
	rdrobust change_ln_non_pg nm_margin if rel_order_mVnm==1
	areg ln_non_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)

	*** EDITED by Donna
	estout m1 m2 m3 using "../../results/table3.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
	
******************************
* Table 4: Robustness checks *
******************************

	*Col 1: Optimal bandwidth
	eststo T4_0a: areg ln_a_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)
	eststo T4_0b: areg a_pg_pc 		DD_nonmodal_wins##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)
	eststo T4_0c: areg ln_non_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)
	eststo T4_0d: areg non_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)

	*Col 2: Half-optimal bandwidth
	eststo T4_1a: areg ln_a_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<0.0356, a(ENTITY_ID) cluster(raceid4)
	eststo T4_1b: areg a_pg_pc 		DD_nonmodal_wins##c.Margin i.datayear if Margin<0.0356, a(ENTITY_ID) cluster(raceid4)
	eststo T4_1c: areg ln_non_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<0.0356, a(ENTITY_ID) cluster(raceid4)
	eststo T4_1d: areg non_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<0.0356, a(ENTITY_ID) cluster(raceid4)

	*Col 3: Twice-optimal bandwidth
	eststo T4_2a: areg ln_a_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<0.1428, a(ENTITY_ID) cluster(raceid4)
	eststo T4_2b: areg a_pg_pc		DD_nonmodal_wins##c.Margin i.datayear if Margin<0.1428, a(ENTITY_ID) cluster(raceid4)
	eststo T4_2d: areg ln_non_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<0.1428, a(ENTITY_ID) cluster(raceid4)
	eststo T4_2c: areg non_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<0.1428, a(ENTITY_ID) cluster(raceid4)

	*Col 4: Second-degree poly interaction
	eststo T4_3a: areg ln_a_pg_pc 	DD_nonmodal_wins##c.Margin##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)
	eststo T4_3b: areg a_pg_pc 		DD_nonmodal_wins##c.Margin##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)
	eststo T4_3c: areg ln_non_pg_pc DD_nonmodal_wins##c.Margin##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)
	eststo T4_3d: areg non_pg_pc 	DD_nonmodal_wins##c.Margin##c.Margin i.datayear if Margin<0.071, a(ENTITY_ID) cluster(raceid4)

	*Col 5: Clustered at city level
	eststo T4_4a: areg ln_a_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<.071, a(ENTITY_ID) cluster(ENTITY_ID)
	eststo T4_4b: areg a_pg_pc 		DD_nonmodal_wins##c.Margin i.datayear if Margin<.071, a(ENTITY_ID) cluster(ENTITY_ID)
	eststo T4_4c: areg ln_non_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071, a(ENTITY_ID) cluster(ENTITY_ID)
	eststo T4_4d: areg non_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<.071, a(ENTITY_ID) cluster(ENTITY_ID)

	*Col 6: Five person councils only
	eststo T4_5a: areg ln_a_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & totcand==5, a(ENTITY_ID) cluster(raceid4)
	eststo T4_5b: areg a_pg_pc 		DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & totcand==5, a(ENTITY_ID) cluster(raceid4)
	eststo T4_5c: areg ln_non_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & totcand==5, a(ENTITY_ID) cluster(raceid4)
	eststo T4_5d: areg non_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & totcand==5, a(ENTITY_ID) cluster(raceid4)

	*Col 7: Restricting "pre" to year before election ONLY
	gen years_since=datayear-earliest_relevantelection  if earliest_relevantelection!=.
	
	eststo T4_6a: areg ln_a_pg_pc	DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & a_pg_pc!=. & years_since>=-2 , a(ENTITY_ID) cluster(raceid4)
	eststo T4_6b: areg a_pg_pc 		DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & a_pg_pc!=. & years_since>=-2 , a(ENTITY_ID) cluster(raceid4)
	eststo T4_6c: areg ln_non_pg_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & a_pg_pc!=. & years_since>=-2 , a(ENTITY_ID) cluster(raceid4)
	eststo T4_6d: areg non_pg_pc 	DD_nonmodal_wins##c.Margin i.datayear if Margin<.071 & a_pg_pc!=. & years_since>=-2 , a(ENTITY_ID) cluster(raceid4)

	esttab T4_* using "T4 Main robust", keep(1.DD_nonmodal_wins) stats(N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv replace


*************************
* Table 5: Interactions *
*************************

gen roc_nonwhite=1-roc_white_prop //gen ROC non-white share

	foreach x in MGdis theil cityfract share_pop_nonwhite roc_fract roc_nonwhite prevote_pg_pc {
		*Partition sample at median
			sum `x' if inmainsample==1, d
			gen hi_`x'= `x'>r(p50) if `x'!=. & inmainsample==1
			gen lo_`x'=1-hi_`x'

		*Generate treatment interactions
			gen treatXlow=DD_nonmodal_wins*lo_`x'
			gen treatXhigh=DD_nonmodal_wins*hi_`x'
			gen high=hi_`x'
		
		*Regress!
			eststo T5_`x': areg ln_a_pg_pc  (treatXlow treatXhigh high)##c.Margin     i.datayear if Margin<.0713803, a(ENTITY_ID) cluster(raceid4)  
			
				lincom 1.treatXhigh-1.treatXlow //test the difference between the two
					estadd scalar b_diff r(estimate)
				te 1.treatXhigh-1.treatXlow=0
					estadd scalar p_diff r(p)
			
			drop treatXlow treatXhigh high
	}
	
* esttab T5_* using "T5 Partition", keep(1.treatXlow 1.treatXhigh) stats(b_diff p_diff N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv replace

*** EDITED by Donna
estout T5_* using "../../results/table5.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*********************************************
* Table 6 is produced in a separate do file *
*********************************************

*********************************************
* Table 7 is produced in a separate do file *
*********************************************

	
*************************************************
* Appendix Figure 1: Calonico et al. balance RD *
*************************************************
	rdplot cityfract 	 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("City fractionalization") legend(off) name(cityfract, replace))
	rdplot citypolar 	 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("City polarization") legend(off) name(citypolar, replace))
	rdplot MGdis 	 	 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("City segregation") legend(off) name(MGdis, replace))
	rdplot theil 	 	 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("City income inequality") legend(off) name(theil, replace))
	rdplot DemShare   	 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("City Democrat share") legend(off) name(DemShare, replace))
	rdplot RegShare  	 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("City registered voter share") legend(off) name(RegShare, replace))
	rdplot comp 		 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("City political competition") legend(off) name(comp, replace))
	rdplot prevote_pg_pc nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("Pre-election PG spending per capita") legend(off) name(prevote_pg_pc, replace))
	rdplot roc_fract 	 nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("Rest-of-council fractionalization") legend(off) name(roc_fract, replace))
	rdplot female 	     nm_margin if rel_order_mVnm==1 & election_occurs==1, p(1) upperend(0.071) lowerend(-0.071) graph_options(title("Female winner") legend(off) name(female, replace))

	graph combine cityfract citypolar MGdis theil DemShare RegShare comp prevote_pg_pc roc_fract female, cols(2) name(combined, replace)
	graph display, ysize(11) xsize(8)
	graph export "FA1 Balance.pdf", replace

************************************  
* Appendix T1: Specific categories *
************************************

	foreach x in COMM_DEVELOP_pc CULT_LEISURE_pc HEALTH_pc PUB_SAFETY_pc TRANSP_pc {
	eststo TA1_`x': areg ln_`x' DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)
	}
	esttab TA1_* using "TA1 specific cat", keep(1.DD_nonmodal_wins) stats(N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv replace 


*************************
* Appendix T2: Revenues *
*************************

	eststo TA2_1: areg ln_GENREV_TAXES_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)
	eststo TA2_2: areg ln_GENREV_INT_GOV_STATE_pc DD_nonmodal_wins##c.Margin i.datayear if Margin<.071  , a(ENTITY_ID) cluster(raceid4)
	
	esttab TA2_* using "TA2 revenues", keep(1.DD_nonmodal_wins) stats(N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv replace 
