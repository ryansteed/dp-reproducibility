clear
set mem 15g
set maxvar 20000
set matsize 11000

use analysis-data
set more off 

* GENERATE MAIN ANALYSIS VARIABLES *

gen tot_above=tot_above_gr3 if grade==3
replace tot_above=tot_above_gr6 if grade==6
replace tot_above=tot_above_gr8 if grade==8

gen tot_tchr=tot_gr3 if grade==3
replace tot_tchr=tot_gr6 if grade==6
replace tot_tchr=tot_gr8 if grade==8

gen mathscore=g3mtstd if grade==3
replace mathscore=g6mtstd if grade==6
replace mathscore=g8mtstd if grade==8

gen rdscore=g3rdstd if grade==3
replace rdscore=g6rdstd if grade==6
replace rdscore=g8rdstd if grade==8

gen tot_abovem=tot_above_gr3m if grade==3
replace tot_abovem=tot_above_gr6m if grade==6
replace tot_abovem=tot_above_gr8m if grade==8

gen tot_tchrm=tot_gr3m if grade==3
replace tot_tchrm=tot_gr6m if grade==6
replace tot_tchrm=tot_gr8m if grade==8

gen tot_abovee=tot_above_gr3e if grade==3
replace tot_abovee=tot_above_gr6e if grade==6
replace tot_abovee=tot_above_gr8e if grade==8

gen tot_tchre=tot_gr3e if grade==3
replace tot_tchre=tot_gr6e if grade==6
replace tot_tchre=tot_gr8e if grade==8

gen tot_abovenm=tot_above_gr3nm if grade==3
replace tot_abovenm=tot_above_gr6nm if grade==6
replace tot_abovenm=tot_above_gr8nm if grade==8

gen tot_tchrnm=tot_gr3nm if grade==3
replace tot_tchrnm=tot_gr6nm if grade==6
replace tot_tchrnm=tot_gr8nm if grade==8

gen tot_abovene=tot_above_gr3ne if grade==3
replace tot_abovene=tot_above_gr6ne if grade==6
replace tot_abovene=tot_above_gr8ne if grade==8

gen tot_tchrne=tot_gr3ne if grade==3
replace tot_tchrne=tot_gr6ne if grade==6
replace tot_tchrne=tot_gr8ne if grade==8

gen tot_aboveo=tot_above_gr3o if grade==3
replace tot_aboveo=tot_above_gr6o if grade==6
replace tot_aboveo=tot_above_gr8o if grade==8

gen tot_tchro=tot_gr3o if grade==3
replace tot_tchro=tot_gr6o if grade==6
replace tot_tchro=tot_gr8o if grade==8

gen newtchr=newtchr_gr3 if grade==3
replace newtchr=newtchr_gr6 if grade==6
replace newtchr=newtchr_gr8 if grade==8

gen exp=exp_gr3 if grade==3
replace exp=exp_gr6 if grade==6
replace exp=exp_gr8 if grade==8

drop exit
gen exit=exit_gr3 if grade==3
replace exit=exit_gr6 if grade==6
replace exit=exit_gr8 if grade==8

gen exitm=exit_gr3m if grade==3
replace exitm=exit_gr6m if grade==6
replace exitm=exit_gr8m if grade==8

gen exite=exit_gr3e if grade==3
replace exite=exit_gr6e if grade==6
replace exite=exit_gr8e if grade==8

drop enroll
gen enroll=g3enrl if grade==3
replace enroll=g6enrl if grade==6
replace enroll=g8enrl if grade==8

gen pct_above=pct_above_gr3 if grade==3
replace pct_above=pct_above_gr6 if grade==6
replace pct_above=pct_above_gr8 if grade==8

gen pct_abovem=pct_above_gr3m if grade==3
replace pct_abovem=pct_above_gr6m if grade==6
replace pct_abovem=pct_above_gr8m if grade==8

gen pct_abovee=pct_above_gr3e if grade==3
replace pct_abovee=pct_above_gr6e if grade==6
replace pct_abovee=pct_above_gr8e if grade==8

