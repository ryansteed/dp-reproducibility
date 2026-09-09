
# List of required libraries
libraries <- c(
  "tidyverse", "fixest","plyr","Hmisc", "cpi","Inflation","modelsummary", "AER", "ivreg", 
  "lmtest", "multiwayvcov", "plm", "lmtest", "sandwich", "latex2exp",
  "haven", "ggplot2", "gt", "magrittr", "fastDummies",
  "bacondecomp", "did2s", "rvest", "lubridate", "nycflights13", "xml2",
  "dplyr", "kableExtra", "estimatr", "geosphere",
  "rmapshaper", "tigris", "sf", "ggplot2", "ggspatial", "rnaturalearth",
  "matrixStats", "readxl", "scales", "devtools",
  "maps", "tigris", "sf", "magick", "ggpattern", "grid",
  "groupdata2", "tikzDevice", "remotes",
  "data.table","fwildclusterboot","educationdata"
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
devtools::install_github("evanjflack/bacondecomp")

# https://github.com/PMassicotte/gtrendsR
devtools::install_github("PMassicotte/gtrendsR")

# Install rnaturalearthhires from GitHub
install_github("ropensci/rnaturalearthhires")

# Install urbnthemes from GitHub
remotes::install_github("UrbanInstitute/urbnthemes", build_vignettes = TRUE)

# Install urbnmapr from GitHub
remotes::install_github("UrbanInstitute/urbnmapr")

# Load all the libraries
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


