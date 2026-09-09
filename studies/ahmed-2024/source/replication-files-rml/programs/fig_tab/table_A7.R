source("data-sources.R")

  df <- read_csv(main_data_path)
  
  resid_df <- read_csv(out_enrol_path) %>% filter( YEAR %in% seq(2008,2018,2)) 
  
  #EFRES01:	First-time degree/certificate-seeking undergraduate students
  #EFRES02:	First-time degree/certificate-seeking undergraduate students who graduated from high school in the past 12 
  resid_df$EFRES02 <- resid_df$EFRES02 %>% as.numeric
  resid_df$EFRES01 <- resid_df$EFRES01 %>% as.numeric
  
  ## Local enrollments 
  local_state_enrol <- resid_df %>% left_join(df) %>% filter(EFCSTATE==FIPS ) # keep in-state enrollments
  local_state <- local_state_enrol
  
  col1 <- c("EFRES01","EFRES02")
  
  for (i in col1) {
    
    local_state[[i]][local_state[[i]]%in%c(0)] <- 1
    
    local_state[[i]] <- local_state[[i]] %>% log
  }
  
  
  
  rhs_law=c(
    "adopt_law",
    "adopt_MM_law",
    
    "is_medical",
    "is_large_inst",
    "ln_STUFACR",
    "ROTC",
    "DIST",
    
    "ln_AGE1824_TOT",
    "ln_AGE1824_FEM_SHARE",
    "ln_per_capita_income",
    "ln_unemply_rate",
    "ln_NETMIG"
  )
  
  
  rhs_store=c(
    "adopt_store",
    "adopt_MM_store",
    
    "is_medical",
    "is_large_inst",
    "ln_STUFACR",
    "ROTC",
    "DIST",
    
    "ln_AGE1824_TOT",
    "ln_AGE1824_FEM_SHARE",
    "ln_per_capita_income",
    "ln_unemply_rate",
    "ln_NETMIG"
  )
  

  bordering1 <- df %>% select(STABBR,FIPS) %>% unique %>%
    filter(STABBR %in% c("AR","NM","OK","KS","NE","WY","UT","TX",  "ID","MT",
                         "WA","OR","CO"))  #contiguous states
  bordering <- bordering1$STABBR
  
  # medical control
  state_df <- tibble(States=state.name, STABBR = state.abb)
  df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique
  
  
  ## med treated control 
  local_state_med <- local_state %>% filter(STABBR %in% c(medical_control,tr_st))


    local_state_med2 <- local_state_med %>% filter(!STABBR %in% bordering)
    local_state2 <- local_state %>% filter(!STABBR %in% bordering)
    
    model1 = feols(EFRES01 ~  .[ rhs_store ]|UNITID+YEAR ,data = local_state_med)
    model01 <- boottest(model1,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- substr(model01[["p_val"]],1,5)
    
    
    model2 <- feols(EFRES01 ~  .[ rhs_store ] |UNITID+YEAR, data =  local_state_med2)
    model02 <- boottest(model2,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model02[["p_val"]],1,5))
    
    model3 <- feols(EFRES01 ~  .[rhs_store ] |UNITID+YEAR, data =  local_state)
    model03 <- boottest(model3,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen", bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model03[["p_val"]],1,5))
     
    model4 <- feols(EFRES01 ~   .[rhs_store ] | UNITID+YEAR, data =  local_state2)
    model04 <- boottest(model4,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model04[["p_val"]],1,5))
   
    model5 <- feols(EFRES02 ~   .[rhs_store ]  |UNITID+YEAR, data = local_state_med)
    model05 <- boottest(model5,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model05[["p_val"]],1,5))
    
    model6 <- feols(EFRES02 ~   .[rhs_store] |UNITID+YEAR, data = local_state_med2)
    model06 <- boottest(model6,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model06[["p_val"]],1,5))
     
    model7 <- feols(EFRES02 ~   .[rhs_store] |UNITID+YEAR, data = local_state)
    model07 <- boottest(model7,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model07[["p_val"]],1,5))
    
    model8 <- feols(EFRES02 ~   .[rhs_store] | UNITID +YEAR, data = local_state2)
    model08 <- boottest(model8,clustid = c("STABBR"),param = rhs_store[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    p_val_boot <- c(p_val_boot,substr(model08[["p_val"]],1,5))
    
    # get the number of colleges and pre-shock treated units mean
    num_inst <- function(df){
      num_treat <- df$UNITID[df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length
      num_contr <- df$UNITID[!df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length 
      num1 <- as.character(num_treat+num_contr) 
      return(num1)
    }
    
    pre_mean <- function(df){
      treated_states <- df$STABBR[df$adopt_law==1] %>% unique
      pre_all <- df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
      
      return(pre_all)
    }
    
    rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6",~"Model 7", ~"Model 8", 
                    
                    "Wild bootstrap p (subcluster)", p_val_boot[1], p_val_boot[2],p_val_boot[3], p_val_boot[4],p_val_boot[5],p_val_boot[6], p_val_boot[7],p_val_boot[8],
                    
                    "N college", num_inst(local_state_med), num_inst(local_state_med2),num_inst(local_state), num_inst(local_state2),num_inst(local_state_med),num_inst(local_state_med2), num_inst(local_state),num_inst(local_state2),
                    "Pre-RML mean enrollment", pre_mean(local_state), pre_mean(local_state),pre_mean(local_state), pre_mean(local_state),pre_mean(local_state),pre_mean(local_state), pre_mean(local_state),pre_mean(local_state),
                    "Controls",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "Year FE",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "College FE",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "Contiguous states excluded",   "N","Y","N",  "Y","N","Y",  "N","Y",
                    
    )
    
    f <- function(x) format(round(x, 3), big.mark=",")
    
    gm <- tibble::tribble(
                  ~raw,        ~clean,          ~fmt,
                  "nobs",      "N Obs.",             0,
                  "r2.conditional", paste0("Conditional","R2"), 2,
                  "adj.r.squared", paste0("Adjusted ","R2"), 2,
                  "r2.within.adjusted", paste0("Adjusted within ","R2"), 2)

    models = list("(tot med)" = model1,
                  "(tot med)" = model2,
                  "(tot all)" = model3,
                  "(tot all)" = model4,
                  "(rhs med)" = model5,
                  "(rhs med)" = model6,
                  "(rhs all)" = model7,
                  "(rhs all)" = model8)
    
    var_names <- c('adopt_law' = 'RM', 'adopt_store' = 'RM')  
    
    note1 = "add note here"
    file_name = "tab_a7_in_state_enrol"
    modelsummary( models,
                  stars = c('*' = .05, '**' = .01,'***' = .001),
                  output = 'latex',
                  coef_map = var_names,
                  gof_map = gm,
                  add_rows=rows
    ) %>%
      footnote(general = note1, threeparttable = TRUE) %>%
      save_kable(file = paste0("../../tables/appendix/",file_name,".tex")) %>% print
    
    
 
