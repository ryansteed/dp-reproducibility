
*clear*
*chdir "C:\Users\Rudi\Dropbox\6. Academicos\Agrotoxicos\Data\Originais"

clear*

***********************************************************************************************************************************************
* Programação parte de base cedida por Dimitri S.

use "$pathfiles_data/Originais/climate_ufmundv.dta", clear

keep if year>=1996 & year<=2010
keep ufmundv year vrain01 - vrain12

foreach i in 01 02 03 04 05 06 07 08 09 10 11 12 {
preserve
keep ufmundv year vrain`i'
gen month = `i'
rename vrain`i' vrain
save "$pathfiles_data/Originais\temp_`i'", replace
restore
}
clear
use "$pathfiles_data/Originais/temp_01.dta"
foreach i in 02 03 04 05 06 07 08 09 10 11 12 {
append using "$pathfiles_data/Originais\temp_`i'"
}

gen code_mun=int(ufmundv/10) 
merge m:1 code_mun using "$pathfiles_data/Originais/amcs_br.dta"
keep AMC code_mun month year vrain

sort code_mun year month
order code_mun year month

egen rain_year = sum(vrain), by(code_mun year)

forval i=1996(1)2010 {
preserve
keep if year==`i'
reshape wide vrain, i(code_mun) j(month) 
keep code_mun year vrain*
save "$pathfiles_data/Originais/temp`i'", replace
restore
}


bys code_mun year: egen rain_plantio1 = sum(vrain) if month>=10
bys code_mun year: egen rain_plantio2 = sum(vrain) if month<=3
bys code_mun year: egen rain_Nplantio = sum(vrain) if inrange(month,4,9)
keep if month==1 | month==12 | month==4
replace month = 2 if month==4
replace month = 3 if month==12
sort year month
egen time = group(year month)
sort code year month
xtset code time
bys code: gen rain_plantio2t = rain_plantio2[_n+1]
gen rain_plantio= rain_plantio1 + rain_plantio2t
gen rain_oct_dec = rain_plantio1
gen rain_oct_mar = rain_plantio
bys code: gen rain_apr_sep = rain_Nplantio[_n-1]
keep if month==3
keep code_mun year rain_oct_dec rain_oct_mar rain_apr_sep rain_year


compress
save "$pathfiles_data/Originais/rain.dta", replace


foreach i in 01 02 03 04 05 06 07 08 09 10 11 12 {
erase  "$pathfiles_data/Originais/temp_`i'.dta"
}
forval i=1996(1)2010 {
erase  "$pathfiles_data/Originais/temp`i'.dta"
}
*
	
	
	
