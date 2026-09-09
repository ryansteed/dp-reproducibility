/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 11/2/2020

DESCRIPTION:
This do-file first imports and cleans referendum-level data obtained through
the WDPI. The goal of the do-file is to create a panel where I can implement
the one-step estimator developed by Cellini et al (2010) QJE. Referendum-level
data are from: https://sfs.dpi.wi.gov/Referenda/CustomReporting.aspx?District=0007
This particular do-file generates a panel with leads, to show figures of the
TOT effects of referendum approval on outcomes *prior* to and after the election.
In particular, the district-by-year panel generated in this do-file is used in
creating Figure 1, Figure 2, Figure 5, Figure 6 in the main body of the paper
as well as Figure B.5, Figure B.6, Figure B.7, Figure B.8, Figure B.9, Figure B.10, 
Figure B.11, Figure B.12 in the Online Appendix.

DATA INPUTS: (1) referendum, (2) cpiu, (3) membership_1993_2018 (4) Master_Admin_Data
DATA OUTPUTS: (1) onestep_panel_figures
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
*I will only keep referendum from 1993-94 on - this is when rev. limits were enacted
keep if yearref>=1993

*Identify measures where percent, passfail, and req dont all match
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
replace TotalReq = TotalReq/newcpi //total amount is now in 2010 dollars
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

replace TotalReq_PP=. if win==0
replace TotalReq=. if win==0

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

***Keep only variables of interesting
drop badobs Type type Yes No Result 

*****************************************
******SECTION II: GET REF DATA READY FOR
******ONE-STEP PANEL CREATION
*****************************************
*The one-step estimator holds constant the full history of successful 
*(and unsuccessful) referenda. Therefore, I will create this history for each
*type of referendum, and then merge them at the end. This exercise follows
*Cellini et al (2010) QJE very closely.

******************************************************************************
*Start with creating the history of operational referenda.
preserve 
keep if operational==1

*There are 1,213 operational referenda from 1993-2018
*How many individual districts held one?
egen unique = group(district_code) //329 unique school districts attempted at least one

*Generate the variable: number of elections that year
bysort district_code yearref: gen numelec=_N
order numelec
label var numelec "# of NR/RR elecs in same year"

*(A) Now, just as in Cellini et al (2010), I will only keep one referendum measure
*per year. Cellini follow the following criteria in determining which to keep:

  *From Cellini et al (2010)'s code: 
  *If there are multiple measures that meet these criteria, keep winning over losing measures
  *and then keep only the highest vote share.  Break ties by (1) GO over parcel (2) lowest requirement.;
  
*I will follow a similar definition. However, alternative ways to restrict to one measure such as:
*gsort district_code yearref -recurring -win -perc - yield pretty much identical results
*gsort district_code yearref -win -perc -recurring 
*gsort district_code yearref -win -perc

*If a school district has more than one question on the ballot during an academic year,
*I keep winning over losing measures and keep the ones with the smallest margin 
*of victory around the cutoff. The intuition is to try to maximize the number of
*observations near the cutoff. However, this restriction turns out not to matter
*for the main results of the paper.
replace mv = abs(mv)
gsort district_code yearref -win mv

*Keep only one observation per district per year
by district_code yearref: keep if _n==1

*Form counts of measures per district 
tab yearref
sort district_code yearref
keep if yearref>=1996 & yearref<=2014 // main sample period in the study
bysort district_code: gen measnum =_n
bysort district_code: gen nummeas =_N
order measnum nummeas
tab measnum

*Generate local that captures maximum number of measures per district
  sum measnum, meanonly
  local maxnmeas=r(max)
  
  
*Label these variables
label var measnum "Measure number (chronological) in district"
label var nummeas "Number of measures in district in sample"


*Keep only relevant variables
keep yearref perc_yes district_code recurring numelec ///
measnum nummeas district_name win total_votes month
tab numelec //85% of school districts only had one election p/y - 15% had more than one


