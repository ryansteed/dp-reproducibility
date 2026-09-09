##------------------------------------------------------------------------------
## Replication of "Disability Benefit Take-Up and Local Labor Market Conditions"
##------------------------------------------------------------------------------

To replicate the results in the paper, simply run the corresponding programs in the "code" folder. Note that the path of the working directory should be changed before running the programs.

Optional: To re-create the datasets used for final analysis, run "code/prepare_data.R", which cleans up and prepares the raw datasets in the "raw_data" folder, and puts the cleaned dataset into the "cleaned_data" folder.

##------------------------------------------------------------------------------
## Folder structure
##------------------------------------------------------------------------------

There are 4 folders in the replication bundle:

* raw_data: original data from which the final datasets are derived
* cleaned_data: final datasets for analysis
* code: code for data cleaning/preparation, and code to generate the figures and tables
* results: figures and tables in the paper

##------------------------------------------------------------------------------
## Folder content - raw_data
##------------------------------------------------------------------------------

* nation_year_raw.csv: national time series
* state_raw.csv: state time-invariant variables
* state_year_raw.csv: state time-variant variables
* county_raw.csv: county time-invariant variables
* county_year_raw.csv: county time-variant variables

* ipums.dat: IPUMS data
* ipums.do: accompanying Stata code of IPUMS data
* ipums.cbk: IPUMS data codebook

##------------------------------------------------------------------------------
## Folder content - cleaned_data
##------------------------------------------------------------------------------

* nation_year_cleaned.dta: national time series for analysis
* state_cleaned.dta: state time-invariant variables
* state_year_cleaned.dta: state time-variant variables
* county_year_cleaned.dta: time-variant variables
* map_data: GIS data for Figure 1

##------------------------------------------------------------------------------
## Folder content - code
##------------------------------------------------------------------------------

* prepare_data.R: turns the raw datasets into final datasets for analysis
* project_routines.do: project routine code that is cited by other Stata programs.

Other file names are self-explanatory.

##------------------------------------------------------------------------------
## Data description and sources
##------------------------------------------------------------------------------

# Data sources

* Regional Economic Information System (REIS)
    * County earnings, employment, SSI payment data
    * https://www.bea.gov/regional/downloadzip.cfm
        * Local Area Personal Income accounts
            * CA4: Personal Income and Employment by Major Component
            * CA35: Personal Current Transfer Receipts
* County Business Patterns (CBP)
    * Industry employment and establishment data
    * https://www.census.gov/programs-surveys/cbp/data/datasets.html
    * CBP data for 1970-1976 were obtained from UCLA's Institute for Social Science Research Data Archive through the kind help of Libbie Stephenson.
    * CBP Data for 1977-1996 and 1998-1999 was obtained from ICPSR with the remaining years being obtained from the U.S. Census Bureau.
    * CBP data for 1967 were obtained from the University of Wisconsin's Data and Information Services Center through the kind help of Cynthia Severt.
    * State-level CBP in 1967 is from CBP 1967 publication; replication of Appendix Table 2 Column 3 requires consulting this book: https://hdl.handle.net/2027/uc1.32106017493179
* SSDI payment data in Decembers 1970–2011 is kindly provided by Dan Black. We collected more recent county SSDI payments from SSA's "OASDI Beneficiaries by State and County" Report (various years). County-level SSDI payment data was not published in 1981.
* County-level coal reserves data is from Dan Black.
* 1990 MSA indicator is from Census: http://www.census.gov/population/estimates/metro-city/90mfips.txt
* IPUMS data
    * samples: 1970 Form 1 State, 1970 Form 2 State, 1990 5%, 2000 5%, 2008-2012, ACS 5-year
    * variables
        * year     "Census year"
        * perwt    "Person weight"
        * sex      "Sex"
        * age      "Age"
        * race     "Race [general version]"
        * raced    "Race [detailed version]"
        * educ     "Educational attainment [general version]"
        * educd    "Educational attainment [detailed version]"
        * occ1990  "Occupation, 1990 basis"
        * ind1990  "Industry, 1990 basis"
        * wkswork2 "Weeks worked last year, intervalled"

# Variable definitions and sources

