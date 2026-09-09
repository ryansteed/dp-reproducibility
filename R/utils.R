##' Utilities and global configuration for analysis
##'
##' This file defines global primary-key vectors used across the pipeline and
##' shared utility helpers. Document the purpose of `pk_*` vectors and the
##' constants used for plotting and reporting at the top of the file.
##' @keywords internal
library(pacman)

pacman::p_load(
  ggplot2,
  ggforce,
  tidyr,
  dplyr,
  janitor,
  comprehenr,
  broom,
  forcats,
  stringr,
  haven,
  ivreg,
  lmtest,
  sandwich,
  estimatr,
  huxtable,
  RSQLite,
  lubridate,
  comprehenr,
  repurrrsive,
  psych,
  fastDummies,
  latex2exp,
  texreg,
  marginaleffects,
  assertthat,
  logger,
  glue,
  cowplot,
  english,
  ggtext,
  patchwork
)
pacman::p_load_gh(
  "davidsjoberg/ggsankey"
)
log_layout(layout_glue_colors)

num_sims = 10
pk_treatments = c("epsilon_str", "mechanism_str", "a_str", "shrink_str", "cscale_str", "b_str", "imputations_str")
pk_treatments_dp = c("epsilon_str", "mechanism_str")
pk_experiments = c("study_id", pk_treatments)
pk_experiment_results = c(pk_experiments, "result_id")
pk_experiment_result_runs = c(pk_experiment_results, "sim_id")
pk_studies = c("study_id")
pk_results = c("study_id", "result_id")
pk_variables = c("study_id", "variable_id")
pk_sensitivity = c(pk_variables, "dataset_name")
pk_result_variables = c("study_id", "result_id", "variable_id")
pk_experiment_variables = c(pk_experiments, "variable_id")
pk_experiment_runs = c(pk_experiments, "sim_id")
pk_experiment_variable_runs = c(pk_experiment_runs, "variable_id")
pk_noise = c(pk_experiment_variable_runs, "dataset_name")


original_label = "Original"
different_threshold = 0.1
different_label = paste("Different (p <", different_threshold, ")")
same_label = paste("Same (p <", different_threshold, ")")
invalid_original_label = "Orig. not sig."
mechanism_expressions = c(
  # \epsilon \frac{\exp(\epsilon) - 1}{\exp(\epsilon) +1
  "Original"=NULL,
  "Original_mo"="MO w/ 20% C.V., no DP",
  "gaussian"=expression(Gaussian~bgroup("(", epsilon*frac(exp(epsilon)-1, exp(epsilon)+1)-zCDP, ")")),
  "laplace"=expression(Laplace~(epsilon-DP)),
  "laplace_mo"=expression(MO~Laplace~(epsilon-DP))
)

hline_title = "Comparison<br>to typical<br>replication<br>rates (no DP)"
hline_color1 = "#7570b3"
hline_color2 = "#e7298a"
hline_color3 = "#a6761d"
hline_color4 = "#666666"
hlines_scale = scale_color_manual(
  name=hline_title,
  values=c(
    "Brodeur"=hline_color1,
    "CamererSP"=hline_color2,
    "CamererCI"=hline_color2,
    "OpenScience"=hline_color3
    # "Williams"=hline_color4
  ),
  breaks=c()
)
hline_alpha = 0.75
hlines = list(
  # Brodeur et al.
  geom_hline(aes(
    yintercept=ifelse(name=="Sign parity", 0.7, NA),
    linetype="Brodeur",
  ), color=hline_color1, alpha=hline_alpha),
  # Camerer et al.
  geom_hline(aes(
    yintercept=ifelse(name=="Sign parity", 0.61, NA),
    linetype="CamererSP",
  ), color=hline_color2, alpha=hline_alpha),
  geom_hline(aes(
    yintercept=ifelse(name=="CI coverage", 0.667, NA),
    linetype="CamererCI",
  ), color=hline_color2, alpha=hline_alpha),
  # Williams et al.
  # geom_hline(aes(
  #   yintercept=ifelse(name=="Sign parity", 0.9, NA),
  #   linetype="Williams"
  # ), color=hline_color4, alpha=hline_alpha),
  # OpenScience
  geom_hline(aes(
    yintercept=ifelse(name=="CI coverage", 0.47, NA),
    linetype="OpenScience",
    color="OpenScience"
  ), color=hline_color3, alpha=hline_alpha),
  scale_linetype_manual(
    name=hline_title,
    values=c(
      "Brodeur"="longdash",
      "CamererSP"="dashed",
      "CamererCI"="dotdash",
      "OpenScience"="twodash"
    ),
    labels=c(
      "Brodeur"="70% of robustness checks in 110 soc. sci. studies\n replicated effect direction (Brodeur et al., 2024)",
      "CamererSP"="11 of 18 lab experiments in econ.\n replicated effect direction (Camerer et al., 2016)",
      "CamererCI"="12 of 18 replicated CIs from econ. contained\n orig. estimates (Camerer et al., 2016)",
      "OpenScience"="47 of 100 replicated CIs from social\n psych. contained orig. estimates\n (Open Science Collaboration, 2015)"
      # "Williams"="60% of economists willing to accept up to 10% significance mismatch (Williams et al., 2024)"
    ),
    breaks=c(
      "Brodeur",
      "CamererSP",
      "OpenScience",
      "CamererCI"
    )
  )
)

