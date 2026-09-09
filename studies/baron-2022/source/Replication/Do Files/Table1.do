/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file generates Table 1, which summarizes referendum-level data.

DATA INPUTS: (1) Referendum
OUTPUT: TABLE 1
*********************************/

**Set Globals
global path "C:\Users\ebaron\Google Drive\Dissertation\School_Spending\AEJ_Revision\Replication\"


*****************************************
******SECTION I: CLEAN UP REFERENDUM DATA
*****************************************
*Import referendum-level data
clear
set more off
import excel using "${path}Data\Intermediate\referendum.xls", firstrow

*Begin cleanup of this dataset
*Keep only variables of interest
keep District* VoteDate TotalAmount Type Yes No Result BriefD ActualW

*Get rid of missing data
drop if DistrictName=="" // 7,491 observations deleted

*Generate additional variables needed for the analysis
*Generate percent yes, and total votes
egen total_votes = rowtotal(Yes No)
order total_votes
gen perc_yes = Yes / total_votes
order perc_yes
replace perc_yes = perc_yes*100 //this will be my running variable throughout

*Rename variables of interest
rename District district_code
destring district_code, replace
rename DistrictName district_name
rename VoteDate date

*Sort data
sort district_code date


*Create dummy variable for Recurring, Nonrecurring, and Bond referendum
*To do this, take the first two letters of "Type" after getting rid of white spaces
generate type = subinstr(Type," ","",.) 
order Type type
tab type
replace type = substr(type,1,2)
tab type

*Now create dummies
gen recurring = (type =="RR")
gen nonrecurring = (type=="NR")
gen bond = (type=="Is")
gen operational = (recurring==1|nonrecurring==1)

*Drop bad observations
drop if perc_yes==. //these don't have information on the # of yes or no votes

*Now, I need to create a year and a month variable
gen year = year(date)
gen month = month(date)
order year month

*Create the academic year in which the ref. was voted on
gen yearref = year-1 if month < 7
order yearref
replace yearref=year if yearref==.
label var yearref "School year referendum was held (e.g. 2004-05 equals 2004)"

*Further sample restrictions

*I will only keep referendum from 1996-2014
keep if yearref>=1996&yearref<=2014

*Identify measures where percent, passfail, and req dont all match;
*These are observations where the percent is less than required but 
*somehow pass or viceversa - we don't want these observations
gen mv=perc-50
order mv
gen badobs=(mv>=0 & mv<. & Result=="Failed")
order badobs
replace badobs=1 if mv<0 & Result=="Passed"
replace badobs=1 if mv==.
count if badobs==1 & perc<.
assert r(N)==1
sort badobs //this was a tie and it failed - this makes sense
label var mv "voteshare-based MARGIN of VICTORY"

*Generate "win" variable
gen win = (Result=="Passed")
label var win "Indicator for pass"

*Note that Total Amount is reported in nominal dollars. 
*I am going to need two variables: total requested, and total approved
gen TotalReq = TotalAmount
order TotalReq TotalAmount
gen TotalPassed = TotalAmount if win==1
order TotalPassed

*I am now merging it CPI data. 
rename yearref school_year
merge m:1 school_year using "${path}Data\Intermediate\cpiu"
order cpi

*Observations that did not match are from earlier years not in my dataset
drop if _merge==2

*Convert Total Amounts to 2010 dollars
sort cpi
gen cpi2010 =.
order cpi2010
replace cpi2010=208.046
gen newcpi = cpi/cpi2010
order newcpi
replace TotalPassed = TotalPassed/newcpi //total amount is now in 2010 dollars
replace TotalAmount = TotalAmount/newcpi //total amount is now in 2010 dollars
drop cpi cpi2010 newcpi _merge TotalAmount 

*Furthermore, I'd like to have a measure of Total Amount Per Pupil
*Note that membership data ends in 2016-17, so I interpolated (linearly)
*the amounts for 2017-18 and 2018-19
merge m:1 district_code school_year using "${path}Data\Intermediate\membership_1993_2018"
order membership
drop if _merge==2
drop _merge

*Generate new variables
gen TotalPassed_PP = TotalPassed/membership
gen TotalReq_PP = TotalReq/membership
order Total*
rename school_year yearref

*Now, examine duplicates. Note that it is possible for a school district to
*ask multiple questions during the same DAY. In fact, some pass and some failed
*even without the same day. First, I will drop clear duplicates. These are obs.
*in which the share of votes, date, and type of ref is the same. 
duplicates tag perc_yes district_code date type total, gen(multiple)
edit if multiple!=0
sort district_code date

*Before I drop these duplicates, I must fix the total amount of money they
*are asking for. For instance, Eau Claire Area asked a non-recurring question
*on April 6, 1999. While this is a clear duplicate, the amount of money is broken
*out throughout all of the duplicates. For instance, the WI Public Policy Forum
*reports this as a single question for roughly $8 million, which is the sum.
*See https://wispolicyforum.org/school-referenda-in-wisconsin-spring-2019-election-update/
local z TotalPassed TotalPassed_PP TotalReq TotalReq_PP
foreach var in `z'{
bysort district_code date type mv: egen `var'1 = sum(`var') if multiple!=0
replace `var' = `var'1 if multiple!=0
drop `var'1
}
drop multiple
replace TotalPassed_PP=. if win==0
replace TotalPassed=. if win==0
*Now, I can drop these duplicates
duplicates drop perc_yes district_code date type TotalPassed TotalReq, force //24 observations deleted

*The observations should be identified by:
*District code, year, type, percent yes
isid district_code yearref type perc_yes //yes - this is the particular question

*Label remaining variables
label var TotalPassed "Total Amount Approved (2010 $)" 
label var TotalReq "Total Amount Requested (2010 $)" 

label var TotalPassed_PP "Total Amount Approved PP (2010 $)" 
label var TotalReq_PP "Total Amount Requested PP (2010 $)" 

label var membership "Total Fall Membership"
label var month "Month in Which the Referendum Took Place"
label var year "Fiscal Year in Which the Referendum Took Place"
label var perc_yes "Vote Share in Favor of the Measure"

label var total_votes "Total Number of Votes"
label var operational "Referendum is for Operational Purposes"
label var bond "Bond Referendum"

label var recurring "Referendum is Recurring" 
label var nonrecurring "Referendum is Nonrecurring"
label var ActualWording "Actual Wording of the Ref. Question"
label var BriefDescription "Brief Description of the Ref. Purpose"

*Keep only variables of interesting
drop badobs Type type Yes No Result 


*****************************************
******SECTION II: REF SUM STATS (TABLE 1)
*****************************************
*PANEL (A)
replace recurring =. if bond==1
replace nonrecurring=. if bond==1

eststo clear
estpost tabstat win perc_yes TotalPassed_PP, statistics(n mean median sd min max) columns(statistics)
preserve
bysort district_code: gen num_questions=_N
duplicates drop district_code num_questions, force
sum num_questions, d
restore

*PANEL (B)
eststo clear
estpost tabstat win perc_yes TotalPassed_PP if recurring==1, statistics(n mean median sd min max) columns(statistics)

*PANEL (C)
eststo clear
estpost tabstat win perc_yes TotalPassed_PP if recurring==0, statistics(n mean median sd min max) columns(statistics)

*PANEL (D)
estpost tabstat win perc_yes TotalPassed_PP if bond==1, statistics(n mean median sd min max) columns(statistics)



