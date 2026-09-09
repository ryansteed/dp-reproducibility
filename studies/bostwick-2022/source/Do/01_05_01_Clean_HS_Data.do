****************************************************
*Clean High School ACT code data
*December 14, 2018
****************************************************


***************************************************************************
*Input Files:
local zips "$mydir/Dropbox/OLDA/Combined_HEI_Files/hei_act_high_sch_tot_29jan16.dta"
local hs2016 "$mydir/Dropbox/OLDA/Raw_HEI_Files/HIGH_SCH_GRAD_16.csv"
local hs2017 "$mydir/Dropbox/OLDA/Raw_HEI_Files/HIGH_SCH_GRAD_17.csv"
local hs_raw "$mydir/Dropbox/OLDA/Raw_HEI_Files/hei_high_sch_grad_anon_11mar16.dta"


*Final output file:
local hs_grad "$mydir/Dropbox/OLDA/Combined_HEI_Files/hei_high_sch_grad_SM99-SP17.dta"
local hs_zips "Intermediate_Data/All_Campuses/high_school_zipcodes.dta"
local out_und "Intermediate_Data/All_Campuses/high_school_undergraduates.dta"
local out_non_und "Intermediate_Data/All_Campuses/high_school_non_undergrad.dta"


***************************************************************************

 
*append high school data for 2015-2016 and 2016-2017 school year entrants to main file
insheet using `hs2016', comma clear
save "temp data files/high_school.dta", replace
insheet using `hs2017', comma clear
append using "temp data files/high_school.dta"
append using `hs_raw'
save `hs_grad', replace



*Remove duplicates from ACT zip code data
use  `zips', clear
keep act_code state city zip
drop if missing(zip)
duplicates drop
save `hs_zips', replace

use `hs_grad', clear

*Drop obs where high school is unknown
replace act_code=subinstr(act_code, " ", "0", .)
destring act_code, gen(check_act) force
drop if check_act==.
drop key_id inst_temp_id hei_ranid inst_assigned_sw check_act
duplicates drop

*Merge in zip code for each school
merge m:1 act_code using `hs_zips'
drop if _merge==2
drop _merge
rename state_abbrev hs_state
rename city hs_city
rename zip_code hs_zip

*Save obs labeled as undergraduate enrollment separately
preserve
keep if admis=="UND"
save `out_und', replace
restore
drop if admis=="UND"
save `out_non_und', replace
