source("data-sources.R")

  df <- read_csv(main_data_path)
  
  non_bordering <- df %>% select(STABBR,FIPS) %>% unique %>% ## treated: "WA","OR","CO"
                          filter(!STABBR %in% c("AL","MI","CA","NV","MA","ME")) %>% #  exclude other treated states 
                          filter(!STABBR %in% c("AR","NM","OK","KS","NE","WY","UT","TX","ID","MT"))  # exclude contiguous states
                        
                        
  bordering <- df %>% select(STABBR,FIPS) %>% unique %>%
                   filter(STABBR %in% c("AR","NM","OK","KS","NE","WY","UT","TX","ID","MT",
                                         "WA","OR","CO"))  #contiguous states
  
  resid_df <- read_csv(out_enrol_path) %>% filter( YEAR %in% seq(2008,2018,2))
  
  #EFRES01:	First-time degree/certificate-seeking undergraduate students
  #EFRES02:	First-time degree/certificate-seeking undergraduate students who graduated from high school in the past 12 
  resid_df$EFRES02 <- resid_df$EFRES02 %>% as.numeric
  resid_df$EFRES01 <- resid_df$EFRES01 %>% as.numeric
  
  ## include enrollments from other states only
  out_state_enrol <-  resid_df %>% left_join(df) %>% filter(!EFCSTATE%in%FIPS) # not in-state enrollment

  
  out_state <- aggregate(cbind(EFRES01,EFRES02)~
                           YEAR+UNITID,
                         data = out_state_enrol,FUN = sum,na.rm=TRUE, na.action=NULL) %>% left_join(df)

  col1 <- c("EFRES01","EFRES02")
  
  for (i in col1) {
    out_state[[i]] <-  log(out_state[[i]]+.0001)
  }
  
  rhs_law=c(
    "adopt_MM_store", # change to "adopt_MM_law" for law RML
    
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
  
  nrhg="EFRES01"
  rhg="EFRES02"
  
  ########## inlcude only medical control
  ## main result
  state_df <- tibble(States=state.name,STABBR = state.abb )
  df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique
  
  ## med treated control 
  out_state_med <- out_state %>% filter(STABBR %in% c(medical_control,tr_st))
  
data_sub1 <- function (is_law1) {
    
    if(is_law1){
      
      contig <-   out_state %>% filter(STABBR %in% bordering$STABBR) %>% dplyr::rename(Contiguous = adopt_law)
      non_contig <- out_state %>%  filter(STABBR %in% non_bordering$STABBR)%>% dplyr::rename(Noncontiguous = adopt_law)
      all_df <- out_state %>% filter(STABBR %in% unique(c(bordering$STABBR,non_bordering$STABBR) ) ) %>% dplyr::rename(All = adopt_law)
      
    }else{
      
      contig <-   out_state %>% filter(STABBR %in% bordering$STABBR) %>% dplyr::rename(Contiguous = adopt_store)
      non_contig <- out_state %>%  filter(STABBR %in% non_bordering$STABBR)%>% dplyr::rename(Noncontiguous = adopt_store)
      all_df <- out_state %>% filter(STABBR %in% unique(c(bordering$STABBR,non_bordering$STABBR) ) ) %>% dplyr::rename(All = adopt_store)
    }
    
    return(list(all_df,contig,non_contig))
}

twfe_did1 <-   function () {

    model1 <- feols(.[nrhg] ~  .[c("All",rhs_law)] |UNITID+YEAR, cluster = "STABBR",data = all_df)
    fit_cis_90 <- confint(model1,level=0.95) %>% data.frame() %>% .[1,]
    model01 <- boottest(model1,clustid = c("STABBR"),param = "All",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    model2 <- feols(.[nrhg] ~   .[c("Contiguous",rhs_law) ] |UNITID+YEAR, cluster = "STABBR", data = contig)
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model2,level=0.95) %>% data.frame() %>% .[1,]) 
    model02 <- boottest(model2,clustid = c("STABBR"),param = "Contiguous",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    model3 <- feols(.[nrhg] ~   .[c("Noncontiguous",rhs_law)] |UNITID+YEAR, cluster = "STABBR",data = non_contig)
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model3,level=0.95) %>% data.frame() %>% .[1,]) 
    model03 <- boottest(model3,clustid = c("STABBR"),param = "Noncontiguous",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    model4 <- feols(.[rhg] ~  .[c("All",rhs_law)] | UNITID+YEAR, cluster = "STABBR",data = all_df)
    fit_cis_90 <- rbind(fit_cis_90,confint(model4,level=0.95) %>% data.frame() %>% .[1,])
    model04 <- boottest(model4,clustid = c("STABBR"),param = "All",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    model5 <- feols(.[rhg] ~   .[c("Contiguous",rhs_law) ] | UNITID+YEAR, cluster = "STABBR", data = contig)
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model5,level=0.95) %>% data.frame() %>% .[1,]) 
    model05 <- boottest(model5,clustid = c("STABBR"),param = "Contiguous",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    model6 <- feols(.[rhg] ~   .[c("Noncontiguous",rhs_law)] | UNITID+YEAR, cluster = "STABBR",data = non_contig)
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model6,level=0.95) %>% data.frame() %>% .[1,]) %>% 
      rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
    model06 <- boottest(model6,clustid = c("STABBR"),param = "Noncontiguous",B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    
    results <- modelsummary(model1,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")%>% 
                  rbind(modelsummary(model2,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                  rbind(modelsummary(model3,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                  rbind(modelsummary(model4,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                  rbind(modelsummary(model5,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                  rbind(modelsummary(model6,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)"))
                
    results2 <- bind_cols(results,fit_cis_90) %>% select(-statistic)
    results2$type <- "Cluster-robust CI"
    results2$outcome <- "Total enrollment"
    results2$outcome[4:6] <- "Recent high school\n graduates enrollment"
    
    results_bootstrap <- results2
    
    results_bootstrap$conf.low_95 <- c(model01$conf_int[1],
                                       model02$conf_int[1],
                                       model03$conf_int[1],
                                       model04$conf_int[1],
                                       model05$conf_int[1],
                                       model06$conf_int[1])
    
    results_bootstrap$conf.high_95 <- c( model01$conf_int[2],
                                         model02$conf_int[2],
                                         model03$conf_int[2],
                                         model04$conf_int[2],
                                         model05$conf_int[2],
                                         model06$conf_int[2])
    
    results_bootstrap$type <- "Wild bootstrap  CI"
    results_bootstrap$outcome <- "Total enrollment"
    results_bootstrap$outcome[4:6] <- "Recent high school\n graduates enrollment"
    
    results2 <- rbind(results2,results_bootstrap) %>% as.tibble()

    return(results2)
    
  }
  
# change F to T to get law based RML estimates
all_df <- data_sub1(F)[[1]]
contig <- data_sub1(F)[[2]]
non_contig <- data_sub1(F)[[3]]

merged_est <-   twfe_did1()
  
  merged_est$Variable <- rep(c("All","Contiguous","Noncontiguous"),4)
  merged_est$Variable <- fct_relevel(factor(merged_est$Variable), c("Noncontiguous","Contiguous","All" ))
  merged_est$Coefficient %<>% as.numeric() 
 

p <-  ggplot(merged_est, 
             aes(x = Variable, y = Coefficient, color = type, linetype = type)) +
                geom_hline(yintercept = 0, 
                           colour = gray(1/2), lty = 2) +
                geom_linerange(aes(x = Variable,
                                   ymin = conf.low_95,
                                   ymax = conf.high_95),
                               lwd = .5,position = position_dodge(width = 0.3))  +
                geom_point(aes(x = Variable, 
                               y = Coefficient), size=1.5,
                           position = position_dodge(width = 0.3)) + 
                coord_flip()+
                facet_grid(outcome ~ . )+
                theme_minimal()+   
                theme(legend.position = "none",strip.text = element_text(face = "bold",size=12))+
                theme(legend.position = "bottom",#c(0.2, 0.1), 
                      legend.title = element_blank(),
                      strip.text = element_text(face = "bold", size = 10)) +
                scale_color_manual(values = c( "brown","darkgreen"), name = "Type", guide = "legend") +
                xlab("")+ylab("Estimate (log points) and 95% Conf. Int.")+
                theme(panel.spacing = unit(2, "lines"))+
                scale_linetype_manual(values = c("dashed", "solid"), name = "Type") +
                theme(panel.spacing = unit(1, "lines"))

print(p)

ggsave("../../figures/main/fig_4_out_disp_did.eps", plot = p,width = 6,height = 5 )  

#==============================
# Use law based RML estimates
#==============================

# change F to T to get law based RML estimates
all_df <- data_sub1(T)[[1]]
contig <- data_sub1(T)[[2]]
non_contig <- data_sub1(T)[[3]]

merged_est <-   twfe_did1()

merged_est$Variable <- rep(c("All" ,"Contiguous", "Noncontiguous"),4)
merged_est$Variable <- fct_relevel(factor(merged_est$Variable), c("Noncontiguous","Contiguous","All" ))
merged_est$Coefficient %<>% as.numeric()


p <-  ggplot(merged_est,
             aes(x = Variable, y = Coefficient, color = type, linetype = type)) +
  geom_hline(yintercept = 0,
             colour = gray(1/2), lty = 2) +
  geom_linerange(aes(x = Variable,
                     ymin = conf.low_95,
                     ymax = conf.high_95),
                 lwd = .5,position = position_dodge(width = 0.3))  +
  geom_point(aes(x = Variable,
                 y = Coefficient), size=1.5,
             position = position_dodge(width = 0.3)) +
  coord_flip()+
  facet_grid(outcome ~ . )+
  theme_minimal()+
  theme(legend.position = "none",strip.text = element_text(face = "bold",size=12))+
  theme(legend.position = "bottom",#c(0.2, 0.1),
        legend.title = element_blank(),
        strip.text = element_text(face = "bold", size = 10)) +
  scale_color_manual(values = c( "brown","darkgreen"), name = "Type", guide = "legend") +
  xlab("")+ylab("Estimate (log points) and 95% Conf. Int.")+
  theme(panel.spacing = unit(2, "lines"))+
  scale_linetype_manual(values = c("dashed", "solid"), name = "Type") +
  theme(panel.spacing = unit(1, "lines"))

print(p)


ggsave("../../figures/appendix/fig_a10_disp_out_did.eps", plot = p,width = 6,height = 5 )


