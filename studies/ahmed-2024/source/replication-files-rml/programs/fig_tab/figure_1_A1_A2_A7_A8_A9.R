source("data-sources.R")
library(tidyverse)
library(dplyr)
#===============================================
# Figure 1: Treated States Legalization Timeline
#===============================================

df <- data_frame(State = c("WA", "CO",  "OR",  "MA",  "CA",  "NV"),
                 `RM by Law` = c(2012,  2012,  2015,  2016,  2016,  2017),
                 `RM by Dispensary`= c(2014,  2014,  2016,  2018,  2018,  2018))

ggplot(df, aes(x=`RM by Law`,y=`RM by Dispensary`),
       size=8)+
        geom_label( 
          data=df  ,
          aes(label=State),
          nudge_x = .2,  # Adjust the spacing for each label
          nudge_y = .2, label.size = 0,
          check_overlap = T)+
        geom_abline(data = data_frame(
          x=2012:2019.5,
          y=2012:2019.5) ,
        intercept = 0, slope = 1, color = "chartreuse4",
        linetype="dashed") + #,size=1
        coord_equal() +
        scale_x_continuous(limits = c(2011, 2018.5),breaks = 2012:2018) +
        scale_y_continuous(limits = c(2011, 2018.5),breaks = 2012:2018) +
        geom_label(
          label="WA", 
          x=2012.2, label.size = 0,
          y=2013.65,
          color = "black",
          fill="white"
        )+
        geom_label(
          label="MA", 
          x=2016.2,
          y=2017.65, label.size = 0,
          color = "black",
          fill="white"
        )+  geom_point(color="chartreuse4")+
        theme_minimal()+
  coord_fixed(ratio = .6)

ggsave("../../figures/main/fig_1_a_treatment.eps",width=5,height = 3.5,units="in")



#==============================================
# Enrollment trends by group
#==============================================

state_df <- tibble(States=state.name,STABBR = state.abb)
df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique

## medical control   
df <- read_csv(main_data_path) %>% filter(STABBR %in% c(medical_control,tr_st)) 

df$Treatment <- ifelse(df$STABBR%in%tr_st,"Ever RML (Treat, N = 6 States)","Ever MML (Control, N = 24 States)")

df2 <- df %>% #select(YEAR,Treatment,EFTOTLT) %>%  
       dplyr::group_by(Treatment,YEAR) %>% 
        dplyr::summarise(avg_enrol=mean(EFTOTLT,na.rm = TRUE)) %>% 
          unique %>% ungroup()

df3 <- read_csv(main_data_path) %>%
  mutate(Treatment = ifelse(STABBR%in%tr_st,"RML States","Non-RML States")) %>% 
  select(YEAR,Treatment,EFTOTLT) %>% 
  dplyr::group_by(Treatment,YEAR) %>% 
  dplyr::summarise(avg_enrol=mean(EFTOTLT,na.rm = TRUE)) %>% 
  unique %>% ungroup()

ggplot(df2,aes(YEAR,avg_enrol,color=Treatment,linetype=Treatment))+
  geom_line()+
  scale_x_continuous(breaks = seq(2009,2019,2) ) +
  scale_color_manual(values = c("navy","forestgreen")) + 
  theme_minimal()+
  xlab("Year")+ylab("Average first-time fall enrollment\n per state university")+
  theme(legend.position = c(.4,.95),legend.title = element_blank())

ggsave("../../figures/main/fig_1_b_raw_enrl.eps",width=5,height = 3.5,units="in")