varnames_lookup = c(
  "Answers primary or co-primary RQ" = "dv_rq_primary",
  "Supports claim mentioned in abstract"="claim_in_abstract",
  "Proportion of personal vars. privatized"="prop_noised_success",
  "Regression sample size"="N_original",
  "Log regression sample size"="log_N_original",
  "Num. vars. noised"="n_vars_noised",
  "Num. vars about people"="n_vars_personal",
  "Log % personal vars. privatized"="prop_noised_success",
  "Model degrees of freedom (num. predictors - 1)"="df_model",
  "Log epsilon"="log_epsilon",
  "Log coeff. of variation (a)"="log_a",
  "Log scaling (b)"="log_b",
  "Claim: pos/neg"="epistemic_claim_abbrv_significant-direction",
  "Claim: insignificant"="epistemic_claim_abbrv_insignificant",
  "Claim: non-zero upper/lower bound"="epistemic_claim_abbrv_interval",
  "Cmd: ivreg, ivreg2, xtivreg2, ivregress, ivreghdfe"="stata_cmd_abbrv_ivreg, ivreg2, xtivreg2, ivregress, ivreghdfe",
  "Cmd: ivreghdfe"="stata_cmd_abbrv_ivreghdfe",
  "Cmd: reghdfe"="stata_cmd_abbrv_reghdfe",
  "Cmd: areg"="stata_cmd_abbrv_areg",
  "Cmd: other (arima, nbreg)"="stata_cmd_abbrv_other",
  "Model: FE"="estimation_method_abbrv_FE ",
  "Model: IV"="estimation_method_abbrv_IV",
  "Model: OLS, no FE"="estimation_method_abbrv_OLS",
  "Model: other"="estimation_method_abbrv_other",
  "Model: DD/DDD"="estimation_method_abbrv_DD/DDD",
  "Design: Boundary reg."="design_Boundary",
  "Design: Triple differences"="design_DDD",
  "Successfully privacy protected"="noised",
  "Count, log count"="query_type_simple_count",
  "Mean, log mean"="query_type_simple_mean",
  "Median"="query_type_simple_median",
  "Ratio"="query_type_simple_ratio",
  "Booleans/categorical"="query_type_simple_boolean/categorical",
  "More complex query"="query_type_simple_other",
  "Stat. type: count"="query_type_simple_count",
  "Stat. type: mean"="query_type_simple_mean",
  "Stat. type: sum/sum"="query_type_simple_sum/sum",
  "% stat. type: count, log count"="prop_query_type_simple_count",
  "% stat. type: mean, log mean"="prop_query_type_simple_mean",
  "% stat. type: median"="prop_query_type_simple_median",
  "% stat. type: other non-count"="prop_query_type_simple_other",
  "% stat. type: boolean/categorical"="prop_query_type_simple_boolean/categorical",
  "% stat. type: ratio"="prop_query_type_simple_ratio",
  "Dependent var."="reg_role_dep",
  "Primary independent var."="reg_role_ind",
  "Control var."="reg_role_control",
  "Instrumental var."="reg_role_instrument",
  "Instrumented var."="reg_role_instrumented",
  "Weighting var."="reg_role_weights",
  "Subsetting var."="reg_role_subset",
  "Subsetting var."="reg_role_subset",
  "# vars.: control"="n_reg_role_abbrv_control",
  "# vars.: ind./treatment var."="n_reg_role_abbrv_ind",
  "# vars.: dep./outcome var."="n_reg_role_abbrv_dep",
  "# vars.: IV"="n_reg_role_abbrv_instrument",
  "# vars.: other"="n_reg_role_abbrv_other",
  "Noised control var(s)."="any_reg_role_abbrv_control",
  "Noised dep/outcome var."="any_reg_role_abbrv_dep",
  "Noised ind./treatment var."="any_reg_role_abbrv_ind",
  "Noised dep./outcome var. x Log epsilon"="any_reg_role_abbrv_dep_log_epsilon",
  "Noised ind./treatment var. x Log epsilon"="any_reg_role_abbrv_ind_log_epsilon",
  "Noised IV var(s)."="any_reg_role_abbrv_instrument",
  "Data: administrative"="data_type_Administrative",
  "Data: blended"="data_type_abbrv_Blended",
  "Data: census"="data_type_abbrv_Census",
  "Data: survey"="data_type_abbrv_Survey",
  "Log sensitivity"="log_sensitivity",
  "Log sensitivity x Gaussian mech. (zCDP)"="log_sensitivity_mechanism_str_gaussian",
  "Log sum of sensitivity"="log_sum_sensitivity",
  "Log avg. RMSD of added noise"="log_avg_rmsd",
  "Log avg. (RMSD / range)"="log_avg_rmsd_norm_range",
  "Log avg. (Sensitivity / range)"="log_avg_avg_sensitivity_norm_range",
  "sum (Sensitivity / mean)"="sum_avg_sensitivity_norm",
  "Log sum (Sensitivity / mean)"="log_sum_avg_sensitivity_norm",
  "Log sum (Sensitivity / range)"="log_sum_avg_sensitivity_norm_range",
  "asinh sum (Sensitivity / range)"="asinh_sum_sensitivity_norm_range",
  "Log (Sensitivity / range)"="log_sensitivity_norm_range",
  "Gaussian mech. (zCDP)"="mechanism_str_gaussian",
  "Log epsilon x Gaussian mech. (zCDP)"="log_epsilon_mechanism_str_gaussian",
  "Log (Sensitivity / range) x Gaussian mech. (zCDP)"="log_sensitivity_norm_range_mechanism_str_gaussian",
  "Log avg. (Sensitivity / range) x Gaussian mech. (zCDP)"="log_avg_sensitivity_norm_range_mechanism_str_gaussian",
  "Log sum (Sensitivity / range) x Gaussian mech. (zCDP)"="log_sum_sensitivity_norm_range_mechanism_str_gaussian",
  "asinh sum (Sensitivity / range) x Gaussian mech. (zCDP)"="asinh_sum_sensitivity_norm_range_mechanism_str_gaussian",
  "Log sum of sensitivity x Gaussian mech. (zCDP)"="log_sum_sensitivity_mechanism_str_gaussian",
  "Effect size"="r_stat",
  "Original effect size"="r_stat_original",
  "Original effect size x Log epsilon"="r_stat_original_log_epsilon",
  "Period: > 1 year"="time_index_abbrv_>1 year",
  "Region: City/municipality/village/zone/MSA/CBSA/AMC"="geographic_index_abbrv_City/municipality/village, U.S. commuting zone/MSA/CBSA/Brazilian AMC",
  "Region: County/tract/block/prefecture/district (<1st division)"="geographic_index_abbrv_County, tract, block (group), district, prefecture, residency, university (<1st division)",
  "Region: State/district/province (1st division)"="geographic_index_abbrv_State, district, province (1st division)",
  "Region: Nation/country"="geographic_index_abbrv_Nation/country",
  "Region: Other"="geographic_index_abbrv_NA",
  "Region: Organization (school, university, police unit)"="geographic_index_abbrv_Organization (school, university, police unit)",
  "% statistics from: administrative data"="prop_data_type_abbrv_Administrative",
  "Morris-Lysy construction"="shrink_str_ml",
  "# component vars."="n_component_vars",
  "Log # component vars."="log_n_component_vars",
  "Log RMSD of noise added to original statistic"="log_rmsd",
  "Rate of strict epistemic parity"="epistemic_match",
  "Avg. sample unit population size"="avg_population_size",
  "Avg. sample unit population size x Log epsilon"="avg_population_size_log_epsilon",
  "Includes individual-level microdata (not noised)"="individual_level"
)
varnames_lookup_inv = setNames(names(varnames_lookup), varnames_lookup)

