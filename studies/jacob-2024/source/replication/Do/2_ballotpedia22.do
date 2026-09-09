/********************************************************************************
More general Ballotpedia 2022 cleaning (not dropping primaries/canceled/runoff/recall/special/etc.) 
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


clear 
cd "${data}/Ballotpedia"

log using input_ballotpedia_2022.log, replace 

**** IMPORT RAW DATA *****

import delimited using "ballotpedia_2022_candidates_for_brian_jacob_umich_2023-01-23.csv", clear 
drop if missing(stage) //one obs read in weird where some data on email ended up on its own row

drop if stageisrankedchoice == "true"

**** CREATE KEY VARIABLES ****

*# votes cast total, # candidates running, # seats, # of incumbents who ran, # of incumbents who won. 
*#votes cast total (note this does not count votes against, so it won't cover recalls)
by stageid, sort: egen total_votes = total(votesfor)

*special vote count variable that also works for recalls
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

replace num_winners = num_advanced if num_winners == 0

*generate variables about democrats and republicans running/winning (though note most candidates are nonpartisan)
by stageid: egen num_democrats = total(partyaffiliation == "Democratic Party") 
by stageid: egen num_republicans = total(partyaffiliation == "Republican Party")

*generate variables about democrat and republican winners (though these are all zero in this dataset)
by stageid: egen num_democrat_winners = total( (partyaffiliation == "Democratic Party") & (candidatestatus == "Won") )
by stageid: egen num_republican_winners = total( (partyaffiliation == "Republican Party") & (candidatestatus == "Won"))

*Only keep fields that might be necessary 

*drop information about the candidates
*drop basic biographical information
drop name firstname lastname gender

*drop ballotpedia identifiers/social media/contact information for candidates
drop candidateid personid ballotpediaurl campaignemail otheremail campaignwebsite personalwebsite campaignfacebook personalfacebook campaigntwitter personaltwitter campaigninstagram personalinstagram campaignyoutube personalyoutube campaignmailingaddress campaignphone linkedin

*drop identifier for write-in candidates
drop writein

*keep only one observation per election
by stageid: keep if _n == _N

*drop leftover variables about candidates
drop incumbent candidatestatus votesfor partyaffiliation votesagainst


*Rename fields to be more understandable and consistent over time 
rename seatsupforelection seats_up_for_election
rename state state
rename electionyear election_year
rename stageid stage_id
rename stage stage
rename raceid race_id
rename racetype race_type
rename officeid office_id
rename officelevel office_level
rename officebranch office_branch
rename districtocdid district_ocdid
rename raceurl race_url
rename stagecanceled stage_canceled
rename partisanprimary partisan_primary
*Fix Partisanprimary variable to be consistent with 2018-2021 (where it is str5)

*ballotpedia calls the district where the election is occurring the "district." to avoid confusion I am renaming this "election_district"
rename districtname election_district
rename districttype election_district_type

 

rename officename office_name

*rename election date variable, noting formatting of the dates is not consistent w/ 2018-2021

rename electiondate election_date_2022

*The district names were very nonstandardized so I created a spreadsheet with them to merge including numeric identifiers

merge m:1 election_district state using "ballotpedia_2022_district_names_all_cases_v3.dta"
keep if _merge == 3
drop _merge

*school_district_name captures the name of the district in the NCES database and nces_district_id is the numeric id (w/ no leading zeroes) in the NCES database


*cd "/Users/`c(username)'/Dropbox (University of Michigan)/School_Boards_and_COVID/Data/Ballotpedia/data_temp"
destring election_year,replace
drop if missing(election_year)
save "clean_ballotpedia_2022_including_all_cases.dta", replace

*clear
log close


