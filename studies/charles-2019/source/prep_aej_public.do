capture log close
log using prep_aej_public, replace text

// Project: Voting Paper
// Task: Clean up the dataset and create new variables for later use
// Author and Date: Yiming Li (Paul), 2012-11-13

version 12.1
clear all
macro drop _all
set more off

use data/voting_paper_extract_public.dta, clear
xtset fips year

//------------------------------------------------------------------------------
// #1
// Generate oil/coal states indicators
//------------------------------------------------------------------------------

// Coal states are: Kentucky, Ohio, Pennsylvania, and West Virginia 
// Oil states are: Colorado, Kansas, Mississippi, Montana, New Mexico
// North Dakota, Oklahoma, Texas, Utah, and Wyoming (we exclude Alaska)

gen fipsst = int(fips / 1000)
gen stateyr = year * 100 + fipsst

egen coalstate = anymatch(fipsst), values(21 39 42 54)
egen oilstate = anymatch(fipsst), values(8 20 28 30 35 38 40 48 49 56)

label values fipsst statenames
label define statenames ///
	1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" ///
	13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" ///
	23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" ///
	32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" 37 "NC" 38 "ND" 39 "OH" 40 "OK" ///
	41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" ///
	51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"

//------------------------------------------------------------------------------
// #2
// Generate indicators for county and state observations
//------------------------------------------------------------------------------

gen cntyobs = mod(fips,1000)!=0
gen stateobs = cntyobs==0
keep if cntyobs==1

//------------------------------------------------------------------------------
// #3
// Drop observations
//------------------------------------------------------------------------------

// In some cases, we drop the entire observation
// In other cases, we use -replace- instead of -drop- to keep the panel balanced

// Drop negative earnings observations
replace earn = . if earn < 0

// Drop year 2000 observation for Loving, TX
for var pres_total senate_total: ///
    replace X = . if year==2000 & fips==48301
	
// Senate: Arkansas - 1990 - Zero Republican votes
//         David Pryor, Democrat, ran unopposed
for var senate_total: ///
    replace X = . if (fips>=5000 & fips<=5999) & year==1990

// Senate: Georgia - 1992 - RUNOFF ELECTION HELD
//         VOTER TURNOUT DROPPED DRAMATICALLY BETWEEN GENERAL AND RUNOFF
for var senate_total: ///
    replace X = . if (fips>=13000 & fips<=13999) & year==1992
	
// Drop observations related to merge, split, and annexation
for num 4027 35061 46071 51800 51770 51944 51918 51941 51909 51911 \ ///
    num 1983 1981 1977 1974 1976 1975 1972 1972 1975 1975 : ///
  replace pres_total = . if fips==X & year<Y \ ///
  replace senate_total = . if fips==X&year<Y \ ///
  replace gov_total = . if fips==X & year<Y \ ///
  replace congr_total = . if fips==X & year<Y \ ///

//------------------------------------------------------------------------------
// #4
// Create new level variables for later use
//------------------------------------------------------------------------------

// Generate Labor Market Outcomes variables
gen per_earn	= earn / pop
gen per_emp		= emp / nadults
gen lper_earn	= ln(per_earn)
gen lper_emp	= ln(per_emp)

// Generate Voter Turnout variables
gen gov_turnout		= gov_total / nadults
gen pres_turnout	= pres_total / nadults
gen senate_turnout	= senate_total / nadults
gen congr_turnout 	= congr_total / nadults
gen sthouse_turnout = state_house_total / nadults

// Generate control variables
gen lpop		= ln(pop)
gen shfemale	= numfemale_adults/nadults
gen shblack		= numblack_adults/nadults
gen shothrace	= numothrace_adults/nadults
gen sh30s		= num30s/nadults
gen sh40s		= num40s/nadults
gen sh50s		= num50s/nadults
gen sh60s		= num60s/nadults
gen sh7080s		= num7080s/nadults