*(B) Generate a tempfile "referenda_wide"
tempfile referenda referenda_wide
sort district_code yearref

***Label remaining variables
label var perc_yes "Share of Votes in Favor of the Measure"
label var total_votes "Total Voter Turnout"

***Save tempfiles
save `referenda'

***Reshape
rename perc_yes percent

**Rename other variables
rename (win percent numelec total_votes month) ///
(op_win op_percent op_numelec op_totalvotes op_month) 

reshape wide yearref op_win op_percent op_numelec op_totalvotes op_month ///
recurring, i(district_code) j(measnum) 

sort district_code

order district_name

***Save tempfile
save `referenda_wide'


*(C) Generate another tempfile, this one called "refstodate"
use `referenda'
gen meastodate = measnum
order meastodate //number of measures to date
by district_code (yearref): gen winstodate = sum(win)
order winstodate //number of wins to date
keep district_code yearref meastodate winstodate
fillin district_code yearref
sort district_code yearref

*Missing values should be zero
by district_code: replace meastodate=0 if _n==1 & _fillin
by district_code: replace winstodate=0 if _n==1 & _fillin
by district_code: replace meastodate=meastodate[_n-1] if meastodate==.
by district_code: replace winstodate=winstodate[_n-1] if winstodate==.
drop _fillin
sort district_code yearref
rename yearref school_year
tempfile refs2date
save `refs2date'


*(D) Make leads and lags of the referenda variables to create history of op. ref.
use "${path}Data\Intermediate\Master_Admin_Data_Final"

*Sort
sort district_code school_year
egen num_unique = group(district_code)
order num_unique
sum num_unique //421 school districts

*Merge to measures to date variable
merge 1:1 district_code school_year using `refs2date'
order meastodate winstodate
sort district_code school_year

 by district_code: replace meastodate=0 if _merge==1 & _n==1
 by district_code: replace winstodate=0 if _merge==1 & _n==1
 by district_code: replace meastodate=meastodate[_n-1] if _merge==1 & _n>1
 by district_code: replace winstodate=winstodate[_n-1] if _merge==1 & _n>1
 drop _merge num_unique
 sort district_code school_year

 *Merge with district-level history
 merge m:1 district_code using `referenda_wide'
 tab _merge
 
 *Drop districts that never had referenda
 edit if _merge==1
 keep if _merge==3
rename school_year year
keep if year>=1996 & year<=2014

 
*Make leads and lags
  *Finance data run from 1996 to 2014, and measures from 1996-2014.
  *Generate 18 lags
   foreach v in op_ismeas op_percent op_win op_numelec op_totalvotes recurring op_month {
    forvalues d=0/18 {
    	gen `v'_prev`d'=0
    }
	forvalues d=1/2 {
    	gen `v'_fut`d'=0
    }
   }

   ***Generate relative year to each measure
   ***This loop basically create historical wins by each measure
  forvalues m=1/`maxnmeas' {
  	gen dyear`m'=year-yearref`m'
  	forvalues d=0/18 {
  		replace op_ismeas_prev`d'=1 if dyear`m'==`d'
      foreach v in op_percent op_win op_numelec op_totalvotes recurring op_month {
  		 replace `v'_prev`d'=`v'`m' if dyear`m'==`d'
  		}
  	}
	forvalues d=1/2 {
  	replace op_ismeas_fut`d'=1 if dyear`m'==-`d'
      foreach v in op_percent op_win op_numelec op_totalvotes recurring op_month {
  		 replace `v'_fut`d'=`v'`m' if dyear`m'==-`d'
  		}
  	}
	
	
  	drop op_percent`m' op_win`m' op_numelec`m' op_totalvotes`m' recurring`m' dyear`m' op_month`m' yearref`m'
  }
 
 
*Make squared, cubed, etc. vars
 forvalues d=0/18 {
 	gen op_percent2_prev`d'=op_percent_prev`d'^2
 	gen op_percent3_prev`d'=op_percent_prev`d'^3
 }
 
