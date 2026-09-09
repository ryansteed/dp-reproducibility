# clear the environment
rm(list = ls())

# set the working directory
path = "~/Dropbox/Research/Oil_Transfer/prep_for_pub/REStat_data_code/"
setwd(path)

# load packages
library(haven)
library(tidyverse)
library(cowplot)

# read data
df = read_dta("cleaned_data/nation_year_cleaned.dta")

# Oil and gas national employment number in 10,000s.
og_natl_emp = df %>%
    ggplot(aes(year, ognatlnumemp / 10000)) +
    xlim(1970, 2011) +
    geom_line() +
    geom_point(color = "grey") +
    ylab("") + xlab("") +
    ggtitle("Oil & Gas National Employment (10,000)") +
    theme(plot.title = element_text(size = 12, hjust = 0, face = "bold"),
          axis.text = element_text(size = 12),
          axis.line = element_line(),
          panel.background = element_blank(),
          panel.grid.major.y = element_line(size = .5, colour = "grey90"),
          panel.grid.major.x = element_line(size = .5, colour = "grey90"),
          plot.margin = unit(c(0.5, 0.5, 0, 0), units = "cm"))

# Real Oil Prices are per barrel in 2010 dollars.
real_oil_prices = df %>%
    ggplot(aes(year, oilprice / cpi * cpi[year == 2010])) +
    xlim(1970, 2011) +
    geom_line() +
    geom_point(color = "grey") +
    ylab("") + xlab("") +
    ggtitle("Real Oil Price (2010 $)") +
    theme(plot.title = element_text(size = 12, hjust = 0, face = "bold"),
          axis.text = element_text(size = 12),
          axis.line = element_line(),
          panel.background = element_blank(),
          panel.grid.major.y = element_line(size = .5, colour = "grey90"),
          panel.grid.major.x = element_line(size = .5, colour = "grey90"),
          plot.margin = unit(c(0.5, 0.5, 0, 0), units = "cm"))

# Real Gas Prices are per thousand cubic feet in 2010 dollars.
real_gas_prices = df %>%
    ggplot(aes(year, gasprice / cpi * cpi[year == 2010])) +
    xlim(1970, 2011) +
    geom_line() +
    geom_point(color = "grey") +
    ylab("") + xlab("") +
    ggtitle("Real Natural Gas Price (2010 $)") +
    theme(plot.title = element_text(size = 12, hjust = 0, face = "bold"),
          axis.text = element_text(size = 12),
          axis.line = element_line(),
          panel.background = element_blank(),
          panel.grid.major.y = element_line(size = .5, colour = "grey90"),
          panel.grid.major.x = element_line(size = .5, colour = "grey90"),
          plot.margin = unit(c(0.5, 0.5, 0, 0), units = "cm"))

plot_grid(real_oil_prices, real_gas_prices, og_natl_emp,
          ncol = 1, align = "v")
ggsave("results/figure2.pdf", width = 8, height = 10)