fips - five digit state+county fips code (first 2 state, last three county)
       NOTE: fips codes are same as in REIS coding. There, they merge together
       some counties - most notably in Viriginia where many independent cities
       are merged with neighboring counties
year - calendar year
earn - REIS variable - total earnings
emp - REIS variable - total employment
manearn - REIS variable - manufacturing earnings
mineemp - REIS variable - mining employment
pop - REIS variable - total population
ssi - REIS variable - Supplemental Security Income payments
ssdisab - Black and Sanders - Social Security Disability payments only

ognumest - CBP variable - oil and gas number of establishments (in March)
ognumemp - CBP variable - oil and gas number of employees (in March)

Oil and Gas establishment size categories for 1974 and later:
ogestsz1 - CBP variable - # of oil and gas establishments with 1-4 employees
ogestsz2 - CBP variable - # of oil and gas establishments with 5-9 employees
ogestsz3 - CBP variable - # of oil and gas establishments with 10-19 employees
ogestsz4 - CBP variable - # of oil and gas establishments with 20-49 employees
ogestsz5 - CBP variable - # of oil and gas establishments with 50-99 employees
ogestsz6 - CBP variable - # of oil and gas establishments with 100-249 empls.
ogestsz7 - CBP variable - # of oil and gas establishments with 250-499 empls.
ogestsz8 - CBP variable - # of oil and gas establishments with 500-999 empls.
ogestsz9 - CBP variable - # of oil and gas establishments with 1000+ empls.
ogestsz10 - CBP variable - # of oil and gas estabs with 1000-1499 empls.
ogestsz11 - CBP variable - # of oil and gas estabs with 1500-2499 empls.
ogestsz12 - CBP variable - # of oil and gas estabs with 2500-4999 empls.
ogestsz13 - CBP variable - # of oil and gas estabs with 5000+ empls.

Oil and Gas establishment size categories for 1973 and earlier:
ogestsz1a - CBP variable - # of oil and gas establishments with 1-3 employees
ogestsz2a - CBP variable - # of oil and gas establishments with 4-7 employees
ogestsz3a - CBP variable - # of oil and gas establishments with 8-19 employees
ogestsz4 - CBP variable - # of oil and gas establishments with 20-49 employees
ogestsz5 - CBP variable - # of oil and gas establishments with 50-99 employees
ogestsz6 - CBP variable - # of oil and gas establishments with 100-249 empls.
ogestsz7 - CBP variable - # of oil and gas establishments with 250-499 empls.
ogestsz8_13 - CBP variable - # of oil and gas establishments with 500+ empls.

coalnumest - CBP variable - coal number of establishments (in March)
coalnumemp - CBP variable - coal number of employees (in March)

Coal establishment size categories for 1974 and later:
coalestsz1 - CBP variable - # of Coal establishments with 1-4 employees
coalestsz2 - CBP variable - # of Coal establishments with 5-9 employees
coalestsz3 - CBP variable - # of Coal establishments with 10-19 employees
coalestsz4 - CBP variable - # of Coal establishments with 20-49 employees
coalestsz5 - CBP variable - # of Coal establishments with 50-99 employees
coalestsz6 - CBP variable - # of Coal establishments with 100-249 empls.
coalestsz7 - CBP variable - # of Coal establishments with 250-499 empls.
coalestsz8 - CBP variable - # of Coal establishments with 500-999 empls.
coalestsz9 - CBP variable - # of Coal establishments with 1000+ empls.
coalestsz10 - CBP variable - # of Coal estabs with 1000-1499 empls.
coalestsz11 - CBP variable - # of Coal estabs with 1500-2499 empls.
coalestsz12 - CBP variable - # of Coal estabs with 2500-4999 empls.
coalestsz13 - CBP variable - # of Coal estabs with 5000+ empls.

Coal establishment size categories for 1973 and earlier:
coalestsz1a - CBP variable - # of Coal establishments with 1-3 employees
coalestsz2a - CBP variable - # of Coal establishments with 4-7 employees
coalestsz3a - CBP variable - # of Coal establishments with 8-19 employees
coalestsz4 - CBP variable - # of Coal establishments with 20-49 employees
coalestsz5 - CBP variable - # of Coal establishments with 50-99 employees
coalestsz6 - CBP variable - # of Coal establishments with 100-249 empls.
coalestsz7 - CBP variable - # of Coal establishments with 250-499 empls.
coalestsz8_13 - CBP variable - # of Coal establishments with 500+ empls.

