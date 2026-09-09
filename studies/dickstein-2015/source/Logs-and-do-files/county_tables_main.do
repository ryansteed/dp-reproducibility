** Dickstein, Duggan, Orsini, Tebaldi
** The Impact of Market Size and Competition on Health Insurance Premiums: Evidence from the First Year of the Affordable Care Act


* this DO files generates log file for main county regressions

log using "County_tables_all_counties" , replace

*** EDIT by Donna
use county_data_P-P.dta , clear
label var dedS51 "Deductible"

*** EDIT by Donna
* capture{
* "regression of premium on controls, state FE, and group indicators (clustering st.err. at the region level)"
eststo: areg SP51 i.Gr ded  , a(state) cl(region_post)
est store r0
eststo: areg SP51 i.Gr ded  Median Inc_25k_100k  GAF relold   smallem    hosp, a(state) cl(region_post)
est store r1

* "regression of N. insurers on controls, state FE, and group indicators (clustering st.err. at the region level)"
eststo: areg Nins i.Gr  , a(state) cl(region_post)
est store r2
eststo: areg Nins i.Gr  Median    Inc_25k_100k  GAF relold   smallem    hosp, a(state) cl(region_post)
est store r3
* }

* est tab r* ,   se stats(N r2_a)   label

estout using "../../results/county.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace


log close


