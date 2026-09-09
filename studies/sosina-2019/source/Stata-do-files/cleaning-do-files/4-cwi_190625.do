
capture log close
macro drop _all
setdate
setdirectory

log using "Logs/4-cwi-saipe_${date}", replace text
********************************************************************************
*cwi-saipe_$date: clean and merge cwi and saipe files
*Written by Ericka Weathers (esw71@psu.edu)
*Edited by Victoria Sosina (vsosina@stanford.edu)
di "Date: $date"
********************************************************************************
/*Create the district and state CWI files for CWI adjustments*/
********************************************************************************

version 13
set linesize 82
set more off, perm

********************************************************************************
*OPEN, RESHAPE, AND MERGE CWI - DISTRICT AND STATE
********************************************************************************

*CWI - district*****************************************************************
use "Source/District_CWI_1997-2013.dta", clear
	
*reshape
reshape long std_ecwi ecwi, i(leaid state_name) j(year)
	rename state_name state

*district-specific names
rename std_ecwi std_ecwi_D
rename ecwi ecwi_D

*cwi prefix
foreach v of var *{
	rename `v' cwi_`v'
}

rename cwi_leaid leaid
rename cwi_year  year
rename cwi_state state


*add cwi suffix to variables with existing labels
local cwi cwi_lea_name cwi_labormarket cwi_lm_name cwi_cnty_code cwi_cnty_name

foreach v of local cwi{
	local varlab: variable label `v'
	label variable `v' "`varlab' (cwi)"
}


*manually label remaining variables
label variable cwi_std_ecwi_D 	"standard error ecwi - district (cwi)"
label variable cwi_ecwi_D 		"extended cwi - district (cwi)"

*save reshaped file
save "Derived/4-cwi_dis_${date}.dta", replace


*CWI - state********************************************************************
use "Source/State_CWI_1997-2014.dta", clear

*reshape
reshape long std_ecwi ECWI, i(pwstate state) j(year)

*state-specific names
rename pwstate 	fipst
rename std_ecwi std_ecwi_S
rename ECWI 	ecwi_S

*cwi prefix
foreach v of var *{
	rename `v' cwi_`v'
}

rename cwi_year  year
rename cwi_state state
rename cwi_fipst fipst

*manually label remaining variables
label variable cwi_std_ecwi_S 	"standard error ecwi - state (cwi)"
label variable cwi_ecwi_S		"extended cwi - state (cwi)"

*save reshaped file
save "Derived/4-cwi_state_${date}.dta", replace


********************************************************************************
*END MATTER
********************************************************************************
capture log close
