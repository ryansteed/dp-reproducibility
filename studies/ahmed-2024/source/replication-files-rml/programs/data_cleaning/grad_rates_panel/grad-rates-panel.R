library(tidyverse)
library(magrittr)
library(dplyr)
library(zoo)

# Setting directory to script location 
setwd(normalizePath(dirname(rstudioapi::getSourceEditorContext()$path),winslash = "\\"))

df <- read_csv("../../data/source_data/ipeds/grad-rate-raw.csv") %>% .[,-87] %>% 
      pivot_longer(cols = -c(1,2),names_to = "grad_rate_type",values_to = "grad_rate")

#df$grad_rate_type %>% unique %>% view

# Extract the last two digits of the year using regular expressions
df$years <- paste0("20",substr(df$grad_rate_type,nchar(df$grad_rate_type)-2,nchar(df$grad_rate_type)-1)) %>% as.numeric

# Convert the extracted years to numeric
df$years <- as.numeric(df$years) 

# Remove parentheses and text within them using regular expressions
df$grad_rate_type <- gsub("\\(.*?\\)", "", df$grad_rate_type) %>% trimws()
#df$grad_rate_type %>% unique %>% view

df$grad_rate_type <-  gsub("6-year Graduation rate -", "", df$grad_rate_type) %>% trimws()
df$grad_rate_type <-  gsub("4-year Graduation rate -", "", df$grad_rate_type) %>% trimws()
df$grad_rate_type <-  gsub("8-year Graduation rate -", "", df$grad_rate_type) %>% trimws()
df$grad_rate_type <-  gsub("Graduation rate -", "", df$grad_rate_type) %>% trimws()

#df$grad_rate_type %>% unique %>% view

df$grad_rate_type <-  gsub("bachelor's degree within 150% of normal time", "grad_rate_bachelor_6_years", df$grad_rate_type) %>% trimws()
df$grad_rate_type <-  gsub("bachelor's degree within 100% of normal time" , "grad_rate_bachelor_4_years", df$grad_rate_type) %>% trimws()
df$grad_rate_type <-  gsub("bachelor's degree within 200% of normal time", "grad_rate_bachelor_8_years", df$grad_rate_type) %>% trimws()

# note: 4 year for associate refers to 2 years, 6 for 3 years and 8 for 4 years
# using the same variable names for consistency
df$grad_rate_type <-  gsub("degree/certificate within 100% of normal time", "grad_rate_associate_4_years", df$grad_rate_type) %>% trimws()
df$grad_rate_type <-  gsub("degree/certificate within 150% of normal time", "grad_rate_associate_6_years", df$grad_rate_type) %>% trimws()
df$grad_rate_type <-  gsub("degree/certificate within 200% of normal time", "grad_rate_associate_8_years", df$grad_rate_type) %>% trimws()

#df$grad_rate_type %>% unique %>% view

df %>% names  

df %<>% select(UNITID=UnitID,inst_nm11=`Institution Name`,YEAR=years,grad_rate_type,grad_rate) %>% 
         pivot_wider(names_from = grad_rate_type, values_from = grad_rate) %>% 
          arrange(UNITID, YEAR)


# testing
enrol_data <- read_csv("../../data/clean_data/enroll_main.csv") %>% left_join(df)

modelsummary::datasummary_skim(enrol_data %>% select(names(df)[-c(1:2)]))


## after investigating the high missing values because 4-year colleges report only bachelor rates
## and associates are only reported by community colleges 

## bachelors graduation rate
modelsummary::datasummary_skim(enrol_data %>% 
                                 filter(HLOFFER>4) %>% 
                                 select(names(df)[-c(1:3)]))
## associates graduation rate
modelsummary::datasummary_skim(enrol_data %>% 
                                 filter(HLOFFER%in%3:4) %>% 
                                 select(names(df)[-c(1:3)]))



#=====
#=====
#=====


