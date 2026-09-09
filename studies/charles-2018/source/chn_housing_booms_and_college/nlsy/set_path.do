cap log close
set more off
clear all

*******************************************************************************
/* The purpose of this dofile is to define the path for data, dofiles, results, 
and everything else. When running the dofiles on any computer, only need to 
change the path in this dofile. Always run this dofile at beginning of session*/
*******************************************************************************

** Folder of the project **
global root = "E:\Matt Notowidigdo\Housing Booms and Education\"

global results = "$root\Results\"
global tables = "$results\Tables\"
global figures = "$results\Figures\"
global figures1979 = "$results\Figures\1979\"
global dofiles = "$root\Do Files\"
global indicatorfile = "$root\Housing Indicator\iv2_log_clean.dta"

* Data *

global datafolder = "Z:\"
global data79 = "$datafolder\NLSY79\"
global data97 = "$datafolder\NLSY97\"
global locationdata97 = "$data97\Location\"
global surveydata97 = "$data97\Survey and Created Variables\"

global cleaned = "$datafolder\Cleaned Data\"

* Public Data *

global publicdata = "$root\Public Data\"
