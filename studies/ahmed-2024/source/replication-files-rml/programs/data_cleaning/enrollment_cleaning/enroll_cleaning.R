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

data_names <- c("../../data/source_data/ipeds/df_inst_char.csv",
                "../../data/source_data/ipeds/df_inst_char2.csv",
                "../../data/source_data/ipeds/df_inst_char3.csv",
                "../../data/source_data/ipeds/finance_all.csv",
                "../../data/source_data/ipeds/quality_measures.csv",
                "../../data/source_data/ipeds/df_adm_act.csv",
                "../../data/clean_data/directory_info_gis.csv"
)

chr1 <- read.csv(data_names[1])
chr2 <- read.csv(data_names[2])
chr3 <- read.csv(data_names[3])
fin <- read.csv(data_names[4])
qual <- read.csv(data_names[5])
adm <- read.csv(data_names[6]) 
gis <- read.csv(data_names[7]) 

# EFALEVEL	3	All students, Undergraduate, Degree/certificate-seeking total
# EFALEVEL	4	All students, Undergraduate, Degree/certificate-seeking, First-time
df <- read_csv("../../data/source_data/ipeds/df_enroll_fall_race.csv") %>% 
  select(UNITID,YEAR,EFALEVEL,LINE,SECTION,LSTUDY,EFTOTLT,EFTOTLM,EFTOTLW) %>% 
  left_join(chr1) %>% 
  left_join(chr2) %>% 
  left_join(chr3) %>% 
  left_join(fin) %>% 
  left_join(qual) %>% 
  left_join(adm) %>% 
  left_join(gis) %>% 
  academic_filtration %>%   ## excludes non-academic institutions.
  filter(YEAR > 2008 & YEAR < 2020 & ## county data available starting from 2009; 2020 not revised in IPEDS+COVID
           FIPS < 57 &  ## exclude territories
           FIPS != 15 & ## exclude Hawaii
           EFALEVEL == 4 & ## All students, Undergraduate, Degree/certificate-seeking, First-time
           PSEFLAG == 1 & ##Active postsecondary institution
           ICLEVEL != 3 & ## Less than 2 years (below associate)
           ACT == "A"& ## active institutions
           STABBR != "MI" & STABBR != "ME" & STABBR != "AK" ### MI opened the first store in 2019, last year of our data
  ) %>% 
  select(
    UNITID,YEAR,
    LATITUDE,LONGITUD,STABBR,CITY,FIPS,COUNTYCD,  ## geo.
    EFTOTLT,EFTOTLM,EFTOTLW, # first time enroll.
    
    distance_co,distance_wa,distance_wa_or,
    
    OBEREG, #Bureau of Economic Analysis (BEA) Regions
    LOCALE, #Degree of urbanization (Urban-centric locale)
    UGOFFER, #Undergraduate offering
    INSTSIZE, #Institution size category
    CONTROL, #private or public
    ICLEVEL, #Level of institution
    MEDICAL,
    HOSPITAL,
    HLOFFER,
    PEO1ISTR, #offers occup. 
    SLO5, #ROTC
    SLO3, #offers distance education
    CCBASIC, #Carnegie Classification : Basic
    CCIPUG, # Carnegie Classification : Undergraduate Instructional Program
    CARNEGIE,#Carnegie Classification 
    
    APPLFEEU, #Undergraduate application fee
    ROOM,#Institution provide on-campus housing 
    TUITION2,#In-state average tuition for full-time undergraduates
    TUITION3, #Out-of-state average tuition for full-time undergraduates
    FEE2, #Out-of-state required fees for full-time undergraduates
    FEE3, #In-state required fees for full-time undergraduates
    CHG4AY3, ##Books and supplies 
    CHG8AY3, ##Off campus (not with family), other expenses 
    
    net_assets,  ## total yearly amounts
    tuition_fees,
    fin_sample,
    
    RET_PCF, # Full-time retention rate
    STUFACR,  
    ADMCON7, 
    
    SATNUM, ## admission scores
    ACTNUM,
    SATPCT,
    ACTPCT,
    SATVR25,
    SATMT25,
    ACTCM25,
    ACTEN25,
    ACTMT25,
    SATVR75,
    SATMT75,
    ACTCM75,
    ACTEN75,
    ACTMT75
    
  ) 


