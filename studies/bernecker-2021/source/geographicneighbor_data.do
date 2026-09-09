set more off

*Creating 8 new variables for putting in the number of waivers for up to 8 neighboring states

gen state_neighbor_1_waivers=.
gen state_neighbor_2_waivers=.
gen state_neighbor_3_waivers=.
gen state_neighbor_4_waivers=.
gen state_neighbor_5_waivers=.
gen state_neighbor_6_waivers=.
gen state_neighbor_7_waivers=.
gen state_neighbor_8_waivers=.

*Filling each of the 8 new variables in turn using the state code and year to identify any of the 2704 observations

forval obs = 1/2704 {
local neighbor1=state_neighbor_1[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor1'" & year==`year')
local experiment_waiver_neighbor1=r(mean)
replace state_neighbor_1_waivers=`experiment_waiver_neighbor1' in `obs'
}

forval obs = 1/2704 {
local neighbor2=state_neighbor_2[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor2'" & year==`year')
local experiment_waiver_neighbor2=r(mean)
replace state_neighbor_2_waivers=`experiment_waiver_neighbor2' in `obs'
}

forval obs = 1/2704 {
local neighbor3=state_neighbor_3[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor3'" & year==`year')
local experiment_waiver_neighbor3=r(mean)
replace state_neighbor_3_waivers=`experiment_waiver_neighbor3' in `obs'
}

forval obs = 1/2704 {
local neighbor4=state_neighbor_4[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor4'" & year==`year')
local experiment_waiver_neighbor4=r(mean)
replace state_neighbor_4_waivers=`experiment_waiver_neighbor4' in `obs'
}

forval obs = 1/2704 {
local neighbor5=state_neighbor_5[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor5'" & year==`year')
local experiment_waiver_neighbor5=r(mean)
replace state_neighbor_5_waivers=`experiment_waiver_neighbor5' in `obs'
}

forval obs = 1/2704 {
local neighbor6=state_neighbor_6[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor6'" & year==`year')
local experiment_waiver_neighbor6=r(mean)
replace state_neighbor_6_waivers=`experiment_waiver_neighbor6' in `obs'
}

forval obs = 1/2704 {
local neighbor7=state_neighbor_7[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor7'" & year==`year')
local experiment_waiver_neighbor7=r(mean)
replace state_neighbor_7_waivers=`experiment_waiver_neighbor7' in `obs'
}

forval obs = 1/2704 {
local neighbor8=state_neighbor_8[`obs']
local year=year[`obs']
sum experiment_waiver if (state_code=="`neighbor8'" & year==`year')
local experiment_waiver_neighbor8=r(mean)
replace state_neighbor_8_waivers=`experiment_waiver_neighbor8' in `obs'
}

*Creating a new variable containing the average number of waivers in all neighboring states

egen waivers_neighbors=rmean(state_neighbor_1_waivers state_neighbor_2_waivers state_neighbor_3_waivers state_neighbor_4_waivers state_neighbor_5_waivers state_neighbor_6_waivers state_neighbor_7_waivers state_neighbor_8_waivers )
