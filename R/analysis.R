factor_df <- function(factor) {
  df_reg %>%
    distinct("study_id") %>%
    nrow() - 1
}

##' Aggregate mean estimates across result sets
##'
##' Summarize replication results by experimental grouping, computing means,
##' standard errors and other summary statistics used by plotting functions.
##' @param df data.frame of results
##' @return summarized data.frame with mean and se columns
results_means <- function(df) {
  df %>%
    group_by(across(all_of(c(pk_experiment_results, "epsilon_str_sci", "epsilon_str_eq", "a_str_eq")))) %>%
    mutate(
      n = n(),
      r_stat_mean = mean(r_stat), # should not be any NAs; watch for warnings
      r_stat_mean_size = label_effect_size(r_stat_mean),
      r_stat_se = sd(r_stat) / sqrt(n),
      p_mean = mean(p),
      p_se = sd(p) / sqrt(n),
      epistemic_match_mean = mean(epistemic_match),
      epistemic_match_se = sd(epistemic_match) / sqrt(n)
    ) %>%
    summarise(across(c(
      study_id_abbrv,
      r_stat_original,
      p_original,
      n,
      sum_avg_sensitivity_norm,
      ends_with("_mean"),
      ends_with("_se"),
      ends_with("size")
    ), first), .groups = "drop") %>%
    ungroup()
}

##' Compute mean noise metrics by group
##'
##' Computes mean and standard error of RMSD and related noise diagnostics
##' grouped by experiment result keys.
##' @param df data.frame of noise diagnostics
##' @return summarized data.frame
noise_means <- function(df) {
  df %>%
    group_by(across(all_of(pk_experiment_results))) %>%
    mutate(
      n = n(),
      rmsd_mean = mean(rmsd), # should not be any NAs; watch for warnings
      rmsd_se = sd(rmsd) / sqrt(n),
      rmsd_norm_mean = mean(rmsd_norm),
      rmsd_norm_se = sd(rmsd_norm) / sqrt(n),
      epistemic_match_mean = mean(epistemic_match)
    ) %>%
    summarise(across(c(
      study_id_abbrv,
      n,
      ends_with("_mean"),
      ends_with("_se")
    ), first), .groups = "drop") %>%
    ungroup()
}

ci_size <- function(se, alpha) {
  se * qnorm(1 - alpha / 2)
}

ci_lb <- function(est, se, alpha) {
  est - ci_size(se, alpha)
}

ci_ub <- function(est, se, alpha) {
  est + ci_size(se, alpha)
}

##' Inverse function for lower CI bound
##'
##' Given an estimate and standard error, compute the alpha at which the CI lower bound equals `lb`.
##' @param est numeric estimate
##' @param se numeric standard error
##' @param lb numeric lower bound
##' @return numeric alpha or NA
ci_lb_inverse <- function(est, se, lb) {
  if_else(
    est < lb,
    NA,
    2 * (1 - pnorm((est - lb) / se)) # alpha such that CI lower bound is lb
  )
}

##' Inverse function for upper CI bound
##'
##' Compute alpha at which CI upper bound equals `ub`.
##' @param est numeric estimate
##' @param se numeric standard error
##' @param ub numeric upper bound
##' @return numeric alpha or NA
ci_ub_inverse <- function(est, se, ub) {
  ifelse(
    est > ub,
    NA,
    2 * (1 - pnorm((ub - est) / se))
  )
}

