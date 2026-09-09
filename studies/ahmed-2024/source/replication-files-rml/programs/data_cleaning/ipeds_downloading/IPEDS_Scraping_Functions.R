library(rvest)
library(tidyverse)
library(plyr)
library(readxl)
library(haven)
library(Hmisc)
library(cpi)
library(Inflation)


## the following functions scrape the data from IPEDS survey
## data source:
## https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?gotoReportId=7&fromIpeds=true

      
## Directory information        
institution_characteristics <- function(){
  
              IPEDS_info1_dowld <- function(my_year){

                # https://nces.ed.gov/ipeds/datacenter/data/HD2008.zip
                zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/HD",my_year, ".zip")
                
                temp <- tempfile()
                download.file(zip_file1,temp)
                data <- read_csv(unz(temp, paste0("hd",my_year,".csv" )))
                unlink(temp) 
                
                names(data) <- toupper(names(data))
                
                return(data)
              }
              
              
              
              ## county fips is available starting from year 2009
              ## saving each file and keeping only interested variables
              Directory_information <- IPEDS_info1_dowld(2009) %>% select(UNITID,
                                                                          INSTNM,
                                                                          STABBR,
                                                                          CITY,
                                                                          ZIP,
                                                                          FIPS,
                                                                          CCBASIC, #Carnegie Classification 2005: Basic
                                                                          CCIPUG, #Carnegie Classification: Undergraduate Instructional Program
                                                                          CARNEGIE,
                                                                          
                                                                          PSEFLAG,  # Postsecondary institution indicator
                                                                          OBEREG,   # Bureau of Economic Analysis (BEA) regions
                                                                          UGOFFER,  # Undergraduate offering
                                                                          INSTSIZE, # Institution size category
                                                                          COUNTYCD,
                                                                          COUNTYNM,
                                                                          CYACTIVE, # Institution is active in current year
                                                                          ACT,      # Status of institution
                                                                          CONTROL,  # Control of institution (private or public)
                                                                          ICLEVEL,  # Level of institution
                                                                          MEDICAL,
                                                                          HOSPITAL,
                                                                          LOCALE,   # Degree of urbanization (Urban-centric locale)
                                                                          HBCU,     # Historically Black College or University
                                                                          TRIBAL,   # Tribal college
                                                                          HLOFFER,  # Highest level of offering
                                                                          LATITUDE,
                                                                          LONGITUD) 
              Directory_information$YEAR <- 2009
              
              ## download and bind the data
              for (j in 2010:2020) {
                print(j)
                Directory_information11 <- IPEDS_info1_dowld(j) 
                if(j<2015){
                 Directory_information1 <- Directory_information11 %>% select(UNITID,INSTNM,STABBR,CITY,ZIP,FIPS,PSEFLAG,OBEREG,CCBASIC,CARNEGIE, CCIPUG, ## carnegie reclassification
                                                                             UGOFFER,INSTSIZE,COUNTYCD,COUNTYNM,CYACTIVE,ACT,CONTROL,
                                                                             ICLEVEL,MEDICAL,HOSPITAL,LOCALE,HBCU,TRIBAL,HLOFFER,LATITUDE,LONGITUD)
                }else if(j > 2014 & j < 2018){
                  
                  Directory_information1 <- Directory_information11 %>% select(UNITID,INSTNM,STABBR,CITY,ZIP,FIPS,PSEFLAG,OBEREG,CCBASIC,CARNEGIE, C15IPUG,
                                                                               UGOFFER,INSTSIZE,COUNTYCD,COUNTYNM,CYACTIVE,ACT,CONTROL,
                                                                               ICLEVEL,MEDICAL,HOSPITAL,LOCALE,HBCU,TRIBAL,HLOFFER,LATITUDE,LONGITUD) %>% 
                                                                                dplyr::rename(  CCIPUG = C15IPUG )
                }else{
                  Directory_information1 <- Directory_information11 %>% select(UNITID,INSTNM,STABBR,CITY,ZIP,FIPS,PSEFLAG,OBEREG,CCBASIC,CARNEGIE, C18IPUG,
                                                                               UGOFFER,INSTSIZE,COUNTYCD,COUNTYNM,CYACTIVE,ACT,CONTROL,
                                                                               ICLEVEL,MEDICAL,HOSPITAL,LOCALE,HBCU,TRIBAL,HLOFFER,LATITUDE,LONGITUD) %>% 
                    dplyr::rename(  CCIPUG = C18IPUG )
                }
                
                
                
                
                
                
                Directory_information1$YEAR <- j
                
                Directory_information <- Directory_information %>% rbind(Directory_information1)
                

              }
              
              

              write_csv(Directory_information,"../../data/source_data/ipeds/df_inst_char.csv")
}

