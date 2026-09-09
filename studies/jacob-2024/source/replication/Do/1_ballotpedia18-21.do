/********************************************************************************
More general Ballotpedia 2018-2021 cleaning (not dropping primaries/runoff/recall/special/etc.) Note it does not included cancelled elections (this would require updating the crosswalk spreadsheet with many more districts. I can do this if necessary but I doubt we will ever be able to do meaningful analysis on cancelled elections.)
********************************************************************************/
clear all 
set more off
macro drop all
capture log close

**************************
**(0) SETUP
**************************
** Setting the Directories

*global user "zachhalberstam"
*global user "bajacob" 
*global user "alvinchr"

clear 
cd "${data}/Ballotpedia"


log using input_ballotpedia_2022.log, replace 

**** IMPORT RAW DATA *****

import delimited "school_board_elections_ballotpedia_2018-2021"

**** CREATE KEY VARIABLES ****

*# votes cast total, # candidates running, # seats, # of incumbents who ran, # of incumbents who won. 
*#votes cast total (note this does not count votes against, so it won't cover recalls)
by stageid, sort: egen total_votes = total(votesfor)
by stageid: egen total_votes_recall = total(votesagainst)
replace total_votes_recall = total_votes_recall + total_votes

* #candidates
by stageid: egen num_candidates_total = total(1)

*additional candidate variables to handle edge cases
* #candidates receiving votes
by stageid: egen num_candidates_receiving_votes = total((votesfor > 0) & (votesfor != .))

* #candidates that were not withdrawn or disqualified
by stageid: egen num_candidates_not_wddq = total(candidatestatus!="Disqualified" & candidatestatus != "Withdrew")

*number of incumbents
by stageid: egen num_incumbent = total(incumbent == "Yes")

*number of winners (note that there is also a Seatsupforelection variable; this one counts the number of determined winners, i.e. # of winners in elections that have been counted)
by stageid: egen num_winners = total(candidatestatus == "Won")

*number of incumbents who won 
by stageid: egen num_incumbent_winners = total( (candidatestatus == "Won") & (incumbent == "Yes"))

*number who advanced to the next round 
by stageid: egen num_advanced = total(candidatestatus == "Advanced")
by stageid: egen num_democrats = total(partyaffiliation == "Democratic Party") 
by stageid: egen num_republicans = total(partyaffiliation == "Republican Party")

*generate variables about democrat and republican winners (though these are all zero in this dataset)
by stageid: egen num_democrat_winners = total( (partyaffiliation == "Democratic Party") & (candidatestatus == "Won") )
by stageid: egen num_republican_winners = total( (partyaffiliation == "Republican Party") & (candidatestatus == "Won"))
*Only keep fields that might be necessary 

//this is for primaries
replace num_winners = num_advanced if num_winners==0

***************************
*drop the canceled elections (there is no useful analysis we can do on those, plus, it would take a lot of effort to update the crosswalk with ~250 more entries)
//drop if stagecanceled == "Yes"



*drop information about the candidates
*drop basic biographical information

drop name firstname lastname gender partyaffiliation incumbent candidatestatus votesfor votesagainst

*drop ballotpedia identifiers for candidates
drop candidateid personid ballotpediaurl

*drop identifier for write-in candidates
drop writein

*keep only one observation per election
by stageid: keep if _n == _N
 

*Rename fields to be more understandable and consistent over time 
rename seatsupforelection seats_up_for_election
rename electionyear election_year
rename raceid race_id
rename racetype race_type
rename officeid office_id
rename officelevel office_level
rename officebranch office_branch
rename districtocdid district_ocdid
rename raceurl race_url
rename stageid stage_id
rename stagecanceled stage_canceled
rename partisanprimary partisan_primary



*election date formats are different, so add a marker to avoid confusion
rename electiondate election_date_2018_2021

*drop the ranked choice observations, then the ranked choice variables (these seem very annoying to deal with and excluding them seems not that bad, given there are just a very small number of districts. one of these districts has 110 observations)

drop if stageisrankedchoice == "true"
drop stageisrankedchoice rankedchoicevotinground

*ballotpedia calls the district where the election is occurring the "district." to avoid confusion I am renaming this "election_district"
rename districtname election_district
rename districttype election_district_type

*keeping the "office name" variable since it is not entirely redundant with the previous two. note for cherokee county, GA, the district is identified as a "school district" but the office names include words that suggest it is actually subdivisions going one. 

rename officename office_name

*The district names were very nonstandardized so I created a spreadsheet with them to merge including numeric identifiers

merge m:1 election_district state using "ballotpedia2018-2021_district_names_including_all_cases_v2.dta"
drop _merge


*school_district_name captures the name of the district in the NCES database and nces_district_id is the numeric id (w/ no leading zeroes) in the NCES database

cd "${data}/Ballotpedia"
save "clean_ballotpedia_2018_2021_including_all_cases_v2.dta", replace

*clear
log close
