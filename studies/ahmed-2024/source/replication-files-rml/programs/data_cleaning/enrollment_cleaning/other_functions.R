# this function adds the dummy variable to a given data frame, enroll_data
# n: treshold for short term after the legalization of marijuana 
# set n to 2 because most states open the first dispensery after 2 years of legalization
# terms_dummy <- function(enroll_data,n){
#   
#   enroll_data$adopt_law_st <- ifelse( ((enroll_data$STABBR=="CO" & enroll_data$YEAR >= 2012 & enroll_data$YEAR <= 2012+n)  |
#                                          (enroll_data$STABBR=="WA" & enroll_data$YEAR >= 2012 & enroll_data$YEAR <= 2012+n)|
#                                          (enroll_data$STABBR=="OR" & enroll_data$YEAR >= 2015 & enroll_data$YEAR <= 2015+n) |
#                                          (enroll_data$STABBR=="MA" & enroll_data$YEAR >= 2016 & enroll_data$YEAR <= 2016+n) |
#                                          (enroll_data$STABBR=="CA" & enroll_data$YEAR >= 2016 & enroll_data$YEAR <= 2016+n) |
#                                          (enroll_data$STABBR=="NV" & enroll_data$YEAR >= 2017 & enroll_data$YEAR <= 2017+n)
#   )
#   ,1,0)
#   
#   enroll_data$adopt_law_lt <- ifelse( ((enroll_data$STABBR=="CO" &  enroll_data$YEAR > 2012+n)  |
#                                          (enroll_data$STABBR=="WA" &  enroll_data$YEAR > 2012+n) |
#                                          (enroll_data$STABBR=="OR" &  enroll_data$YEAR > 2015+n) |
#                                          (enroll_data$STABBR=="MA" &  enroll_data$YEAR > 2016+n) |
#                                          (enroll_data$STABBR=="CA" &  enroll_data$YEAR > 2016+n) |
#                                          (enroll_data$STABBR=="NV" &  enroll_data$YEAR > 2017+n)
#   )
#   ,1,0)
#   
#   return(enroll_data)
# }

