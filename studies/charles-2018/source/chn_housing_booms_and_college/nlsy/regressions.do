cap log close
clear all
set more off

do set_path.do
cd "$root"


local gender0 = "All"
local gender1 = "Males"
local gender2 = "Females"


**************
**
** education variables, employment, migraiton
**
**************
local depvars = "completed1 completed2 completed4 employed moved_MSA_00 moved_state_00 mvd"


**
** MSA "starting year"
**
local Z = 1997 // MSA year	



** Main control variables
**
local controls0 = "i.KEY_RACE_ETHNICITY_1997 ib2.fathers_educ ib2.mothers_educ asvab asvab_missing log_gross_hh_income missing_parent_inc"

local controls1 = "cs2000 fes_2000 foreign_2000 log_pop_2000 D_as_`Z' D_bs_`Z' miss_1990_`Z' i.CV_CENSUS_~_`Z'"



use "$cleaned\NLSY_1997_Cleaned_v2.dta", clear

	*Drop old variables *
	local Z = 1997
	drop college_share_2000_???? fes_2000_???? iv2_log_???? // demand_change_????
	
	#delimit ;
	mmerge metarea_1997 using "Housing Indicator\July 2016 Revision\All_Indicators_v3.dta", 
		type(n:1) umatch(metarea) _merge(metarea_data_merge)
		ukeep(pop_total_2000 share_foreign_18_55_2000 iv female_employed_share_2000 college_share_2000 housing_demand_shock housing_demand_shock_alt  iv2 price_rent_ratio iv3)
		;
	#delimit cr
	keep if metarea_data_merge == 3 & controls_merge_`Z' == 3

	* Regression variables and Labels *
		quietly{
		* Regional dummies *
		tab CV_CENSUS_~_`Z', gen(region_`Z'_d)
		local regions = "NE Midwest South West"
		label def regions 1 "\quad Northeast"
		label def regions 2 "\quad Midwest", add
		label def regions 3 "\quad South", add
		label def regions 4 "\quad West", add

		label val CV_CENSUS_REGION_`Z' regions

		* Age *
		foreach y in 2006 2011 2013 {
			gen Age_`y' = `y'-1 - KEY_BDATE_Y_1997	
		}
		label var Age_2006 "Age in 2006"
		label var Age_2011 "Age in 2011"
		label var Age_2013 "Age in 2013"
		* Quintiles of Test Scores *
		gen asvab_quintile = .

		forvalues s = 0(20)80{
		local s1 = `s'/20 +1
		local s2 = `s'+20
		replace asvab_quintile = `s1' if asvab >= `s' & asvab < `s2' & asvab_missing == 0

		}
		replace asvab_quintile = 5 if asvab == 100
		replace asvab_quintile = 0 if asvab_missing == 1

		label def asvab_quintile 0 "ASVAB Missing"
		label def asvab_quintile 1 "ASVAB 0-19", add
		label def asvab_quintile 2 "ASVAB 20-39", add
		label def asvab_quintile 3 "ASVAB 40-59", add
		label def asvab_quintile 4 "ASVAB 60-79", add
		label def asvab_quintile 5 "ASVAB 80-100", add
		label values asvab_quintile asvab_quintile

	
		* Controls *
		rename female_employed_share_2000 fes_2000
		rename college_share_2000 cs2000
		rename D_assoc_share_`Z' D_as_`Z'
		rename D_bachelor_share_`Z' D_bs_`Z'
		rename missing_1990_data_`Z' miss_1990_`Z'
		
		rename share_foreign_18_55_2000 foreign_2000
		gen log_pop_2000 = ln(pop_total_2000)
		
		label var foreign_2000 	"\quad Share Foreign-Born"
		label var log_pop_2000 	"\quad Log Population 2000"
		label var fes_2000 		"\quad Female Empl. Share"
		label var cs2000 		"\quad College Share"
		label var D_as_`Z' 		"\quad Associate's Share"
		label var D_bs_`Z' 		"\quad Bachelor's Share"
		label var miss_1990_`Z' "\quad Missing Shares"
		
		* Parental Educ *

		label var fathers_educ "Father's Educ. Attainment"
		label var mothers_educ "Mother's Educ. Attainment"

		label def parental_educ 1 "\quad Missing", modify
		label def parental_educ 2 "\quad No HS Degree", modify
		label def parental_educ 3 "\quad HS Degree", modify
		label def parental_educ 4 "\quad Some College", modify
		label def parental_educ 5 "\quad Bachelor's+", modify
	
		label val fathers_educ parental_educ
		label val mothers_educ parental_educ
	
		* Race, Ethnicity *
		label def race 1 "\quad Black"
		label def race 2 "\quad Hispanic", add
		label def race 3 "\quad Mixed Race", add
		label def race 4 "\quad Non-Black", add

		label val KEY_RACE_ETHNICITY_1997 race
		forvalues y = 2006(1)2011{
		label var years_college_`y' "YoC_`y'"
		label var first_year_`y' 	"A1_`y'"
		label var completed1_`y' 	"C1_`y'"
		label var completed2_`y' 	"C2_`y'"
		label var completed3_`y' 	"C3_`y'"
		label var completed4_`y' 	"C4+_`y'"
		}
	}





		
*
* Loop over main variables
*
foreach yvar of local depvars{	
	foreach y in 2006 2013 {

			** Men and Women
			regress `yvar'_`y' iv Age_`y' `controls0' `controls1' , vce(cluster metarea_`Z')

			** Men
			regress `yvar'_`y' iv Age_`y' `controls0' `controls1' if KEY_SEX_1997 == 1, vce(cluster metarea_`Z')
			
			** Women
			regress `yvar'_`y' iv Age_`y' `controls0' `controls1' if KEY_SEX_1997 == 2, vce(cluster metarea_`Z')

}
}