// Generate Oil/Coal Supply Shock variables, using price and employment
gen lognatlnumemp	= ln(ognatlnumemp)
gen lcoalnatlnumemp	= ln(coalnatlnumemp)

gen lrealoilprice = ln(oilprice / cpi)
gen lrealgasprice = ln(gasprice / cpi)
gen lrealcoalprice = ln(coalprice / cpi)

//------------------------------------------------------------------------------
// #5
// Create election indicator variables
//------------------------------------------------------------------------------

// Generate valid election observation indicator
// we use Gubernatorial elections that are four years apart,
// that is, we use an election observation if the next election is four years later.
// we use Senate elections that are six years apart for the same seat.
// we use U.S. House elections that are two years apart.
// we use State House elections that are two years apart.
// We also exclude special elections

gen govobs = year-last_gov_year==4 & gov_turnout!=.
replace govobs = 1 if f4.year-f4.last_gov_year==4 & gov_turnout!=.

// Generate Presidential observation indicator
gen presobs = pres_turnout !=.

// Generate Senate observation indicators for 6-year differences
gen senobs = year-last_senate_year==6 & senate_turnout!=.
replace senobs = 1 if f6.year-f6.last_senate_year==6 & senate_turnout!=.

// Generate U.S. House observation indicator
gen congrobs = congr_turnout!=. & l2.congr_turnout!=.
replace congrobs = 1 if congr_turnout!=. & f2.congr_turnout!=.

gen congr4obs = congr_turnout!=. & l4.congr_turnout!=.
replace congr4obs = 1 if congr_turnout!=. & f4.congr_turnout!=.

// Generate State House election observation indicator
gen sthouseobs = sthouse_turnout!=. & l2.sthouse_turnout!=.
replace sthouseobs = 1 if sthouse_turnout!=. & f2.sthouse_turnout!=.

// create roll-off variables
gen rf_pres_congr	= pres_turnout - congr_turnout if presobs==1 & congr4obs==1
gen rf_pres_gov		= pres_turnout - gov_turnout if presobs==1 & govobs==1
gen rf_pres_sen		= pres_turnout - senate_turnout if presobs==1 & senobs==1
gen rf_pres_st		= pres_turnout - sthouse_turnout if presobs==1 & sthouseobs==1
gen rf_gov_sen		= gov_turnout - senate_turnout if govobs==1 & senobs==1
gen rf_gov_st		= gov_turnout - sthouse_turnout if govobs==1 & sthouseobs==1
gen rf_gov_congr	= gov_turnout - congr_turnout if govobs==1 & congr4obs==1
gen rf_sen_congr	= senate_turnout - congr_turnout if senobs==1 & congr4obs==1
gen rf_sen_st		= senate_turnout - sthouse_turnout if senobs==1 & sthouseobs==1

//------------------------------------------------------------------------------
// #6
// Create "change from last election" differences for different regressions
//------------------------------------------------------------------------------

local change_var ///
	gov_turnout senate_turnout pres_turnout congr_turnout sthouse_turnout ///
	rf_pres_congr rf_pres_gov rf_pres_sen rf_pres_st rf_gov_st rf_sen_st ///
	rf_gov_congr rf_sen_congr rf_gov_sen ///
	lper_earn lper_emp ///
	lpop shfemale shblack shothrace sh30s sh40s sh50s sh60s sh7080s ///
	lognatlnumemp lcoalnatlnumemp lrealoilprice lrealcoalprice ///

