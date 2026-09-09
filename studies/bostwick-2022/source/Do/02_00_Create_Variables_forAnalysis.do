****************************************************
*Create variables needed for analysis
*Oct 16, 2020
****************************************************



*Current User for directories
global mydir "/Users/vkbostwick"
cd "$mydir/Dropbox/OLDA/Calendars/Analysis_Data/All_Campuses"


**************************************************
*Input files
local in "Final_Enrollment_Data_SM99-SP17.dta"
*Output files
local main "Main_Data_Sample.dta"
local full "Full_Data_Sample.dta"
***************************************************************************

*Local that contains last term available in the data
local max_term=72



use `in' , clear

*Drop the very last cohort (F2016) for whom we only observe a partial school-year
*We cannot observe dropout or transfer out for this last cohort
drop if first_term==70



**************************************************************
*Clean up various control variables and identifiers
**************************************************************
**Demographic variables**
*Age variable
replace birth_yr="" if birth_yr=="UNKN"
destring birth_yr, replace
gen age=first_enroll_yr_num-birth_yr
gen age2=age*age
*Gender variable
encode sex_code, gen(female)
replace female=0 if female==2
replace female=. if female==3
*international variable
gen international=race_ethnic_code=="NR"
*replace race=unknown for international students
replace race_ethnic_code="UK" if international==1
*lump native-american with other
replace race_ethnic_code="UK" if race_ethnic_code=="AI"
*race indicators
tab race_ethnic_code, gen(race_ind)

***Drop people without demographics***
drop if missing(age, female, international, race_ethnic_code)

***Flag people who have more than 1 enrollment gap in their first 6 years
gen stopouts=(enroll_gaps_first6>1)

*Define still_enrolled yrs_enrolled dropout
*Indicator for still enrolled in SP17
gen stillenrolled=last_term==`max_term'
replace stillenrolled=0 if everBA==1 | transfer_out==1
*Indicator for dropout
gen dropout=(everBA==0 & transfer_out==0)
replace dropout=0 if stillenrolled==1
*number of years enrolled
*Note: yrs_enrolled==years to dropout if dropout==1
gen yrs_enrolled=yrstoBA if everBA==1
replace yrs_enrolled=(last_term-first_term+1)/4 if dropout==1 | transfer_out==1
*Flag if initially undeclared major
gen undeclared=(initial_major==.)


*encode stem designation variables
foreach var of varlist initial_stem stem_spy* {
	gen `var'_ind =(`var'=="All Levels")
	replace `var'_ind=. if `var'==""
	drop `var'
	rename `var'_ind `var'
}
replace initial_stem=0 if initial_major==.

*Encode campus id
encode campus_code, gen(campus_num)

*Create cohort variable
egen cohort=group(campus_num first_term)