df_vct <- read_csv("../../data/source_data/ipeds/df_enroll_fall_race.csv") %>% 
  select(UNITID,YEAR,EFALEVEL,LINE,SECTION,LSTUDY,EFTOTLT,EFTOTLM,EFTOTLW) %>% 
  filter(!UNITID %in% df$UNITID) %>% 
  left_join(chr1) %>% 
  left_join(chr2) %>% 
  left_join(chr3) %>% 
  left_join(fin) %>% 
  left_join(qual) %>% 
  left_join(adm) %>% 
  left_join(gis) %>% 
  #academic_filtration %>%   ## excludes non-academic institutions.
  filter(YEAR > 2008 & YEAR < 2020 & ## county data available starting from 2009; 2020 not revised in IPEDS+COVID
           FIPS < 57 &  ## exclude territories
           FIPS != 15 & ## exclude Hawaii
           # LINE == 1 & ## Full-time, first-time, first-year, degree-seeking undergraduates
           EFALEVEL == 4 & ## All students, Undergraduate, Degree/certificate-seeking, First-time
           PSEFLAG == 1 & ##Active postsecondary institution
           #ICLEVEL != 3 & ## Less than 2 years (below associate)
           ACT == "A"& ## active institutions
           STABBR != "MI" & STABBR != "ME" & STABBR != "AK" ### MI opened the first store in 2019, last year of our data
  ) %>% 
  select(
    UNITID,YEAR,
    LATITUDE,LONGITUD,STABBR,CITY,FIPS,COUNTYCD,  ## geo.
    EFTOTLT,EFTOTLM,EFTOTLW, # first time enroll.
    
    distance_co,distance_wa,distance_wa_or,
    
    OBEREG, #Bureau of Economic Analysis (BEA) Regions
    LOCALE, #Degree of urbanization (Urban-centric locale)
    UGOFFER, #Undergraduate offering
    INSTSIZE, #Institution size category
    CONTROL, #private or public
    ICLEVEL, #Level of institution
    MEDICAL,
    HOSPITAL,
    HLOFFER,
    PEO1ISTR, #offers occup. 
    SLO5, #ROTC
    SLO3, #offers distance education
    CCBASIC, #Carnegie Classification : Basic
    CCIPUG, # Carnegie Classification : Undergraduate Instructional Program
    CARNEGIE,#Carnegie Classification 
    
    APPLFEEU, #Undergraduate application fee
    ROOM,#Institution provide on-campus housing 
    TUITION2,#In-state average tuition for full-time undergraduates
    TUITION3, #Out-of-state average tuition for full-time undergraduates
    FEE2, #Out-of-state required fees for full-time undergraduates
    FEE3, #In-state required fees for full-time undergraduates
    CHG4AY3, ##Books and supplies 
    CHG8AY3, ##Off campus (not with family), other expenses 
    
    net_assets,  ## total yearly amounts
    tuition_fees,
    fin_sample,
    
    RET_PCF, # Full-time retention rate
    STUFACR,  # Student-to-faculty ratio
    ADMCON7, # requires Admission test scores *** (23 % missing) ****

    SATNUM, ## admission scores
    ACTNUM,
    SATPCT,
    ACTPCT,
    SATVR25,
    SATMT25,
    ACTCM25,
    ACTEN25,
    ACTMT25,
    SATVR75,
    SATMT75,
    ACTCM75,
    ACTEN75,
    ACTMT75
    
  ) 


enroll_data <- df 

for (i in 7:ncol(enroll_data)) {
  enroll_data[[i]] <- enroll_data[[i]] %>% as.numeric
}

score_col <- enroll_data %>% select(c(starts_with("SAT"),starts_with("ACT"))) %>% names

for (i in score_col) {
  #print(paste0(i," Before imputation"))
  
  enroll_data[[i]][
    !enroll_data[["ADMCON7"]] %in% c(1,2) & ## no score requirement
      is.na(enroll_data[[i]]) ## score missing
  ] <- 0
  
  # print(paste0(i," After imputation"))     
  # enroll_data[[i]] %>% summary %>% print
}

enroll_data <- enroll_data %>%  marij_legal_dummy() %>%  select(-ADMCON7) 