marij_legal_dummy <- function(Enroll_char_adm1){
  
  # source: https://www.carnevaleassociates.com/our-work/status-of-state-marijuana-legalization.html
  medical_info <- read_csv("../../data/source_data/others/medical_marij/medical.csv",col_names=F)
  medical_info$med_year <- medical_info$X1 %>% parse_number()
  medical_info$state_name <- medical_info$X1 %>% substr(.,1, str_count(medical_info$X1)-6) %>% toupper() %>% trimws()
  
  ## state name and abbrev tibble
  state_info <- tibble(state_name = state.name %>% toupper, STABBR = state.abb)
  
  ## tibble containing medical legalization data
  medical_info <- medical_info %>% left_join(state_info) %>% select(-c(state_name, X1))
  medical_info$STABBR[length(medical_info$STABBR)] <- "DC"
  
  ## correction
  ## correction
  medical_info$med_year[medical_info$STABBR=="OK"] <- 2018

  

  
  Enroll_char_adm1$adopt_store <- ifelse( ((Enroll_char_adm1$STABBR=="CO" & Enroll_char_adm1$YEAR >=2014)  |
                                             (Enroll_char_adm1$STABBR=="WA" & Enroll_char_adm1$YEAR >= 2014)|
                                             (Enroll_char_adm1$STABBR=="AK" & Enroll_char_adm1$YEAR >= 2016) |
                                             (Enroll_char_adm1$STABBR=="OR" & Enroll_char_adm1$YEAR >= 2016) |
                                             (Enroll_char_adm1$STABBR=="MA" & Enroll_char_adm1$YEAR >= 2018) |
                                             (Enroll_char_adm1$STABBR=="CA" & Enroll_char_adm1$YEAR >= 2018) |
                                             (Enroll_char_adm1$STABBR=="NV" & Enroll_char_adm1$YEAR >= 2018) |
                                             (Enroll_char_adm1$STABBR=="MI" & Enroll_char_adm1$YEAR >= 2019))
                                          ,1,0)
  
  #"CO" "WA" "OR" "CA" "MA" "NV"
  # policy dummy based on the the effective law date                        
  Enroll_char_adm1$adopt_law <- ifelse( ((Enroll_char_adm1$STABBR=="CO" & Enroll_char_adm1$YEAR >= 2012)  |
                                           (Enroll_char_adm1$STABBR=="WA" & Enroll_char_adm1$YEAR >= 2012)|
                                           (Enroll_char_adm1$STABBR=="AK" & Enroll_char_adm1$YEAR >= 2015) |
                                           (Enroll_char_adm1$STABBR=="OR" & Enroll_char_adm1$YEAR >= 2015) |
                                           (Enroll_char_adm1$STABBR=="MA" & Enroll_char_adm1$YEAR >= 2016) |
                                           (Enroll_char_adm1$STABBR=="CA" & Enroll_char_adm1$YEAR >= 2016) |
                                           (Enroll_char_adm1$STABBR=="NV" & Enroll_char_adm1$YEAR >= 2017) |
                                           (Enroll_char_adm1$STABBR=="MI" & Enroll_char_adm1$YEAR >= 2018) |
                                           (Enroll_char_adm1$STABBR=="ME" & Enroll_char_adm1$YEAR >= 2017))
                                        ,1,0) 
  
  Enroll_char_adm1 <- Enroll_char_adm1 %>% left_join(medical_info)
  
 
  Enroll_char_adm1$adopt_medical <- ifelse(Enroll_char_adm1$YEAR < Enroll_char_adm1$med_year | is.na(Enroll_char_adm1$med_year),0,1 )
  
  Enroll_char_adm1$adopt_MM_law <- ifelse(Enroll_char_adm1$adopt_medical == 1 & Enroll_char_adm1$adopt_law == 0, 1,0)
  Enroll_char_adm1$adopt_MM_store <- ifelse(Enroll_char_adm1$adopt_medical == 1 & Enroll_char_adm1$adopt_store == 0, 1,0)
  
  
    return(Enroll_char_adm1)
}



