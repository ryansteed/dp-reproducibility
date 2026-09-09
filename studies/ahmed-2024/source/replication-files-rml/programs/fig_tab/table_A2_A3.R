source("data-sources.R")

state_df <- tibble(States=state.name,STABBR = state.abb)
df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st ] %>% unique

#  This function runs DiD and Wild bootstrap p, 
#  returns and saves latex tables
did_reg <- function(rhs,file_name) {
  
  lh_all="ln_EFTOTLT"
  lh_f="ln_EFTOTLW"
  lh_m="ln_EFTOTLM"
  
  model1 <- feols(.[lh_all] ~  .[rhs[1:2]]|UNITID+YEAR, cluster = "STABBR", data = df1)
  model01 <- boottest(model1,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- substr(model01[["p_val"]],1,5)
   
  model2 <- feols(.[lh_all] ~  .[rhs[1:7]]|UNITID+YEAR, cluster = "STABBR", data = df1)
  model02 <- boottest(model2,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model02[["p_val"]],1,5))
  
  model3 <- feols(.[lh_all] ~  .[rhs[c(1:2,8:12)]]| UNITID+YEAR, cluster = "STABBR", data = df1)
  model03 <- boottest(model3,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen", bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model03[["p_val"]],1,5))
  
  
  model32 <- feols(.[lh_all] ~  .[rhs]| UNITID+YEAR, cluster = "STABBR", data = df1)
  model032 <- boottest(model32,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen", bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model032[["p_val"]],1,5))
  

  
  #-------------------------------------------------------
  model4 <- feols(.[lh_f] ~   .[rhs[1:2]]|UNITID+YEAR, cluster = "STABBR", data = df1)
  model04 <- boottest(model4,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model04[["p_val"]],1,5))
  
  model5 <- feols(.[lh_f] ~   .[rhs[1:7]]|UNITID+YEAR, cluster = "STABBR", data = df1)
  model05 <- boottest(model5,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model05[["p_val"]],1,5))
  
  model6 <- feols(.[lh_f] ~   .[rhs[c(1:2,8:12)]]|UNITID+YEAR, cluster = "STABBR", data = df1)
  model06 <- boottest(model6,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model06[["p_val"]],1,5))
  
  
  model62 <- feols(.[lh_f] ~   .[rhs]|UNITID+YEAR, cluster = "STABBR", data = df1)
  model062 <- boottest(model62,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model062[["p_val"]],1,5))
  
  
  #-------------------------------------------------------
  model7 <- feols(.[lh_m] ~   .[rhs[1:2]] |UNITID+YEAR, cluster = "STABBR", data = df1)
  model07 <- boottest(model7,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model07[["p_val"]],1,5))
  
  model8 <- feols(.[lh_m] ~   .[rhs[1:7]] |UNITID+YEAR, cluster = "STABBR", data = df1)
  model08 <- boottest(model8,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model08[["p_val"]],1,5))
  
  model9 <- feols(.[lh_m] ~   .[rhs[c(1:2,8:12)]] |UNITID+YEAR, cluster = "STABBR", data = df1)
  model09 <- boottest(model9,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model09[["p_val"]],1,5))
  
  
  model92 <- feols(.[lh_m] ~   .[rhs] |UNITID+YEAR, cluster = "STABBR", data = df1)
  model092 <- boottest(model92,clustid = c("STABBR"),param = rhs[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  p_val_boot <- c(p_val_boot,substr(model092[["p_val"]],1,5))
  
  
  num_treat <- df1$UNITID[df1$FIPS %in% unique(df1$FIPS[df1$adopt_law==1])] %>% unique %>% length
  num_contr <- df1$UNITID[!df1$FIPS %in% unique(df1$FIPS[df1$adopt_law==1])] %>% unique %>% length 
  num1 <- as.character(num_treat+num_contr) 
  
  ## pre-shock enrolllments for treated states
  treated_states <- df1$STABBR[df1$adopt_law==1] %>% unique
  pre_all <- df1$EFTOTLT[df1$adopt_law==0 & df1$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
  pre_w <- df1$EFTOTLW[df1$adopt_law==0 & df1$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
  pre_m <- (df1$EFTOTLT[df1$adopt_law==0 & df1$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round - 
              df1$EFTOTLW[df1$adopt_law==0 & df1$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round) %>% as.character
  
  #---------------
  rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6",~"Model 7", ~"Model 8", ~"Model 9", ~"Model 10", ~"Model 11", ~"Model 12", 
                  "Wild bootstrap p (subcluster)", p_val_boot[1], p_val_boot[2],p_val_boot[3], p_val_boot[4],p_val_boot[5],p_val_boot[6], p_val_boot[7],p_val_boot[8],p_val_boot[9], p_val_boot[10],p_val_boot[11],p_val_boot[12],
                  
                  "N college", num1, num1,num1, num1,num1,num1, num1,num1,num1,num1,num1,num1,
                  "Pre-RML mean enrollment", pre_all, pre_all,pre_all, pre_all,pre_w,pre_w, pre_w,pre_w,pre_m,pre_m,pre_m,pre_m,
                  
                  "County controls",    "N","Y","N","Y",   "N","Y","N","Y",  "N","Y","N","Y",
                  "College controls",   "N","N","Y","Y",   "N","N","Y","Y",   "N","N","Y","Y",
                  "Year FE",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y","Y", "Y","Y","Y",
                  "College FE",   "Y","Y","Y",  "Y","Y","Y",  "Y","Y","Y", "Y","Y","Y",)
  
  f <- function(x) format(round(x, 3), big.mark=",")
  
  gm <- tibble::tribble(~raw,        ~clean,          ~fmt,
                        "nobs",      "N Obs.",             0)
  
  models = list("(All)" = model1,
                "(All)" = model2,
                "(All)" = model3,
                "(All)" = model32,
                "(Female)" = model4,
                "(Female)" = model5,
                "(Female)" = model6,
                "(Female)" = model62,
                "(Male)" = model7,
                "(Male)" = model8,
                "(Male)" = model9,
                "(Male)" = model92)
  
  var_names <- c( '1*adopt_law = 0' = 'RM', 
                  '1*adopt_store = 0' = 'RM',
                  "adopt_law" = 'RM', 
                  "adopt_store" = 'RM')
  
  note1 = "add note here"
  
  modelsummary( models,
                stars = c('+' = .104,'*' = .05, '**' = .01,'***' = .001),
                output = 'latex',
                coef_map = var_names,
                gof_map = gm,
                add_rows=rows)%>%
    footnote(general = note1, threeparttable = TRUE) %>%
    save_kable(file = paste0("../../tables/appendix","/",file_name,".tex"))
  
  
  modelsummary( models,
                stars = c('+'=.104, '*' = .05, '**' = .01,'***' = .001),
                output =  "markdown",
                coef_map = var_names,
                gof_map = gm,
                add_rows=rows) %>% print
  
  
}

rhs_law=c(
  "adopt_law","adopt_MM_law",
  
  "ln_AGE1824_TOT",
  "ln_AGE1824_FEM_SHARE",
  "ln_per_capita_income",
  "ln_unemply_rate",
  "ln_NETMIG",
  
  "is_medical",
  "is_large_inst",
  "ln_STUFACR",
  "ROTC",
  "DIST"
)


rhs_store=c(
  "adopt_store","adopt_MM_store",
  
  "ln_AGE1824_TOT",
  "ln_AGE1824_FEM_SHARE",
  "ln_per_capita_income",
  "ln_unemply_rate",
  "ln_NETMIG",
  
  "is_medical",
  "is_large_inst",
  "ln_STUFACR",
  "ROTC",
  "DIST"
  

)

## medical control   
df1 <- read_csv(main_data_path) %>% filter(STABBR %in% c(medical_control,tr_st)) 

file_name="tab_a2a_med_cnt"
did_reg(rhs_law,file_name)

file_name="tab_a2b_med_cnt_store"
did_reg(rhs_store,file_name)

## main result
df1 <- read_csv(main_data_path) 

file_name="tab_a3a_all_cnt"
did_reg(rhs_law,file_name)

file_name="tab_a3b_all_cnt_store"
did_reg(rhs_store,file_name)







