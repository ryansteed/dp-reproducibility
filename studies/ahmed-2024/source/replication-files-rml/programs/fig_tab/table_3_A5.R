# Setting directory to script location 
source("data-sources.R")

  state_df <- tibble(States=state.name, STABBR = state.abb)
  
  df_legal <- read_csv(leg_path) %>%  left_join(state_df) %>% filter(STABBR!="DC")
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique
  
  df1 <- read_csv(wel_path) %>%
               select(adopt_law,adopt_MM_law,adopt_store,adopt_MM_store,
                     YEAR, FIPS, UNITID,COUNTYCD,CARNEGIE,HLOFFER,STABBR,
                     EFYTOTLT,
                     ln_per_capita_income,ln_unemply_rate,ln_AGE1824_TOT,
                     ln_STUFACR,ln_NETMIG,ln_AGE1824_FEM_SHARE,
                     is_medical,is_large_inst,
                     ROTC,DIST,fin_sample,
                     
                     tuition_fees,ln_RET_PCF
                     
              ) %>% filter(STABBR %in% c(medical_control,tr_st))
  
  df1$tuition_per_st <- df1$tuition_fees/df1$EFYTOTLT
  
  log_list <- c("tuition_fees","tuition_per_st")
  
  for (i in log_list) {
    df1[[i]][df1[[i]]==0] <- 1
    df1[[i]] <- df1[[i]] %>% log
  }
  
  #  This function runs DiD and Wild bootstrap p, 
  #  returns and saves latex tables
  did_reg <- function(df1, rhs_law,file_name,is_main){
    
    df1$fin_sample <- df1$fin_sample %>% as.factor()
    
    model1 = feols(.["tuition_fees"] ~  .[ rhs_law ]+fin_sample|UNITID, cluster = "STABBR",data = df1)
    model01 <- boottest(model1,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "norm",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- substr(model01[["p_val"]],1,5)

    
    model2 <- feols(.["tuition_fees"] ~  .[ rhs_law ]+fin_sample |UNITID+ YEAR, cluster = "STABBR", data = df1)
    model02 <- boottest(model2,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "norm",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model02[["p_val"]],1,5))

    
    #-------------------------------------------------------
    model3 <- feols(.["tuition_per_st"] ~  .[rhs_law ]+fin_sample |  UNITID , cluster = "STABBR" , data = df1)
    model03 <- boottest(model3,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "norm", bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model03[["p_val"]],1,5))

    
    model4 <- feols(.["tuition_per_st"] ~   .[rhs_law ]+fin_sample | UNITID  + YEAR , data = df1)
    model04 <- boottest(model4,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "norm",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model04[["p_val"]],1,5))

    #-------------------------------------------------------
    model5 <- feols(.["ln_RET_PCF"] ~   .[rhs_law ]  | UNITID, cluster = "STABBR" , data = df1)
    model05 <- boottest(model5,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "norm",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model05[["p_val"]],1,5))

    
    model6 <- feols(.["ln_RET_PCF"] ~   .[rhs_law ] | UNITID  + YEAR , cluster = "STABBR", data = df1)
    model06 <- boottest(model6,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "norm",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model06[["p_val"]],1,5))

    
    #-------------------------------------------------------
    num1 <- as.character(df1$UNITID %>% unique %>% length )
    
    rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6",
  
                    "Wild bootstrap p (subcluster)", p_val_boot[1], p_val_boot[2],p_val_boot[3], p_val_boot[4],p_val_boot[5],p_val_boot[6],
              
                    "N college", num1, num1,num1, num1,num1,num1,
                    
                    "Controls",    "Y","Y","Y",  "Y","Y","Y",  
                    "College FE",    "Y","Y","Y",  "Y","Y","Y",
                    "Year FE",   "N","Y","N",  "Y","N","Y",  )
    
    f <- function(x) format(round(x, 3), big.mark=",")
    
    gm <- tibble::tribble(
      ~raw,        ~clean,          ~fmt,
      "nobs",      "N Obs.",             0)
    
    models = list(
      "tuition_fees"  =model1,
      "tuition_fees" =  model2,
      "tuition_per_st" =  model3,
      "tuition_per_st"= model4,
      "RET_PCF"= model5,
      "RET_PCF" =  model6)
    
    var_names <- c( '1*adopt_law = 0' = 'RM', '1*adopt_store = 0' = 'RM',
                    'adopt_law' = 'RM', 'adopt_store' = 'RM' )
    
    # edit by Donna
    res_df <- modelsummary(
      models,
      stars = c('*' = .05, '**' = .01, '***' = .001),
      output = "data.frame",
      coef_map = var_names,
      gof_map = gm
    )

    write.csv(res_df, "../../../../results/table1.csv", row.names = FALSE)
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
    ) %>% print
    
    
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
  
  ## main result
  file_name="tab_3_tuiton_med_store"
  did_reg(df1,rhs_law,file_name,TRUE)
  
  #==== using RML by law
  
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
  
  
  
  file_name="tab_a5b_tuiton_med_law"
  did_reg(df1,rhs_law,file_name,FALSE)
  
  ## All states control group
  df1 <- read_csv(wel_path) %>% 
    select(adopt_law,adopt_MM_law,adopt_store,adopt_MM_store,
           
           YEAR, FIPS, UNITID,COUNTYCD,CARNEGIE,HLOFFER,STABBR,
           
           EFYTOTLT,
           
           ln_per_capita_income,ln_unemply_rate,ln_AGE1824_TOT,
           ln_STUFACR,ln_NETMIG,ln_AGE1824_FEM_SHARE,
           
           is_medical,is_large_inst,
           ROTC,DIST,fin_sample,
           
           tuition_fees,ln_RET_PCF
           
    ) 
  
  df1$tuition_per_st <- df1$tuition_fees/df1$EFYTOTLT
  
  log_list <- c(
    "tuition_fees","tuition_per_st"
  )
  
  for (i in log_list) {
    df1[[i]][df1[[i]]==0] <- 1
    df1[[i]] <- df1[[i]] %>% log
  }
  
  ## main result
  file_name="tab_a5a_tuiton_law"
  did_reg(df1,rhs_law,file_name,FALSE)
  
  
  
