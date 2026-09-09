# Note: the computation of distance between each college and the nearest 
# treated border may take up to 30 minutes (adjust for parallel computing)

source("data-sources.R")

  state_df <- tibble(States=state.name, STABBR = state.abb)
  df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC") 
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st &!df_legal$STABBR %in% tr_st] %>% unique
  
  
# This function computes the distance of each coordinates from a given state border
# Define the latitude and longitude coordinates
#### rename the latitude and longitude variables to lat and long respectively
dist_to_border <- function(df,treated_state){
    # Get the polygon of Colorado/any treated state
    colorado <- ne_states(returnclass = "sf") %>% 
      filter(name == treated_state)
    
    # Extract the longitude and latitude coordinates of the polygon
    colorado_coords <- st_coordinates(colorado)
    
    # Convert the coordinates to a matrix
    coords <- cbind(df$lon, df$lat)
    
    # Compute the distance between the coordinates and the border of Colorado
    dist <- dist2Line(p = coords, line = colorado_coords[,1:2])
    
    df[[paste0("distance_",treated_state)]] <- dist[,1]/ 1609.344 ## convert meters to miles
    
    # Compute the minimum and maximum values
    min_val <- min(df[[paste0("distance_",treated_state)]])
    max_val <- max(df[[paste0("distance_",treated_state)]])
    
    # Standardize the values to be between 0 and 1
    df[[paste0("distance_",treated_state,"_std")]] <- (df[[paste0("distance_",treated_state)]] - min_val) / (max_val - min_val)
    
    
    return(df)
    
  }
  
## all treat units are assigned distance of 50000
dist_to_nearest_treat <- function(df_acd){
    
    df <- df_acd %>% dist_to_border(.,"Colorado") %>% 
      dist_to_border(.,"Washington") %>% 
      dist_to_border(.,"Oregon") %>% 
      dist_to_border(.,"Nevada") %>% 
      dist_to_border(.,"California") %>% 
      dist_to_border(.,"Massachusetts")
    
    # Compute the minimum distance for each row
    # i.e. each institution is assigned distance to the closest treated state.
    df$min_dist <- rowMins(as.matrix(df %>% select(distance_Colorado,
                                                   distance_Washington,
                                                   distance_Oregon,
                                                   distance_Nevada,
                                                   distance_California,
                                                   distance_Massachusetts
    )))
    
    ## correct the distance for the treated states
    ## keep the original dist. 
    df$min_dist[df$STABBR == "CO"] <- df$distance_Colorado[df$STABBR == "CO"]
    df$min_dist[df$STABBR == "WA"] <- df$distance_Washington[df$STABBR == "WA"]
    
    df$min_dist[df$STABBR == "OR"] <- df$distance_Oregon[df$STABBR == "OR"]
    df$min_dist[df$STABBR == "NV"] <- df$distance_Nevada[df$STABBR == "NV"]
    
    df$min_dist[df$STABBR == "CA"] <- df$distance_California[df$STABBR == "CA"]
    df$min_dist[df$STABBR == "MA"] <- df$distance_Massachusetts[df$STABBR == "MA"]
    
    
    ## keep the treated units by assigning large distance 
    df$min_dist2 <- df$min_dist
    df$min_dist2[df$STABBR %in% c( "CO", "WA", "OR", "CA", "MA", "NV")] <- 50000
    
    return(df)
  }


df_all <- read_csv(main_data_path) %>% 
              filter(STABBR %in% c(medical_control,tr_st)) %>% 
              dplyr::rename(lat=LATITUDE,lon=LONGITUD) %>%
              dist_to_nearest_treat
  
