clear all

cd "/Users/"

foreach x in asian black hisp white {

use "Gridlock main data for analysis.dta", clear

**********************************
* Regression sample restrictions *
**********************************

	*Restrict to cities that expereince an election between a group and non-group candidate
		gen relevantelectionyear=datayear if election_occurs==1 & `x'Vnon`x'==1  	 	 //groupVnon-group=1 for all years after (and including) an election between a group and non-group candidate
		bysort ENTITY_ID: egen float earliest_relevantelection=min(relevantelectionyear) //Identify first year where there is an mVnm election
		keep if earliest_relevantelection!=.  											 //Drop cities that NEVER experience a relevant election.


	*Some cities have more than one mVnm election. Need to truncate those panels.
		gen rel_gVng=`x'Vnon`x' if election_occurs==1 & relevantelectionyear==datayear & relevantelectionyear!=. //Indicator identifying years with gVng elections
		
		sort ENTITY_ID datayear
		bysort ENTITY_ID: gen float rel_order_gVng=sum(rel_gVng) 
		keep if rel_order_gVng<=1									//drop all observations coincinding (and following) the second mVnm election

		
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
		gen group_wins=`x'_wins 								//local_wins =1 if the winner is a member of specified group.
		replace group_wins=0 if group_wins==1 & `x'Vnon`x'==0	//Only want treat indicator to turn on if "group" candidate wins a "group"Vnon-"group" election
		replace group_wins=0 if datayear==2006					//2006 is the base year, so no one is treated. Set all obs equal to zero. 

		sort ENTITY_ID datayear
		replace group_wins=1 if group_wins[_n-1]==1 & ENTITY_ID==ENTITY_ID[_n-1] //Once treatment occurs, carry that forward.

		replace group_wins=0  if rel_order_gVng<1 & `x'_wins!=. //Make sure all pre-relevant election observations are zero.


	*Construct council identifiers since that is where we cluster
		sort ENTITY_ID datayear
		by ENTITY_ID: replace raceid=raceid[_n-1] if raceid==.
		egen float raceid4 = group(raceid ENTITY_ID), missing

		eststo eth_`x': areg ln_a_pg_pc group_wins##c.Margin   i.datayear if Margin<.0713803, a(ENTITY_ID) cluster(raceid4)
	}
	
	esttab eth_* using "T6 Eth", keep(1.group_wins) stats(N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv replace
	