**************************************************************
*Create main outcome variables
**************************************************************
*BAin4 = graduated on-time
forval yrstofinish = 1/6 {
	gen BAin`yrstofinish' = (yrstoBA<`yrstofinish') if first_term<=(`max_term'+1 - 4*(`yrstofinish'-0.25))
}



**************************************************************
*Create main treatment variables
**************************************************************
***Create main x-var: semester***
*AKRN, BGSU, CLEV, KENT, MIAM, TLDO are always on semesters
*BGSU switches to semester in F1982
*CLEV switches to semester in F1999
*KENT switches to semester in F1979
*TLDO switches to semester in F1997
gen semester=1 if inst_code=="AKRN" | inst_code=="BGSU" | inst_code=="CLEV" | inst_code=="KENT" | inst_code=="MIAM" | inst_code=="TLDO"
*CINC, OHSU, OHUN, WSUN switch to semester in SM/F2012
replace semester=(first_term>=54) if inst_code=="CINC" | inst_code=="OHSU" | inst_code=="OHUN" | inst_code=="WSUN"
*CNTL switches to semester in F2005
replace semester=(first_term>=26) if inst_code=="CNTL"
*SHAW switches to semester in SM2007
replace semester=(first_term>=34) if inst_code=="SHAW"
*YNGS switches to semester in F00
replace semester=(first_term>=6) if inst_code=="YNGS"

*For event studies:
*Create variable t that measures years relative to the switch to semesters (t=0 in year of switch)
gen t=first_term-54 if inst_code=="CINC" | inst_code=="OHSU" | inst_code=="OHUN" | inst_code=="WSUN"
replace t=first_term-26 if inst_code=="CNTL"
replace t=first_term-34 if inst_code=="SHAW"
replace t=first_term-6 if inst_code=="YNGS"
replace t=first_term-2 if inst_code=="CLEV"
replace t=first_term+6 if inst_code=="TLDO"
replace t=first_term+66 if inst_code=="BGSU"
replace t=first_term+78 if inst_code=="KENT"
replace t=t/4
***NOTE: t=. for always semester schools!***

*Create dummy variables for each value of t
tab t, gen(tdummy)
*Group always-semester schools with t>=5
forval i=1/50 {
	replace tdummy`i'=0 if t==.
}
gen fiveormore=(t>=5)
replace fiveormore=1 if t==.
*Create 1 dummy for t<=-10
gen tenbefore=(t<=-10)

*Define partially treated (G1), from fully treated (G2)
*Create different definition of partially treated (G1) for 2-, 3-, 4-, and 5-year outcomes
*t=-4 is last untreated year for 4-year outcomes
*Note: there is no partially treated group for 1-year outcomes
gen G1_2=(t==-1)
gen G1_3=(t>=-2 & t<0)
gen G1_4=(t>=-3 & t<0)
gen G1_5=(t>=-4 & t<0)
gen G2=(t>=0)




**************************************************************
*Create outcome variables for First-year mechanism analysis
**************************************************************
*First-year mechanism variables:
*Dropout, transfer-out, full course-load, gpa/probation, switching major

*First, determine who is still enrolled at the start of each enrollment year "sy" 
*Let each school-year start in Summer (except 1st year starts in Fall) and end in Spring
gen started_sy1=1
forval i=2/6 {
	local j =`i'-1
	*Student started sy2 if still enrolled in Summer after first term
	gen started_sy`i' = yrs_enrolled>=`j' if first_term<=(`max_term'+1-4*`j')
}

*Dropout in freshman year (sy1)
*Note: because we can't see if SP17 is the last term for 2016 cohort or if they're still enrolled,
	*there will be one less cohort for dropout_sy1 and transfer_sy1 than for the other mechanism variables
gen dropout_sy1 = (yrs_enrolled<1 & dropout==1) if first_term<=(`max_term'+1-4)

*Transfer-out in freshman year (sy1)
gen transfer_sy1=(yrs_enrolled<1 & transfer_out==1) if first_term<=(`max_term'+1-4)

*Attempts on-track course-load in freshman year (sy1)
*Note: definition of a full course-load depends on whether school is currently on quarters or semesters
*Identify in each school-year whether the student was on semesters or not
forval i=1/6 {
	gen onsemester`i'=(t>=(1-`i'))
}
gen full_load_sy1=(credit_hrs_attempted1>=30)*onsemester1 + (credit_hrs_attempted1>=45)*(1-onsemester1) 
replace full_load_sy1=0 if credit_hrs_attempted1==. 

*Note: Freshman-year GPA variable already constructed in data (gpa_spy1)
*Needs cleaning (do for all enrollment years sy1-sy6):
forval i=1/6 {
	*Clean GPA
	replace gpa_spy`i'=gpa_spy`i'/10 if gpa_spy`i'>=10
	replace gpa_spy`i'=0 if gpa_spy`i'==. & started_sy`i'==1
	replace gpa_spy`i'=. if started_sy`i'!=1
	rename gpa_spy`i' gpa_sy`i'
}

*Elgible for academic probation (GPA<2.0) in freshman year (sy1)
gen probation_sy1 = (gpa_sy1<2)
replace probation_sy1=. if gpa_sy1==.


*Switched major in freshman year (sy1)
*If starting undeclared, don't count first major as a "switch"
gen switch_sy1=(initial_major!=major_cipcode2010_spy1)
replace switch_sy1=0 if initial_major==.





**************************************************************
*Create outcome variables for cumulative mechanism analysis
**************************************************************
*For each of the first 6 years of enrollment, define cumulative measures of:
*on-track course-taking; gpa/academic probation; major-switching

*On-track credits attempted by end of year sy1-sy6:
*Calculate total cumulative credits at the end of each school-year
gen total_credits1=credit_hrs_attempted1
replace total_credits1=0 if credit_hrs_attempted1==.
forval i=2/6 {
	local j=`i'-1
	gen total_credits`i'= total_credits`j' + credit_hrs_attempted`i'
	replace total_credits`i'=total_credits`j' if credit_hrs_attempted`i'==.
}
*Is the number of total cumulative credits enough to be "on-track"?
*On-track student must complete 15 credits-per-term
*Depends on whether student has been on quarters or semesters in each year
*If semesters, #terms = 2. If quarters, #terms=3
gen num_terms=2
replace num_terms=3 if t<0
forval i=1/6 {
	gen ontrack_enrolled_sy`i'= (total_credits`i'>=num_terms*15) if first_term<=(`max_term'+1-4*(`i'-0.25))
	replace ontrack_enrolled_sy`i'=. if started_sy`i'!=1
	*Add 2 to #terms if the next year is on semesters, or 3 if quarters
	*Stop adding terms after 4 years of enrollment
	local neg_i=`i'*-1
	replace num_terms=num_terms+2 if `i'<4
	replace num_terms=num_terms+1 if `i'<4 & t<`neg_i' 
}
drop num_terms



*Note: Cumulative GPA variable already constructed in data
*Elgible for academic probation (GPA<2.0) in the spring of each sy
forval i=1/6 {
	gen probation_spy`i' = (gpa_sy`i'<2)
	replace probation_spy`i'=. if gpa_sy`i'==.
}


*Indicator for has ever switched majors by end of each sy1-sy6
*First define 1(switch major in year T), conditional on continued enrollment
*Then create cumulative variable for ever switch major by year T
*Note: switch_sy1 already defined above
gen ever_switch_sy1 =(switch_sy1==1)
forval i=2/6 {
	local j =`i'-1
	gen switch_sy`i'=(major_cipcode2010_spy`i'!=major_cipcode2010_spy`j')
	replace switch_sy`i'=0 if major_cipcode2010_spy`j'==.
	replace switch_sy`i'=. if started_sy`i'!=1
	gen ever_switch_sy`i' = (ever_switch_sy`j'==1 | switch_sy`i'==1) if started_sy`i'==1
}






****************************************************
*Want to exclude students who are "enrolled" but not taking credits
*That means years with zero credit hrs but dropout==0
****************************************************

*First define cumulative dropout variable (dropped out on or before end of sy T)
forval i=1/6{
	gen dropout_by`i' = (yrs_enrolled<`i' & dropout==1) if first_term<=(`max_term'+1-4*(`i'+.75))
}

drop if credit_hrs_attempted1==0 & dropout_by1==0
drop if credit_hrs_attempted2==0 & dropout_by2==0
drop if credit_hrs_attempted3==0 & dropout_by3==0
drop if credit_hrs_attempted4==0 & dropout_by4==0


*Also define cumulative transfer-out variable (transferred out on or before end of sy T)
*For use in descriptive analysis/summary statistics
forval i=1/6{
	gen transfer_by`i' = (yrs_enrolled<`i' & transfer_out==1) if first_term<=(`max_term'+1-4*(`i'+.75))
}





*******************************************
*Create cluster id for each set of ovverlapping cohorts within a school
*******************************************
egen yr_group1 = cut(first_enroll_yr_num), at (1998, 1999, 2004, 2009, 2014, 2017)
egen yr_group2 = cut(first_enroll_yr_num), at (1998, 2000, 2005, 2010, 2015, 2017)
egen yr_group3 = cut(first_enroll_yr_num), at (1998, 2001, 2006, 2011, 2016,  2017)
egen yr_group4 = cut(first_enroll_yr_num), at (1998, 2002, 2007, 2012, 2017)
egen yr_group5 = cut(first_enroll_yr_num), at (1998, 2003, 2008, 2013, 2017)

egen cluster_id1 = group(campus_num yr_group1)
egen cluster_id2 = group(campus_num yr_group2)
egen cluster_id3 = group(campus_num yr_group3)
egen cluster_id4 = group(campus_num yr_group4)
egen cluster_id5 = group(campus_num yr_group5)




****Drop unnecessary variables****
drop credit_hrs_completed* courses_completed* major_cipcode2010* sex_code birth* race_ethnic_name enroll_gaps* 
drop yr_num_degree term_code_degree  pgrm_code  multipleBA
compress

save `full' , replace

*keep only cohorts that we can see for at least 4 years
keep if first_term<=(`max_term'+1-4*3.75)
save `main' , replace

