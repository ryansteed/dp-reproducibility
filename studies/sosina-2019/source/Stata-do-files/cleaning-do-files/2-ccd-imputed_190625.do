
capture log close
macro drop _all
setdate
setdirectory

log using "Logs/2-ccd-imputed_${date}", replace text
********************************************************************************
*ccd-imputed_$date: collapsed imputed CCD file
*Victoria Sosina (vsosina@stanford.edu)
di "Date: $date"
********************************************************************************
/*Sum enrollment by race within a district and create proportion enrolled by 
race at the district level. */
********************************************************************************

version 13
set linesize 82
set more off, perm

********************************************************************************
*COLLAPSING AND SORTING IMPUTED CCD FILE
********************************************************************************
	
*Open most recent imputed race data file
use "Source\CCD collapsed imputed school by year.dta", clear

*Check unique identifier
isid ncessch year

*Correct year; CCD year is fall of school year; FY is spring of school year
rename year year_fall
gen year = year_fall + 1

*Retain only variables of interest
keep ///
	ncessch leaid year fips member ///
	totind totasian tothisp totblack totwhite ///
	totflunch totnonflunch totfrlunch totnonfrlunch

*Collapse to count totals by district-year
gen nsch = 1 if !missing(ncessch)
collapse (rawsum) member nsch tot* (first) fips, by(leaid year)

*Check unique identifier
isid leaid year
//district year should be unique identifies

foreach v of var tot*{
	gen per`v' = `v'/member
	local new = subinstr("`v'", "tot", "", 1)
	rename per`v' per`new'
}

*Rename with dataset prefix
foreach v of var tot* per* nsch fips member{
	rename `v' imp_`v'
}

*Check that leaid and year are unique identifiers
sort leaid year
by leaid year: assert _N==1 

order leaid

********************************************************************************
*REMOVE MI MSET	
********************************************************************************
*Save collapsed and sorted imputed file
export delimited "Derived/2-ccd-imputed_working_${date}.txt", replace
import delimited "Derived/2-ccd-imputed_working_${date}.txt", clear stringcols(1)
rm "Derived/2-ccd-imputed_working_${date}.txt"	

********************************************************************************
*LABEL
********************************************************************************	
label variable leaid 		"LEA ID"             
label variable year 		"Spring of school year"
label variable imp_fips 	"FIPS ID (ccd imputed)"          
label variable imp_nsch     "N schools in each district (ccd imputed)"
label variable imp_member   "Total students, all grades (ccd imputed)"
        

label variable imp_totflunch    	"N free lunch (ccd imputed)"
label variable imp_totnonflunch     "N non-free lunch (ccd imputed)"    
label variable imp_totfrlunch     	"N free or reduced price lunch (ccd imputed)"    
label variable imp_totnonfrlunch	"N non-free or reduced price lunch (ccd imputed)"  
label variable imp_totasian       	"N Asian (ccd imputed)"  
label variable imp_tothisp        	"N Hispanic (ccd imputed)"    
label variable imp_totblack       	"N black (ccd imputed)"  
label variable imp_totind          	"N Native American (ccd imputed)"  
label variable imp_totwhite     	"N white (ccd imputed)"  
  
label variable imp_perflunch    	"% free lunch (ccd imputed)"
label variable imp_pernonflunch     "% non-free lunch (ccd imputed)"    
label variable imp_perfrlunch     	"% free or reduced price lunch (ccd imputed)"    
label variable imp_pernonfrlunch	"% non-free or reduced price lunch (ccd imputed)"  
label variable imp_perasian       	"% Asian (ccd imputed)"  
label variable imp_perhisp        	"% Hispanic (ccd imputed)"    
label variable imp_perblack       	"% black (ccd imputed)"  
label variable imp_perind          	"% Native American (ccd imputed)"  
label variable imp_perwhite     	"% white (ccd imputed)" 

********************************************************************************
*SAVE
********************************************************************************
save "Derived/2-ccd-imputed_${date}.dta", replace

********************************************************************************	
*END MATTER
********************************************************************************
capture log close