##' Compute epistemic confidence for estimates
##'
##' Assigns an `epistemic_confidence` score to each estimate using CI inversion
##' and other heuristics. Also computes several parity/label columns used downstream.
##' @param df data.frame of estimates
##' @param threshold numeric decision threshold used to form labels
##' @param control_var string name of control indicator column
##' @param margin logical whether to compute margins relative to control
##' @return data.frame with added epistemic confidence and parity columns
calculate_epistemic_confidence <- function(df, threshold, control_var = "is_control", margin = F) {
  df <- df %>% mutate(
    epistemic_claim = case_when(
      expected_lb == 0 & expected_ub == 0 ~ "insignificant",
      is.na(expected_lb) & is.na(expected_ub) ~ "significant",
      is.na(expected_lb) & expected_ub == 0 ~ "negative",
      expected_lb == 0 & is.na(expected_ub) ~ "positive",
      !is.na(expected_lb) & is.na(expected_ub) ~ "lb",
      is.na(expected_lb) & !is.na(expected_ub) ~ "ub",
      !is.na(expected_lb) & !is.na(expected_ub) ~ "interval",
      .default = "test"
    ),
    epistemic_claim_abbrv = fct_collapse(
      epistemic_claim,
      "interval" = c("interval", "ub", "lb"),
      "significant-direction" = c("positive", "negative", "significant"),
      "insignificant" = c("insignificant"),
    ),
    epistemic_similarity_possible = case_when(
      epistemic_claim == "insignificant" ~ TRUE, # always possible to be insignificant at some p-value
      epistemic_claim == "significant" ~ TRUE, # always possible to be significant at some p-value
      (epistemic_claim == "negative" | epistemic_claim == "ub") & est >= expected_ub ~ FALSE, # impossible when est is too high
      (epistemic_claim == "negative" | epistemic_claim == "ub") & est < expected_ub ~ TRUE,
      (epistemic_claim == "positive" | epistemic_claim == "lb") & est <= expected_lb ~ FALSE, # impossible when est is too low
      (epistemic_claim == "positive" | epistemic_claim == "lb") & est > expected_lb ~ TRUE,
      epistemic_claim == "interval" & (est >= expected_ub | est <= expected_lb) ~ FALSE, # impossible when est is not in range
      epistemic_claim == "interval" & est < expected_ub & est > expected_lb ~ TRUE,
      .default = NA
    ),
    epistemic_confidence = ifelse(
      epistemic_similarity_possible,
      case_when(
        # CIs get wider as alpha decreases
        epistemic_claim == "insignificant" ~ pmin(
          ci_lb_inverse(est, se, 0), # alpha at which CI lower bound == 0; alpha can't be larger than this
          ci_ub_inverse(est, se, 0), # alpha at which CI upper bound == 0;alpha  can't be larger than this
          na.rm = TRUE
        ), # max alpha at which CI includes zero
        epistemic_claim == "significant" ~ pmax(
          ci_lb_inverse(est, se, 0), # alpha at which CI lower bound == 0; alpha can't be smaller than this
          ci_ub_inverse(est, se, 0) # alpha at which CI upper bound == 0; alpha can't be smaller than this
        ), # min alpha at which CI does not include zero
        epistemic_claim == "negative" ~ ci_ub_inverse(est, se, expected_ub), # alpha at which CI upper bound == 0
        epistemic_claim == "positive" ~ ci_lb_inverse(est, se, expected_lb), # alpha at which CI lower bound == 0
        (epistemic_claim == "interval") | (epistemic_claim == "ub") | (epistemic_claim == "lb") ~ 0.0, # good enough if it's in the range (coverage); full enclosure is atypical for these claims
        .default = NA
      ),
      NA
    ),
    "threshold" = !!threshold,
    # epistemic parity
    epistemic_match = case_when(
      !epistemic_similarity_possible ~ 0,
      epistemic_claim == "insignificant" & epistemic_confidence < threshold ~ 0,
      epistemic_claim == "insignificant" & epistemic_confidence >= threshold ~ 1,
      epistemic_similarity_possible & epistemic_confidence < threshold ~ 1,
      epistemic_similarity_possible & epistemic_confidence >= threshold ~ 0
    ),
    # sign parity
    epistemic_match_sign = ifelse(
      epistemic_claim == "insignificant",
      epistemic_match,
      case_when(
        ci_lb(est_original, se_original, threshold) > 0 ~ ci_lb(est, se, threshold) > 0, # if original CI exceeds zero, so must this CI
        ci_ub(est_original, se_original, threshold) < 0 ~ ci_ub(est, se, threshold) < 0, # if original CI under zero, so must this CI
        .default = NA # otherwise, NA
      )
    ),
    # cases where error is a "false negative" (false insig; sig becomes insig)
    sig_original = (ci_lb(est_original, se_original, threshold) > 0) | (ci_ub(est_original, se_original, threshold) < 0),
    insig_original = (ci_ub(est_original, se_original, threshold) > 0) & (ci_lb(est_original, se_original, threshold) < 0),
    epistemic_match_sign_fn = ifelse(
      insig_original, 0, # if originally insig, impossible to have false neg
      case_when( # look for cases where est was sig but has become insig
        ci_lb(est_original, se_original, threshold) > 0 ~ ci_lb(est, se, threshold) < 0, # if original CI exceeds zero but this CI does not
        ci_ub(est_original, se_original, threshold) < 0 ~ ci_ub(est, se, threshold) > 0, # if original CI under zero but this CI above
        .default = NA # otherwise, NA
      )
    ),
    epistemic_match_sign_flip = case_when( # look for cases where est has flipped signs
      ci_lb(est_original, se_original, threshold) > 0 ~ ci_ub(est, se, threshold) < 0, # if original CI above zero but new CI under zero
      ci_ub(est_original, se_original, threshold) < 0 ~ ci_lb(est, se, threshold) > 0, # if original CI under zero but new CI above zero
      .default = NA # otherwise, NA
    ),
    # cases where error is a "false positive" (false sig; insig becomes sig, or sig switches sign)
    epistemic_match_sign_fp = ifelse(
      insig_original, !epistemic_match_sign, # if originally insig, just check if controverted
      epistemic_match_sign_flip # otherwise check for sign flips
    ),
    epistemic_match_sign_type = case_when(
      epistemic_match_sign_fn == 1 ~ "False negative",
      epistemic_match_sign_fp == 1 ~ "False positive",
      (sig_original & epistemic_match_sign) ~ "True positive",
      (insig_original & epistemic_match_sign) ~ "True negative",
      .default = NA
    )
  )
  assert_that(sum(df[[control_var]]) > 0, msg = "Controls must be included to compute epistemic match")
  df <- df %>%
    group_by(across(all_of(c(pk_results, "threshold")))) %>%
    mutate(
      epistemic_match_original = first(epistemic_match[!!sym(control_var)])
    ) %>%
    ungroup() %>%
    mutate(
      epistemic_match = ifelse(
        epistemic_match_original,
        epistemic_match,
        NA
      ), # if original not significant at threshold, not applicable
      epistemic_label = as.factor(case_when(
        !epistemic_match_original ~ invalid_original_label,
        !!sym(control_var) ~ original_label,
        epistemic_match == 1 ~ same_label,
        epistemic_match == 0 ~ different_label
      )),
      epistemic_parity_label = case_when(
        epistemic_match_original == 0 ~ invalid_original_label, # if original not significant at threshold, not applicable
        is.na(epistemic_match) ~ "Undetermined",
        epistemic_match == 1 ~ "Strict parity",
        epistemic_match == 0 ~ "Strict disparity"
      )
    )
  if (margin) {
    vars_to_margin <- c("epistemic_match", "epistemic_match_sign", "coverage")
    df <- df %>%
      filter(!is_control) %>% # ignore controls; just want error or error + DP
      group_by(across(any_of(setdiff(c(pk_experiment_result_runs, "threshold"), pk_treatments_dp)))) %>%
      mutate(
        # epistemic_match_nodp = ifelse(
        #   sum(epsilon_str == "Original") == 1,
        #   epistemic_match[epsilon_str == "Original"],
        #   "ERROR"
        # ),
        # epistemic_match_margin = epistemic_match - epistemic_match_nodp,
        across(any_of(vars_to_margin), ~ ifelse(
          sum(!is_dp) == 1,
          .x[!is_dp],
          "ERROR"
        ), .names = "{.col}_nodp"),
        across(any_of(vars_to_margin), function(x) x - x[epsilon_str == "Original"], .names = "{.col}_margin")
      ) %>%
      ungroup()
    assert_that(df %>% filter(epistemic_match_margin == "ERROR") %>% nrow() == 0, msg = "Margin computation failed for some rows")
  }
  return(df)
}


