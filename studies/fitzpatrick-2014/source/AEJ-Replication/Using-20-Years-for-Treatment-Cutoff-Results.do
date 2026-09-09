clear 
set mem 5g
set maxvar 11000
set matsize 5000
set more off 

* TEACHER DATA *

use TSR89_01char, clear
dmerge rcds using idfix
drop if _merge==2
drop _merge
gen rcds_fix=rcds
replace rcds_fix=rcds2 if rcds2~=""
replace rcds_fix=rcds3 if rcds3~=""
gen totexp= IllinoisYearsExperience + OutOfStateYearsOfExperience
replace totexp=round(totexp,1)
egen exit=max(exitteaching), by(uniqueID year)
capture drop temp
gen temp=totexp if year<=1993
egen pre_exp=mean(temp), by(uniqueID)
drop temp
xtile pre_exp_quart=pre_exp, nq(4)
gen abovemed=pre_exp_quart>2
replace abovemed=. if year>1993
egen pct_above_med=mean(abovemed), by(rcds_fix)

* Assign Grades *

drop if uniqueID==.
gen nograde=1 if LowestGrade==0 & HighestGrade==8
replace nograde=0 if nograde==.

	* Use Longitudinal Data to Assign Grades *

gen lowgrade_fix=LowestGrade
replace lowgrade_fix=. if nograde==1
egen temp=min(lowgrade_fix), by(uniqueID)
replace lowgrade_fix=temp if nograde==1 & temp~=.
drop temp
gen highgrade_fix=HighestGrade
replace highgrade_fix=. if nograde==1
egen temp=max(highgrade_fix), by(uniqueID)
replace highgrade_fix=temp if nograde==1 & temp~=.
drop temp

	* Find Schools with no Teacher Grade Info *

egen pctnograde=mean(nograde), by(rcds_fix)
egen schlflag=tag(rcds_fix)
	* Drop if schools have more than 90% without a grade - 5% of schools *
drop if pctnograde>=.9 & pctnograde~=.

	* Use Existing Distribution to Identify Likelihood of Teaching Each Grade *

drop grade*
gen grade3=1 if LowestGrade~=0 & HighestGrade>=3 & LowestGrade<=3 & Position==19
replace grade3=1 if LowestGrade==0 & HighestGrade==3 & Position==19 
replace grade3=0 if grade3==. & nograde==0

gen grade6=1 if LowestGrade~=0 & HighestGrade>=6 & LowestGrade<=6 & (Position==20 | Position==19)
replace grade6=1 if LowestGrade==0 & HighestGrade==6 & (Position==20 | Position==19)
replace grade6=0 if grade6==. & nograde==0

gen grade8=1 if LowestGrade~=0 & HighestGrade>=8 & LowestGrade<=8 & Position==20
replace grade8=1 if LowestGrade==0 & HighestGrade==8 & Position==20 
replace grade8=0 if grade8==. & nograde==0

egen p3=mean(grade3), by(rcds_fix)
egen p6=mean(grade6), by(rcds_fix)
egen p8=mean(grade8), by(rcds_fix)

gen teach_3=grade3==1
replace teach_3=1 if lowgrade_fix~=0 & highgrade_fix>=3 & lowgrade_fix<=3 & Position==19 & nograde==1
replace teach_3=1 if lowgrade_fix==0 & highgrade_fix==3 & Position==19 & nograde==1
replace teach_3=p3 if teach_3==0 & nograde==1 & Position==19

gen teach_6=grade6==1
replace teach_6=1 if lowgrade_fix~=0 & highgrade_fix>=6 & lowgrade_fix<=6 & (Position==19 | Position==20) & nograde==1
replace teach_6=1 if lowgrade_fix==0 & highgrade_fix==6 & (Position==19 | Position==20) & nograde==1
replace teach_6=p6 if teach_6==0 & nograde==1 & (Position==19 | Position==20)

