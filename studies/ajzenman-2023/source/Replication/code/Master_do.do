clear all

** To run the code, the global 'pgdir' needs to be modified with the path to the "Replication" folder  
*** EDITED by Ryan
* passing in study path as variable
global pgdir "."
***
global code "$pgdir/code"
global rawdata "$pgdir/data/raw"
global intermed "$pgdir/data/intermediate"
global final "$pgdir/data/analysis"
global conf_rawdata "$pgdir/data/confidential"
global conf_intermed "$pgdir/data/conf_intermediate"
global conf_final "$pgdir/data/conf_analysis"
global Tables "$pgdir/results/tables"
global Graphs "$pgdir/results/figures"
global ado "$pgdir/ado"


*** Edited by Ryan: commented out all pre-processing, unused tables ***

********************************************************************************
***********                      0. Setup                         **************
********************************************************************************

****************** Install Stata Packages
* do "${code}/0_stata_setup/stata_setup.do"

* Bartik Weight instalation
* adopath ++ "$ado"



********************************************************************************
***********                       1. Data                         **************
********************************************************************************

* This do-file generates the ENUSC consolidated base
/* do "${code}/1_create/ENUSC.do" */

* This do-file generates the final base "TableI.dta". This base is used to replicate Table A.1 
*do "${code}/1_create/Data_Table_A1.do"

* This do-file generates the final base "enusc_OLS.dta". This base is used to replicate Tables A1, I, II, III, and IV, and Figure A6 (Panels a and c) 
*do "${code}/1_create/OLS_1.do"

* This do-file generates the final base "enusc_IV.dta". This base is used to replicate Tables V, VI, VII, VIII, A6 (Panel A.1-A.3), A7 (Columns 1-3), A.8, A.9, A.10 (Panel A) and A.11 (Columns 1 and 3)
/* do "${code}/1_create/IV_1.do" */

* This do-file generates the final base "pretrendsfinalbase.dta". This base is used to replicate Figures A2, A3 y A4
*do "${code}/1_create/Pretrends.do"

* This do-file generates the final base "IV_panel.dta". This base is used to replicate Table A4 (Panel B.1-B.3)
*do "${code}/1_create/IV_2.do"

* This do-file generates the final base "channels_OLS.dta". This base is used to replicate Tables XII (Columns 1-3), XII (Panel A, Columns 1-3) and XIII (Columns 1-3)
/* do "${code}/1_create/OLS_2.do" */

* This do-file generates the final base "channels_OLS2.dta". This base is used to replicate Table XII (Panel B, Columns 1-3) 
*do "${code}/1_create/OLS_3.do"

* This do-file generates the final base "channels_OLS3.dta". This base is used to replicate Table A16 (Columns 1-3) 
*do "${code}/1_create/OLS_4.do"

* This do-file generates the final base "enusc_IV_haiperven.dta". This base is used to replicate Tables A.10, A.11 and A.12 (Columns 1-7)
*do "${code}/1_create/IV_3.do"

* This do-file generates the final base "enusc_IV_share2002.dta". This base is used to replicate Tables A.13, A.14 and A.15 (Columns 1-7)
*do "${code}/1_create/IV_4.do"


****************** CONFIDENTIAL
* This do-file generates the final base "homicides_OLS.dta". This base is used to replicate Tables A1 (last row), V and A.2, and Figure A6 (Panel b)
*do "${code}/1_create/OLS_1_homicides.do"

* This do-file generates the final base "homicides_IV.dta". This base is used to replicate Tables X, A4 (Panel A.4), A5 (Column 4), A.3, A.8 (Panel B) and A.9 (Column 2)
*do "${code}/1_create/IV_1_homicides.do"

* This do-file generates the final base "pretrendsfinalbase_homicides.dta". This base is used to replicate Figure A5
*do "${code}/1_create/Pretrends_homicides.do"

* This do-file generates the final base "IV_panel_homicides.dta". This base is used to replicate Table A4 (Panel B.4)
*do "${code}/1_create/IV_2_homicides.do"

* This do-file generates the final base "channels_OLS_homicides.dta". This base is used to replicate Tables XI (Column 4), XII (Panel A, Column 4) and XIII (Column 4)
*do "${code}/1_create/OLS_2_homicides.do"

* This do-file generates the final base "channels_OLS2_homicides.dta". This base is used to replicate Table XII (Panel B, Column 4) 
*do "${code}/1_create/OLS_3_homicides.do"

* This do-file generates the final base "channels_OLS3_homicides.dta". This base is used to replicate Table A16 (Column 4) 
*do "${code}/1_create/OLS_4_homicides.do"

* This do-file generates the final base "homicides_IV_haiperven.dta". This base is used to replicate Table A.12 (Column 8)
*do "${code}/1_create/IV_3_homicides.do"

* This do-file generates the final base "homicides_IV_share2002.dta". This base is used to replicate Table A.15 (Column 8)
*do "${code}/1_create/IV_4_homicides.do"



********************************************************************************
***********                      2. Results                       **************
********************************************************************************

****************** Figures I and A1
*do "${code}/2_analysis/Figures_I_A1.do"

****************** Table A.1
*do "${code}/2_analysis/Table_A1.do"
*do "${code}/2_analysis/Table_A1_homicides.do"

****************** Tables I, II, III and IV
*do "${code}/2_analysis/Tables_I_II_III_IV.do"

****************** Tables V and A2
*do "${code}/2_analysis/Tables_V_A2.do"

****************** Tables VI, VII, VIII and IX
do "${code}/2_analysis/Tables_VI_VII_VIII_IX.do"

****************** Tables X and A3
*do "${code}/2_analysis/Tables_X_A3.do"

****************** Figures A2, A3 and A4
*do "${code}/2_analysis/Figures_A2_A3_A4.do"

****************** Figure A5
*do "${code}/2_analysis/Figure_A5.do"

****************** Table A4
*do "${code}/2_analysis/Table_A4.do"
*do "${code}/2_analysis/Table_A4_homicides.do"

****************** Table A5
*do "${code}/2_analysis/Table_A5.do"
*do "${code}/2_analysis/Table_A5_homicides.do"

****************** Table XI, XII, XIII and A16
do "${code}/2_analysis/Tables_XI_XII_XIII_A16.do"
*do "${code}/2_analysis/Tables_XI_XII_XIII_A16_homicides.do"

****************** Figure A6
*do "${code}/2_analysis/Figure_A6_a_c.do"
*do "${code}/2_analysis/Figure_A6_b.do"

****************** Tables A.6, A.7 and A.8
*do "${code}/2_analysis/Tables_A6_A7_A8PanelA.do"
*do "${code}/2_analysis/Table_A8PanelB.do"

****************** Table A.9
*do "${code}/2_analysis/Table_A9_Cols1and3.do"
*do "${code}/2_analysis/Table_A9_Col2.do"

****************** Tables A.10, A.11 and A.12
*do "${code}/2_analysis/Tables_A10_A11_A12.do"
*do "${code}/2_analysis/Table_A12_homicides.do"

****************** Tables A.13, A.14 and A.15
*do "${code}/2_analysis/Tables_A13_A14_A15.do"
*do "${code}/2_analysis/Table_A15_homicides.do"