##Educational offerings, organization, admissions, services and athletic associations
institution_characteristics2 <- function(){
  
  IPEDS_info1_dowld <- function(my_year){
    
    # https://nces.ed.gov/ipeds/datacenter/data/IC2009.zip
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/IC",my_year, ".zip")
    
    temp <- tempfile()
    download.file(zip_file1,temp)
    data <- read_csv(unz(temp, paste0("ic",my_year,".csv" )))
    unlink(temp) 
    
    names(data) <- toupper(names(data))
    
    return(data)
  }
  
  
  ## county fips is available starting from year 2009
  ## saving each file and keeping only interested variables
  Directory_information <- IPEDS_info1_dowld(2008) %>% select(UNITID,
                                                              PEO1ISTR, # Occupational
                                                              PEO2ISTR, # Academic
                                                              SLO5,     # ROTC
                                                              SLO3,     # Distance learning opportunities
                                                              APPLFEEU, # Undergraduate application fee
                                                              ROOM,     # Institution provide on-campus housing
                                                              ROOMAMT,  # Typical room charge for academic year
                                                              BOARDAMT  # Typical board charge for academic year
                                                             
                                                              )
  Directory_information$YEAR <- 2008
  
  ## download and bind the data
  for (j in 2009:2020) {
    
    
    print(j)
    
   
    
    
    Directory_information11 <- IPEDS_info1_dowld(j) 
    
    if(j>2011){
      Directory_information11 <- Directory_information11 %>%   dplyr::rename(SLO3 = DSTNCED1)
    }
    
    Directory_information1 <- Directory_information11 %>% select(UNITID,
                                                                 PEO1ISTR,PEO2ISTR,
                                                                 ## SATPCT,ACTPCT, # Not availabe in 2015 ...
                                                                 SLO5, 
                                                                 SLO3,
                                                                 APPLFEEU,ROOM,
                                                                 ROOMAMT,BOARDAMT
                                                                 ## ENRLM,ENRLW,ENRLT # Not availabe in 2015 ...
                                                                 )
    Directory_information1$YEAR <- j
    
    Directory_information <- Directory_information %>% rbind(Directory_information1)
    
    
  }
  
  
  
  write_csv(Directory_information,"../../data/source_data/ipeds/df_inst_char2.csv")
}

# Student charges for academic year programs
institution_characteristics3 <- function(){
  
  IPEDS_info1_dowld <- function(my_year){
    
    # https://nces.ed.gov/ipeds/datacenter/data/IC2015_AY.zip
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/IC",my_year, "_AY.zip")
    
    temp <- tempfile()
    download.file(zip_file1,temp)
    data <- read_csv(unz(temp, paste0("ic",my_year,"_ay.csv" )))
    unlink(temp) 
    
    names(data) <- toupper(names(data))
    
    return(data)
  }
  
  
  ## county fips is available starting from year 2009
  ## saving each file and keeping only interested variables
  Directory_information <- IPEDS_info1_dowld(2008) %>% select(UNITID,
                                                              TUITION2, # In-state average tuition for full-time undergraduates
                                                              TUITION3, # out-state average tuition for full-time undergraduates
                                                              FEE2,     # In-state required fees for full-time undergraduates
                                                              FEE3,
                                                              CHG4AY3,  # Books and supplies 
                                                              CHG6AY3,  # On campus, other expenses 
                                                              CHG8AY3,  # Off campus (not with family), other expenses 
                                                              

  )
  Directory_information$YEAR <- 2008
  
  ## download and bind the data
  for (j in 2009:2020) {
    
    
    print(j)
    
    
    
    
    Directory_information11 <- IPEDS_info1_dowld(j) 
    
    # if(j>2011){
    #   Directory_information11 <- Directory_information11 %>%   dplyr::rename(SLO3 = DSTNCED1)
    # }
    
    Directory_information1 <- Directory_information11 %>% select(UNITID,
                                                                 TUITION2, # In-state average tuition for full-time undergraduates
                                                                 TUITION3, # out-state average tuition for full-time undergraduates
                                                                 FEE2,     # In-state required fees for full-time undergraduates
                                                                 FEE3,
                                                                 CHG4AY3,  # Books and supplies 
                                                                 CHG6AY3,  # On campus, other expenses 
                                                                 CHG8AY3,  # Off campus (not with family), other expenses 
                                                                 
    )
    Directory_information1$YEAR <- j
    
    Directory_information <- Directory_information %>% rbind(Directory_information1)
    
    
  }
  
  
  
  write_csv(Directory_information,"../../data/source_data/ipeds/df_inst_char3.csv")
}


