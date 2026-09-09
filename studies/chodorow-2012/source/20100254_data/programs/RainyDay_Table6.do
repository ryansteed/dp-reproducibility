/*************************************************************************************************************
RainyDay_Table6
Layout of code is:
1. Declare locals for period over which we are estimating employment change
2. Build dataset (including rainy day data)
3. Scale/Adjust Variables
4. Analysis: Production of Tables
	a. Table 6
*************************************************************************************************************/
version 10.1
clear
set more off
set mem 300m
set matsize 800
cd "$dir"

/*************************************************************************************************************
1. Declare locals
*************************************************************************************************************/

**Set dates for lagged employment
local l_year_0 2008
local l_month_0 5
local l_year_1 2008
local l_month_1 12
local l_period `l_year_0'`l_month_0'_`l_year_1'`l_month_1'

**Set vintage of employment. july20 for old data; june82011 for new data
local vintage june82011

**SA or NSA data?
local adj "SA"

/*************************************************************************************************************
2. Build dataset
*************************************************************************************************************/

*	First, get the instrument
use data/state_medicaid_spending_instrument, replace

*	Now, merge in state population
*		downloaded from Haver, July 20
sort state_abrev
merge state_abrev using data/pop16plus_cleaned, unique
replace pop16plus = pop16plus*1000
tab _merge
drop _merge
rename pop16plus popestimate2008

*	Merge other state controls
sort state_abrev
merge state_abrev using data/state_controls
drop _m
sort state_abrev
*	Note: we rescale GDP so that it is not too large relative to the other variables
rename gdp_2008 gdp_2008_old
gen gdp_2008 = gdp_2008_old/1000000
label variable gdp_2008 "GDP divided by 1,000,000"
drop gdp_2008_old

forvalues i=1/9 {
	qui gen region_`i' = cond(__region_dummies==`i',1,0)
	label variable region_`i' "Region `i'"
}

local regions "region_1 region_2 region_3 region_4 region_5 region_6 region_7 region_8 region_9"

*     Merge in the more recent state budget data on rainy day funds, tax increases, and budget cuts
*DATA ARE IN MILLIONS
sort state_abrev
merge state_abrev using data/StateBudget/statebudgetinfo, unique
assert _merge==3 if state_abrev !="DC"
gen d_rainy2009 = rainyday2009 - rainyday2008
gen d_rainy2010 = rainyday2010 - rainyday2009
gen d_bal2009 = bal2009 - bal2008
gen d_bal2010 = bal2010 - bal2009

label var cut2010spring "FY2010 expenditure cuts from spring 2010 NASBO"
label var cut2010fall "FY2010 expenditure cuts from fall 2009 NASBO"
label var cut2009fall "FY2009 expenditure cuts from fall 2009 NASBO"
label var tax2010fall "FY2010 enacted tax and fee increases from fall 2009 NASBO"
label var exp2010 "FY2010 expenditures preliminary estimate from spring 2010 NASBO"
label var exp2009 "FY2009 actual expenditures from spring 2010 NASBO"
label var exp2008 "FY2008 actual expenditures from fall 2009 NASBO"
label var exp2010r "FY2010 recommended expenditures from spring 2009 NASBO"
label var exp2009a "FY2009 appropriated expenditures from fall 2009 NASBO"
label var rev2010 "FY2010 revenues preliminary estimate from spring 2010 NASBO"
label var rev2009 "FY2009 actual revenues from spring 2010 NASBO"
label var rev2008 "FY2008 actual revenues from fall 2009 NASBO"
label var rev2010r "FY2010 recommended revenues from spring 2009 NASBO"
label var rev2009a "FY2009 appropriated revenues from fall 2009 NASBO"
label var rainyday2009 "FY2009 rainy day fund from spring 2010 NASBO"
label var rainyday2010 "FY2010 rainy day fund from spring 2010 NASBO"
label var rainyday2008 "FY2008 rainy day fun from fall 2009 NASBO"
label var bal2008 "FY2008 end of year balances from fall 2009 NASBO"
label var bal2009 "FY2009 end of year balances from spring 2010 NASBO"
label var bal2010 "FY2010 end of year balances from spring 2010 NASBO"

drop _merge
	
*****	Merge in the state categories of spending
preserve
use data/ARRASpending, clear
keep if date==td(30june2010)
rename  state_acronym state_abrev
drop if state_abrev==""
gen outlays_total = outlaysFMAP + outlaysOther + outlaysSFSF
ren obligationsFMAP oblig_med 
label variable outlays_total "total ARRA outlays as of `spending_date'"
gen medsfsf= outlaysFMAP + outlaysSFSF 
gen paidout = outlaysOther + outlaysSFSF + outlaysFMAP
qui gen fmap = outlaysFMAP
label variable medsfsf "total FMAP + SFSF outlays as of `spending_date'"
foreach s in FM AS MH VI MP GU PR PW N/ [Other] - 14 A {
	drop if state_abrev=="`s'"
	}

sort state_abrev
tempfile arrabystate
save `arrabystate'
restore
sort state_abrev
merge state_abrev using `arrabystate'
assert _merge==3
drop _merge