gen pct_abovenm=pct_above_gr3nm if grade==3
replace pct_abovenm=pct_above_gr6nm if grade==6
replace pct_abovenm=pct_above_gr8nm if grade==8

gen pct_abovene=pct_above_gr3ne if grade==3
replace pct_abovene=pct_above_gr6ne if grade==6
replace pct_abovene=pct_above_gr8ne if grade==8

gen pct_aboveo=pct_above_gr3o if grade==3
replace pct_aboveo=pct_above_gr6o if grade==6
replace pct_aboveo=pct_above_gr8o if grade==8

gen post_above=post*tot_above
gen post_abovem=post*tot_abovem
gen post_abovee=post*tot_abovee
gen post_abovenm=post*tot_abovenm
gen post_abovene=post*tot_abovene
gen post_aboveo=post*tot_aboveo

gen post_tottchr=post*tot_tchr
gen post_tottchrm=post*tot_tchrm
gen post_tottchre=post*tot_tchre
gen post_tottchrnm=post*tot_tchrnm
gen post_tottchrne=post*tot_tchrne
gen post_tottchro=post*tot_tchro

gen post_pctabove=post*pct_above
gen post_pctabovem=post*pct_abovem
gen post_pctabovee=post*pct_abovee
gen post_pctabovenm=post*pct_abovenm
gen post_pctabovene=post*pct_abovene
gen post_pctaboveo=post*pct_aboveo

gen post_above_3=post_above if grade==3
replace post_above_3=0 if grade~=3
gen post_above_6=post_above if grade==6
replace post_above_6=0 if grade~=6
gen post_above_8=post_above if grade==8
replace post_above_8=0 if grade~=8

gen post_tottchr_3=post_tottchr if grade==3
replace post_tottchr_3=0 if grade~=3
gen post_tottchr_6=post_tottchr if grade==6
replace post_tottchr_6=0 if grade~=6
gen post_tottchr_8=post_tottchr if grade==8
replace post_tottchr_8=0 if grade~=8

gen post_abovem_3=post_abovem if grade==3
replace post_abovem_3=0 if grade~=3
gen post_abovem_6=post_abovem if grade==6
replace post_abovem_6=0 if grade~=6
gen post_abovem_8=post_abovem if grade==8
replace post_abovem_8=0 if grade~=8

gen post_tottchrm_3=post_tottchrm if grade==3
replace post_tottchrm_3=0 if grade~=3
gen post_tottchrm_6=post_tottchrm if grade==6
replace post_tottchrm_6=0 if grade~=6
gen post_tottchrm_8=post_tottchrm if grade==8
replace post_tottchrm_8=0 if grade~=8

gen post_abovee_3=post_abovee if grade==3
replace post_abovee_3=0 if grade~=3
gen post_abovee_6=post_abovee if grade==6
replace post_abovee_6=0 if grade~=6
gen post_abovee_8=post_abovee if grade==8
replace post_abovee_8=0 if grade~=8

gen post_tottchre_3=post_tottchre if grade==3
replace post_tottchre_3=0 if grade~=3
gen post_tottchre_6=post_tottchre if grade==6
replace post_tottchre_6=0 if grade~=6
gen post_tottchre_8=post_tottchre if grade==8
replace post_tottchre_8=0 if grade~=8

gen tempenroll=enroll if year<=1993
egen avgenroll=mean(tempenroll), by(clusterid)
drop tempenroll

drop clusterid
egen clusterid=group(rcds_fix grade)

drop if tot_tchr>45
drop if tot_tchre>10
drop if tot_tchrm>10
drop if avgenroll>300
drop if enroll>1000

gen enrollsq=enroll*enroll