foreach i of local change_var {
	gen gov_d_`i' = `i'-l4.`i' if govobs==1 & l4.govobs==1
	gen pres_d_`i' = `i'-l4.`i' if presobs==1 & l4.presobs==1
	gen congr2_d_`i' = `i'-l2.`i' if congrobs==1 & l2.congrobs==1
	gen congr4_d_`i' = `i'-l4.`i' if congr4obs==1 & l4.congr4obs==1
	gen sen6_d_`i' = `i'-l6.`i' if senobs==1 & l6.senobs==1
	gen sen2_d_`i' = `i'-l2.`i' if senobs==1 & l2.senobs==1
	gen sen12_d_`i' = `i'-l12.`i' if senobs==1 & l12.senobs==1
	gen st4_d_`i' = `i' - l4.`i' if sthouseobs==1 & l4.sthouseobs==1
	gen st2_d_`i' = `i' - l2.`i' if sthouseobs==1 & l2.sthouseobs==1
}

//------------------------------------------------------------------------------
// #7
// Generate medium/large indicators for counties, based on 1974 CBP
//------------------------------------------------------------------------------

local ogestsz1974 ogestsz1974_1 ogestsz1974_2 ogestsz1974_3 ogestsz1974_4 ///
	ogestsz1974_5 ogestsz1974_6 ogestsz1974_7 ogestsz1974_8 ogestsz1974_9 ///
	ogestsz1974_10 ogestsz1974_11 ogestsz1974_12
local coalestsz1974 coalestsz1974_1 coalestsz1974_2 coalestsz1974_3 ///
	coalestsz1974_4 coalestsz1974_5	coalestsz1974_6 coalestsz1974_7 ///
	coalestsz1974_8 coalestsz1974_9	coalestsz1974_10 coalestsz1974_11 coalestsz1974_12
local cbpestsz1974 cbpestsz1974_1 cbpestsz1974_2 cbpestsz1974_3 cbpestsz1974_4 ///
	cbpestsz1974_5 cbpestsz1974_6 cbpestsz1974_7 cbpestsz1974_8 cbpestsz1974_9 ///
	cbpestsz1974_10	cbpestsz1974_11 cbpestsz1974_12
local sizemidpnt 2.5 7 14.5 34.5 74.5 174.5 374.5 749.5 ///
	1249.5 1999.5 3749.5 7500

foreach i in "ogestsz1974" "coalestsz1974" "cbpestsz1974" {
	local x = 0
	foreach v of local `i' {
		local x = `x'+1
		local size: word `x' of `sizemidpnt'
		gen temp_`i'_`x' = `v'*`size'
	}
}

order ogestsz1974_* coalestsz1974_* cbpestsz1974_*, seq
egen cbpogemp = rsum(temp_ogestsz1974_1-temp_ogestsz1974_12)
egen cbpcoalemp = rsum(temp_coalestsz1974_1-temp_coalestsz1974_12)
egen cbptotemp = rsum(temp_cbpestsz1974_1-temp_cbpestsz1974_12)

gen cbpogempshare = cbpogemp / cbptotemp
gen cbpcoalempshare = cbpcoalemp / cbptotemp
replace cbpogempshare = 0 if cbpogempshare==.
replace cbpcoalempshare = 0 if cbpcoalempshare==.

foreach i in "og" "coal" {
	gen medium_`i'_1974 = (cbp`i'empshare >= 0.05 & cbp`i'empshare < 0.2)
	gen large_`i'_1974 = (cbp`i'empshare>=0.2)
}

//------------------------------------------------------------------------------
// #8
// Generate medium/large indicators for counties, based on 1967 CBP
//------------------------------------------------------------------------------

gen cbpmineempshare_est1967 = cbpmineemp_est1967 / cbptotemp_est1967
replace cbpmineempshare_est1967 = 0 if cbpmineempshare_est1967==.

gen medium_og_1967 = cbpmineempshare_est1967 >= 0.05 ///
	& cbpmineempshare_est1967 < 0.2 & oilstate==1
gen large_og_1967 = cbpmineempshare_est1967 >= 0.2 & oilstate==1

gen medium_coal_1967 = cbpmineempshare_est1967 >= 0.05 ///
	& cbpmineempshare_est1967 < 0.2 & coalstate==1
gen large_coal_1967 = cbpmineempshare_est1967 >= 0.2 & coalstate==1

