
********************************************************************************
global data "./data"


use "$data/census_cl2.dta",clear
label variable s06p04a "anio de nacimiento"
label variable s06p03a "edad"
label variable s06p01 "relacion o parentesco"
label variable s06p02 "male 1"
label variable s06p08a1 "Desde cuando vive aca"
label variable s06p08a2 "desde el anio"
label variable s06p09 "Sabe leer o escribir"
label variable s06p11a

label variable s06p04a "anio de nacimiento"
label variable s06p03a "edad"
label variable s06p01 "relacion o parentesco"
label variable s06p02 "male 1"
label variable s06p08a1 "Desde cuando vive aca"
label variable s06p08a2 "desde el anio"
label variable s06p09 "Sabe leer o escribir"
label variable s06p11a

*Age in 1996
gen age1996=1996-s06p04a

*Age restrictions (affected cohorts)
keep if age1996>=7 &age1996<=20

*Adding municipality codes
mmerge depid_c07 municipio_c07 using "$data/municipio.dta"
rename municipio codigo
rename s06p04a yob


*Gangs data
sort codigo
drop _merge
*** EDITED by Ryan Steed
// sort pandillas2003 before merge
preserve
use "$data/pandillas2003.dta", clear
sort codigo
tempfile temp
save `temp', replace
restore
merge codigo using `temp'
***
replace TOTAL=0 if TOTAL==.
gen pandilla=(TOTAL>0)


*IV
gen nacidos3=1 if  codigo==821  |codigo==608| codigo==315 | codigo==515| codigo==617 | codigo==710 | codigo==607| codigo==614 | codigo==613| codigo==602 |codigo==210 |codigo==315 | codigo==821 | codigo==512 | codigo==515 | codigo==1217 | codigo==906 | codigo==511 | codigo==710 | codigo==306| codigo==302|codigo==316
replace nacidos3=0 if nacidos3==.


*Defining variables
gen treat7x9=(age1996==7 | age1996==8 | age1996==9)*pandilla
gen treat10x12=(age1996==10 | age1996==11 | age1996==12)*pandilla
gen treat13x15=(age1996==13 | age1996==14 | age1996==15)*pandilla
gen treat16x18=(age1996==16 | age1996==17 | age1996==18)*pandilla

gen ivtreat7x9=(age1996==7 | age1996==8 | age1996==9)*nacidos3
gen ivtreat10x12=(age1996==10 | age1996==11 | age1996==12)*nacidos3
gen ivtreat13x15=(age1996==13 | age1996==14 | age1996==15)*nacidos3
gen ivtreat16x18=(age1996==16 | age1996==17 | age1996==18)*nacidos3

gen educ_y=0 if s06p11a1==1 | s06p10==3
replace educ_y=0 if (s06p11a1==2 ) & s06p11a2==0
replace educ_y=1 if (s06p11a1==2 ) & s06p11a2==1
replace educ_y=2 if (s06p11a1==2 ) & s06p11a2==2
replace educ_y=3 if (s06p11a1==2 ) & s06p11a2==3
replace educ_y=4 if (s06p11a1==2 ) & s06p11a2==4
replace educ_y=5 if (s06p11a1==2 ) & s06p11a2==5
replace educ_y=6 if (s06p11a1==2 ) & s06p11a2==6
replace educ_y=7 if (s06p11a1==2 ) & s06p11a2==7
replace educ_y=8 if (s06p11a1==2 ) & s06p11a2==8
replace educ_y=9 if (s06p11a1==2 ) & s06p11a2==9

replace educ_y=10 if s06p11a1==3 & s06p11a2==1
replace educ_y=11 if s06p11a1==3 & s06p11a2==2
replace educ_y=12 if s06p11a1==3 & s06p11a2==3
replace educ_y=13 if s06p11a1==3 & s06p11a2==4

replace educ_y=7 if s06p11a1==4 & s06p11a2==1
replace educ_y=8 if s06p11a1==4 & s06p11a2==2
replace educ_y=9 if s06p11a1==4 & s06p11a2==3

replace educ_y=13 if s06p11a1==5 & s06p11a2==1
replace educ_y=14 if s06p11a1==5 & s06p11a2==2
replace educ_y=15 if s06p11a1==5 & s06p11a2>=3

replace educ_y=13 if s06p11a1==6 & s06p11a2==1
replace educ_y=14 if s06p11a1==6 & s06p11a2==2
replace educ_y=15 if s06p11a1==6 & s06p11a2==3

replace educ_y=13 if s06p11a1==7 & s06p11a2==1
replace educ_y=14 if s06p11a1==7 & s06p11a2==2
replace educ_y=15 if s06p11a1==7 & s06p11a2==3
replace educ_y=16 if s06p11a1==7 & s06p11a2==4
replace educ_y=17 if s06p11a1==7 & s06p11a2>=5

replace educ_y=18 if s06p11a1==8 & s06p11a2==1
replace educ_y=19 if s06p11a1==8 & s06p11a2==2
replace educ_y=20 if s06p11a1==8 & s06p11a2==3

replace educ_y=18 if s06p11a1==9 & s06p11a2==1
replace educ_y=19 if s06p11a1==9 & s06p11a2==2
replace educ_y=20 if s06p11a1==9 & s06p11a2==3
replace educ_y=21 if s06p11a1==9 & s06p11a2==4
replace educ_y=22 if s06p11a1==9 & s06p11a2==5

*** RESULTS USING EDU CYCLES
eststo: reghdfe educ_y treat7x9 treat10x12 treat13x15 treat16x18, absorb(i.codigo i.s06p03a) cluster(codigo)
outreg2 treat7x9 treat10x12 treat13x15 treat16x18 using humank2.txt, tex(frag) dec(3) replace addtext(Municipality FE, YES, Cohort FE, YES, Trends, NO, URBAN, NO)

eststo:reghdfe educ_y treat7x9 treat10x12 treat13x15 treat16x18 if s06p08a1==1, absorb(i.codigo i.s06p03a i.codigo#c.s06p03a) cluster(codigo)
outreg2 treat7x9 treat10x12 treat13x15 treat16x18 using humank2.txt, tex(frag) dec(3) append addtext(Municipality FE, YES, Cohort FE, YES, Trends, YES, URBAN, NO)

reghdfe educ_y treat7x9 treat10x12 treat13x15 treat16x18 if areadsc=="URBANO", absorb(i.codigo i.s06p03a i.codigo#c.s06p03a) cluster(codigo)
outreg2 treat7x9 treat10x12 treat13x15 treat16x18 using humank2.txt, tex(frag) dec(3) append addtext(Municipality FE, YES, Cohort FE, YES, Trends, YES, URBAN, NO)

*reghdfe educ_y (treat7x9 treat10x12 treat13x15 treat16x18 = ivtreat7x9 ivtreat10x12 ivtreat13x15 ivtreat16x18) if areadsc=="URBANO", absorb(i.codigo i.s06p03a i.codigo#c.s06p03a) cluster(codigo)
*outreg2 treat7x9 treat10x12 treat13x15 treat16x18 using humank2.txt, tex(frag) dec(3) append addtext(Municipality FE, YES, Cohort FE, YES, Trends, YES, URBAN, NO)
estout using "./../../results/table.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace
save final.dta, replace