gen tot3= tot3_tchr1+ tot3_tchr2+ tot3_tchr3+ tot3_tchr4 + tot3_tchr5 + tot3_tchr6_9 + tot3_tchr10_14 + tot3_tchr15_19 + tot3_tchr20_24 + tot3_tchr25_29 + tot3_tchr30_34 + tot3_tchr35_39 + tot3_tchr40
gen tot6= tot6_tchr1+ tot6_tchr2+ tot6_tchr3+ tot6_tchr4 + tot6_tchr5 + tot6_tchr6_9 + tot6_tchr10_14 + tot6_tchr15_19 + tot6_tchr20_24 + tot6_tchr25_29 + tot6_tchr30_34 + tot6_tchr35_39 + tot6_tchr40
gen tot8= tot8_tchr1+ tot8_tchr2+ tot8_tchr3+ tot8_tchr4 + tot8_tchr5 + tot8_tchr6_9 + tot8_tchr10_14 + tot8_tchr15_19 + tot8_tchr20_24 + tot8_tchr25_29 + tot8_tchr30_34 + tot8_tchr35_39 + tot8_tchr40

gen tchrcount=tot3 if grade==3
replace tchrcount=tot6 if grade==6
replace tchrcount=tot8 if grade==8

gen ptrat3=g3enrl/tot3
gen ptrat6=g6enrl/tot6
gen ptrat8=g8enrl/tot8

gen ptrat_full=ptrat3 if grade==3
replace ptrat_full=ptrat6 if grade==6
replace ptrat_full=ptrat8 if grade==8

xtset clusterid

* TABLE 1 *

summ mathscore rdscore tot_above tot_tchr tot_abovem tot_tchrm tot_abovee tot_tchre pblack phisp pasian plep plinc pattd enroll [aw=avgenroll] if year<=1997
summ mathscore rdscore tot_above tot_tchr tot_abovem tot_tchrm tot_abovee tot_tchre pblack phisp pasian plep plinc pattd enroll [aw=avgenroll] if year<=1997 & grade==3
summ mathscore rdscore tot_above tot_tchr tot_abovem tot_tchrm tot_abovee tot_tchre pblack phisp pasian plep plinc pattd enroll [aw=avgenroll] if year<=1997 & grade==6
summ mathscore rdscore tot_above tot_tchr tot_abovem tot_tchrm tot_abovee tot_tchre pblack phisp pasian plep plinc pattd enroll [aw=avgenroll] if year<=1997 & grade==8

* TABLE 3 *

	* Exits *

capture drop temp
capture drop temp2
gen temp=exit if year==1990
egen temp2=mean(temp), by(rcds_fix grade)
gen lag_exit=temp2 if year==1991
drop temp temp2
gen temp=exit if year==1991
egen temp2=mean(temp), by(rcds_fix grade)
replace lag_exit=temp2 if year==1992
drop temp temp2
gen temp=exit if year==1992
egen temp2=mean(temp), by(rcds_fix grade)
replace lag_exit=temp2 if year==1993
drop temp temp2
gen temp=exit if year==1993
egen temp2=mean(temp), by(rcds_fix grade)
replace lag_exit=temp2 if year==1994
drop temp temp2
gen temp=exit if year==1994
egen temp2=mean(temp), by(rcds_fix grade)
replace lag_exit=temp2 if year==1995
drop temp temp2
gen temp=exit if year==1995
egen temp2=mean(temp), by(rcds_fix grade)
replace lag_exit=temp2 if year==1996
drop temp temp2
gen temp=exit if year==1996
egen temp2=mean(temp), by(rcds_fix grade)
replace lag_exit=temp2 if year==1997
drop temp temp2

*** EDIT by Donna

eststo: xi: xtreg lag_exit post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & year>1990 [aw=avgenroll], fe vce(robust)
xi: xtreg lag_exit post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)

	* Experience *

eststo: xi: xtreg exp post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg exp post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

	* New Teachers *

eststo: xi: xtreg newtchr post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg newtchr post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

*** EDITED by Donna
estout using "../../results/table1.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

	* Student-teacher Ratio *

xi: xtreg ptrat_full post_above post_tottchr pblack phisp pasian plep plinc pattd i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg ptrat_full post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

	* Means *

