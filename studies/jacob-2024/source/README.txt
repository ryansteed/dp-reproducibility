README 
School Board Elections Before, During, and After the COVID-19 Pandemic
Brian Jacob


*******************************
This package contains all the code and data used in Jacob (2024): School Board Elections Before, During, and After the COVID-19 Pandemic∗
All code and analyses should be attributed to Brian Jacob, with research assistance from Alvin Christian and Zack Halberstam. This code borrows heavily from the replication package from Baum & Jacob (2023): Racial Differences in Parent Response to COVID-19 Schooling Policies.  
You can contact the author at bajacob@umich.edu with any questions. 
*******************************


*******************************
Software Requirements 
*******************************
All analyses were conducted in Stata 18.0 SE. 
The master do-file 00_paper_shell.do recreates all analyses conducted in Stata. 
Make sure to input the relevant working directory. 

*******************************
Directions for Use
*******************************
This replication package contains processed data and code. For the creation of the processed datasets, refer to the replication package from Baum & Jacob (2023) (https://doi.org/10.1073/pnas.2307308120) which can be found at OPEN-ICPSR here: https://www.openicpsr.org/openicpsr/project/194722/version/V1/view

The code provided allows users to re-create all the tables and figures in the manuscript using nearly all variables used in the analyses.  

To re-run any analyses, refer to the scripts in the "Do" folder. 


*******************************
Data Availability
*******************************
With two exceptions, all data in the paper are publicly-available. 
When publicly-available, raw data can be accessed from the websites linked in Baum & Jacob (2023) (https://doi.org/10.1073/pnas.2307308120) or below.
All data should be cited appropriately as requested by the relevant institutions.

Data from the American Enterprise Institute and Fordham Institute were generously provided by researchers involved in the relevant projects. 
The raw datasets are not in the replication file but the analytic dataset contains the final cleaned variables.
Interested researchers should reach out to the following individuals:
-- AEI: Nat Malkus
-- Fordham: Amber Winkler, Janie Scull, Dara Zeehandelaar

All access links below are up-to-date as of 08/19/2024. 

*******************************
Datasets
*******************************

*******************************
Data from Baum & Jacob (2023)
*******************************

district_demo_ach_file_v3.dta
--This is an intermediary dataset created in Baum & Jacob (2023)
--It contains district characteristics using data from the CCD, SEDA, AEI, and the Fordham Institute.   
--Details on the creation of this file, along with all publicly-available necessary to replicate this file, is contained in replication package from Baum & Jacob (2023) (https://doi.org/10.1073/pnas.2307308120), which can be found at OPEN-ICPSR here: https://www.openicpsr.org/openicpsr/project/194722/version/V1/view


ccd_offtrend_all_distr.dta
--These data contain calculated district enrollment trends and deviations from trend for all school districts. 
--This data is created using the methods described in Baum and Jacob (2023) and documented in the replication package mentioned above. However, it uses a slightly different analytic sample from the Baum and Jacob (2023) paper so it is not included in the data set district_demo_ach_file_v3.dta. 


*******************************
Raw data from this paper
*******************************

Ballotpedia
--datasets:
----2018-2022 school board election results from the 100 largest cities as well as the top 200 districts by enrollment

State Trump Vote Share
-- datasets:
---- https://www.presidency.ucsb.edu/statistics/elections/2016

*******************************
Final analysis data
*******************************

SBE_base_data.dta
--This combines the above datasets and is used for the main analysis.

*******************************
Folder Structure and Code Description
*******************************
The folder structure is listed below. 

Raw data and processed data from Baum & Jacob (2023) are stored in the "Data" folder.
The final analytic dataset is found in the "Final analysis data" folder.
The output is generated in the "Output" folder. 

Do
-- 00_paper_shell.do: runs Stata code for entire paper 
---- 1_ballotpedia18-21.do: prepares ballotpedia data from 2018-21
---- 2_ballotpedia22.do: prepares ballotpedia data from 2022
---- 3_ballotpedia_combine.do: combines ballotpedia data
---- 4_sbe_base_v3.do: prepares base dataset for analysis
          *** The final analysis data SBE_base_data.dta is included in the package for convenience (see above). 
---- 5_analysis.do: main analysis file

Data (size in parentheses)

-- Ballotpedia (43MB)
-- ccd_offtrend_all_distr.dta (1,731KB)
-- district_demo_ach_file_v3.dta (15,333KB)
-- state_vote_share_trump_2016.dta (4KB)
