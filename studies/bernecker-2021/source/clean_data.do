set more off

use welfarereform_082013_v42.dta 

*fill missing values of perc_presdemo with last non-missing value
replace perc_presdemo = l.perc_presdemo if perc_presdemo >= .

*generate years_since_election and second_half_cycle
gen years_since_election=.
replace years_since_election=0 if election==1
replace years_since_election=1 if l.election==1 & years_since_election==.
replace years_since_election=2 if l.l.election==1 & years_since_election==.
replace years_since_election=3 if l.l.l.election==1 & years_since_election==.

gen second_half_cycle=.
replace second_half_cycle=0 if years_since_election==0 | years_since_election==1 
replace second_half_cycle=1 if years_since_election==2 | years_since_election==3

*generate party dummies
gen gov_rep=.
replace gov_rep=0 if (govparty==1)
replace gov_rep=1 if (govparty==0)
gen gov_dem=.
replace gov_dem=0 if (govparty==0)
replace gov_dem=1 if (govparty==1)

*generate relative caseload measure
gen caseload_rel=tanf_rec_cy/(1000*pop)

*generate low governor quality dummies
gen gov_years_pol_office=.
replace gov_years_pol_office=gov_inaugural_age-gov_age1steo
**median of years in political office (1978-1996) is 12 years
gen gov_quality1_low=.
replace gov_quality1_low=0 if (gov_years_pol_office!=.)
replace gov_quality1_low=1 if (gov_years_pol_office!=. & gov_years_pol_office<12)

*based on education
gen gov_quality2_low=.
replace gov_quality2_low=0 if (gov_edu!=.)
replace gov_quality2_low=1 if (gov_edu!=. & gov_edu==1)

gen gov_quality3_low=.
replace gov_quality3_low=0 if (gov_edu!=.)
replace gov_quality3_low=1 if ((gov_edu!=. & gov_edu==1) | (gov_edu!=. & gov_edu==2))

gen gov_quality4_low=.
replace gov_quality4_low=0 if (gov_state_legislature!=. & gov_congress!=.)
replace gov_quality4_low=1 if (gov_state_legislature!=. & gov_congress!=. & gov_state_legislature==0 & gov_congress==0)

gen gov_quality5_low=.
replace gov_quality5_low=0 if (gov_attorney_general!=. & gov_lieutenant_gov!=. & gov_secretary_of_state!=.)
replace gov_quality5_low=1 if (gov_attorney_general!=. & gov_lieutenant_gov!=. & gov_secretary_of_state!=. & gov_attorney_general==0 & gov_lieutenant_gov==0 & gov_secretary_of_state==0)

gen gov_quality6_low=.
replace gov_quality6_low=0 if (gov_quality4_low!=. & gov_quality5_low!=.)
replace gov_quality6_low=1 if (gov_quality4_low!=. & gov_quality5_low!=. & gov_quality4_low==0 & gov_quality5_low==0)

*generate religion dummies
gen gov_protestant=.
replace gov_protestant=0 if (gov_religious_group!=.)
replace gov_protestant=1 if (gov_religious_group!=. & gov_religious_group==1)
gen gov_catholic=.
replace gov_catholic=0 if (gov_religious_group!=.)
replace gov_catholic=1 if (gov_religious_group==2)

*generate age and age dummy
gen gov_age=.
replace gov_age=year-gov_yob
**median age (1978-1996) is 55 years
gen gov_old=.
replace gov_old=0 if (gov_age!=.)
replace gov_old=1 if (gov_age!=. & gov_age>=55)
gen gov_young=.
replace gov_young=1 if (gov_old!=.)
replace gov_young=0 if (gov_old!=. & gov_old==1)

*generate no lameduck indicator
gen nlameduck=.
replace nlameduck=0 if (lameduck!=.)
replace nlameduck=1 if (lameduck!=. & lameduck==0)

*democratic seat share
gen up_dem_share=updem/uptot
gen low_dem_share=lowdem/lowtot

*generate polarization (based on seat distribution in state legislature)
gen polarization_house=.
replace polarization_house = abs(lowdem/lowtot-0.5)
gen polarization_senate=.
replace polarization_senate = abs(updem/uptot-0.5)

gen pcap_1000=pcap/1000
gen pop_1000=pop/1000