vardefs_lookup = c(
  "epistemic_match"="Avg. epistemic parity (strict)",
  "n_vars_noised"="Number of variables in the regression that received added noise",
  "n_component_vars"="Total number of component statistics noised (e.g., numerator and denominator counts) to compute final noisy regression variables (e.g., ratios)",
  "log_n_component_vars"="Log total number of component statistics noised (e.g., numerator and denominator counts) to compute all final noisy regression variables (e.g., ratios)",
  "sum_avg_sensitivity_norm"="Total sensitivity as a proportion of the original statistic",
  "log_sum_avg_sensitivity_norm"="Log of total sensitivity as a proportion of the original statistic",
  "query_type_simple_count"="Dummy: Statistic is based on counts or logs of counts",
  "prop_query_type_simple_count"="% of statistics that are based on counts or logs of counts",
  "query_type_simple_mean"="Dummy: Statistic is based on means or logs of means (sum / n, count / n)",
  "prop_query_type_simple_mean"="% of statistics that are based on means or logs of means (sum / n, count / n)",  
  "query_type_simple_median"="Dummy: Statistic is based on medians",
  "prop_query_type_simple_median"="% of statistics that are based on medians",  
  "query_type_simple_other"="Dummy: Statistic is based on exponentials or other complex operations",
  "prop_query_type_simple_other"="% of statistics based on exponentials and other complex operations",  
  "query_type_simple_boolean/categorical"="Dummy: Statistic is based on booleans or categoricals",
  "prop_query_type_simple_boolean/categorical"="% of statistics that are based on booleans or categoricals",
  "query_type_simple_ratio"="Dummy: Statistic is based on ratios (count / count, count / sum)",
  "prop_query_type_simple_ratio"="% of statistics that are ratios (count / count, count / sum)",
  "r_stat_original"="Original effect size (r)",
  "epistemic_claim_abbrv_insignificant"="Original claim requires insignificant effect",
  "epistemic_claim_abbrv_significant-direction"="Original claim requires significant effect in a specific direction",
  "epistemic_claim_abbrv_interval"="Original claim requires significant effect with a non-zero lower and/or upper bound",
  "N_original"="Sample size of original regression",
  "log_N_original"="Log of original regression sample size",
  "df_model"="Degrees of freedom of original regression model",
  "any_reg_role_abbrv_dep"="Dummy: Dependent/outcome variable has added noise",
  "any_reg_role_abbrv_ind"="Dummy: Independent/treatment variable has added noise",
  "any_reg_role_abbrv_instrument"="Dummy: Instrumental variable has added noise",
  "geographic_index_abbrv_City/municipality/village, U.S. commuting zone/MSA/CBSA/Brazilian AMC"="Dummy: Regression sample unit is a city, municipality, village, U.S. commuting zone, U.S. metropolitan statistical area, or U.S. core-based statistical area",
  "geographic_index_abbrv_County, tract, block, district, prefecture, residency (<1st division)"="Dummy: Regression sample unit is a county/tract/block/district/prefecture/residency (<1st division)",
  "geographic_index_abbrv_State, district, province (1st division)"="Dummy: Regression sample unit is a state/district/province (1st division)",
  "geographic_index_abbrv_Nation/country"="Dummy: Regression sample unit is a nation/country",
  "geographic_index_abbrv_Organization (school, police unit)"="Dummy: Regression sample unit is an organization (school, police unit)",
  "geographic_index_abbrv_County, tract, block (group), district, prefecture, residency, university (<1st division)"="Dummy: Regression sample unit is a county, tract, block, block group, district, prefecture, residency, or university (<1st division)",
  "log_epsilon"="Log of privacy loss parameter (epsilon)",
  "mechanism_str_gaussian"="Dummy: Gaussian (zCDP) privacy mechanism used",
  "log_rmsd"="Log of root mean squared deviation (RMSD) in noised statistic compared to original",
  "log_sensitivity"="Log of sensitivity of statistic (the most the statistic could change if a single individual's data were added or removed)",
  "avg_population_size"="Average population size of sample units in regression"
)

dummy_cols_imputena = function(df, select_columns, ...) {
  df %>%
    mutate(across(all_of(select_columns), ~ replace_na(as.character(.x), "NA"))) %>%
    fastDummies::dummy_cols(
      select_columns=select_columns,
      ...
    )
}

source("R/plots.R")
source("R/data.R")
source("R/analysis.R")
source("R/reporting.R")
