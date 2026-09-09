/*********************************
AUTHOR: JASON BARON
LAST UPDATED: 12/21/2020

DESCRIPTION:
This do-file imports data from the NCES on expenditures and revenues
at the district level. This dataset comes from the Common Core of data and
is available from 1996-97 through 2014-15.

DATA INPUTS: (1) 1996, 1997,...,2014.txt (2) cpiu.dta (3) crosswalk.dta
DATA OUTPUTS: (1) rev_expenditures.dta
*********************************/

*****************************************
***SECTION I: IMPORT REV AND EXP TXT FILES
***AND SAVE AS STATA FILES
*****************************************
clear
set more off
cd "${path}Data\Raw\Expenditures_Revenues_CCD"

**Write loop to import datasets
local allfiles : dir . files "*.txt"
display `allfiles'

foreach file in `allfiles' {
insheet using `file'
local noextension : subinstr local file ".txt" ""
keep if fipst==55
tostring *, replace
save `noextension'.dta, replace
clear
}


*****************************************
***SECTION II: GEN DIST BY YEAR PANEL
*****************************************
*Append these files into one
clear
use 1996
append using 1997 1998 1999 2000 2001 
drop censusid //this variable won't let me append directly, and I don't need it
append using 2002 2003 2004 2005 2006 2007 ///
2008 2009 2010 2011 2012 2013 2014 

*Sort data
sort leaid year
order leaid year
tab year

*Fix year variable - Note that this is the *fiscal* year
replace year = "1995" if year=="95"
replace year = "1996" if year=="96"
replace year = "1997" if year=="97"
replace year = "1998" if year=="98"
replace year = "1999" if year=="99"
replace year = "2000" if year=="0"
replace year = "2001" if year=="1"
replace year = "2002" if year=="2"
replace year = "2003" if year=="3"
replace year = "2004" if year=="4"
replace year = "2005" if year=="5"
replace year = "2006" if year=="6"
replace year = "2007" if year=="7"
replace year = "2008" if year=="8"
replace year = "2009" if year=="9"
replace year = "2010" if year=="10"
replace year = "2011" if year=="11"
replace year = "2012" if year=="12"
replace year = "2013" if year=="13"
replace year = "2014" if year=="14"
replace year = "2015" if year=="15"

*Make sure it worked
tab year

*Destring the variable year, and create academic year, rather than FY
destring year, replace
replace year = year-1
rename year school_year

*Destring district code
destring leaid, replace
sort leaid school_year

*Keep only variables of interest
drop fipst fipsco cmsa stname stabbr fl*  

*Rename variables of interest

*Revenues
rename (totalrev tfedrev tstrev tlocrev t06 u50) ///
(total_rev fed_rev state_rev local_rev rev_proptaxes private_cont)

*Expenditures
*Current Operation Expenditure
*Note: tcurelsc = total current expenditures for elementary/secondary education
*tcurinst is total current expenditures on instruction
*tcurssvc is total current expenditures in support services (gets broken down)
*tcuroth is total current expenditures, other elementary/secondary
*tcurelsc is the sum of tcurinst + tcurssvc + tcuroth
*Specific categories are broken down from tcurssvc
rename (tcurelsc tcurinst tcurssvc tcuroth e17 e07 e08 e09 v40 v45 v90 tcapout v93 v02 k14) ///
(tot_exp tot_exp_inst tot_exp_ss tot_exp_oth ss_pupils ss_instruction ///
ss_graladmin ss_schooladmin ss_operation_maint ss_transp ss_other tot_capout textbooks_exp ///
tech_supplies_exp tech_equipment_exp)  

*Membership
rename v33 membership

*Teacher Compensation
rename (z33 z35 z36 z37 z38 v10) ///
(tot_teach_sal teach_sal_reg teach_sal_se teach_sal_voc teach_sal_oth ///
tot_teach_ben)

*Debt
rename (i86 _19h _21f) (interest_debt LT_debt_out LT_debt_issued)
rename (f12 g15 k09) (cap_construction cap_existing cap_inst_equip)


