* * * * Total Stimulus, excluding DOL money * * * *
*  In this section I make total stimulus variables that exclude DOL money.
*  I believe that Wall Street Journal already excluded the DOL from its estimates.
*  Note that you have to copy the American Progress DOL figures forward.


gen obl_lessDOL = obligations - finaltotalobl_dlrDOL
gen pay_lessDOL = payments - finaltotalpd_dlrDOL
gen ann_lessDOL = announcements - finaltotalpd_dlrDOL

* Replace HHS with medicaid
bysort time: egen total_medicaid = total(medicaid_fy2007)
drop total_medicaid


sort state time

foreach varname of varlist obl_lessDOL pay_lessDOL ann_lessDOL {
	gen `varname'_mill_cap = `varname'/(StatePopulation*1000)
	replace `varname'_mill_cap = `varname'_mill_cap / 1000000
}

