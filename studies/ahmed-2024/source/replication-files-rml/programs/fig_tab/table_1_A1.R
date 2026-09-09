source("data-sources.R")

  df <- read_csv(main_data_path) 
  
  covariates1 <- df %>% select(YEAR,UNITID,FIPS,STABBR,COUNTYCD,CARNEGIE,HLOFFER,
                               adopt_law,adopt_MM_law,adopt_store,adopt_MM_store,
                               ROTC,DIST,is_medical,is_large_inst,ln_STUFACR,
                               ln_AGE1824_FEM_SHARE,ln_AGE1824_TOT,
                               ln_unemply_rate,ln_per_capita_income,ln_NETMIG,
  ) %>% unique
  
  adm <- read_csv(adm_path) %>% left_join(covariates1) %>% 
    filter(ADMSSNM>0,ADMSSNW>0)## colleges with admissions
  
  adm$SATACTNUM <- adm$SATNUM+adm$ACTNUM
  
  adm$MATH <- rowMeans(cbind(adm$ACTMT75, adm$SATMT75), na.rm=TRUE)
  adm$MATH[is.nan(adm$MATH)] <- NA
  
  adm$ENGLISH <- rowMeans(cbind(adm$ACTEN75, adm$SATVR75), na.rm=TRUE)
  adm$ENGLISH[is.nan(adm$ENGLISH)] <- NA
  
  
  col1 <- c("ADMSSN","ADMSSNM","ADMSSNW",
            "APPLCN", "APPLCNM", "APPLCNW",
            "SATNUM","ACTNUM","SATACTNUM"
  )
  
  for (i in col1) {
    adm[[i]] <-log(adm[[i]]+1)
  }    
  
  
  ## standardize the scores
  col2 <- c(
    "ACTMT75","SATMT75","ACTEN75","SATVR75","MATH","ENGLISH"
  )
  
  for (i in col2) {
    adm[[paste0(i,"_z")]]  <- ( adm[[i]]  - mean( adm[[i]],na.rm = T )) / sd( adm[[i]],na.rm = T )
  }
  
  adm_data <- adm %>% select("UNITID", "YEAR", "COUNTYCD","STABBR",
                             # "ACTMT75_z","SATMT75_z","ACTEN75_z","SATVR75_z",
                             "ACTMT75","SATMT75","ACTEN75","SATVR75",
                             "ADMSSN","SATACTNUM"
  )
  ###=========================================
  
  
  #%%%%%%% out-of-state enrollment data %%%%%%%%%%%%%%%%%%
  df <- read_csv(main_data_path)
  
  resid_df <- read_csv(out_enrol_path)   %>% 
    filter( YEAR %in% seq(2008,2018,2)) 
  
  
  resid_df$EFRES02 <- resid_df$EFRES02 %>% as.numeric
  resid_df$EFRES01 <- resid_df$EFRES01 %>% as.numeric
  
  
  
  ## out-of-state enrollments 
  out_state_enrol <- resid_df %>% left_join(df) %>% filter(EFCSTATE!=FIPS )
  
  out_state <- aggregate(cbind(EFRES01,EFRES02)~
                           YEAR+UNITID,
                         data = out_state_enrol,FUN = sum,na.rm=TRUE, na.action=NULL) 
  
  col1 <- c("EFRES01","EFRES02" )
  
  
  for (i in col1) {
    
    out_state[[i]][out_state[[i]]<=0] <- 1
    
    out_state[[i]] <- out_state[[i]] %>% log
  }
  
  
  #&&&&&&&&&&& tuitioin and retention rate data &&&&&&&&&&&&&&
  
  welfare <- read_csv(wel_path) %>% 
    select(YEAR, STABBR, UNITID,COUNTYCD,
           EFYTOTLT,
           tuition_fees,ln_RET_PCF) 
  
  ## unlog retention rate
  welfare$RET_PCF <- exp(welfare$ln_RET_PCF)
  
  welfare$tuition_per_st <- welfare$tuition_fees/welfare$EFYTOTLT
  
  log_list <- c(
    "tuition_fees","tuition_per_st"
  )
  
  for (i in log_list) {
    welfare[[i]][welfare[[i]]==0] <- 1
    welfare[[i]] <- welfare[[i]] %>% log
  }
  
  
  welfare <- welfare %>% 
    select(YEAR, UNITID,STABBR,
           tuition_fees,tuition_per_st,
           RET_PCF
           
    ) 
  
  affected_states <- df$STABBR[df$adopt_law ==1] %>% unique()
  welfare$dum = ifelse( (welfare$STABBR %in% affected_states), "RM States", "Non-RM States")
  
  
  outcomes = c(
    "ln_EFTOTLT",
    "ln_EFTOTLM",
    "ln_EFTOTLW",
    "ln_CTOTALT"
  )
  
  
  
  controls =c(
    
    "is_medical",
    "is_large_inst",
    "ROTC",
    "DIST",
    
    "ln_AGE1824_TOT",
    "AGE1824_FEM_SHARE",
    "unemply_rate",
    "ln_STUFACR",
    "ln_per_capita_income",
    "ln_NETMIG"
  )
  
  grd_rates_df <- read_csv(grad_rate_path) %>% 
                    select(grad_rate_bachelor_4_years,grad_rate_bachelor_6_years,grad_rate_bachelor_8_years,
                           grad_rate_associate_4_years,grad_rate_associate_6_years,grad_rate_associate_8_years,
                           YEAR, UNITID)

  
  df <- read_csv( main_data_path) %>% 
    left_join(read_csv(com_path) %>% 
                filter(AWLEVEL%in% c("All undergraduate degrees"))) %>% 
    select(c("UNITID", "YEAR", "COUNTYCD","STABBR","adopt_law",
             outcomes,controls,"RET_PCF")) %>%
    left_join(adm_data) %>% 
    left_join(out_state) %>% select(-RET_PCF) %>% 
    left_join(grd_rates_df) %>% 
    left_join(welfare) %>% 
    dplyr::rename(
      `Log total first-time enrollment`=ln_EFTOTLT,
      `Log female first-time enrollment`=ln_EFTOTLW,
      `Log male first-time enrollment`=ln_EFTOTLM,
      `Log number of degrees` = ln_CTOTALT,
      
    
      `Aggregate enrollment over 20k dummy`=is_large_inst,
      `Offering medical degree dummy`=is_medical,
      `Offering ROTC program dummy`=ROTC,
      `Offering distance programs dummy`=DIST,
      `Log student to faculty ratio`=ln_STUFACR,
      `Log age 18 to 24 population`=ln_AGE1824_TOT,
      `Age 18 to 24 population female share`=AGE1824_FEM_SHARE,
      `Unemployment rate`=unemply_rate,
      `Log per capita income`=ln_per_capita_income,
      `Log Net migration`=ln_NETMIG,
    
      `Log total out-of-state enrollment`=EFRES01,
      `Log RHG out-of-state enrollment`=EFRES02,
      
      `Tuition and fees revenue`=tuition_fees,
      `Tuition and fees revenue per student`=tuition_per_st,
     
      
      `Log number of  admissionss`=ADMSSN,
      `Log number of ACT and SAT submissions`=SATACTNUM,
      
      `Bachelor’s graduation rate (100% normal time)` = grad_rate_bachelor_4_years,
      `Bachelor’s graduation rate (150% normal time)` = grad_rate_bachelor_6_years,
      `Bachelor’s graduation rate (200% normal time)` = grad_rate_bachelor_8_years,
      `Associate’s graduation rate (100% normal time)` = grad_rate_associate_4_years, # i just changed the name for consistency (4 years here refers to 2 years)
      `Associate’s graduation rate (150% normal time)` = grad_rate_associate_6_years,
      `Associate’s graduation rate (200% normal time)` = grad_rate_associate_8_years,
      
 
      `Retention rate`=RET_PCF,
  
      `ACT 75th Math score`=ACTMT75,
      `SAT 75th Math score`=SATMT75,
      `ACT 75th English score`=ACTEN75,
      `ACT 75th Crititcal Reading score`=SATVR75
      
    )
  
  
  
  affected_states <- df$STABBR[df$adopt_law ==1] %>% unique()
  df$dum = ifelse( (df$STABBR %in% affected_states), "RM States", "Non-RM States")
  
  treated_inst <- df$UNITID[df$STABBR %in% affected_states] %>% unique %>% length()
  control_inst <- (df$UNITID %>% unique %>% length()) - treated_inst
  

  
  # datasummary( `Log total first-time enrollment`+
  #                `Log female first-time enrollment`+
  #                `Log male first-time enrollment`+
  #                `Log number of degrees`+
  #                
  #                
  #                `ACT 75th Math score`+
  #                `SAT 75th Math score`+
  #                `ACT 75th English score`+
  #                `ACT 75th Crititcal Reading score`+
  #                `Log number of  admissionss`+
  #                `Log number of ACT and SAT submissions`+
  #                
  #                `Tuition and fees revenue`+
  #                `Tuition and fees revenue per student`+
  #                `Retention rate`+
  #                
  #                `Log total out-of-state enrollment`+
  #                `Log RHG out-of-state enrollment`+
  #                
  #              `Bachelor’s graduation rate (100% normal time)`+
  #              `Bachelor’s graduation rate (150% normal time)`+
  #              `Bachelor’s graduation rate (200% normal time)`+
  #              `Associate’s graduation rate (100% normal time)`+
  #              `Associate’s graduation rate (150% normal time)` +
  #              `Associate’s graduation rate (200% normal time)`+
  #              
  #                
  #                `Offering medical degree dummy`+
  #                `Aggregate enrollment over 20k dummy`+
  #                `Offering ROTC program dummy`+
  #                `Offering distance programs dummy`+
  #                `Log student to faculty ratio`+
  #                `Log age 18 to 24 population`+
  #                `Age 18 to 24 population female share`+
  #                `Unemployment rate`+
  #                `Log per capita income`+
  #                `Log Net migration`
  #              ~ (Mean + SD   ),
  #              data = df , output = "../../tables/appendix/summary_stat_all.tex")
  
  
  
  datasummary_balance(~ dum,
                      fmt = fmt_decimal(digits = 3, pdigits = 3),
                      dinm_statistic='p.value',
                      # stars=TRUE,
                      output = "../../tables/appendix/summary_stat.tex",
                      data = df %>% select(-c(STABBR,UNITID,YEAR,COUNTYCD,adopt_law)))
  

  ## main result
  state_df <- tibble(
    States=state.name,
    STABBR = state.abb
  )
  
  
  df_legal <- read_csv(  leg_path) %>% 
                left_join(state_df) %>% filter(STABBR!="DC")
  
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  
  never_treated_control <- df_legal$STABBR[!df_legal$STABBR %in% mari_st] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & 
                                       !df_legal$STABBR %in% tr_st] %>% unique
  
  
  datasummary_balance(~ dum,
                      fmt = fmt_decimal(digits = 3, pdigits = 3),
                      dinm_statistic='p.value',
                      # stars=TRUE,
                      output = "../../tables/main/summary_stat_med.tex",
                      data = df %>% filter(STABBR %in% c(medical_control,tr_st)) %>%
                        select(-c(STABBR,UNITID,YEAR,COUNTYCD,adopt_law)))
  
  datasummary_balance(~ dum,
                      fmt = fmt_decimal(digits = 3, pdigits = 3),
                      dinm_statistic='p.value',
                      data = df %>% filter(STABBR %in% c(medical_control,tr_st)) %>%
                        select(-c(STABBR,UNITID,YEAR,COUNTYCD,adopt_law)))
  
  df = df %>% filter(STABBR %in% c(medical_control,tr_st)) 
  treated_inst <- df$UNITID[df$STABBR %in% affected_states] %>% unique %>% length()
  control_inst <- (df$UNITID %>% unique %>% length()) - treated_inst
  
  

