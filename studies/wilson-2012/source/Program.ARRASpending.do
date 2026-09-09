* * * * ARRA spending over agencies * * * *
*  We also need, for every state, the total per capita ARRA spending by summing the financial
*  activity reports, and dividing by the number of people
*  in each state. The department of State, the FCC, the GSA, NASA, the RRB,
*  the SBA, the SI, and the VA were all missing either obligations or payments.
*  So I add up all of the values of the non-missing data for 
*  obligations, payments, announcemtns, and wall street journal announcements
*  and put them into new variables.

*  The haver population data is in thousands of people, so I multiply the denominator of the per
*  capita obligations by 1,000. I do the same thing for the Wall Street Journal amounts, then because
*  we are assigning this amount to be a constant, I copy it forward so that we can have access to it at
*  later observations.

*  I also calculate the American Progress per capita amount, and copy it forward so we can use in the regression.

gen obligations   = 0
gen payments      = 0
gen announcements = 0

qui: desc finaltotalobl_dlr*, varlist
foreach variable in `r(varlist)' {
	replace obligations = obligations + `variable' if `variable' ~= .
	}

qui: desc finaltotalpd_dlr*, varlist
foreach variable in `r(varlist)' {
	replace payments = payments + `variable' if `variable' ~= .
	}

qui: desc Announced*, varlist
foreach variable in `r(varlist)'{
	replace announcements = announcements + `variable' if `variable' ~= .
	}

generate obligations_percapita   = obligations   / (StatePopulation*1000)
generate payments_percapita      = payments      / (StatePopulation*1000)
generate announcements_percapita = announcements / (StatePopulation*1000)

