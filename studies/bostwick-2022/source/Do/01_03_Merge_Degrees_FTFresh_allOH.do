***************************************************************************
*Merge data on degrees awarded into 
*Individual-level file with all first-time freshmen undergrads
*May 17, 2018
***************************************************************************


***************************************************************************
*Input and output files:
local in "Intermediate_Data/All_Campuses/Indiv_FTFresh_allOH_SM99-SP17.dta"
local degrees "$mydir$/Dropbox/OLDA/Combined_HEI_Files/hei_degree_cert_anon_BAonly.dta"
local terms "$mydir/Dropbox/OLDA/Raw_Other_Files/mytermindex.dta"

local out "Intermediate_Data/All_Campuses/Indiv_FTFresh_withDegrees_SM99-SP17.dta"

***************************************************************************


***Merge in Bachelor's degrees***
use `in', clear
merge 1:m hei_psid inst_code campus_code using `degrees'
drop if _merge==2
rename _merge BA_merge
*If obs didn't match on campus_code, try matching on main campus_code (for MIAM and OHSU)
preserve
	drop if BA_merge==3
	rename campus_code hold_campus
	gen campus_code=inst_code
	merge 1:m hei_psid inst_code campus_code using `degrees', update
	tab inst_code _merge
	replace BA_merge=(_merge)
	drop if _merge==2
	replace campus_code=hold_campus
	save "temp data files/temp.dta", replace
	restore
drop if BA_merge!=3
append using "temp data files/temp.dta"
drop _merge hold_campus key_id yr_num degree_cert_level_code degree_cert_cr_hrs id_num

*merge in term index for when degree was earned
rename degree_cert_yr yr_num
rename degree_cert_term term_code
merge m:1 yr_num term_code using `terms', keep(match master)
drop _merge term_num
rename yr_num yr_num_degree
rename term_code term_code_degree
rename term_index term_index_degree

*Check for degrees earned before enrollment started
tab subject_code if term_index_degree<first_term


*generate variable for ever completes BA
egen everBA=max(BA_merge==3 | BA_merge==4), by(person_campus)
*Flag students who earn multiple BAs
duplicates tag person_campus, gen(multipleBA)

**If more than 1 degree:
*If not in the same term, keep the first
*otherwise, keep one at random
sort person_campus term_index_degree
drop if person_campus==person_campus[_n-1]
duplicates report person_campus
drop BA_merge

*Years-to-degree
gen yrstoBA=(term_index_degree-first_term+1)/4
save `out', replace

