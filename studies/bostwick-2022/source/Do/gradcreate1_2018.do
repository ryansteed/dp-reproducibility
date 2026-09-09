clear

cd "$PATH/Academic Calendar"

quietly do ./do/grad1991.do
quietly do ./do/grad1992.do
quietly do ./do/grad1993.do
quietly do ./do/grad1994.do
quietly do ./do/grad1995.do
quietly do ./do/grad1996.do
quietly do ./do/grad1997.do
quietly do ./do/grad1998.do
quietly do ./do/grad1999.do
quietly do ./do/grad2000.do
quietly do ./do/grad2001.do
quietly do ./do/grad2002.do
quietly do ./do/grad2003.do
quietly do ./do/grad2004.do
quietly do ./do/grad2005.do
quietly do ./do/grad2006.do
quietly do ./do/grad2007.do
quietly do ./do/grad2008.do
quietly do ./do/grad2009.do
quietly do ./do/grad2010.do


use ./data/grad2010.dta
append using ./Data/grad2009.dta, force
append using ./Data/grad2008.dta, force
append using ./Data/grad2007.dta, force
append using ./Data/grad2006.dta, force
append using ./Data/grad2005.dta, force
append using ./Data/grad2004.dta, force
append using ./Data/grad2003.dta, force
append using ./Data/grad2002.dta, force
append using ./Data/grad2001.dta, force
append using ./Data/grad2000.dta, force
append using ./Data/grad1999.dta, force
append using ./Data/grad1998.dta, force
append using ./Data/grad1997.dta, force
append using ./Data/grad1996.dta, force
append using ./Data/grad1995.dta, force
append using ./Data/grad1994.dta, force
append using ./Data/grad1993.dta, force
append using ./Data/grad1992.dta, force
append using ./Data/grad1991.dta, force

order unitid year
sort unitid year

xtset unitid year


*Entering Cohort from 1994 is missing 4 year graduation data.
*A linear interpolation is used to fill in the missing year.


gen nonurm_4yrgrads=(tot4yrgrads-urm_4yrgrads)
gen nonurm_6yrgrads=(tot6yrgrads-urm_6yrgrads)
gen nonurm_cohort=(totcohort-urm_cohort)

gen count=1
bys unitid: egen totalcount=sum(count)

*non-interpolated non-urm graduation rates
gen nonurmgradrate4yr=nonurm_4yrgrads/nonurm_cohort
gen nonurmgradrate6yr=nonurm_6yrgrads/nonurm_cohort

/*
replace gradrate4yr=0 if gradrate4yr==. & totcohort!=. & year!=1994
replace mengradrate4yr=0 if mengradrate4yr==. & totcohort!=. & year!=1994
replace womengradrate4yr=0 if womengradrate4yr==. & totcohort!=. & year!=1994
replace urmgradrate4yr=0 if urmgradrate4yr==. & totcohort!=. & year!=1994
replace nonurmgradrate4yr=0 if nonurmgradrate4yr==. & totcohort!=. & year!=1994

replace gradrate6yr=0 if gradrate6yr==. & totcohort!=.
replace mengradrate6yr=0 if mengradrate6yr==. & totcohort!=.
replace womengradrate6yr=0 if womengradrate6yr==. & totcohort!=.
replace urmgradrate6yr=0 if urmgradrate6yr==. & totcohort!=.
replace nonurmgradrate6yr=0 if nonurmgradrate6yr==. & totcohort!=.
*/

*1994 interpolated 4-year graduation rates
bys unitid: ipolate gradrate4yr year if year>=1993 & year<=1995, gen(gradrate4yr_ipolate)
bys unitid: ipolate mengradrate4yr  year if year>=1993 & year<=1995, gen(mengradrate4yr_ipolate)
bys unitid: ipolate womengradrate4yr  year if year>=1993 & year<=1995, gen(womengradrate4yr_ipolate)
bys unitid: ipolate urmgradrate4yr year if year>=1993 & year<=1995, gen(urmgradrate4yr_ipolate)
bys unitid: ipolate nonurmgradrate4yr year if year>=1993 & year<=1995, gen(nonurmgradrate4yr_ipolate)

replace gradrate4yr_ipolate=gradrate4yr if year!=1994
replace mengradrate4yr_ipolate=mengradrate4yr if year!=1994
replace womengradrate4yr_ipolate=womengradrate4yr if year!=1994
replace urmgradrate4yr_ipolate=urmgradrate4yr if year!=1994
replace nonurmgradrate4yr_ipolate=nonurmgradrate4yr if year!=1994

drop *5yrgrads
drop *5yr

save ./data/gradmaster1_2018.dta, replace