compute_error_metrics <- function(results, control_var = "is_control", mo = F) {
  results <- results %>%
    mutate(
      F_stat = t**2,
      df_t = N - df_m,
      r_stat = sqrt((F_stat / df_model) / ((F_stat / df_model) + 1)), # https://osf.io/z7aux, https://stats.stackexchange.com/questions/484418/the-correlation-coefficient-per-df-effect-size-measure
      p_bin = case_when(
        p < 0.01 ~ "p<0.01",
        p < 0.05 ~ "p<0.05",
        p < 0.10 ~ "p<0.1",
      )
    ) %>%
    # record the original result for reference
    group_by(across(all_of(pk_results))) %>%
    mutate(
      across(c("est", "se", "t", "p", "N", "p_bin"), function(x) first(x[!!sym(control_var)]), .names = "{.col}_original"),
      sig_match = p_bin == p_bin_original,
      sign_match = sign(est) == sign(est_original), # whether signs match
      r_stat = ifelse(sign_match, r_stat, -r_stat), # adjust r_stat sign accordingly
      r_stat_size = label_effect_size(r_stat),
      across(c("r_stat", "r_stat_size"), function(x) first(x[!!sym(control_var)]), .names = "{.col}_original")
    ) %>%
    ungroup() %>%
    calculate_epistemic_confidence(different_threshold) %>%
    mutate(
      se_ratio = se_original / se,
      ess = N_original * se_ratio,
      epistemic_match_size = (r_stat_size == r_stat_size_original) & sign_match,
      bias = est - est_original,
      bias_abs = abs(est - est_original),
      bias_rel = abs(bias / est_original),
      bias_r = r_stat - r_stat_original,
      bias_r_abs = abs(bias_r)
    )
  results
}