#==============================================
# Figure A2: Marijuana Consumption and 
# Price by Legalization Status
#==============================================
price_plot <- function(){
  
  
  ####################################
  ## extract weed prices from 
  ## https://www.priceofweed.com/
  ####################################
  # extracting all the tables for 2010 to 2020
  
  ##  *********** uncomment these lines to redownload the raw data *******************
  
  #-----------------------------------------------------------------
  ## begin downloading the data from https://www.priceofweed.com/
  #-----------------------------------------------------------------
  
  ## list of links
  ##-----------------
  ##library(XML)
  ## Extract hyperlink from Excel file in R (extracted from priceofweed.com)
  # linkTable<- read_csv("~/Desktop/mr_paper/data/source_data/others/WeedPrice.csv")
  # 
  # ##TempTable <- PriceData
  # linkTable$url <- as.character(linkTable$url)
  # linkTable$url <- linkTable$url %>% gsub(" ","%20",.)
  # 
  # 
  # ##link1="https://www.priceofweed.com/prices/United-States/Alabama.html"
  # node22 <- ".avg_box"
  # 
  # ### this function takes the index of the url
  # ### returns scraped table from the url
  # ### the node is defined outside of the function
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
  # 
  # ## save the first entry
  # PriceData <- scrapePrices(1)
  # k1=nrow(linkTable)
  # ## loop and bind with the first entry
  #     for (j in 2:nrow(linkTable)) {
  #         PriceData <-    rbind(PriceData, scrapePrices(j))
  #         print(paste0(j," /", k1) )
  #       }
  # 
  # # cleaning the price variable from extraneous characters 
  # PriceData$measure_unit %>% unique() # the same unit
  # 
  # # I checked the web and the text means no entry
  # PriceData$price[PriceData$price=="I feel bad for these guys -->"] <- NA
  # 
  # # convert price to double
  # PriceData$price <- PriceData$price %>% gsub("\\$","",.) %>% as.numeric()
  # 
  # PriceData$quality_type %>% unique()
  # 
  # 
  # # looking at the distribution 
  # ggplot(data = PriceData,aes(price))+
  #             geom_histogram()+
  #             facet_wrap(~quality_type)
  # 
  # # remove the low quality as it has lots of missing values and years
  # PriceData1 <- PriceData %>% filter(quality_type!="Low Quality")
  # 
  # 
  # write_csv(PriceData1,"~/Desktop/mr_paper/data/source_data/others/cleaned_price_df.csv")
  
  #-----------------------------------------------------------------
  ## end downloading the data from https://www.priceofweed.com/
  #-----------------------------------------------------------------
  
  PriceData1 <- read_csv("../../data/clean_data/cleaned_price_df.csv")
  
  # # ploting the price 
  # ggplot(data = PriceData1)+
  #               geom_point(aes(x=Year, y=price))+
  #               facet_wrap(~quality_type)
  # 
  # # looking at the distribution 
  marij_yr_st <- c(2012,2012,2015,2015,2015,2016,2017)
  
  # ggplot(data = PriceData1,aes(price))+
  #   geom_histogram()+
  #   facet_wrap(~quality_type)
  
  # aggregate price over quality, year, and state by taking the mean
  PriceData_states <- aggregate(by=list(Year=PriceData1$Year, Jurisdictions=PriceData1$Jurisdictions),
                                x= PriceData1[,2], FUN = mean, na.rm=TRUE, na.action=na.omit) %>% 
    dplyr::rename(Jurisdiction=Jurisdictions)
  
  PriceData_states$Jurisdiction %>% unique()
  treated_states <- c("California","Washington","Nevada" ,"Oregon" , "Massachusetts",  "Colorado")
  PriceData_states$`Legal status` <- ifelse(PriceData_states$Jurisdiction %in% treated_states,"RM-states","Non-RM states")
  
  PriceData_states <- PriceData_states %>% as.tibble()
  PriceData_states$price <- PriceData_states$price %>% as.numeric()
  
  PriceData_states2 <- aggregate(by=list(Year=PriceData_states$Year, 
                                         `Legal status`=PriceData_states$`Legal status`),
                                 x= PriceData_states[,3], FUN = mean, na.rm=TRUE, na.action=na.omit)
  
  
  ggplot(PriceData_states2)+ geom_line(aes(x=Year, y=price,color=`Legal status`,linetype=`Legal status`),
                                       size=1) + 
    scale_x_continuous(breaks=seq(2010,2020,2))+ xlab("")+ ylab("Price ($/Oz.)")+
    geom_vline(xintercept = marij_yr_st %>% unique, linetype="dashed")+theme_bw()+
    theme(legend.position= "none",legend.title = element_blank()) +
    scale_linetype_manual(values = c("dashed","solid") , name=NULL) +
    scale_color_manual(values = c("blue","chartreuse4"), name=NULL )
  res_h=5
  res_w=7
  
  ggsave("../../figures/appendix/fig_a2b_mr_prices.eps",
         width = res_w,height = res_h)
  
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
  
}
price_plot() # a

