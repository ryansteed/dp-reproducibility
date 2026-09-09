*** This directory contains data and code that produces the cleaned datasets and replicates the full set tables and figures in the following paper:

Title:"Did Pandemic Unemployment Benefits Increase Unemployment? Evidence from Early State-Level Expirations"

Authors: Harry Holzer, Glenn Hubbard, and Michael R. Strain

Directory Structure:

	- The data are stored in .dta format in the folder: data
	- All code is provided in the folder: code
	- All graphs are placed into the folder: graphs
	- All tables are placed the folder: tables

Data Availability Statement:

This project uses Current Population Survey data from IPUMS, Covid cases and restrictions data from the Oxford Covid-19 Government Response Tracker (OxCGRT) and data from the Household Pulse Survey provided by the Census Bureau

All data is publically available.


Description of files in the data/raw folder:

- cps-data.dta: IPUMS CPS data microdata downloaded on August 16, 2022 from here: https://cps.ipums.org/cps/

- ipums-cps-variables-and-samples: This file contains a list of the variables and samples in the raw data file cps-data.dta. 

	- The "variables" tab has a list of the variables in the extract and the "samples" tab has a list of CPS basic monthly samples included in the extract. No other additional case restrictions were applied prior to download

	- To download the extract:

		1) To download extracts from ipums you first need to create and account with IPUMS. If you have already done this, you can log in to your account and skip to step 2

		2) From the main page at https://cps.ipums.org/cps/, click on "GET DATA".

		3) Select the variables from the "variables" tab of the ipums-variables-and-samples spreadsheet.
		
		4) Click on "CHANGE SAMPLES", click the "Basic Monthly" tab and then select the samples from the "samples" tab of the ipums-variables-and-samples spreadsheet.
	
		5) After selecting all variables and samples, click on "VIEW CART".

		6) Click "CREATE DATA EXTRACT".

		7) In "DATA FORMAT make sure .dta (Stata) is selected and click "SUBMIT EXTRACT".

		8) After the extract is downloaded, unzip the .dta file and rename it "cps-data.dta".




- FPUC_and_work_search_full: This spreadsheet contains raw data on the states that withdrew from FPUC and or PUA and the dates of withdrawal. 

	- Data for this spreadsheet and for Table A2 come from Congressional Research Service (2021) States Opting Out of COVID-19 Unemployment Insurance (UI) Agreements IN11679. Last updated August 20, 2021. 
	
	- URL: https://crsreports.congress.gov/product/pdf/IN/IN11679

	- A pdf version of the document is included in the raw data folder as: States Opting Out of Covid-19 Unemployment Insurance Aggrements CRS 2021.pdf 


- oxford-government-response-11-24-2021.xlsx: OxCGRT data downloaded on November 24, 2021 from here: https://github.com/OxCGRT/USA-covid-policy

	- The OxCGRT data was updated multiple times per day until June 2023.

	- The specific vintage of the data used for this project can be accessed here: https://github.com/OxCGRT/USA-covid-policy/tree/309317f79b7115a786ea3839d0715d096178f947


- state_fips_master: Crosswalk between state names, two-letter abbreviations and state fips codes. 

	- The data used in the crosswalk was adapted from the file here: https://github.com/kjhealy/fips-codes/blob/master/state_fips_master.csv

	- The District of Columbia was added with state FIPS code 11, Census region code 3, and Census division code 5.

- hps: This folder contains the Household Pulse Survey Public Use Files. 

Each CSV file contains the data for a corresponding survey round downloaded from here: https://www.census.gov/programs-surveys/household-pulse-survey/datasets.html

THe files can be downloaded by clicking on the links "HPS Week ## CSV" where ## is from 22 to 39. The files need to be unzipped and the file "pulse_puf_YYYY_##.csv" needs to be renamed "pulse_puf_##.csv" where ## is the week from 22 to 39


Description of files created in the data/proc folder:

- individual-analysis.dta: Individual-level dataset used to estimate regressions involving labor market transitions as the outcome.

- aggregate-snalysis.dta: State-level dataset used to estimate regressions incolving the employment-population ratio or the unemployment rate as the outcome.

- DD-and-DDD-placebos-individual.dta: Dataset of placebo regression estimates for unemployment to employment transitions.

- DD-and-DDD-placebos-aggregate.dta: Dataset of placebo regression estimates for state employment-population ratio and unemployment rate.

Note on OxCGRT data:

The OxCGRT data was updated multiple times per day until June 2023.

The specific vintage of the data used for this project can be accessed here: https://github.com/OxCGRT/USA-covid-policy/309317f79b7115a786ea3839d0715d096178f947

*** Software Requirements:

Stata 16.1

External Packages:
	- reghdfe version 6.12.2, 02Nov2021
	- ftools version 2.49.0, 06may2022
	- mplotoffset version 1.1.1, 14mar2015
	- grc1leg2 version 1.6, 15Jun2021
	- estout version 3.17, 02jun2014
	- egenmore last revised 24jan2019
	- erepost version 1.0.2, 15jun2015


*** Description of programs in the code folder

- 00-master.do: Creates needed directories and calls other programs below that generate results.

- 01-clean-individual-data.do: Creates the dataset: "proc/individual-analysis.dta"
 
- 02-clean-aggregate-data.do: Creates the dataset: "proc/aggregate-analysis.dta"

- 03-clean-hps-data.do: Creates the dataset "proc/hps-analysis.dta"

- 04-table-1-ue-transitions.do: Generates results in Table 1 for U-E transitions.

- 05-table-1-epop-ur.do: Generates results in Table 1 state EPOP and UR.

- 06-table-2.do: Generates results in Table 2.

- 07-table-3.do: Generates results in Table 3.

- 08-table-4.do: Generates results in Table 4.

- 09-figure-1.do: Generates Figure 1.

- 10-placebo-program-individual-data.do: Generates dataset of placebo estimates used to make Figures A1 and A2.

- 11-placebo-program-aggregate-data.do: Generates dataset of placebo estimates used to make Figures A3, A4, A5, and A6.

- 12-figures-A1-A2.do: Generates Figures A1 and A2.

- 13-figures-A3-A6.do: Generates Figures A3, A4, A5, and A6.

- 14-figure-A7.do: Generates Figure A7.

- 15-figures-A8-A9.do: Generates Figures A8 and A9.

- 16-counterfactual-analysis.do: Generates inputs used in counterfactual calculations in Table A1.




Memory and Runtime Requirements:

- The analysis was last run on a server with 120 gigabytes of RAM. The runtime was about 90 minutes. The code should run well on systems with 8 GB of RAM.


Instructions:

1) Open the 00-master.do file.

2) If needed install the dependencies reghdfe, ftools, grc1leg2, estout, and mplotoffset by uncommenting lines 21-27.

3) Change the line global path on line 23 to the directory on your computer where these files are located.