compute_coverage_metrics <- function(df, ...) {
  df <- df %>%
    mutate(
      ci_lb_original = ci_lb(est_original, se_original, alpha),
      ci_ub_original = ci_ub(est_original, se_original, alpha),
      sign_match_ci = (
        ci_lb(est_original, se_original, alpha) > 0 & ci_lb(est, se, alpha) > 0 # both CIs exceed zero
      ) | (
        ci_ub(est_original, se_original, alpha) < 0 & ci_ub(est, se, alpha) < 0 # both CIs under zero
      ),
      coverage = est > ci_lb_original & est < ci_ub_original, # simple coverage: does original val fall within CI @ alpha?
      coverage_ci = ci_lb(est_original, se_original, alpha) <= ci_ub(est, se, alpha) &
        ci_lb(est, se, alpha) <= ci_ub(est_original, se_original, alpha) # test if CIs overlap @ alpha
    )
  df %>%
    calculate_epistemic_confidence(df$alpha, ...)
}

summ_stats <- function(df, include_desc = FALSE, count_dummies = TRUE, compact = TRUE) {
  summ <- df %>%
    mutate(name = factor(name, levels = unique(name))) %>% # preserves order of vars from above
    group_by(name) %>%
    summarise(
      is_dummy = count_dummies & all(as.numeric(value) %in% c(0, 1, NA)),
      `Obs.` = as.integer(if (is_dummy) sum(value, na.rm = T) else sum(!is.na(value))),
      Mean = if (is_dummy) NA else mean(value, na.rm = T),
      SD = if (is_dummy) NA else sd(value, na.rm = T),
      "Min." = if (is_dummy) NA else min(value, na.rm = T),
      Q1 = if (is_dummy) NA else quantile(value, 0.25, na.rm = T),
      Median = if (is_dummy) NA else median(value, na.rm = T),
      Q3 = if (is_dummy) NA else quantile(value, 0.75, na.rm = T),
      "Max." = if (is_dummy) NA else max(value, na.rm = T)
    ) %>%
    mutate_if(
      where(function(x) is.numeric(x) & !is.integer(x)),
      function(x) {
        ifelse(
          is.na(x),
          "",
          ifelse(
            abs(x) > 10000,
            sub("e([+-])0+", "e\\1", formatC(signif(x, 3), digits = 2, format = "e")),
            formatC(signif(x, 3), digits = 3, format = "fg", flag = "#")
          )
        )
      }
    )

  if (compact) {
    summ <- summ %>%
      mutate(
        `Mean (SD)` = ifelse(is_dummy, NA, paste0(Mean, " (", SD, ")", sep = "")),
        `Median (Q1, Q3)` = ifelse(is_dummy, NA, paste0(Median, " (", Q1, ", ", Q3, ")", sep = "")),
        `Range` = ifelse(is_dummy, NA, paste0(Min., "--", Max.))
      ) %>%
      select(-Mean, -SD, -Min., -Q1, -Median, -Q3, -Max.)
  }

  summ <- summ %>% select(-is_dummy)

  if (include_desc) {
    summ <- summ %>%
      mutate(
        name_chr = as.character(name),
        # First try to get description from internal name in vardefs_lookup
        desc_direct = vardefs_lookup[name_chr],
        # If that's NA, try using varnames_lookup to convert display name to internal name
        Description = ifelse(!is.na(desc_direct), desc_direct, ifelse(
          name_chr %in% names(varnames_lookup),
          vardefs_lookup[varnames_lookup[name_chr]],
          NA_character_
        )),
        Description = ifelse(is.na(Description), "", Description)
      ) %>%
      select(-name_chr, -desc_direct) %>%
      relocate(Description, .after = name)
  }

  options(knitr.kable.NA = "")
  summ %>%
    knitr::kable(format = "latex", booktabs = T) %>%
    writeLines()
  return(summ)
}