google_trend <- function(){
  
  ##  *********** uncomment these lines to redownload the raw data *******************
  
  #-----------------------------------------------------
  ## begin downloading the data using gtrendsR libary
  #-----------------------------------------------------
  
  ## get the google trend for marijuana related search words
  # res <- gtrends(c("dispensary","marijuana", "weed","pot"),
  #                geo = c(paste0("US-",state.abb[1])),time="all" )
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
  # 
  # write_csv(df,"~/Desktop/marijuana_enrollment/data/source_data/others/trends_raw.csv")
  
  #-----------------------------------------------------
  ## end downloading the data using gtrendsR libary
  #-----------------------------------------------------
  
  
  
  #---------------------
  ## begin data cleaning
  #----------------------
  #"~/Desktop/project_tables_figures/google_trend/trends_raw.csv"
  
  
  df <- read_csv("../../data/clean_data/trends_raw.csv")
  
  ## keeping the year only
  df$YEAR <- df$date %>% as.character() %>% substr(.,1,4) %>% as.numeric()
  
  ## state abbreviation 
  df$STABBR <- substr(df$geo,4,5)
  
  ## consider hits less than 1 zero
  # df$hits %>% unique()
  df$hits[df$hits=="<1"] <- "0"
  df$hits <- df$hits %>% as.numeric()
  
  ## removing incomplete period 
  df <- df %>% filter(YEAR<2022) %>%  
    select(YEAR,STABBR,keyword,hits) %>% 
    aggregate(hits ~ keyword + STABBR + YEAR, data = ., mean)
  
  
  #---------------------
  ## end data cleaning
  #----------------------
  
  #--------------****----------****----------------
  
  marij_legal_st <- c("CO","WA","AK","OR","MA","CA","NV","MI")
  marij_yr_st <- c(2012,2012,2015,2015,2015,2016,2017,2018)
  
  
  law_marij <- data_frame(
    STABBR = marij_legal_st,
    YEAR = marij_yr_st
  )
  
  
  #--------------****----------****----------------
  
  ## spread the data over keywords and take
  ## the average of marijuana related words
  df2 <- df %>% spread(key=keyword,value = hits)
  
  ## not necessary referring to dispensary stores
  df2$marij_related_words <- rowMeans(df2[,c("marijuana","pot","weed")])
  
  #df2 <- df2 %>% select(-c(marijuana,pot,weed)) 
  df2$legal <- ifelse(df2$STABBR %in% marij_legal_st,"RM-states","Non-RM states")
  df2$YEAR <- df2$YEAR %>% as.numeric
  
  #write_csv(df2,"~/Desktop/mr_paper/data/clean_data/google_trend_df.csv")
  
  # ggplot(df2,
  #        aes(x=YEAR, y=dispensary)) +
  #   geom_jitter()+
  #   geom_smooth(se = FALSE)+
  #   theme_bw()+
  #   xlab("")+ylab("Dispensary web popularity")+
  #   geom_vline(xintercept = c(2012,2015,2016,2017), linetype="dashed")+
  #   scale_x_continuous(breaks=seq(2004,2021,2))
  # ggsave("~/Desktop/mr_paper/figures/main/figure_2a.pdf")
  
  ggplot(df2,
         aes(x=YEAR, y=dispensary,color=legal,linetype=legal)) +
    # geom_jitter()+
    geom_smooth( se = FALSE)+
    theme_bw()+
    xlab("")+ylab("Dispensary web popularity")+
    geom_vline(xintercept = c(2012,2015,2016,2017), linetype="dashed")+
    scale_x_continuous(breaks=seq(2004,2021,2))+
    theme(legend.position = c(.15,.9))+
    scale_linetype_manual(values = c("dashed","solid") , name=NULL) +
    scale_color_manual(values = c("blue","chartreuse4"), name=NULL )
  
  res_h=5
  res_w=7
  
  
  ggsave("../../figures/appendix/fig_a2a_google_trends.eps",
         width = res_w,height = res_h)
  
  
}
google_trend() # b


#==============================================
# Figure A1: Marijuana Legalization Timeline
#==============================================

state_df <- tibble(States=state.name,STABBR = state.abb)

df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")

df_legal$`Legalization status` <- NA

df_legal$`Legalization status`[df_legal$adopt_MM_law ==1] <- "Medical"
df_legal$`Legalization status`[df_legal$adopt_law==1] <- "Recreational-law"
df_legal$`Legalization status`[df_legal$adopt_store==1] <- "Recreational-store"
df_legal$`Legalization status`[is.na(df_legal$`Legalization status`)] <- " "

