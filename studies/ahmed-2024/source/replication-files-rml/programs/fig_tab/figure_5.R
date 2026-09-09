# Note: the computation of distance between each college and the nearest 
# treated border may take up to 30 minutes (adjust for parallel computing)

# Setting directory to script location 
source("data-sources.R")
  
  df_acd <- read_csv(main_data_path) #%>% select(-adopt_law) %>% dplyr::rename(adopt_law=adopt_store)
  df_acd$is_public <- ifelse(df_acd$CONTROL==1,1,0)
  lh_all="ln_EFTOTLT"
  
  rhs_law=c(
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
  
  
  did_reg1 <- function(df_acd){ 
    
    
    model1a = feols(.[lh_all] ~  .[c("Associate",rhs_law) ] | 
                      UNITID +YEAR, cluster = c('STABBR') , 
                    data = df_acd %>% filter(HLOFFER%in%c(2:5)) %>% 
                      dplyr::rename(Associate=adopt_law)
                    
    )
    model01a = summary(model1a, cluster = c('STABBR'))
    fit_cis_95 <- confint(model01a,level=0.95) %>% data.frame() %>% .[1,]
    btstrp1 <- boottest(model1a,clustid = c("STABBR"),param = "Associate",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    
    
    ## not used
    model1b = feols(.[lh_all] ~  .[ c("Bachelor",rhs_law) ] | 
                      UNITID +YEAR, cluster = c('STABBR') , 
                    data = df_acd %>% filter(HLOFFER%in%c(2:5))%>% 
                      dplyr::rename(Bachelor=adopt_law) )
    model01b = summary(model1b, cluster = c('STABBR'))
    btstrp2 <- boottest(model1b,clustid = c("STABBR"),param = "Bachelor",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    
    model1m = feols(.[lh_all] ~  .[  c("Master",rhs_law) ] | 
                      UNITID +YEAR, cluster = c('STABBR') , 
                    data = df_acd %>% filter(HLOFFER%in%c(7,9))%>% 
                      dplyr::rename(Master=adopt_law) )
    model01m = summary(model1m, cluster = c('STABBR'))
    btstrp3 <- boottest(model1m,clustid = c("STABBR"),param = "Master",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    
    ## not used
    model2d <- feols(.[lh_all] ~  .[  c("Doctor",rhs_law) ] |
                       UNITID +YEAR, cluster = c('STABBR') 
                     , data = df_acd %>% filter(HLOFFER%in%c(7,9))%>% 
                       dplyr::rename(Doctor=adopt_law) )
    model02d = summary(model2d, cluster = c('STABBR'))
    fit_cis_95 <- rbind(fit_cis_95 ,confint(model02d,level=0.95) %>% data.frame() %>% .[1,]) 
    btstrp4 <- boottest(model2d,clustid = c("STABBR"),param = "Doctor",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    ## did for public institutions
    model1p = feols(.[lh_all] ~  .[c("Public",rhs_law) ] | 
                      UNITID +YEAR, cluster = c('STABBR') , 
                    data = df_acd %>% filter(is_public==1) %>% 
                      dplyr::rename(Public=adopt_law)
                    
    )
    model01p = summary(model1p, cluster = c('STABBR'))
    fit_cis_95 <- rbind(fit_cis_95 ,confint(model01p,level=0.95) %>% data.frame() %>% .[1,]) 
    btstrp5 <- boottest(model1p,clustid = c("STABBR"),param = "Public",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    
    ##  did for private institutions
    model1pv = feols(.[lh_all] ~  .[c("Private",rhs_law) ] | 
                       UNITID +YEAR, cluster = c('STABBR') , 
                     data = df_acd %>% filter(is_public==0) %>% 
                       dplyr::rename(Private=adopt_law)
                     
    )
    model01pv = summary(model1pv, cluster = c('STABBR'))
    fit_cis_95 <- rbind(fit_cis_95 ,confint(model01pv,level=0.95) %>% data.frame() %>% .[1,]) %>% 
      rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
    btstrp6 <- boottest(model1pv,clustid = c("STABBR"),param = "Private",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    
    results <- modelsummary(model01a,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")%>% 
                  rbind(modelsummary(model01m,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                  rbind(modelsummary(model01p,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                  rbind(modelsummary(model01pv,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) 
    
    results2 <- bind_cols(results, fit_cis_95) %>% select(-statistic) 
    
    # Create a factor with the desired variable order
    results2$Variable <- c("Associate's or Bachelor's","Master's or Doctoral's","Public","Private")
    var_order <- c("Associate's or Bachelor's","Master's or Doctoral's","Public","Private")
    results2$Variable <- fct_relevel(factor(results2$Variable), var_order)
    
    results2$type <- "Cluster-robust CI"
    #=====
 
    results_bootstrap <- results2
    
    results_bootstrap$conf.low_95 <- c(btstrp1$conf_int[1],
                                       btstrp3$conf_int[1],
                                       btstrp5$conf_int[1],
                                       btstrp6$conf_int[1])
    
    results_bootstrap$conf.high_95 <- c( btstrp1$conf_int[2],
                                         btstrp3$conf_int[2],
                                         btstrp5$conf_int[2],
                                         btstrp6$conf_int[2])
    
    results_bootstrap$type <- "Wild bootstrap  CI"
    results2 <- rbind(results2,results_bootstrap) 
    return(results2)
    
  }
  
  all_states <- did_reg1(df_acd)
  all_states$sample <- "All states control"
  
  
  ######## MEDICAL SAMPLE ################
  
  state_df <- tibble( States=state.name,STABBR = state.abb )
  df_legal <- read_csv(leg_path ) %>% left_join(state_df) %>% filter(STABBR!="DC")
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st &!df_legal$STABBR %in% tr_st] %>% unique
  
  
  df <- read_csv(main_data_path)%>% filter(STABBR %in% c(medical_control,tr_st))
  
  df_acd=df
  df_acd$is_public <- ifelse(df_acd$CONTROL==1,1,0)
  
  med_states <- did_reg1(df_acd)
  med_states$sample <- "Medical states control"
  
  all1 <- med_states %>% rbind(all_states)
  all1$Coefficient %<>% as.numeric()
  p <- ggplot(all1 %>% filter(sample == "Medical states control"), 
              aes(x = Variable, y = Coefficient, color = type, linetype = type)) +
                geom_hline(yintercept = 0, 
                           colour = gray(1/2), lty = 2) +
                geom_linerange(aes(x = Variable,
                                   ymin = conf.low_95,
                                   ymax = conf.high_95),
                               lwd = .5,position = position_dodge(width = 0.2))  +
                geom_point(aes(x = Variable, 
                               y = Coefficient), size=1.5,
                           position = position_dodge(width = 0.2)) + 
                coord_flip()+
                #facet_grid( ~ sample )+
                theme_minimal()+   
                theme(legend.position = "bottom",#c(0.2, 0.1), 
                      legend.title = element_blank(),
                      strip.text = element_text(face = "bold", size = 10)) +
                scale_color_manual(values = c( "brown","darkgreen"), name = "Type", guide = "legend") +
                scale_linetype_manual(values = c("dashed", "solid"), name = "Type") +
                #scale_color_discrete(name="")+
                #scale_shape_discrete(name="")+
                xlab("")+
                ylab("Estimate (log points) and 95% Conf. Int.")+
                theme(panel.spacing = unit(1, "lines"))
  
  print(p)
  
  
  ggsave("../../figures/main/fig_5a_hetro_all_inst_type.eps", plot = p,width = 5.5,height = 4) 
 
  
  #=======
  #=======
  #=======
  

  did_est_table  <- function(treat_exclude){
    
    df_acd <- read_csv(main_data_path) %>% 
                  select(-adopt_law) %>% 
                  dplyr::rename(adopt_law=adopt_store)%>% 
                  filter(!STABBR %in% treat_exclude ) ## exclude late treated units
    
    df_acd$is_public <- ifelse(df_acd$CONTROL==1,1,0)
    lh_all="ln_EFTOTLT"
    
    
    rhs_law=c(
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
    
    did_reg <- function(df_acd){ 
      
      ## did using the academic sample
      model1a = feols(.[lh_all] ~  .[c("Associate",rhs_law) ] | 
                        UNITID +YEAR, cluster = c('STABBR') , 
                      data = df_acd %>% filter(HLOFFER%in%2:3&is_public==1) %>% 
                        dplyr::rename(Associate=adopt_law)
                      
      )
      model01a = summary(model1a, cluster = c('STABBR'))
      fit_cis_95 <- confint(model01a,level=0.95) %>% data.frame() %>% .[1,]
      btstrp1 <- boottest(model1a,clustid = c("STABBR"),param = "Associate",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR","UNITID"),fe ="UNITID")
      
      model1b = feols(.[lh_all] ~  .[ c("Bachelor",rhs_law) ] | 
                        UNITID +YEAR, cluster = c('STABBR') , 
                      data = df_acd %>% filter(HLOFFER%in%4:5&is_public==1)%>% 
                        dplyr::rename(Bachelor=adopt_law) )
      model01b = summary(model1b, cluster = c('STABBR'))
      fit_cis_95 <- rbind(fit_cis_95 ,confint(model01b,level=0.95) %>% data.frame() %>% .[1,])
      btstrp2 <- boottest(model1b,clustid = c("STABBR"),param = "Bachelor",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
      
      
      model1m = feols(.[lh_all] ~  .[  c("Master",rhs_law) ] | 
                        UNITID +YEAR, cluster = c('STABBR') , 
                      data = df_acd %>% filter(HLOFFER%%7&is_public==1)%>% 
                        dplyr::rename(Master=adopt_law) )
      model01m = summary(model1m, cluster = c('STABBR'))
      fit_cis_95 <- rbind(fit_cis_95 ,confint(model01m,level=0.95) %>% data.frame() %>% .[1,])
      btstrp3 <- boottest(model1m,clustid = c("STABBR"),param = "Master",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
      
      model2d <- feols(.[lh_all] ~  .[  c("Doctor",rhs_law) ] |
                         UNITID +YEAR, cluster = c('STABBR') 
                       , data = df_acd %>% filter(HLOFFER%in%9&is_public==1)%>% 
                         dplyr::rename(Doctor=adopt_law) )
      model02d = summary(model2d, cluster = c('STABBR'))
      fit_cis_95 <- rbind(fit_cis_95 ,confint(model02d,level=0.95) %>% data.frame() %>% .[1,]) 
      btstrp4 <- boottest(model2d,clustid = c("STABBR"),param = "Doctor",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
      

      ## did for public institutions
      model1p = feols(.[lh_all] ~  .[c("Public",rhs_law) ] | 
                        UNITID +YEAR, cluster = c('STABBR') , 
                      data = df_acd %>% filter(is_public==1) %>% 
                        dplyr::rename(Public=adopt_law))
      
      model01p = summary(model1p, cluster = c('STABBR'))
      fit_cis_95 <- rbind(fit_cis_95 ,confint(model01p,level=0.95) %>% data.frame() %>% .[1,]) 
      btstrp5 <- boottest(model1p,clustid = c("STABBR"),param = "Public",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
      
      
      ##  did for private institutions
      model1pv = feols(.[lh_all] ~  .[c("Private",rhs_law) ] | 
                         UNITID +YEAR, cluster = c('STABBR') , 
                       data = df_acd %>% filter(is_public==0) %>% 
                         dplyr::rename(Private=adopt_law))
      
      model01pv = summary(model1pv, cluster = c('STABBR'))
      fit_cis_95 <- rbind(fit_cis_95 ,confint(model01pv,level=0.95) %>% data.frame() %>% .[1,]) %>% 
        rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
      btstrp6 <- boottest(model1pv,clustid = c("STABBR"),param = "Private",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
      
      
      results <- modelsummary(model01a,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)") %>% 
        rbind(modelsummary(model01b,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
        rbind(modelsummary(model01m,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
        rbind(modelsummary(model02d,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
        rbind(modelsummary(model01p,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
        rbind(modelsummary(model01pv,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) 
        
        
      results2 <- bind_cols(results, fit_cis_95) %>% select(-statistic) 
      
      # Create a factor with the desired variable order
      results2$Variable <- c("Associate's","Bachelor's","Master's","Doctoral's","Public","Private")
      var_order <- c("Public","Private","Doctoral's","Master's","Bachelor's","Associate's")
      results2$Variable <- fct_relevel(factor(results2$Variable), var_order)
      
      results2$type <- "Cluster-robust CI"
      #=====
      
      results_bootstrap <- results2
      
      results_bootstrap$conf.low_95 <- c(btstrp1$conf_int[1],
                                         btstrp2$conf_int[1],
                                         btstrp3$conf_int[1],
                                         btstrp4$conf_int[1],
                                         btstrp5$conf_int[1],
                                         btstrp6$conf_int[1])
      
      results_bootstrap$conf.high_95 <- c( btstrp1$conf_int[2],
                                           btstrp2$conf_int[2],
                                           btstrp3$conf_int[2],
                                           btstrp4$conf_int[2],
                                           btstrp5$conf_int[2],
                                           btstrp6$conf_int[2])
      
      results_bootstrap$type <- "Wild bootstrap  CI"
      results2 <- rbind(results2,results_bootstrap) 
      
      return(results2)
      
    }
    
    all_states <- did_reg(df_acd)
    all_states$sample <- "All states control"
    
    ######## MEDICAL SAMPLE ################
    state_df <- tibble(States=state.name,STABBR = state.abb)
    
    df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
    tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
    mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
    medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st &!df_legal$STABBR %in% tr_st] %>% unique
    
    
    df <- read_csv(main_data_path)%>% 
      filter(STABBR %in% c(medical_control,tr_st))%>% 
      select(-adopt_law) %>% 
      dplyr::rename(adopt_law=adopt_store)%>% 
      filter(!STABBR %in% treat_exclude ) ## exclude late treated units
    
    df_acd=df
    df_acd$is_public <- ifelse(df_acd$CONTROL==1,1,0)
    
    med_states <- did_reg(df_acd)
    med_states$sample <- "Medical states control"
    
    all1 <- med_states %>% rbind(all_states) %>% filter(!Variable%in%c("Private","Public"))
    return(all1)
  }
  
  treat_exclude = c("CA","MA","NV","OR")
  all0 <- did_est_table(treat_exclude)
  all0$Treat_type <- "Early adopters\n (WA, CO)"
  
  treat_exclude = c("WA","CO")
  all1 <- did_est_table(treat_exclude)
  all1$Treat_type <- "Late adopters\n (CA ,MA ,NV , OR)"
  all1 <- all1 %>% rbind(all0)
  
  all1$Coefficient %<>% as.numeric()
  p <- ggplot(all1 %>% filter(sample == "Medical states control"), 
              aes(x = Variable, y = Coefficient, color = type, linetype = type)) +
              geom_hline(yintercept = 0, 
                         colour = gray(1/2), lty = 2) +
              geom_linerange(aes(x = Variable,
                                 ymin = conf.low_95,
                                 ymax = conf.high_95),
                             lwd = .5,position = position_dodge(width = 0.5))  +
              geom_point(aes(x = Variable, 
                             y = Coefficient), size=1.5,
                         position = position_dodge(width = 0.5)) + 
              coord_flip()+
              facet_grid( Treat_type~ .)+
              theme_minimal()+   
    theme(legend.position = "bottom",#c(0.2, 0.1), 
          legend.title = element_blank(),
          strip.text = element_text(face = "bold", size = 10)) +
    scale_color_manual(values = c( "brown","darkgreen"), name = "Type", guide = "legend") +
    scale_linetype_manual(values = c("dashed", "solid"), name = "Type") +
              xlab("")+ylab("Estimate (log points) and 95% Conf. Int.")+
    theme(panel.spacing = unit(1, "lines"))
  
  print(p)
  
  ggsave("../../figures/main/fig_5b_inst_type_public.eps", plot = p,width = 5.5,height = 4 ) 
  
