clear
set more off

insheet using mayer_data.csv

gen year = floor(t)
tab year

tab msa

sort msa t

bys msa: egen lcl_mean = mean(lcl_sec_sales_frac) if year >= 2002 & year <= 2005
bys msa: egen dis_mean = mean(dis_sec_sales_frac) if year >= 2002 & year <= 2005
sort msa lcl_mean
by msa: replace lcl_mean = lcl_mean[1] 
sort msa dis_mean
by msa: replace dis_mean = lcl_mean[1] 

replace year = 2003 if year == 2002
replace year = 2005 if year == 2004
keep if year == 2003 | year == 2005

collapse (mean) own_occ_sales *frac *_mean, by(msa year)

sort msa year
by msa: gen lcl_diff = lcl_sec_sales_frac - lcl_sec_sales_frac[_n-1]
by msa: gen dis_diff = dis_sec_sales_frac - dis_sec_sales_frac[_n-1]

keep if dis_diff < .
drop *frac

count
list

gen metarea = .

replace metarea = 72 if msa == "Baltimore"
replace metarea = 152 if msa == "Charlotte"
replace metarea = 164 if msa == "Cincinnati"
replace metarea = 168 if msa == "Cleveland"
replace metarea = 208 if msa == "Denver"
replace metarea = 359 if msa == "Jacksonville"
replace metarea = 412 if msa == "Las Vegas"
replace metarea = 448 if msa == "Los Angeles"
replace metarea = 500 if msa == "Miami"
replace metarea = 508 if msa == "Milwaukee"
replace metarea = 512 if msa == "Minneapolis"
replace metarea = 596 if msa == "Orlando"
replace metarea = 616 if msa == "Philadelphia"
replace metarea = 620 if msa == "Phoenix"
replace metarea = 678 if msa == "Riverside"
replace metarea = 692 if msa == "Sacramento"
replace metarea = 732 if msa == "San Diego"
replace metarea = 736 if msa == "San Francisco"
replace metarea = 740 if msa == "San Jose"
replace metarea = 828 if msa == "Tampa"
replace metarea = 884 if msa == "Washington"

count
sort metarea
merge metarea using ./fhfa/metarea_vol.dta
tab _merge, missing
keep if _merge == 3 | _merge == 1
gen dataquick = (_merge == 3) 
collapse (mean) dis_diff total_vol own_occ_sales, by(metarea dataquick)

assert metarea < .

sort metarea
save mayer_data.dta, replace