enroll_data$UNITID.f <- enroll_data$UNITID %>% as.factor
enroll_data$YEAR.f <- enroll_data$YEAR %>% as.factor
enroll_data$COUNTYCD.f <- enroll_data$COUNTYCD %>% as.factor

enroll_data$CCBASIC.f <- enroll_data$CCBASIC %>% as.factor
enroll_data$OBEREG.f <- enroll_data$OBEREG %>% as.factor
enroll_data$LOCALE.f <- enroll_data$LOCALE %>% as.factor
enroll_data$INSTSIZE.f <- enroll_data$INSTSIZE %>% as.factor
enroll_data$HOSPITAL.f <- enroll_data$HOSPITAL %>% as.factor
enroll_data$HLOFFER.f <- enroll_data$HLOFFER %>% as.factor
enroll_data$ROOM.f <- enroll_data$ROOM %>% as.factor
enroll_data$STATE.f <- enroll_data$FIPS %>% as.factor

enroll_data$ROTC <-  ifelse(enroll_data$SLO5 == 1,1,0) ## ROTC
enroll_data$DIST <-  ifelse(enroll_data$SLO3 == 1,1,0) ## distance

#---------------
### Census POP 
#---------------
enroll_data <- enroll_data %>% left_join(read_csv("../../data/source_data/controls/pop/census_agesex.csv"))

enroll_data <- enroll_data %>% left_join(read_csv("../../data/source_data/controls/pop/census_migration.csv"))

enroll_data$DEATHS <- enroll_data$DEATHS/100000
enroll_data$BIRTHS <- enroll_data$BIRTHS/100000

enroll_data$AGE1417_FEM_SHARE <- enroll_data$AGE1417_FEM/enroll_data$AGE1417_TOT
enroll_data$AGE1824_FEM_SHARE <- enroll_data$AGE1824_FEM/enroll_data$AGE1824_TOT

## add constant for Net migration for log transform
enroll_data$NETMIG <- enroll_data$NETMIG + abs(min(enroll_data$NETMIG,na.rm = T)-1)

enroll_data$INTERNATIONALMIG <- enroll_data$INTERNATIONALMIG + abs(min(enroll_data$INTERNATIONALMIG,na.rm = T)-1)
enroll_data$NPOPCHG_ <- enroll_data$NPOPCHG_ + abs(min(enroll_data$NPOPCHG_,na.rm = T)-1)
enroll_data$net_assets <- enroll_data$net_assets + abs(min(enroll_data$net_assets,na.rm = T)-1)

#-----------------
### BLS and BEA
#-----------------

bls_bea <- read_csv("../../data/source_data/controls/bls_bea_data.csv") %>% 
  dplyr::rename(YEAR=TimePeriod,COUNTYCD=GeoFips)

bls_bea$YEAR <- bls_bea$YEAR %>% as.numeric
bls_bea$COUNTYCD <- bls_bea$COUNTYCD %>% as.numeric

enroll_data <- enroll_data %>% left_join(bls_bea)
enroll_data$gdp_real12 <- enroll_data$gdp_real12/enroll_data$population

# DUMMIES 
add_dummies <- function(fin_df){
  fin_df$is_large_inst <- ifelse(fin_df$INSTSIZE %in% c(5) ,1,0) ## institutions with at least 20,000 aggregate enroll.
  fin_df$is_midsize_inst <- ifelse(fin_df$INSTSIZE %in% c(4) ,1,0) ## institutions with at least 10K to 20,000 aggregate enroll.
  fin_df$is_small_inst <- ifelse(fin_df$INSTSIZE %in% c(1,2) ,1,0) ## institutions with under 5k aggregate enroll.
  fin_df$is_medical <- ifelse(fin_df$MEDICAL %in% c(1) ,1,0) ## institutions with under 5k aggregate enroll.
  fin_df$is_city <- ifelse(fin_df$LOCALE %in% c(11:13) ,1,0)
  
  
  return(fin_df)
}
enroll_data <- enroll_data %>% add_dummies

log_list <- c("EFTOTLW", "EFTOTLM", "EFTOTLT",
              "per_capita_income", "unemply_rate",
              "AGE1824_TOT", "AGE1824_FEM_SHARE",
              "STUFACR","RET_PCF","NETMIG"
)

