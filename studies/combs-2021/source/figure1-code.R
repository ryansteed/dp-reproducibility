# The Effects of Homestead Exemptions for Seniors and Disabled People on School Districts
# Alex Combs and John Foster
# Replication of Figure 1

# Packages
library(tidyverse)

# Data Imports

## Exemption Data from Kentucky Department of Revenue
county_hex <- read_csv("real-property-assessment-and-homestead-exemptions_2018.csv",
         col_names = c('county',
                       'residential',
                       'farm',
                       'commercial',
                       'res_senior_hex',
                       'res_disability_hex',
                       'farm_senior_hex',
                       'farm_disability_hex',
                       'comm_senior_hex',
                       'comm_disability_hex',
                       'senior_hex_claims',
                       'disability_hex_claims'),
         skip = 1)

## County locales from NCHS, 2013
county_locale <- read_csv("county_locale.csv")

# Data Prep

# Exemption data

## Remove last row of NAs
county_hex <- county_hex[1:120,]
county_hex$residential <- as.numeric(county_hex$residential)
county_hex$comm_senior_hex <- as.numeric(county_hex$comm_senior_hex)
county_hex$comm_disability_hex <- as.numeric(county_hex$comm_disability_hex)

## Calculate total property value
## (assessed values account for hex amounts; must add hex amounts for total)
county_hex$total_value <- rowSums(county_hex[,2:10], na.rm = TRUE)

## Calculate total exemption value
county_hex$total_exempt <- rowSums(county_hex[,5:10], na.rm = TRUE)

## Calculate percent total value exempt
county_hex <- county_hex %>% 
  mutate(pct_exempt = (total_exempt/total_value)*100)

# Locales

## Transorm county to match county_hex
county_locale <- county_locale %>% 
  separate(county, c("county", NA))

county_locale$county <- str_to_upper(county_locale$county)

## Join county_locale to county_hex
county_hex <- county_hex %>% 
  left_join(county_locale, by = "county")

# Create binary variable for rural

county_hex <- county_hex %>% 
  mutate(rural = if_else(urban_code == "Non-core", "Rural", "Non-rural"))

county_hex$rural <- as.factor(county_hex$rural)

# Figure 1

county_hex %>% 
  ggplot(aes(y = pct_exempt, x = rural)) +
  geom_boxplot(alpha = 0) +
  geom_jitter(color = "steelblue", width = 0.3) +
  coord_flip() +
  theme_classic() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.line.y = element_blank())

ggsave("pct-tax-base-exempt_ky-county_2018.eps")