get_metrics_long <- function(df) {
  df %>%
    mutate(
      log_se_ratio = log(se_ratio)
    ) %>%
    pivot_longer(
      c(
        # "epistemic_match_size",
        "log_se_ratio",
        # "epistemic_match",
        # "bias", "bias_abs", "bias_rel",
        "sig_match",
        "sign_match",
        "bias_r",
        "bias_r_abs"
      )
    ) %>%
    mutate(
      name = fct_recode(
        as.factor(name),
        # "<i>n</i><sub>ESS</sub>"="ess",
        # "Epist. parity in size"="epistemic_match_size",
        "log <i>n</i><sub>ESS</sub>/<i>n</i>" = "log_se_ratio",
        # "Epistemic parity ($p<0.1$)"="epistemic_match",
        "Signif. match" = "sig_match",
        "Sign match" = "sign_match",
        "Diff. in effect size r" = "bias_r",
        "Abs. diff. in effect size r" = "bias_r_abs"
      )
    )
}

get_metrics_long_alpha <- function(df, all = F, margin = F, ...) {
  alpha <- c(0.01, 0.05, 0.1)
  df <- df %>%
    select(-any_of(c("alpha", "threshold"))) %>%
    crossing(alpha) %>%
    compute_coverage_metrics(margin = margin, ...) %>%
    filter(!is_control)
  if (!margin) {
    metrics <- c(
      "Strict parity" = "epistemic_match",
      "Sign parity" = "epistemic_match_sign",
      "CI coverage" = "coverage"
    )
    if (all) {
      extra_metrics <- c(
        # "FNR (sign parity)"="epistemic_match_sign_fn",
        "FPR (sign parity)" = "epistemic_match_sign_fp",
        "Sign reversed" = "epistemic_match_sign_flip"
      )
      metrics <- c(metrics, extra_metrics)
    }
  } else {
    metrics <- c(
      "$\\Delta$ Strict parity" = "epistemic_match_margin",
      "$\\Delta$ Sign parity" = "epistemic_match_sign_margin",
      "$\\Delta$ CI coverage" = "coverage_margin"
    )
  }

  df <- df %>%
    pivot_longer(unname(metrics)) %>%
    mutate(
      alpha_str = paste0("$\\alpha=", alpha, "$"),
      name = fct_recode(
        as.factor(name),
        !!!metrics
      ) %>% fct_relevel(!!!names(metrics))
    )
  return(df)
}

