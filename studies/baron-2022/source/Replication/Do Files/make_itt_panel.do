/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file first imports and cleans referendum-level data obtained through
the WDPI. The goal of the do-file is to create a panel where I can implement
the ITT estimator developed by Cellini et al (2010) QJE. Referendum-level
data are from: https://sfs.dpi.wi.gov/Referenda/CustomReporting.aspx?District=0007
In particular, the election-level panel generated in this do-file is used in creating 
Table C1, Table C5, Figure B13, Figure B14, and Figure B15.

DATA INPUTS: (1) referendum, (2) cpiu, (3) membership_1993_2018 (4) Master_Admin_Data
DATA OUTPUTS: (1) itt_panel
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

***Begin cleanup of this dataset
***Keep only variables of interest
keep District* VoteDate TotalAmount Type Yes No Result BriefD ActualW

***Get rid of missing data
drop if DistrictName=="" // 7,491 observations deleted

***Generate additional variables needed for the analysis
***Generate percent yes, and total votes
egen total_votes = rowtotal(Yes No)
order total_votes
gen perc_yes = Yes / total_votes
order perc_yes
replace perc_yes = perc_yes*100 //this will be my running variable throughout

***Rename variables of interest
rename District district_code
destring district_code, replace
rename DistrictName district_name
rename VoteDate date

***Sort data
sort district_code date


***Create dummy variable for Recurring, Nonrecurring, and Bond referendum
***To do this, take the first two letters of "Type" after getting rid of white spaces
generate type = subinstr(Type," ","",.) 
order Type type
tab type
replace type = substr(type,1,2)
tab type

***Now create dummies
gen recurring = (type =="RR")
gen nonrecurring = (type=="NR")
gen bond = (type=="Is")
gen operational = (recurring==1|nonrecurring==1)

***Drop bad observations
drop if perc_yes==. //these don't have information on the # of yes or no votes

***Now, I need to create a year and a month variable
gen year = year(date)
gen month = month(date)
order year month

***Create the academic year in which the ref. was voted on
gen yearref = year-1 if month < 7
order yearref
replace yearref=year if yearref==.
label var yearref "School year referendum was held (e.g. 2004-05 equals 2004)"

***Further sample restrictions

***I will only keep referendum from 1993-94 on
keep if yearref>=1993

***Identify measures where percent, passfail, and req dont all match;
***These are observations where the percent is less than required but 
***somehow pass or viceversa - we don't want these observations
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

***Generate "win" variable
gen win = (Result=="Passed")
label var win "Indicator for pass"

***Note that Total Amount is reported in nominal dollars. 
***I am going to need two variables: total requested, and total approved
gen TotalReq = TotalAmount
order TotalReq TotalAmount
gen TotalPassed = TotalAmount if win==1
order TotalPassed

***I am now merging it CPI data. 
rename yearref school_year
merge m:1 school_year using "${path}Data\Intermediate\cpiu"
order cpi

***Observations that did not match are from earlier years not in my dataset
edit if _merge==2
drop if _merge==2

***Convert Total Amounts to 2010 dollars
sort cpi
gen cpi2010 =.
order cpi2010
replace cpi2010=208.046
gen newcpi = cpi/cpi2010
order newcpi
replace TotalPassed = TotalPassed/newcpi //total amount is now in 2010 dollars
replace TotalReq = TotalReq/newcpi //total amount is now in 2010 dollars
drop cpi cpi2010 newcpi _merge TotalAmount 

***Furthermore, I'd like to have a measure of Total Amount Per Pupil
***Note that membership data ends in 2016-17, so I interpolated (linearly)
***the amounts for 2017-18 and 2018-19
merge m:1 district_code school_year using "${path}Data\Intermediate\membership_1993_2018"
order membership
drop if _merge==2
drop _merge

***Generate new variables
gen TotalPassed_PP = TotalPassed/membership
gen TotalReq_PP = TotalReq/membership
order Total*
rename school_year yearref

***Now, examine duplicates. Note that it is possible for a school district to
***ask multiple questions during the same DAY. In fact, some pass and some failed
***even without the same day. First, I will drop clear duplicates. These are obs.
***in which the share of votes, date, and type of ref is the same. 
duplicates tag perc_yes district_code date type total, gen(multiple)
edit if multiple!=0
sort district_code date

