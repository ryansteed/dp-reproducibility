source("data-sources.R")

#==============================================
# Figure 5: Goodman-Bacon Decomposition
#==============================================

GoodmanBacon <- function(){
  
  df <- read_csv(main_data_path) %>% 
    select(UNITID, YEAR,FIPS,adopt_law,adopt_MM_law,CARNEGIE,CONTROL,COUNTYCD,
           ln_EFTOTLT,ln_EFTOTLW,ln_EFTOTLM,adopt_store,adopt_MM_store,
           is_medical,is_large_inst,ln_STUFACR,ln_NETMIG,
           ROTC,DIST,ln_AGE1824_TOT,ln_AGE1824_FEM_SHARE,
           ln_per_capita_income,ln_unemply_rate,
           
    ) %>%  na.omit #%>% filter(!UNITID %in% excl2$UNITID )
  
  
  ##### using states that legalized marijuana for medical use as a control group
  state_df <- tibble(States=state.name,STABBR = state.abb )
  
  df_legal <- read_csv(leg_path) %>% 
    left_join(state_df) %>% filter(STABBR!="DC")
  
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  
  never_treated_control <- df_legal$STABBR[!df_legal$STABBR %in% mari_st] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & 
                                       !df_legal$STABBR %in% tr_st] %>% unique
  
  
  df_med <- read_csv(main_data_path) %>% 
    select(UNITID,STABBR, YEAR,FIPS,adopt_law,adopt_MM_law,CARNEGIE,CONTROL,
           ln_EFTOTLT,ln_EFTOTLW,ln_EFTOTLM,adopt_store,adopt_MM_store,
           is_medical,is_large_inst,ln_STUFACR,ln_NETMIG,
           ROTC,DIST,ln_AGE1824_TOT,ln_AGE1824_FEM_SHARE,
           ln_per_capita_income,ln_unemply_rate,
    ) %>%  na.omit %>%  filter(STABBR %in% c(medical_control,tr_st)) %>% select(-STABBR)
  
  
  #sample_name: character names of the sample (all states, or medical)
  bacon_decom <- function(df,sample_name){
    ## all enrollments
    df$YEAR <- df$YEAR %>% as.integer
    df$UNITID <- df$UNITID %>% as.character()
    
    
    ret_bacon <- bacon(ln_EFTOTLT ~ 
                         adopt_law +adopt_MM_law+
                         is_medical+
                         is_large_inst+
                         ln_STUFACR+
                         ROTC+
                         DIST+
                         ln_AGE1824_TOT+
                         ln_AGE1824_FEM_SHARE+
                         ln_per_capita_income+
                         ln_unemply_rate+
                         ln_NETMIG,
                       data = df,
                       id_var = "FIPS",
                       time_var = "YEAR")
    
    beta_hat_w <- ret_bacon$beta_hat_w
    beta_hat_b <- weighted.mean(ret_bacon$two_by_twos$estimate, 
                                ret_bacon$two_by_twos$weight)
    Omega <- ret_bacon$Omega
    bacon_coef_cont <- Omega*beta_hat_w + (1 - Omega)*beta_hat_b
    print(paste("Weighted sum of decomposition =", round(bacon_coef_cont, 4)))
    
    
    ret_bacon$two_by_twos$law <- "Dispensary not open"
    
    decom_est <- data_frame(
      weight =  0.4,
      estimate =  0.4,
      decomp = paste("Weighted sum of decomposition =", round(bacon_coef_cont, 4)),
      sample=sample_name,
      law= "Dispensary not open"
    )
    
    ##===============================
    ### Use now the store opening RML
    ##===============================
    
    ## all enrollments
    ret_bacons <- bacon(ln_EFTOTLT ~  
                          adopt_store +adopt_MM_store+
                          is_medical+
                          is_large_inst+
                          ln_STUFACR+
                          ROTC+
                          DIST+
                          ln_AGE1824_TOT+
                          ln_AGE1824_FEM_SHARE+
                          ln_per_capita_income+
                          ln_unemply_rate+
                          ln_NETMIG,
                        data = df,
                        id_var = "FIPS",
                        time_var = "YEAR")
    
    beta_hat_w <- ret_bacons$beta_hat_w
    beta_hat_b <- weighted.mean(ret_bacons$two_by_twos$estimate, 
                                ret_bacons$two_by_twos$weight)
    Omega <- ret_bacons$Omega
    bacon_coef_cont <- Omega*beta_hat_w + (1 - Omega)*beta_hat_b
    
    
    print(paste("Weighted sum of decomposition =", round(bacon_coef_cont, 4)))
    ret_bacons$two_by_two$law <- "Dispensary open"
    
    
    decom_est2 <- data_frame(
      weight =  0.4,
      estimate =  0.4,
      decomp = paste("Weighted sum of decomposition =", round(bacon_coef_cont, 4)),
      sample=sample_name,
      law= "Dispensary open"
    )
    
    est_bacon <- rbind(decom_est2,decom_est)
    bacon <- ret_bacons$two_by_two %>% rbind(ret_bacon$two_by_two) %>% as.tibble()
    bacon$sample <- sample_name
    
    return(list(bacon,est_bacon))
    
  }
  
  
  leg_law <- data_frame(
    state_law = c("WA & CO",  "OR", "CA & MA", "NV"),
    treated = c(2012,   2015,  2016,  2017) ,
    type="Treated vs Untreated"
    
  )
  leg_law$treated <- leg_law$treated %>% as.numeric
  
  leg_store <- data_frame(
    state_store = c("WA & CO", "CA, MA & NV","OR"),
    treated= c(2014,2018,2016) ,
    type="Treated vs Untreated"
  )
  
  leg_store$treated <- leg_store$treated %>% as.numeric
  
  bac1 <- bacon_decom(df ,"All states control")
  bac2 <- bacon_decom(df_med,"Medical states control")
  
  bacon <- bac1[[1]] %>% rbind(bac2[[1]]) %>%  left_join(leg_law)%>% left_join(leg_store)
  
  bac_est_labels <- bac1[[2]] %>% rbind(bac2[[2]]) %>% as_data_frame()
  bac_est_labels$type <- "Both Treated"
  
  bacon$law %>% unique
  bacon$sample %>% unique
  
  dff1=as_data_frame(bacon)%>% filter(
    sample == "Medical states control"&
      law == "Dispensary open"
  ) 
  
  bac_est_labels2= bac_est_labels%>% filter(
    sample == "Medical states control"&
      law == "Dispensary open"
  ) 
  
  p1 <- ggplot(dff1)+
    aes(x = weight, y = estimate, shape = factor(type)) +
    labs(x = "Weight", y = "Estimate (log points)") +
    geom_point()+
    theme_minimal()+
    theme(legend.position = c(.86,.08),
          legend.title=element_blank(),panel.spacing = unit(2, "lines"),
          strip.text = element_text(face = "bold",size=12)
    ) +
    geom_text(aes(weight,estimate,label = decomp,fontface=2),
              data=bac_est_labels2,vjust = 4,
              hjust = .4,size=2,color="darkgreen")+
    geom_text(aes(label = state_store,fontface=2),
              data=dff1,vjust = -1,hjust = .8,size=2,color="darkgreen")
  
  print(p1)
  
  ggsave("../../figures/appendix/fig_A6_bacon_decom.eps", plot = p1,width = 7,height = 5 )  
  
  
  
}
GoodmanBacon()