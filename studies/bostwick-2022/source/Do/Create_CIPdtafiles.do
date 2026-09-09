***Create Master CIP file with codes from 1990, 2000, and 2010 codes****
cd "$PATH/Data"
**********************************************************
*Save csv/xls files as .dta
**********************************************************
insheet using "CIPCrosswalk1990to2000.csv", clear comma
rename cip2000 cipcode2000
rename cip1990 cipcode1990
*remove duplicates
duplicates drop cipcode2000 cipcode1990, force
keep cipcode1990 cipcode2000
save CIPcrosswalk1990to2000.dta, replace
 
import excel using "discipline_subject_CIP_Nov2011.xls", clear firstrow case(lower)
destring subjectcode, gen(cipcode2010)
drop subjectcode
save CIP2010.dta, replace

insheet using "CIPCrosswalk2000to2010.csv", clear comma
replace cipcode2000=round(cipcode2000*10000)
replace cipcode2010=round(cipcode2010*10000)
*remove duplicates
duplicates drop cipcode2000 cipcode2010, force
duplicates tag cipcode2010, gen(dup)
drop if dup>0 & action=="New"
drop dup
save CIPcrosswalk2000to2010.dta, replace


import excel using "prior_HEI_subject_codes.xls", clear sheet("2008") firstrow case(lower)
destring subjectcode, gen(cipcode2000)
drop subjectcode
save CIP2000.dta, replace

**********************************************************
*Merge all together
**********************************************************
use CIPcrosswalk1990to2000.dta, clear
merge m:1 cipcode2000 using CIP2000.dta
drop if _merge==1
drop _merge
drop subject*
joinby cipcode2000 using CIPcrosswalk2000to2010.dta, unmatched(both)
drop _merge
drop textchange 
*merge in 2010 CIP
merge m:1 cipcode2010 using CIP2010.dta
drop _merge 
rename subjecttitle subjecttitle2010
rename subjectfield subjectfield2010
duplicates drop
save CIPmaster.dta, replace

**********************************************************
***Save a version with no missings in 1990, 2000, and in 2010
**********************************************************
use CIPmaster.dta, clear
drop if missing(cipcode1990)
drop *2000 action
save CIPmaster_nomiss1990.dta, replace
use CIPmaster.dta, clear
drop if missing(cipcode2000)
drop *1990 action
duplicates drop
save CIPmaster_nomiss2000.dta, replace
use CIPmaster.dta, clear
drop if missing(cipcode2010)
drop if cipcode2000==59999
drop *1990 *2000 action
duplicates drop
save CIPmaster_nomiss2010.dta, replace



