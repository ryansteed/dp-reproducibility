#==============================================
# RML Effect on First-Time Enrollment, 
# by Legalization and Control Group Types
# clustering at the state level
#==============================================

source("data-sources.R")

df <- read_csv(main_data_path)

rhs_law <- c("adopt_law","adopt_MM_law","is_medical","is_large_inst","ln_STUFACR","ROTC","DIST",
              "ln_AGE1824_TOT","ln_AGE1824_FEM_SHARE","ln_per_capita_income","ln_unemply_rate","ln_NETMIG")

rhs_store <- c("adopt_store","adopt_MM_store","is_medical","is_large_inst","ln_STUFACR","ROTC","DIST",
               "ln_AGE1824_TOT","ln_AGE1824_FEM_SHARE","ln_per_capita_income","ln_unemply_rate","ln_NETMIG")

# runs DiD and returns a list of model estimates
did_reg <- function(df,rhs_law){
  
  model1 <- feols(.["ln_EFTOTLT"] ~  .[c("T",rhs_law[-c(1)])] |
                    UNITID+YEAR, cluster = "STABBR",data = df %>% dplyr::rename("T" =rhs_law[1]))
  fit_cis_90 <- confint(model1,level=0.95) %>% data.frame() %>% .[1,]
  model01 <- boottest(model1,clustid = c("STABBR"),param = "T",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  
  model2 <- feols(.["ln_EFTOTLW"] ~   .[c("F",rhs_law[-c(1)]) ] |
                    UNITID+YEAR, cluster = "STABBR", data = df %>% dplyr::rename("F" =rhs_law[1]))
  fit_cis_90 <- rbind(fit_cis_90 ,confint(model2,level=0.95) %>% data.frame() %>% .[1,]) 
  model02 <- boottest(model2,clustid = c("STABBR"),param = "F",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  
  model3 <- feols(.["ln_EFTOTLM"] ~   .[c("M",rhs_law[-c(1)])] |
                    UNITID+YEAR, cluster = "STABBR",data = df %>% dplyr::rename("M"=rhs_law[1]))
  fit_cis_90 <- rbind(fit_cis_90 ,confint(model3,level=0.95) %>% data.frame() %>% .[1,]) %>% 
    rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
  #rename("conf.low_95" = "X5..","conf.high_95" = "X95..")
  model03 <- boottest(model3,clustid = c("STABBR"),param = "M",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
  
  results <- modelsummary(model1,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")%>% 
                rbind(modelsummary(model2,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                rbind(modelsummary(model3,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) 
              
  results2 <- bind_cols(results,fit_cis_90) %>% select(-statistic)
  results2$type <- "Cluster-robust CI"
  
  results_bootstrap <- results2
  
  results_bootstrap$conf.low_95 <- c(model01$conf_int[1],
                                     model02$conf_int[1],
                                     model03$conf_int[1])
  
  results_bootstrap$conf.high_95 <- c( model01$conf_int[2],
                                       model02$conf_int[2],
                                       model03$conf_int[2])
  
  results_bootstrap$type <- "Wild bootstrap  CI"
  
  results2 <- rbind(results2,results_bootstrap) 
  
  return(results2)
  
}


law_all_est <-  did_reg(df,rhs_law)
law_all_est$law <- "RML by\n Law"
law_all_est$sample <- "All states control"

store_all_est <-  did_reg(df,rhs_store)
store_all_est$law <- "RML by\n Dispensary"
store_all_est$sample <- "All states control"

## using states that legalized marijuana for medical use as a control group
state_df <- tibble(States=state.name,STABBR = state.abb)

df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")

tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique

df <- read_csv(main_data_path) %>% filter(STABBR %in% c(medical_control,tr_st))

law_med_est <-  did_reg(df,rhs_law)
law_med_est$law <- "RML by\n Law"
law_med_est$sample <- "Medical states control"

store_med_est <-  did_reg(df,rhs_store)
store_med_est$law <- "RML by\n Dispensary"
store_med_est$sample <- "Medical states control"

did_results <- law_med_est %>% rbind(store_med_est) %>% rbind(law_all_est) %>% rbind(store_all_est)

did_results$Variable<- rep(c("Total","Female","Male"),4)


did_results$Coefficient %<>% as.numeric() 

p <-  ggplot(did_results, 
             aes(x = Variable, y = Coefficient, color = type, linetype = type)) +
              geom_hline(yintercept = 0, 
                         colour = gray(1/2), lty = 2) +
              geom_linerange(aes(x = Variable,
                                 ymin = conf.low_95,
                                 ymax = conf.high_95),
                             lwd = .5,position = position_dodge(width = .6))  +
              geom_point(aes(x = Variable, 
                             y = Coefficient), size=1.5,
                         position = position_dodge(width = .6)) + 
              coord_flip()+
              facet_grid(law ~ sample )+
              theme_minimal()+   
  theme(legend.position = "bottom",#c(0.2, 0.1), 
        legend.title = element_blank(),
        strip.text = element_text(face = "bold", size = 10)) +
  scale_color_manual(values = c( "brown","darkgreen"), name = "Type", guide = "legend") +
              xlab("Enrollments")+ylab("Estimate (log points) and 95% Conf. Int.")+
  scale_linetype_manual(values = c("dashed", "solid"), name = "Type") +
  theme(panel.spacing = unit(1, "lines"))
print(p)


ggsave("../../figures/main/fig_2_b_main_did.eps", plot = p,width =6,height = 4 )  


did_results$law <- fct_relevel(factor(did_results$law), c("RML by\n Law","RML by\n Dispensary"))

p <-  ggplot(did_results %>% filter(sample%in%"Medical states control"), 
             aes(x = Variable, y = Coefficient, color = type, linetype = type)) +
  geom_hline(yintercept = 0, 
             colour = gray(1/2), lty = 2) +
  geom_linerange(aes(x = Variable,
                     ymin = conf.low_95,
                     ymax = conf.high_95),
                 lwd = .5,position = position_dodge(width = .3))  +
  geom_point(aes(x = Variable, 
                 y = Coefficient), size=1.5,
             position = position_dodge(width = .3)) + 
  coord_flip()+
  facet_grid(~law  )+
  theme_minimal()+   
  theme(legend.position = "bottom",#c(0.2, 0.1), 
        legend.title = element_blank(),
        strip.text = element_text(face = "bold", size = 10)) +
  scale_color_manual(values = c( "brown","darkgreen"), name = "Type", guide = "legend") +
  xlab("Enrollments")+ylab("Estimate (log points) and 95% Conf. Int.")+
  scale_linetype_manual(values = c("dashed", "solid"), name = "Type") +
  theme(panel.spacing = unit(1, "lines"))
print(p)

# for slides
#ggsave("../../figures/main/fig2p_main_did.eps", plot = p,width =5.5,height = 3.5 )  

#==============================================
# RML Effect on First-Time Enrollment, 
# by Legalization and Control Group Types
# clustering at the institution level
#==============================================

df <- read_csv(main_data_path)

num_treat <- df$UNITID[df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length
num_contr <- df$UNITID[!df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length 
num1 <- as.character(num_treat+num_contr) 

## pre-shock enrolllments for treated states
treated_states <- df$STABBR[df$adopt_law==1] %>% unique
pre_all <- df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
pre_w <- df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
pre_m <- (df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round - 
            df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round) %>% as.character


rhs_law=c(
  "adopt_law","adopt_MM_law",
  "is_medical","is_large_inst","ln_STUFACR","ROTC","DIST",
  "ln_AGE1824_TOT","ln_AGE1824_FEM_SHARE","ln_per_capita_income","ln_unemply_rate","ln_NETMIG"
)

rhs_store=c(
  "adopt_store","adopt_MM_store",
  "is_medical","is_large_inst","ln_STUFACR","ROTC","DIST",
  "ln_AGE1824_TOT","ln_AGE1824_FEM_SHARE","ln_per_capita_income","ln_unemply_rate","ln_NETMIG"
)


model1 <- feols(.["ln_EFTOTLT"] ~  .[rhs_law] |UNITID+YEAR, data = df)
model_all = summary(model1, cluster = c('UNITID'))

# runs DiD and returns a list of model estimates
did_reg <- function(df,rhs_law){
  
  model3 <- feols(.["ln_EFTOTLT"] ~  .[c("T",rhs_law[-c(1)])] |
                    UNITID+YEAR,data = df %>% dplyr::rename("T" =rhs_law[1]))
  model03 = summary(model3, cluster = c('UNITID'))
  fit_cis_90 <- confint(model03,level=0.95) %>% data.frame() %>% .[1,]
  
  model6 <- feols(.["ln_EFTOTLW"] ~   .[c("F",rhs_law[-c(1)]) ] |
                    UNITID+YEAR, data = df %>% dplyr::rename("F" =rhs_law[1]))
  model06 = summary(model6, cluster = c('UNITID'))
  fit_cis_90 <- rbind(fit_cis_90 ,confint(model06,level=0.95) %>% data.frame() %>% .[1,]) 
  
  model9 <- feols(.["ln_EFTOTLM"] ~   .[c("M",rhs_law[-c(1)])] |
                    UNITID+YEAR,data = df %>% dplyr::rename("M"=rhs_law[1]))
  model09 = summary(model9, cluster = c('UNITID'))
  fit_cis_90 <- rbind(fit_cis_90 ,confint(model09,level=0.95) %>% data.frame() %>% .[1,]) %>% 
    rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
  
  # results <- tidy(model03)[1,] %>% 
  #   rbind(tidy(model06)[1,])%>% 
  #   rbind(tidy(model09)[1,])
  # 
  results <- modelsummary(model03,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")%>% 
    rbind(modelsummary(model06,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
    rbind(modelsummary(model09,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) 
  
  
  results2 <- bind_cols(results, 
                        fit_cis_90) %>% select(-statistic)
  
  
  return(results2)
  
}

law_all_est <-  did_reg(df,rhs_law)
law_all_est$law <- "RML by\n Law"#"Dispensary not open"
law_all_est$sample <- "All states control"

store_all_est <-  did_reg(df,rhs_store)
store_all_est$law <- "RML by\n Dispensary"#"Dispensary open"
store_all_est$sample <- "All states control"

## using states that legalized marijuana for medical use as a control group
state_df <- tibble(States=state.name,STABBR = state.abb)

df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")

tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique

never_treated_control <- df_legal$STABBR[!df_legal$STABBR %in% mari_st] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & 
                                     !df_legal$STABBR %in% tr_st] %>% unique


df <- read_csv(main_data_path) %>% filter(STABBR %in% c(medical_control,tr_st))

num_treat <- df$UNITID[df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length
num_contr <- df$UNITID[!df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length 
num2 <- as.character(num_treat+num_contr) 

## pre-shock enrollments for treated states
treated_states <- df$STABBR[df$adopt_law==1] %>% unique
pre_all <- df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
pre_w <- df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
pre_m <- (df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round - 
            df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round) %>% as.character


model1 <- feols(.["ln_EFTOTLT"] ~  .[rhs_law] |
                  UNITID  + YEAR 
                , data = df)
model_med = summary(model1, cluster = c('UNITID'))

law_med_est <-  did_reg(df,rhs_law)
law_med_est$law <- "RML by\n Law"#"Dispensary not open"
law_med_est$sample <- "Medical states control"

store_med_est <-  did_reg(df,rhs_store)
store_med_est$law <- "RML by\n Dispensary" #"Dispensary open"
store_med_est$sample <- "Medical states control"

did_results <- law_med_est %>% rbind(store_med_est) %>% rbind(law_all_est) %>% rbind(store_all_est)

did_results$Variable<- rep(c("Total","Female","Male"),4)

## adding text note
# A data frame with labels for each facet
f_labels <- data.frame(law = c( "RML by\n Dispensary", "RML by\n Law"),
                      # law = c( "Dispensary not open", "Dispensary not open"), 
                       sample = c("All states control", "Medical states control"),
                       label= c(
                         paste0("N Obs. = ", model_all$nobs ,
                                "; ","N colleges = ",num1
                         ),
                         paste0("N Obs. = ", model_med$nobs ,
                                "; ","N colleges = ",num2
                         )))

did_results$Coefficient %<>% as.numeric() 



p <-  ggplot(did_results, 
             aes(x = Variable, y = Coefficient)) +
  geom_hline(yintercept = 0, 
             colour = gray(1/2), lty = 2) +
  geom_linerange(aes(x = Variable,
                     ymin = conf.low_95,
                     ymax = conf.high_95),color="brown",linetype="dashed",
                 lwd = .5,position = position_dodge(width = 0.2))  +
  geom_point(aes(x = Variable, 
                 y = Coefficient), size=1.5,
             position = position_dodge(width = 0.2),color="brown") + 
  coord_flip()+
  facet_grid(law ~ sample )+
  theme_minimal()+   
  theme(legend.position = "none",
        strip.text = element_text(face = "bold",size = 12))+
  scale_color_discrete(name="")+
  scale_shape_discrete(name="")+
  xlab("Enrollments")+ylab("Estimate (log points) and 95% Conf. Int.")+
  theme(panel.spacing = unit(2, "lines"))+
  geom_text(x="Total",y=.08,aes(label = label),data=f_labels,vjust = -3,size=12)



print(p)



ggsave("../../figures/main/fig_2_a_main_did.eps", plot = p,width =6,height = 4)  