gen teach_8=grade8==1
replace teach_8=1 if lowgrade_fix~=0 & highgrade_fix>=8 & lowgrade_fix<=8 & Position==20 & nograde==1
replace teach_8=1 if lowgrade_fix==0 & highgrade_fix==8 & Position==20 & nograde==1
replace teach_8=p8 if teach_8==0 & nograde==1 & Position==20

* Fix Experience *

egen flag=tag(uniqueID year)
egen firstyr=min(year), by(uniqueID)
gen enter=firstyr==year
gen temp=totexp if enter==1
egen firstexp=max(temp), by(uniqueID)
drop temp
gen temp=1 if flag==1 & year==1990
egen in90=max(temp), by(uniqueID)
replace in90=0 if in90==.
drop temp
gen temp=1 if flag==1 & year==1991
egen in91=max(temp), by(uniqueID)
replace in91=0 if in91==.
drop temp
gen temp=1 if flag==1 & year==1992
egen in92=max(temp), by(uniqueID)
replace in92=0 if in92==.
drop temp
gen temp=1 if flag==1 & year==1993
egen in93=max(temp), by(uniqueID)
replace in93=0 if in93==.
drop temp
gen temp=1 if flag==1 & year==1994
egen in94=max(temp), by(uniqueID)
replace in94=0 if in94==.
drop temp
gen temp=1 if flag==1 & year==1995
egen in95=max(temp), by(uniqueID)
replace in95=0 if in95==.
drop temp
gen temp=1 if flag==1 & year==1996
egen in96=max(temp), by(uniqueID)
replace in96=0 if in96==.
drop temp
gen temp=1 if flag==1 & year==1997
egen in97=max(temp), by(uniqueID)
replace in97=0 if in97==.
drop temp
gen temp=1 if flag==1 & year==1998
egen in98=max(temp), by(uniqueID)
replace in98=0 if in98==.
drop temp
gen temp=1 if flag==1 & year==1999
egen in99=max(temp), by(uniqueID)
replace in99=0 if in90==.
drop temp
gen temp=1 if flag==1 & year==2000
egen in2000=max(temp), by(uniqueID)
replace in2000=0 if in2000==.
drop temp
gen temp=1 if flag==1 & year==2001
egen in2001=max(temp), by(uniqueID)
replace in2001=0 if in2001==.
drop temp

gen exp_fix=firstexp if firstyr==year
replace exp_fix=firstexp + in90 if firstyr==1989 & year==1990
replace exp_fix=firstexp + in90 + in91 if firstyr<1991 & year==1991
replace exp_fix=firstexp + in90 + in91 + in92 if firstyr<1992 & year==1992
replace exp_fix=firstexp + in90 + in91 + in92 + in93 if firstyr<1993 & year==1993
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 if firstyr<1994 & year==1994
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 + in95 if firstyr<1995 & year==1995
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 + in95 + in96 if firstyr<1996 & year==1996
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 + in95 + in96 + in97 if firstyr<1997 & year==1997
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 + in95 + in96 + in97 + in98 if firstyr<1998 & year==1998
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 + in95 + in96 + in97 + in98 + in99 if firstyr<1999 & year==1999
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 + in95 + in96 + in97 + in98 + in99 + in2000 if firstyr<2000 & year==2000
replace exp_fix=firstexp + in90 + in91 + in92 + in93 + in94 + in95 + in96 + in97 + in98 + in99 + in2000 + in2001 if firstyr<2001 & year==2001
replace exp_fix=exp_fix-1 if firstyr~=1989 & year>firstyr

gen exp_gr3=exp_fix if teach_3>0
gen exp_gr6=exp_fix if teach_6>0
gen exp_gr8=exp_fix if teach_8>0

* Grade-Specific Experience Percentages *

	 * Third Grade *

		* Total *

gen temp=exp_gr3 if year<=1993
gen abovegr3=teach_3 if temp>=20 & temp~=.
replace abovegr3=0 if abovegr3==. & temp~=. 
replace abovegr3=. if year>1993
drop temp
egen temp=sum(abovegr3), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr3=mean(temp), by(rcds_fix)
drop temp
egen temp=sum(teach_3), by(rcds_fix year)
replace temp=. if year>1993
egen tot_gr3=mean(temp), by(rcds_fix)
drop temp
gen pct_above_gr3=tot_gr3/tot_gr3

		* Math *

