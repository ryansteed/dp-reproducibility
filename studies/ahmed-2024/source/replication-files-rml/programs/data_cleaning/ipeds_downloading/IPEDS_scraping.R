library(rvest)
library(tidyverse)
library(plyr)

source('../data_cleaning/ipeds_downloading/IPEDS_Scraping_Functions.R')
#-------------------------------------------------------------------------
## Intitutional Characteristics--offerings 
#-------------------------------------------------------------------------

institution_characteristics() 
institution_characteristics2()
institution_characteristics3()

###############################################################################
## admissions, enroll., test scores, services and athletic associations
###############################################################################
admission() 

 
#-------------------------------------------------------------------------
## 1 ## Race/ethnicity, gender, attendance status, and level of student
#-------------------------------------------------------------------------
fall_enroll_race()

 
 #-------------------------------------------------------------------------
 # finance data
 #-------------------------------------------------------------------------
 finance_public_gasp()
 finance_public_fasb()
 finance_private()
 
 fasb <- read_csv("../../../data/source_data/ipeds/finance_fasb.csv")
 gasp <- read_csv("../../../data/source_data/ipeds/finance_gasp.csv")
 private <- read_csv("../../../data/source_data/ipeds/finance_private.csv")
 finance_concat(fasb,gasp)
 finance_concat_all(fasb,gasp,private)
 
 #-------------------------------------------------------------------------
 ## Residence and migration of first-time freshman
 #-------------------------------------------------------------------------------------
 residence_first_enrol()

 #-------------------------------------------------------------------------
 ## Total entering class, retention rates, and student-to-faculty ratio
 #-------------------------------------------------------------------------
 quality_measures()
 
 #-------------------------------------------------------------------------
 ## 12-month unduplicated headcount
 #-------------------------------------------------------------------------
 enrol_headcount()
 
 #-------------------------------------------------------------------------
 ##  Awards/degrees conferred by program (6-digit CIP code), award level, race/ethnicity
 #-------------------------------------------------------------------------
 degree_completion()
 
 
 
 