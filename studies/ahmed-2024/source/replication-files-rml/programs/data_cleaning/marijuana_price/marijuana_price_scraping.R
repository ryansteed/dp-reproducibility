library(tidyverse)
library(rvest)
library(lubridate)
library(nycflights13)
library(xml2)
library(rvest)
library(readxl)
library(dplyr)


####################################
## extract weed prices from 
## https://www.priceofweed.com/
####################################
# extracting all the tables for 2010 to 2020

#-----------------------------------------------------------------
## begin downloading the data from https://www.priceofweed.com/
#-----------------------------------------------------------------

## list of links
##-----------------
##library(XML)
## Extract hyperlink from Excel file in R (extracted from priceofweed.com)
    linkTable<- read_csv("../../data/source_data/others/WeedPrice.csv")
    linkTable$url <- as.character(linkTable$url)
    linkTable$url <- linkTable$url %>% gsub(" ","%20",.)
    
    # ##link1="https://www.priceofweed.com/prices/United-States/Alabama.html"
    node22 <- ".avg_box"

    ### this function takes the index of the url
    ### returns scraped table from the url
    ### the node is defined outside of the function
    # scrapePrices <- function(k){
    # 
    #      link1 <- linkTable$url[k]
    # 
    #     # call the title with the date
    #     col_page <- read_html(link1)
    # 
    #     # calling the table
    #     col_table0 <- col_page %>% html_nodes(node22) %>%
    #                   html_table() %>% as.data.frame() %>% select(1:2)  %>%
    #                   rename(quality_type=X1,  price=X2)
    # 
    #     # separate the measurement unit
    #     col_table <- col_table0[-1,]
    #     unit_mesrmt <- col_table0[1,]
    # 
    #     col_table$url <- link1
    #     col_table$Year <- linkTable$Year[k]
    #     col_table$Jurisdictions <- linkTable$Jurisdictions[k]
    #     col_table$measure_unit <- unit_mesrmt[1,2]
    # 
    #   return(as_data_frame(col_table) )}

    scrapePrices <- function(k){
      tryCatch({
        link1 <- linkTable$url[k]
        col_page <- read_html(link1)
        col_table0 <- col_page %>% html_nodes(node22) %>%
          html_table() %>% as.data.frame() %>% select(1:2)  %>%
          rename(quality_type=X1,  price=X2)
        col_table <- col_table0[-1,]
        unit_mesrmt <- col_table0[1,]
        col_table$url <- link1
        col_table$Year <- linkTable$Year[k]
        col_table$Jurisdictions <- linkTable$Jurisdictions[k]
        col_table$measure_unit <- unit_mesrmt[1,2]
        return(as_data_frame(col_table))
      }, error = function(e){
        return(NULL) # or handle the error as you see fit
      })
    }
    
    ## save the first entry
    PriceData <- scrapePrices(1)
    k1=nrow(linkTable)
    ## loop and bind with the first entry
        for (j in 2:nrow(linkTable)) {
            PriceData <-    rbind(PriceData, scrapePrices(j))
            print(paste0(j," /", k1) )
          }

    # cleaning the price variable from extraneous characters
    PriceData$measure_unit %>% unique() # the same unit

    # I checked the web and the text means no entry
    PriceData$price[PriceData$price=="I feel bad for these guys -->"] <- NA

    # convert price to double
    PriceData$price <- PriceData$price %>% gsub("\\$","",.) %>% as.numeric()

    PriceData$quality_type %>% unique()

    # looking at the distribution
    # ggplot(data = PriceData,aes(price))+
    #             geom_histogram()+
    #             facet_wrap(~quality_type)

    # remove the low quality as it has lots of missing values and years
    PriceData1 <- PriceData %>% filter(quality_type!="Low Quality")

   # write_csv(PriceData1,"../../data/source_data/others/cleaned_price_df.csv")

#-----------------------------------------------------------------
## end downloading the data from https://www.priceofweed.com/
#-----------------------------------------------------------------
  
# checking the data
#PriceData1 <- read_csv("../../data/source_data/others/cleaned_price_df.csv")

# # ploting the price 
# ggplot(data = PriceData1)+
#               geom_point(aes(x=Year, y=price))+
#               facet_wrap(~quality_type)
# 
# # looking at the distribution 
#marij_yr_st <- c(2012,2012,2015,2015,2015,2016,2017,2018)

# ggplot(data = PriceData1,aes(price))+
#               geom_histogram()+
#               facet_wrap(~quality_type)

# aggregate price over quality, year, and state by taking the mean
# 
# PriceData_states <- aggregate(by=list(Year=PriceData1$Year, Jurisdictions=PriceData1$Jurisdictions),
#                           x= PriceData1[,2], FUN = mean, na.rm=TRUE, na.action=na.omit) %>% 
#                           rename(Jurisdiction=Jurisdictions)
# 
# PriceData_states$Jurisdiction %>% unique()
# treated_states <- c("California","Washington","Nevada" ,"Oregon" , "Massachusetts",  "Colorado")
# PriceData_states$`Legal status` <- ifelse(PriceData_states$Jurisdiction %in% treated_states,"RML","NRML")
# 
# PriceData_states <- PriceData_states %>% as.tibble()
# PriceData_states$price <- PriceData_states$price %>% as.numeric()
# 
# PriceData_states2 <- aggregate(by=list(Year=PriceData_states$Year, 
#                                         `Legal status`=PriceData_states$`Legal status`),
#                                 x= PriceData_states[,3], FUN = mean, na.rm=TRUE, na.action=na.omit)

# ggplot(PriceData_states2)+ geom_line(aes(x=Year, y=price,color=`Legal status`,linetype=`Legal status`),
#                                      size=1) + 
#           scale_x_continuous(breaks=seq(2010,2020,2))+ xlab("")+ ylab("Price ($/Oz.)")+
#           geom_vline(xintercept = marij_yr_st %>% unique, linetype="dashed")+theme_bw()+
#           theme(legend.position=c(.91,.91),legend.title = element_blank()) +
#           scale_linetype_manual(values = c("dashed","solid") , name=NULL) +
#           scale_color_manual(values = c("blue","chartreuse4"), name=NULL )
# ggsave("~/Desktop/mr_paper/figures/main/mr_prices.pdf")

#-----------
# PriceData_national <- aggregate(by=list(Year=PriceData1$Year),
#                         x= PriceData1[,2], FUN = mean, na.rm=TRUE, na.action=na.omit)
# 
# PriceData_national$Jurisdiction <- "NATIONAL" 
# 
# # 
# ggplot(PriceData_national)+ geom_line(aes(x=Year, y=price),color="chartreuse4",size=1) +
#           theme_bw() + scale_x_continuous(breaks=seq(2010,2020,2))+ xlab("")+ ylab("Price ($/Oz.)")+
#   geom_vline(xintercept = marij_yr_st %>% unique, linetype="dashed")
# ggsave("~/Desktop/mr_paper/figures/figure_4b.pdf")