*Label variables

*Revenues
label var total_rev "Total Revenue"
label var fed_rev "Total Federal Revenue"
label var state_rev "Total State Revenue"
label var local_rev "Total Local Revenue"
label var rev_proptaxes "Local Revenue - Property Taxes"
label var private_cont "Local Revenue - Private Contributions"

*Expenditures
*Broad
label var tot_exp "Total current expenditures for elem/sec education"
label var tot_exp_inst "Total current expenditures - instruction"
label var tot_exp_ss "Total current expenditures - support services"
label var tot_exp_oth "Total current expenditures - other"
label var tot_capout "Total capital outlay expenditures"

*More specific (Support Services)
label var ss_pupils "Current expenditures - support services - pupils"
label var ss_instruction "Current expenditures - support services - instructional staff"
label var ss_graladmin "Current expenditures - support services - gral administration"
label var ss_schooladmin "Current expenditures - support services - school administration"
label var ss_operation_maint "Current expenditures - support services - op. and maint. of plant"
label var ss_transp "Current expenditures - support services - student transp."
label var ss_other "Current expenditures - support services - business/central/other"

*Even more specific
label var tech_supplies_exp "Expenditures in tech-related supplies and purch. serv."
label var tech_equipment_exp "Expenditures in tech-related equipment"
label var textbooks_exp "Expenditures for textbooks used in classroom"

*Membership
label var membership "Fall membership"

*Teacher Compensation
*Broad
label var tot_teach_sal "Total teacher salaries"
label var tot_teach_ben "Total teacher benefits"

*Debt
label var interest_debt "Interest on Debt"
label var LT_debt_out "Long_Term Debt Outstanding at beg of FY"
label var LT_debt_issued "Long-Term Debt Issued on FY"

*Capital Outlays (Specific)
label var cap_construction "Capital Outlays on Construction"
label var cap_existing "Capital Outlays on Land and Existing Structures"
label var cap_inst_equip "Capital Outlays on Instructional Equipment"

*Create a local of these variables
local z total_rev fed_rev state_rev local_rev rev_proptaxes private_cont tot_exp ///
tot_exp_inst tot_exp_ss tot_exp_oth ss_pupils ss_instruction ss_graladmin ///
ss_schooladmin ss_operation_maint ss_transp ss_other tot_capout textbooks_exp ///
tech_supplies_exp tech_equipment_exp tot_teach_sal tot_teach_ben interest_debt ///
LT_debt_out LT_debt_issued cap_construction cap_existing cap_inst_equip

*Keep only variables of interest
destring membership, replace
keep leaid name school_year `z' membership

*Examine summary statistics, and make sure there are no outliers / wrong data
foreach var in `z'{
    destring `var', replace
	replace `var'=. if `var'<0
}
replace membership =. if membership<0
sum `z' membership
edit if membership==. 

*Replace Norris School District's membership from "." to "60"
replace membership = 60 if membership==. & leaid==5510710 //this information is available from the WDPI

*Convert to real 2010 dollars using the Midwestern CPI-U
merge m:1 school_year using "${path}Data\Intermediate\cpiu"
edit if _merge==2 // I do not have these school years in my dataset
drop if _merge==2
drop _merge
sort leaid school_year
order cpi

*Make a variable CPI in 2010
gen cpi2010 =.
order cpi2010
replace cpi2010=208.046
gen newcpi = cpi/cpi2010
order newcpi

*Write loop to convert to real dollars, per member measures
foreach v in `z'{
replace `v' = (`v'/newcpi) //deflate
}
sort leaid school_year

*Drop these variables
drop newcpi cpi2010 cpi 


*Deal with consolidations, name changes, and mergers
bysort leaid: gen nobs = _N
order nobs //19 obs. signifies a "full balanced panel"
edit if nobs!=19

*The are a few consolidations a mergers to worry about. The full list can
*be found here: https://dpi.wi.gov/sms/reorganization/history-and-orders

*(1) River Ridge (merge between Bloomington and West Grant in 1995)
*Since this was in 1995, this merger is not a problem in this dataset.

