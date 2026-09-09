* Appendix Figure A2

* this do-file creates a figure of net school openings/closures
* dataset: cps_schools_2007_2017.dta
* source of raw data is CPS shape files

clear

********************************************************************************
** Part 1: Create SchoolID-UnitID Crosswalk
********************************************************************************
use "$datasets/cps_schools_2007_2017.dta", clear

keep school_id unit_id
drop if school_id==""
drop if unit_id==""

duplicates drop

tempfile school_unit
save "`school_unit'"

* Make Crosswalk with School_ID as Link
use "`school_unit'", clear
rename unit_id unit_id_merge
tempfile school_unit_schoolidlink
save "`school_unit_schoolidlink'"

* Make Crosswalk with Unit_ID as Link
use "`school_unit'", clear
rename school_id school_id_merge
tempfile school_unit_unitidlink
save "`school_unit_unitidlink'"

********************************************************************************
** Part 2: Use Crosswalk to Populate IDs for Missing Years
********************************************************************************
use "$datasets/cps_schools_2007_2017.dta", clear

merge m:n school_id using "`school_unit_schoolidlink'"
tab _merge
drop _merge

merge m:n unit_id using "`school_unit_unitidlink'"
tab _merge
drop _merge

gen unitid=unit_id
replace unitid=unit_id_merge if unitid==""

gen schoolid=school_id
replace schoolid=school_id_merge if schoolid==""

********************************************************************************
** Part 3: Generate Group Variable for Schools Without SchoolID-UnitID Linkage
********************************************************************************

egen id = group(schoolid unitid), missing

bysort id year: gen count=_N

duplicates tag id year, gen(dup)

list school_nm sch_addr year unit_id school_id if dup==1
drop dup

* there are 46 duplicates (23 unique schools) *
* all have the same addresses *

duplicates drop id year, force


********************************************************************************
** Part 4: Create Figure: School Openings/Closings 
********************************************************************************

isid id year

tab year

fillin id year

gen indata=(_fillin==0)
sort id year

by id: gen indata_lag = indata[_n-1]
replace indata_lag = . if year==2007

* continuous
gen cts = (indata==1 & indata_lag==1)

* close
gen close = (indata==0 & indata_lag==1)

* open
gen open = (indata==1 & indata_lag==0)

* not in
gen notin = (indata==0 & indata_lag==0)


gen status = ""
replace status="cts" if cts==1
replace status="open" if open==1
replace status="close" if close==1
replace status="notin" if notin==1

tab year status


********************************************************************************
** Part 5: Openings/Closures by Type
********************************************************************************


* make small dataset of ids and school names
preserve

collapse (firstnm) school_nm, by(id)
isid id
rename school_nm school_name

tempfile schoolnames
save "`schoolnames'"

restore

merge m:1 id using "`schoolnames'"
tab _merge
keep if _merge==3
drop _merge

* try to create charter indicator based on sch_type and name (text)

gen charter_contract = .

replace charter_contract = 1 if sch_type=="Charter"
replace charter_contract = 1 if sch_type=="Alternative/Charter"
replace charter_contract = 1 if sch_type=="Contract"
replace charter_contract = 1 if sch_type=="Alternative/Contract"
replace charter_contract = 0 if charter_contract==.

egen charter_contract_max = max(charter_contract), by(id)
	drop charter_contract
	rename charter_contract_max charter_contract

* school openings
list school_name if year==2008 & status=="open"
list school_name if year==2009 & status=="open"
list school_name if year==2010 & status=="open"
list school_name if year==2011 & status=="open"
list school_name if year==2012 & status=="open"
list school_name if year==2013 & status=="open"
list school_name if year==2014 & status=="open"
list school_name if year==2015 & status=="open"
list school_name if year==2016 & status=="open"
list school_name if year==2017 & status=="open"

* school closings
list school_name if year==2008 & status=="close"
list school_name if year==2009 & status=="close"
list school_name if year==2010 & status=="close"
list school_name if year==2011 & status=="close"
list school_name if year==2012 & status=="close"
list school_name if year==2013 & status=="close"
list school_name if year==2014 & status=="close"
list school_name if year==2015 & status=="close"
list school_name if year==2016 & status=="close"
list school_name if year==2017 & status=="close"



********************************************************************************
** Part 6: Create the Same Figure with Charter/Contract
********************************************************************************

* need starting values for charter_contract and district schools in 2007
tab charter_contract if year==2007 & indata==1
	* charter/contract: 46
	* district: 589

preserve

collapse (sum) close cts open notin, by(year charter_contract)

* reshape wide
gen school_type = ""
replace school_type = "_cc" if charter_contract==1
replace school_type = "_dist" if charter_contract==0
drop charter_contract

reshape wide open close cts notin, i(year) j(school_type) string

* for graphing
gen total_cc = cts_cc + open_cc
gen total_dist = cts_dist + open_dist
	replace total_cc = 589 if year==2007
	replace total_dist = 46 if year==2007
replace close_cc = close_cc * -1
replace close_dist = close_dist * -1
gen net_change_cc = close_cc + open_cc
gen net_change_dist = close_dist + open_dist


* generate bars for graphing
gen open = open_cc + open_dist
gen close = close_cc + close_dist
gen total = total_cc + total_dist
gen net_change = net_change_dist + net_change_cc

twoway bar open year, barwidth(0.6) bcolor(gs6) || ///
	   bar open_cc year, barwidth(0.6) bcolor(gs2) || ///
	   bar close year, barwidth(0.6) bcolor(gs14) || ///
	   bar close_cc year, barwidth(0.6) bcolor(gs10) || ///
	   connected net_change year, mcolor(black) lcolor(black) lpattern(solid) mlabel(total) mlabposition(12) ///	   
	   scheme(s1mono) ///
	   xlabel(2007(1)2017, angle(45)) ///
	   ylabel(-60(20)80) ///
	   yline(0) ///
	   ytitle("Schools" " ") ///
	   xtitle(" " "Year") ///
	   legend(order(1 "Openings - District" 2 "Openings - Charter" 3 "Closings - District" 4 "Closings - Charter" 5 "Net Change (Total)"))

	   
	   
graph export "$output/school_openings_closures_withcharter.png", replace
window manage close graph

restore




