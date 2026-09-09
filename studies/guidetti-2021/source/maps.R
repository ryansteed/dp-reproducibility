if(!require(foreign)){install.packages("foreign")}
library(foreign)
if(!require(readstata13)){install.packages("readstata13")}
library(readstata13)
if(!require(rgeos)){install.packages("rgeos")}
library(rgeos)
if(!require(rgdal)){install.packages("rgdal")}
library(rgdal)
if(!require(ggplot2)){install.packages("ggplot2")}
library(ggplot2)
if(!require(ggmap)){install.packages("ggmap")}
library(ggmap)
if(!require(ggthemes)){install.packages("ggthemes")}
library(ggthemes)
if(!require(maptools)){install.packages("maptools")}
library(maptools)
if(!require(mapproj)){install.packages("mapproj")}
library(mapproj)
if(!require(gridExtra)){install.packages("gridExtra")}
library(gridExtra)

rm(list = ls())
setwd(" add the path here ")

#####################
# map with monitors #
#####################

data <- read.dta13("main_data.dta")

monitors <- unique(data[c("monitor","latitude","longitude")])
district <- unique(data["district"])

#SPMA shapefile
shape <- readOGR("census", "SC2010_CEM_RMSAO")
shape_dist <- gUnaryUnion(shape, id = shape@data$COD_DI )

shape_dist_plot <- fortify(shape, region="COD_DI")

shape_dist_plot$plot[shape_dist_plot$id %in% district$district] <- 1
shape_dist_plot$plot[is.na(shape_dist_plot$plot)] <- 0

# plot
map_monitors <-ggplot() + geom_polygon(data = shape_dist_plot, aes(x = long, y = lat, group = group, fill = plot), show.legend = TRUE) +
  geom_polygon(data = shape_dist, aes(x = long, y = lat, group = group), fill=NA, color = "black", size = 0.25) + coord_map() +
  theme_minimal() + theme(legend.position="bottom", legend.key = element_rect(fill = "white", colour = "white"), legend.key.width = unit(0.9, "cm"), legend.key.height = unit(0.4, "cm"), legend.key.size = unit(0.2, "cm"))  + 
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(0.5,0.25,0.25,1), "cm")) +
  scale_fill_gradientn(colors=c("#FFFFFF", "#CCCCCC"),na.value = "#FFFFFF", guide = "legend", breaks=c(0,1), labels=c("","Districts within 5km"), name = "")  +   geom_point(aes(x = longitude, y = latitude, color="Monitors"), data = monitors, shape=16) + scale_color_manual(name="", values=c(Monitors="red")) + scale_shape(solid=TRUE) + labs(fill="") 
ggsave(map_monitors, file = "map_district.png", width = 6.5, height = 4.5, type = "cairo-png")

rm(monitors, shape_dist, shape_dist_plot, data, district)


###########################
# map with pediatric beds #
###########################

#municipalities shape
shape_mun <- gUnaryUnion(shape, id = shape@data$COD_MU)
shape_mun_plot <- fortify(shape, region="COD_MU")

#data with pediatric beds
data <- read.dta13("munic_beds.dta")
data$tx_ped <- data$pediatric*1000/data$population
data$plot <- ifelse(data$tx_ped < 0.5 | is.na(data$tx_ped), 1, 
                    ifelse(data$tx_ped < 1 & data$tx_ped >= 0.5, 2, 
                           ifelse(data$tx_ped < 2 & data$tx_ped >= 1, 3, ifelse(data$tx_ped <= 3 & data$tx_ped >= 2, 4, ifelse(data$tx_ped > 3, 5, NA)))))

shape_mun_plot <- merge(data, shape_mun_plot, by.x="munic_id", by.y = "id", all.x=TRUE, all.y=TRUE)



map_beds <- ggplot() + geom_polygon(data = shape_mun_plot, aes(x = long, y = lat, group = group, fill = plot), show.legend = TRUE) +
  geom_polygon(data = shape_mun, aes(x = long, y = lat, group = group), fill=NA, color = "black", size = 0.25) + theme_minimal() + coord_map() +
  theme(legend.position="bottom", legend.key = element_rect(fill="white", colour="white"), legend.key.width = unit(0.9, "cm"), legend.key.height = unit(0.4, "cm"), plot.subtitle = element_text(hjust = 0.5), legend.key.size = unit(0.2, "cm"))  +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(0.5,0.25,0.25,1), "cm")) +
  scale_color_manual(name=expression(" "), values=c("black")) + scale_shape(solid=TRUE) + labs(fill="") + 
  scale_fill_gradientn(colors=c("#FF3333", "#FF6666","#996699","#6666CC", "#0000CC"),na.value = "#FFFFFF", guide = "legend", breaks=c(1,2,3,4,5), labels=c("< 0.5","[0.5,1)", "[1,2)","[2,3]","> 3"), name= "beds/1,000 children") 
ggsave(map_beds, file = "map_beds.png", width = 6.5, height = 4.5, type = "cairo-png")


#################
# grid the maps #
#################

grid<- grid.arrange(map_monitors, map_beds, nrow = 1, ncol=2, widths=c(2,2))
ggsave(grid,file = "maps.png", width = 12, height = 4, type = "cairo-png")
ggsave(grid,file = "maps.pdf", width = 12, height = 4)


rm(list = ls())
