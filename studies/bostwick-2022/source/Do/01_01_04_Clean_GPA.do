******************************************************************
*Clean and append GPA files
*Obs is a person-inst-term
*May 16, 2018
******************************************************************


***************************************************************************
*Input files:
local in "$mydir/Dropbox/OLDA/Combined_HEI_Files/hei_gpa_SM99-SP17.dta"

*Final output file:
local out "Intermediate_Data/All_Campuses/GPA_allOH_SM99-SP17.dta"
***************************************************************************

use `in', clear

*Undergrad only (note first-time freshmen at Toledo are mis-classified as admis=="HGH" in 2013)
keep if admis_area=="UND" | admis_area=="HGH" 
*keep only enrollment in degree-granting instituions
keep if inst_code=="AKRN" | inst_code=="BGSU" | inst_code=="CINC" | inst_code=="CLEV" | inst_code=="CNTL" | inst_code=="KENT" | inst_code=="MIAM" | inst_code=="OHSU" | inst_code=="OHUN" | inst_code=="SHAW" | inst_code=="TLDO" | inst_code=="WSUN" | inst_code=="YNGS"
*Calculate gpa
gen gpa=cum_gpa_points/cum_gpa_hrs
drop admis_area cum* key_id
compress
save `out', replace
