library(tidyverse)
library(dplyr)

# Setting directory to script location 
setwd(normalizePath(dirname(rstudioapi::getSourceEditorContext()$path),winslash = "\\"))


## Adding controls and policy dummies from enrollment data to completion data
enrol <- read_csv("../../data/clean_data/enroll_all.csv" )
compl <- read_csv("../../data/source_data/ipeds/df_completion.csv" ) %>% 
                    filter(YEAR>2008,UNITID %in% unique(enrol$UNITID) )

compl1 <- compl %>% left_join(enrol) %>% filter(!is.na(STABBR)  ) 


compl1$ln_CTOTALT <- log(1+compl1$CTOTALT)
compl1$ln_CTOTALW <- log(1+compl1$CTOTALW)
compl1$ln_CTOTALM <- log(1+compl1$CTOTALM)

# sort the data by grouping variables
compl1 <- arrange(compl1,AWLEVEL,FIPS,UNITID, YEAR)

# generate leads and lags
compl2 <- compl1 %>%
  arrange(AWLEVEL,FIPS,UNITID, YEAR) %>%
  group_by(AWLEVEL,FIPS,UNITID) %>%
  mutate(ln_CTOTALT_lead1 = dplyr::lead(ln_CTOTALT,default = NA),
         ln_CTOTALT_lead2 = dplyr::lead(ln_CTOTALT,n=2,default = NA),
         ln_CTOTALT_lead3 = dplyr::lead(ln_CTOTALT,n=3,default = NA),
         ln_CTOTALT_lead4 = dplyr::lead(ln_CTOTALT,n=4,default = NA),
         ln_CTOTALT_lead5 = dplyr::lead(ln_CTOTALT,n=5,default = NA),
         ln_CTOTALT_lead6 = dplyr::lead(ln_CTOTALT,n=6,default = NA)

         ) %>% ungroup()

write_csv(compl2,"../../data/clean_data/completion.csv" )

## check
# compl2 %>% select(
#                   AWLEVEL,FIPS,UNITID,YEAR,
#                   ln_CTOTALT_lead1,
#                   ln_CTOTALT_lead2,ln_CTOTALT_lead3,
#                   ln_CTOTALT_lead4,ln_CTOTALT_lead5,
#                   ln_CTOTALT_lead6
#                 ) %>%
#                   filter(AWLEVEL==unique(compl2$AWLEVEL)[3]) %>%
#                   arrange( AWLEVEL,FIPS,UNITID,YEAR) %>% view


