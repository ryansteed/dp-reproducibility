
*************************************************************************************************
********* This program calls in the 6 IPEDS files and cleans them *******************************
**** the result of this program is the cleaned IPEDS data for analysis: ipeds_cleaned_final  ****
*************************************************************************************************

clear
global PATH ".."

cd "$PATH/Do"
/*
These programs call in the sub-programs that are downloadable from IPEDS and the raw CSV datafiles 
that are also downloadable from IPEDS. 
*/

/*
do directorycreate1_2018 
cd "$PATH/Do"
do facultycreate1_2018
cd "$PATH/Do"
do gradcreate1_2018
cd "$PATH/Do"
do institutioncreate1_2018
cd "$PATH/Do"
do revenuecreate1_2018
cd "$PATH/Do"
do tuitioncreate1_2018
*/
clear

/*
directorymaster1_2018.dta includes the universe of 4-year, non-profit colleges and universities
and contains information about the Carnegie classification, type of school, address, etc.
*/
cd "$PATH/Data"
use directorymaster1_2018.dta

/*
The directory file is merged with institutionmaster1_2018.dta, which contains information on the
academic calendar a school uses.
*/

merge 1:1 unitid year using institutionmaster1_2018.dta
drop if _merge!=3
drop _merge

/*
The gradmaster1_2018.dta contains four- and six-year graduation rates and these rates by
various subpopulations.
*/

sort unitid year
merge 1:1 unitid year using gradmaster1_2018.dta


drop if _merge==2
gen merge=_merge
drop _merge

/*
The revenuesmaster1_2018.dta includes costs and revenues
*/

sort unitid year
merge 1:1 unitid year using revenuesmaster1_2018.dta
drop if _merge==2
drop _merge


/*
We then merged in faculty (facultymaster1_2018.dta) and tuition data (tuitionmaster1_2018.dta)
*/

sort unitid year
merge 1:1 unitid year using facultymaster1_2018.dta
drop if _merge==2
drop _merge
sort unitid year
merge 1:1 unitid year using tuitionmaster1_2018.dta
drop if _merge==2
drop _merge


/*
We drop the "other calendar system" observations. We code four1four schedules as 
semesters and trimesters are coded as quarters. Estimates are not sensitive to this re-coding
*/

drop if othercalsys==1
gen semester2=semester+four1four
gen quarter2=quarter+trimester
sort unitid year

*drop very small schools as they are not representative.
*Estimates are not sensitive to this sample selection 
bysort unitid: egen meansize = mean(totcohortsize)
drop if meansize<100

*** The following code produces variables for the event studies
sort unitid year

bysort unitid: gen yeartosem=year if semester2[_n]-semester2[_n-1]==1
bysort unitid: gen yeartoquart=year if quarter2[_n]-quarter2[_n-1]==1


bysort unitid: egen yearofsem=max(yeartosem)
bysort unitid: egen yearofquart=max(yeartoquart)
drop if yearofquart!=.
gen changer=0
replace changer=1 if yearofsem!=.


drop yeartosem yeartoquart yearofquart
gen yearstosem=year-yearofsem


gen yearsbf23=0
replace yearsbf23=1 if yearstosem==-23
gen yearsbf22=0
replace yearsbf22=1 if yearstosem==-22
gen yearsbf21=0
replace yearsbf21=1 if yearstosem==-21
gen yearsbf20=0
replace yearsbf20=1 if yearstosem==-20
gen yearsbf19=0
replace yearsbf19=1 if yearstosem==-19
gen yearsbf18=0
replace yearsbf18=1 if yearstosem==-18
gen yearsbf17=0
replace yearsbf17=1 if yearstosem==-17
gen yearsbf16=0
replace yearsbf16=1 if yearstosem==-16
gen yearsbf15=0
replace yearsbf15=1 if yearstosem==-15
gen yearsbf14=0
replace yearsbf14=1 if yearstosem==-14
gen yearsbf13=0
replace yearsbf13=1 if yearstosem==-13
gen yearsbf12=0
replace yearsbf12=1 if yearstosem==-12
gen yearsbf11=0
replace yearsbf11=1 if yearstosem==-11
gen yearsbf10=0
replace yearsbf10=1 if yearstosem==-10
gen yearsbf9=0
replace yearsbf9=1 if yearstosem==-9
gen yearsbf8=0
replace yearsbf8=1 if yearstosem==-8
gen yearsbf7=0
replace yearsbf7=1 if yearstosem==-7
gen yearsbf6=0
replace yearsbf6=1 if yearstosem==-6
gen yearsbf5=0
replace yearsbf5=1 if yearstosem==-5
gen yearsbf4=0
replace yearsbf4=1 if yearstosem==-4
gen yearsbf3=0
replace yearsbf3=1 if yearstosem==-3
gen yearsbf2=0
replace yearsbf2=1 if yearstosem==-2
gen yearsbf1=0
replace yearsbf1=1 if yearstosem==-1

gen yearof=0
replace yearof=1 if yearstosem==0

gen yearsaf1=0
replace yearsaf1=1 if yearstosem==1
gen yearsaf2=0
replace yearsaf2=1 if yearstosem==2
gen yearsaf3=0
replace yearsaf3=1 if yearstosem==3
gen yearsaf4=0
replace yearsaf4=1 if yearstosem==4
gen yearsaf5=0
replace yearsaf5=1 if yearstosem==5
gen yearsaf6=0
replace yearsaf6=1 if yearstosem==6
gen yearsaf7=0
replace yearsaf7=1 if yearstosem==7
gen yearsaf8=0
replace yearsaf8=1 if yearstosem==8
gen yearsaf9=0
replace yearsaf9=1 if yearstosem==9
gen yearsaf10=0
replace yearsaf10=1 if yearstosem==10
gen yearsaf11=0
replace yearsaf11=1 if yearstosem==11
gen yearsaf12=0
replace yearsaf12=1 if yearstosem==12
gen yearsaf13=0
replace yearsaf13=1 if yearstosem==13
gen yearsaf14=0
replace yearsaf14=1 if yearstosem==14
gen yearsaf15=0
replace yearsaf15=1 if yearstosem==15
gen yearsaf16=0
replace yearsaf16=1 if yearstosem==16

gen yearsaf17=0
replace yearsaf17=1 if yearstosem==17

gen yearsaf18=0
replace yearsaf18=1 if yearstosem==18
gen yearsaf19=0
replace yearsaf19=1 if yearstosem==19
gen yearsaf20=0
replace yearsaf20=1 if yearstosem==20
gen yearsaf21=0
replace yearsaf21=1 if yearstosem==21
gen yearsaf22=0
replace yearsaf22=1 if yearstosem==22

gen yearsaf10plus=0
replace yearsaf10plus=1 if yearstosem>=10 | (changer==0 & semester2==1)

gen yearsbf10minus=0
replace yearsbf10minus=1 if yearstosem<=-10 | (changer==0 & quarter2==1)


*cleaning a few variables 

replace revenue=revenue/1000000
replace cost=cost/1000000

gen public=0
replace public=1 if sector==1

save ipeds_cleaned_final.dta, replace