for (i in log_list) {
  
  enroll_data[[paste0("ln_",i)]] <- enroll_data[[i]] %>% as.numeric
  enroll_data[[paste0("ln_",i)]][enroll_data[[paste0("ln_",i)]]==0] <- 1
  enroll_data[[paste0("ln_",i)]] <- enroll_data[[paste0("ln_",i)]] %>% log
}

write_csv(enroll_data,"../../data/clean_data/enroll_robust_controls.csv")

df_main <- enroll_data %>% select(UNITID,STABBR,YEAR,FIPS,COUNTYCD,CONTROL,
                                  OBEREG,ICLEVEL,HLOFFER,MEDICAL,CCBASIC,CCIPUG,CARNEGIE,
                                  distance_co,distance_wa,distance_wa_or,
                                  adopt_store,adopt_MM_store,adopt_law,adopt_MM_law,
                                  ROTC,DIST,is_medical,is_midsize_inst,
                                  is_small_inst,is_large_inst,is_city,
                                  
                                  EFTOTLT,EFTOTLM,EFTOTLW,
                                  AGE1824_FEM_SHARE,AGE1824_TOT,
                                  unemply_rate,per_capita_income,
                                  NETMIG,STUFACR,RET_PCF,net_assets,
                                  
                                  ln_EFTOTLT,ln_EFTOTLM,ln_EFTOTLW,
                                  ln_AGE1824_FEM_SHARE,ln_AGE1824_TOT,
                                  ln_unemply_rate,ln_per_capita_income,
                                  ln_NETMIG,ln_STUFACR,ln_RET_PCF,
                                  LATITUDE,LONGITUD
                                  
                            
                                  
                                  )

write_csv(df_main, "../../data/clean_data/enroll_main.csv")

enroll_data <- df_vct 

for (i in 7:ncol(enroll_data)) {
  enroll_data[[i]] <- enroll_data[[i]] %>% as.numeric
}

score_col <- enroll_data %>% select(c(starts_with("SAT"),starts_with("ACT"))) %>% names

for (i in score_col) {
  #print(paste0(i," Before imputation"))
  
  enroll_data[[i]][
    !enroll_data[["ADMCON7"]] %in% c(1,2) & ## no score requirement
      is.na(enroll_data[[i]]) ## score missing
  ] <- 0
  
 # print(paste0(i," After imputation"))     
 # enroll_data[[i]] %>% summary %>% print
}

enroll_data <- enroll_data %>%  marij_legal_dummy() %>% select(-ADMCON7) 

enroll_data$UNITID.f <- enroll_data$UNITID %>% as.factor
enroll_data$YEAR.f <- enroll_data$YEAR %>% as.factor
enroll_data$COUNTYCD.f <- enroll_data$COUNTYCD %>% as.factor

enroll_data$CCBASIC.f <- enroll_data$CCBASIC %>% as.factor
enroll_data$OBEREG.f <- enroll_data$OBEREG %>% as.factor
enroll_data$LOCALE.f <- enroll_data$LOCALE %>% as.factor
enroll_data$INSTSIZE.f <- enroll_data$INSTSIZE %>% as.factor
enroll_data$HOSPITAL.f <- enroll_data$HOSPITAL %>% as.factor
enroll_data$HLOFFER.f <- enroll_data$HLOFFER %>% as.factor
enroll_data$ROOM.f <- enroll_data$ROOM %>% as.factor
enroll_data$STATE.f <- enroll_data$FIPS %>% as.factor

enroll_data$ROTC <-  ifelse(enroll_data$SLO5 == 1,1,0) ## ROTC
enroll_data$DIST <-  ifelse(enroll_data$SLO3 == 1,1,0) ## distance

st1 <- data_frame(STABBR=state.abb %>% toupper, STATENAME=state.name %>% toupper)

#----------------
### Census POP
#----------------
enroll_data <- enroll_data %>% left_join(read_csv("../../data/source_data/controls/pop/census_agesex.csv"))

enroll_data <- enroll_data %>% left_join(read_csv("../../data/source_data/controls/pop/census_migration.csv"))

enroll_data$DEATHS <- enroll_data$DEATHS/100000
enroll_data$BIRTHS <- enroll_data$BIRTHS/100000

enroll_data$AGE1417_FEM_SHARE <- enroll_data$AGE1417_FEM/enroll_data$AGE1417_TOT
enroll_data$AGE1824_FEM_SHARE <- enroll_data$AGE1824_FEM/enroll_data$AGE1824_TOT

