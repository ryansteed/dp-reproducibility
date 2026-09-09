*******************************
*Title: sbe_base_v3

*Purpose: calculate base elections dataset for analysis

*Created by: mengyang
*Last edited: alvin christian, 8/27/24
*******************************

clear 

set more off

clear matrix

clear mata

set matsize 5000

clear 
//cd "${data}"

global data "${filepath}/Data"
global finaldata "${filepath}\Final analysis data"
//cd "${filepath}"

program drop _all

*** LOAD Ballotpedia DATA *** 
use "$data/Ballotpedia/clean_combined_general_ballotpedia_data_merged_with_census_v2.dta" , clear 

capture drop _merge 

tab stageisrankedchoice, m 
*drop 3 ranked choice obs
drop if stageisrankedchoice=="true"
*drop variables not needed
drop stageisrankedchoice rankedchoicevotinground 

*race types
gen recall=race_type=="Recall" 
gen special=race_type=="Special"
gen regular=race_type=="Regular" 

*log vote share measure 
gen l_votes_per_seat_per_pop=ln(votes_per_seat_per_pop)

*incumbent variables 
gen any_incumbent=num_incumbent>0
  label var any_incumbent "Election included 1+ incumbents"

gen frac_incumbent=num_incumbent/num_candidates_total
  label var frac_incumbent "Fraction candidates who were incumbents"
  
gen frac_incumbent_winners=num_incumbent_winners/num_winners
  label var frac_incumbent_winners "Fraction of winners who were incumbents"
  
gen frac_incumbent_who_won=num_incumbent_winners/num_incumbent 
  label var frac_incumbent_who_won "Fraction of incumbents who won"

gen num_cand_per_seat = num_candidates_total/seats_up_for_election
  label var num_cand_per_seat "Number of candidates per seat" 

gen frac_incumbent_who_ran = num_incumbent / seats_up_for_election
   replace frac_incumbent_who_ran=1 if frac_incumbent_who_ran>1 & frac_incumbent_who_ran!=. 
   label var frac_incumbent_who_ran "Fraction of races with an incumbent"
   
gen frac_dem_winners = num_democrat_winners/num_democrats
  label var num_democrats "Number of democracts in election" 
  label var frac_dem_winners "Fraction winners who are democracts"

 gen frac_democrats=num_democrats/num_candidates_total 
     label var frac_democrats "Fraction candidates who are democrats"

*stage variables
gen runoff=stage=="General Runoff"|stage=="Primary Runoff"
tab runoff, m 
gen primary=inlist(stage,"Primary","Primary Runoff") 
gen general=inlist(stage,"General","General Runoff") 
gen pri_partisan=partisan_primary=="true"
gen pri_nonpart=partisan_primary=="false" 
 

*# of primaries for this district-subdivision over time period
egen tmp=sum(1) if stage=="Primary", by(office_name)
egen num_primary=max(tmp), by(office_name)
drop tmp
egen tmp=sum(1) if stage=="General", by(office_name)
egen num_general=max(tmp), by(office_name)
drop tmp


*Create indicators for time period 
gen tmpy=year(election_date)
gen tmpm=month(election_date)
gen yr2018_spr=tmpy==2018 & tmpm<=6
gen yr2018_fall=tmpy==2018 & tmpm>6 
gen yr2019_spr=tmpy==2019 & tmpm<=6
gen yr2019_fall=tmpy==2019 & tmpm>6 
gen yr2020_spr=tmpy==2020 & tmpm<=6
gen yr2020_fall=tmpy==2020 & tmpm>6 
gen yr2021_spr=tmpy==2021 & tmpm<=6
gen yr2021_fall=tmpy==2021 & tmpm>6 
gen yr2022_spr=tmpy==2022 & tmpm<=6
gen yr2022_fall=tmpy==2022 & tmpm>6 
rename tmpy el_year 
rename tmpm el_month 
gen post_covid=election_date>mdy(3,10,2020) 
label var post_covid "after march 10 2020"

gen summer2020 =  election_date>mdy(3,10,2020) & election_date<mdy(9,1,2020)  
gen ay2021 =  election_date>mdy(8,31,2020)& election_date<mdy(9,1,2021) 
gen ay2122 = election_date>mdy(8,31,2021)
gen ay2022 = election_date>mdy(8,31,2020)


