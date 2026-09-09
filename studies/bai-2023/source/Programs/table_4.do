
/***************************************************************************************************
 
 *** POLITICAL CONFLICT AND DEVELOPMENT DYNAMICS: ECONOMIC LEGACIES OF THE CULTURAL REVOLUTION   ***

****************************************************************************************************/

clear
set more off

global MainDir "../Data"

use "../Data/census_individual.dta"

******************************************************************************************************************
/*		TABLE 4: Individual-level Results: Revolutionary Intensity, Education, and Labor Market Outcomes		*/
******************************************************************************************************************


********************************************************************************
*********            REGRESSIONS: 1931-35 as base group             ************
********************************************************************************		

* Years of schooling
	 
     quietly areg lnyearsofedu age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 age3640 ///
	 age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t, absorb(prefid00) robust cluster(prefid00)
	 
	 regsave age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1931-35_base/edu_coeff_2000_ipums_1of2.dta", ci saveold(13) replace		
		
* College Education
	 
     quietly logit college age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 age3640 ///
	 age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1931-35_base/edu_coeff_2000_ipums_2of2.dta", ci saveold(13) replace
	 
* Employment 

     quietly logit employed age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 age3640 ///
	 age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1931-35_base/lab_coeff_2000_ipums_1of4.dta", ci saveold(13) replace

* Days Worked During Past Week 
	 
     quietly reg days_worked age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 age3640 ///
	 age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1931-35_base/lab_coeff_2000_ipums_2of4.dta", ci saveold(13) replace
	 
* Professional Occupation 
	 
     quietly logit professional age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 age3640 ///
	 age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1931-35_base/lab_coeff_2000_ipums_3of4.dta", ci saveold(13) replace

* Entrepreneurship 
	 
     quietly logit entrepreneur age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 age3640 ///
	 age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age3640deaths age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1931-35_base/lab_coeff_2000_ipums_4of4.dta", ci saveold(13) replace
	 
	 
********************************************************************************
*********            REGRESSIONS: 1936-40 as base group             ************
********************************************************************************		

drop if age3135 == 1

* Years of schooling
	 
     quietly areg lnyearsofedu age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 ///
	 age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t, absorb(prefid00) robust cluster(prefid00)
	 
	 regsave age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1936-40_base/edu_coeff_2000_ipums_1of2.dta", ci saveold(13) replace		
		
* College Education
	 
     quietly logit college age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 ///
	 age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1936-40_base/edu_coeff_2000_ipums_2of2.dta", ci saveold(13) replace
	 
* Employment 

     quietly logit employed age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 ///
	 age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1936-40_base/lab_coeff_2000_ipums_1of4.dta", ci saveold(13) replace

* Days Worked During Past Week 
	 
     quietly reg days_worked age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 ///
	 age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1936-40_base/lab_coeff_2000_ipums_2of4.dta", ci saveold(13) replace
	 
* Professional Occupation 
	 
     quietly logit professional age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 ///
	 age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1936-40_base/lab_coeff_2000_ipums_3of4.dta", ci saveold(13) replace

* Entrepreneurship 
	 
     quietly logit entrepreneur age7680 age7175 age6670 age6165 age5660 age5155 age4650 age4145 ///
	 age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4145deaths age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1936-40_base/lab_coeff_2000_ipums_4of4.dta", ci saveold(13) replace

********************************************************************************
*********            REGRESSIONS: 1941-45 as base group             ************
********************************************************************************		

drop if age3640 == 1

* Years of schooling
	 
     quietly areg lnyearsofedu age7680 age7175 age6670 age6165 age5660 age5155 age4650 ///
	 age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t, absorb(prefid00) robust cluster(prefid00)
	 
	 regsave age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1941-45_base/edu_coeff_2000_ipums_1of2.dta", ci saveold(13) replace		
		
* College Education
	 
     quietly logit college age7680 age7175 age6670 age6165 age5660 age5155 age4650 ///
	 age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1941-45_base/edu_coeff_2000_ipums_2of2.dta", ci saveold(13) replace
	 
* Employment 

     quietly logit employed age7680 age7175 age6670 age6165 age5660 age5155 age4650 ///
	 age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1941-45_base/lab_coeff_2000_ipums_1of4.dta", ci saveold(13) replace

* Days Worked During Past Week 
	 
     quietly reg days_worked age7680 age7175 age6670 age6165 age5660 age5155 age4650 ///
	 age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1941-45_base/lab_coeff_2000_ipums_2of4.dta", ci saveold(13) replace
	 
* Professional Occupation 
	 
     quietly logit professional age7680 age7175 age6670 age6165 age5660 age5155 age4650 ///
	 age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1941-45_base/lab_coeff_2000_ipums_3of4.dta", ci saveold(13) replace

* Entrepreneurship 
	 
     quietly logit entrepreneur age7680 age7175 age6670 age6165 age5660 age5155 age4650 ///
	 age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths ///
	 age7680deaths male han urban $prov_t i.prefid00, robust cluster(prefid00)
     
	 regsave age4650deaths age5155deaths age5660deaths age6165deaths age6670deaths age7175deaths age7680deaths ///
		using "$MainDir/Results/1941-45_base/lab_coeff_2000_ipums_4of4.dta", ci saveold(13) replace

		
		