forvalues d=1/2 {
	 	gen op_percent2_fut`d'=op_percent_fut`d'^2
 	gen op_percent3_fut`d'=op_percent_fut`d'^3
}
 
 *Rename initial values
 foreach v of varlist *_prev0 {
   rename `v' tmp_`v'
  }
  
*This is the operational referenda sample - save as a tempfile
tempfile operational_sample
drop _merge
save `operational_sample'
restore 
 
******************************************************************************
*Now, Create history of bond referenda
keep if bond==1

*There are 1,862 operational referenda from 1993-2018
*How many individual districts held one?
egen unique = group(district_code) //402 unique school districts attempted at least one

*Generate the variable: number of elections that year
bysort district_code yearref: gen numelec=_N
order numelec
label var numelec "# of NR/RR elecs in same year"

*(A) Now, just as in Cellini et al (2010), I will only keep one referendum measure
*per year. Cellini follow the following criteria in determining which to keep:

  *From Cellini et al (2010)'s code: 
  *If there are multiple measures that meet these criteria, keep winning over losing measures
  *and then keep only the highest vote share.  Break ties by (1) GO over parcel (2) lowest requirement.;
  
*I will follow a similar definition. However, alternative ways to restrict to one measure such as:
*gsort district_code yearref -recurring -win -perc - yield pretty much identical results
*gsort district_code yearref -win -perc -recurring 
*gsort district_code yearref -win -perc

*If a school district has more than one question on the ballot during an academic year,
*I keep winning over losing measures and keep the ones with the smallest margin 
*of victory around the cutoff
replace mv = abs(mv)
gsort district_code yearref -win mv

*Keep only one observation per district per year
by district_code yearref: keep if _n==1

*Form counts of measures per district 
tab yearref
sort district_code yearref
keep if yearref>=1996 & yearref<=2014
bysort district_code: gen measnum =_n
bysort district_code: gen nummeas =_N
order measnum nummeas
tab measnum

*Generate local that captures maximum number of measures per district
  sum measnum, meanonly
  local maxnmeas=r(max)
   
*Label these variables
label var measnum "Measure number (chronological) in district"
label var nummeas "Number of measures in district in sample"

*Keep only relevant variables
keep yearref perc_yes district_code recurring numelec ///
measnum nummeas district_name win total_votes month
tab numelec //75% of school districts only had one election p/y - 25% had more than one

*(B) Generate a tempfile "referenda_wide"
tempfile referenda referenda_wide
sort district_code yearref

*Label remaining variables
label var perc_yes "Share of Votes in Favor of the Measure"
label var total_votes "Total Voter Turnout"

*Save tempfiles
save `referenda'

*Reshape
rename perc_yes percent

*Rename other variables
rename (win percent numelec total_votes month) ///
(bond_win bond_percent bond_numelec bond_totalvotes bond_month) 

reshape wide yearref bond_win bond_percent bond_numelec bond_totalvotes bond_month ///
recurring, i(district_code) j(measnum) 

sort district_code

order district_name

*Save tempfile
save `referenda_wide'


*(C) Generate another tempfile, this one called "refstodate"
use `referenda'
gen meastodate = measnum
order meastodate //number of measures to date
by district_code (yearref): gen winstodate = sum(win)
order winstodate //number of wins to date
keep district_code yearref meastodate winstodate
fillin district_code yearref
sort district_code yearref