clean_results_for_regression <- function(df, drop_top_cat = TRUE, ...) {
  print_counts("Initial sample: %d results, %d studies", df)
  log_info(sprintf(
    "Dropping %d results with no noised vars",
    df %>% filter(n_vars_noised <= 0) %>% distinct(study_id, result_id) %>% nrow()
  ))
  missing_match <- df %>% filter(is.na(epistemic_match))
  log_info(sprintf(
    "Imputing epistemic match 0 for %d rows with null epistemic_match",
    missing_match %>% distinct(study_id, result_id) %>% nrow()
  ))
  df <- df %>%
    filter(n_vars_noised > 0) %>%
    mutate(
      epistemic_match = replace_na(epistemic_match, 0)
    )
  dummies <- c("estimation_method_abbrv", "design", "stata_cmd_abbrv", "epistemic_claim_abbrv", "time_index_abbrv", "geographic_index_abbrv")
  print(df %>% select(all_of(dummies)) %>% summary())
  df <- df %>%
    dummy_cols_imputena(
      select_columns = dummies,
      remove_first_dummy = F,
      remove_most_frequent_dummy = drop_top_cat,
      ignore_na = F
    ) %>%
    mutate(
      n_vars_personal_x_df_model = n_vars_personal * df_model
    )
  n_results <- df %>%
    distinct(across(all_of(pk_results))) %>%
    nrow()
  n_sims <- df %>%
    distinct(sim_id) %>%
    nrow()
  treatments <- df %>% distinct(across(all_of(pk_treatments)))
  print(treatments)
  n_treatments <- treatments %>% nrow()
  log_info("Final regression df size {df %>% nrow()} = {n_results} x {n_sims} x {n_treatments} minus the above")
  log_info("Summarized to {df %>% nrow()} = {n_results} x {n_treatments}")
  df <- df %>%
    clean_for_regression(...)
  df %>%
    mutate(
      log_epistemic_match = log(1 + epistemic_match)
    )
}

clean_for_regression <- function(df, aggregate = T, grouping = pk_experiment_results) {
  to_transform <- c(
    "rmsd", "sensitivity", "epsilon",
    "avg_rmsd", "prop_noised",
    "sum_sensitivity", "avg_sensitivity", "sensitivity_norm_range",
    "rmsd_norm_range", "avg_rmsd_norm_range",
    "sum_avg_sensitivity",
    "sum_avg_sensitivity_norm", "sum_avg_sensitivity_norm_ind", "sum_avg_sensitivity_norm_dep",
    "avg_avg_sensitivity_norm", "sum_avg_sensitivity_norm_range",
    "N_original", "n_component_vars"
  )
  df <- df %>%
    mutate(
      across(any_of(to_transform), function(x) ifelse(x == 0, NA, log10(x)), .names = "log_{.col}"),
      # https://robjhyndman.com/hyndsight/transformations
      across(any_of(to_transform), asinh, .names = "asinh_{.col}")
    )
  df <- df %>%
    mutate(
      mechanism_str_gaussian = +(mechanism_str == "gaussian"),
      shrink_str_ml = +(shrink_str == "Morris-Lysy"),
      across(any_of(c(
        "log_sensitivity", "log_epsilon", "log_sensitivity_norm_range", "log_avg_sensitivity_norm_range",
        "asinh_sum_sensitivity", "log_sum_sensitivity", "log_sum_avg_sensitivity_norm", "asinh_sum_sensitivity_norm_range"
      )), ~ mechanism_str_gaussian * .x, .names = "{.col}_mechanism_str_gaussian"),
      across(c(starts_with("epistemic_claim_abbrv_"), starts_with("log_sum_avg_sensitivity_norm"), any_of(c(
        "any_reg_role_abbrv_ind", "any_reg_role_abbrv_dep", "avg_population_size", "df_model", "log_N_original", "r_stat_original"
      ))), ~ log_epsilon * .x, .names = "{.col}_log_epsilon")
    )
  if (aggregate) {
    df <- df %>%
      group_by(across(all_of(grouping))) %>%
      reg_summarize()
  }
  df
}

