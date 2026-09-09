source("data-sources.R")

state_df <- tibble(States=state.name,STABBR = state.abb)
df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique

# main data--IPEDS
df <- read_csv(main_data_path) %>% filter(STABBR %in% c(medical_control,tr_st)) 

treat_units <- df$STABBR[df$adopt_law%in%1] %>% unique
control_units <- df$STABBR[!df$STABBR%in%treat_units] %>% unique


df %<>%  mutate(sm_cult_dum = ifelse(STABBR %in% c("OR"), 1, 0)) %>% 
            mutate(no_cult_dum = ifelse(STABBR %in% c("WA"), 1, 0)) %>% 
            mutate(large_cult_dum = ifelse(STABBR %in% c("NV","MA","CA","CO"), 1, 0))


rhs_store=c(
  #"is_medical", :removed due to colinearity 
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

bootstrap_p_value <- function(mod1,treat_var1) {
  
  model99 <- boottest(mod1,clustid = c("STABBR"),param = treat_var1,B = 9999,bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  model999 <- boottest(mod1,clustid = c("STABBR"),param = treat_var1,B = 9999,bootcluster = c("STABBR"),fe ="UNITID")
 
   return(list(substr(model99[["p_val"]],1,5),substr(model999[["p_val"]],1,5)))
  
}

model01 = feols(.["ln_EFTOTLT"] ~  .[c("adopt_store:no_cult_dum","adopt_store","no_cult_dum",rhs_store)]|UNITID,cluster = "STABBR" ,data = df)
model02 = feols(.["ln_EFTOTLT"] ~  .[c("adopt_store:no_cult_dum","adopt_store","no_cult_dum",rhs_store)]|UNITID+YEAR,cluster = "STABBR" ,data = df)

model1 = feols(.["ln_EFTOTLT"] ~  .[c("adopt_store:sm_cult_dum","adopt_store","sm_cult_dum",rhs_store)]|UNITID,cluster = "STABBR" ,data = df)
model2 = feols(.["ln_EFTOTLT"] ~  .[c("adopt_store:sm_cult_dum","adopt_store","sm_cult_dum",rhs_store)]|UNITID+YEAR,cluster = "STABBR" ,data = df)

model3 = feols(.["ln_EFTOTLT"] ~  .[c("adopt_store:large_cult_dum","adopt_store","large_cult_dum",rhs_store)]|UNITID,cluster = "STABBR" ,data = df)
model4 = feols(.["ln_EFTOTLT"] ~  .[c("adopt_store:large_cult_dum","adopt_store","large_cult_dum",rhs_store)]|UNITID+YEAR,cluster = "STABBR" ,data = df)

#===========

btstrp1 <- list(bootstrap_p_value(model01,"adopt_store:no_cult_dum"),
                bootstrap_p_value(model02,"adopt_store:no_cult_dum"),
                
                bootstrap_p_value(model1,"adopt_store:sm_cult_dum"),
                bootstrap_p_value(model2,"adopt_store:sm_cult_dum"),
                
                bootstrap_p_value(model3,"adopt_store:large_cult_dum"),
                bootstrap_p_value(model4,"adopt_store:large_cult_dum"))

p_val_boot <- btstrp1 %>% unlist %>% .[seq(1,12,2)]
p_val_boot2 <- btstrp1 %>% unlist %>% .[seq(2,12,2)]
#===========

rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6",
                
                "Wild bootstrap p (subcluster)", p_val_boot[1], p_val_boot[2],p_val_boot[3], p_val_boot[4],p_val_boot[5],p_val_boot[6],
                "Wild bootstrap p", p_val_boot2[1], p_val_boot2[2],p_val_boot2[3], p_val_boot2[4],p_val_boot2[5],p_val_boot2[6], 
                
                
                "Year FE",    "N","Y","N","Y","N","Y",
                "College FE",   "Y","Y","Y","Y","Y","Y",)

f <- function(x) format(round(x, 3), big.mark=",")

gm <- tibble::tribble(
  ~raw,        ~clean,          ~fmt,
  "nobs",      "N Obs.",             0,
  "r2.conditional", paste0("Conditional","R2"), 2,
  "adj.r.squared", paste0("Adjusted ","R2"), 2,
  "r2.within.adjusted", paste0("Adjusted within ","R2"), 2)

#----------------------------------------------------------------

models = list(
  "None" = model01, # (OR & WA)
  "None" = model02,
  "4 plants" = model1, # (OR & WA)
  "4 plants" = model2,
  "6 plants" = model3, #(CA, MA, CO, & NV)
  "6 plants" = model4)

var_names <- c("adopt_store:no_cult_dum"="RM",
               "adopt_store:sm_cult_dum"="RM",
               "adopt_store:large_cult_dum"="RM")

modelsummary( models,
              stars = c('*' = .05, '**' = .01,'***' = .001),
              output = 'markdown',
              coef_map = var_names,
              gof_map = gm,
              add_rows=rows)


modelsummary( models,
              stars = c('*' = .05, '**' = .01,'***' = .001),
              output = 'latex',
              coef_map = var_names,
              gof_map = gm,
              add_rows=rows)%>%
  footnote(general = "", threeparttable = TRUE) %>%
  save_kable(file = paste0("../../tables/appendix/","tab_a8_hetro_cultv",".tex"))