*Missing values should be zero
by district_code: replace meastodate=0 if _n==1 & _fillin
by district_code: replace winstodate=0 if _n==1 & _fillin
by district_code: replace meastodate=meastodate[_n-1] if meastodate==.
by district_code: replace winstodate=winstodate[_n-1] if winstodate==.
drop _fillin
sort district_code yearref
rename yearref school_year
tempfile refs2date
save `refs2date'


*(D) Make leads and lags of the referenda variables to create history of op. ref.
use "${path}Data\Intermediate\Master_Admin_Data_Final"

*Sort
sort district_code school_year
egen num_unique = group(district_code)
order num_unique
sum num_unique //421 school districts

*Merge to measures to date variable
merge 1:1 district_code school_year using `refs2date'
order meastodate winstodate
sort district_code school_year

 by district_code: replace meastodate=0 if _merge==1 & _n==1
 by district_code: replace winstodate=0 if _merge==1 & _n==1
 by district_code: replace meastodate=meastodate[_n-1] if _merge==1 & _n>1
 by district_code: replace winstodate=winstodate[_n-1] if _merge==1 & _n>1
 drop _merge num_unique
 sort district_code school_year

 *Merge with district-level history
 merge m:1 district_code using `referenda_wide'
 tab _merge
 
 *Drop districts that never had referenda
 edit if _merge==1
 keep if _merge==3
rename school_year year
keep if year>=1996 & year<=2014

*Make leads and lags
  *Finance data run from 1996 to 2014, and measures from 1996-2014.
  *Generate 18 lags
   foreach v in bond_ismeas bond_percent bond_win bond_numelec bond_totalvotes recurring bond_month {
    forvalues d=0/18 {
    	gen `v'_prev`d'=0
    }
	forvalues d=1/2 {
    	gen `v'_fut`d'=0
    }
   }

   ***Generate relative year to each measure
   ***This loop basically create historical wins by each measure
  forvalues m=1/`maxnmeas' {
  	gen dyear`m'=year-yearref`m'
  	forvalues d=0/18 {
  		replace bond_ismeas_prev`d'=1 if dyear`m'==`d'
      foreach v in bond_percent bond_win bond_numelec bond_totalvotes recurring bond_month {
  		 replace `v'_prev`d'=`v'`m' if dyear`m'==`d'
  		}
  	}
	forvalues d=1/2 {
  		replace bond_ismeas_fut`d'=1 if dyear`m'==-`d'
      foreach v in bond_percent bond_win bond_numelec bond_totalvotes recurring bond_month {
  		 replace `v'_fut`d'=`v'`m' if dyear`m'==-`d'
  		}
  	}
	
  	drop bond_percent`m' bond_win`m' bond_numelec`m' bond_totalvotes`m' recurring`m' dyear`m' bond_month`m' yearref`m'
  }
 
 
*Make squared, cubed, etc. vars
 forvalues d=0/18 {
 	gen bond_percent2_prev`d'=bond_percent_prev`d'^2
 	gen bond_percent3_prev`d'=bond_percent_prev`d'^3
 }
 
 forvalues d=1/2 {
	gen bond_percent2_fut`d'=bond_percent_fut`d'^2
 	gen bond_percent3_fut`d'=bond_percent_fut`d'^3
}
 
 *Rename initial values
 foreach v of varlist *_prev0 {
   rename `v' tmp_`v'
  }

  
