set more off

*Creating 8 new variables for putting in the number of waivers for 4 "population size neighboring" states

gen pop_neighbor_1_waivers=.
gen pop_neighbor_2_waivers=.
gen pop_neighbor_3_waivers=.
gen pop_neighbor_4_waivers=.

*Filling each of the 4 new variables in turn using the state code and year to identify any of the 2704 observations

forval obs = 1/2704 {
local neighbor1=pop_neighbor_1[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor1'" & year==`year')
local experiment_waiver_neighbor1=r(mean)
replace pop_neighbor_1_waivers=`experiment_waiver_neighbor1' in `obs'
}

forval obs = 1/2704 {
local neighbor2=pop_neighbor_2[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor2'" & year==`year')
local experiment_waiver_neighbor2=r(mean)
replace pop_neighbor_2_waivers=`experiment_waiver_neighbor2' in `obs'
}

forval obs = 1/2704 {
local neighbor3=pop_neighbor_3[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor3'" & year==`year')
local experiment_waiver_neighbor3=r(mean)
replace pop_neighbor_3_waivers=`experiment_waiver_neighbor3' in `obs'
}

forval obs = 1/2704 {
local neighbor4=pop_neighbor_4[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor4'" & year==`year')
local experiment_waiver_neighbor4=r(mean)
replace pop_neighbor_4_waivers=`experiment_waiver_neighbor4' in `obs'
}

*Creating a new variable containing the average number of waivers in all neighboring states

egen waivers_pop_neighbors=rmean(pop_neighbor_1_waivers pop_neighbor_2_waivers pop_neighbor_3_waivers pop_neighbor_4_waivers)
