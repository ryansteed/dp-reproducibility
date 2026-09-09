***************************************************************************
*Create a file including all undergraduate enrollment SM99-SP17 
*keep all campuses
*Each obs is a person-inst-term
*May 16, 2018
***************************************************************************


***************************************************************************
*Input files:
local in "$mydir/Dropbox/OLDA/Combined_HEI_Files/hei_stud_enroll_SM99-SP17.dta"
local term_index "$mydir/Dropbox/OLDA/Raw_Other_Files/mytermindex.dta"

*Output files:
local all_enroll "Intermediate_Data/All_Campuses/Enroll_allOH_unclean"
local out "Intermediate_Data/All_Campuses/Enroll_allOH_SM99-SP17.dta"
***************************************************************************




use `in', clear

*keep only undergrad students (note first-time freshmen at Toledo are mis-classified as admis=="HGH" in 2013)
keep if admis_area=="UND" | admis_area=="HGH" 
*drop non-undergraduate enrollment
drop if rank_code=="NU"
*keep only enrollment in degree-granting instituions
keep if inst_code=="AKRN" | inst_code=="BGSU" | inst_code=="CINC" | inst_code=="CLEV" | inst_code=="CNTL" | inst_code=="KENT" | inst_code=="MIAM" | inst_code=="OHSU" | inst_code=="OHUN" | inst_code=="SHAW" | inst_code=="TLDO" | inst_code=="WSUN" | inst_code=="YNGS"

*Drop unnecessary variables
drop admis_area residency pgrm_code key_id
compress

*Merge in my term index
merge m:1 yr_num term_code using `term_index'
drop if _merge==2
drop _merge
compress
save `all_enroll', replace

************************************************
*Fill in gaps in enrollment
************************************************
egen person_campus=group(hei_psid inst_code campus_code)
tsset person_campus term_index
tab term_index, miss
tsfill
tab term_index, miss
foreach var of varlist hei_psid inst_code campus_code major_study rank_code {
bysort person_campus (term_index): replace `var'=`var'[_n-1] if _n!=1 & missing(`var')
}


*tag first and last enrollment
egen first_term=min(term_index), by(hei_psid inst_code campus_code)
egen last_term=max(term_index), by(hei_psid inst_code campus_code)


save `out', replace




