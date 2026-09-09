source("data-sources.R")

state_df <- tibble(States = state.name, STABBR = state.abb)
df_legal <- read_csv(leg_path) %>%
  left_join(state_df) %>%
  filter(STABBR != "DC")
tr_st <- unique(df_legal$STABBR[df_legal$adopt_law == 1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique()
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique()

## medical control
df1 <- read_csv(main_data_path) %>%
  filter(STABBR %in% c(medical_control, tr_st)) %>%
  left_join(read_csv(grad_rate_path)) %>%
  filter(!STABBR %in% c("CA", "MA", "NV", "OR"))


#  This function runs DiD and Wild bootstrap p,
#  returns and saves latex tables
did_reg <- function(df1, file_name) {
  rhs <- c(
    "adopt_store", "adopt_MM_store",
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

  model1 <- feols(.["grad_rate_bachelor_4_years"] ~ .[rhs] | UNITID + YEAR, cluster = "STABBR", data = df1)
  model01 <- boottest(model1, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR", "YEAR"), fe = "UNITID")
  p_val_boot <- substr(model01[["p_val"]], 1, 5)
  model011 <- boottest(model1, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR"), fe = "UNITID")
  p_val_boot2 <- substr(model011[["p_val"]], 1, 5)

  model2 <- feols(.["grad_rate_bachelor_6_years"] ~ .[rhs] | UNITID + YEAR, cluster = "STABBR", data = df1)
  model02 <- boottest(model2, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR", "YEAR"), fe = "UNITID")
  p_val_boot <- c(p_val_boot, substr(model02[["p_val"]], 1, 5))
  model022 <- boottest(model2, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR"), fe = "UNITID")
  p_val_boot2 <- c(p_val_boot2, substr(model022[["p_val"]], 1, 5))

  model3 <- feols(.["grad_rate_bachelor_8_years"] ~ .[rhs] | UNITID + YEAR, cluster = "STABBR", data = df1)
  model03 <- boottest(model3, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR", "YEAR"), fe = "UNITID")
  p_val_boot <- c(p_val_boot, substr(model03[["p_val"]], 1, 5))
  model033 <- boottest(model3, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR"), fe = "UNITID")
  p_val_boot2 <- c(p_val_boot2, substr(model033[["p_val"]], 1, 5))

  model4 <- feols(.["grad_rate_associate_4_years"] ~ .[rhs] | UNITID + YEAR, cluster = "STABBR", data = df1)
  model04 <- boottest(model4, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR", "YEAR"), fe = "UNITID")
  p_val_boot <- c(p_val_boot, substr(model04[["p_val"]], 1, 5))
  model044 <- boottest(model4, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR"), fe = "UNITID")
  p_val_boot2 <- c(p_val_boot2, substr(model044[["p_val"]], 1, 5))

  model5 <- feols(.["grad_rate_associate_6_years"] ~ .[rhs] | UNITID + YEAR, cluster = "STABBR", data = df1)
  model05 <- boottest(model5, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR", "YEAR"), fe = "UNITID")
  p_val_boot <- c(p_val_boot, substr(model05[["p_val"]], 1, 5))
  model055 <- boottest(model5, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR"), fe = "UNITID")
  p_val_boot2 <- c(p_val_boot2, substr(model055[["p_val"]], 1, 5))

  model6 <- feols(.["grad_rate_associate_8_years"] ~ .[rhs] | UNITID + YEAR, cluster = "STABBR", data = df1)
  model06 <- boottest(model6, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR", "YEAR"), fe = "UNITID")
  p_val_boot <- c(p_val_boot, substr(model06[["p_val"]], 1, 5))
  model066 <- boottest(model6, clustid = c("STABBR"), param = rhs[1], B = 9999, type = "mammen", bootcluster = c("STABBR"), fe = "UNITID")
  p_val_boot2 <- c(p_val_boot2, substr(model066[["p_val"]], 1, 5))

  num1 <- df1$UNITID[!is.na(df1$grad_rate_bachelor_4_years)] %>%
    unique() %>%
    length() %>%
    as.character()
  num2 <- df1$UNITID[!is.na(df1$grad_rate_associate_4_years)] %>%
    unique() %>%
    length() %>%
    as.character()
  #---------------
  rows <- tribble(
    ~"Coefficients", ~"Model 1", ~"Model 2", ~"Model 3", ~"Model 4", ~"Model 5", ~"Model 6",
    "Wild bootstrap p (subcluster)", p_val_boot[1], p_val_boot[2], p_val_boot[3], p_val_boot[4], p_val_boot[5], p_val_boot[6],
    "Wild bootstrap p", p_val_boot2[1], p_val_boot2[2], p_val_boot2[3], p_val_boot2[4], p_val_boot2[5], p_val_boot2[6],
    "N college", num1, num1, num1, num2, num2, num2,
    "Controls", "Y", "Y", "Y", "Y", "Y", "Y",
    "Year FE", "Y", "Y", "Y", "Y", "Y", "Y",
    "College FE", "Y", "Y", "Y", "Y", "Y", "Y",
  )

  f <- function(x) format(round(x, 3), big.mark = ",")

  gm <- tibble::tribble(
    ~raw, ~clean, ~fmt,
    "nobs", "N Obs.", 0
  )

  models <- list(
    "(100%-Bachelor)" = model1,
    "(150%-Bachelor)" = model2,
    "(200%-Bachelor)" = model3,
    "(100%-Associates)" = model4,
    "(150%-Associates)" = model5,
    "(200%-Associates)" = model6
  )

  var_names <- c("adopt_store" = "RM")

  # note1 = "add note here"

  # modelsummary( models,
  #               stars = c('+' = .1,'*' = .05, '**' = .01,'***' = .001),
  #               output = 'latex',
  #               coef_map = var_names,
  #               gof_map = gm,
  #               add_rows=rows
  # ) %>%
  #   footnote(general = note1, threeparttable = TRUE) %>%
  #   save_kable(file = paste0("../../tables/main","/",file_name,".tex"))


  # modelsummary( models,
  #               stars = c('*' = .05, '**' = .01,'***' = .001),
  #              # output =  "markdown",
  #               coef_map = var_names,
  #               gof_map = gm,
  #               add_rows=rows)
}

## without taking any leads
# file_name="grad_rate"
# did_reg(df1,file_name)


# ============================================
# using the leads of graduation rates
# ============================================

# Setting directory to script location
# setwd(normalizePath(dirname(rstudioapi::getSourceEditorContext()$path),winslash = "\\"))

# set seed for wild bootstrap
dqrng::dqset.seed(2352342)
set.seed(23325)

source("data-sources.R")

# get the vector of medical states control group
state_df <- tibble(States = state.name, STABBR = state.abb)

df_legal <- read_csv(leg_path) %>%
  left_join(state_df) %>%
  filter(STABBR != "DC")
tr_st <- unique(df_legal$STABBR[df_legal$adopt_law == 1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique()
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique()

df <- read_csv(main_data_path) %>%
  filter(STABBR %in% c(medical_control, tr_st)) %>%
  left_join(read_csv(grad_rate_path)) %>%
  filter(!STABBR %in% c("CA", "MA", "NV", "OR"))

rhs_law <- c(
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

#  This function runs DiD and Wild bootstrap p,
#  returns and saves latex tables
did_reg <- function(df, rhs_law, file_name, outcome_leads, is_main) {
  model1 <- feols(.[outcome_leads[1]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
  ### Edited by Ryan
  # model01 <- boottest(model1,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="YEAR")
  # p_val_boot <- substr(model01[["p_val"]],1,5)
  # model011 <- boottest(model1,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR"),fe ="YEAR")
  # p_val_boot2 <- substr(model011[["p_val"]],1,5)

  model2 <- feols(.[outcome_leads[2]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
  ### Edited by Ryan
  # model02 <- boottest(model2,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  # p_val_boot <- c(p_val_boot,substr(model02[["p_val"]],1,5))
  # model022 <- boottest(model2,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR"),fe ="UNITID")
  # p_val_boot2 <- c(p_val_boot2,substr(model022[["p_val"]],1,5))

  model3 <- feols(.[outcome_leads[3]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
  ### Edited by Ryan
  # model03 <- boottest(model3,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen", bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  # p_val_boot <- c(p_val_boot,substr(model03[["p_val"]],1,5))
  # model033 <- boottest(model3,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen", bootcluster = c("STABBR"),fe ="UNITID")
  # p_val_boot2 <- c(p_val_boot2,substr(model033[["p_val"]],1,5))

  model4 <- feols(.[outcome_leads[4]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
  ### Edited by Ryan
  # model04 <- boottest(model4,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="YEAR")
  # p_val_boot <- c(p_val_boot,substr(model04[["p_val"]],1,5))
  # model044 <- boottest(model4,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR"),fe ="YEAR")
  # p_val_boot2 <- c(p_val_boot2,substr(model044[["p_val"]],1,5))

  model5 <- feols(.[outcome_leads[5]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
  ### Edited by Ryan
  # model05 <- boottest(model5,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  # p_val_boot <- c(p_val_boot,substr(model05[["p_val"]],1,5))
  # model055 <- boottest(model5,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR"),fe ="UNITID")
  # p_val_boot2 <- c(p_val_boot2,substr(model055[["p_val"]],1,5))

  model6 <- feols(.[outcome_leads[6]] ~ .[c(rhs_law)] | UNITID + YEAR, cluster = "STABBR", data = df, warn = FALSE, notes = FALSE)
  ### Edited by Ryan
  # model06 <- boottest(model6,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  # p_val_boot <- c(p_val_boot,substr(model06[["p_val"]],1,5))
  # model066 <- boottest(model6,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR"),fe ="UNITID")
  # p_val_boot2 <- c(p_val_boot2,substr(model066[["p_val"]],1,5))

  grd_rt <- outcome_leads[1] %>% gsub("_lead1", "", .)
  num1 <- as.character(df$UNITID[!is.na(df[[grd_rt]])] %>% unique() %>% length())

  ## pre-shock enrolllments for treated states
  treated_states <- df$STABBR[df$adopt_law == 1] %>% unique()

  ### Edited by Ryan
  # rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6",

  #                 "Wild bootstrap p", p_val_boot[1], p_val_boot[2],p_val_boot[3], p_val_boot[4],p_val_boot[5],p_val_boot[6],
  #                # "Wild bootstrap p", p_val_boot2[1], p_val_boot2[2],p_val_boot2[3], p_val_boot2[4],p_val_boot2[5],p_val_boot2[6],

  #                 "N college", num1, num1,num1, num1,num1,num1,
  #                 #"Pre-RML mean number of degrees", pre_all, pre_all,pre_all, pre_all,pre_all,pre_all,
  #                 "Controls",    "Y","Y","Y",  "Y","Y","Y",
  #                 "Year FE",    "Y","Y","Y",  "Y","Y","Y",
  #                 "College FE",   "Y","Y","Y",  "Y","Y","Y")

  # f <- function(x) format(round(x, 3), big.mark=",")

  gm <- tibble::tribble(
    ~raw, ~clean, ~fmt,
    "nobs", "N Obs.", 0,
    "r2.conditional", paste0("Conditional", "R2"), 2,
    "adj.r.squared", paste0("Adjusted ", "R2"), 2,
    "r2.within.adjusted", paste0("Adjusted within ", "R2"), 2
  )

  models <- list(
    "Lead 1" = model1,
    "Lead 2" = model2,
    "Lead 3" = model3,
    "Lead 4" = model4,
    "Lead 5" = model5,
    "Lead 6" = model6
  )

  var_names <- c("adopt_law" = "RM", "adopt_store" = "RM")

  # edit by Donna
  res_df <- modelsummary(
    models,
    stars = c("*" = .05, "**" = .01, "***" = .001),
    output = "data.frame",
    coef_map = var_names,
    gof_map = gm,
    statistic = c("std.error", "statistic", "p.value")
  )

  write.csv(res_df, paste0("../../../../results/", file_name, ".csv"), row.names = FALSE)

  # note1 = "add note here"

  # if(is_main){
  #   modelsummary( models,
  #                 stars = c('+' = .1,'*' = .05, '**' = .01,'***' = .001),
  #                 output = 'latex',
  #                 coef_map = var_names,
  #                 gof_map = gm,
  #                 add_rows=rows
  #   ) %>%
  #     footnote(general = note1, threeparttable = TRUE) %>%
  #     save_kable(file = paste0("../../tables/main/",file_name,".tex"))
  # }else{
  #   modelsummary( models,
  #                 stars = c('+' = .1,'*' = .05, '**' = .01,'***' = .001),
  #                 output = 'latex',
  #                 coef_map = var_names,
  #                 gof_map = gm,
  #                 add_rows=rows
  #   )%>%
  #     footnote(general = note1, threeparttable = TRUE) %>%
  #     save_kable(file = paste0("../../tables/appendix/",file_name,".tex"))
  # }

  # modelsummary( models,
  #               stars = c('+' = .1,'*' = .05, '**' = .01,'***' = .001),
  #              # output =  "markdown",
  #               coef_map = var_names,
  #               gof_map = gm,
  #               add_rows=rows
  # )
}


# Bachelor
outcome_leads <- paste0("grad_rate_bachelor_4_years_lead", 1:6)
file_name <- paste0("tab_2_med_grad_rate_", "Graduation rate (Bachelor-100%)")
did_reg(df, rhs_law, file_name, outcome_leads, TRUE) %>% print()

outcome_leads <- paste0("grad_rate_bachelor_6_years_lead", 1:6)
file_name <- paste0("tab_2_med_grad_rate_", "Graduation rate (Bachelor-150%)")
did_reg(df, rhs_law, file_name, outcome_leads, TRUE) %>% print()

# outcome_leads <- paste0("grad_rate_bachelor_8_years_lead",1:6)
# file_name=paste0("tab_2_med_grad_rate_","Graduation rate (Bachelor-200%)")
# did_reg(df,rhs_law,file_name,outcome_leads,TRUE) %>% print


# associate
outcome_leads <- paste0("grad_rate_associate_4_years_lead", 1:6)
file_name <- paste0("tab_2_med_grad_rate_", "Graduation rate (Associate-100%)")
did_reg(df, rhs_law, file_name, outcome_leads, TRUE) %>% print()

outcome_leads <- paste0("grad_rate_associate_6_years_lead", 1:6)
file_name <- paste0("tab_2_med_grad_rate_", "Graduation rate (Associate-150%)")
did_reg(df, rhs_law, file_name, outcome_leads, TRUE) %>% print()

# outcome_leads <- paste0("grad_rate_associate_8_years_lead",1:6)
# file_name=paste0("tab_2_med_grad_rate_","Graduation rate (Associate-200%)")
# did_reg(df,rhs_law,file_name,outcome_leads,TRUE) %>% print

#------------------------------
## all the states control
#------------------------------

df <- read_csv(main_data_path) %>%
  left_join(read_csv(grad_rate_path)) %>%
  filter(!STABBR %in% c("CA", "MA", "NV", "OR"))

# Bachelor
outcome_leads <- paste0("grad_rate_bachelor_4_years_lead", 1:6)
file_name <- paste0("tab_a4_all_grad_rate_", "Graduation rate (Bachelor-100%)")
did_reg(df, rhs_law, file_name, outcome_leads, FALSE) %>% print()

outcome_leads <- paste0("grad_rate_bachelor_6_years_lead", 1:6)
file_name <- paste0("tab_a4_all_grad_rate_", "Graduation rate (Bachelor-150%)")
did_reg(df, rhs_law, file_name, outcome_leads, FALSE) %>% print()

# outcome_leads <- paste0("grad_rate_bachelor_8_years_lead",1:6)
# file_name=paste0("tab_2_all_grad_rate_","Graduation rate (Bachelor-200%)")
# did_reg(df,rhs_law,file_name,outcome_leads,FALSE) %>% print


# associate
outcome_leads <- paste0("grad_rate_associate_4_years_lead", 1:6)
file_name <- paste0("tab_a4_all_grad_rate_", "Graduation rate (Associate-100%)")
did_reg(df, rhs_law, file_name, outcome_leads, FALSE) %>% print()

outcome_leads <- paste0("grad_rate_associate_6_years_lead", 1:6)
file_name <- paste0("tab_a4_all_grad_rate_", "Graduation rate (Associate-150%)")
did_reg(df, rhs_law, file_name, outcome_leads, FALSE) %>% print()

# outcome_leads <- paste0("grad_rate_associate_8_years_lead",1:6)
# file_name=paste0("tab_2_all_grad_rate_","Graduation rate (Associate-200%)")
# did_reg(df,rhs_law,file_name,outcome_leads,FALSE) %>% print
