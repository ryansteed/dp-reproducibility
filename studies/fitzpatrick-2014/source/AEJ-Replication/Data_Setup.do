clear 
set mem 5g
set maxvar 11000
set matsize 5000
set more off 

use rcdata.dta, clear

* THERE WAS A CHANGE IN THE REGION CODING IN 1996, SO WE HAVE RECODED RCDS TO ACCOUNT FOR THIS SO THAT THE TWO DATASETS WILL MATCH *

replace rcds="14"+substr(rcds,3,11) if substr(rcds,1,2)=="15"

* GENERATE STANDARDIZED TEST VARIABLES *

replace year=year+1900
replace year=2000 if year==1900
gen g3mtstd=.
forval x=1990(1)2000{
summ g3mt if year==`x'
local mean=r(mean)
local sd=r(sd)
replace g3mtstd=(g3mt-`mean')/`sd' if year==`x'
}
gen g6mtstd=.
forval x=1990(1)2000{
summ g6mt if year==`x'
local mean=r(mean)
local sd=r(sd)
replace g6mtstd=(g6mt-`mean')/`sd' if year==`x'
}
gen g8mtstd=.
forval x=1990(1)2000{
summ g8mt if year==`x'
local mean=r(mean)
local sd=r(sd)
replace g8mtstd=(g8mt-`mean')/`sd' if year==`x'
}
gen g3rdstd=.
forval x=1990(1)2000{
summ g3rd if year==`x'
local mean=r(mean)
local sd=r(sd)
replace g3rdstd=(g3rd-`mean')/`sd' if year==`x'
}
gen g6rdstd=.
forval x=1990(1)2000{
summ g6rd if year==`x'
local mean=r(mean)
local sd=r(sd)
replace g6rdstd=(g6rd-`mean')/`sd' if year==`x'
}
gen g8rdstd=.
forval x=1990(1)2000{
summ g8rd if year==`x'
local mean=r(mean)
local sd=r(sd)
replace g8rdstd=(g8rd-`mean')/`sd' if year==`x'
}
replace year=year-1900
replace year=0 if year==100
sort rcds year
save rcdata2, replace

* SOME SCHOOL IDS IN THE DATA CHANGE OVER TIME, SO WE MATCH SCHOOLS BY NAME AND DISTRICT IN ORDER TO CONSTRUCT A CONSISTENT SCHOOL ID *

do idfix

* READ IN THE TEACHER-LEVEL DATA *

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
gen grade1=1 if LowestGrade~=0 & HighestGrade>=1 & LowestGrade<=1 & Position==19
replace grade1=1 if LowestGrade==0 & HighestGrade==1 & Position==19 
replace grade1=0 if grade1==. & nograde==0

gen grade2=1 if LowestGrade~=0 & HighestGrade>=2 & LowestGrade<=2 & Position==19
replace grade2=1 if LowestGrade==0 & HighestGrade==2 & Position==19 
replace grade2=0 if grade2==. & nograde==0

gen grade3=1 if LowestGrade~=0 & HighestGrade>=3 & LowestGrade<=3 & Position==19
replace grade3=1 if LowestGrade==0 & HighestGrade==3 & Position==19 
replace grade3=0 if grade3==. & nograde==0

gen grade4=1 if LowestGrade~=0 & HighestGrade>=4 & LowestGrade<=4 & Position==19
replace grade4=1 if LowestGrade==0 & HighestGrade==4 & Position==19 
replace grade4=0 if grade4==. & nograde==0

gen grade5=1 if LowestGrade~=0 & HighestGrade>=5 & LowestGrade<=5 & Position==19
replace grade5=1 if LowestGrade==0 & HighestGrade==5 & Position==19 
replace grade5=0 if grade5==. & nograde==0

gen grade6=1 if LowestGrade~=0 & HighestGrade>=6 & LowestGrade<=6 & (Position==20 | Position==19)
replace grade6=1 if LowestGrade==0 & HighestGrade==6 & (Position==20 | Position==19)
replace grade6=0 if grade6==. & nograde==0

gen grade7=1 if LowestGrade~=0 & HighestGrade>=7 & LowestGrade<=7 & Position==20
replace grade7=1 if LowestGrade==0 & HighestGrade==7 & Position==20
replace grade7=0 if grade7==. & nograde==0

gen grade8=1 if LowestGrade~=0 & HighestGrade>=8 & LowestGrade<=8 & Position==20
replace grade8=1 if LowestGrade==0 & HighestGrade==8 & Position==20 
replace grade8=0 if grade8==. & nograde==0

gen grade9=1 if LowestGrade~=0 & HighestGrade>=9 & LowestGrade<=9 & Position>=20
replace grade9=1 if LowestGrade==0 & HighestGrade==9 & Position>=20 
replace grade9=0 if grade9==. & nograde==0

gen grade10=1 if LowestGrade~=0 & HighestGrade>=10 & LowestGrade<=10 & Position>=20
replace grade10=1 if LowestGrade==0 & HighestGrade==10 & Position>=20 
replace grade10=0 if grade10==. & nograde==0

gen grade11=1 if LowestGrade~=0 & HighestGrade>=11 & LowestGrade<=11 & Position>=20
replace grade11=1 if LowestGrade==0 & HighestGrade==11 & Position>=20 
replace grade11=0 if grade11==. & nograde==0

gen grade12=1 if LowestGrade~=0 & HighestGrade>=12 & LowestGrade<=12 & Position>=20
replace grade12=1 if LowestGrade==0 & HighestGrade==12 & Position>=20 
replace grade12=0 if grade12==. & nograde==0

egen p3=mean(grade3), by(rcds_fix)
egen p6=mean(grade6), by(rcds_fix)
egen p8=mean(grade8), by(rcds_fix)
egen p1=mean(grade1), by(rcds_fix)
egen p2=mean(grade2), by(rcds_fix)
egen p4=mean(grade4), by(rcds_fix)
egen p5=mean(grade5), by(rcds_fix)
egen p7=mean(grade7), by(rcds_fix)
egen p9=mean(grade9), by(rcds_fix)
egen p10=mean(grade10), by(rcds_fix)
egen p11=mean(grade11), by(rcds_fix)
egen p12=mean(grade12), by(rcds_fix)

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

gen teach_1=grade1==1
replace teach_1=1 if lowgrade_fix~=0 & highgrade_fix>=1 & lowgrade_fix<=1 & Position==19 & nograde==1
replace teach_1=1 if lowgrade_fix==0 & highgrade_fix==1 & Position==19 & nograde==1
replace teach_1=p1 if teach_1==0 & nograde==1 & Position==19

gen teach_2=grade2==1
replace teach_2=1 if lowgrade_fix~=0 & highgrade_fix>=2 & lowgrade_fix<=2 & Position==19 & nograde==1
replace teach_2=1 if lowgrade_fix==0 & highgrade_fix==2 & Position==19 & nograde==1
replace teach_2=p2 if teach_2==0 & nograde==1 & Position==19

gen teach_4=grade4==1
replace teach_4=1 if lowgrade_fix~=0 & highgrade_fix>=4 & lowgrade_fix<=4 & Position==19 & nograde==1
replace teach_4=1 if lowgrade_fix==0 & highgrade_fix==4 & Position==19 & nograde==1
replace teach_4=p4 if teach_4==0 & nograde==1 & Position==19

gen teach_5=grade5==1
replace teach_5=1 if lowgrade_fix~=0 & highgrade_fix>=5 & lowgrade_fix<=5 & Position==19 & nograde==1
replace teach_5=1 if lowgrade_fix==0 & highgrade_fix==5 & Position==19 & nograde==1
replace teach_5=p5 if teach_5==0 & nograde==1 & Position==19

gen teach_7=grade7==1
replace teach_7=1 if lowgrade_fix~=0 & highgrade_fix>=7 & lowgrade_fix<=7 & Position==20 & nograde==1
replace teach_7=1 if lowgrade_fix==0 & highgrade_fix==7 & Position==20 & nograde==1
replace teach_7=p7 if teach_7==0 & nograde==1 & Position==20

gen teach_9=grade9==1
replace teach_9=1 if lowgrade_fix~=0 & highgrade_fix>=9 & lowgrade_fix<=9 & Position>=20 & nograde==1
replace teach_9=1 if lowgrade_fix==0 & highgrade_fix==9 & Position>=20 & nograde==1
replace teach_9=p9 if teach_9==0 & nograde==1 & Position>=20

gen teach_10=grade10==1
replace teach_10=1 if lowgrade_fix~=0 & highgrade_fix>=10 & lowgrade_fix<=10 & Position>=20 & nograde==1
replace teach_10=1 if lowgrade_fix==0 & highgrade_fix==10 & Position>=20 & nograde==1
replace teach_10=p10 if teach_10==0 & nograde==1 & Position>=20

gen teach_11=grade11==1
replace teach_11=1 if lowgrade_fix~=0 & highgrade_fix>=11 & lowgrade_fix<=11 & Position>=20 & nograde==1
replace teach_11=1 if lowgrade_fix==0 & highgrade_fix==11 & Position>=20 & nograde==1
replace teach_11=p11 if teach_11==0 & nograde==1 & Position>=20

gen teach_12=grade12==1
replace teach_12=1 if lowgrade_fix~=0 & highgrade_fix>=12 & lowgrade_fix<=12 & Position>=20 & nograde==1
replace teach_12=1 if lowgrade_fix==0 & highgrade_fix==12 & Position>=20 & nograde==1
replace teach_12=p12 if teach_12==0 & nograde==1 & Position>=20

* Fix Experience - use the first experience level observed and then assume experience increases by one year each year. *

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

gen exp_gr1=exp_fix if teach_1>0
gen exp_gr2=exp_fix if teach_2>0
gen exp_gr4=exp_fix if teach_4>0
gen exp_gr5=exp_fix if teach_5>0
gen exp_gr7=exp_fix if teach_7>0
gen exp_gr9=exp_fix if teach_7>0
gen exp_gr10=exp_fix if teach_7>0
gen exp_gr11=exp_fix if teach_7>0
gen exp_gr12=exp_fix if teach_7>0

* Generate Grade-Specific Experience Numbers *

	 * Third Grade *

		* Total *
gen temp=exp_gr3 if year<=1993
gen abovegr3=teach_3 if temp>=15 & temp~=.
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
gen abovegr3m=teach_3 if temp>=15 & temp~=.
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
gen abovegr3e=teach_3 if temp>=15 & temp~=.
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

		* Non-Math *

gen temp=exp_gr3 if year<=1993 & subject~="math" & subject~="selfcont"
gen abovegr3nm=teach_3 if temp>=15 & temp~=.
replace abovegr3nm=0 if abovegr3nm==. & temp~=. 
replace abovegr3nm=. if year>1993
drop temp
egen temp=sum(abovegr3nm), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr3nm=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_3 if subject~="math" & subject~="selfcont"
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr3nm=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr3nm=tot_above_gr3nm/tot_gr3nm

		* Non-English *

gen temp=exp_gr3 if year<=1993 & subject~="end/read" & subject~="bilingual" & subject~="selfcont"
gen abovegr3ne=teach_3 if temp>=15 & temp~=.
replace abovegr3ne=0 if abovegr3ne==. & temp~=. 
replace abovegr3ne=. if year>1993
drop temp
egen temp=sum(abovegr3ne), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr3ne=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_3 if subject~="end/read" & subject~="bilingual" & subject~="selfcont"
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr3ne=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr3ne=tot_above_gr3ne/tot_gr3ne

		* Other *

gen temp=exp_gr4 if year<=1993
replace temp=exp_gr5 if year<=1993 & temp==.
replace temp=exp_gr6 if year<=1993 & temp==.
replace temp=exp_gr7 if year<=1993 & temp==.
replace temp=exp_gr8 if year<=1993 & temp==.
replace temp=exp_gr9 if year<=1993 & temp==.
replace temp=exp_gr10 if year<=1993 & temp==.
replace temp=exp_gr11 if year<=1993 & temp==.
replace temp=exp_gr12 if year<=1993 & temp==.
gen abovegr3o=teach_4 if temp>=15 & temp~=. & teach_3~=1
replace abovegr3o=teach_5 if temp>=15 & temp~=. & abovegr3o~=1 & teach_5~=0 & teach_5~=. & teach_3~=1
replace abovegr3o=teach_6 if temp>=15 & temp~=. & abovegr3o~=1 & teach_6~=0 & teach_6~=. & teach_3~=1
replace abovegr3o=teach_7 if temp>=15 & temp~=. & abovegr3o~=1 & teach_7~=0 & teach_7~=. & teach_3~=1
replace abovegr3o=teach_8 if temp>=15 & temp~=. & abovegr3o~=1 & teach_8~=0 & teach_8~=. & teach_3~=1
replace abovegr3o=teach_9 if temp>=15 & temp~=. & abovegr3o~=1 & teach_9~=0 & teach_9~=. & teach_3~=1
replace abovegr3o=teach_10 if temp>=15 & temp~=. & abovegr3o~=1 & teach_10~=0 & teach_10~=. & teach_3~=1
replace abovegr3o=teach_11 if temp>=15 & temp~=. & abovegr3o~=1 & teach_11~=0 & teach_11~=. & teach_3~=1
replace abovegr3o=teach_12 if temp>=15 & temp~=. & abovegr3o~=1 & teach_12~=0 & teach_12~=. & teach_3~=1
replace abovegr3o=0 if abovegr3o==. & temp~=. 
replace abovegr3o=. if year>1993
drop temp
egen temp=sum(abovegr3o), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr3o=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_4 if teach_3~=1
replace temp=teach_5 if temp~=1 & teach_5~=0 & teach_5~=. & teach_3~=1
replace temp=teach_6 if temp~=1 & teach_6~=0 & teach_6~=. & teach_3~=1
replace temp=teach_7 if temp~=1 & teach_7~=0 & teach_7~=. & teach_3~=1
replace temp=teach_8 if temp~=1 & teach_8~=0 & teach_8~=. & teach_3~=1
replace temp=teach_9 if temp~=1 & teach_9~=0 & teach_9~=. & teach_3~=1
replace temp=teach_10 if temp~=1 & teach_10~=0 & teach_10~=. & teach_3~=1
replace temp=teach_11 if temp~=1 & teach_11~=0 & teach_11~=. & teach_3~=1
replace temp=teach_12 if temp~=1 & teach_12~=0 & teach_12~=. & teach_3~=1
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr3o=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr3o=tot_gr3o/tot_gr3o

	 * Sixth Grade *

		* Total *

gen temp=exp_gr6 if year<=1993
gen abovegr6=teach_6 if temp>=15 & temp~=.
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
gen abovegr6m=teach_6 if temp>=15 & temp~=.
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
gen abovegr6e=teach_6 if temp>=15 & temp~=.
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

		* Non-Math *

gen temp=exp_gr6 if year<=1993 & subject~="math" & subject~="selfcont"
gen abovegr6nm=teach_6 if temp>=15 & temp~=.
replace abovegr6nm=0 if abovegr6nm==. & temp~=. 
replace abovegr6nm=. if year>1993
drop temp
egen temp=sum(abovegr6nm), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr6nm=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_6 if subject~="math" & subject~="selfcont"
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr6nm=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr6nm=tot_above_gr6nm/tot_gr6nm

		* Non-English *

gen temp=exp_gr6 if year<=1993 & subject~="end/read" & subject~="bilingual" & subject~="selfcont"
gen abovegr6ne=teach_6 if temp>=15 & temp~=.
replace abovegr6ne=0 if abovegr6ne==. & temp~=. 
replace abovegr6ne=. if year>1993
drop temp
egen temp=sum(abovegr6ne), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr6ne=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_6 if subject~="end/read" & subject~="bilingual" & subject~="selfcont"
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr6ne=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr6ne=tot_above_gr6ne/tot_gr6ne

		* Other *

gen temp=exp_gr7 if year<=1993
replace temp=exp_gr8 if year<=1993 & temp==.
replace temp=exp_gr9 if year<=1993 & temp==.
replace temp=exp_gr10 if year<=1993 & temp==.
replace temp=exp_gr11 if year<=1993 & temp==.
replace temp=exp_gr12 if year<=1993 & temp==.
gen abovegr6o=teach_7 if temp>=15 & temp~=. & teach_6~=1
replace abovegr6o=teach_8 if temp>=15 & temp~=. & abovegr6o~=1 & teach_8~=0 & teach_8~=. & teach_6~=1
replace abovegr6o=teach_9 if temp>=15 & temp~=. & abovegr6o~=1 & teach_9~=0 & teach_9~=. & teach_6~=1
replace abovegr6o=teach_10 if temp>=15 & temp~=. & abovegr6o~=1 & teach_10~=0 & teach_10~=. & teach_6~=1
replace abovegr6o=teach_11 if temp>=15 & temp~=. & abovegr6o~=1 & teach_11~=0 & teach_11~=. & teach_6~=1
replace abovegr6o=teach_12 if temp>=15 & temp~=. & abovegr6o~=1 & teach_12~=0 & teach_12~=. & teach_6~=1
replace abovegr6o=0 if abovegr6o==. & temp~=. 
replace abovegr6o=. if year>1993
drop temp
egen temp=sum(abovegr6o), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr6o=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_7 if teach_6~=1
replace temp=teach_8 if temp~=1 & teach_8~=0 & teach_8~=. & teach_6~=1
replace temp=teach_9 if temp~=1 & teach_9~=0 & teach_9~=. & teach_6~=1
replace temp=teach_10 if temp~=1 & teach_10~=0 & teach_10~=. & teach_6~=1
replace temp=teach_11 if temp~=1 & teach_11~=0 & teach_11~=. & teach_6~=1
replace temp=teach_12 if temp~=1 & teach_12~=0 & teach_12~=. & teach_6~=1
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr6o=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr6o=tot_gr6o/tot_gr6o

	 * Eighth Grade *

		* Total *

gen temp=exp_gr8 if year<=1993
gen abovegr8=teach_8 if temp>=15 & temp~=.
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
gen abovegr8m=teach_8 if temp>=15 & temp~=.
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
gen abovegr8e=teach_8 if temp>=15 & temp~=.
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

		* Non-Math *

gen temp=exp_gr8 if year<=1993 & subject~="math" & subject~="selfcont"
gen abovegr8nm=teach_8 if temp>=15 & temp~=.
replace abovegr8nm=0 if abovegr8nm==. & temp~=. 
replace abovegr8nm=. if year>1993
drop temp
egen temp=sum(abovegr8nm), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr8nm=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_8 if subject~="math" & subject~="selfcont"
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr8nm=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr8nm=tot_above_gr8nm/tot_gr8nm

		* Non-English *

gen temp=exp_gr8 if year<=1993 & subject~="end/read" & subject~="bilingual" & subject~="selfcont"
gen abovegr8ne=teach_8 if temp>=15 & temp~=.
replace abovegr8ne=0 if abovegr8ne==. & temp~=. 
replace abovegr8ne=. if year>1993
drop temp
egen temp=sum(abovegr8ne), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr8ne=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_8 if subject~="end/read" & subject~="bilingual" & subject~="selfcont"
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr8ne=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr8ne=tot_above_gr8ne/tot_gr8ne

		* Other *

gen temp=exp_gr9 if year<=1993
replace temp=exp_gr10 if year<=1993 & temp==.
replace temp=exp_gr11 if year<=1993 & temp==.
replace temp=exp_gr12 if year<=1993 & temp==.
gen abovegr8o=teach_9 if temp>=15 & temp~=. & teach_8~=1
replace abovegr8o=teach_9 if temp>=15 & temp~=. & abovegr8o~=1 & teach_9~=0 & teach_9~=. & teach_8~=1
replace abovegr8o=teach_10 if temp>=15 & temp~=. & abovegr8o~=1 & teach_10~=0 & teach_10~=. & teach_8~=1
replace abovegr8o=teach_11 if temp>=15 & temp~=. & abovegr8o~=1 & teach_11~=0 & teach_11~=. & teach_8~=1
replace abovegr8o=teach_12 if temp>=15 & temp~=. & abovegr8o~=1 & teach_12~=0 & teach_12~=. & teach_8~=1
replace abovegr8o=0 if abovegr8o==. & temp~=. 
replace abovegr8o=. if year>1993
drop temp
egen temp=sum(abovegr8o), by(rcds_fix year)
replace temp=. if year>1993
egen tot_above_gr8o=mean(temp), by(rcds_fix)
drop temp
gen temp=teach_9 if teach_8~=1
replace temp=teach_10 if temp~=1 & teach_10~=0 & teach_10~=. & teach_8~=1
replace temp=teach_11 if temp~=1 & teach_11~=0 & teach_11~=. & teach_8~=1
replace temp=teach_12 if temp~=1 & teach_12~=0 & teach_12~=. & teach_8~=1
egen temp2=sum(temp), by(rcds_fix year)
replace temp2=. if year>1993
egen tot_gr8o=mean(temp2), by(rcds_fix)
drop temp temp2
gen pct_above_gr8o=tot_gr8o/tot_gr8o

* Exits *

gen temp=exit*teach_3 if exp_fix>=15
egen exit_gr3=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_6 if exp_fix>=15
egen exit_gr6=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_8 if exp_fix>=15
egen exit_gr8=sum(temp), by(rcds_fix year)
drop temp

* Exits by Subject *

gen temp=exit*teach_3 if exp_fix>=15 & (subject=="math" | subject=="selfcont")
egen exit_gr3m=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_3 if exp_fix>=15  & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen exit_gr3e=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_6 if exp_fix>=15 & (subject=="math" | subject=="selfcont")
egen exit_gr6m=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_6 if exp_fix>=15  & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
egen exit_gr6e=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_8 if exp_fix>=15 & (subject=="math" | subject=="selfcont")
egen exit_gr8m=sum(temp), by(rcds_fix year)
drop temp
gen temp=exit*teach_8 if exp_fix>=15 & (subject=="end/read" | subject=="bilingual" | subject=="selfcont")
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

* Percent of Teachers with Different Experience Levels *

gen treated_grades=1 if teach_3>0 | teach_6>0 | teach_8>0

set more off
local yr "3 6 8"
foreach x of local yr{
gen temp=teach_`x' if exp_fix==1 & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr1=temp2/temp3
ren temp2 tot`x'_tchr1
drop temp temp3
gen temp=teach_`x' if exp_fix==2 & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr2=temp2/temp3
ren temp2 tot`x'_tchr2
drop temp temp3
gen temp=teach_`x' if exp_fix==3 & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr3=temp2/temp3
ren temp2 tot`x'_tchr3
drop temp temp3
gen temp=teach_`x' if exp_fix==4 & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr4=temp2/temp3
ren temp2 tot`x'_tchr4
drop temp temp3
gen temp=teach_`x' if exp_fix==5 & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr5=temp2/temp3
ren temp2 tot`x'_tchr5
drop temp temp3
gen temp=teach_`x' if exp_fix>=6 & exp_fix<=9 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr6_9=temp2/temp3
ren temp2 tot`x'_tchr6_9
drop temp temp3
gen temp=teach_`x' if exp_fix>=10 & exp_fix<=14 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr10_14=temp2/temp3
ren temp2 tot`x'_tchr10_14
drop temp temp3
gen temp=teach_`x' if exp_fix>=15 & exp_fix<=19 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr15_19=temp2/temp3
ren temp2 tot`x'_tchr15_19
drop temp temp3
gen temp=teach_`x' if exp_fix>=20 & exp_fix<=24 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr20_24=temp2/temp3
ren temp2 tot`x'_tchr20_24
drop temp temp3
gen temp=teach_`x' if exp_fix>=25 & exp_fix<=29 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr25_29=temp2/temp3
ren temp2 tot`x'_tchr25_29
drop temp temp3
gen temp=teach_`x' if exp_fix>=30 & exp_fix<=34 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr30_34=temp2/temp3
ren temp2 tot`x'_tchr30_34
drop temp temp3
gen temp=teach_`x' if exp_fix>=35 & exp_fix<=39 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr35_39=temp2/temp3
ren temp2 tot`x'_tchr35_39
drop temp temp3
gen temp=teach_`x' if exp_fix>=40 & exp_fix~=. & teach_`x'>0
replace temp=0 if temp==. & teach_`x'>0
egen temp2=sum(temp), by(rcds_fix year)
egen temp3=sum(teach_`x'), by(rcds_fix year)
gen pct`x'_tchr40=temp2/temp3
ren temp2 tot`x'_tchr40
drop temp temp3
}

save analysis_teacher, replace

* COLLAPSE TO SCHOOL-YEAR MEANS TO READ INTO THE TEST SCORE DATA *

collapse (mean) teach_3 teach_6 teach_8 grade3 grade6 grade8 totexp exit exit_gr3 exit_gr3m exit_gr3e exit_gr6 exit_gr6m exit_gr6e exit_gr8 exit_gr8m exit_gr8e newtchr_gr3 newtchr_gr6 newtchr_gr8 exp_fix exp_gr3 exp_gr6 exp_gr8 abovegr3 pct_above_gr3 tot_above_gr3 tot_gr3 pct_above_gr3m tot_above_gr3m tot_gr3m pct_above_gr3e tot_above_gr3e tot_gr3e pct_above_gr3nm tot_above_gr3nm tot_gr3nm pct_above_gr3ne tot_above_gr3ne tot_gr3ne pct_above_gr3o tot_above_gr3o tot_gr3o abovegr6 pct_above_gr6 tot_above_gr6 tot_gr6 pct_above_gr6m tot_above_gr6m tot_gr6m pct_above_gr6e tot_above_gr6e tot_gr6e pct_above_gr6nm tot_above_gr6nm tot_gr6nm pct_above_gr6ne tot_above_gr6ne tot_gr6ne pct_above_gr6o tot_above_gr6o tot_gr6o abovegr8 pct_above_gr8 tot_above_gr8 tot_gr8 pct_above_gr8m tot_above_gr8m tot_gr8m pct_above_gr8e tot_above_gr8e tot_gr8e pct_above_gr8nm tot_above_gr8nm tot_gr8nm pct_above_gr8ne tot_above_gr8ne tot_gr8ne pct_above_gr8o tot_above_gr8o tot_gr8o pct3_tchr1 pct3_tchr2 pct3_tchr3 pct3_tchr4 pct3_tchr5 pct3_tchr6_9 pct3_tchr10_14 pct3_tchr15_19 pct3_tchr20_24 pct3_tchr25_29 pct3_tchr30_34 pct3_tchr35_39 pct3_tchr40 pct6_tchr1 pct6_tchr2 pct6_tchr3 pct6_tchr4 pct6_tchr5 pct6_tchr6_9 pct6_tchr10_14 pct6_tchr15_19 pct6_tchr20_24 pct6_tchr25_29 pct6_tchr30_34 pct6_tchr35_39 pct6_tchr40 pct8_tchr1 pct8_tchr2 pct8_tchr3 pct8_tchr4 pct8_tchr5 pct8_tchr6_9 pct8_tchr10_14 pct8_tchr15_19 pct8_tchr20_24 pct8_tchr25_29 pct8_tchr30_34 pct8_tchr35_39 pct8_tchr40 tot3_tchr1 tot3_tchr2 tot3_tchr3 tot3_tchr4 tot3_tchr5 tot3_tchr6_9 tot3_tchr10_14 tot3_tchr15_19 tot3_tchr20_24 tot3_tchr25_29 tot3_tchr30_34 tot3_tchr35_39 tot3_tchr40 tot6_tchr1 tot6_tchr2 tot6_tchr3 tot6_tchr4 tot6_tchr5 tot6_tchr6_9 tot6_tchr10_14 tot6_tchr15_19 tot6_tchr20_24 tot6_tchr25_29 tot6_tchr30_34 tot6_tchr35_39 tot6_tchr40 tot8_tchr1 tot8_tchr2 tot8_tchr3 tot8_tchr4 tot8_tchr5 tot8_tchr6_9 tot8_tchr10_14 tot8_tchr15_19 tot8_tchr20_24 tot8_tchr25_29 tot8_tchr30_34 tot8_tchr35_39 tot8_tchr40, by(rcds_fix year)

sort rcds_fix year
dmerge rcds_fix year using rcdata2_idfix.dta
gen region=substr(rcds,1,9)
tab _merge

* DROP THE ONES THAT DON'T MATCH - ALL HIGH SCHOOLS AND ALTERNATIVE SCHOOLS * 
drop if _merge==1
drop if _merge==2

* FIX SOME OUTLIERS *

replace tot_gr3=. if tot_gr3==0
replace tot_above_gr3=. if tot_gr3==0
replace tot_above_gr3m=. if tot_gr3==0
replace tot_above_gr3e=. if tot_gr3==0
replace tot_above_gr3nm=. if tot_gr3==0
replace tot_above_gr3ne=. if tot_gr3==0
replace tot_above_gr3o=. if tot_gr3==0
replace pct_above_gr3=. if tot_gr3==0
replace pct_above_gr3m=. if tot_gr3==0
replace pct_above_gr3e=. if tot_gr3==0
replace pct_above_gr3nm=. if tot_gr3==0
replace pct_above_gr3ne=. if tot_gr3==0
replace pct_above_gr3o=. if tot_gr3==0
replace tot_gr6=. if tot_gr6==0
replace tot_above_gr6=. if tot_gr6==0
replace tot_above_gr6m=. if tot_gr6==0
replace tot_above_gr6e=. if tot_gr6==0
replace tot_above_gr6nm=. if tot_gr6==0
replace tot_above_gr6ne=. if tot_gr6==0
replace tot_above_gr6o=. if tot_gr6==0
replace pct_above_gr6=. if tot_gr6==0
replace pct_above_gr6m=. if tot_gr6==0
replace pct_above_gr6e=. if tot_gr6==0
replace pct_above_gr6nm=. if tot_gr6==0
replace pct_above_gr6ne=. if tot_gr6==0
replace pct_above_gr6o=. if tot_gr6==0
replace tot_gr8=. if tot_gr8==0
replace tot_above_gr8=. if tot_gr8==0
replace tot_above_gr8m=. if tot_gr8==0
replace tot_above_gr8e=. if tot_gr8==0
replace tot_above_gr8nm=. if tot_gr8==0
replace tot_above_gr8ne=. if tot_gr8==0
replace tot_above_gr8o=. if tot_gr8==0
replace pct_above_gr8=. if tot_gr8==0
replace pct_above_gr8m=. if tot_gr8==0
replace pct_above_gr8e=. if tot_gr8==0
replace pct_above_gr8nm=. if tot_gr8==0
replace pct_above_gr8ne=. if tot_gr8==0
replace pct_above_gr8o=. if tot_gr8==0

* GENERATE POST-TREATMENT INTERACTION VARIABLES  *

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
gen post_gr3nm=post*pct_above_gr3nm
gen post_gr3ne=post*pct_above_gr3ne
gen post_totabovegr3nm=post*tot_above_gr3nm
gen post_totabovegr3ne=post*tot_above_gr3ne
gen post_totgr3nm=post*tot_gr3nm
gen post_totgr3ne=post*tot_gr3ne
gen post_gr3o=post*pct_above_gr3o
gen post_totabovegr3o=post*tot_above_gr3o
gen post_totgr3o=post*tot_gr3o

gen post_gr6=post*pct_above_gr6
gen post_gr6m=post*pct_above_gr6m
gen post_gr6e=post*pct_above_gr6e
gen post_totabovegr6=post*tot_above_gr6
gen post_totabovegr6m=post*tot_above_gr6m
gen post_totabovegr6e=post*tot_above_gr6e
gen post_totgr6=post*tot_gr6
gen post_totgr6m=post*tot_gr6m
gen post_totgr6e=post*tot_gr6e
gen post_gr6nm=post*pct_above_gr6nm
gen post_gr6ne=post*pct_above_gr6ne
gen post_totabovegr6nm=post*tot_above_gr6nm
gen post_totabovegr6ne=post*tot_above_gr6ne
gen post_totgr6nm=post*tot_gr6nm
gen post_totgr6ne=post*tot_gr6ne
gen post_gr6o=post*pct_above_gr6o
gen post_totabovegr6o=post*tot_above_gr6o
gen post_totgr6o=post*tot_gr6o
gen post_gr8=post*pct_above_gr8
gen post_gr8m=post*pct_above_gr8m
gen post_gr8e=post*pct_above_gr8e
gen post_totabovegr8=post*tot_above_gr8
gen post_totabovegr8m=post*tot_above_gr8m
gen post_totabovegr8e=post*tot_above_gr8e
gen post_totgr8=post*tot_gr8
gen post_totgr8m=post*tot_gr8m
gen post_totgr8e=post*tot_gr8e
gen post_gr8nm=post*pct_above_gr8nm
gen post_gr8ne=post*pct_above_gr8ne
gen post_totabovegr8nm=post*tot_above_gr8nm
gen post_totabovegr8ne=post*tot_above_gr8ne
gen post_totgr8nm=post*tot_gr8nm
gen post_totgr8ne=post*tot_gr8ne
gen post_gr8o=post*pct_above_gr8o
gen post_totabovegr8o=post*tot_above_gr8o
gen post_totgr8o=post*tot_gr8o

egen clusterid=group(rcds_fix)
egen flag=tag(clusterid year)
drop if flag==0
drop flag

* MAKE DATA SET GRADE-SCHOOL-YEAR INSTEAD OF SCHOOL-YEAR *

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

* SAVE THE ANALYSIS DATA FILE - THIS IS THE FILE USED TO GENERATE ALL OF THE RESULTS *

save analysis-data, replace


