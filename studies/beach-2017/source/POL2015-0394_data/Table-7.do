clear all

cd "."

use "Gridlock-voting-data-for-analysis"


gen voteshare=ceda_votes/ceda_totvotes //vote share from each election.

drop if win<0 & year==preelectionyear //these are weird situations where the candidate lost but ultimately served (probably by being appointed)

gsort personid year -voteshare 
duplicates drop personid year, force //sometimes a candidate will show up more than once per year (this is a district based thing). Keep the election with the biggest vote share (that is probably how the city deals with a situation where the candidate is elected twice).

* Some candidates won't have a pre-election. Will need to restrict to candidates that we observe before and after mVnm
duplicates tag personid, gen(haspre)


* Now let's turns DD_nonmodal_wins into the indicator it should be -- no one is treated prior to the mVnm election
replace DD_nonmodal_wins=0 if year==preelectionyear 

**********************************
*Table 7: Electoral consequences *
**********************************

	* FUTURE VOTE SHARE WITH CANDIDATE FIXED EFFECTS
		eststo voting_1: areg voteshare DD_nonmodal_wins##c.Margin i.numcandidates i.year if Margin<.0713803 & haspre!=0, a(personid) cluster(raceid)

	* FUTURE VOTE SHARE WITHOUT CANDIDATE FIXED EFFECTS
		eststo voting_2:  reg voteshare DD_nonmodal_wins##c.Margin i.numcandidates i.year if Margin<.0713803 & year>relevantelectionyear, cluster(raceid)

	* IS THE DECLINE IN VOTE SHARE BECAUSE MORE CANDIDATES ARE RUNNING?
		eststo voting_3:  reg numcandidates DD_nonmodal_wins##c.Margin i.year if Margin<.0713803 & year>relevantelectionyear, cluster(raceid)
	
	* WHAT ABOUT A CHANGE IN THE NUMBER OF INCUMBENTS THAT ARE RUNNING?
		eststo voting_4:  reg numincumbents DD_nonmodal_wins##c.Margin i.year if Margin<.0713803 & year>relevantelectionyear, cluster(raceid)
		
	* esttab voting_* using "T7 Voting", keep(1.DD_nonmodal_wins) stats(N r2) b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) csv replace
	
	*** EDITED by Donna
	estout voting_* using "../../results/table7.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace