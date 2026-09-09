source("data-sources.R")

library(fixest)
#==========================================================
# Figure A3: Event Study Graph of RML Treatment 
# by Institution Type
#==========================================================

## this function run the twfe did and Sun and Abraham event study
## returns a table with coefficients and confidence intervals (0.9)

# lhs: is the left hand side of the event study regression 
# #lhs <- "ln_EFTOTLT"  
dynamic_did <- function(df,sample_name,outcome_name,lhs){
  library(data.table)
  
  df$time <- df$YEAR %>% as.numeric()
  treat_state <- df$STABBR[df$adopt_store==1] %>% unique
  df$treat <- ifelse(df$STABBR %in% treat_state,1,0)
  
  ## first year of RML
  df$`_nfd` <- NA  ## need this for event study
  
  for (j in treat_state) {
    st1 <- j
    yr1 <- df$YEAR[df$STABBR == st1 & df$adopt_store==1] %>% min #************
    df$`_nfd`[df$STABBR == st1  ] <- yr1
  }
  
  df$year <- df$YEAR %>% as.numeric()
  
  df <- df %>% data.table
  
  ## treatment dummy
  df[, treat := ifelse(is.na(`_nfd`), 0, 1)]
  
  ## number of years since first treated
  df[, time_to_treat := ifelse(treat==1, year - `_nfd`, 0)] 
  
  # Following Sun and Abraham, we give our never-treated units a fake "treatment"
  # date far outside the relevant study period.
  df[, year_treated := ifelse(treat==0, 10000, `_nfd`)]
  
  
  rhs=c(
    
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
  
  num_per=6
  ref1=-1
  
  ## https://lost-stats.github.io/Model_Estimation/Research_Design/event_study.html
  
  ### TWFE dynamic DID
  mod_twfe = feols(.[lhs] ~ i(time_to_treat, treat, ref = ref1) + ## Our key interaction: time × treatment status
                     .[rhs] |                    ## Other controls
                     UNITID + YEAR ,                             ## FEs
                   cluster = ~ UNITID,                          ## Clustered SEs
                   data = df[abs(df$time_to_treat)<num_per,])
  
  ## get the estimates and the confidence intervals values
  fit_cis_90_twfe <- confint(mod_twfe,level=0.95) %>% data.frame() %>% .[1:10,]
  
  est_twfe <- tidy(mod_twfe ) %>% data.frame() %>% .[1:10,]
  #est_twfe <- modelsummary(mod_twfe,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
  
  
  est_twfe$method <- "TWFE"
  
  ### Sun and Abraham dynamic DID
  mod_sa = feols(.[lhs] ~ sunab(year_treated, year) + ## The only thing that's changed
                   .[rhs] |
                   UNITID + YEAR ,
                 cluster = ~ UNITID,
                 data = df[abs(df$time_to_treat)<num_per,])
  
  fit_cis_90_sun <- confint(mod_sa,level=0.95) %>% data.frame() %>% .[1:10,]
  
  est_sun <- tidy(mod_sa ) %>% data.frame() %>% .[1:10,]
  #est_sun <- modelsummary(mod_sa,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
  
  est_sun$method <- "Sun & Abraham (2021)"
  
  ## create a single table
  fit_cis_90 <- fit_cis_90_sun %>% rbind(fit_cis_90_twfe)  %>%
    rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
  est_coef <- est_sun %>% rbind(est_twfe)
  
  
  results2 <- bind_cols(est_coef,
                        fit_cis_90) %>% select(-std.error,
                                               -statistic,
                                               -p.value) %>%
    rename(Variable = term, Coefficient = estimate)
  
  results2$Variable <- results2$Variable %>% parse_number
  
  ## add zero values for period -1 (normalization period)
  results2 <- results2 %>%
    rbind(c(-1,0,"Sun & Abraham (2021)",0,0))%>%
    rbind(c(-1,0,"TWFE",0,0))
  
  
  results2$outcome <- outcome_name
  results2$sample <-  sample_name
  
  for (i in c("Variable","Coefficient","conf.low_95", "conf.high_95")) {
    results2[[i]] <-  results2[[i]] %>% as.numeric
  }
  
  return(results2 %>% as_data_frame)
}


## loading the data
df <- read_csv("../../data/clean_data/enroll_all.csv") 
df_voc <- read_csv("../../data/clean_data/enroll_vocational.csv") 

### run the dynamic DID and bind the results
event_results <- dynamic_did(df,"All","Total enrollment","ln_EFTOTLT") %>% 
  rbind(dynamic_did(df_voc,"Vocational","Total enrollment","ln_EFTOTLT") )

# define color values for each group
colors <- c("darkgreen","black")

# # Create a factor with the desired variable order
# var_order <- c("Total enrollment","Female enrollment", "Male enrollment")
# event_results$outcome <- fct_relevel(factor(event_results$outcome), var_order)

p1 <-  ggplot(event_results ) +
  geom_hline(yintercept = 0,
             colour = gray(1/2), lty = 2) +
  geom_vline(xintercept = 0,
             colour = gray(1/2), lty = 2) +
  geom_linerange(aes(x = Variable,color=method,
                     ymin = conf.low_95,
                     ymax = conf.high_95),
                 position = position_dodge(width = 0.4),
                 lwd = .5)  +
  geom_point(aes(x = Variable,
                 y = Coefficient,shape=method,color=method), 
             position = position_dodge(width = 0.4),
             size=1.5) +
  facet_grid(sample~.)+
  theme_minimal()+
  xlab("Years since RML (dispensary open)")+
  ylab("Estimate (log points) and 95% Conf. Int.")+
  scale_color_manual(values = colors) +
  theme(panel.spacing = unit(1, "lines"),legend.title=element_blank(),
        legend.position = "top",strip.text = element_text(face = "bold",size=12))+
  scale_x_continuous(breaks = seq(-6,5,1)) 

print(p1)


ggsave("../../figures/appendix/fig_a3_voct_all_event.eps", plot = p1,height = 8,width = 8 )

#==========================================================
# Figure A4: Event Study Graph of RML 
# (Dispensary Not Open) Treatment
#==========================================================

## this function run the twfe did and Sun and Abraham event study
## returns a table with coefficients and confidence intervals (0.9)

# lhs: is the left hand side of the event study regression 
# #lhs <- "ln_EFTOTLT"  
dynamic_did <- function(df,sample_name,outcome_name,lhs){
  library(data.table)
  
  df$time <- df$YEAR %>% as.numeric()
  treat_state <- df$STABBR[df$adopt_law==1] %>% unique
  df$treat <- ifelse(df$STABBR %in% treat_state,1,0)
  
  ## first year of RML
  df$`_nfd` <- NA  ## need this for event study
  
  for (j in treat_state) {
    st1 <- j
    yr1 <- df$YEAR[df$STABBR == st1 & df$adopt_law==1] %>% min #************
    df$`_nfd`[df$STABBR == st1  ] <- yr1
  }
  
  df$year <- df$YEAR %>% as.numeric()
  
  df <- df %>% data.table
  
  ## treatment dummy
  df[, treat := ifelse(is.na(`_nfd`), 0, 1)]
  
  ## number of years since first treated
  df[, time_to_treat := ifelse(treat==1, year - `_nfd`, 0)] 
  
  # Following Sun and Abraham, we give our never-treated units a fake "treatment"
  # date far outside the relevant study period.
  df[, year_treated := ifelse(treat==0, 10000, `_nfd`)]
  
  
  rhs=c(
    
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
  
  num_per=6
  ref1=-1
  
  ## https://lost-stats.github.io/Model_Estimation/Research_Design/event_study.html
  
  ### TWFE dynamic DID
  mod_twfe = feols(.[lhs] ~ i(time_to_treat, treat, ref = ref1) + ## Our key interaction: time × treatment status
                     .[rhs] |                    ## Other controls
                     UNITID + YEAR ,                             ## FEs
                   cluster = ~ UNITID,                          ## Clustered SEs
                   data = df[abs(df$time_to_treat)<num_per,])
  
  ## get the estimates and the confidence intervals values
  fit_cis_90_twfe <- confint(mod_twfe,level=0.95) %>% data.frame() %>% .[1:10,]
  
  est_twfe <- tidy(mod_twfe ) %>% .[1:10,]
  #est_twfe <- modelsummary(mod_twfe,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
  
  est_twfe$method <- "TWFE"
  
  ### Sun and Abraham dynamic DID
  mod_sa = feols(.[lhs] ~ sunab(year_treated, year) + ## The only thing that's changed
                   .[rhs] |
                   UNITID + YEAR ,
                 cluster = ~ UNITID,
                 data = df[abs(df$time_to_treat)<num_per,])
  
  fit_cis_90_sun <- confint(mod_sa,level=0.95) %>% data.frame() %>% .[1:10,]
  
  est_sun <- tidy(mod_sa ) %>% data.frame() %>% .[1:10,]
  #est_sun <- modelsummary(mod_sa,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
  
  est_sun$method <- "Sun & Abraham (2021)"
  
  ## create a single table
  fit_cis_90 <- fit_cis_90_sun %>% rbind(fit_cis_90_twfe)  %>%
    rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
  est_coef <- est_sun %>% rbind(est_twfe)
  
  
  results2 <- bind_cols(est_coef,
                        fit_cis_90) %>% select(-std.error,
                                               -statistic,
                                               -p.value) %>%
    rename(Variable = term, Coefficient = estimate)
  
  results2$Variable <- results2$Variable %>% parse_number
  
  ## add zero values for period -1 (normalization period)
  results2 <- results2 %>%
    rbind(c(-1,0,"Sun & Abraham (2021)",0,0))%>%
    rbind(c(-1,0,"TWFE",0,0))
  
  
  results2$outcome <- outcome_name
  results2$sample <-  sample_name
  
  for (i in c("Variable","Coefficient","conf.low_95", "conf.high_95")) {
    results2[[i]] <-  results2[[i]] %>% as.numeric
  }
  
  return(results2 %>% as_data_frame)
}

## loading the data
df <- read_csv(main_data_path) 

state_df <- tibble(States=state.name, STABBR = state.abb)

df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")

tr_st <- unique(df_legal$STABBR[df_legal$adopt_store==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique

never_treated_control <- df_legal$STABBR[!df_legal$STABBR %in% mari_st] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & 
                                     !df_legal$STABBR %in% tr_st] %>% unique


df_med <- df %>%   filter(STABBR %in% c(medical_control,tr_st))


### run the dynamic DID and bind the results
event_results <- dynamic_did(df,"All states control","Total enrollment","ln_EFTOTLT") %>% 
  rbind(dynamic_did(df,"All states control","Female enrollment","ln_EFTOTLW") )%>% 
  rbind(dynamic_did(df,"All states control","Male enrollment","ln_EFTOTLM") ) %>%
  rbind(dynamic_did(df_med,"Medical states control","Total enrollment","ln_EFTOTLT") )%>% 
  rbind(dynamic_did(df_med,"Medical states control","Female enrollment","ln_EFTOTLW") )%>% 
  rbind(dynamic_did(df_med,"Medical states control","Male enrollment","ln_EFTOTLM") )
# define color values for each group
colors <- c(  "darkgreen","black")

# Create a factor with the desired variable order
var_order <- c("Total enrollment","Female enrollment", "Male enrollment")
event_results$outcome <- fct_relevel(factor(event_results$outcome), var_order)


p1 <-  ggplot(event_results) +
  geom_hline(yintercept = 0,
             colour = gray(1/2), lty = 2) +
  geom_vline(xintercept = 0,
             colour = gray(1/2), lty = 2) +
  geom_linerange(aes(x = Variable,color=method,
                     ymin = conf.low_95,
                     ymax = conf.high_95),
                 position = position_dodge(width = 0.4),
                 lwd = .5)  +
  geom_point(aes(x = Variable,
                 y = Coefficient,shape=method,color=method), 
             position = position_dodge(width = 0.4),
             size=1.5) +
  facet_grid(  outcome ~ sample)+
  theme_minimal()+
  xlab("Years since RML (dispensary not open)")+
  ylab("Estimate (log points) and 95% Conf. Int.")+
  scale_color_manual(values = colors) +
  theme(panel.spacing = unit(1, "lines"),legend.title=element_blank(),
        legend.position = "top",strip.text = element_text(face = "bold",size=12))+
  scale_x_continuous(breaks = seq(-6,5,1)) 

print(p1)

ggsave("../../figures/appendix/fig_a4_main_event_law.eps", plot = p1,height = 8,width = 8 )


#==========================================================
# Figure A5: Event Study Graph of RML (Dispensary Open) 
# Treatment Using All States Control Group
#==========================================================

## this function run the twfe did and Sun and Abraham event study
## returns a table with coefficients and confidence intervals (0.9)

# lhs: is the left hand side of the event study regression 
# #lhs <- "ln_EFTOTLT"  
dynamic_did <- function(df,sample_name,outcome_name,lhs){
  library(data.table)
  
  df$time <- df$YEAR %>% as.numeric()
  treat_state <- df$STABBR[df$adopt_law==1] %>% unique
  df$treat <- ifelse(df$STABBR %in% treat_state,1,0)
  
  ## first year of RML
  df$`_nfd` <- NA  ## need this for event study
  
  for (j in treat_state) {
    st1 <- j
    yr1 <- df$YEAR[df$STABBR == st1 & df$adopt_law==1] %>% min #************
    df$`_nfd`[df$STABBR == st1  ] <- yr1
  }
  
  df$year <- df$YEAR %>% as.numeric()
  
  df <- df %>% data.table
  
  ## treatment dummy
  df[, treat := ifelse(is.na(`_nfd`), 0, 1)]
  
  ## number of years since first treated
  df[, time_to_treat := ifelse(treat==1, year - `_nfd`, 0)] 
  
  # Following Sun and Abraham, we give our never-treated units a fake "treatment"
  # date far outside the relevant study period.
  df[, year_treated := ifelse(treat==0, 10000, `_nfd`)]
  
  
  rhs=c(
    
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
  
  num_per=6
  ref1=-1
  
  ## https://lost-stats.github.io/Model_Estimation/Research_Design/event_study.html
  
  ### TWFE dynamic DID
  mod_twfe = feols(.[lhs] ~ i(time_to_treat, treat, ref = ref1) + ## Our key interaction: time × treatment status
                     .[rhs] |                    ## Other controls
                     UNITID + YEAR ,                             ## FEs
                   cluster = ~ UNITID,                          ## Clustered SEs
                   data = df[abs(df$time_to_treat)<num_per,])
  
  ## get the estimates and the confidence intervals values
  fit_cis_90_twfe <- confint(mod_twfe,level=0.95) %>% data.frame() %>% .[1:10,]
  
  est_twfe <- tidy(mod_twfe) %>% data.frame() %>% .[1:10,]
  #est_twfe <- modelsummary(mod_twfe,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
  
  est_twfe$method <- "TWFE"
  
  ### Sun and Abraham dynamic DID
  mod_sa = feols(.[lhs] ~ sunab(year_treated, year) + ## The only thing that's changed
                   .[rhs] |
                   UNITID + YEAR ,
                 cluster = ~ UNITID,
                 data = df[abs(df$time_to_treat)<num_per,])
  
  fit_cis_90_sun <- confint(mod_sa,level=0.95) %>% data.frame() %>% .[1:10,]
  
  est_sun <- tidy(mod_sa ) %>% data.frame() %>% .[1:10,]
  #est_sun <- modelsummary(mod_sa,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
  
  est_sun$method <- "Sun & Abraham (2021)"
  
  ## create a single table
  fit_cis_90 <- fit_cis_90_sun %>% rbind(fit_cis_90_twfe)  %>%
    rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
  est_coef <- est_sun %>% rbind(est_twfe)
  
  
  results2 <- bind_cols(est_coef,
                        fit_cis_90) %>% select(-std.error,
                                               -statistic,
                                               -p.value) %>%
    rename(Variable = term, Coefficient = estimate)
  
  results2$Variable <- results2$Variable %>% parse_number
  
  ## add zero values for period -1 (normalization period)
  results2 <- results2 %>%
    rbind(c(-1,0,"Sun & Abraham (2021)",0,0))%>%
    rbind(c(-1,0,"TWFE",0,0))
  
  
  results2$outcome <- outcome_name
  results2$sample <-  sample_name
  
  for (i in c("Variable","Coefficient","conf.low_95", "conf.high_95")) {
    results2[[i]] <-  results2[[i]] %>% as.numeric
  }
  
  return(results2 %>% as_data_frame)
}

## loading the data
df <- read_csv(main_data_path) %>% dplyr::rename(adopt_law2=adopt_law,adopt_law=adopt_store)

state_df <- tibble(States=state.name,STABBR = state.abb)

df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")

tr_st <- unique(df_legal$STABBR[df_legal$adopt_store==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique

never_treated_control <- df_legal$STABBR[!df_legal$STABBR %in% mari_st] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & 
                                     !df_legal$STABBR %in% tr_st] %>% unique

df_med <- df %>%   filter(STABBR %in% c(medical_control,tr_st))

### run the dynamic DID and bind the results
event_results <- dynamic_did(df,"All states control","Total enrollment","ln_EFTOTLT") %>% 
  rbind(dynamic_did(df,"All states control","Female enrollment","ln_EFTOTLW") )%>% 
  rbind(dynamic_did(df,"All states control","Male enrollment","ln_EFTOTLM") ) %>%
  rbind(dynamic_did(df_med,"Medical states control","Total enrollment","ln_EFTOTLT") )%>% 
  rbind(dynamic_did(df_med,"Medical states control","Female enrollment","ln_EFTOTLW") )%>% 
  rbind(dynamic_did(df_med,"Medical states control","Male enrollment","ln_EFTOTLM") )

# define color values for each group
colors <- c("darkgreen","black")

# Create a factor with the desired variable order
var_order <- c("Total enrollment","Female enrollment", "Male enrollment")
event_results$outcome <- fct_relevel(factor(event_results$outcome), var_order)

p1 <-  ggplot(event_results %>% filter(sample=="All states control")) +
  geom_hline(yintercept = 0,
             colour = gray(1/2), lty = 2) +
  geom_vline(xintercept = 0,
             colour = gray(1/2), lty = 2) +
  geom_linerange(aes(x = Variable,color=method,
                     ymin = conf.low_95,
                     ymax = conf.high_95),
                 position = position_dodge(width = 0.4),
                 lwd = .5)  +
  geom_point(aes(x = Variable,
                 y = Coefficient,shape=method,color=method), 
             position = position_dodge(width = 0.4),
             size=1.5) +
  facet_grid(outcome~.)+
  theme_minimal()+
  xlab("Years since RML (dispensary open)")+
  ylab("Estimate (log points) and 95% Conf. Int.")+
  scale_color_manual(values = colors) +
  theme(panel.spacing = unit(1, "lines"),legend.title=element_blank(),
        legend.position = "top",strip.text = element_text(face = "bold",size=12))+
  scale_x_continuous(breaks = seq(-6,5,1)) 

print(p1)

ggsave("../../figures/appendix/fig_a5_main_event_allstates_store.eps", plot = p1,height = 8,width = 8 )
