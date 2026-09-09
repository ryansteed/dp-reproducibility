## this script: clean up and prepare data

## Run this script ONLY IF you want to re-create the files in the "cleaned_data" folder.

##------------------------------------------------------------------------------
## setup
##------------------------------------------------------------------------------
rm(list = ls())

# set working directory
setwd(".")

# EDITED BY RYAN STEED
install.packages("pacman")
pacman::p_load(
    readstata13,
    testthat,
    data.table,
    statar,
    magrittr,   
    scales,
    lazyeval,
    haven,
    stringr,
    forcats,
    tidyverse
)
#

library(readstata13)
library(testthat)
library(data.table)
library(statar)
library(magrittr)
library(scales)
library(lazyeval)
library(haven)
library(stringr)
library(forcats)
library(tidyverse)

# functions
reorder_cols = function(df, ...) {
    df = df[sort(names(df))]
    df = eval(substitute(select(df, ..., everything())))
    df %>% arrange(...)
}

update_var = function(df) {
    conflict.varlist =
        names(df %>% select(ends_with(".x"))) %>%
        str_replace(".x", "")

    for (i in conflict.varlist) {
        var = substitute(i)
        var.x = paste0(i, ".x")
        var.y = paste0(i, ".y")
        mutate_call = lazyeval::interp(~ifelse(is.na(var.y), var.x, var.y),
                                       var.x = as.name(var.x),
                                       var.y = as.name(var.y))
        df %<>% mutate_(.dots = setNames(list(mutate_call), var))
        df =
            eval(substitute(select(df, -var.x, -var.y),
                            list(var.x = as.name(var.x),
                                 var.y = as.name(var.y))))
    }

    return(df)
}

##------------------------------------------------------------------------------
## nation-year table
##------------------------------------------------------------------------------
nation.year.table = read_csv("raw_data/nation_year_raw.csv")

nation.year.table.mutated = nation.year.table %>%
    mutate(log_ognatlnumemp = log(ognatlnumemp), # oil/gas national emp
           log_real_oilprice  = log(oilprice / cpi * 100),
           log_real_coalprice = log(coalprice_ppi / cpi * 100),
           log_real_gasprice  = log(gasprice / cpi * 100)) %>%
    reorder_cols(fips, year)

##------------------------------------------------------------------------------
## state tables
##------------------------------------------------------------------------------
state.table = read_csv("raw_data/state_raw.csv")

# Coal states are: Kentucky, Ohio, Pennsylvania, and West Virginia
coal.state = c(21, 39, 42, 54)

# Oil & Gas states are: Colorado, Kansas, Louisiana, Mississippi, Montana, New Mexico
# North Dakota, Oklahoma, Texas, Utah, and Wyoming (we exclude Alaska 2 and West Virginia 54)
og.state = c(8, 20, 22, 28, 30, 35, 38, 40, 48, 49, 56)

state.table.mutated = state.table %>%
    mutate(coal_state = fips_st %in% coal.state,
           og_state   = fips_st %in% og.state) %>%
    reorder_cols(fips_st)
expect_equal(nrow(state.table.mutated %>% filter(og_state == "TRUE")), 11)
expect_equal(nrow(state.table.mutated %>% filter(coal_state == "TRUE")), 4)

##------------------------------------------------------------------------------
## state-year table
##------------------------------------------------------------------------------
state.year.table = read_csv("raw_data/state_year_raw.csv")

state.year.table.mutated = state.year.table %>%
    select(fips_st, year, cbpnumemp, minenumemp, minenumest, ognumest) %>%
    reorder_cols(fips_st, year)

##------------------------------------------------------------------------------
## county-year table: part 1
##------------------------------------------------------------------------------
county.year.table = read_csv("raw_data/county_year_raw.csv", guess_max = 100000)
cpi = read_csv("raw_data/nation_year_raw.csv") %>% select(year, cpi)

# create new variables
county.year.table.tmp = county.year.table %>%
    left_join(cpi, by = "year") %>%
    mutate(log_real_earn = ifelse(earn == 0, NA, log(earn / cpi * 100)),
           log_emp              = ifelse(emp == 0, NA, log(emp)),
           log_real_ssdi        = ifelse(ssdisab == 0, NA, log(ssdisab / cpi * 100)),
           log_real_ssi         = ifelse(ssi == 0, NA, log(ssi / cpi * 100)),
           log_pop              = log(pop)
           ) %>%
    select(-cpi)