gen temp=exp_gr3 if year<=1993 & (subject=="math" | subject=="selfcont")
gen abovegr3m=teach_3 if temp>=20 & temp~=.
replace abovegr3m=0 if abovegr3m==. & temp~=. 
replace abovegr3m=. if year>1993
drop temp
egen temp=sum(abovegr3m), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr3m=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_3 if (subject=="math" | subject=="selfcont")
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr3m=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr3m=tot_above_gr3m/tot_gr3m

		* English *

gen temp=exp_gr3 if year<=1993 & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
gen abovegr3e=teach_3 if temp>=20 & temp~=.
replace abovegr3e=0 if abovegr3e==. & temp~=. 
replace abovegr3e=. if year>1993
drop temp
egen temp=sum(abovegr3e), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr3e=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_3 if (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr3e=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr3e=tot_above_gr3e/tot_gr3e

	 * Sixth Grade *

		* Total *

gen temp=exp_gr6 if year<=1993
gen abovegr6=teach_6 if temp>=20 & temp~=.
replace abovegr6=0 if abovegr6==. & temp~=. 
replace abovegr6=. if year>1993
drop temp
egen temp=sum(abovegr6), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr6=mean(temp), by(rcds_fix)
drop temp
egen temp=sum(teach_6), by(rcds_fix year)
replace temp=. if year>1993
egen tot_gr6=mean(temp), by(rcds_fix)
drop temp
gen pct_above_gr6=tot_above_gr6/tot_gr6

		* Math *

gen temp=exp_gr6 if year<=1993 & (subject=="math" | subject=="selfcont")
gen abovegr6m=teach_6 if temp>=20 & temp~=.
replace abovegr6m=0 if abovegr6m==. & temp~=. 
replace abovegr6m=. if year>1993
drop temp
egen temp=sum(abovegr6m), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr6m=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_6 if (subject=="math" | subject=="selfcont")
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr6m=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr6m=tot_above_gr6m/tot_gr6m

		* English *

gen temp=exp_gr6 if year<=1993 & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
gen abovegr6e=teach_6 if temp>=20 & temp~=.
replace abovegr6e=0 if abovegr6e==. & temp~=. 
replace abovegr6e=. if year>1993
drop temp
egen temp=sum(abovegr6e), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr6e=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_6 if (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr6e=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr6e=tot_above_gr6e/tot_gr6e

	 * Eighth Grade *

		* Total *

gen temp=exp_gr8 if year<=1993
gen abovegr8=teach_8 if temp>=20 & temp~=.
replace abovegr8=0 if abovegr8==. & temp~=. 
replace abovegr8=. if year>1993
drop temp
egen temp=sum(abovegr8), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr8=mean(temp), by(rcds_fix)
drop temp
egen temp=sum(teach_8), by(rcds_fix year)
replace temp=. if year>1993
egen tot_gr8=mean(temp), by(rcds_fix)
drop temp
gen pct_above_gr8=tot_above_gr8/tot_gr8

		* Math *

gen temp=exp_gr8 if year<=1993 & (subject=="math" | subject=="selfcont")
gen abovegr8m=teach_8 if temp>=20 & temp~=.
replace abovegr8m=0 if abovegr8m==. & temp~=. 
replace abovegr8m=. if year>1993
drop temp
egen temp=sum(abovegr8m), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr8m=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_8 if (subject=="math" | subject=="selfcont")
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr8m=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr8m=tot_above_gr8m/tot_gr8m

		* English *

gen temp=exp_gr8 if year<=1993 & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
gen abovegr8e=teach_8 if temp>=20 & temp~=.
replace abovegr8e=0 if abovegr8e==. & temp~=. 
replace abovegr8e=. if year>1993
drop temp
egen temp=sum(abovegr8e), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr8e=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_8 if (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr8e=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr8e=tot_above_gr8e/tot_gr8e

* Exits *

gen temp=exit*teach_3 if exp_fix>=20
egen exit_gr3=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_6 if exp_fix>=20
egen exit_gr6=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_8 if exp_fix>=20
egen exit_gr8=sum(temp), by(rcds_fix year)
drop temp

* Exits by Subject *

gen temp=exit*teach_3 if exp_fix>=20 & (subject=="math" | subject=="selfcont")
egen exit_gr3m=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_3 if exp_fix>=20  & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen exit_gr3e=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_6 if exp_fix>=20 & (subject=="math" | subject=="selfcont")
egen exit_gr6m=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_6 if exp_fix>=20  & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen exit_gr6e=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_8 if exp_fix>=20 & (subject=="math" | subject=="selfcont")
egen exit_gr8m=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_8 if exp_fix>=20 & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen exit_gr8e=sum(temp), by(rcds_fix year)
drop temp

* New Teachers *

gen temp=exp_gr3<=1
replace temp=temp*teach_3
egen newtchr_gr3=sum(temp), by(rcds_fix year)
drop temp
gen temp=exp_gr6<=1
replace temp=temp*teach_6
egen newtchr_gr6=sum(temp), by(rcds_fix year)
drop temp
gen temp=exp_gr8<=1
replace temp=temp*teach_8
egen newtchr_gr8=sum(temp), by(rcds_fix year)
drop temp

collapse (mean) teach_3 teach_6 teach_8 grade3 grade6 grade8 totexp exit exit_gr3 exit_gr3m exit_gr3e exit_gr6 exit_gr6m exit_gr6e exit_gr8 exit_gr8m exit_gr8e newtchr_gr3 newtchr_gr6 newtchr_gr8 exp_fix exp_gr3 exp_gr6 exp_gr8 abovegr3 pct_above_gr3 tot_above_gr3 tot_gr3 pct_above_gr3m tot_above_gr3m tot_gr3m pct_above_gr3e tot_above_gr3e tot_gr3e abovegr6 pct_above_gr6 tot_above_gr6 tot_gr6 pct_above_gr6m tot_above_gr6m tot_gr6m pct_above_gr6e tot_above_gr6e tot_gr6e abovegr8 pct_above_gr8 tot_above_gr8 tot_gr8 pct_above_gr8m tot_above_gr8m tot_gr8m pct_above_gr8e tot_above_gr8e tot_gr8e, by(rcds_fix year)

sort rcds_fix year
dmerge rcds_fix year using rcdata2_idfix.dta
gen region=substr(rcds,1,9)
*drop if region=="140162990"
*drop if region=="150162990"
tab _merge

drop if _merge==1
drop if _merge==2

* FIX SOME OUTLIERS *

replace tot_gr3=. if tot_gr3==0
replace tot_above_gr3=. if tot_gr3==0
replace tot_above_gr3m=. if tot_gr3==0
replace tot_above_gr3e=. if tot_gr3==0
replace pct_above_gr3=. if tot_gr3==0
replace pct_above_gr3m=. if tot_gr3==0
replace pct_above_gr3e=. if tot_gr3==0
replace tot_gr6=. if tot_gr6==0
replace tot_above_gr6=. if tot_gr6==0
replace tot_above_gr6m=. if tot_gr6==0
replace tot_above_gr6e=. if tot_gr6==0
replace pct_above_gr6=. if tot_gr6==0
replace pct_above_gr6m=. if tot_gr6==0
replace pct_above_gr6e=. if tot_gr6==0
replace tot_gr8=. if tot_gr8==0
replace tot_above_gr8=. if tot_gr8==0
replace tot_above_gr8m=. if tot_gr8==0
replace tot_above_gr8e=. if tot_gr8==0
replace pct_above_gr8=. if tot_gr8==0
replace pct_above_gr8m=. if tot_gr8==0
replace pct_above_gr8e=. if tot_gr8==0

gen post=year>1993
gen post_gr3=post*pct_above_gr3
gen post_gr3m=post*pct_above_gr3m
gen post_gr3e=post*pct_above_gr3e
gen post_totabovegr3=post*tot_above_gr3
gen post_totabovegr3m=post*tot_above_gr3m
gen post_totabovegr3e=post*tot_above_gr3e
gen post_totgr3=post*tot_gr3
gen post_totgr3m=post*tot_gr3m
gen post_totgr3e=post*tot_gr3e

gen post_gr6=post*pct_above_gr6
gen post_gr6m=post*pct_above_gr6m
gen post_gr6e=post*pct_above_gr6e
gen post_totabovegr6=post*tot_above_gr6
gen post_totabovegr6m=post*tot_above_gr6m
gen post_totabovegr6e=post*tot_above_gr6e
gen post_totgr6=post*tot_gr6
gen post_totgr6m=post*tot_gr6m
gen post_totgr6e=post*tot_gr6e

gen post_gr8=post*pct_above_gr8
gen post_gr8m=post*pct_above_gr8m
gen post_gr8e=post*pct_above_gr8e
gen post_totabovegr8=post*tot_above_gr8
gen post_totabovegr8m=post*tot_above_gr8m
gen post_totabovegr8e=post*tot_above_gr8e
gen post_totgr8=post*tot_gr8
gen post_totgr8m=post*tot_gr8m
gen post_totgr8e=post*tot_gr8e

egen clusterid=group(rcds_fix)
egen flag=tag(clusterid year)
drop if flag==0
drop flag

* Make Data Set Grade-School-Year

gen count=(tot_gr3~=. & g3mtstd~=. & teach_3~=0)
replace count=count+1 if tot_gr6~=. & g6mtstd~=. & teach_6~=0
replace count=count+1 if tot_gr8~=. & g8mtstd~=. & teach_8~=0
drop if count==0
expand count 
egen numschl=seq(), by(rcds_fix year)

gen grade=3 if numschl==1 & tot_gr3~=. & g3mtstd~=. & teach_3~=0
replace grade=6 if numschl==1 & tot_gr6~=. & g6mtstd~=. & grade==. & teach_6~=0
replace grade=8 if numschl==1 & tot_gr8~=. & g8mtstd~=. & grade==. & teach_8~=0

egen tempgrade=max(grade), by(rcds_fix year)

replace grade=6 if numschl==2 & tot_gr6~=. & g6mtstd~=. & tempgrade==3 & teach_6~=0
replace grade=8 if numschl==2 & tot_gr8~=. & g8mtstd~=. & tempgrade==3 & grade==. & teach_8~=0
replace grade=8 if numschl==2 & tot_gr8~=. & g8mtstd~=. & tempgrade==6 & grade==. & teach_8~=0

gen temp=grade if numschl==2
egen tempgrade2=max(temp), by(rcds_fix year)
replace grade=8 if numschl==3 & tot_gr8~=. & g8mtstd~=. & tempgrade==3 & tempgrade2==6 & grade==. & teach_8~=0
drop tempgrade*

* Make Overall Data *

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

gen post_above=post*tot_above
gen post_abovem=post*tot_abovem
gen post_abovee=post*tot_abovee

gen post_tottchr=post*tot_tchr
gen post_tottchrm=post*tot_tchrm
gen post_tottchre=post*tot_tchre

gen post_pctabove=post*pct_above
gen post_pctabovem=post*pct_abovem
gen post_pctabovee=post*pct_abovee

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

xtset clusterid

* ESTIMATES USING 20 YEARS EXPERIENCE AS CUTOFF FOR TREATMENT (ROW 1, TABLE 10) *

xi: xtreg mathscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_above post_tottchr pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)

xi: xtreg mathscore post_abovem post_tottchrm pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)
xi: xtreg rdscore post_abovee post_tottchre pblack phisp pasian plep plinc pattd enroll enrollsq i.year*i.grade if year<=1997 [aw=avgenroll], fe vce(robust)


