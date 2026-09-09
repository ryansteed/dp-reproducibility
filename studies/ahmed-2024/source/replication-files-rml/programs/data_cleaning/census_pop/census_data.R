library(tidyverse)
library(RCurl)

setwd(normalizePath(dirname(rstudioapi::getSourceEditorContext()$path),winslash = "\\"))
#setwd("~/Desktop/marijuana_enrollment/programs/census_pop")

# source:
## https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/
########################################################################################

tm <- data_frame(
  period=2010:2019,
  YEAR=c(3:12)
)


## does the same as above but also binds data for each year
get_cencus <- function(census_url,agesex){
  for (i in 2:56) {
    
    file1 <-  paste0(
      census_url,
      sprintf("%02d", i),
      ".csv"
    )
    
    if(url.exists(file1)){
      df2 <- read_csv(file1) 
      agesex <- agesex %>% rbind(df2)
    }
    
  }
  
  return(agesex)
}

file1 <-  paste0(
  "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-agesex-",
  sprintf("%02d", 1),
  ".csv"
)

agesex <- read_csv(file1) 

url1 <- "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-agesex-"
agesex <- get_cencus(url1,agesex) %>%  
  filter(!YEAR %in% c(1,2)) %>% left_join(tm) %>% relocate(period,.after = YEAR)

file1 <-  paste0(
  "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-alldata-",
  sprintf("%02d", 1),
  ".csv"
)

alldata <- read_csv(file1) 

url2 <- "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-alldata-"
alldata <- get_cencus(url2,alldata) %>%  filter(!YEAR %in% c(1,2)) %>% left_join(tm) %>% relocate(period,.after = YEAR)

### 2000 to 2009 #############
## https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/asrh/

#agesex10 <- read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2000-2010/intercensal/county/co-est00int-agesex-5yr.csv")

tm <- data_frame(
  period=2000:2009,
  YEAR=c(3:12)
)

agesex00 <- read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/asrh/cc-est2009-agesex-01.csv")
url3 <- "https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/asrh/cc-est2009-agesex-"
agesex00 <- get_cencus(url3,agesex00) %>%  
  filter(!YEAR %in% c(1,2)) %>% left_join(tm) %>% relocate(period,.after = YEAR)


alldata00 <- read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/asrh/cc-est2009-alldata-01.csv")
url4 <- "https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/asrh/cc-est2009-alldata-"
alldata00 <- get_cencus(url4,alldata00) %>%  
  filter(!YEAR %in% c(1,2)) %>% left_join(tm) %>% relocate(period,.after = YEAR)


### combine all 2000 to 2019
agesex000 <- agesex00 %>% select(
                                COUNTY,STATE,period,
                              POPESTIMATE,POPEST_MALE,POPEST_FEM,
                              AGE1417_TOT,AGE1417_MALE,AGE1417_FEM,
                              AGE1824_TOT,AGE1824_MALE,AGE1824_FEM)
agesex001 <- agesex %>% select(
                              COUNTY,STATE,period,
                              POPESTIMATE,POPEST_MALE,POPEST_FEM,
                              AGE1417_TOT,AGE1417_MALE,AGE1417_FEM,
                              AGE1824_TOT,AGE1824_MALE,AGE1824_FEM)

agesex_df <- agesex000 %>% rbind(agesex001) %>% dplyr::rename(YEAR=period)
agesex_df$COUNTYCD <- paste0(agesex_df$STATE,agesex_df$COUNTY) %>% as.numeric


write_csv(agesex_df %>% select(-c(STATE,COUNTY)),"../../data/source_data/controls/pop/census_agesex.csv")



alldata000 <- alldata00 %>% select(
                                  COUNTY,STATE,period,
                                  AGEGRP,
                                  TOT_POP,TOT_MALE,TOT_FEMALE,
                                  WA_MALE,WA_FEMALE,
                                  BA_MALE,BA_FEMALE,IA_MALE,
                                IA_FEMALE,AA_MALE,AA_FEMALE,
                                H_MALE,H_FEMALE)

alldata001 <- alldata %>% select(
                                      COUNTY,STATE,period,
                                      AGEGRP,
                                      TOT_POP,TOT_MALE,TOT_FEMALE,
                                      WA_MALE,WA_FEMALE,
                                      BA_MALE,BA_FEMALE,IA_MALE,
                                      IA_FEMALE,AA_MALE,AA_FEMALE,
                                      H_MALE,H_FEMALE)

alldata_df <- alldata000 %>% rbind(alldata001) %>% dplyr::rename(YEAR=period) %>% 
                                      filter(AGEGRP == 4)   ## 4 = Age 15 to 19 years
alldata_df$COUNTYCD <- paste0(alldata_df$STATE,alldata_df$COUNTY) %>% as.numeric

########################
## net migration data

#2010 to 2019
mig1 <- read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv") %>% 
                gather(key = "key",value = "value",-c(1:7))
mig1$YEAR <- mig1$key %>% parse_number
mig1$key <- gsub('[0-9]+', '', mig1$key)
mig11 <- mig1 %>% spread(key,value)

#2000 to 2009
mig2 <- read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/totals/co-est2009-alldata.csv")%>% 
          gather(key = "key",value = "value",-c(1:7))
mig2$YEAR <- mig2$key %>% parse_number
mig2$key <- gsub('[0-9]+', '', mig2$key)
mig22 <- mig2 %>% spread(key,value)

migr_df <- mig11 %>% rbind(mig22) %>% 
                            select(
                            STATE,COUNTY,YEAR,
                            NETMIG,DEATHS,BIRTHS,POPESTIMATE,NPOPCHG_,INTERNATIONALMIG)

for (i in 4:ncol(migr_df)){ migr_df[[i]] <- migr_df[[i]] %>% as.numeric}

migr_df$COUNTYCD <- paste0(migr_df$STATE,migr_df$COUNTY) %>% as.numeric

write_csv(migr_df %>% select(-c(STATE,COUNTY)),"../../data/source_data/controls/pop/census_migration.csv")