summ ptrat_full lag_exit exp newtchr [aw=avgenroll] if year<=1993
summ ptrat3 lag_exit exp newtchr [aw=avgenroll] if year<=1993 & grade==3
summ ptrat6 lag_exit exp newtchr [aw=avgenroll] if year<=1993 & grade==6
summ ptrat8 lag_exit exp newtchr [aw=avgenroll] if year<=1993 & grade==8

* TABLE 4 *

gen tot_tchr1=tot3_tchr1 if grade==3
replace tot_tchr1=tot6_tchr1 if grade==6
replace tot_tchr1=tot8_tchr1 if grade==8
gen tot_tchr2=tot3_tchr2 if grade==3
replace tot_tchr2=tot6_tchr2 if grade==6
replace tot_tchr2=tot8_tchr2 if grade==8
gen tot_tchr3=tot3_tchr3 if grade==3
replace tot_tchr3=tot6_tchr3 if grade==6
replace tot_tchr3=tot8_tchr3 if grade==8
gen tot_tchr4=tot3_tchr4 if grade==3
replace tot_tchr4=tot6_tchr4 if grade==6
replace tot_tchr4=tot8_tchr4 if grade==8
gen tot_tchr5=tot3_tchr5 if grade==3
replace tot_tchr5=tot6_tchr5 if grade==6
replace tot_tchr5=tot8_tchr5 if grade==8
gen tot_tchr6_9=tot3_tchr6_9 if grade==3
replace tot_tchr6_9=tot6_tchr6_9 if grade==6
replace tot_tchr6_9=tot8_tchr6_9 if grade==8
gen tot_tchr10_14=tot3_tchr10_14 if grade==3
replace tot_tchr10_14=tot6_tchr10_14 if grade==6
replace tot_tchr10_14=tot8_tchr10_14 if grade==8
gen tot_tchr15_19=tot3_tchr15_19 if grade==3
replace tot_tchr15_19=tot6_tchr15_19 if grade==6
replace tot_tchr15_19=tot8_tchr15_19 if grade==8
gen tot_tchr20_24=tot3_tchr20_24 if grade==3
replace tot_tchr20_24=tot6_tchr20_24 if grade==6
replace tot_tchr20_24=tot8_tchr20_24 if grade==8
gen tot_tchr25_29=tot3_tchr25_29 if grade==3
replace tot_tchr25_29=tot6_tchr25_29 if grade==6
replace tot_tchr25_29=tot8_tchr25_29 if grade==8
gen tot_tchr30_34=tot3_tchr30_34 if grade==3
replace tot_tchr30_34=tot6_tchr30_34 if grade==6
replace tot_tchr30_34=tot8_tchr30_34 if grade==8
gen tot_tchr35_39=tot3_tchr35_39 if grade==3
replace tot_tchr35_39=tot6_tchr35_39 if grade==6
replace tot_tchr35_39=tot8_tchr35_39 if grade==8
gen tot_tchr40=tot3_tchr40 if grade==3
replace tot_tchr40=tot6_tchr40 if grade==6
replace tot_tchr40=tot8_tchr40 if grade==8

xi: xtreg tot_tchr1 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr2 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr3 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr4 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr5 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr6_9 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr10_14 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr15_19 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr20_24 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr25_29 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr30_34 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr35_39 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr40 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)

xi: xtreg tot_tchr1 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr2 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr3 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr4 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr5 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr6_9 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr10_14 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr15_19 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr20_24 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr25_29 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr30_34 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr35_39 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr40 post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 [aw=avgenroll], fe vce(robust)

	* Means *

summ tot_tchr* if year<=1993 [aw=enroll] 
summ tot_tchr* if year<=1993 & grade==3 [aw=enroll] 
summ tot_tchr* if year<=1993 & grade==6 [aw=enroll] 
summ tot_tchr* if year<=1993 & grade==8 [aw=enroll] 

* TABLE 5 *

*** EDIT by Donna
eststo m1: xi: xtreg mathscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
eststo m2: xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

eststo m3: xi: xtreg mathscore post_abovem post_tottchrm pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
eststo m4: xi: xtreg rdscore post_abovee post_tottchre pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

estout m1 m2 m3 m4 using "../../results/table2.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

