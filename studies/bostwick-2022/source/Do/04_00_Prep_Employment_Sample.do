***************************************************************************
*We have requested all UI records corresponding to students in the "Full_Data_Sample.dta" file
*Clean the raw UI data and merge into "Full_Data_Sample.dta" for employment analysis
*Oct 15, 2020
***************************************************************************


*Current User for directories
global mydir "/Users/vkbostwick"

cd "$mydir/Dropbox/OLDA/Calendars"
clear
set more off

*Clean raw employment data
* Reshape so that each observation corresponds to a student X school-year
*4 output files: "Analysis_Data/All_Campuses/UI_Wages_cleaned_F99-07.dta"
				*"Analysis_Data/All_Campuses/UI_Wages_cleaned_F08-17.dta"
				*"Analysis_Data/All_Campuses/UI_NAICS_cleaned_F99-07.dta"
				*"Analysis_Data/All_Campuses/UI_NAICS_cleaned_F08-16.dta"
do "Current_Do_Files/All_Campuses/04_01_Clean_UI_Data.do"


*Merge cleaned employment data into estimation sample
*Create employment outcome variables
*Final output file: “FullSample_withEmp.dta"
do "Current_Do_Files/All_Campuses/04_02_Merge_UI_to_FullSample.do"


*Final dataset: "Analysis_Data/All_Campuses/FullSample_withEmp.dta"
