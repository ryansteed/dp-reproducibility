library(tidyverse)
library(rvest)
library(lubridate)
library(nycflights13)
library(xml2)
library(rvest)
library(readxl)
library(dplyr)
library(modelsummary)
library(fixest)

source("../data_cleaning/enrollment_cleaning/other_functions.R")

data_names <- c("../../data/source_data/ipeds/headcounts.csv",
                "../../data/source_data/ipeds/finance_all.csv"
)

# EFFYLEV	1	All students total
# EFFYLEV	2	Undergraduate
# EFFYLEV	4	Graduate
# LSTUDY	1	Undergraduate
# LSTUDY	3	Graduate
# LSTUDY	999	Generated total
agg_enrol <- read.csv(data_names[1]) %>% 
  filter(EFFYLEV==2) %>% 
  filter(LSTUDY==1) %>% 
  select(-c(EFFYLEV,LSTUDY))

fin <- read.csv(data_names[2])

df <- read_csv("../../data/clean_data/enroll_main.csv") %>%
  select(
    UNITID,STABBR,YEAR,FIPS,COUNTYCD,
    HLOFFER,CARNEGIE,
    
    adopt_store,adopt_MM_store,adopt_law,adopt_MM_law,
    ROTC,DIST,is_medical,is_large_inst,
    
    ln_EFTOTLT,ln_EFTOTLM,ln_EFTOTLW,EFTOTLT,
    ln_AGE1824_FEM_SHARE,ln_AGE1824_TOT,
    ln_unemply_rate,ln_per_capita_income,
    ln_NETMIG,ln_STUFACR,ln_RET_PCF
    
  ) %>% left_join(fin) %>% left_join(agg_enrol)


write_csv(df, "../../data/clean_data/welfare.csv")
