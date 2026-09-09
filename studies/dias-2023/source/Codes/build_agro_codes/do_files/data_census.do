********************************************************************************
*** Build: Census Data
********************************************************************************

*
use using "$pathfiles_censusdata/Censo00_AC_pes_comp.dta", clear
append using "$pathfiles_censusdata/Censo10_AC_pes_comp.dta", force

foreach y in 00 10{
foreach f in AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO{

append using "$pathfiles_censusdata/Censo`y'_`f'_pes_comp.dta", force

}
}

drop id_dom

**********************************************

keep munic ano peso_pess ativ2000 rend_ocup_prin_def idade pos_ocup_sem sit_setor_C rend_total_def alfabetizado nacionalidade

gen n_work_agr=.
replace n_work_agr=peso_pess*inrange(ativ2000,01000,09999)
gen n_work_manuf=.
replace n_work_manuf=peso_pess*inrange(ativ2000,15000,37999)
gen n_work_any=.
replace n_work_any=peso_pess if ativ2000!=.

gen avg_wage_manuf=peso_pess*rend_ocup_prin_def if(idade>=10 & inrange(ativ2000,15000,37999)==1 & (pos_ocup_sem==1|pos_ocup_sem==3))
gen sum_weight_manuf=peso_pess if(idade>=10 & inrange(ativ2000,15000,37999)==1  & (pos_ocup_sem==1|pos_ocup_sem==3))

gen avg_wage_agr=peso_pess*rend_ocup_prin_def if(idade>=10 & inrange(ativ2000,01000,09999)==1 & (pos_ocup_sem==1|pos_ocup_sem==3))
gen sum_weight_agr=peso_pess if(idade>=10 & inrange(ativ2000,01000,09999)==1  & (pos_ocup_sem==1|pos_ocup_sem==3))

gen n_pop_rural=peso_pess*sit_setor_C

gen avg_income=.
replace avg_income=peso_pess*rend_total_def if(inrange(idade,10,60)==1 & rend_total_def>0)
gen sum_weight_income=peso_pess if(inrange(idade,10,60)==1 & rend_total_def>0)

gen n_literate=peso_pess*alfabetizado if(idade>=10)

gen pop_for_mig_rate=peso_pess if( ((inrange(idade,10,60)==1 & ano==2000) | (inrange(idade,20,70)==1 & ano==2010)) & nacionalidade==0 )

collapse (sum) n_work_* avg_wage* sum_weight_* n_pop_rural avg_income n_literate pop_for_mig_rate peso_pess, by(munic ano)

* Merge AMC codes
rename munic code_mun
merge m:1 code_mun using "$pathfiles_data/Originais/amcs_br.dta"
drop _merge

collapse (sum) n_work_* avg_wage* sum_weight_* n_pop_rural avg_income n_literate pop_for_mig_rate peso_pess, by(AMC ano)


gen empl_share_agr=n_work_agr/n_work_any
gen empl_share_manuf=n_work_manuf/n_work_any
drop n_work_agr n_work_manuf n_work_any

replace avg_wage_agr=log(avg_wage_agr/sum_weight_agr)
replace avg_wage_manuf=log(avg_wage_manuf/sum_weight_manuf)
replace avg_income=log(avg_income/sum_weight_income)

gen aux_migration=pop_for_mig_rate if(ano==2000)
by AMC: egen pop_mig_initial=max(aux_migration)
drop aux_migration

summarize pop_for_mig_rate if ano==2000
local popmigbr2000=r(sum)
summarize pop_for_mig_rate if ano==2010
local popmigbr2010=r(sum)

gen survival_rate=`popmigbr2010'/`popmigbr2000'
gen forward_surv=pop_for_mig_rate-survival_rate*pop_mig_initial if ano==2010
gen reverse_surv=pop_for_mig_rate/survival_rate-pop_mig_initial if ano==2010
gen net_migrants=(forward_surv+reverse_surv)/2
drop forward_surv reverse_surv pop_mig_initial pop_for_mig_rate
* We get the net migration rate by dividing net_migrants by population in 2000 for each municipality

rename ano year

save "$pathfiles_data/Workfiles/data_census.dta", replace


