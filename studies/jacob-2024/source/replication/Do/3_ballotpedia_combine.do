/********
Combines ballotpedia data from the two years and additionally cleans and checks school district vs. school district subdivision. Then merges with the census data.
*********/

clear all 
set more off 
macro drop all
capture log close


*global user "zachhalberstam"
*global user "bajacob" 


cd "$data/Ballotpedia/"

append using "clean_ballotpedia_2018_2021_including_all_cases_v2.dta" "clean_ballotpedia_2022_including_all_cases.dta"

*clean up dates
gen election_date = date(election_date_2018_2021, "YMD")
gen election_date_2 = date(election_date_2022, "YMD")
replace election_date = election_date_2 if election_date == .
drop election_date_2018_2021
drop election_date_2022 election_date_2

format election_date %td 
*drop all of the elections with stage_canceled as true
//drop if stage_canceled == "Yes"
*drop one strange election, in which the top vote-getter got a 3-year term and the second vote-getter got a 1-year term



drop if office_name == "DEFOREST AREA SCHOOL DISTRICT BOARD OF EDUCATION VILLAGE OF WINDSOR 1-YEAR AND 3-YEAR TERMS"


//make histogram
forval i = 2018/2022 {
	di d(1nov`i') " " _c
	di d(1may`i') " " _c
 }
hist election_date,freq xla(21489 21305 21854 21670 22220 22036 22585 22401 22950 22766, angle(45) )



*generate leftover variables that haven't already been generated in the input files

*indicator variable for whether no votes were cast
replace total_votes = 0 if stage_canceled=="Yes"
gen no_votes = (total_votes == 0)

*indicator variable for whether the election went to a runoff (note we must also check the stages of elections since primaries have candidates who advance as well)
gen went_to_runoff = (num_advanced >0) & (stage == "General")

*indicator variable for whether the election was uncontested (here, "uncontested" means that the number of candidates receiving votes is less than or equal to the number of seats available. I'm also specifying general elections here since I believe the "seats up for election" variable refers to seats available in the general. Note also that recalls will often have a "true" value for this variable as well because sometimes the only candidates are the ones up for recall.)
gen uncontested_general = ((num_candidates_receiving_votes <= seats_up_for_election) & (stage == "General"))  | ((stage == "General") & no_votes==1) 

gen uncontested_primary = ((stage == "Primary") & (num_candidates_not_wddq <= num_advanced + num_winners)) | ((stage == "Primary") & no_votes==1)





*standardize case and trim
replace office_name = upper(trim(office_name))

replace election_district_type = "School district subdivision" if election_district_type == "School Board District"


*Investigate which school districts have positions elected in "zones" which are not marked as subdivisions
list if election_district_type == "School District" & strpos(office_name, "ZONE")

*All of the districts listed are in Oregon or Idaho. They appear to be mislabeled subdivisions (there are the tricky Scappoose Zones At-large, which we decided to call subdivisions in the more restrictive document). So we replace them)
replace election_district_type = "School district subdivision" if election_district_type == "School District" & strpos(office_name, "ZONE")
*Note that generally for these cases the election district is listed as the whole school board even though they are just for one office

*Investigate which school districts have positions elected in "areas" which are not marked as subdivisions
list if election_district_type == "School District" & strpos(office_name, "AREA")
*some of these are what we want to find and change, but others are districts with "AREA" in the name (e.g. Verona Area School District)
*exclude these
list office_name election_district if election_district_type == "School District" & strpos(office_name, "AREA") & !strpos(office_name, "AREA SCHOOL") & !strpos(office_name, "AREA BOARD") & !strpos(office_name, "AREA PUBLIC")
*something strange is going on with charleston county. The elections are listed in individual districts but school board members might be representing multiple districts as per school board websites? I think a recent SC-wide school board reform is responsible.
*Still, all of these appear to be true subdivisions (though I have not looked at each carefully individually). (even if charleston county has other subdivisions as well) . So we replace.
replace election_district_type = "School district subdivision" if election_district_type == "School District" & strpos(office_name, "AREA") & !strpos(office_name, "AREA SCHOOL") & !strpos(office_name, "AREA BOARD") & !strpos(office_name, "AREA PUBLIC")

*Investigate which school districts have positions in "regions" which are not marked as subdivisions
list if election_district_type == "School District" & strpos(office_name, "REGION")
*it's Mukwonago in WI which should be a subdivision and one recall question where "regional" is in the district name. Replace Mukwonago.
replace election_district_type = "School district subdivision" if election_district_type == "School District" & strpos(office_name, "MUKWONAGO") & strpos(office_name, "REGION")

*Investigate which school districts have positions in "subdistricts" which are not marked as subdivisions
list if election_district_type == "School District" & strpos(office_name, "SUBDISTRICT")
list if election_district_type == "School District" & strpos(office_name, "SUB-DISTRICT")
*There are none

*Investigate which school districts have positions in "quadrants" which are not marked as subdivisions
list if election_district_type == "School District" & strpos(office_name, "QUADRANT")
*It's one district in Indiana and these should be subdivisions (the school board website is not clear, but the page on ballotpedia is). So we replace them.
replace election_district_type = "School district subdivision" if election_district_type == "School District" & strpos(office_name, "QUADRANT")

*Investigate which school districts have positions in "wards" which are not marked as subdivisions
list if election_district_type == "School District" & strpos(office_name, "WARD")
*Everything that comes up seems to be actual subdivisions except for "BROWARD" and "HOWARD" which come up with this search
list if election_district_type == "School District" & strpos(office_name, "WARD") & !strpos(office_name, "OWARD")
*replace these
replace election_district_type = "School district subdivision" if election_district_type == "School District" & strpos(office_name, "WARD") & !strpos(office_name, "OWARD")


*Now for the biggest and most annoying one: Investigate which school districts have positions in "districts" which are not marked as subdivisions.
*The big obstacle is not finding all the ones that are "school districts"
*first, we deal with those that do not contain "school district" in the office name
list office_name if election_district_type == "School District" & strpos(office_name, "DISTRICT") & !strpos(office_name, "SCHOOL DISTRICT")
*some districts come up still because "district" is in the name. excude these as well
list office_name if election_district_type == "School District" & strpos(office_name, "DISTRICT") & !strpos(office_name, "SCHOOL DISTRICT") & !strpos(office_name, "UNIFIED DISTRICT") & !strpos(office_name, "ELEMENTARY DISTRICT")
*these look mostly good, except for some which are, strangely, labeled "at-large." These districts are in Pinellas County and Hillsborough county: looking them up specifically, they are true at-large districts, despite the strange name.
*list the candidates for replacement in this category:
list office_name if election_district_type == "School District" & strpos(office_name, "DISTRICT") & !strpos(office_name, "SCHOOL DISTRICT") & !strpos(office_name, "UNIFIED DISTRICT") & !strpos(office_name, "ELEMENTARY DISTRICT") & !strpos(office_name, "AT-LARGE")
*These all seem like they are actually subdivisions. Have not examined every one of them. Still, I am going to replace them.
replace election_district_type = "School district subdivision" if election_district_type == "School District" & strpos(office_name, "DISTRICT") & !strpos(office_name, "SCHOOL DISTRICT") & !strpos(office_name, "UNIFIED DISTRICT") & !strpos(office_name, "ELEMENTARY DISTRICT") & !strpos(office_name, "AT-LARGE")

*and we still need to deal with districts that have "school district" in the name
*start with some plausible lead-ins to district
list office_name if election_district_type == "School District" & (strpos(office_name, "TRUSTEES DISTRICT")| strpos(office_name, "BOARD DISTRICT") | strpos(office_name, "EDUCATION DISTRICT"))
*some of these are denoted "at-large." get rid of them.
list office_name if election_district_type == "School District" & (strpos(office_name, "TRUSTEES DISTRICT")| strpos(office_name, "BOARD DISTRICT") | strpos(office_name, "EDUCATION DISTRICT")) & !strpos(office_name, "AT-LARGE")
*These all seem like they are actually subdivisions. Have not examined every one of them. Still, I am going to replace them.
replace election_district_type = "School district subdivision" if election_district_type == "School District" & (strpos(office_name, "TRUSTEES DISTRICT")| strpos(office_name, "BOARD DISTRICT") | strpos(office_name, "EDUCATION DISTRICT")) & !strpos(office_name, "AT-LARGE")

*numerical districts
list office_name if election_district_type == "School District" & (strpos(office_name, "DISTRICT 1") | strpos(office_name, "DISTRICT 2") | strpos(office_name, "DISTRICT 3") | strpos(office_name, "DISTRICT 4") | strpos(office_name, "DISTRICT 5") | strpos(office_name, "DISTRICT 6") | strpos(office_name, "DISTRICT 7") | strpos(office_name, "DISTRICT 8") | strpos(office_name, "DISTRICT 9"))
*exclude at-large
list office_name if election_district_type == "School District" & (strpos(office_name, "DISTRICT 1") | strpos(office_name, "DISTRICT 2") | strpos(office_name, "DISTRICT 3") | strpos(office_name, "DISTRICT 4") | strpos(office_name, "DISTRICT 5") | strpos(office_name, "DISTRICT 6") | strpos(office_name, "DISTRICT 7") | strpos(office_name, "DISTRICT 8") | strpos(office_name, "DISTRICT 9")) & !strpos(office_name, "AT-LARGE")
*Exclude Parkrose School District 3, which is included in this because of the district name. This leaves us with just one office - Somerset Independent School District 6, which we replace
list if election_district_type == "School District" & (strpos(office_name, "DISTRICT 1") | strpos(office_name, "DISTRICT 2") | strpos(office_name, "DISTRICT 3") | strpos(office_name, "DISTRICT 4") | strpos(office_name, "DISTRICT 5") | strpos(office_name, "DISTRICT 6") | strpos(office_name, "DISTRICT 7") | strpos(office_name, "DISTRICT 8") | strpos(office_name, "DISTRICT 9")) & !strpos(office_name, "AT-LARGE") & !strpos(office_name, "PARKROSE SCHOOL DISTRICT 3")

replace election_district_type = "School district subdivision" if election_district_type == "School District" & (strpos(office_name, "DISTRICT 1") | strpos(office_name, "DISTRICT 2") | strpos(office_name, "DISTRICT 3") | strpos(office_name, "DISTRICT 4") | strpos(office_name, "DISTRICT 5") | strpos(office_name, "DISTRICT 6") | strpos(office_name, "DISTRICT 7") | strpos(office_name, "DISTRICT 8") | strpos(office_name, "DISTRICT 9")) & !strpos(office_name, "AT-LARGE") & !strpos(office_name, "ACADEMY SCHOOL DISTRICT 20") & !strpos(office_name, "PARKROSE SCHOOL DISTRICT 3")

*there are districts like Charleston County and Deforest which should be regional but have no indicator word like "district" or "region" or "area." Not sure what a standardized way to deal with these would be.

*deal with subdistricts without identifiers ("area," "region," "ward," etc.) that I've noticed
*Hamilton School District, WI
replace election_district_type = "School district subdivision" if state=="WI" & strpos(office_name, "HAMILTON")

*DeForest School District, WI
replace election_district_type = "School district subdivision" if state=="WI" & strpos(office_name, "FOREST") & !strpos(office_name, "AT-LARGE")

*Charleston County, SC
*note recent SC reforms mean that this is not regional anymore, but at the time of the election I think it was.
replace election_district_type = "School district subdivision" if strpos(office_name, "CHARLESTON COUNTY")

*making a pass through those that are still labeled "School District"
list office_name in 1/25 if election_district_type == "School District"
list office_name if election_district_type == "School District"

*Replace Buffalo
replace election_district_type = "School district subdivision" if strpos(office_name, "BUFFALO") & !strpos(office_name, "AT-LARGE")

*Replace Oklahoma
replace election_district_type = "School district subdivision" if state == "OK" & (strpos(office_name, "OFFICE") | strpos(office_name, "NUMBER"))

*Replace Douglas County, CO
replace election_district_type = "School district subdivision" if strpos(office_name, "DOUGLAS") & state == "CO"

*Replace if the word "Precinct" is used (this only affects Davis, UT so far)
replace election_district_type = "School district subdivision" if strpos(office_name, "PRECINCT")

*Replace if the word "Portion" is used (this only affects Verona Area, WI so far)
replace election_district_type = "School district subdivision" if strpos(office_name, "PORTION")

//replace state = "KY" if nces_district_id==2102990 & election_district!="Jefferson Parish Public School System" //mislabeled jefferson county in LA vs KY
replace nces_district_id=2200840 if nces_district_id==2102990 & election_district=="Jefferson Parish Public School System" 

//accidentally missing identifiers
replace nces_district_id = 3813760 if missing(nces_district_id) & state=="ND"



//formats
format election_date %td 

save "combined_general_ballotpedia_data_v2.dta", replace


***************CENSUS MERGE**************
clear
*cd "/Users/`c(username)'/Dropbox (University of Michigan)/School_Boards_and_COVID/Data/Ballotpedia/data_raw/EDGE_Export_77161055709"

*import census data
import delimited "DP02_001_USSchoolDistrictAll_7716101623.txt"

*extract state from the name
gen state = substr(geography, length(geography)-1, 2)

rename leaid nces_district_id

*there are repeated entries in Census data
by nces_district_id state, sort: egen count = total(1)


drop if count>1
drop count

//detroit not labeled right
replace nces_district_id=2601103 if nces_district_id==2612000


*now merge
*cd "/Users/`c(username)'/Dropbox (University of Michigan)/School_Boards_and_COVID/Data/Ballotpedia/data_temp"
merge 1:m nces_district_id state using "combined_general_ballotpedia_data_v2.dta"


*drop districts that were not in the ballotpedia data set
keep if _merge == 3

*some relevant population variables
rename dp02_87est total_population
rename dp02_69est adult_civilian_population
rename dp02_53est school_enr


*drop many many extra population variables
drop dp02*

*rename census variables to clarify
rename year census_data_year
rename geography census_district_name
rename geoid census_geoid

*iteration has all of its observations equal to 1 and it is a mysterious census variable
drop iteration

*drop all of the elections with stage_canceled as true
//drop if stage_canceled == "Yes"
drop if stage_id== 97475 //30 million votes, likely a mistake

* gen some vars for use
gen votes_per_seat = total_votes/seats_up_for_election
label var votes_per_seat "votes per seats up for election"
gen votes_per_candidates = total_votes/num_candidates_total
label var votes_per_candidates "votes per total number of candidates"
gen votes_per_pop= total_votes/adult_civilian_population
label var votes_per_pop "vote per civ pop"
gen votes_per_school_enr = total_votes/school_enr
label var votes_per_school_enr "vote per school enrollment"
gen votes_per_seat_per_pop = total_votes/seats_up_for_election/adult_civilian_population
label var votes_per_seat_per_pop "Votes per seats up for election per civ pop"


*In the latest data (8/8/22), some elections on 5/24/22 and every election after 5/24/22 have missing data.
//drop if election_date >= mdy(5,24,2022)
drop _

save "clean_combined_general_ballotpedia_data_merged_with_census_v2.dta", replace