/*
* FIGURES 3 AND 4 *

tab year if year<=1997, gen(ydum)

gen tot_above_1=tot_above*ydum1
gen tot_above_2=tot_above*ydum2
gen tot_above_3=tot_above*ydum3
gen tot_above_4=tot_above*ydum4
gen tot_above_5=tot_above*ydum5
gen tot_above_6=tot_above*ydum6
gen tot_above_7=tot_above*ydum7
gen tot_above_8=tot_above*ydum8

gen tot_1=tot_tchr*ydum1
gen tot_2=tot_tchr*ydum2
gen tot_3=tot_tchr*ydum3
gen tot_4=tot_tchr*ydum4
gen tot_5=tot_tchr*ydum5
gen tot_6=tot_tchr*ydum6
gen tot_7=tot_tchr*ydum7
gen tot_8=tot_tchr*ydum8

gen tot_abovem_1=tot_abovem*ydum1
gen tot_abovem_2=tot_abovem*ydum2
gen tot_abovem_3=tot_abovem*ydum3
gen tot_abovem_4=tot_abovem*ydum4
gen tot_abovem_5=tot_abovem*ydum5
gen tot_abovem_6=tot_abovem*ydum6
gen tot_abovem_7=tot_abovem*ydum7
gen tot_abovem_8=tot_abovem*ydum8

gen totm_1=tot_tchrm*ydum1
gen totm_2=tot_tchrm*ydum2
gen totm_3=tot_tchrm*ydum3
gen totm_4=tot_tchrm*ydum4
gen totm_5=tot_tchrm*ydum5
gen totm_6=tot_tchrm*ydum6
gen totm_7=tot_tchrm*ydum7
gen totm_8=tot_tchrm*ydum8

gen tot_abovee_1=tot_abovee*ydum1
gen tot_abovee_2=tot_abovee*ydum2
gen tot_abovee_3=tot_abovee*ydum3
gen tot_abovee_4=tot_abovee*ydum4
gen tot_abovee_5=tot_abovee*ydum5
gen tot_abovee_6=tot_abovee*ydum6
gen tot_abovee_7=tot_abovee*ydum7
gen tot_abovee_8=tot_abovee*ydum8

gen tote_1=tot_tchre*ydum1
gen tote_2=tot_tchre*ydum2
gen tote_3=tot_tchre*ydum3
gen tote_4=tot_tchre*ydum4
gen tote_5=tot_tchre*ydum5
gen tote_6=tot_tchre*ydum6
gen tote_7=tot_tchre*ydum7
gen tote_8=tot_tchre*ydum8

xi: xtreg mathscore tot_above_1 tot_above_2 tot_above_3 tot_above_5 tot_above_6 tot_above_7 tot_above_8 tot_1 tot_2 tot_3 tot_5 tot_6 tot_7 tot_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore tot_above_1 tot_above_2 tot_above_3 tot_above_5 tot_above_6 tot_above_7 tot_above_8 tot_1 tot_2 tot_3 tot_5 tot_6 tot_7 tot_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

xi: xtreg mathscore tot_abovem_1 tot_abovem_2 tot_abovem_3 tot_abovem_5 tot_abovem_6 tot_abovem_7 tot_abovem_8 totm_1 totm_2 totm_3 totm_5 totm_6 totm_7 totm_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore tot_abovee_1 tot_abovee_2 tot_abovee_3 tot_abovee_5 tot_abovee_6 tot_abovee_7 tot_abovee_8 tote_1 tote_2 tote_3 tote_5 tote_6 tote_7 tote_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

*/

* TABLE 6 *

xi: xtreg mathscore post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_above_3 post_above_6 post_above_8 post_tottchr_3 post_tottchr_6 post_tottchr_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

xi: xtreg mathscore post_abovem_3 post_abovem_6 post_abovem_8 post_tottchrm_3 post_tottchrm_6 post_tottchrm_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_abovee_3 post_abovee_6 post_abovee_8 post_tottchre_3 post_tottchre_6 post_tottchre_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