//------------------------------------------------------------------------------
// #9
// create IVs
//------------------------------------------------------------------------------

// Employment based IVs
foreach yr in 1974 1967 {
	// for level regressions
	gen level_medium_coal_`yr'_empiv = medium_coal_`yr' * lcoalnatlnumemp
	gen level_large_coal_`yr'_empiv = large_coal_`yr' * lcoalnatlnumemp
	gen level_medium_og_`yr'_empiv = medium_og_`yr' * lognatlnumemp
	gen level_large_og_`yr'_empiv = large_og_`yr' * lognatlnumemp

	// for Gubernatorial elections
	gen gov_d_medium_coal_`yr'_empiv = medium_coal_`yr' * gov_d_lcoalnatlnumemp
	gen gov_d_large_coal_`yr'_empiv = large_coal_`yr' * gov_d_lcoalnatlnumemp
	gen gov_d_medium_og_`yr'_empiv = medium_og_`yr' * gov_d_lognatlnumemp
	gen gov_d_large_og_`yr'_empiv = large_og_`yr' * gov_d_lognatlnumemp
	
	// for Presidential elections
	gen pres_d_medium_coal_`yr'_empiv = medium_coal_`yr' * pres_d_lcoalnatlnumemp
	gen pres_d_large_coal_`yr'_empiv = large_coal_`yr' * pres_d_lcoalnatlnumemp
	gen pres_d_medium_og_`yr'_empiv = medium_og_`yr' * pres_d_lognatlnumemp
	gen pres_d_large_og_`yr'_empiv = large_og_`yr' * pres_d_lognatlnumemp
	
	// for Senate elections 6-yr diffs
	gen sen6_d_medium_coal_`yr'_empiv = medium_coal_`yr' * sen6_d_lcoalnatlnumemp
	gen sen6_d_large_coal_`yr'_empiv = large_coal_`yr' * sen6_d_lcoalnatlnumemp
	gen sen6_d_medium_og_`yr'_empiv = medium_og_`yr' * sen6_d_lognatlnumemp
	gen sen6_d_large_og_`yr'_empiv = large_og_`yr' * sen6_d_lognatlnumemp

	// for Senate elections 2-yr diffs
	gen sen2_d_medium_coal_`yr'_empiv = medium_coal_`yr' * sen2_d_lcoalnatlnumemp
	gen sen2_d_large_coal_`yr'_empiv = large_coal_`yr' * sen2_d_lcoalnatlnumemp
	gen sen2_d_medium_og_`yr'_empiv = medium_og_`yr' * sen2_d_lognatlnumemp
	gen sen2_d_large_og_`yr'_empiv = large_og_`yr' * sen2_d_lognatlnumemp

	// for Senate elections 12-yr diffs
	gen sen12_d_medium_coal_`yr'_empiv = medium_coal_`yr' * sen12_d_lcoalnatlnumemp
	gen sen12_d_large_coal_`yr'_empiv = large_coal_`yr' * sen12_d_lcoalnatlnumemp
	gen sen12_d_medium_og_`yr'_empiv = medium_og_`yr' * sen12_d_lognatlnumemp
	gen sen12_d_large_og_`yr'_empiv = large_og_`yr' * sen12_d_lognatlnumemp

	// for State House elections 4-yr diffs
	gen st4_d_medium_coal_`yr'_empiv = medium_coal_`yr' * st4_d_lcoalnatlnumemp
	gen st4_d_large_coal_`yr'_empiv = large_coal_`yr' * st4_d_lcoalnatlnumemp
	gen st4_d_medium_og_`yr'_empiv = medium_og_`yr' * st4_d_lognatlnumemp
	gen st4_d_large_og_`yr'_empiv = large_og_`yr' * st4_d_lognatlnumemp

	// for State House elections 2-yr diffs
	gen st2_d_medium_coal_`yr'_empiv = medium_coal_`yr' * st2_d_lcoalnatlnumemp
	gen st2_d_large_coal_`yr'_empiv = large_coal_`yr' * st2_d_lcoalnatlnumemp
	gen st2_d_medium_og_`yr'_empiv = medium_og_`yr' * st2_d_lognatlnumemp
	gen st2_d_large_og_`yr'_empiv = large_og_`yr' * st2_d_lognatlnumemp

	// for U.S. House elections 4-yr diffs
	gen congr4_d_medium_coal_`yr'_empiv = medium_coal_`yr' * congr4_d_lcoalnatlnumemp
	gen congr4_d_large_coal_`yr'_empiv = large_coal_`yr' * congr4_d_lcoalnatlnumemp
	gen congr4_d_medium_og_`yr'_empiv = medium_og_`yr' * congr4_d_lognatlnumemp
	gen congr4_d_large_og_`yr'_empiv = large_og_`yr' * congr4_d_lognatlnumemp

	// for U.S. House elections 2-yr diffs
	gen congr2_d_medium_coal_`yr'_empiv = medium_coal_`yr' * congr2_d_lcoalnatlnumemp
	gen congr2_d_large_coal_`yr'_empiv = large_coal_`yr' * congr2_d_lcoalnatlnumemp
	gen congr2_d_medium_og_`yr'_empiv = medium_og_`yr' * congr2_d_lognatlnumemp
	gen congr2_d_large_og_`yr'_empiv = large_og_`yr' * congr2_d_lognatlnumemp
}


