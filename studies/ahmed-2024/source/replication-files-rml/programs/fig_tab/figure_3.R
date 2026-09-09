#==============================================
# Figure 3: Event Study Graph of RML Treatment
#==============================================
source("data-sources.R")

## this function run the twfe did and Sun and Abraham event study
## returns a table with coefficients and confidence intervals (0.9)

# lhs: is the left hand side of the event study regression 
# #lhs <- "ln_EFTOTLT"  
dynamic_did <- function(data1,sample_name,outcome_name,lhs){
  library(data.table)
  
  data1$time <- data1$YEAR %>% as.numeric()
  treat_state <- data1$STABBR[data1$adopt_law==1] %>% unique
  data1$treat <- ifelse(data1$STABBR %in% treat_state,1,0)
  
  ## first year of RML
  data1$`_nfd` <- NA  ## need this for event study
  
  for (j in treat_state) {
    st1 <- j
    yr1 <- data1$YEAR[data1$STABBR == st1 & data1$adopt_law==1] %>% min 
    data1$`_nfd`[data1$STABBR == st1  ] <- yr1
  }
  
  data1$year <- data1$YEAR %>% as.numeric()
  
  data1 <- data1 %>% data.table
  
  ## treatment dummy
  data1[, treat := ifelse(is.na(`_nfd`), 0, 1)]
  
  ## number of years since first treated
  data1[, time_to_treat := ifelse(treat==1, year - `_nfd`, 0)] 
  
  # Following Sun and Abraham, we give our never-treated units a fake "treatment"
  # date far outside the relevant study period.
  data1[, year_treated := ifelse(treat==0, 10000, `_nfd`)]
  
  
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
mod_sa0 = feols(.[lhs] ~ sunab(year_treated, year)| UNITID + YEAR ,
                 cluster = ~ STABBR,
                 data = data1[abs(data1$time_to_treat)<num_per,])

## get the estimates and the confidence intervals values
fit_cis <- confint(mod_sa0,level=0.95) %>% data.frame() %>% .[1:10,]

est_sun0 <- modelsummary(mod_sa0,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
est_sun0$method <- "Without Controls"
  
  ### Sun and Abraham dynamic DID
  mod_sa = feols(.[lhs] ~ sunab(year_treated, year) + ## The only thing that's changed
                   .[rhs] | UNITID + YEAR ,
                 cluster = ~ STABBR,
                 data = data1[abs(data1$time_to_treat)<num_per,])
  fit_cis_90_sun <- confint(mod_sa,level=0.95) %>% data.frame() %>% .[1:10,]
  est_sun <- modelsummary(mod_sa,output = "dataframe") %>% filter(statistic=="estimate") %>% .[1:10,] %>% dplyr::rename("Coefficient"="(1)")
  est_sun$method <- "With Controls"
  
  ## create a single table
  fit_cis_90 <- fit_cis_90_sun %>% rbind(fit_cis) %>% 
                  rename("conf.low_95" = "X2.5..","conf.high_95" = "X97.5..")
  
  est_coef <- est_sun %>% rbind(est_sun0)
  
  
  #results2 <- bind_cols(est_coef,fit_cis_90) %>% rename(Variable = term)
  
  results2 <-  bind_cols(est_coef,fit_cis_90) %>% rename(Variable = term)
  results2$Variable <- results2$Variable %>% parse_number
  
  ## add zero values for period -1 (normalization period)
  results2 <- results2 %>% select(-c(part,statistic))
  results2 <- results2 %>% rbind(c(-1,0,"With Controls",0,0)) %>% rbind(c(-1,0,"Without Controls",0,0))
  
  
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
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st&!df_legal$STABBR %in% tr_st] %>% unique

df_med <- df %>%   filter(STABBR %in% c(medical_control,tr_st))

### run the dynamic DID and bind the results
event_results <- dynamic_did(df,"All states control","Total","ln_EFTOTLT") %>% 
                    rbind(dynamic_did(df,"All states control","Female","ln_EFTOTLW") )%>% 
                    rbind(dynamic_did(df,"All states control","Male","ln_EFTOTLM") ) %>%
                    rbind(dynamic_did(df_med,"Medical states control","Total","ln_EFTOTLT") )%>% 
                    rbind(dynamic_did(df_med,"Medical states control","Female","ln_EFTOTLW") )%>% 
                    rbind(dynamic_did(df_med,"Medical states control","Male","ln_EFTOTLM") )

# define color values for each group
colors <- c("darkgreen","black")

# Create a factor with the desired variable order
var_order <- c("Total","Female", "Male")
event_results$outcome <- fct_relevel(factor(event_results$outcome), var_order)

event_results$method <- fct_relevel(factor(event_results$method), c("With Controls","Without Controls"))
event_results$method <- fct_relevel(factor(event_results$method), c("Without Controls","With Controls"))

# event_results %<>% filter(!method%in%0)

p1 <-  ggplot(event_results %>% filter(sample=="Medical states control")) +
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
                      legend.position = c(.25,.95),
                      strip.text = element_text(face = "bold",size=12))+
                scale_x_continuous(breaks = seq(-6,5,1)) 

print(p1)


ggsave(file="../../figures/main/fig_3_main_event.eps", plot = p1,height = 6.5,width = 6 )


# print a small plot for presentation 

p1 <-  ggplot(event_results %>% filter(sample=="Medical states control") %>% 
                filter(outcome=="Total")) +
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
               # facet_grid(outcome~.)+
                theme_minimal()+
                xlab("Years since RML (dispensary open)")+
                ylab("Estimate (log points) and 95% Conf. Int.")+
                scale_color_manual(values = colors) +
                theme(panel.spacing = unit(1, "lines"),legend.title=element_blank(),
                      legend.position = c(.18,.95),strip.text = element_text(face = "bold",size=12))+
                scale_x_continuous(breaks = seq(-6,5,1)) 

#print(p1)

# for the presentation slides
#ggsave(file="../../figures/main/fig_3_main_event_present.eps", plot = p1,height = 3.5,width = 5.5 )