*****************************************
******SECTION III: MERGE OPERATIONAL AND 
******BOND REFERENDA HISTORIES AND SAVE
******FINAL PANEL
*****************************************
***This is the bond referenda sample - merge with operational referenda history
drop _merge
merge 1:1 district_code year using `operational_sample'

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         2,242
        from master                     1,710  (_merge==1)
        from using                        532  (_merge==2)

    matched                             5,434  (_merge==3)
    -----------------------------------------
*/
bysort district_code: gen nobs=_N
order nobs
*There are 19 observations per district. Thus, this means the following:
*286 school districts proposed both an op. and a bond referendum
*90 school districts proposed a bond ref. but not an op. referendum
*28 school districts proposed an op. referendum but not a bond referendum

*Generate variables indicating this information
gen tried_only_bond=(_merge==1)
gen tried_only_op = (_merge==2)
gen tried_both = (_merge==3)
drop _merge

*Sort dataset
sort district_code year

*Now, replace missing values with zeros for bond variables in obs with only op. measures
local z tmp_bond_ismeas_prev0 bond_ismeas_prev1 bond_ismeas_prev2 bond_ismeas_prev3 ///
bond_ismeas_prev4 bond_ismeas_prev5 bond_ismeas_prev6 bond_ismeas_prev7 bond_ismeas_prev8 ///
bond_ismeas_prev9 bond_ismeas_prev10 bond_ismeas_prev11 bond_ismeas_prev12 bond_ismeas_prev13 ///
bond_ismeas_prev14 bond_ismeas_prev15 bond_ismeas_prev16 bond_ismeas_prev17 bond_ismeas_prev18 ///
tmp_bond_percent_prev0 bond_percent_prev1 bond_percent_prev2 bond_percent_prev3 bond_percent_prev4 ///
bond_percent_prev5 bond_percent_prev6 bond_percent_prev7 bond_percent_prev8 bond_percent_prev9 ///
bond_percent_prev10 bond_percent_prev11 bond_percent_prev12 bond_percent_prev13 bond_percent_prev14 ///
bond_percent_prev15 bond_percent_prev16 bond_percent_prev17 bond_percent_prev18 tmp_bond_win_prev0 ///
bond_win_prev1 bond_win_prev2 bond_win_prev3 bond_win_prev4 bond_win_prev5 bond_win_prev6 bond_win_prev7 ///
bond_win_prev8 bond_win_prev9 bond_win_prev10 bond_win_prev11 bond_win_prev12 bond_win_prev13 ///
bond_win_prev14 bond_win_prev15 bond_win_prev16 bond_win_prev17 bond_win_prev18 ///
tmp_bond_numelec_prev0 bond_numelec_prev1 bond_numelec_prev2 bond_numelec_prev3 ///
bond_numelec_prev4 bond_numelec_prev5 bond_numelec_prev6 bond_numelec_prev7 ///
bond_numelec_prev8 bond_numelec_prev9 bond_numelec_prev10 bond_numelec_prev11 ///
bond_numelec_prev12 bond_numelec_prev13 bond_numelec_prev14 bond_numelec_prev15 ///
bond_numelec_prev16 bond_numelec_prev17 bond_numelec_prev18 tmp_bond_totalvotes_prev0 ///
bond_totalvotes_prev1 bond_totalvotes_prev2 bond_totalvotes_prev3 bond_totalvotes_prev4 ///
bond_totalvotes_prev5 bond_totalvotes_prev6 bond_totalvotes_prev7 bond_totalvotes_prev8 ///
bond_totalvotes_prev9 bond_totalvotes_prev10 bond_totalvotes_prev11 bond_totalvotes_prev12 ///
bond_totalvotes_prev13 bond_totalvotes_prev14 bond_totalvotes_prev15 bond_totalvotes_prev16 ///
bond_totalvotes_prev17 bond_totalvotes_prev18 tmp_bond_month_prev0 bond_month_prev1 ///
bond_month_prev2 bond_month_prev3 bond_month_prev4 bond_month_prev5 bond_month_prev6 ///
bond_month_prev7 bond_month_prev8 bond_month_prev9 bond_month_prev10 bond_month_prev11 ///
bond_month_prev12 bond_month_prev13 bond_month_prev14 bond_month_prev15 bond_month_prev16 ///
bond_month_prev17 bond_month_prev18 tmp_bond_percent2_prev0 tmp_bond_percent3_prev0 ///
bond_percent2_prev1 bond_percent3_prev1 bond_percent2_prev2 bond_percent3_prev2 ///
bond_percent2_prev3 bond_percent3_prev3 bond_percent2_prev4 bond_percent3_prev4 ///
bond_percent2_prev5 bond_percent3_prev5 bond_percent2_prev6 bond_percent3_prev6 ///
bond_percent2_prev7 bond_percent3_prev7 bond_percent2_prev8 bond_percent3_prev8 ///
bond_percent2_prev9 bond_percent3_prev9 bond_percent2_prev10 bond_percent3_prev10 ////
bond_percent2_prev11 bond_percent3_prev11 bond_percent2_prev12 bond_percent3_prev12 ///
bond_percent2_prev13 bond_percent3_prev13 bond_percent2_prev14 bond_percent3_prev14 ///
bond_percent2_prev15 bond_percent3_prev15 bond_percent2_prev16 bond_percent3_prev16 ///
bond_percent2_prev17 bond_percent3_prev17 bond_percent2_prev18 bond_percent3_prev18 ///
bond_ismeas_fut1 bond_ismeas_fut2 bond_percent_fut1 bond_percent_fut2 bond_win_fut1 ///
bond_win_fut2 bond_numelec_fut1 bond_numelec_fut2 bond_totalvotes_fut1 bond_totalvotes_fut2 bond_month_fut2 ///
bond_month_fut1 bond_percent2_fut1 bond_percent2_fut2 bond_percent3_fut1 bond_percent3_fut2

foreach var in `z'{
    replace `var'=0 if `var'==. & tried_only_op==1
}