df <- df %>%
  arrange(UNITID, YEAR) %>%
  group_by(UNITID) %>% 
  mutate(grad_rate_associate_4_years_lead1 = dplyr::lead(grad_rate_associate_4_years,default = NA),
         grad_rate_associate_4_years_lead2 = dplyr::lead(grad_rate_associate_4_years,n=2,default = NA),
         grad_rate_associate_4_years_lead3 = dplyr::lead(grad_rate_associate_4_years,n=3,default = NA),
         grad_rate_associate_4_years_lead4 = dplyr::lead(grad_rate_associate_4_years,n=4,default = NA),
         grad_rate_associate_4_years_lead5 = dplyr::lead(grad_rate_associate_4_years,n=5,default = NA),
         grad_rate_associate_4_years_lead6 = dplyr::lead(grad_rate_associate_4_years,n=6,default = NA),
         
         grad_rate_associate_6_years_lead1 = dplyr::lead(grad_rate_associate_6_years,default = NA),
         grad_rate_associate_6_years_lead2 = dplyr::lead(grad_rate_associate_6_years,n=2,default = NA),
         grad_rate_associate_6_years_lead3 = dplyr::lead(grad_rate_associate_6_years,n=3,default = NA),
         grad_rate_associate_6_years_lead4 = dplyr::lead(grad_rate_associate_6_years,n=4,default = NA),
         grad_rate_associate_6_years_lead5 = dplyr::lead(grad_rate_associate_6_years,n=5,default = NA),
         grad_rate_associate_6_years_lead6 = dplyr::lead(grad_rate_associate_6_years,n=6,default = NA),
         
         grad_rate_associate_8_years_lead1 = dplyr::lead(grad_rate_associate_8_years,default = NA),
         grad_rate_associate_8_years_lead2 = dplyr::lead(grad_rate_associate_8_years,n=2,default = NA),
         grad_rate_associate_8_years_lead3 = dplyr::lead(grad_rate_associate_8_years,n=3,default = NA),
         grad_rate_associate_8_years_lead4 = dplyr::lead(grad_rate_associate_8_years,n=4,default = NA),
         grad_rate_associate_8_years_lead5 = dplyr::lead(grad_rate_associate_8_years,n=5,default = NA),
         grad_rate_associate_8_years_lead6 = dplyr::lead(grad_rate_associate_8_years,n=6,default = NA),
         
         #============
         
         grad_rate_bachelor_4_years_lead1 = dplyr::lead(grad_rate_bachelor_4_years,default = NA),
         grad_rate_bachelor_4_years_lead2 = dplyr::lead(grad_rate_bachelor_4_years,n=2,default = NA),
         grad_rate_bachelor_4_years_lead3 = dplyr::lead(grad_rate_bachelor_4_years,n=3,default = NA),
         grad_rate_bachelor_4_years_lead4 = dplyr::lead(grad_rate_bachelor_4_years,n=4,default = NA),
         grad_rate_bachelor_4_years_lead5 = dplyr::lead(grad_rate_bachelor_4_years,n=5,default = NA),
         grad_rate_bachelor_4_years_lead6 = dplyr::lead(grad_rate_bachelor_4_years,n=6,default = NA),
         
         grad_rate_bachelor_6_years_lead1 = dplyr::lead(grad_rate_bachelor_6_years,default = NA),
         grad_rate_bachelor_6_years_lead2 = dplyr::lead(grad_rate_bachelor_6_years,n=2,default = NA),
         grad_rate_bachelor_6_years_lead3 = dplyr::lead(grad_rate_bachelor_6_years,n=3,default = NA),
         grad_rate_bachelor_6_years_lead4 = dplyr::lead(grad_rate_bachelor_6_years,n=4,default = NA),
         grad_rate_bachelor_6_years_lead5 = dplyr::lead(grad_rate_bachelor_6_years,n=5,default = NA),
         grad_rate_bachelor_6_years_lead6 = dplyr::lead(grad_rate_bachelor_6_years,n=6,default = NA),
         
         grad_rate_bachelor_8_years_lead1 = dplyr::lead(grad_rate_bachelor_8_years,default = NA),
         grad_rate_bachelor_8_years_lead2 = dplyr::lead(grad_rate_bachelor_8_years,n=2,default = NA),
         grad_rate_bachelor_8_years_lead3 = dplyr::lead(grad_rate_bachelor_8_years,n=3,default = NA),
         grad_rate_bachelor_8_years_lead4 = dplyr::lead(grad_rate_bachelor_8_years,n=4,default = NA),
         grad_rate_bachelor_8_years_lead5 = dplyr::lead(grad_rate_bachelor_8_years,n=5,default = NA),
         grad_rate_bachelor_8_years_lead6 = dplyr::lead(grad_rate_bachelor_8_years,n=6,default = NA)
         
         
  ) %>%
  ungroup()

write_csv(df,"../../data/clean_data/grad_rates.csv")