## corrections
# https://www.mpp.org/states/utah/summary-of-utahs-medical-cannabis-law/
df_legal$med_year[df_legal$STABBR%in%"UT"] <- 2019
df_legal$`Legalization status`[df_legal$STABBR%in%"UT"&df_legal$YEAR>2018] <- "Medical"

# https://www.mpp.org/states/west-virginia/
df_legal$med_year[df_legal$STABBR%in%"WV"] <- 2018
df_legal$`Legalization status`[df_legal$STABBR%in%"WV"&df_legal$YEAR>2017] <- "Medical"

ggplot(df_legal,aes(YEAR, States,color=`Legalization status`, 
                    shape = `Legalization status`), size=12 )+
  scale_x_continuous(breaks=seq(2009,2019,by=1),expand = c(0, .9))+
  #geom_point(aes(shape=`Legalization status`) )+
  geom_point( )+
  theme_classic()+xlab("")+
  theme(legend.position = "bottom") +
  scale_color_manual(values=c("white","chartreuse3","chartreuse4","darkgreen") )+
  scale_shape_manual(values = c("circle",  "plus","square", "triangle"))

# increase the width and save the plot 
ggsave("../../figures/appendix/fig_a1_legal_apdx.eps",height=10,width = 7.5)




#==============================================
# Figure A7: Medical Marijuana Control Group
#==============================================

# ----------

state_df <- tibble(States=state.name,STABBR = state.abb)
df_legal <- read_csv(leg_path) %>% left_join(state_df) %>% filter(STABBR!="DC")
tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & !df_legal$STABBR %in% tr_st] %>% unique

# ----------

df_legal <- df_legal %>% filter(STABBR %in% c(medical_control,tr_st)) %>% select(STABBR) %>% unique

df_legal$`Legalization status: ` <- ifelse(df_legal$STABBR %in% tr_st,"Recreational marijuana",
                                           "Medical marijuana")

states_map <- get_urbn_map(map = "states", sf = TRUE)


df_legal_map <- left_join(states_map, df_legal, by = c("state_abbv"="STABBR"))
df_legal_map$`Legalization status: `[is.na(df_legal_map$`Legalization status: `)] <- "Others"


# Or specify the factor levels in the order you want
df_legal_map$`Legalization status: ` <- factor(df_legal_map$`Legalization status: `, 
                                               levels = c("Recreational marijuana",
                                                          "Medical marijuana",
                                                          "Others"
                                               ))

states_map <- map_data("state") %>% dplyr::rename(state_abbv=region)

ggplot(df_legal_map %>% filter(!state_abbv%in%c("HI","DC","AK")) ) +
            geom_sf_pattern(aes(pattern =  `Legalization status: `),
                            pattern_colour  = 'black',
                            pattern_density = .3,
                            pattern_spacing = 0.025 )+
            geom_sf(mapping = aes( fill = `Legalization status: `),
                    color = "white", size = .01) +
            
            scale_fill_manual(values = alpha(c("chartreuse4", "green","gray98"),.8))+
            coord_sf(datum = NA)+
            geom_sf_text(aes(label = state_abbv),size=1.5, check_overlap=TRUE,fontface = "bold")+
            theme_classic()+
            xlab(NULL)+ylab(NULL)+
            theme(legend.position = "bottom",
                  plot.margin = margin(t = 0,  # Top margin
                                       r = 0,  # Right margin
                                       b = 0,  # Bottom margin
                                       l = 0  # Left margin
                  ))


ggsave("../../figures/appendix/fig_a7_med_contol_groups_apdx.png",height = 4,width = 7)

#==============================================
# Note: Figure A8 
# execute figure A7 first
#==============================================

df_legal_map %<>% mutate(`Legalization status: ` = case_when(
                    df_legal_map$state_abbv %in% c("WA","OR","CO") ~ "RM States",
                    df_legal_map$state_abbv %in% c("ID","MT","WY","UT","AZ","NM","TX","OK","KS","NE") ~ "Contiguous States Control",
                    df_legal_map$state_abbv %in% c("CA","NV","MI","ME","MA") ~ "Excluded RM States",
                  
                    TRUE ~  "Noncontiguous State Control"
                  ))


