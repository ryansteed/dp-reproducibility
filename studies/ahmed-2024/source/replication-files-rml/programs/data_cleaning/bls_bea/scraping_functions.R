library(rvest)
library(tidyverse)
library(plyr)
library(censusapi) 
library(bea.R)
library(readxl)


######################
## BEA & BLS DATA
######################

## source:
## https://jwrchoi.com/post/how-to-use-bureau-of-economic-analysis-bea-api-in-r/
## https://github.com/us-bea/bea.R

## get the table name from: https://apps.bea.gov/itable/index.cfm
## "CAINC1"

## cpi source: 
# https://www.minneapolisfed.org/about-us/monetary-policy/inflation-calculator/consumer-price-index-1913-


get_bls_bea_data <- function(){

  readRenviron("~/.Renviron")
  BEA_KEY= Sys.getenv("BEA_KEY")
  
  ## finding the lineCodes
  # Retrieve linecodes as dataframe
  linecode <- beaParamVals(beaKey = BEA_KEY, "Regional", "LineCode")$ParamValue
  
  # Inspect the dataset
  # glimpse(linecode)
  
  # The table names are available in the first parts of the "Desc" column
  # Filter using str_detect() and identify the linecodes
  # linecode %>% filter(str_detect(Desc, "CAINC1"))
  # linecode %>% filter(str_detect(Desc, "CAGDP1"))
  
  gdp_real <- list(
    "UserID" = BEA_KEY, # Set up API key
    "Method" = "GetData", # Method
    "datasetname" = "Regional", # Specify dataset
    "TableName" = "CAGDP1", # Specify table within the dataset
    "LineCode" = 1, # Specify the line code
    "GeoFips" = "COUNTY", # Specify the geographical level
    "Year" = "2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020" # Specify the year
  )
  gdp_real0 <- beaGet(gdp_real, asWide = FALSE) 
  
  gdp_real12_df <- gdp_real0 %>% 
                      select(GeoFips, TimePeriod, DataValue, GeoName) %>% 
                      mutate(GeoName = gsub(",.*$", "", GeoName)) %>% 
                      dplyr::rename(gdp_real12 = DataValue,
                                    county = GeoName)
 
  per_capita_income <- list(
                        "UserID" = BEA_KEY, # Set up API key
                        "Method" = "GetData", # Method
                        "datasetname" = "Regional", # Specify dataset
                        "TableName" = "CAINC1", # Specify table within the dataset
                        "LineCode" = 3, # Specify the line code
                        "GeoFips" = "COUNTY", # Specify the geographical level
                        "Year" = "2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020" # Specify the year
                      )
  
  per_capita_income_df0 <- beaGet(per_capita_income, asWide = FALSE) 
  
  per_capita_income_df <- per_capita_income_df0 %>% 
                            select(GeoFips, TimePeriod, DataValue, GeoName) %>% 
                            mutate(GeoName = gsub(",.*$", "", GeoName)) %>% 
                            dplyr::rename(per_capita_income = DataValue,
                                          county = GeoName)
  
  
  personal_income <- list(
                        "UserID" = BEA_KEY, # Set up API key
                        "Method" = "GetData", # Method
                        "datasetname" = "Regional", # Specify dataset
                        "TableName" = "CAINC1", # Specify table within the dataset
                        "LineCode" = 1, # Specify the line code
                        "GeoFips" = "COUNTY", # Specify the geographical level
                        "Year" = "2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020" # Specify the year
                      )
  personal_income_df0 <- beaGet(personal_income, asWide = FALSE)
  personal_income_df <- personal_income_df0 %>% 
                            select(GeoFips, TimePeriod, DataValue, GeoName) %>% 
                            mutate(GeoName = gsub(",.*$", "", GeoName)) %>% 
                            dplyr::rename(personal_income = DataValue,
                                          county = GeoName)
 
  population <- list(
                    "UserID" = BEA_KEY, # Set up API key
                    "Method" = "GetData", # Method
                    "datasetname" = "Regional", # Specify dataset
                    "TableName" = "CAINC1", # Specify table within the dataset
                    "LineCode" = 2, # Specify the line code
                    "GeoFips" = "COUNTY", # Specify the geographical level
                    "Year" = "2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020" # Specify the year
                  )
  
  population_df0 <- beaGet(population, asWide = FALSE)
  
  population_df <- population_df0 %>% 
                      select(GeoFips, TimePeriod, DataValue, GeoName) %>% 
                      mutate(GeoName = gsub(",.*$", "", GeoName)) %>% 
                      dplyr::rename(population = DataValue,
                                    county = GeoName)
  
  rm(population_df0,personal_income_df0,per_capita_income_df0,
     linecode,gdp_real0)
  
  ## joining the data
  df <- per_capita_income_df %>% left_join(personal_income_df[,-4],by=c("GeoFips","TimePeriod")) %>% 
         left_join(population_df[,-4],by=c("GeoFips","TimePeriod")) %>% left_join(gdp_real12_df[,-4],by=c("GeoFips","TimePeriod"))
  
  ######################
  ## BLS DATA
  ######################
  ## data source: https://www.bls.gov/lau/tables.htm#cntyaa
  #https://web.archive.org/web/20190831005817/https://www.bls.gov/lau/laucnty18.xlsx
  
  var_names <- c("LAUS_Code","state_fips","county_fips","county","TimePeriod",
                 "labor_force","num_employed","num_unemployed","unemply_rate")
  
  temp = tempfile(fileext = ".xlsx")
  dataURL <- paste0("https://web.archive.org/web/20190831005817/https://www.bls.gov/lau/laucnty0",1,".xlsx")
  download.file(dataURL, destfile=temp, mode='wb')
  bls <- read_excel(temp, sheet =1,skip = 4) %>% select(-c("...6" ))
  colnames(bls) <- var_names
  
  for (j in 2:9) {
    temp = tempfile(fileext = ".xlsx")
    dataURL <- paste0("https://web.archive.org/web/20190831005817/https://www.bls.gov/lau/laucnty0",j,".xlsx")
    download.file(dataURL, destfile=temp, mode='wb')
    bls2 <- read_excel(temp, sheet =1,skip = 4) %>% select(-c("...6" ))
    colnames(bls2) <- var_names
    
    bls <- bls %>% rbind(bls2)
  }
  
  for (j in 10:20) {
    temp = tempfile(fileext = ".xlsx")
    dataURL <- paste0("https://web.archive.org/web/20190831005817/https://www.bls.gov/lau/laucnty",j,".xlsx")
    download.file(dataURL, destfile=temp, mode='wb')
    bls2 <- read_excel(temp, sheet =1,skip = 4) %>% select(-c("...6" ))
    colnames(bls2) <- var_names
    
    bls <- bls %>% rbind(bls2)
  }
  
  rm(bls2,personal_income_df,per_capita_income_df,population_df,gdp_real12_df)
  
  ##############################
  ## Merging BLS and BEA data
  ##############################
  
  ## combine state and coty fips for bls data
  bls$GeoFips <- paste0(bls$state_fips,bls$county_fips)
  
  bls <- bls %>% select(GeoFips,TimePeriod,labor_force,num_employed,num_unemployed,unemply_rate)
  df_all <- df %>% left_join(bls)
  df_all$TimePeriod <- df_all$TimePeriod %>% as.numeric()
  
  ############################
  ## nominal to real using cpi
  ############################
  
  # https://www.minneapolisfed.org/about-us/monetary-policy/inflation-calculator/consumer-price-index-1913-
  cpi_data <-  read_csv("../../data/source_data/others/cpi_data.csv")[-1,]

  cpi_data$cpi <-  cpi_data$cpi %>% as.numeric()

  # 2020 cpi
  CPI_12 <- cpi_data$cpi[cpi_data$TimePeriod==2012]

  # left join the data
  df_all <- left_join(df_all,cpi_data)

  df_all$per_capita_income <- df_all$per_capita_income/df_all$cpi * CPI_12[1]
  df_all$personal_income <- df_all$personal_income/df_all$cpi * CPI_12[1]


  df_all <- df_all %>% select(-c(cpi,`Annual Percent Change`))
  
  
  write_csv(df_all,"../../data/source_data/controls/bls_bea_data.csv")
  
}


get_bls_bea_data()


