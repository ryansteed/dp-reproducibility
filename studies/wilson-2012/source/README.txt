2/14/2012

To recreate all of the tables and figures reported in "Fiscal Spending Jobs Mulitpliers: Evidence from the 2009 American Recovery and Reinvestment Act" by Daniel J. Wilson, forthcoming in American Economic Journal: Economic Policy:

1) Run Wilson_AEJEP_2012.do in STATA
2) Compile the tex file "documents/Results.tex" using a tex compiler (e.g., WinEdit) 


The following programs and ado files are included as they are called by Wilson_AEJEP_2012.do to produce some of the tables and figures :

FixSSA.ado
Program.3yrMAControls.do
Program.ExcludingDOL.do
Program.ARRASpending.doS
Program.ARRASpending.AlternativeHHSInstrument.do
Program.SpendingCategories.do
Program.StateGSPPerCapita.do
ExpectedPayrollEmployment.ado
GSPPerCapitaGeneralDate.ado

Datasets - The datasets are in the "../data" subdirectory.  They differ only in the time period over which the change in employment is calculated, with the exception that Master_Controls_and_Outcomes.dta does not include change in employment variables and is used to loop through different ending/starting dates

Master.Final.dta		- "Pre-treatment" period begins in February 2009
Master.Final.JanPre.dta		- "Pre-treatment" period begins in January 2009
Master.Final.DecPre.dta		- "Pre-treatment" period begins in December 2008
Master.Final.NovPre.dta		- "Pre-treatment" period begins in November 2008
Master_Controls_and_Outcomes.dta

The "../table definitions" directory contains formatting definitions for the tex document

"Wilson_AEJEP_2012.do" will put all of the tables and figures into a "../results" subdirectory and log files into a "../logs" subdirectory