// Price based IVs
foreach yr in 1974 1967 {
	// for level regressions
	gen level_medium_coal_`yr'_piv = medium_coal_`yr' * lrealcoalprice
	gen level_large_coal_`yr'_piv = large_coal_`yr' * lrealcoalprice
	gen level_medium_og_`yr'_piv = medium_og_`yr' * lrealoilprice
	gen level_large_og_`yr'_piv = large_og_`yr' * lrealoilprice

	// for Gubernatorial elections
	gen gov_d_medium_coal_`yr'_piv = medium_coal_`yr' * gov_d_lrealcoalprice
	gen gov_d_large_coal_`yr'_piv = large_coal_`yr' * gov_d_lrealcoalprice
	gen gov_d_medium_og_`yr'_piv = medium_og_`yr' * gov_d_lrealoilprice
	gen gov_d_large_og_`yr'_piv = large_og_`yr' * gov_d_lrealoilprice
	
	// for Presidential elections
	gen pres_d_medium_coal_`yr'_piv = medium_coal_`yr' * pres_d_lrealcoalprice
	gen pres_d_large_coal_`yr'_piv = large_coal_`yr' * pres_d_lrealcoalprice
	gen pres_d_medium_og_`yr'_piv = medium_og_`yr' * pres_d_lrealoilprice
	gen pres_d_large_og_`yr'_piv = large_og_`yr' * pres_d_lrealoilprice
	
	// for Senate elections 6-yr diffs
	gen sen6_d_medium_coal_`yr'_piv = medium_coal_`yr' * sen6_d_lrealcoalprice
	gen sen6_d_large_coal_`yr'_piv = large_coal_`yr' * sen6_d_lrealcoalprice
	gen sen6_d_medium_og_`yr'_piv = medium_og_`yr' * sen6_d_lrealoilprice
	gen sen6_d_large_og_`yr'_piv = large_og_`yr' * sen6_d_lrealoilprice

	// for Senate elections 2-yr diffs
	gen sen2_d_medium_coal_`yr'_piv = medium_coal_`yr' * sen2_d_lrealcoalprice
	gen sen2_d_large_coal_`yr'_piv = large_coal_`yr' * sen2_d_lrealcoalprice
	gen sen2_d_medium_og_`yr'_piv = medium_og_`yr' * sen2_d_lrealoilprice
	gen sen2_d_large_og_`yr'_piv = large_og_`yr' * sen2_d_lrealoilprice

	// for Senate elections 12-yr diffs
	gen sen12_d_medium_coal_`yr'_piv = medium_coal_`yr' * sen12_d_lrealcoalprice
	gen sen12_d_large_coal_`yr'_piv = large_coal_`yr' * sen12_d_lrealcoalprice
	gen sen12_d_medium_og_`yr'_piv = medium_og_`yr' * sen12_d_lrealoilprice
	gen sen12_d_large_og_`yr'_piv = large_og_`yr' * sen12_d_lrealoilprice

	// for State House elections 4-yr diffs
	gen st4_d_medium_coal_`yr'_piv = medium_coal_`yr' * st4_d_lrealcoalprice
	gen st4_d_large_coal_`yr'_piv = large_coal_`yr' * st4_d_lrealcoalprice
	gen st4_d_medium_og_`yr'_piv = medium_og_`yr' * st4_d_lrealoilprice
	gen st4_d_large_og_`yr'_piv = large_og_`yr' * st4_d_lrealoilprice

	// for State House elections 2-yr diffs
	gen st2_d_medium_coal_`yr'_piv = medium_coal_`yr' * st2_d_lrealcoalprice
	gen st2_d_large_coal_`yr'_piv = large_coal_`yr' * st2_d_lrealcoalprice
	gen st2_d_medium_og_`yr'_piv = medium_og_`yr' * st2_d_lrealoilprice
	gen st2_d_large_og_`yr'_piv = large_og_`yr' * st2_d_lrealoilprice

	// for U.S. House elections 4-yr diffs
	gen congr4_d_medium_coal_`yr'_piv = medium_coal_`yr' * congr4_d_lrealcoalprice
	gen congr4_d_large_coal_`yr'_piv = large_coal_`yr' * congr4_d_lrealcoalprice
	gen congr4_d_medium_og_`yr'_piv = medium_og_`yr' * congr4_d_lrealoilprice
	gen congr4_d_large_og_`yr'_piv = large_og_`yr' * congr4_d_lrealoilprice

	// for U.S. House elections 2-yr diffs
	gen congr2_d_medium_coal_`yr'_piv = medium_coal_`yr' * congr2_d_lrealcoalprice
	gen congr2_d_large_coal_`yr'_piv = large_coal_`yr' * congr2_d_lrealcoalprice
	gen congr2_d_medium_og_`yr'_piv = medium_og_`yr' * congr2_d_lrealoilprice
	gen congr2_d_large_og_`yr'_piv = large_og_`yr' * congr2_d_lrealoilprice
}