*(2) Trevor - Wilmot (merge between Trevor Grade and Wilmot Grade in 2006)
*Also, Salem changed name to Trevor in 2000
replace leaid = 5500052 if leaid== 5513320 //replace Trevor's LEAID
replace leaid = 5500052 if leaid== 5513380 //replace Wilmot's LEAID
edit if leaid== 5500052
sort leaid school_year //at the end, I will collapse by year and LEAID to fix this merger


*(3) There was a split between Shawano-Gresham into Shawano and Gresham in 2007-08
replace leaid = 5513620 if leaid== 5500056
edit if leaid==5513620


*(4) Glidden and Park Falls merged in 2009 to become Chequamegon
replace leaid = 5500058 if leaid == 5505550 //glidden
replace leaid = 5500058 if leaid == 5511430 //park falls
edit if leaid==5500058

*(5) Chetek and Weyerhauser merged to become Chetek - Weyerhauser
replace leaid = 5500061 if leaid == 5502490 //chetek
replace leaid = 5500061 if leaid == 5516530 //weyerhauser
edit if leaid==5500061


*(6) Herman, Neosho, Rubicon merged in 2016
replace leaid=5500075 if leaid==5513200 //Rubicon 
replace leaid=5500075 if leaid==5510410 //Neosho
replace leaid=5500075 if leaid==5506390 //Herman
edit if leaid==5500075

*Collapse data to account for these consolidations
collapse (sum) `z' membership, by(leaid school_year) 
bysort leaid: gen nobs=_N
edit if nobs!=19
drop if nobs!=19

*Now, merge to WI district codes
merge m:1 leaid using "${path}Data\Raw\Crosswalk\crosswalk"
edit if _merge==2 //Holy Hill and Gresham - this is right
edit if _merge==1
keep if _merge==3
drop _merge nobs
order lea_name district_code
sort district_code school_year

*Generate "Per Member measures"
foreach var in `z'{
gen `var'_mem = `var'/member
}

*Keep only per member measures
drop `z'

*Label New Variables
*Revenues
label var total_rev "Total Revenue PM"
label var fed_rev "Total Federal Revenue PM"
label var state_rev "Total State Revenue PM"
label var local_rev "Total Local Revenue PM"
label var rev_proptaxes "Local Revenue - Property Taxes PM"
label var private_cont "Local Revenue - Private Contributions PM"

*Expenditures
*Broad
label var tot_exp_mem "Total current expenditures for elem/sec education PM"
label var tot_exp_inst "Total current expenditures - instruction PM"
label var tot_exp_ss "Total current expenditures - support services PM"
label var tot_exp_oth "Total current expenditures - other PM"
label var tot_capout "Total capital outlay expenditures PM"

*More specific (Support Services)
label var ss_pupils "Current expenditures - support services - pupils PM"
label var ss_instruction "Current expenditures - support services - instructional staff PM"
label var ss_graladmin "Current expenditures - support services - gral administration PM"
label var ss_schooladmin "Current expenditures - support services - school administration PM"
label var ss_operation_maint "Current expenditures - support services - op. and maint. of plant PM"
label var ss_transp "Current expenditures - support services - student transp. PM"
label var ss_other "Current expenditures - support services - business/central/other PM"


*Teacher Compensation
label var tot_teach_sal "Total teacher salaries PM"
label var tot_teach_ben "Total teacher benefits PM"

*Debt
label var interest_debt "Interest on Debt PM"
label var LT_debt_out "Long_Term Debt Outstanding at beg of FY PM"
label var LT_debt_issued "Long-Term Debt Issued on FY PM"

*Drop other variables I will not usre
drop textbooks_exp tech_supplies_exp tech_equipment_exp ///
cap_construction cap_existing cap_inst_equip

*Private Contributions should be marked as missing before 2005 - it is only 
*available from 2005-06 through 2014-15
replace private_cont =. if school_year<2005

*****************************************
******SECTION III: SAVE THIS DATASET
*****************************************
save "${path}Data\Raw\Completed_Files\rev_expenditures", replace
