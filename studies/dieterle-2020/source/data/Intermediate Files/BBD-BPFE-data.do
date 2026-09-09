use  LAUS-JOLTS-UIB.dta
merge m:1 st_county_cd using county-total-population.dta, nogen

xtset st_cn_id qtr

/*
Generate Variables
*/

*log unemployment rate
gen ln_unemp=ln(unemp_r)
*"quasi-difference" unemployment rate
gen ln_unemp_qd=ln_unemp-(0.99)*(1-sep_rate)*f.ln_unemp

*log UI weeks
gen ln_ui=ln(ui_avail_qtr_avg)


joinby st_county_cd using county-pairs-for-BLS-LAUS.dta


egen pair_qtr_id=group(pair_id qtr)
bysort pair_id qtr: egen within_pair_qtr_id=rank( st_cn_id), unique
xtset pair_qtr_id within_pair_qtr_id

foreach x of varlist ln_unemp_qd ln_ui {
gen D_`x'=d.`x'
}


gen bbd_samp1=qtr>179 & qtr<208


bysort pair_qtr_id: egen pair_pop=total(POP10_TOTAL)

total pair_pop if qtr==180
gen wgt=pair_pop/_b[pair_pop]


save BBD-bpfe.dta, replace
