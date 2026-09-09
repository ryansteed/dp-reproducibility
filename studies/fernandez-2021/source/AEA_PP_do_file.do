set more off
clear
*** This code reproduces the results for Medical Residents *****
import excel "aamc_data.xlsx", sheet("Sheet1") firstrow
gen treat =0
replace treat =1 if State=="Puerto Rico" & Year > 2017
label var treat "Act14/Hurricane Maria"
label var MUA_PCT "Pct in MUA"
label var Percent_in_state "Pct in State"
areg MUA_PCT treat i.Year, a(State) cluster(State)
outreg2 using MUA.doc, replace label ctitle(Pct in MUA) keep(treat) addtext(State FE, YES, Year FE, YES)
areg Percent_in_state treat i.Year, a(State) cluster(State)
outreg2 using MUA.doc, append label ctitle(Pct in State) keep(treat) addtext(State FE, YES, Year FE, YES)

gen tot_MUA = MUA+ Non_MUA
encode State, gen(state2)
xtset state2 Year
label var MUA "No. of Resident in MUA"
xtpoisson MUA treat i.Year, fe e(tot_MUA) r
outreg2 using MUA.doc, append label ctitle(No. of Resident in MUA) keep(treat) addtext(State FE, YES, Year FE, YES)
label var Number_in_state "No. of Residents remain in State"
gen tot_state = Number_in_state + Number_out_of_state 
xtpoisson  Number_in_state treat i.Year, fe e(tot_state) r
outreg2 using MUA.doc, append label ctitle(No. of Residents remain in State) keep(treat) addtext(State FE, YES, Year FE, YES)


**** This code replicates the results use for Table 2 in the paper ******

clear
use "oes_2000_2019_modified.dta", clear
drop if pop_==.
drop treat
destring tot_emp, replace force
gen treat = 0
replace treat = 1 if area =="72" & year>2017
gen treat2008 = 0
replace treat2008 =1 if area =="72" & year>2007
gen treat_2014 = 0
replace treat_2014 = 1 if area =="72" & year>2014
label var treat "Act14/Hurricane Maria"
label var treat2008 "Great Recession"
label var treat_2014 "Junk Bond Status"

eststo: xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-0000" ,fe r i(state_fips) 
outreg2 using OES_level_poisson.doc, replace label ctitle(All Healthcare Providers) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1062" ,fe r i(state_fips) 
outreg2 using OES_level_poisson.doc, append label ctitle(Family Medicine) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1063" ,fe r i(state_fips) 
outreg2 using OES_level_poisson.doc, append label ctitle(Internal Medicine) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1065" ,fe r i(state_fips) 
outreg2 using OES_level_poisson.doc, append label ctitle(Pediatrics) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1069" ,fe r i(state_fips)
outreg2 using OES_level_poisson.doc, append label ctitle(Other Physicians & Surgeons) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES) 
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1111" ,fe r i(state_fips) 
outreg2 using OES_level_poisson.doc, append label ctitle(Registered Nurses) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)

xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-0000" ,fe r i(state_fips) e(pop)
outreg2 using OES_level_poisson_per.doc, replace label ctitle(All Healthcare Providers) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1062" ,fe r i(state_fips) e(pop)
outreg2 using OES_level_poisson_per.doc, append label ctitle(Family Medicine) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1063" ,fe r i(state_fips) e(pop)
outreg2 using OES_level_poisson_per.doc, append label ctitle(Internal Medicine) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1065" ,fe r i(state_fips) e(pop)
outreg2 using OES_level_poisson_per.doc, append label ctitle(Pediatrics) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1069" ,fe r i(state_fips) e(pop)
outreg2 using OES_level_poisson_per.doc, append label ctitle(Other Physicians & Surgeons) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
xtpoisson tot_emp treat treat2008 treat_2014 i.year if occ_code=="29-1111" ,fe r i(state_fips) e(pop)
outreg2 using OES_level_poisson_per.doc, append label ctitle(Registered Nurses) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
*** EDITED by Ryan
estout using "../results/table.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
eststo clear
***
* Notes
*29-1011	Chiropractors	29-1011	Chiropractors
*29-1021	Dentists, General	29-1021	Dentists, General
*29-1022	Oral and Maxillofacial Surgeons	29-1022	Oral and Maxillofacial Surgeons
*29-1023	Orthodontists	29-1023	Orthodontists
*29-1024	Prosthodontists	29-1024	Prosthodontists
*29-1029	Dentists, All Other Specialists	29-1029	Dentists, All Other Specialists
*29-1031	Dietitians and Nutritionists	29-1031	Dietitians and Nutritionists
*29-1041	Optometrists	29-1041	Optometrists
*29-1051	Pharmacists	29-1051	Pharmacists
*29-1061	Anesthesiologists	29-1061	Anesthesiologists
*29-1062	Family and General Practitioners	29-1062	Family and General Practitioners
*29-1063	Internists, General	29-1063	Internists, General
*29-1064	Obstetricians and Gynecologists	29-1064	Obstetricians and Gynecologists
*29-1065	Pediatricians, General	29-1065	Pediatricians, General
*29-1066	Psychiatrists	29-1066	Psychiatrists
*29-1067	Surgeons	29-1067	Surgeons
*29-1069	Physicians and Surgeons, All Other	29-1069	Physicians and Surgeons, All Other
*29-1071	Physician Assistants	29-1071	Physician Assistants
*29-1081	Podiatrists	29-1081	Podiatrists
*29-1111	Registered Nurses*	29-1141	Registered Nurses
*29-1111	Registered Nurses*	29-1151	Nurse Anesthetists
*29-1111	Registered Nurses*	29-1161	Nurse Midwives
*29-1111	Registered Nurses*	29-1171	Nurse Practitioners
*29-1121	Audiologists	29-1181	Audiologists
*29-1122	Occupational Therapists	29-1122	Occupational Therapists
*29-1123	Physical Therapists	29-1123	Physical Therapists
*29-1124	Radiation Therapists	29-1124	Radiation Therapists
*29-1125	Recreational Therapists	29-1125	Recreational Therapists
*29-1126	Respiratory Therapists	29-1126	Respiratory Therapists
*29-1127	Speech-Language Pathologists	29-1127	Speech-Language Pathologists
*29-1129	Therapists, All Other*	29-1128	Exercise Physiologists
*29-1129	Therapists, All Other*	29-1129	Therapists, All Other
*29-1131	Veterinarians	29-1131	Veterinarians
*29-1199	Health Diagnosing and Treating Practitioners, All Other	29-1199	Health Diagnosing and Treating Practitioners, All Other
*29-2011	Medical and Clinical Laboratory Technologists	29-2011	Medical and Clinical Laboratory Technologists
*29-2012	Medical and Clinical Laboratory Technicians	29-2012	Medical and Clinical Laboratory Technicians
*29-2021	Dental Hygienists	29-2021	Dental Hygienists
*29-2031	Cardiovascular Technologists and Technicians	29-2031	Cardiovascular Technologists and Technicians
*29-2032	Diagnostic Medical Sonographers	29-2032	Diagnostic Medical Sonographers
*29-2033	Nuclear Medicine Technologists	29-2033	Nuclear Medicine Technologists
*29-2034	Radiologic Technologists and Technicians*	29-2034	Radiologic Technologists 
*29-2034	Radiologic Technologists and Technicians*	29-2035 	Magnetic Resonance Imaging Technologists
*29-2041	Emergency Medical Technicians and Paramedics	29-2041	Emergency Medical Technicians and Paramedics
*29-2051	Dietetic Technicians	29-2051	Dietetic Technicians
*29-2052	Pharmacy Technicians	29-2052	Pharmacy Technicians
*29-2053	Psychiatric Technicians	29-2053	Psychiatric Technicians
*29-2054	Respiratory Therapy Technicians	29-2054	Respiratory Therapy Technicians
*29-2055	Surgical Technologists	29-2055	Surgical Technologists
*29-2056	Veterinary Technologists and Technicians	29-2056	Veterinary Technologists and Technicians
*29-2061	Licensed Practical and Licensed Vocational Nurses	29-2061	Licensed Practical and Licensed Vocational Nurses
*29-2071	Medical Records and Health Information Technicians	29-2071	Medical Records and Health Information Technicians
*29-2081	Opticians, Dispensing	29-2081	Opticians, Dispensing
*29-2091	Orthotists and Prosthetists	29-2091	Orthotists and Prosthetists
*29-2099	Health Technologists and Technicians, All Other*	29-2092	Hearing Aid Specialists
*29-2099	Health Technologists and Technicians, All Other*	29-2057	Ophthalmic Medical Technicians
*29-2099	Health Technologists and Technicians, All Other*	29-2099	Health Technologists and Technicians, All Other
*29-9011	Occupational Health and Safety Specialists	29-9011	Occupational Health and Safety Specialists
*29-9012	Occupational Health and Safety Technicians	29-9012	Occupational Health and Safety Technicians
*29-9091	Athletic Trainers	29-9091	Athletic Trainers
*29-9099	Healthcare Practitioners and Technical Workers, All Other*	29-9092	Genetic Counselors
*29-9099	Healthcare Practitioners and Technical Workers, All Other*	29-9099	Healthcare Practitioners and Technical Workers, All Other
clear
use "pr_county_estab.dta"
drop if i_pop==.
drop treat*
gen treat = 0
gen treat2008 = 0
gen treat_2014 = 0
replace treat_2014 = 1 if state_fips ==72 & year>2014

replace treat = 1 if state_fips ==72 & year>2017
replace treat2008 =1 if state_fips ==72 & year>2007

label var treat "Act14/Hurricane Maria"
label var treat2008 "Great Recession"
label var treat_2014 "Junk Bond Status"

eststo: xtpoisson qtrly_estabs_count treat* i.time, fe i(area_fips) r 
outreg2 using QCEW_poisson.doc, replace label ctitle(Physicians Office - Level) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)

eststo: xtpoisson qtrly_estabs_count treat* i.time, fe i(area_fips) r e(i_pop)
outreg2 using QCEW_poisson.doc, append label ctitle(Physicians Office - Rate) keep(treat treat_2014) addtext(State FE, YES, Year FE, YES)
estout using "../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

