use  "Intermediate Files/LAUS-JOLTS-UIB.dta", clear

merge m:1 st_county_cd using All-States-All-County-with-Nonmodal-Pop-Moments.dta, nogen

merge m:1 st_county_cd using border-counties.dta, nogen

egen st_bound=group(near_mode)

gen st1=real(word(subinstr(near_mode, "-", " ",.), 1))
gen st2=real(word(subinstr(near_mode, "-", " ",.), 2))

gen neigh_st=st1 if st_fips==st2
replace neigh_st=st2 if st_fips==st1

gen st1_nm=""
gen st2_nm=""

sum st_fips
local min=r(min)
local max=r(max)
forvalues s=`min'/`max'{
gen temp1=state_nm if st_fips==`s'
egen temp2=mode(temp1)
replace st1_nm=temp2 if st1==`s'
replace st2_nm=temp2 if st2==`s'
drop temp1 temp2
}



gen st_bound_nm=st1_nm+"-"+st2_nm


preserve
keep st_fips year qtr st_name ui_avail_qtr_avg st_bound
duplicates drop
bysort st_bound qtr: egen ui_bound_rank=rank(ui_avail_qtr_avg), track
bysort st_bound qtr: egen temp=max(ui_bound_rank)
gen diff_samp=temp==2
gen treat=ui_bound_rank==2 if diff_samp==1
tab treat
tab treat if qtr>=180 & qtr<=207
drop temp
save RD-State-by-border-Treatment-Status.dta, replace
restore

merge m:1 st_fips year qtr st_bound using RD-State-by-border-Treatment-Status.dta, nogen



/*
Generate Variables
*/

*log unemployment rate
gen ln_unemp=ln(unemp_r)
*"quasi-difference" unemployment rate
xtset st_cn_id qtr
gen ln_unemp_qd=ln_unemp-(0.99)*(1-sep_rate)*f.ln_unemp

*log UI weeks
gen ln_ui=ln(ui_avail_qtr_avg)

merge 1:1 st_county_cd quarter year using  QCEW.dta, nogen keep(master match)

rename wkwage_q_avg wkwage 
gen ln_wkwage=ln(wkwage)

drop emp
merge 1:1 st_county_cd qtr using qwi_2017.dta
drop if st_cn_id==. & _merge==2
drop _merge
xtset st_cn_id qtr
gen earn=f.earnbeg
gen ln_earn=ln(earn)

merge 1:1 st_county_cd qtr using  county-work-pop.dta, nogen keep(master match)

gen ln_emppop=ln(empend/pop_over15)


forvalues m=1/6{
gen double mu`m'_rd=mu`m' if  treat==1
replace mu`m'_rd=((-1)^(`m'))*mu`m' if  treat==0
}
egen st_bound_qtr_id=group(st_bound qtr)
bysort st_bound qtr: egen st_bound_qtr_obs=count(ln_unemp) if  diff_samp==1 & ln_ui<. & ln_unemp<. 
egen st_by_bound=group(st_fips st_bound)

gen bbd_samp1=qtr>179 & qtr<208




merge m:1 st_county_cd using county-total-population.dta, nogen

total POP10_TOTAL
gen wgt=POP10_TOTAL/_b[POP10_TOTAL]


set seed 573947294
gen ran=runiform()
bysort st_bound qtr st_fips: egen temp1=min(ran)
bysort st_bound qtr: egen temp2=min(temp1)
gen treat_pran=temp1>temp2
drop temp* ran

bysort st_county_cd: egen temp=mean(treat)
gen treat_puidiff=temp>.5
set seed 3432356
gen ran=runiform()
bysort st_fips st_bound: egen temp2=min(ran)
bysort  st_bound: egen temp3=min(temp2)
replace treat_puidiff=1 if temp==.5 & temp3==temp2
drop temp* ran

merge m:1 st_fips st_bound qtr using placebo-trigger-treat.dta, nogen keep(master match)

save BBD-RD-No-Drop.dta, replace

keep if bbd_samp1==1 & border_county==1 & ln_ui<. 

keep st_county_cd st_fips state_nm year qtr quarter diff_samp treat_pran treat_puidiff treat_p4 treat_p5 mu1 mu2 mu3 mu4 mu5 mu6 near_mode neigh_st st_bound st_bound_nm treat ln_unemp ln_unemp_qd ln_wkwage ln_earn ln_emppop ln_ui st_bound_qtr_id st_by_bound wgt

save BBD-RD.dta, replace