## add constant for Net migration for log transform
enroll_data$NETMIG <- enroll_data$NETMIG + abs(min(enroll_data$NETMIG,na.rm = T)-1)

enroll_data$INTERNATIONALMIG <- enroll_data$INTERNATIONALMIG + abs(min(enroll_data$INTERNATIONALMIG,na.rm = T)-1)
enroll_data$NPOPCHG_ <- enroll_data$NPOPCHG_ + abs(min(enroll_data$NPOPCHG_,na.rm = T)-1)
enroll_data$net_assets <- enroll_data$net_assets + abs(min(enroll_data$net_assets,na.rm = T)-1)

#----------------
### BLS and BEA
#----------------
bls_bea <- read_csv("../../data/source_data/controls/bls_bea_data.csv") %>% 
  dplyr::rename(YEAR=TimePeriod,COUNTYCD=GeoFips)

bls_bea$YEAR <- bls_bea$YEAR %>% as.numeric
bls_bea$COUNTYCD <- bls_bea$COUNTYCD %>% as.numeric

enroll_data <- enroll_data %>% left_join(bls_bea)
enroll_data$gdp_real12 <- enroll_data$gdp_real12/enroll_data$population
enroll_data <- enroll_data %>% add_dummies

log_list <- c("EFTOTLW", "EFTOTLM", "EFTOTLT",
              "per_capita_income", "unemply_rate",
              "AGE1824_TOT", "AGE1824_FEM_SHARE",
              "STUFACR","RET_PCF","NETMIG"
)

for (i in log_list) {
  
  enroll_data[[paste0("ln_",i)]] <- enroll_data[[i]] %>% as.numeric
  enroll_data[[paste0("ln_",i)]][enroll_data[[paste0("ln_",i)]]==0] <- 1
  enroll_data[[paste0("ln_",i)]] <- enroll_data[[paste0("ln_",i)]] %>% log
}


df_vct2 <- enroll_data %>% select(UNITID,STABBR,YEAR,FIPS,COUNTYCD,CONTROL,
                                  OBEREG,ICLEVEL,HLOFFER,MEDICAL,CCBASIC,CCIPUG,CARNEGIE,
                                  distance_co,distance_wa,distance_wa_or,
                                  adopt_store,adopt_MM_store,adopt_law,adopt_MM_law,
                                  ROTC,DIST,is_medical,is_midsize_inst,
                                  is_small_inst,
                                  
                                  EFTOTLT,EFTOTLM,EFTOTLW,
                                  AGE1824_FEM_SHARE,AGE1824_TOT,
                                  unemply_rate,per_capita_income,
                                  NETMIG,STUFACR,RET_PCF,net_assets,
                                  
                                  ln_EFTOTLT,ln_EFTOTLM,ln_EFTOTLW,
                                  ln_AGE1824_FEM_SHARE,ln_AGE1824_TOT,
                                  ln_unemply_rate,ln_per_capita_income,
                                  ln_NETMIG,ln_STUFACR,ln_RET_PCF,
                                  
                                  
                                  is_large_inst,is_city)



write_csv(df_vct2, "../../data/clean_data/enroll_vocational.csv")

df_all <- rbind(df_main %>% select(names(df_vct2)),df_vct2)

write_csv(df_all,"../../data/clean_data/enroll_all.csv" )

#-----------------------------------------------------------------------------------------
## welfare sample
# fin <- read.csv(data_names[4])
# qual <- read.csv(data_names[5])


#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
## out of state enrollment sample
# academ_coll <- df_main$UNITID %>% unique ## academic colleges
# # out-of-state
# df_main$YEAR[df_main$YEAR==2009] <- 2008 ## use 2009 as a proxy for 2008 controls
# 
# resid1 <- read_csv("~/Desktop/marijuana_enrollment/data/source_data/ipeds/resid_first_enrol.csv") %>% 
#   filter(UNITID %in% academ_coll) %>% 
#   filter( YEAR %in% seq(2008,2018,2) ) %>%  ## the survey is run in even years only
#   left_join(df_main)  
# 
# write_csv(resid1, "~/Desktop/marijuana_enrollment/data/clean_data/enroll_resid.csv")