# create balanced sample indicators to be imported into the county table
county.balanced.sample.ssdi = county.year.table.tmp %>%
    group_by(fips) %>%
    filter(!year %in% c(1967, 1968, 1969, 1981, 2012, 2013)) %>%
    summarise(bal_obs_ssdi = !any(is.na(ssdisab)))
county.balanced.sample.ssi = county.year.table.tmp %>%
    group_by(fips) %>%
    filter(!year %in% c(1967, 1968, 2012, 2013)) %>%
    summarise(bal_obs_ssi = !any(is.na(ssi)))

# create county annual oil/gas and coal employment share in 1974 or later & 1973 or earlier
median.sizes.1974 =
    c(2.5, 7, 14.5, 34.5, 74.5, 174.5, 374.5, 749.5, 1249.5, 1999.5, 3749.5, 7500)
median.sizes.1973 =
    c(2, 5.5, 13.5, 34.5, 74.5, 174.5, 374.5, 1999.5)

for (i in c("og", "cbp")) {
    # for years 1974 and later
    varlist.1974 = sapply(c(1:8, 10:13), function(x) paste0(i, "estsz", as.character(x)))
    df = county.year.table.tmp %>%
        filter(year %in% 1974:2011) %>% # Data up to 2011
        select(fips, year,
               match(varlist.1974, names(county.year.table.tmp)))
    df.m = data.frame(mapply(`*`, df, c(1, 1, median.sizes.1974)))
    i_numemp_est = paste0(i, "_numemp_est")
    df.m[, i_numemp_est] = rowSums(df.m[, c(3:ncol(df.m))])
    df.m %<>% select_("fips", "year", i_numemp_est)
    county.year.table.tmp %<>% left_join(df.m, by = c("fips", "year"))
    rm(df, df.m)

    # for years 1973 and earlier
    varlist.1973 = sapply(c("1a", "2a", "3a", 4:7, "8_13"), function(x) {
        paste0(i, "estsz", as.character(x))
    })
    df = county.year.table.tmp %>%
        filter(year %in% c(1967, 1970:1973)) %>%
        select(fips, year,
               match(varlist.1973, names(county.year.table.tmp)))
    df.m = data.frame(mapply(`*`, df, c(1, 1, median.sizes.1973)))
    i_numemp_est = paste0(i, "_numemp_est")
    df.m[, i_numemp_est] = rowSums(df.m[, c(3:ncol(df.m))], na.rm = TRUE)
    df.m %<>% select_("fips", "year", i_numemp_est)
    county.year.table.tmp %<>% left_join(df.m, by = c("fips", "year"))
    rm(df, df.m)
    rm(i, i_numemp_est)
}

county.year.table.tmp %<>% update_var()

# for 1967, we proxy share of employment in oil and gas in oil states
# with share of employment in mining, therefore
# for non-oil states, these shares should be missing
county.table = read_csv("raw_data/county_raw.csv", guess_max = 3000)

county.year.table.tmp %<>%
    left_join(county.table %>% select(fips, ends_with("est1967")), by = "fips") %>%
    left_join(state.table.mutated %>% select(fips_st, og_state, coal_state),
              by = "fips_st") %>%
    mutate(og_numemp_est = ifelse(is.na(og_numemp_est) & (year %in% c(1967, 1970:2011)),
                                  0, og_numemp_est)) %>%
    mutate(og_share_emp_est = og_numemp_est / cbp_numemp_est,
           og_share_emp_est = ifelse(is.na(og_share_emp_est) & (year %in% c(1967, 1970:2011)),
                                     0, og_share_emp_est)) %>%
    mutate(og_share_emp_est = ifelse(og_state == FALSE & (year == 1967),
                                     NA, og_share_emp_est)) %>%
    select(-ends_with("est1967"), -og_state, -coal_state)

# categorize mining's employment share into three groups:
# small [0, .05], medium (.05, .2], and large (.2, 1]
county.year.table.tmp %<>%
    mutate(og_size = cut(og_share_emp_est,
                         breaks = c(0, .05, .2, 1), include.lowest = T))