***Now, replace missing values with zeros for op. variables in only bond measures
local y tmp_op_ismeas_prev0 op_ismeas_prev1 op_ismeas_prev2 op_ismeas_prev3 ///
op_ismeas_prev4 op_ismeas_prev5 op_ismeas_prev6 op_ismeas_prev7 op_ismeas_prev8 ///
op_ismeas_prev9 op_ismeas_prev10 op_ismeas_prev11 op_ismeas_prev12 op_ismeas_prev13 ///
op_ismeas_prev14 op_ismeas_prev15 op_ismeas_prev16 op_ismeas_prev17 op_ismeas_prev18 ///
tmp_op_percent_prev0 op_percent_prev1 op_percent_prev2 op_percent_prev3 op_percent_prev4 ///
op_percent_prev5 op_percent_prev6 op_percent_prev7 op_percent_prev8 op_percent_prev9 ///
op_percent_prev10 op_percent_prev11 op_percent_prev12 op_percent_prev13 op_percent_prev14 ///
op_percent_prev15 op_percent_prev16 op_percent_prev17 op_percent_prev18 tmp_op_win_prev0 ///
op_win_prev1 op_win_prev2 op_win_prev3 op_win_prev4 op_win_prev5 op_win_prev6 op_win_prev7 ///
op_win_prev8 op_win_prev9 op_win_prev10 op_win_prev11 op_win_prev12 op_win_prev13 ///
op_win_prev14 op_win_prev15 op_win_prev16 op_win_prev17 op_win_prev18 ///
tmp_op_numelec_prev0 op_numelec_prev1 op_numelec_prev2 op_numelec_prev3 ///
op_numelec_prev4 op_numelec_prev5 op_numelec_prev6 op_numelec_prev7 ///
op_numelec_prev8 op_numelec_prev9 op_numelec_prev10 op_numelec_prev11 ///
op_numelec_prev12 op_numelec_prev13 op_numelec_prev14 op_numelec_prev15 ///
op_numelec_prev16 op_numelec_prev17 op_numelec_prev18 tmp_op_totalvotes_prev0 ///
op_totalvotes_prev1 op_totalvotes_prev2 op_totalvotes_prev3 op_totalvotes_prev4 ///
op_totalvotes_prev5 op_totalvotes_prev6 op_totalvotes_prev7 op_totalvotes_prev8 ///
op_totalvotes_prev9 op_totalvotes_prev10 op_totalvotes_prev11 op_totalvotes_prev12 ///
op_totalvotes_prev13 op_totalvotes_prev14 op_totalvotes_prev15 op_totalvotes_prev16 ///
op_totalvotes_prev17 op_totalvotes_prev18 tmp_op_month_prev0 op_month_prev1 ///
op_month_prev2 op_month_prev3 op_month_prev4 op_month_prev5 op_month_prev6 ///
op_month_prev7 op_month_prev8 op_month_prev9 op_month_prev10 op_month_prev11 ///
op_month_prev12 op_month_prev13 op_month_prev14 op_month_prev15 op_month_prev16 ///
op_month_prev17 op_month_prev18 tmp_op_percent2_prev0 tmp_op_percent3_prev0 ///
op_percent2_prev1 op_percent3_prev1 op_percent2_prev2 op_percent3_prev2 ///
op_percent2_prev3 op_percent3_prev3 op_percent2_prev4 op_percent3_prev4 ///
op_percent2_prev5 op_percent3_prev5 op_percent2_prev6 op_percent3_prev6 ///
op_percent2_prev7 op_percent3_prev7 op_percent2_prev8 op_percent3_prev8 ///
op_percent2_prev9 op_percent3_prev9 op_percent2_prev10 op_percent3_prev10 ////
op_percent2_prev11 op_percent3_prev11 op_percent2_prev12 op_percent3_prev12 ///
op_percent2_prev13 op_percent3_prev13 op_percent2_prev14 op_percent3_prev14 ///
op_percent2_prev15 op_percent3_prev15 op_percent2_prev16 op_percent3_prev16 ///
op_percent2_prev17 op_percent3_prev17 op_percent2_prev18 op_percent3_prev18 ///
tmp_recurring_prev0 recurring_prev1 recurring_prev2 recurring_prev3 recurring_prev4 ///
recurring_prev5 recurring_prev6 recurring_prev7 recurring_prev8 recurring_prev9 ///
recurring_prev10 recurring_prev11 recurring_prev12 recurring_prev13 recurring_prev14 ///
recurring_prev15 recurring_prev16 recurring_prev17 recurring_prev18 ///
op_ismeas_fut1 op_ismeas_fut2 op_percent_fut2 op_percent_fut1 op_win_fut2 op_win_fut1 ///
op_numelec_fut2 op_numelec_fut1 op_totalvotes_fut1 op_totalvotes_fut2 op_month_fut1 op_month_fut2 ///
op_month_fut1 op_percent2_fut1 op_percent2_fut2 op_percent3_fut1 op_percent3_fut2

