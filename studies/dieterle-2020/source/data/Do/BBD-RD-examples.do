* Generate Figure 1
use Data/BBD-RD.dta if diff_samp==1, clear

#delimit ;
keep if (st_bound_nm=="Florida-Georgia" & year==2010 & quarter==1) 
|  (st_bound_nm=="Illinois-Iowa" & year==2011 & quarter==2) 
|  (st_bound_nm=="Oklahoma-Texas" & year==2010 & quarter==4) 
|  (st_bound_nm=="Virginia-WestVirginia" & year==2011 & quarter==3) 
|  (st_bound_nm=="Montana-NorthDakota" & year==2010 & quarter==2) 
|  (st_bound_nm=="Kentucky-Tennesse" & year==2011 & quarter==2)
;
#delimit cr

egen st_bound_qtr_fig=group(st_bound qtr)

forvalues m=1/6{
gen double mu`m'_rd=mu`m' if  treat==1
replace mu`m'_rd=((-1)^(`m'))*mu`m' if  treat==0
}


sum st_bound_qtr_fig
local min=r(min)
local max=r(max)


forvalues b=`min'/`max'{
preserve
keep if  st_bound_qtr_fig==`b' 
local year=year(dofq(qtr))
local quarter=quarter(dofq(qtr))

gen temp1=state_nm if treat==1
egen temp2=mode(temp1)
local st1=temp2
drop temp*
gen temp1=state_nm if treat==0
egen temp2=mode(temp1)
local st0=temp2
drop temp*

gen ui=round(exp(ln_ui))
mean  ui  if treat==0
local ui0= round(_b[ui])

mean  ui  if treat==1
local ui1= round(_b[ui])

gen zero=0

sum mu1_rd
local min=r(min)
local max=r(max)
#delimit ;
twoway lfit ln_unemp mu1_rd  [aweight=wgt] if treat==0, range(.,0) lpattern(solid) lcolor(black)
|| lfit ln_unemp mu1_rd  [aweight=wgt] if treat==1, range(0,.) lpattern(solid) lcolor(black)
|| scatter ln_unemp mu1_rd  [aweight=wgt] if treat==0, msize(vsmall) mfcolor(none)
|| scatter ln_unemp mu1_rd  [aweight=wgt] if treat==1, msize(vsmall) mfcolor(none)
|| lfit ln_unemp zero  [aweight=wgt] if treat==0, range(`min',0) lpattern(dash) lcolor(gray)
|| lfit ln_unemp zero  [aweight=wgt] if treat==1, range(0,`max') lpattern(dash) lcolor(gray)
title(`st0'-`st1' Border Counties: `year' Q`quarter') subtitle(`st0' UI=`ui0' Weeks and `st1' UI=`ui1' Weeks)
ytitle("Log Unemployment") xtitle("Population Weighted Mean Distance to Border")
legend(off)
name(RD`st0'`st1'`year'q`quarter'pw, replace)
;
#delimit cr
restore
}

