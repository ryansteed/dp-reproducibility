*Policy Effects Years 4+ FOCS or GNCS
*focs - men
lincom focs
*focs - women
lincom focs+f_focs

*gncs - men
eststo: lincom gncs
*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*gncs - women - main results
lincom gncs+f_gncs

matrix lincom_table = (r(estimate), r(se), r(t), r(p), r(lb), r(ub))

lincom -f_gncs
matrix new_row = (r(estimate), r(se), r(t), r(p), r(lb), r(ub))
matrix lincom_table = lincom_table \ new_row
matrix colnames lincom_table = est se t p lb ub
matrix rownames lincom_table = female difference

clear
version 17
svmat lincom_table, names(col)
gen str20 label = ""
replace label = "female" in 1
replace label = "difference" in 2
order label
rename label var
export delimited using "../../results/lincom_result.csv", replace
drop est se t p lb ub

* (gncs-focs) male
* lincom gncs-focs
* (gncs-focs) female
* lincom gncs+f_gncs - focs - f_focs
* (male-female) focs
* lincom -f_focs
* (male-female) gncs - main results

/*
*Policy Effects Years 0-3 of FOCS or GNCS
* early focs - men
lincom focs+focs0
* early focs - women
lincom focs+f_focs+focs0+f_focs0
* early gncs - men
lincom gncs+gncs0
* early gncs - women
lincom gncs+f_gncs+gncs0+f_gncs0
* early (gncs-focs) male
lincom gncs+gncs0-focs-focs0
* early (gncs-focs) female
lincom gncs+f_gncs+gncs0+f_gncs0-focs-f_focs-focs0-f_focs0
* early (male-female) focs
lincom -f_focs-f_focs0
* early (male-female) gncs
lincom -f_gncs-f_gncs0
*/