* TABLE 7 *

	* Cutoffs defined by unweighted distributions in 1993 *

capture drop temp
gen temp=mathscore if year<=1993
egen premath=mean(mathscore), by(rcds_fix grade)
drop temp
gen temp=rdscore if year<=1993
egen preread=mean(rdscore), by(rcds_fix grade)
drop temp

global lowinc "37.9"
global lowwhite "71"
global lowmath "-.1744927"
global lowread "-.0881798"

	* By Income *

eststo clear

eststo: xi: xtreg mathscore post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc>=$lowinc  [aw=avgenroll], fe vce(robust)
eststo lowincome: xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)

eststo: xi: xtreg mathscore post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc<$lowinc [aw=avgenroll], fe vce(robust)
eststo lowincomecontrol: xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc<$lowinc [aw=avgenroll], fe vce(robust)

	* By Pct. White *

eststo: xi: xtreg mathscore post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite<$lowwhite [aw=avgenroll], fe vce(robust)
eststo lowwhite: xi: xtreg rdscore post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite<$lowwhite [aw=avgenroll], fe vce(robust)

eststo: xi: xtreg mathscore post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite>=$lowwhite [aw=avgenroll], fe vce(robust)
eststo lowwhitecontrol: xi: xtreg rdscore post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite>=$lowwhite [aw=avgenroll], fe vce(robust)

	* By Pre-Treatment Score *

eststo: xi: xtreg mathscore post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & premath<$lowmath [aw=avgenroll], fe vce(robust)
eststo lowbaseline: xi: xtreg rdscore post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & preread<$lowread [aw=avgenroll], fe vce(robust)

eststo: xi: xtreg mathscore post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & premath>=$lowmath [aw=avgenroll], fe vce(robust)
eststo lowbaselinecontrol: xi: xtreg rdscore post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & preread>=$lowread [aw=avgenroll], fe vce(robust)

