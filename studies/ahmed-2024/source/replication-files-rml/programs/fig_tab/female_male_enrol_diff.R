
source("data-sources.R")

## medical control   
panel_data <- read_csv(main_data_path)

rhs=c(
  "adopt_law","adopt_MM_law",
  
  "is_medical",
  "is_large_inst",
  "ln_STUFACR",
  "ROTC",
  "DIST",
  
  "ln_AGE1824_TOT",
  "ln_AGE1824_FEM_SHARE",
  "ln_per_capita_income",
  "ln_unemply_rate",
  "ln_NETMIG"
)

mod_f <- feols(.["ln_EFTOTLW"] ~  .[rhs]|UNITID+YEAR, cluster = "STABBR", data = panel_data)
mod_m <- feols(.["ln_EFTOTLM"] ~  .[rhs]|UNITID+YEAR, cluster = "STABBR", data = panel_data)


# Function to estimate feols with year and college fixed effects
feols_function <- function(data,is_female) {
  
  if(is_female) {
    model <- feols(.["ln_EFTOTLW"] ~  .[rhs]|UNITID+YEAR, cluster = "STABBR", data = data)
  } else{
    model <- feols(.["ln_EFTOTLM"] ~  .[rhs]|UNITID+YEAR, cluster = "STABBR", data = data)
  }
  
  return(coef(model)[1])
}

# Function to get a bootstrap sample at the level of each year and college combination
bootstrap_sample_function <- function(data) {
  #sampled_data <- data[sample(nrow(data), replace = TRUE), ]
  sampled_data <- plm::pdata.frame(data[sample(nrow(data), replace = TRUE), ], index = c("UNITID", "YEAR"))
  
  return(sampled_data)
}

# Set the number of bootstrap iterations
num_iterations <- 10^3

# Perform bootstrap and estimate feols for each sample
bootstrap_f <- replicate(num_iterations, feols_function(bootstrap_sample_function(panel_data),TRUE), simplify = FALSE)
coef_f <- bootstrap_f %>% unlist %>% as.vector()

bootstrap_m <- replicate(num_iterations, feols_function(bootstrap_sample_function(panel_data),FALSE), simplify = FALSE)
coef_m <- bootstrap_m %>% unlist %>% as.vector()

# do a t test for difference between two means
# plot(density(coef_f))
# plot(density(coef_m))


# Calculate standard error
standard_error_f <- sd(coef_f) / sqrt(length(coef_f))
standard_error_m <- sd(coef_m) / sqrt(length(coef_m))
cov_fm <- cov(coef_f,coef_m)

critical_val <- (as.numeric(mod_m$coefficients[1]) - as.numeric(mod_f$coefficients[1]))/
                  sqrt(standard_error_f^2+standard_error_m^2-2*cov_fm)


## p value (assume normality due to large sample size)
2 * (1 - pnorm(abs(critical_val)))
#t.test(coef_f,coef_m)


