# clear the environment
rm(list = ls())

# set the working directory
path = "~/Dropbox/Research/Oil_Transfer/prep_for_pub/REStat_data_code/"
mapdata.path = "cleaned_data/map_data/"
setwd(path)

# load packages
library(rgdal)
library(tidyverse)

# read in the shapefile
county = readOGR(dsn = mapdata.path, layer = "cb_2013_us_county_20m") %>%
    fortify(region = "GEOID")
state = readOGR(dsn = mapdata.path, layer = "cb_2013_us_state_20m") %>%
    fortify(region = "GEOID") %>%
    filter(id != "02" & id != "15" & as.numeric(id) < 57) # exclude Alaska and Hawaii

county = county %>% mutate(fips = as.numeric(id))

# read the oil and gas employment share data
ogshare.df = read_csv(paste0(mapdata.path, "heat_map_og_share_1974.csv"))

# join the GIS data and the mining share data
plot.df = left_join(county, ogshare.df, by = "fips")

# plot
p = plot.df %>%
    filter(og_state == 1) %>%
    ggplot() +
    geom_polygon(aes(x = long, y = lat, group = group, fill = as.factor(cnty_size_1974)),
                 color = "grey50", size = .2) +
    geom_polygon(data = state, aes(x = long, y = lat, group = group),
                 fill = NA, color = "black", size = .2) +
    coord_map() +
    scale_fill_grey(breaks = c(1, 2, 3),
                    labels = c("small: < 5%", "medium: 5-20%", "large: > 20%"),
                    start = .8, end = .2) +
    theme(legend.position = c(0.85, 0.2),
          legend.background = element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size = 12),
          axis.line = element_blank(),
          axis.title = element_blank(),
          axis.text  = element_blank(),
          axis.ticks = element_blank(),
          panel.background = element_blank(),
          plot.margin = unit(c(1, 0, 0, 0), "cm"))
p
ggsave("results/figure1.pdf", width = 10, height = 6)
