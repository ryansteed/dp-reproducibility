capture log close
log using table1_&_online_appendix_table1_aej, replace text

// Project: Voting Paper
// Task: Summary statistics
// Author and Date: Yiming Li (Paul), 2012-11-13

version 12.1
clear all
macro drop _all
set matsize 2000
set more off

use data/voting_paper_cleaned.dta, clear
xtset fips year

//------------------------------------------------------------------------------
// Summary Stats: Presdential Elections Voter Turnout
//------------------------------------------------------------------------------

// Mean and std. dev.
sum pres_turnout if presobs==1 & (year>=1969 & year<=2000) [aw=nadults]
sum pres_turnout if presobs==1 & (year>=1969 & year<=1990) ///
	& (coalstate==1 | oilstate==1) [aw=nadults]
	
// # elections
egen tagpres = tag(fipsst year) if presobs==1 & (year>=1969 & year<=2000)
count if tagpres==1
count if tagpres==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990)

//------------------------------------------------------------------------------
// Summary Stats: Gubernatorial Elections Voter Turnout
//------------------------------------------------------------------------------

// Mean and std. dev.
sum gov_turnout if govobs==1 & (year>=1969 & year<=2000) [aw=nadults]
sum gov_turnout if govobs==1 & (year>=1969 & year<=1990) ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

	// Presdential years
sum gov_turnout if govobs==1 & (year>=1969 & year<=2000) & presobs==1 [aw=nadults]
sum gov_turnout if govobs==1 & (year>=1969 & year<=1990) & presobs==1 ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

	// non-Presidential years
sum gov_turnout if govobs==1 & (year>=1969 & year<=2000) & presobs==0 [aw=nadults]
sum gov_turnout if govobs==1 & (year>=1969 & year<=1990) & presobs==0 ///
	& (coalstate==1 | oilstate==1) [aw=nadults] 
	
// # elections, and # elections in Pres. years
egen taggov = tag(fipsst year) if govobs==1 & (year>=1969 & year<=2000)
count if taggov==1
scalar numall = r(N)
count if taggov==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990)
scalar numog = r(N)

count if taggov==1 & presobs==1
scalar numallpres = r(N)
count if taggov==1 & presobs==1 & (coalstate==1 | oilstate==1) ///
	& (year>=1969 & year<=1990)
scalar numogpres = r(N)

scalar sharepresall = numallpres / numall
scalar sharepresog = numogpres / numog

scalar list sharepresall sharepresog

//------------------------------------------------------------------------------
// Summary Stats: Senate Elections Voter Turnout
//------------------------------------------------------------------------------

// Mean and std. dev.
sum senate_turnout if senobs==1 & (year>=1969 & year<=2000) [aw=nadults]
sum senate_turnout if senobs==1 & (year>=1969 & year<=1990) ///
	& (coalstate==1 | oilstate==1) [aw=nadults]
	
	// Presdential years
sum senate_turnout if senobs==1 & (year>=1969 & year<=2000) & presobs==1 [aw=nadults]
sum senate_turnout if senobs==1 & (year>=1969 & year<=1990) & presobs==1 ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

	// non-Presidential years
sum senate_turnout if senobs==1 & (year>=1969 & year<=2000) & presobs==0 [aw=nadults]
sum senate_turnout if senobs==1 & (year>=1969 & year<=1990) & presobs==0 ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

// # elections, and # elections in Pres. years
egen tagsenate = tag(fipsst year) if senobs==1 & (year>=1969 & year<=2000)
count if tagsenate==1
count if tagsenate==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990)

count if tagsenate==1 & presobs==1
count if tagsenate==1 & presobs==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990)

//------------------------------------------------------------------------------
// Summary Stats: U.S. House Elections Voter Turnout
//------------------------------------------------------------------------------

sum congr_turnout if congr_turnout!=. & (year>=1969 & year<=2000) [aw=nadults]
sum congr_turnout if congr_turnout!=. & (year>=1969 & year<=1990) ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

	// Presdential years
sum congr_turnout if congr_turnout!=. & (year>=1969 & year<=2000) & presobs==1 [aw=nadults]
sum congr_turnout if congr_turnout!=. & (year>=1969 & year<=1990) & presobs==1 ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

	// non-Presidential years
sum congr_turnout if congr_turnout!=. & (year>=1969 & year<=2000) & presobs==0 [aw=nadults]
sum congr_turnout if congr_turnout!=. & (year>=1969 & year<=1990) & presobs==0 ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

egen tagcongr = tag(fipsst year) if congr_turnout!=. & (year>=1969 & year<=2000)

count if tagcongr==1
count if tagcongr==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990)

count if tagcongr==1 & presobs==1
count if tagcongr==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990) ///
	& presobs==1

//------------------------------------------------------------------------------
// Summary Stats: State House Elections Voter Turnout
//------------------------------------------------------------------------------

sum sthouse_turnout if sthouse_turnout!=. & (year>=1969 & year<=2000) [aw=nadults]
sum sthouse_turnout if sthouse_turnout!=. & (year>=1969 & year<=1990) ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

	// Presdential years
sum sthouse_turnout if sthouse_turnout!=. & (year>=1969 & year<=2000) & presobs==1 [aw=nadults]
sum sthouse_turnout if sthouse_turnout!=. & (year>=1969 & year<=1990) & presobs==1 ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

	// non-Presidential years
sum sthouse_turnout if sthouse_turnout!=. & (year>=1969 & year<=2000) & presobs==0 [aw=nadults]
sum sthouse_turnout if sthouse_turnout!=. & (year>=1969 & year<=1990) & presobs==0 ///
	& (coalstate==1 | oilstate==1) [aw=nadults]

egen tagst = tag(fipsst year) if sthouse_turnout!=. & (year>=1969 & year<=2000)

count if tagst==1 
count if tagst==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990)

count if tagst==1 & presobs==1
count if tagst==1 & (coalstate==1 | oilstate==1) & (year>=1969 & year<=1990) ///
	& presobs==1

log close
