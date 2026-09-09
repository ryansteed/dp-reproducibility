capture log close
log using appendix_table1_aej, replace text

// Project: voting paper
// Task: top mining states by employment shares
// Author and Date: Yiming Li (Paul), 2012-11-12

version 12.1
clear all
macro drop _all
set more off

use "data/voting_paper_extract.dta", clear
xtset fips year

gen fipsst = int(fips / 1000)
gen cntyobs = mod(fips, 1000)!=0

label values fipsst statenames
label define statenames ///
	1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" ///
	13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" ///
	23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" ///
	32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" 37 "NC" 38 "ND" 39 "OH" 40 "OK" ///
	41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" ///
	51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"

keep if cntyobs==0

//------------------------------------------------------------------------------
// percent of 1974 CBP employment from mining
//------------------------------------------------------------------------------

gen mineempsh1974cbp = minenumemp / cbpnumemp

//------------------------------------------------------------------------------
// 1974 CBP share of mining establishments found in oil and coal industries
//------------------------------------------------------------------------------

gen ogestsh1974cbp = ognumest / minenumest
gen coalestsh1974cbp = coalnumest / minenumest

//------------------------------------------------------------------------------
// list the results
//------------------------------------------------------------------------------

gsort -mineempsh1974cbp
list fipsst mineempsh1974cbp ogestsh1974cbp coalestsh1974cbp

log close