###############################################################################
## Educational offerings, organization, applications, 
## admissions, enrollees, test scores, services and athletic associations
###############################################################################
#https://nces.ed.gov/ipeds/datacenter/data/IC2012.zip    ## these are file urls
#https://nces.ed.gov/ipeds/datacenter/data/ADM2014.zip
#https://nces.ed.gov/ipeds/datacenter/data/IC2013.zip
#https://nces.ed.gov/ipeds/datacenter/data/ADM2019.zip

admission <- function(){
  
          IPEDS_info2_dowld <- function(my_year){
            
            ## source:
            # https://stackoverflow.com/questions/3053833/using-r-to-download-zipped-data-file-extract-and-import-data
            if(my_year<2014){
              zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/IC",my_year, ".zip")
            } else{
              zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/ADM",my_year, ".zip")
            }
            
            temp <- tempfile()
            download.file(zip_file1,temp)
            if(my_year<2014){
              data <- read_csv(unz(temp, paste0("ic",my_year,".csv" )))
            } else {data <- read_csv(unz(temp, paste0("adm",my_year,".csv" )))}
            unlink(temp) 
            
            names(data) <- toupper(names(data))
            
            return(data)
          }
          
          ## saving each file and keeping only interested variables
          df <- IPEDS_info2_dowld(2009) %>% select(UNITID,
                                                   ADMCON1, # Secondary school GPA
                                                   ADMCON2, # Secondary school rank
                                                   ADMCON3, # Secondary school record
                                                   ADMCON4, # Completion of college-preparatory program
                                                   ADMCON7, # Admission test scores
                                                   APPLCN,
                                                   APPLCNM,
                                                   APPLCNW,
                                                   ADMSSN,
                                                   ADMSSNM,
                                                   ADMSSNW,
                                                   ENRLT,   # total first time enroll
                                                   ENRLFTM,
                                                   ENRLFTW,
                                                   ENRLPT,  # total firt time part time enroll
                                                   ENRLPTM,
                                                   ENRLPTW,
                                                   SATNUM,
                                                   SATPCT,
                                                   ACTNUM,
                                                   ACTPCT,
                                                   SATVR25,
                                                   SATVR75,
                                                   SATMT25,
                                                   SATMT75,
                                                   ACTCM25,
                                                   ACTCM75,
                                                   ACTEN25,
                                                   ACTEN75,
                                                   ACTMT25,
                                                   ACTMT75
          )                                     
          
          df$YEAR <- 2009
          
          
          ## download and bind the data
          for (j in 2010:2020) {
            print(j)
            
            df1 <- IPEDS_info2_dowld(j)  %>% select(UNITID,ADMCON1,ADMCON2,ADMCON3,ADMCON4,ADMCON7,
                                                    APPLCN,APPLCNM,APPLCNW,ADMSSN,ADMSSNM,ADMSSNW,
                                                    ENRLT,ENRLFTM, ENRLFTW,ENRLPT, ENRLPTM,ENRLPTW,
                                                    SATNUM,SATPCT,ACTNUM,ACTPCT,
                                                    SATVR25,SATVR75,SATMT25,SATMT75,
                                                    ACTCM25,ACTCM75,ACTEN25,ACTEN75,ACTMT25,
                                                    ACTMT75
            ) 
            
            df1$YEAR <- j
            
            df <- df %>% rbind(df1)
            
          }     
          
          df_adm_act <- df
          rm(df1,df)
          
          write_csv(df_adm_act,"../../data/source_data/ipeds/df_adm_act.csv")

}


#-------------------------------------------------------------------------
## 1 ## Race/ethnicity, gender, attendance status, and level of student
#-------------------------------------------------------------------------

