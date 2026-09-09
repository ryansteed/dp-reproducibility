** Dickstein, Duggan, Orsini, Tebaldi
** The Impact of Market Size and Competition on Health Insurance Premiums: Evidence from the First Year of the Affordable Care Act


* this DO files generates log file for county regressions with distance restriction

use county_data_P&P_distance_restriction.dta , clear

log using "County_tables_distance" , replace

gen ELIGIBLE = (distance<100)

capture {
areg SP51 Gr ded   if ELIGIBLE==1, a(state) rob
est store PriceFE_e0
areg SP51 Gr ded  Median Inc_25k_100k  GAF  relold   smallem    hosp if ELIGIBLE==1, a(state) rob
est store PriceFE_e1


areg Nins Gr    if ELIGIBLE==1, a(state) rob
est store InsFE_e0
areg Nins Gr   Median Inc_25k_100k  GAF  relold   smallem    hosp if ELIGIBLE==1, a(state) rob
est store InsFE_e1
}

est tab Price* ,   se stats(N r2_a)   label
est tab Ins* , se stats(N r2_a) label

log close


