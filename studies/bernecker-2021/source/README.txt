---
title: "README"
author: "Christina Gathmann"
date: "08 May 2020"
output: html_document
---
# Summary

This README file states how to replicate the results in Bernecker, Boyer and Gathmann (2020): which datasets have been used; how the data can be obtained; and what the computational requirements are.

Data Availability Statements
----------------------------

Bernecker, Boyer, and Gathmann (2020) combine data from multiple sources. The cleaned dataset (.dta file extension) used to support the findings of this study is provided with the STATA DO-file ("experiment_replication.do"), which reproduces the results of the paper. The name of the cleaned dataset is "experimentation_replicationdata". 

Moreover, in this section, a list of original datasets which were used to construct the cleaned dataset are shown and some links to datasets are also provided. A detailed description of how these datasets were used to create the file "experimentation_replicationdata.dta" is provided in Section II. of the article's Online Appendix.

The unmarried birth variable in particular is constructed by combining three different data sources (as explained in the online appendix of the paper). The three data sources are TANF Reports, NBER data and the CDC Vital Statistics (URLs for all of them provided on the online appendix as well). The constructed variable is included in the cleaned dataset provided in the repository of the article available at http://doi.org/10.3886/E115823V2. 


### Original Datasets

* Center for Disease Control and Prevention (CDC)
* [Datasets from Klarner Politics](https://www.klarnerpolitics.org/datasets-1) & Klarner(2013)
* [National Governor's Association](https://www.nga.org/) 
* [State Ideology Data from Richard C. Fording](http://rcfording.wordpress.com/state-ideology-data/)
* Statistical Abstract of the United States: 2012 (131st edition)
* TANF Annual Reports to Congress, I-VIII. Technical report
* [The Cook Political Report](https://cookpolitical.com/pvi-map-and-district-list)
* Vital Statistics
* [Welfare Rules Database](https://wrd.urban.org/wrd/Query/query.cfm) for data on welfare policy reforms
* Yearbook of Immigration Statistics
* Fang and Keane (2004)
* Holbrook and Van Dunk (1993)
* Leip (2012)
* List and Sturm (2006)
* March Current Population Survey (Center for Economic and Policy Research, 2012)
* State-level AFDC and TANF spending data from Paul Ehmann at the U.S. Census Bureau for welfare spending
* U.S. governors data provided by David J. Andersen from the Eagleton Institute of Politics at Rutgers University

### Intermediate files

In the data archive, we provide a set of intermediate do-files, which were used to generate the analysis data file from the raw data files. As the files have evolved over the years, these programs will likely not run as is.   

1. "mergeclean_data.do": prepares control variables 

2. "clean_data.do": do additional cleaning of political variables

3. "update_data.do": adds more years to dataset

4. "popneighbor_data.do": generate spillover variable (population neighbors)

5. "geographicneighbor_data.do": generate spillover variable (geographic neighbors)

6. "policyrules_data.do": define relevant welfare rules  

7. "experimentreversal_data.do": generates dependent variables on experimentation and reversals


Computational requirements
---------------------------

### Software Requirements
- Stata (code was last run with version 16)
  - binscatter 
  - estout
  - st0159_1
  - outreg2

### Memory and Runtime Requirements
The code was last run on a 4-core Intel-based desktop with Windows 10 version 1803 and with 8 GB RAM on November 27, 2019. 

Instructions
------------
1. Make sure you have "experimentation_replicationdata.dta" and "experiment_replication.do" files in order to reproduce the results from Bernecker, Boyer, and Gathmann (2019).
2. Open the "experiment_replication.do" file and set the path "data" to the directory where the dataset "experimentation_replicationdata.dta" is stored so that the DO-file can load the .dta file. Also, set the path "results" to the folder where you want to store the graphs and tables, which are generated from running the code. To do so, please adjust line 5 and 6 of the DO-file.
3. Run the DO-file. You will be able to replicate the results from Bernecker, Boyer, and Gathmann (2020), and obtain all graphs and tables in the paper. 