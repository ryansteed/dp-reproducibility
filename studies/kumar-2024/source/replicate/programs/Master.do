*****SET THE REPLICATE FOLDER AS WORKING DIRECTORY*****
cd "C:\Users\Anil Kumar\OneDrive\Dallas Fed\anil\research\texas_home_equity\credit_constraints\AEJ_final_replication\replicate"

**CURRENTLY ALL TABLES AND FIGURES WILL BE SAVED TO THE RESULTS FOLDER
global resultsdir "results"

set scheme  s2color

cap log close
log using "results\replication.log", replace text
adopath + "programs\stata_ado_files"
**EDIT and Execute "replicate\programs\config.do" TO CAREFULLY INSTALL REQUIRED PACKAGES IF NOT ALREADY INSTALLED 
include "programs\config.do"
/*some info about how and when the program was run*/
local variant = cond(c(MP),"MP",cond(c(SE),"SE",c(flavor)) )  
di "=== SYSTEM DIAGNOSTICS ==="
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `variant'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"
di "=========================="
**starting date and time
di c(current_date)
di c(current_time)

**NOTE: TO CREATE ALL TABLES AND FIGURES AFRESH, DELETE ALL FILES IN "replicate\results" FOLDER

**NOTE: TABLE 1 OF THE PAPER IS BASED ON PROPRIETORY DATA. ONCE YOU GET ACCESS TO THE DATA ON NUMBER OF LOAN ORIGINATIONS BY STATE AND YEAR FOR CASH-OUT LOANS, CLOSED END HOME EQUITY LOANS (HEL) AND HOME EQUITY LINES OF CREDIT  (HELOC), THEN TABLE CAN BE REPLICATED BY RUNNING "programs\Table 1.do". UNCOMMENT THE FOLLOWING LINE TO REPLICATE TABLE 1, YOU HAVE ACCESS TO THE DATA.
**do "programs\Table 1.do"

do "programs\Figure 1, A1 Table 2, 3.do"
do "programs\Figure 2A, 2B, 4A, 4B, A2, A3, A4, A5, A6 Table 5.do"
do "programs\Figure 3.do"

**NOTE: Run this only if R and required packages are installed on your computer
**ALSO NOTE THE FOLLOWING BEFORE RUNNING R CODE
**Uncomment the lines 4-8 of mcpanel_v2.R
**Change the address of working directory set in line 18
**Make sure the data being read in lines 21 and 22 are available in the appropritae directory
**The results from estimation using R will be saved in "replicate\results"
**NOW UNCOMMENT THE FOLLOWING LINE TO RUN R CODE FOR MATRIX COMPLETION FROM WITHIN STATA

**shell "C:\Program Files\R\R-4.1.0\bin\x64\R.exe" CMD BATCH "programs\mcpanel_v2.R"

**NOTE: If R and/or required packages are not installed or you want to avoid running R code then comment out the line above and copy previously created R matrix completion output from "data\R_mcpanel_results\mcpanel.dta" to "$resultsdir\mcpanel.dta" by uncommenting the next line

copy "data\R_mcpanel_results\mcpanel.dta" "$resultsdir\mcpanel.dta", replace

**NOTE: MUST RUN "programs\Figures 2A, 2B, 4A, 4B, A2, A3, A4, A5, A6 Table 5.do" BEFORE THIS TO CREATE an INPUT FILE FOR THE NEXT DO FILE

do "programs\Figure 5, A7, A8 Table 6.do"
do "programs\Table 4.do"
do "programs\Table A1.do"

**NOTE: Run this only if R and required packages are installed on your computer
**ALSO NOTE THE FOLLOWING BEFORE RUNNING R CODE
**Uncomment the lines 4-8 of mcpanel_v2_energystate.R
**Change the address of working directory set in line 18
**Make sure the data being read in lines 21 and 22 are available in the appropritae directory
**The results from estimation using R will be saved in "replicate\results"
**NOW UNCOMMENT THE FOLLOWING LINE TO RUN R CODE FOR MATRIX COMPLETION FROM WITHIN STATA

**shell "C:\Program Files\R\R-4.1.0\bin\x64\R.exe" CMD BATCH "programs\mcpanel_v2_energystate.R"

**NOTE: If R and/or required packages are not installed or you want to avoid running R code then comment out the line above and copy previously created R matrix completion output from "data\R_mcpanel_results\mcpanel_energystate.dta" to "$resultsdir\mcpanel_energystate.dta" by uncommenting the next line
 
copy "data\R_mcpanel_results\mcpanel_energystate.dta"  "$resultsdir\mcpanel_energystate.dta", replace

**NOTE: MUST HAVE RUN "programs\Figures 2A, 2B, 4A, 4B, A2, A3, A4, A5, A6 Table 5.do" BEFORE THIS TO CREATE an INPUT FILE FOR THE NEXT DO FILE

do "programs\Figure A9.do"

**********************************************************************************************************************************************
**********************************************************************************************************************************************
/***IMPORTANT NOTE: PSID EXTRACTS USED FOR Appendix Figure A2 ARE NOT ALLOWED WITH THIS REPLICATION ARCHIVE. THEY HAVE BEEN DEPOSITED AT THE OPENICPSR PSID ARCHIVE. MUST DOWNLOAD THE FOLLOWING TWO FILES USING THE DONWLOAD LINKS BELOW AND PLACE THEM IN "replicate\data" BEFORE EXECUTING THIS FILE TO REPLICATE APPENDIX TABLE A2 
(1) https://www.openicpsr.org/openicpsr/project/195021/version/V1/view?path=/openicpsr/195021/fcr:versions/V1/psid_variables_from_cnef.dta&type=file
(2) https://www.openicpsr.org/openicpsr/project/195021/version/V1/view?path=/openicpsr/195021/fcr:versions/V1/psid_ownhome.dta&type=file
*/
**AFTER DOWNLOADING THE TWO FILES ABOVE AND PLACING IN "replicate\data" FOLDER, UNCOMMENT THE FOLLOWING LINE TO REPLICATE APPENDIX TABLE A2
**do "programs\Table A2.do"
**********************************************************************************************************************************************
**********************************************************************************************************************************************

**ending date and time
di c(current_date)
di c(current_time)

cap log close

