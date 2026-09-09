
////////////////////////////////////////////////////////////////////////////////
/// 	
/// 	Replication for  "Do Police Maximize Arrests or Minimize Crime?"  
/// 	Allison Stashko  		
/// 	Created May 23, 2022
/// 							
////////////////////////////////////////////////////////////////////////////////


/// See accompanying README.pdf

// 1_Tables.do and 2_Figures.do use the following packages available with SSC:
	// ssc install reghdfe
	// ssc install psacalc
	// ssc install interflex
	// ssc install grstyle

*version 16.1 

clear all
set more off
set matsize 800

//set directory names
*** Edited by Annie
global ReplicationPath "." 
global InputPath "$ReplicationPath/Input"
global CodePath "$ReplicationPath/Code"
global TablesPath "$ReplicationPath/Tables"
global FiguresPath "$ReplicationPath/Figures"
***
// Run code for tables and figures

do "$CodePath/1_Tables.do"

* do "../$CodePath/2_Figures.do"

	
