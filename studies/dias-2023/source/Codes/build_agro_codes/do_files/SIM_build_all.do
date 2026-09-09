********************************************************************************
* Build: Infant and Maternal Mortality
********************************************************************************

clear*
set more off , permanently


use "${datasus}/SIM_micro.dta", clear
count // 19,208,779


* Restrict sample and variables
* Restrict sample and variables
drop if mun_res==. | mun_res==0
drop if mun_res<110001
drop if idade>=400 & d_fem==0
keep mun_res idade d_fet d_fem capcid_cau cid_cau dtnasc

drop if dtnasc==.
tostring dtnasc, gen(nasc)
gen ano=""
gen mes=""

* if strlen(nasc)==4, only have info on birth year
replace ano=substr(nasc,2,4) if strlen(nasc)==5
replace mes=substr(nasc,1,1) if strlen(nasc)==5

replace ano=substr(nasc,3,4) if strlen(nasc)==6
replace mes=substr(nasc,1,2) if strlen(nasc)==6

replace ano=substr(nasc,4,4) if strlen(nasc)==7
replace mes=substr(nasc,2,2) if strlen(nasc)==7

replace ano=substr(nasc,5,4) if strlen(nasc)==8
replace mes=substr(nasc,3,2) if strlen(nasc)==8

destring ano mes, replace

keep if inrange(ano,1998,2010)==1

count //916,641


********************************************************************************
* Babies


gen baby_death=(idade<400 & idade!=.)
gen baby_death_fetal=(d_fet==1)
gen baby_death_girl=(idade<400 & idade!=. & d_fem==1)
gen baby_death_boy=(idade<400 & idade!=. & d_fem==0)
gen baby_death_24hs=(idade<=200 & idade!=.)
gen baby_death_27days=(idade>200 & idade<=227)
gen baby_death_year=(idade>227 & idade<400)
foreach i in baby_death baby_death_24hs baby_death_27days baby_death_year baby_death_girl baby_death_boy {
replace `i'=. if d_fet==1
}
gen baby_death_infectious=(idade<400 & idade!=. & capcid==1)
gen baby_death_respiratory=(idade<400 & idade!=. & capcid==10)
gen baby_death_perinatal=(idade<400 & idade!=. & capcid==16)
gen baby_death_congenital=(idade<400 & idade!=. & capcid==17)
gen baby_death_external=(idade<400 & idade!=. & capcid==19)
gen baby_death_endocrine=(idade<400 & idade!=. & capcid==4 & substr(cid_cau,1,1)=="E" & inrange(real(substr(cid_cau,2,2)),00,35))
gen baby_death_nutrition=(idade<400 & idade!=. & capcid==4 & substr(cid_cau,1,1)=="E" & inrange(real(substr(cid_cau,2,2)),40,90))
gen baby_death_genito=(idade<400 & idade!=. & capcid==7 & substr(cid_cau,1,1)=="N")
gen baby_death_illdef=(idade<400 & idade!=. & capcid==22)
gen baby_death_others=(idade<400 & idade!=. & capcid!=1  & capcid!=17  & capcid!=4 &  capcid!=22 & capcid!=16 & capcid!=10 & capcid!=19 & baby_death_genito!=1) 
/* others ~4% --> tab capcid_cau baby_death_others if idade<400 & idade!=., mis */
foreach i in baby_death_infectious baby_death_respiratory baby_death_perinatal baby_death_congenital baby_death_external baby_death_endocrine baby_death_nutrition baby_death_genito baby_death_illdef baby_death_others {
replace `i'=. if d_fet==1
}


* Detail causes if perinatal
gen baby_death_perlenght =1 if substr(cid_cau,1,1)=="P" & inrange(real(substr(cid_cau,2,2)),5,8) & idade<400 & idade!=.
gen baby_death_perrespcard =1 if substr(cid_cau,1,1)=="P" & inrange(real(substr(cid_cau,2,2)),20,29) & idade<400 & idade!=.
gen baby_death_perinfct =1 if substr(cid_cau,1,1)=="P" & inrange(real(substr(cid_cau,2,2)),35,39) & idade<400 & idade!=.
gen baby_death_perhaemor =1 if substr(cid_cau,1,1)=="P" & inrange(real(substr(cid_cau,2,2)),50,61) & idade<400 & idade!=.
gen baby_death_perothers = 1 if idade<400 & idade!=.
replace baby_death_perothers=. if capcid!=16 
foreach k in baby_death_perlenght baby_death_perrespcard baby_death_perinfct baby_death_perhaemor {
replace baby_death_perothers=. if `k'==1 
}

gen baby_death_endoc_nut = (baby_death_endocrine==1 | baby_death_nutrition==1)
gen baby_death_affected = (baby_death_endocrine==1 | baby_death_genito==1 | baby_death_perinatal==1)



********************************************************************************
* Mothers
gen mat_death_all=(idade>=410 & idade<=449 & d_fem==1)
gen mat_death_mat=(idade>=410 & idade<=449 & d_fem==1 & capcid==15)





********************************************************************************
* Save and collapse


rename mun_res code_mun
rename ano year



collapse (sum) baby_death* mat_death*, by(year code_mun)
compress
save "$pathfiles_data/Workfiles/SIM_year.dta", replace