reg_summarize <- function(df) {
  df %>%
    summarise(
      across(any_of(c("epistemic_match", "sensitivity")), sum, .names = "sum_{.col}"),
      across(where(~ (n_distinct(.x) == 1)), first),
      across(where(is.numeric), mean),
      .groups = "drop"
    )
}

get_spec <- function(df, v) {
  df %>% select(matches(paste(v, sep = "|")))
}

get_models <- function(specs, ...) to_list(for (spec in specs) spec[["df"]] %>% lm_coeftest_parity(spec[["spec"]], study_fe = spec[["study_fe"]], depvar = spec[["outcome"]], ...))

coefs_matching <- function(models, expr) {
  unlist(sapply(models, function(model) {
    tidy(model) %>%
      filter(str_detect(term, expr)) %>%
      pull(term)
  }))
}

get_reg_df <- function(df, spec, depvar = "^epistemic_match$") {
  df <- df %>%
    get_spec(c(depvar, spec)) %>%
    rename(any_of(varnames_lookup))
  print(df %>%
    filter_at(vars(names(.)), any_vars(is.infinite(.) | is.na(.))) %>%
    select(study_id, where(function(x) any(is.na(x)))) %>%
    distinct())
  df
}

lm_coeftest_parity <- function(df, spec, depvar = "epistemic_match", study_fe = TRUE, cluster = "study_id") {
  # check that depvar exists
  assert_that(any(grepl(depvar, names(df))), msg = glue("No depvar {depvar} found"))
  assert_that(any(grepl(paste(spec, collapse = "|"), names(df))), msg = glue("No indvars {spec} found"))
  df <- get_reg_df(df, spec, depvar)
  data <- if (study_fe) df else df %>% select(-study_id)
  print(data)
  model <- data %>%
    lm()
  # glm(family=binomial(link="probit"))
  # glm(family=binomial(link="logit"))
  # glm(family=binomial(link="log"))

  qqnorm(model$residuals)
  qqline(model$residuals)
  plot(scale(predict(model)), rstandard(model))
  hist(model$residuals)
  hist(data %>% pull(1))

  vcov <- vcovCL(model, type = "HC1", cluster = df[[cluster]])
  robust <- model %>%
    coeftest(vcov = vcov, save = T)

  if ("epsilon_str" %in% names(df)) {
    epsilon_dummies <- robust %>%
      tidy() %>%
      filter(grepl("epsilon_str", term)) %>%
      mutate(
        epsilon = str_replace(term, "epsilon_str", "") %>% as.numeric(),
        ymin = ci_lb(estimate, std.error, alpha = different_threshold),
        ymax = ci_ub(estimate, std.error, alpha = different_threshold)
      ) %>%
      ggplot(aes(x = epsilon, y = estimate, ymin = ymin, ymax = ymax)) +
      geom_point() +
      geom_line() +
      geom_errorbar(alpha = 0.2) +
      geom_ribbon(alpha = 0.2) +
      scale_x_continuous(trans = ggforce::trans_reverser("log10")) +
      theme +
      ylab("Estimate") +
      xlab(expression(epsilon))

    print(epsilon_dummies)
  }

  robust
}

check_factors <- function(model, factors) {
  all_factors <- all(sapply(
    factors,
    function(f) any(tidy(model) %>% pull(term) %>% str_detect(f))
  ))
  return(if (all_factors) "Yes" else "No")
  # if (any(tidy(model) %>% pull(term) %>% str_detect(factors))) "Yes" else "No"
}