minenumest - CBP variable - total number of mining establishments (in March)
minenumemp - CBP variable - total number of mining employees (in March)

cbpnumest - CBP variable - total number of establishments (in March)
cbpnumemp - CBP variable - total number of employees (in March)

Total establishment size categories for 1974 and later:
cbpestsz1 - CBP variable - # of Total establishments with 1-4 employees
cbpestsz2 - CBP variable - # of Total establishments with 5-9 employees
cbpestsz3 - CBP variable - # of Total establishments with 10-19 employees
cbpestsz4 - CBP variable - # of Total establishments with 20-49 employees
cbpestsz5 - CBP variable - # of Total establishments with 50-99 employees
cbpestsz6 - CBP variable - # of Total establishments with 100-249 empls.
cbpestsz7 - CBP variable - # of Total establishments with 250-499 empls.
cbpestsz8 - CBP variable - # of Total establishments with 500-999 empls.
cbpestsz9 - CBP variable - # of Total establishments with 1000+ empls.
cbpestsz10 - CBP variable - # of Total estabs with 1000-1499 empls.
cbpestsz11 - CBP variable - # of Total estabs with 1500-2499 empls.
cbpestsz12 - CBP variable - # of Total estabs with 2500-4999 empls.
cbpestsz13 - CBP variable - # of Total estabs with 5000+ empls.

Total establishment size categories for 1973 and earlier:
cbpestsz1a - CBP variable - # of Total establishments with 1-3 employees
cbpestsz2a - CBP variable - # of Total establishments with 4-7 employees
cbpestsz3a - CBP variable - # of Total establishments with 8-19 employees
cbpestsz4 - CBP variable - # of Total establishments with 20-49 employees
cbpestsz5 - CBP variable - # of Total establishments with 50-99 employees
cbpestsz6 - CBP variable - # of Total establishments with 100-249 empls.
cbpestsz7 - CBP variable - # of Total establishments with 250-499 empls.
cbpestsz8_13 - CBP variable - # of Total establishments with 500+ empls.

ognatlnumest - CBP variable - national oil and gas establishments
ognatlnumemp - CBP variable - national oil and gas employees

cbptotemp_est1967 - 1967 CBP - 1967 Total county employment - constructed from establishment size categories
cbpmineemp_est1967 - 1967 CBP - 1967 Total county mine employment - constructed from establishment size categories

cbptotestab1967 - 1967 CBP - 1967 Overall number of establishments
cbpogestab1967 - 1967 CBP - 1967 Oil and Gas establishments
cbpmineestab1967 - 1967 CBP - 1967 Total mining establishments

oilprice - nominal price of crude oil - [EIA: U.S. Crude Oil First Purchase Price](http://www.eia.gov/dnav/pet/hist/LeafHandler.ashx?n=pet&s=f000000__3&f=a)
gasprice - nominal price of natural gas - [EIA: Wellhead price per thousand cubic feet](http://www.eia.gov/dnav/ng/hist/n9190us3a.htm)
coalprice_ppi - PPI - Commodities - Coal - BLS, PPI program, Series ID: WPU051, Not Seasonally Adjusted, base year: 1982
cpi - Consumer Price Index - All Urban Consumers, base 1982--84 - [BLS](http://data.bls.gov/cgi-bin/surveymost?cu)

##------------------------------------------------------------------------------
## Software needed for replication
##------------------------------------------------------------------------------

The following system setup and software versions are used by the authors, other versions have not been tested.

* Operating system tested: macOS Sierra 10.12.4
* Stata 14
    * Stata packages: ivreg2, estout, ranktest
    * use `ssc install package_name` to install the packages
* R version 3.3.2 (2016-10-31)
    * tidyverse_1.1.1
    * data.table_1.10.4
    * cowplot_0.7.0
    * rgdal_1.2-7
    * lazyeval_0.2.0.9000
    * scales_0.4.1.9000
    * statar_0.6.4
    * magrittr_1.5
    * testthat_1.0.2.9000
    * readstata13_0.8.5