***Before I drop these duplicates, I must fix the total amount of money they
***are asking for. For instance, Eau Claire Area asked a non-recurring question
***on April 6, 1999. While this is a clear duplicate, the amount of money is broken
***out throughout all of the duplicates. For instance, the WI Public Policy Forum
***reports this as a single question for roughly $8 million, which is the sum.
***See https://wispolicyforum.org/school-referenda-in-wisconsin-spring-2019-election-update/
local z TotalPassed TotalPassed_PP TotalReq TotalReq_PP
foreach var in `z'{
bysort district_code date type mv: egen `var'1 = sum(`var') if multiple!=0
replace `var' = `var'1 if multiple!=0
drop `var'1
}
drop multiple
replace TotalPassed_PP=. if win==0
replace TotalPassed=. if win==0

replace TotalReq_PP=. if win==0
replace TotalReq=. if win==0
***Now, I can drop these duplicates
duplicates drop perc_yes district_code date type TotalPassed TotalReq, force //24 observations deleted

***The observations should be identified by:
****District code, year, type, percent yes
isid district_code yearref type perc_yes //yes - this is the particular question

***Label remaining variables
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

***Keep only variables of interesting
drop badobs Type type Yes No Result 

*****************************************
******SECTION II: GET REF DATA READY FOR
******ITT PANEL CREATION
*****************************************
***Now, just as in Cellini et al (2010), I will only keep one referendum measure
***per year (of the same type). For instance, if there are two operational ref.
***in one academic year, I will only keep one for that year. However, a district
***is allowed to have both an op. and a capital exp. during the same year.
***Cellini follow the following criteria in determining which to keep:

  *From Cellini et al (2010)'s code: 
  *If there are multiple measures that meet these criteria, keep winning over 
  *losing measures and then keep only the highest vote share. Break ties by 
  *(1) GO over parcel (2) lowest requirement.;
  
***I will follow a similar definition. However, alternative ways to restrict to 
***one measure such as: gsort district_code yearref -recurring -win -perc 
***yield pretty much identical results

***First, I need to create a unique identifier for district-type of referendum-year.
egen uniqueid = group(district_code yearref bond)
order uniqueid

***Now, keep only one measure per uniqueid
replace mv = abs(mv)
gsort uniqueid -win mv 

***Generate the variable: number of elections that year
bysort uniqueid yearref: gen numelec=_N
order numelec
label var numelec "# same-type elecs in same academic year"

***Keep only one observation per district per year (either op. or bond)
by uniqueid yearref: keep if _n==1

***Form counts of measures per district since 1997 (most of the data start here)
tab yearref
keep if yearref>=1996 & yearref<=2014
bysort district_code: gen measnum =_n
bysort district_code: gen nummeas =_N
order measnum nummeas
tab measnum

***Label these variables
label var measnum "Measure number (chronological) in district"
label var nummeas "Number of measures in district in sample"

***Using isid check whether the variables district code, school year, and type of
***referendum uniquely identify observations. This is a proposal-level dataset.
isid district_code yearref bond 
sort district_code yearref
gen refid =_n //this is the unique identifier for each proposal
order refid

****Keep only variables of interest
keep district_code district_name yearref perc win numelec recurring bond refid 

***Order dataset
order refid district_name district_code yearref perc recurring win bond
rename perc_yes perc

***Generate two distinct tempfiles. The first one is called simply "referenda"
tempfile referenda
save `referenda' //this will later be merged with finance data + four needed
*vars: "op_iswin op_isbond op_ismeas bond_ismeas"

***The second temp file is "referenda_long"***
keep district_code yearref  win bond refid

***Generate variables
gen op_iswin = (win==1&bond==0)
gen bond_iswin = (win==1&bond==1)

***Generate "ismeasure variables"
gen op_ismeas = (bond==0)
gen bond_ismeas = (bond==1)


***Label variables
label var op_ismeas "Is any operational measure on ballot this year?"
label var op_iswin "Did op. measure on ballot win?"

label var bond_ismeas "Is any capital measure on ballot this year?"
label var bond_iswin "Did bond measure on ballot win?"

***Keep only variables of interest
keep district_code yearref op* bond_iswin bond_ismeas refid

***Create full panel out of this dataset
fillin district_code yearref

***Now, these variables should not be missing. They are zeroes for all of the variables
***I kept. 
 foreach v of varlist op* bond_iswin bond_ismeas {
 	replace `v'=0 if _fillin==1
 }
***Drop fillin variable
drop _fillin refid

***Once again, this is not year of referendum, it is school year
rename yearref school_year
collapse (sum) op* bond*, by(district_code school_year)

***Save this as a tempfile
tempfile referenda_long
save `referenda_long'

***Now, start with simple referenda panel and create proposal-level panel
use `referenda'

*Create proposal-level panel
joinby district_code using "${path}Data\Intermediate\Master_Admin_Data_Final", unmatched(none)

***Sort dataset
sort refid school_year

***Generate additional variables needed for ITT analysis
gen op_win = win if bond==0
order op_win
replace op_win=0 if bond==1

gen op_perc = perc if bond==0
order op_perc
replace op_perc=0 if bond==1

gen bond_win = win if bond==1
order bond_win
replace bond_win=0 if bond==0

gen bond_perc = perc if bond==1
order bond_perc
replace bond_perc=0 if bond==0

***Generate number of years elapsed since election (this would be year - yearref)
gen dyear=school_year-yearref
order dyear
tab dyear, m

***Make squared, cubed, etc. vars;
gen op_perc2=op_perc^2
gen op_perc3=op_perc^3

gen bond_perc2=bond_perc^2
gen bond_perc3=bond_perc^3


***Make leads and lags
order dyear
 foreach v in op_perc op_perc2 op_perc3 op_win bond_perc bond_perc2 bond_perc3 bond_win {
 forvalues dy = 1/22{
 gen `v'_m`dy'= `v'*(dyear==-`dy')
 }
 forvalues dy = 0/21 {
 gen `v'_`dy' = `v'*(dyear==`dy')
 }
    }


***Merge this dataset with long referenda file
merge m:1 district_code school_year using `referenda_long'	
drop if _merge==2
drop _merge	
order op_ismeas op_iswin bond_ismeas bond_iswin	
	

	
***Rename to make it easier to exclude year 0 from all analyses
foreach v of varlist op_perc_0 op_perc2_0 op_perc3_0 op_win_0 bond_perc_0 bond_perc2_0 bond_perc3_0 bond_win_0 {
	rename `v' tmp_`v'
	} 
	
	
****Generate year and relative year fixed effects
tab school_year, gen(yrdums)
tab dyear, gen(dydums)  


*Save this dataset
save "${path}Data\Final\itt_panel", replace