gen el_yr_mn=ym(el_year,el_month)
format el_yr_mn %tm 
*# months pre and post covid: post covid 12 months in `22 and 12 months in `21, and 9 months in `20 = 33 months.  pre covid, '18, '19' + 2 months in 20 = 26 months 


*uncontested 
gen uncontested=uncontested_general==1|uncontested_primary==1 
tab uncontested no_votes if regular==1 & runoff==0, m 
gen canceled = uncontested==1 | no_votes==1 
label var uncontested "number of candidates receiving votes is less than or equal to the number of seats available"
label var canceled "number of candidates receiving votes is less than or equal to the number of seats available or No votes recorded"

*elections before and after covid - excluding recall or special elections
egen tmp=sum(1) if stage=="Primary"&race_type=="Regular" & canceled==0, by(office_name)
egen tmp2=max(tmp), by(office_name)
gen num_prim=tmp2 
drop tmp tmp2   

egen tmp=mean(post_covid) if stage=="Primary"&race_type=="Regular" & canceled==0, by(office_name)
egen tmp2=max(tmp), by(office_name)
gen any_prim_pre_and_post=tmp2>0 & tmp2<1
drop tmp tmp2  

egen tmp=sum(1) if stage=="General"&race_type=="Regular" & canceled==0, by(office_name)
egen tmp2=max(tmp), by(office_name)
gen num_gen=tmp2 
drop tmp tmp2 

egen tmp=mean(post_covid) if stage=="General"&race_type=="Regular" & canceled==0 , by(office_name)
egen tmp2=max(tmp), by(office_name)
gen any_gen_pre_and_post=tmp2>0 & tmp2<1
drop tmp tmp2  

egen tag=tag(office_name stage race_type)
egen tag2=tag(office_name) 

tab num_prim any_prim_pre_and_post if tag2, m
tab num_gen any_gen_pre_and_post if tag2, m
 
gen no_election=no_votes==1 | uncontested==1 
 
*District Type 
tab election_district_type , m
gen subdivision=election_district_type=="School district subdivision"
tab subdivision, m 



************************************
*** MERGE ON DISTRICT VARIABLES ****
************************************

d, f 
rename nces_district_id leaid 
merge m:1 leaid using  "$data/district_demo_ach_file_v3.dta"

list census_district_name leaid if _merge==1
drop if _merge==1 
gen has_voting_data=_merge==3 
drop _merge 

//label to make it easier to output
label var baplusall "ba+ rate"

//note: these two variables require the aei data which is not available in this replication package
gen no_mask_data = no_mask_sep==. 
gen never_mask_req = no_mask_sep==1 & no_mask_oct==1 if no_mask_data == 0 


gen no_mode_data = mode_start_distr==. 
gen hybrid=mode_start_distr==1 if no_mode_data==0 
gen inperson=mode_start_distr==2 if no_mode_data==0 
gen remote=mode_start_distr==3 if no_mode_data==0 
gen no_mode_pct=pct_hybrid_distr_yr==.

egen permin=rsum(perblk perhsp)
egen avg_deaths_per_month_per_1000 = rmean(death*)


*Merge on partisanship variables 
merge m:1 state_name using "$data/state_vote_share_trump_2016.dta", keepusing(state_name state_vote_trump)
*merge m:1 state_name using "$finaldata/state_vote_share_trump_2016.dta", keepusing(state_name state_vote_trump)
drop if _merge==2
drop _merge 
egen tagst=tag(state) 

drop tag* 
 
*Create indicator for having pre and post covid data  
egen tmppost=max(post_covid==1) if regular==1 & runoff!=1 & no_election==0, by(office_id) 
egen tmppre=max(post_covid==0) if regular==1 & runoff!=1 & no_election==0, by(office_id)
gen both = tmppost==1 & tmppre==1 
egen has_pre_and_post_data=max(both), by(leaid) 
 
egen tag=tag(office_id) 
tab both if tag, m  
codebook leaid if both 
capture drop tag 

egen taglea=tag(leaid)

*drop few obs for weird districts 
keep if lea_type==1 | lea_type == 2 

*Merge on enrollment change measures 
merge m:1 leaid using "${data}\ccd_offtrend_all_distr.dta", keepusing(tot_enr16_20 tot_pct_offtrend2021 tot_pct_offtrend2022)
drop if _merge==2
drop _merge 


egen has_data=max(has_voting_data), by(leaid)

save "$finaldata/SBE_base_data.dta", replace 