fall_enroll_race <- function(){ 
     
  
  # https://nces.ed.gov/ipeds/datacenter/data/EF2006A.zip
  # https://nces.ed.gov/ipeds/datacenter/data/EF2014A.zip
  # https://nces.ed.gov/ipeds/datacenter/data/EF2019A.zip
  
          IPEDS_info3_dowld <- function(my_year){
            
            zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/EF",my_year, "A.zip")
            temp <- tempfile()
            download.file(zip_file1,temp)
            data <- read_csv(unz(temp, paste0("ef",my_year,"a.csv" )))
            unlink(temp) 
            names(data) <- toupper(names(data))
            return(data %>% data_frame())
          }
          
          ## saving each file and keeping only interested variables
          # df66 <- IPEDS_info3_dowld(2006) 
          # df66$EFNRALT <- df66$EFRACE01 + df66$EFRACE02
          # 
          # df77 <- IPEDS_info3_dowld(2007)
          # df77$EFNRALT <- df77$EFRACE01 + df77$EFRACE02
          # 
          # df66$YEAR <- 2006
          # df77$YEAR <- 2007
          # 
          # df <- df66 %>% rbind(df77) %>% rename(c("EFRACE16"="EFTOTLW","EFRACE18"="EFBKAAT","EFRACE15"="EFTOTLM", "EFRACE21" = "EFHISPT",
          #                                         "EFRACE19"="EFAIANT","EFRACE20"="EFASIAT","EFRACE22"="EFWHITT","EFRACE24"="EFTOTLT" ) ) %>% 
          #   select("UNITID","YEAR","EFALEVEL","LINE","SECTION","LSTUDY","EFTOTLT","EFTOTLM",
          #          "EFTOTLW","EFAIANT","EFASIAT","EFBKAAT","EFHISPT","EFWHITT","EFNRALT")
          
          df <- IPEDS_info3_dowld(2009) %>% select(UNITID,EFALEVEL,LINE,SECTION,LSTUDY,XEFTOTLT,XEFTOTLM,
                                                   XEFTOTLW,XEFAIANT,XEFASIAT,XEFBKAAT,XEFHISPT,XEFWHITT,XEFNRALT,
                                                   XEFAIANM,XEFAIANW,XEFASIAM,XEFASIAW,XEFBKAAM,XEFBKAAW,XEFHISPM,
                                                   XEFHISPW,XEFWHITM,XEFWHITW,
                                                   EFTOTLT,EFTOTLM,
                                                   EFTOTLW,EFAIANT,EFASIAT,EFBKAAT,EFHISPT,EFWHITT,EFNRALT,
                                                   EFAIANM,EFAIANW,EFASIAM,EFASIAW,EFBKAAM,EFBKAAW,EFHISPM,
                                                   EFHISPW,EFWHITM,EFWHITW)
            
          df$YEAR <- 2009
          
            # dplyr::rename(c(EFTOTLT=XEFTOTLT,EFTOTLM=XEFTOTLM, EFTOTLW = XEFTOTLW,
            #                 EFAIANT=XEFAIANT,EFASIAT=XEFASIAT,EFBKAAT=XEFBKAAT,
            #                 EFHISPT = XEFHISPT,EFWHITT=XEFWHITT,EFNRALT=XEFNRALT,
            #                 EFAIANM =XEFAIANM,EFAIANW = XEFAIANW,XEFASIAM = EFASIAM,
            #                 EFASIAW = XEFASIAW,EFBKAAM = XEFBKAAM, EFBKAAW = XEFBKAAW,
            #                 EFHISPM = XEFHISPM,EFHISPW = XEFHISPW,EFWHITM = XEFWHITM,EFWHITW = XEFWHITW) )
                                                                                          
          # for ( col in 1:ncol(df)){
          #   colnames(df)[col] <-  sub("X", "", colnames(df)[col]) %>% trimws()
          # }
          
          #print(colnames(df))
          
          ## download and bind the data
          for (j in 2010:2020) {
            print(j)
            
            df1 <- IPEDS_info3_dowld(j) %>% select(UNITID,EFALEVEL,LINE,SECTION,LSTUDY,XEFTOTLT,XEFTOTLM,
                                                   XEFTOTLW,XEFAIANT,XEFASIAT,XEFBKAAT,XEFHISPT,XEFWHITT,XEFNRALT,
                                                   XEFAIANM,XEFAIANW,XEFASIAM,XEFASIAW,XEFBKAAM,XEFBKAAW,XEFHISPM,
                                                   XEFHISPW,XEFWHITM,XEFWHITW,
                                                   EFTOTLT,EFTOTLM,
                                                   EFTOTLW,EFAIANT,EFASIAT,EFBKAAT,EFHISPT,EFWHITT,EFNRALT,
                                                   EFAIANM,EFAIANW,EFASIAM,EFASIAW,EFBKAAM,EFBKAAW,EFHISPM,
                                                   EFHISPW,EFWHITM,EFWHITW)
           # print(colnames(df1))
            
            df1$YEAR <- j
            
            df <- df %>% rbind(df1)
            
          }     
          
          df_enroll_fall_race <- df
          rm(df1,df)
          write_csv(df_enroll_fall_race,"../../data/source_data/ipeds/df_enroll_fall_race.csv")
}

#-------------------------------------------------------------------------
## Total entering class, retention rates, and student-to-faculty ratio
#-------------------------------------------------------------------------
# https://nces.ed.gov/ipeds/datacenter/data/EF2020D.zip
# https://nces.ed.gov/ipeds/datacenter/data/EF2015D.zip