ggplot(df_legal_map %>% filter(!state_abbv%in%c("HI","DC","AK")) ) +
  geom_sf_pattern(aes(pattern =  `Legalization status: `),
                  pattern_colour  = 'black',
                  pattern_density = .3,
                  pattern_spacing = 0.025 )+
  geom_sf(mapping = aes( fill = `Legalization status: `),
          color = "white", size = .01) +
  
  scale_fill_manual(values = alpha(c( "green","darkgray","gray98","chartreuse4"),.8))+
  coord_sf(datum = NA)+
  geom_sf_text(aes(label = state_abbv),size=1.5, check_overlap=TRUE,fontface = "bold")+
  theme_classic()+
  xlab(NULL)+ylab(NULL)+
  theme(legend.position = "bottom",
        #lengend.title = element_blank(),
        plot.margin = margin(t = 0,  # Top margin
                             r = 0,  # Right margin
                             b = 0,  # Bottom margin
                             l = 0  # Left margin
        )
        )


ggsave("../../figures/appendix/fig_a8_cont_map.png",height = 4,width = 8)

#==============================================
# Figure A9: The Exclusion of Control Colleges
# Within 80 Miles of Treated Borders
#==============================================

spillover_map <- function(){
  
  state_df <- tibble(States=state.name,STABBR = state.abb)
  
  df_legal <- read_csv(leg_path) %>% 
    left_join(state_df) %>% filter(STABBR!="DC")
  
  tr_st <- unique(df_legal$STABBR[df_legal$adopt_law==1])
  mari_st <- df_legal$STABBR[!is.na(df_legal$med_year)] %>% unique
  
  never_treated_control <- df_legal$STABBR[!df_legal$STABBR %in% mari_st] %>% unique
  medical_control <- df_legal$STABBR[df_legal$STABBR %in% mari_st & 
                                       !df_legal$STABBR %in% tr_st] %>% unique
  
  
  ## medical control   
  df_acd <- read_csv(main_data_path) %>% 
    filter(STABBR %in% c(medical_control,tr_st))%>% 
    dplyr::rename(lat=LATITUDE,lon=LONGITUD)
  
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
  
  df <- df_acd %>% 
    dist_to_border(.,"Colorado") %>% 
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
  
  
  # https://education.illinoisstate.edu/grapevine/historical/
  #******** test the distance by maping ***********
  # Get the US map
  us_map <- ne_states(returnclass = "sf")
  
  # Get the polygon of treated states
  colorado <- ne_states(returnclass = "sf") %>% 
    filter(name %in% c("Colorado","Washington","Oregon",
                       "Nevada","California","Massachusetts"))
  
  # Extract the longitude and latitude coordinates of the polygon
  colorado_coords <- st_coordinates(colorado)
  
  ## testing the measued distances
  # Plot the US map and the location of the given coordinates
  # ggplot() +
  #   geom_sf(data = us_map) +
  #   geom_point(aes(x = lon , y = lat),
  #              size = .3, color = "red",
  #              data = df %>% filter(min_dist<200 &
  #                                     !STABBR %in% c( "CO", "WA", "OR", "CA", "MA", "NV"))
  #   ) +
  #   geom_sf(data = colorado, fill = NA, color = "blue",size=2) +
  #   coord_sf(xlim = c(-125, -65), ylim = c(25, 50)) +
  #   theme_void()
  
  ## keep the treated units by assigning large distance 
  df$min_dist2 <- df$min_dist
  df$min_dist2[df$STABBR %in% c( "CO", "WA", "OR", "CA", "MA", "NV")] <- 50000
  
  state_labels <- tibble(name=state.name,STABBR = state.abb)
  
  us_map <- inner_join(us_map,state_labels)
  
  # Plot the US map and the location of the given coordinates
  df$`Groups` <- ifelse( df$STABBR %in% c( "CO", "WA", "OR", "CA", "MA", "NV"), "Treatment","Control")
  
  ggplot() +
    geom_sf(data = us_map) +
    geom_point(aes(x = lon , y = lat,color=Groups), 
               size = .5, #color = "red",
               data = df %>% filter(!min_dist2<80 )
    ) +
    geom_sf(data = colorado, fill = NA, color = "blue",size=6) +
    coord_sf(xlim = c(-125, -65), ylim = c(25, 50)) +
    theme_void()+
    geom_sf_text(data = us_map,aes(label = STABBR),  check_overlap = TRUE)+
    theme(legend.position = "bottom", legend.title = element_blank())
  
  ggsave("../../figures/appendix/fig_A9_map_spil.eps",width = 8,height = 5 )  
  #-----
  
  
  
}
spillover_map()