### Edited by Ryan
renv::load("../../../../../..")
###

# Setting directory to script location
# install.packages("rstudioapi")

# execute the following code to install and load the required packages
# source("install_load_packages.R")

options(repos = c(CRAN = "https://cloud.r-project.org"))
# List of required libraries
libraries <- c(
  "tidyverse", "fixest", "plyr", "Hmisc", "cpi", "Inflation", "modelsummary", "AER", "ivreg",
  "lmtest", "multiwayvcov", "plm", "lmtest", "sandwich", "latex2exp",
  "haven", "ggplot2", "gt", "magrittr", "fastDummies",
  "bacondecomp", "did2s", "rvest", "lubridate", "nycflights13", "xml2",
  "dplyr", "kableExtra", "estimatr", "geosphere",
  "rmapshaper", "tigris", "sf", "ggplot2", "ggspatial", "rnaturalearth",
  "matrixStats", "readxl", "scales", "devtools",
  "maps", "tigris", "sf", "magick", "ggpattern", "grid",
  "groupdata2", "tikzDevice", "remotes",
  "data.table", "fwildclusterboot", "educationdata"
)

# Function to check and install packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Loop through the list and install missing packages
invisible(lapply(libraries, install_if_missing))

# Load the devtools package
library(devtools)
library(remotes)



# these are not on CRAN but rather on GitHub

# load from github
# https://github.com/evanjflack/bacondecomp
# devtools::install_github("evanjflack/bacondecomp")

# https://github.com/PMassicotte/gtrendsR
# devtools::install_github("PMassicotte/gtrendsR")

# Install rnaturalearthhires from GitHub
# install_github("ropensci/rnaturalearthhires")

# Install urbnthemes from GitHub
# remotes::install_github("UrbanInstitute/urbnthemes", build_vignettes = TRUE)

# Install urbnmapr from GitHub
# remotes::install_github("UrbanInstitute/urbnmapr")

library(tidyverse)
library(fixest)
library(modelsummary)
library(AER)
library(ivreg)
library(bacondecomp)
library(lmtest)
library(multiwayvcov)
library(plm)
library(lmtest)
library(sandwich)
library(latex2exp)
library(haven)
library(ggplot2)
library(dplyr)
library(gt)
library(magrittr)
library(fastDummies)
library(bacondecomp)
library(did2s)
library(rvest)
library(lubridate)
library(nycflights13)
library(xml2)
library(dplyr)
library(kableExtra)
library(estimatr)
library(geosphere)
library(rnaturalearthhires)
library(rmapshaper)
library(tigris)
library(sf)
library(ggplot2)
library(ggspatial)
library(rnaturalearth)
library(matrixStats)
library(readxl)
library(scales)
library(urbnmapr)
library(urbnthemes)
library(maps)
library(tigris)
library(fwildclusterboot)
library(magick)
library(ggpattern)
library(grid)
library(groupdata2)
library(tikzDevice)
library(gtrendsR)
library(data.table)
library(educationdata)
library(rvest)
library(tidyverse)
library(plyr)
library(Hmisc)
library(cpi)
library(Inflation)


#----------------------------------------------------------
#------------- DOWNLOAD & MERGE DATA  ---------------------
## NOTE: UNCOMMENT TO RUN THE CODE BELOW
#----------------------------------------------------------

#############################################################
## (1) Download the data from nces.ed.gov AND OTHER SOURCES
#############################################################

## 1-a) IPEDS DATA
# source("../data_cleaning/ipeds_downloading/IPEDS_scraping.R")
# source("../data_cleaning/grad_rates_panel/grad-rates-panel.R")

## 1-b) CONTROL VARIABLES DATA (county level population, unemployment rate, etc.)
# source("../data_cleaning/census_pop/census_data.R")
# source("../data_cleaning/bls_bea/scraping_functions.R")

## 1-c) OTHERS: Google Trends & Marijuana prices
## Note: try again if you encounter error for sending too many requests
# source("../data_cleaning/google_trend/google_trend_data.R")
# source("../data_cleaning/marijuana_price/marijuana_price_scraping.R")

#############################################################
## (2) data merging--merge data from different sources above
#############################################################

## merges data and saves to enroll_all.csv,enroll_vocational.csv,
## enroll_main.csv,enroll_robust_controls.csv,completion.csv,grad_rates.csv,
## welfare.csv
# source("../data_cleaning/enrollment_cleaning/enroll_cleaning.R")
# source("../data_cleaning/completion_cleaning/compl_cleaning.R")
# source("../data_cleaning/grad_rates_panel/grad-rates-panel.R")
# source("../data_cleaning/enrollment_cleaning/welfare_cleaning.R")

#----------------------------------------------------------
#-------------------------- TABLES ------------------------
#----------------------------------------------------------

# Summary Statistics (tables 1 & A1)
# source("table_1_A1.R")

# RML effect on Log Number of Undergraduate Degrees (tables 2 & A4--panel a)
source("table_2_A4_panel_a.R")

# RML effect on Undergraduate Graduation Rates (tables 2 & A4--panels b and c)
source("table_2_A4_panel_b_c.R")

# RML effect on tuition and retention rate (tables 3 & A5)
# source("table_3_A5.R")

# RML effect on Admission and Test Scores (tables 4 and A6)
# source("table_4_A6.R")

# RML effect on in-State Enrollment (table A7)
# source("table_A7.R")

# RML effect on Enrollment (tables A2 & A3)
# source("table_A2_A3.R")

# Heterogeneous effect by the allowed cultivation (table A8)
# source("table_A8.R")

# see figure_6_table_A9.R bellow for Table A9

#----------------------------------------------------------
#-------------------------- FIGURES -----------------------
#----------------------------------------------------------

# Figure 1: Treated States Legalization Timeline, Trends, and Control Groups
# (Figure 1, A1, A2, A7, A8, A9)
# source("figure_1_A1_A2_A7_A8_A9.R")

# RML Effect on First-Time Enrollment (Figure 2)
# source("figure_2.R")

# main event study (Figure 3)
# source("figure_3.R")

# Effects on out-of-state enrollments (Figure 4 and A10)
# source("figure_4_A10.R")

# Heterogeneous Effects of Recreational Marijuana Legalization (Figure 5)
# source("figure_5.R")

# Sensitivity to proximity spillover (figure 6 and table A9)
# Takes long to run due to the computing of distance matrix
# (i.e., each college and the closest treatment state border)
# source("figure_6_table_A9.R")

# Other event study graphs (Figure A3, A4, A5)
# source("figure_A3_A4_A5.R")

# Goodman-Bacon Decomposition (Figure A6)
# source("figure_A6.R")
