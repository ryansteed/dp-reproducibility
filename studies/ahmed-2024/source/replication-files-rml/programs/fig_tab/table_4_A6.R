source("data-sources.R")

  state_df <- tibble(States=state.name,STABBR = state.abb)
  df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique
  
  df <- read_csv(main_data_path) 
  
  covariates1 <- df %>% select(YEAR,UNITID,FIPS,STABBR,COUNTYCD,CARNEGIE,HLOFFER,
                               adopt_law,adopt_MM_law,adopt_store,adopt_MM_store,
                               ROTC,DIST,is_medical,is_large_inst,ln_STUFACR,
                               ln_AGE1824_FEM_SHARE,ln_AGE1824_TOT,
                               ln_unemply_rate,ln_per_capita_income,ln_NETMIG) %>% unique
  
  adm <- read_csv(adm_path) %>% 
            left_join(covariates1) %>% 
            filter(ADMSSNM>0,ADMSSNW>0) %>% 
            filter(STABBR %in% c(medical_control,tr_st))## colleges with admissions
  
  adm$SATACTNUM <- adm$SATNUM+adm$ACTNUM
  
  adm$MATH <- rowMeans(cbind(adm$ACTMT75, adm$SATMT75), na.rm=TRUE)
  adm$MATH[is.nan(adm$MATH)] <- NA
  
  adm$ENGLISH <- rowMeans(cbind(adm$ACTEN75, adm$SATVR75), na.rm=TRUE)
  adm$ENGLISH[is.nan(adm$ENGLISH)] <- NA
  
  
  col1 <- c("ADMSSN","ADMSSNM","ADMSSNW",
            "APPLCN", "APPLCNM", "APPLCNW",
            "SATNUM","ACTNUM","SATACTNUM" )
  
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
  
  rhs_law=c(
    "adopt_store","adopt_MM_store",
    
    "is_medical",
    "is_large_inst",
    "ROTC",
    "DIST",
    "ln_STUFACR", 
    
    "ln_AGE1824_TOT",
    "ln_AGE1824_FEM_SHARE", 
    "ln_per_capita_income",
    "ln_unemply_rate",
    "ln_NETMIG"
  )
  
  admsn="ADMSSN"
  testnum="SATACTNUM"
  lh_m="SATACTNUM"
  
  #  This function runs DiD and Wild bootstrap p, 
  #  returns and saves latex tables
  did_reg <- function(df,rhs_law,file_name,is_main){
    
    
    model1 = feols(.["ADMSSN"] ~  .[rhs_law] | UNITID+YEAR, cluster = "STABBR", data = df)
    model01 <- boottest(model1,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="YEAR")
    p_val_boot <- substr(model01[["p_val"]],1,5)
   
    
    model2 <- feols(.["SATACTNUM"] ~  .[rhs_law] | UNITID+YEAR, cluster = "STABBR", data = df)
    model02 <- boottest(model2,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model02[["p_val"]],1,5))
    
    model3 <- feols(.["ACTMT75_z"] ~  .[rhs_law] | UNITID+YEAR, cluster = "STABBR", data = df)
    model03 <- boottest(model3,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen", bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model03[["p_val"]],1,5))
    
    model4 <- feols(.["SATMT75_z"] ~   .[rhs_law] | UNITID+YEAR, cluster = "STABBR", data = df)
    model04 <- boottest(model4,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="YEAR")
    p_val_boot <- c(p_val_boot,substr(model04[["p_val"]],1,5))
    
    model5 <- feols(.["ACTEN75_z"] ~   .[rhs_law]  | UNITID+YEAR, cluster = "STABBR", data = df)
    model05 <- boottest(model5,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model05[["p_val"]],1,5))
    
    model6 <- feols(.["SATVR75_z"] ~   .[rhs_law] | UNITID+YEAR, cluster = "STABBR", data = df)
    model06 <- boottest(model6,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model06[["p_val"]],1,5))
   
    num_treat <- df$UNITID[df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length
    num_contr <- df$UNITID[!df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length 
    num1 <- as.character(num_treat+num_contr) 
    
    n0 <- df %>% filter(!is.na(ACTMT75)|!is.na(SATMT75))  ## number of institutions with admissions
    num0 <- n0$UNITID %>% unique %>% length %>% as.character
    
    n1 <- df %>% filter(!is.na(ADMSSN))  ## number of institutions with admissions
    num1 <- n1$UNITID %>% unique %>% length %>% as.character
    
    
    n2 <- df %>% filter(!is.na(ACTMT75))  ## number of institutions with act submissions
    num2 <- n2$UNITID %>% unique %>% length %>% as.character
    
    
    n3 <- df %>% filter(!is.na(SATMT75))  ## number of institutions with sat submissions
    num3 <- n3$UNITID %>% unique %>% length %>% as.character
    
    rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6", 
                    
                    "Wild bootstrap p (subcluster)", p_val_boot[1], p_val_boot[2],p_val_boot[3], p_val_boot[4],p_val_boot[5],p_val_boot[6],
                    
                    "N college", num1, num0,num2, num3,num2,num3,
                    "Controls",    "Y","Y","Y",  "Y","Y","Y", 
                    "Year FE",    "Y","Y","Y",  "Y","Y","Y", 
                    "College FE",   "Y","Y","Y",  "Y","Y","Y",  )
    
    f <- function(x) format(round(x, 3), big.mark=",")

    gm <- tibble::tribble(
      ~raw,        ~clean,          ~fmt,
      "nobs",      "N Obs.",             0,
      "r2.conditional", paste0("Conditional","R2"), 2,
      "adj.r.squared", paste0("Adjusted ","R2"), 2,
      "r2.within.adjusted", paste0("Adjusted within ","R2"), 2
      
    )
    
    #----------------------------------------------------------------
    
    models = list(
      "ADMSSN"  =model1,
      "SATACTNUM" =  model2,
      "ACTMT75" =  model3,
      "SATMT75"= model4,
      "ACTEN75"= model5,
      "SATVR75" =  model6 )
    

    var_names <- c('adopt_law' = 'RM','adopt_store' = 'RM')
   
    note1 = "add note here"
    
    if(is_main){
      modelsummary( models,
                    stars = c('*' = .05, '**' = .01,'***' = .001),
                    output = 'latex',
                    coef_map = var_names,
                    gof_map = gm,
                    add_rows=rows
                    
      ) %>%
        footnote(general = note1, threeparttable = TRUE) %>%
        save_kable(file = paste0("../../tables/main/",file_name,".tex"))
    }else{
      modelsummary( models,
                    stars = c('*' = .05, '**' = .01,'***' = .001),
                    output = 'latex',
                    coef_map = var_names,
                    gof_map = gm,
                    add_rows=rows
      )%>%
        footnote(general = note1, threeparttable = TRUE) %>%
        save_kable(file = paste0("../../tables/appendix/",file_name,".tex"))
    }
    
    modelsummary( models,
                  stars = c('*' = .05, '**' = .01,'***' = .001),
                  output =  "markdown",
                  coef_map = var_names,
                  gof_map = gm,
                  add_rows=rows
    )%>% print
    
  }

  ## main result
  file_name="tab_4_adm_scores_med"
  df=adm
  did_reg(df,rhs_law,file_name,TRUE)
  

  rhs_law=c(
    "adopt_law","adopt_MM_law",
    
    "is_medical",
    "is_large_inst",
    "ROTC",
    "DIST",
    "ln_STUFACR", 
    
    "ln_AGE1824_TOT",
    "ln_AGE1824_FEM_SHARE", 
    "ln_per_capita_income",
    "ln_unemply_rate",
    "ln_NETMIG"
  )
  
  file_name="tab_a6b_adm_scores_med_law"
  did_reg(df,rhs_law,file_name,FALSE)
  
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
            "SATNUM","ACTNUM","SATACTNUM")
  
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
  
  df=adm
  file_name="tab_a6a_adm_scores_all_law"
  did_reg(df,rhs_law,file_name,FALSE)
  
  
