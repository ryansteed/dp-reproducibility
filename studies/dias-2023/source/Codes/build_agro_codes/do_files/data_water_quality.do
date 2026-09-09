********************************************************************************
* Build: Water Quality
********************************************************************************

*** Extract and join all water quality data
	* We will get a dataset with municipalities and years for which we have data
clear
use "$pathfiles_data/Originais/water_quality_1.dta"
keep mun_cod ano dbo nitrogênioamoniacal chumbo óleosegraxas índicedefenois manganês
rename dbo bod1
rename nitrogênioamoniacal ammonia_nitrogen1
rename chumbo lead1
rename óleosegraxas oils1
rename índicedefenois phenol_index1
rename manganês manganese1
tempfile quality1
save `quality1'

clear
use "$pathfiles_data/Originais/water_quality_2.dta"
keep mun_cod ano dbo nitrogênioamoniacal chumbo óleosegraxas índicedefenois manganês
rename dbo bod2
rename nitrogênioamoniacal ammonia_nitrogen2
rename chumbo lead2
rename óleosegraxas oils2
rename índicedefenois phenol_index2
rename manganês manganese2
tempfile quality2
save `quality2'

clear
use "$pathfiles_data/Originais/water_quality_3.dta"
keep mun_cod ano dbo nitrogênioamoniacal chumbo óleosegraxas índicedefenois manganês
rename dbo bod3
rename nitrogênioamoniacal ammonia_nitrogen3
rename chumbo lead3
rename óleosegraxas oils3
rename índicedefenois phenol_index3
rename manganês manganese3
tempfile quality3
save `quality3'

* The datasets do not have all municipalities - 2 has 5554, 1 and 3 have 1700, 1800 municipalities
clear
use `quality2'
merge 1:1 mun_cod ano using `quality1'
drop _merge
merge 1:1 mun_cod ano using `quality3'
drop _merge

gen code_mun = substr(string(mun_cod),1,6)
destring code_mun, replace
rename ano year

tempfile waterquality
save `waterquality'	
	
	
*** Build a full balanced panel with water quality data

* Build the basic municipality-year panel:

do "$pathfiles_do/build_panel.do"

* Merge water quality data and municipal area (to collapse by AMC); adjusted areas dta has munic 430000 dropped
merge 1:1 code_mun year using `waterquality'
drop if _merge==2 // Years <1996 or >2010 and unidentified municipality (430000/4300001); 11 municipalities only in master data
drop _merge

// Below, adjusted just means that we already created an ID variable with 6 digits
// for each municipality from the 7-digit ID (last digit is irrelevant).
merge m:1 code_mun using "$pathfiles_data/Originais/area_mun_Ibge_2010_adjusted.dta", keepusing(area_ibge_km2)
drop _merge

bysort AMC year: egen amcarea = sum(area_ibge_km2)
foreach x in bod ammonia_nitrogen lead oils phenol_index manganese{
replace `x'1 = `x'1 * (area_ibge_km2/amcarea)
replace `x'2 = `x'2 * (area_ibge_km2/amcarea)
replace `x'3 = `x'3 * (area_ibge_km2/amcarea)
}

* Create auxiliar variable to identify missings in bod data when we collapse
foreach v in bod ammonia_nitrogen lead oils phenol_index manganese{
forv i=1/3{
	gen missing`v' = 0
	replace missing`v'=1 if `v'`i'==.
	bysort AMC year: egen allmissing`v'`i'=min(missing`v')
	drop missing`v'
}
}

** Colapse by AMC-year
sort AMC
collapse (sum) bod* ammonia_nitrogen* lead* oils* phenol_index* manganese* (min) allmissing* (first) code_uf, by(AMC year)

* Adjust missings in bod measures
foreach v in bod ammonia_nitrogen lead oils phenol_index manganese{
	forv i=1/3{
		replace `v'`i'=. if allmissing`v'`i'==1
	}
}

save "$pathfiles_data/Workfiles/data_water_quality.dta", replace
