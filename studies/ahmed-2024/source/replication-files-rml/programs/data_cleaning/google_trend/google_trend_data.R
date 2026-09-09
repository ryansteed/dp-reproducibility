# loading packages
library(rvest)
library(tidyverse)
library(gtrendsR)


##  *********** uncomment these lines to redownload the raw data *******************

#-----------------------------------------------------
## begin downloading the data using gtrendsR libary
#-----------------------------------------------------

## get the google trend for marijuana related search words
## 429 error code typically indicates that too many requests have been sent in a given amount of time
## to resolve this issue, wait for a while/ restart r and then try again (this worked for me)
    # res <- gtrendsR::gtrends(c("dispensary","marijuana", "weed","pot"),
    #                geo = c(paste0("US-",state.abb[1])),time="today 3-m") 
    # 
    # df <- res$interest_over_time
    # 
    #     for (j in 1:length(state.abb)){
    #       df2 <- gtrends(c("dispensary","marijuana", "weed","pot"),
    #                      geo = c(paste0("US-",state.abb[j])),time="all" )$interest_over_time
    #       df <- df %>% rbind(df2)
    # 
    #       print(j)
    # 
    #     }

    # write_csv(df,"../../data/source_data/others/trends_raw.csv")

#-----------------------------------------------------
## end downloading the data using gtrendsR libary
#-----------------------------------------------------



#---------------------
## begin data cleaning
#----------------------
df <- read_csv("../../data/source_data/others/trends_raw.csv")

## keeping the year only
df$YEAR <- df$date %>% as.character() %>% substr(.,1,4) %>% as.numeric()

## state abbreviation 
df$STABBR <- substr(df$geo,4,5)

## consider hits less than 1 zero
df$hits[df$hits=="<1"] <- "0"
df$hits <- df$hits %>% as.numeric()

## removing incomplete period 
df <- df %>% filter(YEAR<2022) %>%  
             select(YEAR,STABBR,keyword,hits) %>% 
             aggregate(hits ~ keyword + STABBR + YEAR, data = ., mean)

#---------------------
## end data cleaning
#----------------------
    marij_legal_st <- c("CO","WA","AK","OR","MA","CA","NV","MI")
    marij_yr_st <- c(2012,2012,2015,2015,2015,2016,2017,2018)
    
    law_marij <- data_frame(STABBR = marij_legal_st,
                            YEAR = marij_yr_st)
    
## spread the data over keywords and take
## the average of marijuana related words
df2 <- df %>% spread(key=keyword,value = hits)

## not necessary referring to dispensary stores
df2$marij_related_words <- rowMeans(df2[,c("marijuana","pot","weed")])
df2$legal <- ifelse(df2$STABBR %in% marij_legal_st,"LMR","NLMR")
df2$YEAR <- df2$YEAR %>% as.numeric

write_csv(df2,"../../data/source_data/others/google_trend_df.csv")

#checking
# ggplot(df2,
#        aes(x=YEAR, y=dispensary)) +
#        geom_jitter()+
#        geom_smooth(se = FALSE)+
#         theme_bw()+
#         xlab("")+ylab("Dispensary web popularity")+
#         geom_vline(xintercept = c(2012,2015,2016,2017), linetype="dashed")+
#         scale_x_continuous(breaks=seq(2004,2021,2))
# ggsave("~/Desktop/marijuana_enrollment/figures/figure_2a.pdf")
# 
# 
# ggplot(df2,
#        aes(x=YEAR, y=dispensary,color=legal,linetype=legal)) +
#  # geom_jitter()+
#   geom_smooth( se = FALSE)+
#   theme_bw()+
#   xlab("")+ylab("Dispensary web popularity")+
#   geom_vline(xintercept = c(2012,2015,2016,2017), linetype="dashed")+
#   scale_x_continuous(breaks=seq(2004,2021,2))+
#   theme(legend.position = c(.1,.8))+
#   scale_linetype_manual(values = c("solid","dashed") , name=NULL) +
#   scale_color_manual(values = c("chartreuse4","blue"), name=NULL )
# 
# ggsave("~/Desktop/marijuana_enrollment/figures/figure_2b.pdf")