*	Now merge in the actual and lagged employment change
sort state_abrev
foreach level in totalemp totalgov edhealth education health {
	preserve
	use data/CES/`level'`vintage', replace
	qui drop if state_abrev=="" 
	gen sachange_`level'_lag = 1000*(_`l_year_1'`l_month_1' - _`l_year_0'`l_month_0') 
	qui keep state_abrev  sachange_`level'  sachange_`level'_lag
	tempfile `level'
	qui save ``level''
	restore
	merge state_abrev using ``level'', sort

	qui keep if _merge==3
	drop _merge

}

/*************************************************************************************************************
3. Rescale variables
*************************************************************************************************************/
replace pop_density = pop_density/10000
label variable pop_density "pop density/10000"

gen share_kerry_10000 = share_kerry/10000
label variable share_kerry_10000 "share kerry / 10000"

gen union_share_10000 = union_share/10000
label variable union_share_10000 "union share/ 10000"

gen per_empl_manu_10000 = per_empl_manu/10000
label variable per_empl_manu_10000 "per_empl_manu/10000"

gen popestimate2008_bil = popestimate2008/1000000000
label variable popestimate2008_bil "population estimate 2008 in billions

local control1 ""
local control2 "`regions' share_kerry_10000 union_share_10000 gdp_pc per_empl_manu_10000 popestimate2008_bil"

*	Divides these ones by 100000
foreach var in instrument paidout fmap oblig_med outlaysFMAP medsfsf {
	capture qui gen `var'_pc = `var'/popestimate2008
	capture qui replace `var'_pc = `var'_pc/100000
}

*	Does not divide these by 1000
foreach var of varlist cut* tax* d_rainy* d_bal* {
	capture qui gen `var'_pc = `var'/popestimate2008
}

foreach level in totalemp totalgov edhealth education health {
	gen sachange_`level'_lag_pc = sachange_`level'_lag/popestimate2008
	}

qui gen gdp_pc = 1000000*gdp_2008/popestimate2008

label variable paidout_pc "Total ARRA Payouts per capita ($100k)"
label variable fmap_pc "ARRA FMAP Payouts per capita ($100k)"
label variable oblig_med_pc "ARRA FMAP Obligations per capita($100k)"
label variable instrument_pc "FMAP Instrument (100k)"
label variable per_empl_manu "Employment manufacturing share"
label variable share_kerry "2004 Kerry share"
label variable union_share "Union share"
label variable gdp_pc "GDP per capita divided by 10000"
capture label variable qcew_ch_employ_pc "ch per capita employment, QCEW"

drop if state_abrev =="DC"
replace cut2010spring_pc = 0 if cut2010spring_pc == .
replace cut2010spring_pc = . if state_abrev == "DE"
replace cut2010fall_pc = 0 if cut2010fall_pc == 0
replace cut2010fall_pc = . if (state_abrev=="AL" | state_abrev=="MS" | state_abrev=="NC")

foreach var of varlist d_rainy2010_pc d_rainy2009_pc d_bal* cut2010spring_pc cut2010fall_pc cut2009fall_pc tax2010fall_pc {
gen `var'_100000 = 10*`var'
} 

/*************************************************************************************************************
4. Analysis: TABLE 6
*************************************************************************************************************/

capture estimates drop *

* Rainy day 2009
ivregress 2sls d_rainy2009_pc_100000 (fmap_pc = instrument_pc) if state_abrev!="AK", robust
test fmap_pc==.5
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store rainy_1

ivregress 2sls d_rainy2009_pc_100000 `control2' (fmap_pc = instrument_pc) if state_abrev!="AK", robust
test fmap_pc==.5
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store rainy_2

ivregress 2sls d_rainy2009_pc_100000 `control2' sachange_totalemp_lag_pc (fmap_pc = instrument_pc) if state_abrev!="AK", robust
test fmap_pc==.5
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store rainy_3

* Rainy day 2010

ivregress 2sls d_rainy2010_pc_100000 (fmap_pc = instrument_pc) if state_abrev!="AK", robust
test fmap_pc==.5
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store rainy_4

ivregress 2sls d_rainy2010_pc_100000 `control2' (fmap_pc = instrument_pc) if state_abrev!="AK", robust
test fmap_pc==.5
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store rainy_5

ivregress 2sls d_rainy2010_pc_100000 `control2' sachange_totalemp_lag_pc (fmap_pc = instrument_pc) if state_abrev!="AK", robust
test fmap_pc==.5
sum `e(depvar)' if e(sample)==1, meanonly
estadd scalar mean=`r(mean)'*100000
estimates store rainy_6

estout * using output/table6_rainyday.txt, replace cells(b(star fmt(%9.2f)) se(fmt(%9.2f))) varwidth(30) label varlabel(_cons "Constant") stats(N r2 mean, labels("Observations" "R-squared" "Mean Dep Var")) order(fmap_pc _cons) starlevels(* .10 ** .05 *** .01)

*	Fact checking:
*		When we include Alaska, we cannot reject the null that the coefficient on total FMAP payouts per person is equal to 0 (p-value = 0.265 for changes from 2008 to 2009 and 0.254 for changes from 2009 to 2010).
ivregress 2sls d_rainy2009_pc_100000 (fmap_pc = instrument_pc) , robust
ivregress 2sls d_rainy2010_pc_100000 (fmap_pc = instrument_pc) , robust