estout using "../../results/table7.csv", cells(`"b() se() t() p()"') stats(N r2 df_m df_r df_b df) notype abbrev begin(`"""') delimiter(`"",""') end(`"""') replace

*** EDITED by Ryan
exit
***

* TABLE 8 *

	* Student-Teacher Ratio *

xi: xtreg ptrat_full post_above post_tottchr pblack phisp pasian plep pattd i.year*i.grade if year<=1997 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg ptrat_full post_above post_tottchr pblack phisp pasian plep pattd i.year*i.grade if year<=1997 & plinc<$lowinc [aw=avgenroll], fe vce(robust)

xi: xtreg ptrat_full post_above post_tottchr plinc plep pattd i.year*i.grade if year<=1997 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg ptrat_full post_above post_tottchr plinc plep pattd i.year*i.grade if year<=1997 & pwhite>$lowwhite [aw=avgenroll], fe vce(robust)

xi: xtreg ptrat_full post_above post_tottchr plinc pblack phisp pasian plep pattd i.year*i.grade if year<=1997 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg ptrat_full post_above post_tottchr plinc pblack phisp pasian plep pattd i.year*i.grade if year<=1997 & premath>$lowmath [aw=avgenroll], fe vce(robust)

xi: xtreg ptrat_full post_above post_tottchr plinc pblack phisp pasian plep pattd i.year*i.grade if year<=1997 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg ptrat_full post_above post_tottchr plinc pblack phisp pasian plep pattd i.year*i.grade if year<=1997 & preread>$lowread [aw=avgenroll], fe vce(robust)

	* Exits *

xi: xtreg lag_exit post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg lag_exit post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc<$lowinc [aw=avgenroll], fe vce(robust)

xi: xtreg lag_exit post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg lag_exit post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite>$lowwhite [aw=avgenroll], fe vce(robust)

xi: xtreg lag_exit post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg lag_exit post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1995 & premath>$lowmath [aw=avgenroll], fe vce(robust)

xi: xtreg lag_exit post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg lag_exit post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1995 & preread>$lowread [aw=avgenroll], fe vce(robust)

	* Experience *

xi: xtreg exp post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg exp post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc<$lowinc [aw=avgenroll], fe vce(robust)

xi: xtreg exp post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg exp post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite>$lowwhite [aw=avgenroll], fe vce(robust)

xi: xtreg exp post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg exp post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & premath>$lowmath [aw=avgenroll], fe vce(robust)

xi: xtreg exp post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg exp post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & preread>$lowread [aw=avgenroll], fe vce(robust)

	* New Teacher *

xi: xtreg newtchr post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg newtchr post_above post_tottchr pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & plinc<$lowinc [aw=avgenroll], fe vce(robust)

xi: xtreg newtchr post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg newtchr post_above post_tottchr plinc plep pattd enroll enrollsq i.year*i.grade if year<=1997 & pwhite>$lowwhite [aw=avgenroll], fe vce(robust)

xi: xtreg newtchr post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg newtchr post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & premath>$lowmath [aw=avgenroll], fe vce(robust)

xi: xtreg newtchr post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg newtchr post_above post_tottchr plinc pblack phisp pasian plep pattd enroll enrollsq i.year*i.grade if year<=1997 & preread>$lowread [aw=avgenroll], fe vce(robust)

	* Means *

	* Student-Teacher Ratios *

summ ptrat_full if year<=1993 & plinc>=$lowinc [aw=enroll]
summ ptrat_full if year<=1993 & plinc<$lowinc [aw=enroll]

summ ptrat_full if year<=1993 & pwhite<=$lowwhite [aw=enroll]
summ ptrat_full if year<=1993 & pwhite>$lowwhite [aw=enroll]

summ ptrat_full if year<=1993 & premath<=$lowmath [aw=enroll]
summ ptrat_full if year<=1993 & premath>$lowmath [aw=enroll]

summ ptrat_full if year<=1993 & preread<=$lowread [aw=enroll]
summ ptrat_full if year<=1993 & preread>$lowread [aw=enroll]

	* Exits *

summ lag_exit if year<=1993 & plinc>=$lowinc [aw=enroll]
summ lag_exit if year<=1993 & plinc<$lowinc [aw=enroll]

summ lag_exit if year<=1993 & pwhite<=$lowwhite [aw=enroll]
summ lag_exit if year<=1993 & pwhite>$lowwhite [aw=enroll]

summ lag_exit if year<=1993 & premath<=$lowmath [aw=enroll]
summ lag_exit if year<=1993 & premath>$lowmath [aw=enroll]

summ lag_exit if year<=1993 & preread<=$lowread [aw=enroll]
summ lag_exit if year<=1993 & preread>$lowread [aw=enroll]

	* Experience *

summ exp if year<=1993 & plinc>=$lowinc [aw=enroll]
summ exp if year<=1993 & plinc<$lowinc [aw=enroll]

summ exp if year<=1993 & pwhite<=$lowwhite [aw=enroll]
summ exp if year<=1993 & pwhite>$lowwhite [aw=enroll]

summ exp if year<=1993 & premath<=$lowmath [aw=enroll]
summ exp if year<=1993 & premath>$lowmath [aw=enroll]

summ exp if year<=1993 & preread<=$lowread [aw=enroll]
summ exp if year<=1993 & preread>$lowread [aw=enroll]

	* New Teachers *

summ newtchr if year<=1993 & plinc>=$lowinc [aw=enroll]
summ newtchr if year<=1993 & plinc<$lowinc [aw=enroll]

summ newtchr if year<=1993 & pwhite<=$lowwhite [aw=enroll]
summ newtchr if year<=1993 & pwhite>$lowwhite [aw=enroll]

summ newtchr if year<=1993 & premath<=$lowmath [aw=enroll]
summ newtchr if year<=1993 & premath>$lowmath [aw=enroll]

summ newtchr if year<=1993 & preread<=$lowread [aw=enroll]
summ newtchr if year<=1993 & preread>$lowread [aw=enroll]

***EDIT by Donna
/*
* TABLE 9 *

	* Excluding 8th Grade *

xi: xtreg mathscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & grade~=8 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & grade~=8 [aw=avgenroll], fe vce(robust)

	* Including Other Teachers *

xi: xtreg mathscore post_above post_tottchr post_aboveo post_tottchro pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & grade~=8 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_above post_tottchr post_aboveo post_tottchro pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & grade~=8 [aw=avgenroll], fe vce(robust)

* TABLE 10 - SEE README FILE FOR GUIDE ON CODE TO REPRODUCE ALL RESULTS IN THIS TABLE *

	* OLS -- PERCENT *

xi: xtreg mathscore post_pctabove pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_pctabove pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

xi: xtreg mathscore post_pctabovem pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_pctabovee pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

	* NO CHICAGO *

xi: xtreg mathscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & dsname~="CITY OF CHICAGO SCHOOL DIST 299" [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & dsname~="CITY OF CHICAGO SCHOOL DIST 299" [aw=avgenroll], fe vce(robust)

xi: xtreg mathscore post_abovem post_tottchrm pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & dsname~="CITY OF CHICAGO SCHOOL DIST 299" [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_abovee post_tottchre pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 & dsname~="CITY OF CHICAGO SCHOOL DIST 299" [aw=avgenroll], fe vce(robust)

* SCHOOL-POST FIXED EFFECTS *

xi: reg mathscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade i.rcds_fix*post if year<=1997 [aw=avgenroll], cluster(clusterid)
xi: reg rdscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade i.rcds_fix*post if year<=1997 [aw=avgenroll], cluster(clusterid)

xi: reg mathscore post_abovem post_tottchrm pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade i.rcds_fix*post if year<=1997 [aw=avgenroll], cluster(clusterid)
xi: reg rdscore post_abovee post_tottchre pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade i.rcds_fix*post if year<=1997 [aw=avgenroll], cluster(clusterid)


* ONLINE APPENDIX FIGURE A-1 *

xi: xtreg ptrat_full tot_above_1 tot_above_2 tot_above_3 tot_above_5 tot_above_6 tot_above_7 tot_above_8 tot_1 tot_2 tot_3 tot_5 tot_6 tot_7 tot_8 pblack phisp pasian plep plinc i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg lag_exit tot_above_1 tot_above_2 tot_above_3 tot_above_5 tot_above_6 tot_above_7 tot_above_8 tot_1 tot_2 tot_3 tot_5 tot_6 tot_7 tot_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg exp tot_above_1 tot_above_2 tot_above_3 tot_above_5 tot_above_6 tot_above_7 tot_above_8 tot_1 tot_2 tot_3 tot_5 tot_6 tot_7 tot_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg newtchr tot_above_1 tot_above_2 tot_above_3 tot_above_5 tot_above_6 tot_above_7 tot_above_8 tot_1 tot_2 tot_3 tot_5 tot_6 tot_7 tot_8 pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

* ONLINE APPENDIX FIGURE A-2 *

xi: xtreg tot_tchr1 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr2 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr3 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr4 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr5 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr6_9 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr10_14 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr15_19 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr20_24 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr25_29 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr30_34 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr35_39 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr40 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & plinc>=$lowinc [aw=avgenroll], fe vce(robust)

xi: xtreg tot_tchr1 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr2 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr3 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr4 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr5 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr6_9 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr10_14 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr15_19 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr20_24 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr25_29 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr30_34 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr35_39 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr40 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & pwhite<=$lowwhite [aw=avgenroll], fe vce(robust)

xi: xtreg tot_tchr1 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr2 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr3 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr4 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr5 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr6_9 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr10_14 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr15_19 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr20_24 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr25_29 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr30_34 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr35_39 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr40 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & premath<=$lowmath [aw=avgenroll], fe vce(robust)

xi: xtreg tot_tchr1 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr2 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr3 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr4 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr5 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr6_9 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr10_14 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr15_19 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr20_24 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr25_29 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr30_34 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr35_39 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)
xi: xtreg tot_tchr40 post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1995 & preread<=$lowread [aw=avgenroll], fe vce(robust)

*/