rename_levels = function(x) {
    levels(x)[levels(x) == "[0,0.05]"] = "small"
    levels(x)[levels(x) == "(0.05,0.2]"] = "medium"
    levels(x)[levels(x) == "(0.2,1]"] = "large"
    x
}

factor.list = c("og_size")
county.year.table.tmp[factor.list] =
    lapply(county.year.table.tmp[factor.list], rename_levels)

##------------------------------------------------------------------------------
## county table
##------------------------------------------------------------------------------
# create easy new variables
county.table.tmp = county.table %>%
    mutate(log_coalres = log(black2002coalres + 1))

# import new variables
county.table.tmp %<>%
    left_join(county.balanced.sample.ssdi, by = c("fips")) %>%
    left_join(county.balanced.sample.ssi,  by = c("fips")) %>%
    mutate(msa1990 = ifelse(is.na(msa1990), 0, msa1990))

# create manufacturing earnings share in 1969
wide.county.year.table = county.year.table.tmp %>%
    mutate(manufact_earn_share = manearn / earn) %>%
    select(fips, year, manufact_earn_share) %>%
    melt(id.vars = c("fips", "year")) %>%
    dcast(fips ~ variable + year)

## replace 1969 with various years for 5 coal counties
## in order to replicate Black et al 2002 Table 3
wide.county.year.table %<>%
    mutate(manufact_earn_share_1969 =
               ifelse(fips == 21159, manufact_earn_share_1970,
               ifelse(fips == 21119, manufact_earn_share_1971,
               ifelse(fips == 21223, manufact_earn_share_1972,
               ifelse(fips == 21237, manufact_earn_share_1982,
               ifelse(fips == 21215, manufact_earn_share_1984,
                      manufact_earn_share_1969)))))) %>%
    select(fips, manufact_earn_share_1969)

county.table.tmp %<>% left_join(wide.county.year.table, by = "fips")
rm(wide.county.year.table)

# create 1967 and 1974 CBP mining employment indicators
## make the wide table, and keep the year-specific vars
wide.county.year.table1 = as.data.table(county.year.table.tmp) %>%
    select(fips, year, ends_with("size")) %>%
    data.table::melt(id.vars = c("fips", "year"), value.factor = T) %>%
    data.table::dcast(fips ~ variable + year) %>%
    select(fips, ends_with("1967"), ends_with("1974")) %>%
    as_data_frame()
wide.county.year.table2 = as.data.table(county.year.table.tmp) %>%
    select(fips, year, ends_with("share_emp_est")) %>%
    data.table::melt(id.vars = c("fips", "year")) %>%
    data.table::dcast(fips ~ variable + year) %>%
    select(fips, ends_with("1967"), ends_with("1974")) %>%
    as_data_frame()

## create binary variables based on county size factor variables
for (i in c("small", "medium", "large")) {
    wide.county.year.table1[paste0("og_size_1967", i)] = if_else(wide.county.year.table1$og_size_1967 == i, 1, 0)
    wide.county.year.table1[paste0("og_size_1974", i)] = if_else(wide.county.year.table1$og_size_1974 == i, 1, 0)
}

## Import into county table
county.table.mutated  = county.table.tmp %>%
    left_join(wide.county.year.table1, by = "fips") %>%
    left_join(wide.county.year.table2, by = "fips") %>%
    reorder_cols(fips)

##------------------------------------------------------------------------------
## county-year table: part 2
##------------------------------------------------------------------------------
# import variables from other tables to create IVs
national.emp = nation.year.table.mutated %>%
    select(year, log_ognatlnumemp,
           log_real_oilprice, log_real_coalprice, log_real_gasprice, cpi)
state.type = state.table.mutated %>%
    select(fips_st, coal_state, og_state)
county.measures = county.table.mutated %>%
    select(fips, log_coalres,
           ends_with("medium"), ends_with("large"), contains("share_emp_est"))

county.year.table.tmp %<>%
    left_join(national.emp, by = "year") %>%
    left_join(state.type, by = "fips_st") %>%
    left_join(county.measures, by = "fips")

# create continous IVs
gen_iv = function(df, shock, county_measure, new_var) {
    shock = deparse(substitute(shock))
    county_measure = deparse(substitute(county_measure))
    new_var = deparse(substitute(new_var))
    d_new_var = paste0("d_", new_var)

    mutate_call = lazyeval::interp(~(shock - lag(shock)) * county_measure,
                                   shock = as.name(shock),
                                   county_measure = as.name(county_measure))
    df %<>%
        group_by(fips) %>%
        arrange(year) %>%
        mutate_(.dots = setNames(list(mutate_call), d_new_var))
}

