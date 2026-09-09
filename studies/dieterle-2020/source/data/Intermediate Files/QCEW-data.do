
*Raw QCEW fles first saved as .csv
foreach y in 05 06 07 08 09 10 11{
forvalues q=1/4{
clear
import delimited allhlcn`y'`q'.csv, varnames(1)
drop employmentlocationquotientrelati totalwagelocationquotientrelativ
keep if areatype=="County" & ownership=="Total Covered" & industry=="Total, all industries"
save qcew20`y'q`q', replace
}
}

use qcew05q1, clear
keep areacode st cnty stname area
save qcew-fips.dta, replace

clear

forvalues y=2005/2011{
use qcew`y'q1, clear
capture noisily: rename (januaryemployment februaryemployment marchemployment) (month1 month2 month3)
drop statuscode
save qcew`y'q1, replace
use qcew`y'q2, clear
capture noisily: rename (aprilemployment mayemployment juneemployment) (month1 month2 month3)
drop statuscode
save qcew`y'q2, replace
use qcew`y'q3, clear
capture noisily:  rename (julyemployment augustemployment septemberemployment) (month1 month2 month3)
drop statuscode
save qcew`y'q3, replace
use qcew`y'q4, clear
capture noisily:  rename (octoberemployment novemberemployment decemberemployment) (month1 month2 month3)
drop statuscode
save qcew`y'q4, replace

}


clear

forvalues y=2005/2011{
forvalues q=1/4{
append using qcew`y'q`q'
}
}

destring month1 month2 month3 totalquarterlywages, replace ignore(",")

egen emp_q_avg=rowmean(month1 month2 month3)
rename averageweeklywage wkwage_q_avg

drop month1 month2 month3 totalquarterlywages areatype
rename qtr quarter

merge m:1 stname area using qcew-fips, nogen 
rename areacode st_county_cd
drop if stname=="Alaska"
save QCEW, replace