# This function runs DiD and Wild bootstrap p, 
# returns and saves latex tables
did_reg <- function(df,lh_all,rhs_law){
    
    model1 = feols(.[lh_all] ~  .[ rhs_law ]| UNITID+YEAR, cluster = "STABBR",data = df  %>% filter(!min_dist2<=10))
    model01 <- boottest(model1,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- confint(model1,level=0.95) %>% data.frame() %>% .[1,]
 
    model2 <- feols(.[lh_all] ~  .[ rhs_law ] | UNITID+YEAR, cluster = "STABBR", data =   df%>% filter(!min_dist2<20 ))
    model02 <- boottest(model2,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model2,level=0.95) %>% data.frame() %>% .[1,]) 
    
    model3 <- feols(.[lh_all] ~  .[rhs_law ] | UNITID+YEAR, cluster = "STABBR" , data =  df%>% filter(!min_dist2<30 ))
    model03 <- boottest(model3,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen", bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model3,level=0.95) %>% data.frame() %>% .[1,]) 

    model4 <- feols(.[lh_all] ~   .[rhs_law ] | UNITID+YEAR, cluster = "STABBR", data =  df%>% filter(!min_dist2<40 ))
    model04 <- boottest(model4,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model4,level=0.95) %>% data.frame() %>% .[1,]) 
    
    model5 <- feols(.[lh_all] ~   .[rhs_law ]  | UNITID+YEAR, cluster = "STABBR" , data =  df%>% filter(!min_dist2<50 ))
    model05 <- boottest(model5,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model5,level=0.95) %>% data.frame() %>% .[1,]) 
    
    model6 <- feols(.[lh_all] ~   .[rhs_law ] | UNITID+YEAR, cluster = "STABBR" , data =  df%>% filter(!min_dist2<60 ))
    model06 <- boottest(model6,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model6,level=0.95) %>% data.frame() %>% .[1,]) 

    model7 <- feols(.[lh_all] ~   .[rhs_law] | UNITID+YEAR, cluster = "STABBR", data =  df%>% filter(!min_dist2<70 ))
    model07 <- boottest(model7,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model7,level=0.95) %>% data.frame() %>% .[1,]) 
    
    model8 <- feols(.[lh_all] ~   .[rhs_law] | UNITID+YEAR, cluster = "STABBR", data =  df%>% filter(!min_dist2<80 ))
    model08 <- boottest(model8,clustid = c("STABBR"),param = rhs_law[1],B = 9999,type = "mammen",bootcluster = c("STABBR","YEAR"),fe ="UNITID")
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model8,level=0.95) %>% data.frame() %>% .[1,])%>% 
      dplyr::rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..") 
    
    
    ## results for plot
    results <- modelsummary(model1,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")%>% 
                rbind(modelsummary(model2,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                rbind(modelsummary(model3,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                rbind(modelsummary(model4,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                rbind(modelsummary(model5,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                rbind(modelsummary(model6,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                rbind(modelsummary(model7,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) %>% 
                rbind(modelsummary(model8,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1,3:4] %>% dplyr::rename("Coefficient"="(1)")) 
    
    results2 <- bind_cols(results, fit_cis_90) %>% select(-statistic)
    
    results2$miles <- seq(10,80,10)
    results2$type <- "Cluster-robust CI"
    
    results_bootstrap <- results2
    
    results_bootstrap$conf.low_95 <- c(model01$conf_int[1],
                                       model02$conf_int[1],
                                       model03$conf_int[1],
                                       model04$conf_int[1],
                                       model05$conf_int[1],
                                       model06$conf_int[1],
                                       model07$conf_int[1],
                                       model08$conf_int[1])
    
    results_bootstrap$conf.high_95 <- c( model01$conf_int[2],
                                         model02$conf_int[2],
                                         model03$conf_int[2],
                                         model04$conf_int[2],
                                         model05$conf_int[2],
                                         model06$conf_int[2],
                                         model07$conf_int[2],
                                         model08$conf_int[2])
    
    results_bootstrap$type <- "Wild bootstrap  CI"
    

    results2 <- rbind(results2,results_bootstrap) 
    
    
    
    # get the number of colleges and pre-shock treated units mean
    num_inst <- function(n1){
      df <-  df %>% filter(!min_dist2<n1 )
      num_treat <- df$UNITID[df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length
      num_contr <- df$UNITID[!df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length 
      num1 <- as.character(num_treat+num_contr) 
      return(num1)
    }
    pre_mean <- function(){
      
      if(lh_all== "ln_EFTOTLW"){
        treated_states <- df$STABBR[df$adopt_law==1] %>% unique
        pre_all <- df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
      }
      
      if(lh_all== "ln_EFTOTLM"){
        treated_states <- df$STABBR[df$adopt_law==1] %>% unique
        pre_all <- (df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round - 
                      df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round) %>% as.character
      }
      
      
      if(lh_all=="ln_EFTOTLT"){
        treated_states <- df$STABBR[df$adopt_law==1] %>% unique
        pre_all <- df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
      }
      
      
      return(pre_all)
    }
    
    rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6",~"Model 7", ~"Model 8", 
                    
                    # "Wild bootstrap p (subcluster)", p_val_boot[1], p_val_boot[2],p_val_boot[3], p_val_boot[4],p_val_boot[5],p_val_boot[6], p_val_boot[7],p_val_boot[8],
                    # "Wild bootstrap p", p_val_boot2[1], p_val_boot2[2],p_val_boot2[3], p_val_boot2[4],p_val_boot2[5],p_val_boot2[6], p_val_boot2[7],p_val_boot2[8],
                     
                    "N college", num_inst(10), num_inst(20),num_inst(30), num_inst(40),num_inst(50),num_inst(60), num_inst(70),num_inst(80),
                    "Pre-RML mean enrollment", pre_mean(), pre_mean(),pre_mean(), pre_mean(),pre_mean(),pre_mean(), pre_mean(),pre_mean(),
                    "Controls",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "Year FE",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "College FE",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "# of miles removed from the sample", "10","20","30", "40","50","60",  "70","80",
    )
    
    f <- function(x) format(round(x, 3), big.mark=",")
    
    gm <- tibble::tribble(
      ~raw,        ~clean,          ~fmt,
      "nobs",      "N Obs.",             0,
      "r2.conditional", paste0("Conditional","R2"), 2,
      "adj.r.squared", paste0("Adjusted ","R2"), 2,
      "r2.within.adjusted", paste0("Adjusted within ","R2"), 2)
    
    models = list("(1)" = model1,
                  "(2)" = model2,
                  "(3)" = model3,
                  "(4)" = model4,
                  "(5)" = model5,
                  "(6)" = model6,
                  "(7)" = model7,
                  "(8)" = model8)
    
    
    var_names <- c('adopt_law' = 'RM','adopt_store' = 'RM' )

    note1 = "add note here"
    
    modelsummary( models,
                  stars = c('*+' = .1,'*' = .05, '**' = .01,'***' = .001),
                  output = 'latex',
                  coef_map = var_names,
                  gof_map = gm,
                  add_rows=rows
    ) %>%
      footnote(general = note1, threeparttable = TRUE) %>%
      #save_kable(file = paste0("../../tables/main/",file_name,".tex")) %>% print
    
    return(results2)
    
  }

lh_all="ln_EFTOTLT"  
rhs_law <- c("adopt_law","adopt_MM_law",
             
             "is_medical",
             "is_large_inst",
             "ln_STUFACR",
             "ROTC",
             "DIST",
             
             "ln_AGE1824_TOT",
             "ln_AGE1824_FEM_SHARE",
             "ln_per_capita_income",
             "ln_unemply_rate",
             "ln_NETMIG")

df=df_all
did_all <- did_reg(df,lh_all,rhs_law)
did_all$sample <- "All institutions"

df$pub_non_research <- ifelse(df$CONTROL%in%1&df$HLOFFER%in%c(3,5),1,0)
df$adopt_law2 <- df$adopt_law
df$adopt_law <- df$pub_non_research*df$adopt_law

  rhs_law=c(
    "adopt_law",
    "pub_non_research",
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
    "ln_NETMIG")

did_all2 <- did_reg(df,lh_all,rhs_law)
did_all2$sample <- "Public non-research"
  
did_results2 <- rbind(did_all,did_all2) %>% mutate(Coefficient=as.numeric(Coefficient))

  p <- ggplot(did_results2, 
              aes(x = miles, y = Coefficient, color = type, linetype = type)) +
              geom_hline(yintercept = 0, color = "gray50", linetype = 2) +
              geom_linerange(aes(x = miles, ymin = conf.low_95, ymax = conf.high_95), 
                             size = 0.5, position = position_dodge(width = 3)) +
              geom_point(aes(x = miles, y = Coefficient),shape="triangle", size = 1.5,
                         position = position_dodge(width = 3)) +
              facet_grid(sample ~ . , scales = "free") +
              theme_minimal() +
              theme(legend.position = "bottom",#c(0.2, 0.1), 
                    legend.title = element_blank(),
                    strip.text = element_text(face = "bold", size = 12)) +
              scale_color_manual(values = c( "brown","darkgreen"), name = "Type", guide = "legend") +
              scale_linetype_manual(values = c("dashed", "solid"), name = "Type") +
              scale_x_continuous(breaks = seq(10, 80, 10)) +
              xlab("Miles removed") +
              ylab("Estimate (log points) and 95% Conf. Int.")  +
              theme(panel.spacing = unit(2, "lines"))
  
  print(p)
  
ggsave(file="../../figures/main/fig_6_spillover.eps",width=5,height=6)  

#---------------
## TABLE A9
#---------------
  ## main result
  state_df <- tibble(States=state.name, STABBR = state.abb)
  
  df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC") 
  
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  
  never_treated_control <- df_legal$STABBR[!df_legal$STABBR %in% mari_st] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & 
                                       !df_legal$STABBR %in% tr_st] %>% unique
  
  
  ## this function computes the distance of each coordinates from a given state border
  # # Define the latitude and longitude coordinates
  #### rename the latitude and longitude variables to lat and long respectively
  dist_to_border <- function(df,treated_state){
    # Get the polygon of Colorado/any treated state
    colorado <- ne_states(returnclass = "sf") %>% 
      filter(name == treated_state)
    
    # Extract the longitude and latitude coordinates of the polygon
    colorado_coords <- st_coordinates(colorado)
    
    # Convert the coordinates to a matrix
    coords <- cbind(df$lon, df$lat)
    
    # Compute the distance between the coordinates and the border of Colorado
    #dist <- dist2Line(p = c(lon, lat), line = colorado_coords[,1:2])
    dist <- dist2Line(p = coords, line = colorado_coords[,1:2])
    
    # Print the distance in kilometers
    #print(paste0("Distance to Colorado border: ", round(dist/1000, 2), " km"))
    
    df[[paste0("distance_",treated_state)]] <- dist[,1]/ 1609.344 ## convert meters to miles
    
    # Compute the minimum and maximum values
    min_val <- min(df[[paste0("distance_",treated_state)]])
    max_val <- max(df[[paste0("distance_",treated_state)]])
    
    # Standardize the values to be between 0 and 1
    df[[paste0("distance_",treated_state,"_std")]] <- (df[[paste0("distance_",treated_state)]] - min_val) / (max_val - min_val)
    
    
    return(df)
    
  }
  
  ## all treat units are assigned distance of 50000
  dist_to_nearest_treat <- function(df_acd){
    
    df <- df_acd %>% dist_to_border(.,"Colorado") %>% 
      dist_to_border(.,"Washington") %>% 
      dist_to_border(.,"Oregon") %>% 
      dist_to_border(.,"Nevada") %>% 
      dist_to_border(.,"California") %>% 
      dist_to_border(.,"Massachusetts")
    
    # Compute the minimum distance for each row
    # i.e. each institution is assigned distance to the closest treated state.
    df$min_dist <- rowMins(as.matrix(df %>% select(distance_Colorado,
                                                   distance_Washington,
                                                   distance_Oregon,
                                                   distance_Nevada,
                                                   distance_California,
                                                   distance_Massachusetts
    )))
    
    ## correct the distance for the treated states
    ## keep the original dist. 
    df$min_dist[df$STABBR == "CO"] <- df$distance_Colorado[df$STABBR == "CO"]
    df$min_dist[df$STABBR == "WA"] <- df$distance_Washington[df$STABBR == "WA"]
    
    df$min_dist[df$STABBR == "OR"] <- df$distance_Oregon[df$STABBR == "OR"]
    df$min_dist[df$STABBR == "NV"] <- df$distance_Nevada[df$STABBR == "NV"]
    
    df$min_dist[df$STABBR == "CA"] <- df$distance_California[df$STABBR == "CA"]
    df$min_dist[df$STABBR == "MA"] <- df$distance_Massachusetts[df$STABBR == "MA"]
    
    
    ## keep the treated units by assigning large distance 
    df$min_dist2 <- df$min_dist
    df$min_dist2[df$STABBR %in% c( "CO", "WA", "OR", "CA", "MA", "NV")] <- 50000
    
    return(df)
  }
  
  #df %<>% filter(STABBR %in% bordering$STABBR)
  
  ## public non-research institutions   
  df_public <- read_csv(main_data_path) %>% 
    filter(STABBR %in% c(medical_control,tr_st))%>% 
    dplyr::rename(lat=LATITUDE,lon=LONGITUD)%>% 
    filter(CONTROL==1) %>% filter(HLOFFER%in%c(3,5)) %>% dist_to_nearest_treat
  
  ## all academic instituions
  df_all <- read_csv(main_data_path) %>% 
    filter(STABBR %in% c(medical_control,tr_st))%>% 
    dplyr::rename(lat=LATITUDE,lon=LONGITUD) %>% dist_to_nearest_treat
  
  
  rhs_law=c(
    "adopt_law","adopt_MM_law",
    
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
    "adopt_store","adopt_MM_store",
    
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
  
  
lh_all="ln_EFTOTLT"
  
## runs DiD returns and saves latex tables
did_reg <- function(df,lh_all,rhs_law,file_name){
    
    
    model1 = feols(.[lh_all] ~  .[ rhs_law ]|
                     UNITID  + YEAR, cluster = "STABBR"  ,
                   data = df  %>% filter(!min_dist2<=10))
    model01 = summary(model1, cluster = c('UNITID'))
    
    fit_cis_90 <- confint(model01,level=0.95) %>% data.frame() %>% .[1,]
    
    
    model2 <- feols(.[lh_all] ~  .[ rhs_law ] |
                      UNITID  + YEAR, cluster = "STABBR"  
                    , data =   df%>% filter(!min_dist2<20 ))
    model02 = summary(model2, cluster = c('UNITID'))
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model02,level=0.95) %>% data.frame() %>% .[1,]) 
    
    
    model3 <- feols(.[lh_all] ~  .[rhs_law ] |
                      UNITID  + YEAR, cluster = "STABBR"  
                    , data =  df%>% filter(!min_dist2<30 ))
    model03 = summary(model3, cluster = c('UNITID'))
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model03,level=0.95) %>% data.frame() %>% .[1,]) 
    
    
    #-------------------------------------------------------
    #-------------------------------------------------------
    model4 <- feols(.[lh_all] ~   .[rhs_law ] |
                      UNITID  + YEAR, cluster = "STABBR"   
                    , data =  df%>% filter(!min_dist2<40 ))
    model04 = summary(model4, cluster = c('UNITID'))
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model04,level=0.95) %>% data.frame() %>% .[1,]) 
    
    
    model5 <- feols(.[lh_all] ~   .[rhs_law ]  |
                      UNITID  + YEAR, cluster = "STABBR"  
                    , data =  df%>% filter(!min_dist2<50 ))
    model05 = summary(model5, cluster = c('UNITID'))
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model05,level=0.95) %>% data.frame() %>% .[1,]) 
    
    
    model6 <- feols(.[lh_all] ~   .[rhs_law ] |
                      UNITID   + YEAR, cluster = "STABBR"   
                    , data =  df%>% filter(!min_dist2<60 ))
    model06 = summary(model6, cluster = c('UNITID'))
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model06,level=0.95) %>% data.frame() %>% .[1,]) 
    
    #-------------------------------------------------------
    #-------------------------------------------------------
    
    model7 <- feols(.[lh_all] ~   .[rhs_law] |
                      UNITID  + YEAR , cluster = "STABBR" 
                    , data =  df%>% filter(!min_dist2<70 ))
    model07 = summary(model7, cluster = c('UNITID'))
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model07,level=0.95) %>% data.frame() %>% .[1,]) 
    
    
    model8 <- feols(.[lh_all] ~   .[rhs_law] |
                      UNITID  + YEAR , cluster = "STABBR" 
                    , data =  df%>% filter(!min_dist2<80 ))
    model08 = summary(model8, cluster = c('UNITID'))
    fit_cis_90 <- rbind(fit_cis_90 ,confint(model08,level=0.95) %>% data.frame() %>% .[1,])%>% 
      dplyr::rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..") 
    
    
    ## results for plot
    results <- tidy(model01)[1,]%>% 
      rbind(tidy(model02)[1,]) %>% 
      rbind(tidy(model03)[1,]) %>% 
      rbind(tidy(model04)[1,]) %>% 
      rbind(tidy(model05)[1,]) %>% 
      rbind(tidy(model06)[1,]) %>% 
      rbind(tidy(model07)[1,]) %>% 
      rbind(tidy(model08)[1,]) 
    
    results2 <- bind_cols(results, 
                          fit_cis_90) %>% select(-std.error, 
                                                 -statistic,
                                                 -p.value) %>% 
      dplyr::rename(Variable = term, Coefficient = estimate)
    
    results2$miles <- seq(10,80,10)
    
    #=== regression table
    #--------------------------------
    
    # get the number of colleges and pre-shock treated units mean
    num_inst <- function(n1){
      df <-  df %>% filter(!min_dist2<n1 )
      num_treat <- df$UNITID[df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length
      num_contr <- df$UNITID[!df$FIPS %in% unique(df$FIPS[df$adopt_law==1])] %>% unique %>% length 
      num1 <- as.character(num_treat+num_contr) 
      return(num1)
    }
    pre_mean <- function(){
      
      if(lh_all== "ln_EFTOTLW"){
        treated_states <- df$STABBR[df$adopt_law==1] %>% unique
        pre_all <- df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
      }
      
      if(lh_all== "ln_EFTOTLM"){
        treated_states <- df$STABBR[df$adopt_law==1] %>% unique
        pre_all <- (df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round - 
                      df$EFTOTLW[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T)%>% round) %>% as.character
      }
      
      
      if(lh_all=="ln_EFTOTLT"){
        treated_states <- df$STABBR[df$adopt_law==1] %>% unique
        pre_all <- df$EFTOTLT[df$adopt_law==0 & df$STABBR %in% treated_states] %>% mean(na.rm=T) %>% round %>% as.character
      }
      
      
      return(pre_all)
    }
    
    rows <- tribble(~"Coefficients", ~"Model 1",  ~"Model 2",~"Model 3",~"Model 4",~"Model 5",~"Model 6",~"Model 7", ~"Model 8", 
                    
                    "N college", num_inst(10), num_inst(20),num_inst(30), num_inst(40),num_inst(50),num_inst(60), num_inst(70),num_inst(80),
                    "Pre-RML mean enrollment", pre_mean(), pre_mean(),pre_mean(), pre_mean(),pre_mean(),pre_mean(), pre_mean(),pre_mean(),
                    "Controls",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "Year FE",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "College FE",    "Y","Y","Y",  "Y","Y","Y",  "Y","Y",
                    "# of miles removed from the sample", "10","20","30", "40","50","60",  "70","80",
    )
    
    f <- function(x) format(round(x, 3), big.mark=",")
    
    gm <- tibble::tribble(
      ~raw,        ~clean,          ~fmt,
      "nobs",      "N Obs.",             0,
      "r2.conditional", paste0("Conditional","R2"), 2,
      "adj.r.squared", paste0("Adjusted ","R2"), 2,
      "r2.within.adjusted", paste0("Adjusted within ","R2"), 2
      
    )
    
    #----------------------------------------------------------------
    
    models = list(
      "(1)" = model01,
      "(2)" = model02,
      "(3)" = model03,
      "(4)" = model04,
      "(5)" = model05,
      "(6)" = model06,
      "(7)" = model07,
      "(8)" = model08
    )
    
    
    var_names <- c(
      'adopt_law' = 'RM',
      'adopt_store' = 'RM' 
    )
    
    
    note1 = "add note here"
    modelsummary( models,
                  stars = c('*' = .05, '**' = .01,'***' = .001),
                  output = 'latex',
                  coef_map = var_names,
                  gof_map = gm,
                  add_rows=rows
    ) %>%
      footnote(general = note1, threeparttable = TRUE) %>%
      save_kable(file = paste0("../../tables/appendix/",file_name,".tex")) %>% print
    
    return(results2)
    
  }
  
  
did_reg(df_all,lh_all,rhs_store,file_name="fig_9a_a_spillover_all")
did_reg(df_public,lh_all,rhs_store,file_name="fig_9a_b_spillover_pub_nres")