## creating an academic subset only--no vocational or tech institutions
academic_filtration <- function(enroll_data){
  
  enroll_data$INSTNM=str_replace_all(enroll_data$INSTNM,"[^[:graph:]]", " ")  
  enroll_data$INSTNM <- enroll_data$INSTNM %>% as.character() %>% toupper() %>% trimws()
  inst_names <- enroll_data$INSTNM %>% unique() %>% as.tibble()
  
 
  # check institutions ending in INC
  inc_int <- inst_names$value[grepl(" INC$",inst_names$value)] %>% as_tibble()
  
  ## check ACADEMY  adopt_Sr
  inc_int2 <- inst_names$value[grepl("ACADEMY",inst_names$value)] %>% as_tibble()
  
  ## inncluding only colleges and universities
  enroll_data_academic <- enroll_data %>% filter(grepl("COLLEGE",INSTNM)|
                                                   grepl("UNIVERSITY",INSTNM)|
                                                   grepl("COMMUNITY COLLEGE",INSTNM)) %>% 
    filter(! grepl(" INC$",INSTNM) ) %>% ## exclude inc. institutions
    filter(! grepl("ACADEMY",INSTNM) ) %>%  ## exclude academy institutions
    filter(! grepl("BEAUTY COLLEGE",INSTNM) ) %>%
    filter(! grepl("TECHNICAL COLLEGE",INSTNM) ) %>%  
    filter(! grepl("BARBER COLLEGE",INSTNM) ) %>%  
    filter(! grepl("BARBER STYLING",INSTNM) )  %>%  
    filter(! grepl("CAREER COLLEGE",INSTNM) )  %>%  
    filter(! grepl("HAIRSTYLING",INSTNM) )  %>%  
    filter(! grepl("COLLEGE OF COSMETOLOGY",INSTNM) )  %>%  
    filter(! grepl("TECHNOLOGY COLLEGE",INSTNM) )  %>%  
    filter(! grepl("BARBERING",INSTNM) ) %>%  
    filter(! grepl("COSMETOLOGY",INSTNM) ) %>%  
    filter(! grepl("HAIR DESIGN",INSTNM) ) %>%  
    filter(! grepl("MASSAGE THERAPY",INSTNM) ) %>%  
    filter(! grepl("CAREER CENTER",INSTNM) ) %>%  
    filter(! grepl("COLLEGE OF HAIR SKIN AND NAILS",INSTNM) ) %>%  
    filter(! grepl("APPLIED TECHNOLOGY COLLEGE",INSTNM) ) %>%  
    filter(! grepl("HAIR STYLING",INSTNM) ) %>%  
    filter(! grepl("INDIANA INSTITUTE OF TECHNOLOGY-COLLEGE OF PROFESSIONAL STUDIES",INSTNM) ) 
  
  
  return(enroll_data_academic)
}
##NURSING-CINCINNATI
## keep only contiguous states 
# PSEFLAG	"Postsecondary institution indicator
# Identifies an institution whose primary purpose is to provide postsecondary education,is 
# open to the general public and is currently an active (operating) institution."
# ICLEVEL	1	Four or more years
# ICLEVEL	2	At least 2 but less than 4 years
# ICLEVEL	3	Less than 2 years (below associate)
other_filtration <- function(df){
      df %>% filter(YEAR > 2008 & YEAR < 2020 & ## county data available starting from 2009; 2020 not revised in IPEDS+COVID
                            FIPS < 57 &  ## exclude territories
                            FIPS != 15 & ## exclude Hawaii
                            PEO2ISTR == 1 & ## keep academic inst.
                            # LINE == 1 & ## Full-time, first-time, first-year, degree-seeking undergraduates
                            EFALEVEL == 4 & ## All students, Undergraduate, Degree/certificate-seeking, First-time
                            PSEFLAG == 1 &
                            ICLEVEL != 3 & ACT == "A"&
                            STABBR != "MI" & STABBR != "ME" & STABBR != "AK" ### MI opened the first store in 2019, last year of our data
                            
      ) %>% return()
  
  

}



## put all potential x variable together using
## UNITID, YEAR and/ COUNTYCD
# returns a data frame 
indepent_variables <- function(){

data_names <- c("../../data/cleaned_data/raw_data/directory_info.csv",
                "../../data/cleaned_data/raw_data/adm_act.csv",
                "../../data/cleaned_data/raw_data/finance_all.csv",
                "../../data/cleaned_data/raw_data/bls_bea_data.csv"
)

gis_dist <- read_csv("../../data/cleaned_data/raw_data/directory_info_gis.csv")

df2 <- read_csv(data_names[4]) %>% dplyr::rename(COUNTYCD=GeoFips,YEAR=TimePeriod)
df2$COUNTYCD <- df2$COUNTYCD %>% as.numeric()
df2$YEAR <- df2$YEAR %>% as.numeric()


df <- read_csv(data_names[1]) %>% left_join(gis_dist) %>% 
      left_join(read_csv(data_names[2]) )  %>% 
      left_join(read_csv(data_names[3]) ) %>% 
      left_join(df2) %>% select( 
    UNITID,YEAR,
    INSTNM,CITY,STABBR,ZIP,FIPS,COUNTYCD,COUNTYNM,OBEREG,LOCALE,ICLEVEL,   #directory_info.csv
    GROFFER,HLOFFER,MEDICAL,ACT,PSEFLAG,INSTSIZE,LONGITUD,LATITUDE,distance_ma,distance_co,
    distance_wa,distance_wa_or,
    APPLCN,APPLCNM,APPLCNW,ADMSSN,ADMSSNM,ADMSSNW,SATNUM,ACTNUM, #adm_act.csv
    SATVR75,SATMT75,ACTMT75,ACTEN75,
    net_assets,tuition_fees,fin_sample, #finance_all.csv
    per_capita_income,personal_income,population,gdp_real12, #bls_bea_data.csv
    unemply_rate,labor_force,num_employed,num_unemployed
    
    
  )
      return(df)
}