collapse_factor_reg <- function(tbl, models, label, factors, statlines = 3) {
  rownum <- nrow(tbl) - statlines
  labels <- sapply(models, check_factors, factors = factors)
  print(labels)
  if (all(labels == "No")) {
    return(tbl)
  }
  tbl %>%
    add_rows(
      c(label, labels),
      copy_cell_props = F,
      after = rownum - 1
    ) %>%
    set_align(rownum, final(length(models)), "center")
}


format_regression_output <- function(models, skinny=FALSE) {
  statistics <- c(
    "N. obs." = "nobs",
    "R squared" = "r.squared",
    "F statistic" = "statistic"
    # "p value" = "p.value"
  )
  coefs_to_omit <- coefs_matching(
    models,
    "study_id|result_id|component vars|% stat. type|Model degrees of freedom|Num. vars. noised"
  )
  print(coefs_to_omit)
  table <- huxreg(
    models,
    omit_coefs = coefs_to_omit,
    statistics = statistics,
    align = "center",
    note = "{stars}. Robust standard errors are clustered by study."
  ) %>%
    collapse_factor_reg(models, "Study FE", c("study_id"), statlines = length(statistics)) %>%
    collapse_factor_reg(models, "Result FE", c("result_id"), statlines = length(statistics)) %>%
    collapse_factor_reg(models, "Implementation controls", c(
      "Num. vars. noised", "component vars"
    ), statlines = length(statistics)) %>%
    collapse_factor_reg(models, "Query type controls", c(
      "% stat. type: count, log count"
    ), statlines = length(statistics)) %>%
    # collapse_factor_reg(models, "Stata command controls", c(
    #   "Cmd: ivreg, ivreg2, xtivreg2, ivregress, ivreghdfe"
    # ), statlines=length(statistics)) %>%
    # make statistics values centered
    # set_align(final(length(statistics)+1), final(length(models)), "center") %>%
    map_contents(by_function(replace_backticks)) %>%
    set_all_padding(0)
  # set_label("tab:regression") %>%
  # set_caption("Impact of mechanism & result characteristics on epistemic parity.")
  
  if (skinny) {
    # Force tabular (no tabularx)
    table <- set_tabular_environment(table, "tabular")
    # widths
    w_col1  <- "4.5cm"       # wrapped coef-name column
    w_note  <- "\\hsize" # note should not exceed table width
    cc <- contents(table)
    # col 1 as a plain character vector (prevents c("...") artifacts)
    col1 <- as.character(unlist(cc[, 1], use.names = FALSE))
    # Wrap rows 2..(last-1) in col 1 (leave header + note row alone)
    i_wrap <- 2:(nrow(cc) - 1)
    col1[i_wrap] <- sprintf("\\parbox[t]{%s}{%s}", w_col1, col1[i_wrap])
    # Make the last row (note) wrap within text width (still multicolumn)
    note_i <- nrow(cc)
    col1[note_i] <- gsub("<", "$<$", col1[note_i], fixed = TRUE)
    col1[note_i] <- sprintf("\\parbox[t]{%s}{\\raggedright\\strut %s}", w_note, col1[note_i])
    cc[, 1] <- col1
    contents(table) <- cc
    # Don’t escape the LaTeX we injected in col 1
    esc <- escape_contents(table)
    esc[i_wrap, 1] <- FALSE
    esc[note_i, 1] <- FALSE
    escape_contents(table) <- esc
  }
  
  table
}

replace_backticks <- function(x) {
  str_replace_all(x, "`", "")
}

# collapse_factor = function(tbl, label, factors, statlines=4) {
#   tbl %>%
#     add_rows(
#       c(label, sapply(models, check_factors, factors=factors)),
#       copy_cell_props=F,
#       after=nrow(.)-statlines-1
#     )
# }

# check_factors = function(model, factor) {
#   if (any(tidy(model) %>% pull(term) %>% str_detect(factor))) "Yes" else "No"
# }
