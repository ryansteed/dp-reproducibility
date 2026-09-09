***************************************************************************
*Create an individual-level dataset for all first-time freshmen at all schools
*Exclude transfer students and spring/winter/summer starters
*Include: demographics and degree information, major in yrs1-4, grades, credits, HS zip code
*Sept 25, 2020
***************************************************************************


*Current User for directories
global mydir "/Users/vkbostwick"
clear
set more off

*Create master list of all CIP codes*
*For later use in 01_02_01_Merge_Files.do*
cd "$mydir/Dropbox/OLDA/Raw_Other_Files"
do "Create_CIPdtafiles.do"



cd "$mydir/Dropbox/OLDA/Calendars"

*Create a file including all undergraduate enrollment SM99-SP17 
*Each obs is a person-inst-term
*Final output file: "Intermediate_Data/All_Campuses/Enroll_allOH_SM99-SP17.dta"
do "Current_Do_Files/All_Campuses/01_01_01_Create_Enrollment_allOH_SM99-SP17.do"

**************************************************************
*Append and clean student entrance files
*Keep non-transfer, first time students (not necessarily freshmen)
*merge in race demographics
*Final output file: "Intermediate_Data/All_Campuses/Entrance_allOH_Und_FirstTime.dta"
***************************************************************************
do "Current_Do_Files/All_Campuses/01_01_02_Create_Demographics.do"

*Take course enrollment file
*Collapse down to term-level
*Output file: "Intermediate_Data/All_Campuses/Credits_allOH_SM99-SP17.dta"
do "Current_Do_Files/All_Campuses/01_01_03_Calc_Credit_Hours.do"

*Clean GPA files
*Output file: "Intermediate_Data/All_Campuses/GPA_allOH_SM99-SP17.dta"
do "Current_Do_Files/All_Campuses/01_01_04_Clean_GPA.do"


*Merge together enrollment, demographics, credit hours, and gpa
*Output file: "Intermediate_Data/All_Campuses/FTFresh_FallStarts_00-16_Long.dta"
do "Current_Do_Files/All_Campuses/01_02_01_Merge_Files.do"

*Collapse to school-year variables for first 6 years of enrollment
*Reshape wide to create individual-level dataset
*Output file: "Intermediate_Data/All_Campuses/Indiv_FTFresh_allOH_SM99-SP17.dta"
do "Current_Do_Files/All_Campuses/01_02_02_Collapse_to_Individual.do"


*Merge data on degrees awarded into file 
*Output file: "Intermediate_Data/All_Campuses/Indiv_FTFresh_withDegrees_SM99-SP17.dta"
do "Current_Do_Files/All_Campuses/01_03_Merge_Degrees_FTFresh_allOH.do"


*Identify students who enroll at a different campus (as an undergrad) following last_term
*(aka students who transfer out of original college)
*Output file: "Intermediate_Data/All_Campuses/Enrollment_Data_noHS_SM99-SP17.dta"
do "Current_Do_Files/All_Campuses/01_04_Identify_Transfers_Out.do"

*Clean High School zip code data
do "Current_Do_Files/All_Campuses/01_05_01_Clean_HS_Data.do"
*Merge HS zip codes into main file
*Output file: "Analysis_Data/All_Campuses/Final_Enrollment_Data_SM99-SP17.dta"
do "Current_Do_Files/All_Campuses/01_05_02_Merge_HS_Data.do"


*Final dataset: "Analysis_Data/All_Campuses/Final_Enrollment_Data_SM99-SP17.dta"