# TODO: use coal PPI price for replication
county.year.table.tmp %<>%
    gen_iv(log_real_coalprice, log_coalres, coalprice_by_coalres) %>%
    gen_iv(log_real_oilprice, og_share_emp_est_1967, oilprice_by_emp1967) %>%
    gen_iv(log_real_oilprice, og_share_emp_est_1974, oilprice_by_emp1974) %>%
    gen_iv(log_ognatlnumemp, og_share_emp_est_1967, ogemp_by_emp1967) %>%
    gen_iv(log_ognatlnumemp, og_share_emp_est_1974, ogemp_by_emp1974) %>%
    ungroup()

county.year.table.tmp %<>%
    select(-log_real_oilprice, -log_real_coalprice, -log_real_gasprice, -cpi,
           -coal_state, -og_state, -log_coalres,
           -contains("natlnumemp"), -ends_with("medium"), -ends_with("large"),
           -ends_with("share_emp_est_1967"), -ends_with("share_emp_est_1974"))

ivs.df = county.year.table.tmp %>%
    select(fips, year,
           starts_with("d_oilprice_by"),
           starts_with("d_ogemp_by"))

# Drop observations related to merge, split, and annexation
county.year.table.tmp %<>%
    filter(!((fips == 4027  & year < 1983) |
             (fips == 35061 & year < 1981) |
             (fips == 46071 & year < 1977) |
             (fips == 51770 & year < 1976) |
             (fips == 51800 & year < 1974) |
             (fips == 51909 & year < 1975) |
             (fips == 51911 & year < 1975) |
             (fips == 51918 & year < 1972) |
             (fips == 51941 & year < 1972) |
             (fips == 51944 & year < 1975))) %>%
    complete(nesting(fips, fips_st), year = 1967:2013) %>%
    select(-starts_with("d_oilprice_by"),
           -starts_with("d_ogemp_by"))

# Re-fill the IVs
county.year.table.tmp %<>%
    left_join(ivs.df, by = c("fips", "year"))

county.year.table.mutated = county.year.table.tmp %>% reorder_cols(fips, year)
##------------------------------------------------------------------------------
## prepare normal tables for analysis
##------------------------------------------------------------------------------
drop_states = function(df) {
    # exclude states: Alaska, Washington DC, Hawaii
    state.list = c(2, 11, 15)
    df %<>% filter(!fips_st %in% state.list)
    return(df)
}

save_as_csv_stata = function(name) {
    file.name = deparse(substitute(name))
    file.path.csv = paste0("cleaned_data/", file.name, ".csv")
    file.path.dta = paste0("cleaned_data/", file.name, ".dta")
    name %>% write_csv(file.path.csv)
    name %>% write_dta(file.path.dta)
}

##------------------------------------------------------------------------------
## prepare nation-year table for analysis
##------------------------------------------------------------------------------
nation.year.table.mutated %>%
    reorder_cols(fips, year) %>%
    write_dta("cleaned_data/nation_year_cleaned.dta")

##------------------------------------------------------------------------------
## prepare state-year and state table for analysis
##------------------------------------------------------------------------------
state.table.mutated %>%
    drop_states() %>%
    write_dta("cleaned_data/state_cleaned.dta")

state.year.table.mutated %>%
    left_join(state.table.mutated %>% select(fips_st, state_name), by = "fips_st") %>%
    drop_states() %>%
    write_dta("cleaned_data/state_year_cleaned.dta")

##------------------------------------------------------------------------------
## prepare county-year table for analysis
##------------------------------------------------------------------------------
county.year.table.mutated %>%
    mutate(stateyr = year * 100 + fips_st) %>%
    left_join(state.table.mutated %>% select(fips_st, coal_state, og_state), by = "fips_st") %>%
    left_join(county.table.mutated %>%
                  select(fips, msa1990, manufact_earn_share_1969, log_coalres,
                         contains("bal_obs"),
                         contains("share_emp_est")),
              by = "fips") %>%
    drop_states() %>%
    reorder_cols(fips, year) %>%
    write_dta("cleaned_data/county_year_cleaned.dta")