quality_measures <- function(){ 
  
  IPEDS_info3_dowld <- function(my_year){
    
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/EF",my_year, "D.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    data <- read_csv(unz(temp, paste0("ef",my_year,"d_rv.csv" )))
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  IPEDS_info3_dowld_20 <- function(my_year){
    
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/EF",my_year, "D.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    data <- read_csv(unz(temp, paste0("ef",my_year,"d.csv" )))
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  df <- IPEDS_info3_dowld(2009) %>% select(UNITID,
                                           RET_PCF, # Full-time retention rate
                                           STUFACR, # Student-to-faculty ratio  # starts in 2009
                                           )
  
  df$YEAR <- 2009

  
  ## download and bind the data
  for (j in 2010:2020) {
    print(j)
    
    if(j==2020){
      df1 <- IPEDS_info3_dowld_20(j) %>% select(
                                                UNITID,
                                                RET_PCF, # Full-time retention rate
                                                STUFACR, # Student-to-faculty ratio
                                              )
    }else{
    df1 <- IPEDS_info3_dowld(j) %>% select(
                                            UNITID,
                                            RET_PCF, # Full-time retention rate
                                            STUFACR, # Student-to-faculty ratio
                                          )
    }
    
    df1$YEAR <- j
    
    df <- df %>% rbind(df1)
    
  }     
  
  df_enroll_fall_race <- df
  rm(df1,df)
  write_csv(df_enroll_fall_race,"../../data/source_data/ipeds/quality_measures.csv")
}


#-------------------------------------------------------------------------
## finance survey (public)
#-------------------------------------------------------------------------------------

finance_public_fasb <- function(){ 
  
  yrs <- c("0809","0910","1011","1112","1213","1314","1415","1516","1617","1718","1819", "1920")
  
  # https://nces.ed.gov/ipeds/datacenter/data/F1415_F2.zip
  # https://nces.ed.gov/ipeds/datacenter/data/F1920_F2.zip
  
  IPEDS_info3_dowld <- function(yrs){
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/F",yrs, "_F2.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    
    if(yrs=="1920"){
      data <- read_csv(unz(temp, paste0("f",yrs, "_f2.csv" )))
    }else{
      data <- read_csv(unz(temp, paste0("f",yrs, "_f2_rv.csv" )))
    }
    
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  
  df <- IPEDS_info3_dowld(yrs[1]) %>% select(UNITID,F2A19,F2A06,F2D01,F2D03,F2D04,F2E012)
  
  
  df$YEAR <- 2009
  
  
  
  ## download and bind the data
  ##2010:2019
  k1=2010
  for (j in yrs[2:length(yrs)] ) {
    print(j)
    
    df1 <- IPEDS_info3_dowld(j) %>% select(UNITID,F2A19,F2A06,F2D01,F2D03,F2D04,F2E012)
    # print(colnames(df1))
    
    df1$YEAR <- k1
    
    df <- df %>% rbind(df1)
    k1=k1+1
  }     
  
  
  write_csv(df,"../../data/source_data/ipeds/finance_fasb.csv")
}

finance_public_gasp <- function(){ 
  #my_year=2009
  yrs <- c("0809","0910","1011","1112","1213","1314","1415","1516","1617","1718","1819","1920")
  
  IPEDS_info3_dowld <- function(yrs){
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/F",yrs, "_F1A.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    
    if(yrs=="1920"){
      data <- read_csv(unz(temp, paste0("f",yrs, "_f1a.csv" )))
    }else{
      data <- read_csv(unz(temp, paste0("f",yrs, "_f1a_rv.csv" ))) # no revised data for 2020
    }
    
    
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  
  df <- IPEDS_info3_dowld(yrs[1]) %>% select(UNITID,F1A27T4,F1A18,F1B01,F1B11,F1B12,F1C012)
  
  
  df$YEAR <- 2009
  
  
  
  ## download and bind the data
  ##2010:2019
  k1=2010
  for (j in yrs[2:length(yrs)] ) {
    print(j)
    
    df1 <- IPEDS_info3_dowld(j) %>% select(UNITID,F1A27T4,F1A18,F1B01,F1B11,F1B12,F1C012)
    # print(colnames(df1))
    
    df1$YEAR <- k1
    
    df <- df %>% rbind(df1)
    k1=k1+1
  }     
  
  
  write_csv(df,"../../data/source_data/ipeds/finance_gasp.csv")
}

finance_private <- function(){ 
  
  yrs <- c("0809","0910","1011","1112","1213","1314","1415","1516","1617","1718","1819", "1920")
  
  #https://nces.ed.gov/ipeds/datacenter/data/F1920_F3.zip
  
  IPEDS_info3_dowld <- function(yrs){
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/F",yrs, "_F3.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    
    if(yrs=="1920"){
      data <- read_csv(unz(temp, paste0("f",yrs, "_f3.csv" )))
    }else{
      data <- read_csv(unz(temp, paste0("f",yrs, "_f3_rv.csv" )))
    }
    
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  #F3A01B,F3A01,F3A02,F3D01,F3D03A,F3D03C,F3E012
  
  df <- IPEDS_info3_dowld(yrs[1]) %>% select(UNITID,F3A01,F3A02,F3D01)
  
  
  df$YEAR <- 2009
  
  
  
  ## download and bind the data
  ##2010:2019
  k1=2010
  for (j in yrs[2:length(yrs)] ) {
    print(j)
    
    df1 <- IPEDS_info3_dowld(j) %>% select(UNITID,F3A01,F3A02,F3A01,F3A02,F3D01)
    # print(colnames(df1))
    
    df1$YEAR <- k1
    
    df <- df %>% rbind(df1)
    k1=k1+1
  }     
  
  
  write_csv(df,"../../data/source_data/ipeds/finance_private.csv")
}

finance_concat <- function(fasb,gasp){
  names(fasb)[2:7] <- c("PPE", "net_assets", "tuition_fees","state_appro","local_appro","instr_salaries_wages")
  names(gasp)[2:7] <- c("PPE", "net_assets", "tuition_fees","state_appro","local_appro","instr_salaries_wages")
  # private(private)[2] <- "PPE"
  # private(private)[2] <- "PPE"
  # private(private)[5:8] <- c("tuition_fees","state_appro","local_appro","instr_salaries_wages")
  
  fasb$fin_sample <- 1
  gasp$fin_sample <- 0
  #private$fin_sample <- 3
  
  #private$net_assets <- private$F3A01 %>% as.numeric() - private$F3A02 %>% as.numeric()
  
  #private <- private %>% select(colnames(fasb))
  
  finance_data <- fasb %>% rbind(gasp) 
  
  write_csv(finance_data,"../../data/source_data/ipeds/finance_public.csv")
  
}

finance_concat_all <- function(fasb,gasp,private){
  names(fasb)[2:7] <- c("PPE", "net_assets", "tuition_fees","state_appro","local_appro","instr_salaries_wages")
  names(gasp)[2:7] <- c("PPE", "net_assets", "tuition_fees","state_appro","local_appro","instr_salaries_wages")
  
  
  
  fasb$fin_sample <- 1
  gasp$fin_sample <- 2
  private$fin_sample <- 3
  
  private$net_assets <- private$F3A01 %>% as.numeric() - private$F3A02 %>% as.numeric()
  
  private <-  private %>% dplyr::rename(tuition_fees=F3D01)
  
  
  
  finance_data <- fasb %>% select(UNITID,YEAR,net_assets,tuition_fees,fin_sample) %>% 
    rbind(gasp %>% select(UNITID,YEAR,net_assets,tuition_fees,fin_sample) ) %>%
    rbind(private %>% select(UNITID,YEAR,net_assets,tuition_fees,fin_sample) )
  
  write_csv(finance_data,"../../data/source_data/ipeds/finance_all.csv")
  
}



#-------------------------------------------------------------------------
## Residence and migration of first-time freshman
#-------------------------------------------------------------------------------------
residence_first_enrol <- function(){ 
  
  # https://nces.ed.gov/ipeds/datacenter/data/EF2008C.zip
  # ef2008c_rv.csv
  
  yrs <- 2008:2019
  
  IPEDS_info3_dowld <- function(yrs){
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/EF",yrs, "C.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    data <- read_csv(unz(temp, paste0("ef",yrs, "c_rv.csv" )))
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  
  df <- IPEDS_info3_dowld(yrs[1]) %>% select(UNITID,EFCSTATE,LINE,EFRES01,EFRES02)
  
  
  df$YEAR <- 2008
  
  
  
  ## download and bind the data
  ##2010:2019
  k1=2009
  for (j in yrs[2:length(yrs)] ) {
    print(j)
    
    df1 <- IPEDS_info3_dowld(j) %>% select(UNITID,EFCSTATE,LINE,EFRES01,EFRES02)
    # print(colnames(df1))
    
    df1$YEAR <- k1
    
    df <- df %>% rbind(df1)
    k1=k1+1
  }     
  
  
  write_csv(df,"../../data/source_data/ipeds/resid_first_enrol.csv")
}


#-------------------------------------------------------------------------
## Major field of study, race/ethnicity, gender, attendance status, and level of student: Fall 
#-------------------------------------------------------------------------------------

enroll_majors <- function(){ 
  
  yrs <- seq(2008,2020,2)
  
  # https://nces.ed.gov/ipeds/datacenter/data/EF2016CP.zip
  # https://nces.ed.gov/ipeds/datacenter/data/EF2010CP.zip
  # ef2010cp_rv
  
  IPEDS_info3_dowld <- function(yrs){
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/EF",yrs, "CP.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    if(yrs==2020){
      data <- read_csv(unz(temp, paste0("ef",yrs, "cp.csv" )))  ## revised version is not available for 2020
    }else{
      data <- read_csv(unz(temp, paste0("ef",yrs, "cp_rv.csv" )))
    }
    
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  
  df <- IPEDS_info3_dowld(yrs[1]) %>% select(UNITID,EFCIPLEV,CIPCODE,LINE,
                                             SECTION,LSTUDY,EFTOTLT,EFTOTLM,
                                             EFTOTLW,EFASIAT,EFBKAAT,EFHISPT,EFWHITT)
  
  
  
  df$YEAR <- 2008
  
  
  
  ## download and bind the data
  ##2010:2019
  k1=2010
  for (j in yrs[2:length(yrs)] ) {
    print(j)
    
    df1 <- IPEDS_info3_dowld(j) %>% select(UNITID,EFCIPLEV,CIPCODE,LINE,
                                           SECTION,LSTUDY,EFTOTLT,EFTOTLM,
                                           EFTOTLW,EFASIAT,EFBKAAT,EFHISPT,EFWHITT)
    # print(colnames(df1))
    
    df1$YEAR <- k1
    
    df <- df %>% rbind(df1)
    k1=k1+2
  }     
  
  
  write_csv(df,"../../data/source_data/ipeds/enroll_majors.csv")
}



#-------------------------------------------------------------------------
## 12-month unduplicated headcount
#-------------------------------------------------------------------------
#https://nces.ed.gov/ipeds/datacenter/data/EFFY2015.zip
#effy2015_rv.csv



enrol_headcount <- function(){ 
  
  IPEDS_info3_dowld <- function(my_year){
    
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/EFFY",my_year, ".zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    data <- read_csv(unz(temp, paste0("effy",my_year,"_rv.csv" )))
    unlink(temp) 
    names(data) <- toupper(names(data))
    return(data %>% data_frame())
  }
  
  
  df <- IPEDS_info3_dowld(2009) %>% select(UNITID,EFFYLEV,LSTUDY,EFYTOTLT,EFYTOTLM,EFYTOTLW)
  
  df$YEAR <- 2009
  
  
  ## download and bind the data
  for (j in 2010:2020) {
    print(j)
    
    df1 <- IPEDS_info3_dowld(j) %>% select(UNITID,EFFYLEV,LSTUDY,EFYTOTLT,EFYTOTLM,EFYTOTLW)
    # print(colnames(df1))
    
    df1$YEAR <- j
    
    df <- df %>% rbind(df1)
    
  }     
  
  df_enroll_fall_race <- df
  rm(df1,df)
  write_csv(df_enroll_fall_race,"../../data/source_data/ipeds/headcounts.csv")
}


#-------------------------------------------------------------------------
## Awards/degrees conferred by program (6-digit CIP code), award level, race/ethnicity
#---------------------------------------------------------------------------------------
degree_completion <- function(){ 

  
  
  setwd(getwd())
  int1=TRUE
  yr_min=2008
  yr_max=2021
  
  ## download individual surveys
  for (yr in yr_min:yr_max) {
    # https://nces.ed.gov/ipeds/datacenter/data/C2013_A_Dict.zip
    #https://nces.ed.gov/ipeds/datacenter/data/C2013_A.zip
    ## get the dictionary data
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/C",yr, "_A_Dict.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    files1 <- unzip(temp, list = TRUE)$Name
    
    ## check if the dictionary is in the zip folder
    if(grepl(".csv",files1[1])){
      
      # find the Excel file inside the ZIP archive
      excel_file <- files1[grep(".xlsx$", files1)]
      
      # extract the path to the Excel file from the connection object
      excel_path <- unzip(temp, excel_file)
      
      # get the sheet names from the Excel file
      sheet_names <- excel_sheets(excel_path)
      
      # get the description of variables
      dict1 <- read_excel(excel_path, sheet = 1, col_names = FALSE)
      dict_var_label <- read_excel(excel_path, sheet = 2)[,c(2,7)]
      
    }
    
    ## get the ipeds data
    zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/C",yr, "_A.zip")
    temp <- tempfile()
    download.file(zip_file1,temp)
    
    ## the name of data files
    files <- unzip(temp, list = TRUE)$Name
    
    ## use reviewed version if available
    if (length(files)>1) {
      data_name <- files[2]
    }else{
      data_name <- files[1]
    }
    
    # extract the path to the Excel file from the connection object
    excel_path <- unzip(temp, data_name)
    
    # read in the data and assign labels from the codebook
    df <- read_csv(excel_path) %>% select(-starts_with("X"))
    var_names1 <- names(df)
    if(grepl(".csv",files1[1])){
      for (j in var_names1) {
        label(df[[j ]]) <- dict_var_label$varTitle[dict_var_label$varname== j]
      }
    } 
    
    # create a new folder in the current working directory
    if(int1){
      setwd(getwd())
      current_dir <- getwd()
      new_folder <- "ipeds_completion"
      dir.create(file.path(current_dir, new_folder))
      int1=FALSE
    }
    df$year <- yr
    names(df) = names(df) %>%  toupper()
    setwd(getwd())
    write_csv(df,paste0("ipeds_completion/compl","_",yr,".csv"))
    
    print(yr)
  }
  
  variables=list()
  for (k in yr_min:yr_max) {
    
    file_path2 <- paste0("ipeds_completion/compl","_",k,".csv")
    
    var_nm = read_csv(file_path2) %>% names 
    
    variables <- append(variables,list(nm=var_nm))
    
    names(variables)[names(variables)=="nm"] <- as.character(k)
    
    
  }
  
  # find the variable names that are identical in each list element
  common_vars <- Reduce(intersect, variables)
  
  ## bind all the yearly surveys with common variables
  int1=TRUE
  for (k in yr_min:yr_max) {
    setwd(getwd())
    file_path2 <- paste0("ipeds_completion/compl","_",k,".csv")
    
    if(int1){
      
      df <- read_csv(file_path2) %>% select(common_vars)
      
      int1=FALSE
    }else{
      
      df <- df %>% rbind(
        read_csv(file_path2) %>% select(common_vars)
      )
    }
    
    
    
  }
  
  setwd(getwd())
  zip_file1 <- paste0("https://nces.ed.gov/ipeds/datacenter/data/C",yr_max, "_A_Dict.zip")
  temp <- tempfile()
  download.file(zip_file1,temp)
  files <- unzip(temp, list = TRUE)$Name
  
  # find the Excel file inside the ZIP archive
  excel_file <- files[grep(".xlsx$", files)]
  
  # extract the path to the Excel file from the connection object
  excel_path <- unzip(temp, excel_file)
  
  # get the sheet names from the Excel file
  sheet_names <- excel_sheets(excel_path)
  
  # get the description of variables
  dict1 <- read_excel(excel_path, sheet = 1, col_names = FALSE)
  dict_var_label <- read_excel(excel_path, sheet = 2)[,c(2,7)]
  
  var_names1 <- names(df)[-length(names(df))]
  
  for (j in var_names1) {
    # print(j)
    df[[j ]] <- df[[j ]] %>% as.numeric()
    label(df[[j ]]) <- dict_var_label$varTitle[dict_var_label$varname== j]
  }
  
  
  
  #modelsummary::datasummary_skim(df)
  
  #   AWLEVEL	3	Associate's degree
  # AWLEVEL	5	Bachelor's degree
  #   AWLEVEL	7	Master's degree
  # AWLEVEL	17	Doctor's degree - research/scholarship
  #   AWLEVEL	18	Doctor's degree - professional practice
  # AWLEVEL	19	Doctor's degree - other
  
  
  # CIPCODE	A	7	Disc		CIP Code -  2010 Classification
  # MAJORNUM	N	1	Disc		First or Second Major
  # AWLEVEL	N	2	Disc		Award Level code
  
  
  library(dplyr)
  # restrict to undergraduate degrees
  # summing over all CIPCODE and MAJORNUM
  df2 <- df %>% filter(AWLEVEL %in% c(3,5) ) %>% 
    select(UNITID,AWLEVEL,YEAR,CTOTALM,CTOTALW) 


  df_agg <- aggregate(cbind(CTOTALM, CTOTALW) ~ UNITID + AWLEVEL + YEAR,
                      data = df2, FUN = sum, na.rm = TRUE)
  df_agg_all <- aggregate(cbind(CTOTALM, CTOTALW) ~ UNITID + YEAR,
                      data = df2, FUN = sum, na.rm = TRUE)
  
  
  df_agg$CTOTALT <- df_agg$CTOTALM+df_agg$CTOTALW
  df_agg_all$CTOTALT <- df_agg_all$CTOTALM+df_agg_all$CTOTALW
  
  df_agg_all$AWLEVEL <- "All undergraduate degrees"
  df_agg$AWLEVEL <- ifelse(df_agg$AWLEVEL==3,"Associate's degree","Bachelor's degree")
  
  comp_data=rbind(df_agg,df_agg_all)
  write_csv(comp_data,"../../data/source_data/ipeds/df_completion.csv")
  
  
}