// Continous IVs based on 1974 employment

	// for Presidential elections
	gen pres_d_coal_contiv = cbpcoalempshare * pres_d_lcoalnatlnumemp
	gen pres_d_og_contiv = cbpogempshare * pres_d_lognatlnumemp

	// for Senate elections
	gen sen6_d_coal_contiv = cbpcoalempshare * sen6_d_lcoalnatlnumemp
	gen sen6_d_og_contiv = cbpogempshare * sen6_d_lognatlnumemp

	// for Gubernatorial elections
	gen gov_d_coal_contiv = cbpcoalempshare * gov_d_lcoalnatlnumemp
	gen gov_d_og_contiv = cbpogempshare * gov_d_lognatlnumemp

	// for U.S. House elections
	gen congr4_d_coal_contiv = cbpcoalempshare * congr4_d_lcoalnatlnumemp
	gen congr4_d_og_contiv = cbpogempshare * congr4_d_lognatlnumemp

	// for State House elections
	gen st4_d_coal_contiv = cbpcoalempshare * st4_d_lcoalnatlnumemp
	gen st4_d_og_contiv = cbpogempshare * st4_d_lognatlnumemp

//------------------------------------------------------------------------------
// save dataset
//------------------------------------------------------------------------------
save data/voting_paper_cleaned_public.dta, replace

log close
