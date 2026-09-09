*** CREATED BY RYAN STEED ***

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

*** EDITED BY Ryan Steed
* [ SKIPPING TEACHER MICRODATA CONSTRUCTION ]
use analysis_teacher
***

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


