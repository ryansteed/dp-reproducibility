This document provides instructions for generating the results for “The distortionary effects of incentives in government: Evidence from China's “death ceiling” program.”
To do so, you must run the *.do file, deaths_aejfinal, on Stata version 13 or later. You must put all *.dta files in a folder, and enter its path into the 9th line of the do file (which currently reads, “cd "C:\Users\rfisman\Dropbox (CBS)\deathceailings"”. You must also change the line above to reflect your own username (currently it is set to rfisman).
Finally, before you run the do file, you must create a subfolder titled “tables” in the folder to collect the generated tables. 
The main death ceiling data file is data_aej.dta, while several ancillary files are loaded for some of the supplementary analyses:
1. Gdptarget provides province’s GDP targets
2. No Promotion provides the dates of passage and implementation of no safety, no promotion laws
3. Province_gdp provides province GDP data
4. provincedeath_imct_1993_2012_final provides data on deaths in manufacturing industries for 1993-2012
5. provinceid provides a common identifier to match across datasets.

Please see the paper’s text for details on variable definitions and construction