foreach var in `y'{
    replace `var'=0 if `var'==. & tried_only_bond==1
}


*Generate year dummy variables
tab year, gen(yrdums)

**Generate indicators if the district passed both at some point during the sample period
bysort district_code: egen everwinbond = max(tmp_bond_win_prev0)
bysort district_code: egen everwinop = max(tmp_op_win_prev0)
gen passed_both = (everwinop==1&everwinbond==1)

*Generate interaction terms
gen tmp_interaction_prev0 = tmp_bond_win_prev0*tmp_op_win_prev0
gen interaction_prev1 = bond_win_prev1*op_win_prev1
gen interaction_prev2 = bond_win_prev2*op_win_prev2
gen interaction_prev3 = bond_win_prev3*op_win_prev3
gen interaction_prev4 = bond_win_prev4*op_win_prev4
gen interaction_prev5 = bond_win_prev5*op_win_prev5
gen interaction_prev6 = bond_win_prev6*op_win_prev6
gen interaction_prev7 = bond_win_prev7*op_win_prev7
gen interaction_prev8 = bond_win_prev8*op_win_prev8
gen interaction_prev9 = bond_win_prev9*op_win_prev9
gen interaction_prev10 = bond_win_prev10*op_win_prev10
gen interaction_prev11= bond_win_prev11*op_win_prev11
gen interaction_prev12 = bond_win_prev12*op_win_prev12
gen interaction_prev13 = bond_win_prev13*op_win_prev13
gen interaction_prev14 = bond_win_prev14*op_win_prev14
gen interaction_prev15 = bond_win_prev15*op_win_prev15
gen interaction_prev16 = bond_win_prev16*op_win_prev16
gen interaction_prev17 = bond_win_prev17*op_win_prev17
gen interaction_prev18 = bond_win_prev18*op_win_prev18


*Keep only variables of interest, examine summary statistics, and label all vars
drop nobs meastodate winstodate leaid 

***Save this dataset
save "${path}Data\Final\onestep_panel_figures", replace
 

 




















