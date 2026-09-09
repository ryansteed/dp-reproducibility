load_tables <- function(name, dbs_to_include) {
  dfs <- lapply(dbs_to_include, function(x) read_sqlite(glue("results/experiments/{x}.db"), name))
  dplyr::bind_rows(dfs)
}

#' Load and join study results and metadata
#'
#' Load result records for a set of experiments/studies, join with study,
#' results and variable metadata, compute noise/sensitivity summaries and
#' return a tidy data.frame ready for analysis.
#'
#' @param experiments_to_include character vector of experiment ids to include
#' @param study_metadata data.frame with per-study metadata
#' @param results_metadata data.frame describing available result files
#' @param variables_metadata data.frame describing variable mappings
#' @param noise logical or data.frame with noise diagnostics
#' @param sensitivities logical or data.frame with sensitivity diagnostics
#' @return data.frame combined results with summary columns
#' @export
load_results <- function(experiments_to_include, study_metadata, results_metadata, variables_metadata, noise, sensitivities) {
  # load experiment configs
  experiments <- load_tables("experiments", dbs_to_include) %>%
    select(-c(time)) %>%
    filter(experiment_id %in% experiments_to_include)

  # load results
  results <- load_tables("results", dbs_to_include) %>%
    right_join(experiments, by = c(pk_experiments, "experiment_id"))
  print_antijoin("%d experiments with no results", experiments, results, pk_experiments)
  print_counts("Loaded %d saved results from %d studies", results)
  # require a full panel of runs for each experiment
  results <- results %>%
    clean_results() %>%
    fill_panel()

  # join in metadata
  print_antijoin("%d studies with no metadata", results, study_metadata, pk_studies)
  results_latest <- results %>%
    # only keep studies that are listed in the spreadsheet as implemented
    inner_join(study_metadata, by = "study_id")
  print_counts("Joined study metadata for %d results from %d studies", results_latest)

  print_antijoin("%d results with no metadata", results_latest, results_metadata, pk_results)
  print_antijoin("%d metadata with no results", results_metadata, results_latest, pk_results)
  print_antijoin("%d results with no variables", results_latest, variables_metadata, pk_results)
  print_antijoin("%d variables with no results", variables_metadata, results_latest, pk_results)
  length_before <- nrow(results_latest)
  print(results_latest[64003, ])
  results_latest <- results_latest %>%
    # only keep results that are listed in the spreadsheet
    inner_join(results_metadata, by = pk_results, relationship = "many-to-one") %>%
    summarize_variables(variables_metadata)
  print(length_before)
  print(results_latest)
  assert_that(nrow(results_latest) == length_before)
  print_counts("Joined results and variables/noise metadata for %d results from %d studies", results_latest)

  results_latest <- results_latest %>%
    summarize_noise(noise, variables_metadata, sensitivities) %>%
    summarize_sensitivity(variables_metadata, sensitivities) %>%
    summarize_population(noise)
  assert_that(nrow(results_latest) == length_before)
  print_counts("Joined noise/sensitivity summary for %d results from %d studies", results_latest)

  results_latest <- results_latest %>%
    filter(n_vars_noised > 0)
  print_counts("%d results from %d studies have noised variables", results_latest)

  results_latest
}

#' Summarize sample unit size information used by results
#'
#' Compute average sample unit sizes and related metadata for each result
#' by joining population variables to noise diagnostics.
#' @param df data.frame of results
#' @param df_noise data.frame of noise diagnostics
#' @return data.frame results augmented with population summary columns
#' @export
summarize_population <- function(df, df_noise) {
  population_sizes <- df_noise %>%
    # population size will be the same across treatments, but possibly different across datasets
    distinct(study_id, variable_id, dataset_name, original_mean)
  population_vars <- df %>%
    distinct(study_id, result_id, population_variable) %>%
    separate_rows(population_variable, sep = ",") %>%
    mutate(variable_id = trimws(population_variable)) %>%
    filter(!is.na(population_variable))
  join_key <- c("study_id", "variable_id")
  pops <- population_vars %>%
    left_join(
      population_sizes,
      by = join_key
    ) %>%
    # average, in the case of multiple datasets
    group_by(study_id, result_id) %>%
    summarise(
      avg_population_size = mean(original_mean, na.rm = TRUE),
      n_datasets_population = n_distinct(dataset_name),
      n_population_variables = n_distinct(population_variable),
      .groups = "drop"
    )
  # highlight missing population sizes
  print_antijoin("%d pop variables with no noise records", population_vars, population_sizes, join_key)
  # join pops back into df
  df <- df %>%
    left_join(pops, by = c("study_id", "result_id"))
  df
}

#' Summarize noise metrics per result
#'
#' Aggregates RMSD and normalized RMSD measures across component statistics
#' and joins the summary back into the result table.
#' @param df data.frame of results
#' @param df_noise data.frame of noise diagnostics
#' @param variables_metadata data.frame describing variables
#' @param df_sensitivities data.frame of sensitivity diagnostics
#' @return data.frame results augmented with noise summary
#' @export
summarize_noise <- function(df, df_noise, variables_metadata, df_sensitivities) {
  long <- df %>%
    join_noise_long(variables_metadata, df_noise)
  summ_noise <- long %>%
    group_by(across(all_of(pk_experiment_result_runs))) %>%
    summarise(
      avg_rmsd = mean(rmsd),
      avg_rmsd_norm = mean(rmsd_norm, na.rm = T),
      avg_rmsd_norm_range = mean(rmsd_norm_range, na.rm = T),
      avg_rmsd_norm_range_ind = mean(rmsd_norm_range[reg_role_abbrv == "ind"], na.rm = T),
      avg_rmsd_norm_range_dep = mean(rmsd_norm_range[reg_role_abbrv == "dep"], na.rm = T),
      .groups = "drop"
    )
  df <- df %>%
    left_join(summ_noise, by = pk_experiment_result_runs) %>%
    mutate(
      prop_noised = n_vars_noised / df_model
    )
  df
}

#' Summarize sensitivity metrics for results
#'
#' Convert sensitivity diagnostics to long form and compute aggregated
#' sensitivity metrics (sums, averages, counts) by the requested grouping.
#' @param df data.frame results or long sensitivity table
#' @param variables_metadata data.frame describing variables
#' @param df_sensitivities data.frame of raw sensitivity outputs
#' @param grouping character vector grouping columns (defaults to `pk_results`)
#' @param is_long logical if `df` is already in long sensitivity format
#' @return data.frame results augmented with sensitivity summaries
#' @export
summarize_sensitivity <- function(df, variables_metadata, df_sensitivities, grouping = pk_results, is_long = F) {
  if (is_long) {
    long <- df
  } else {
    long <- df %>%
      filter(!is_control) %>%
      select(all_of(grouping)) %>%
      # sensitivity info is no more specific than this key, so we can simplify
      distinct() %>%
      inner_join(variables_metadata, by = grouping, relationship = "many-to-many")
  }
  long_sensitivity <- join_sensitivity_long(long, df_sensitivities)
  assert_that(
    long_sensitivity %>% drop_na(sensitivity) %>% get_dupes(all_of(c(pk_result_variables, "component_variables"))) %>% nrow() == 0
  )

  summ_sens <- long_sensitivity %>%
    group_by(across(all_of(grouping))) %>%
    summarise(
      n_component_vars = n_distinct(component_variables),
      n_sens_gt_1 = sum(sens_gt_1),
      sum_sensitivity = sum(sensitivity, na.rm = T),
      avg_sensitivity = mean(sensitivity, na.rm = T),
      across(c("avg_sensitivity_norm", "avg_sensitivity_norm_range"), ~ mean(.x, na.rm = T), .names = "avg_{.col}"),
      across(c("avg_sensitivity_norm", "avg_sensitivity_norm_range"), ~ mean(.x[reg_role_abbrv == "ind"], na.rm = T), .names = "avg_{.col}_ind"),
      across(c("avg_sensitivity_norm", "avg_sensitivity_norm_range"), ~ mean(.x[reg_role_abbrv == "dep"], na.rm = T), .names = "avg_{.col}_dep"),
      across(c("avg_sensitivity_norm", "avg_sensitivity_norm_range"), ~ sum(.x, na.rm = T), .names = "sum_{.col}"),
      across(c("avg_sensitivity_norm", "avg_sensitivity_norm_range"), ~ sum(.x[reg_role_abbrv == "ind"], na.rm = T), .names = "sum_{.col}_ind"),
      across(c("avg_sensitivity_norm", "avg_sensitivity_norm_range"), ~ sum(.x[reg_role_abbrv == "dep"], na.rm = T), .names = "sum_{.col}_dep"),
      # default should be zero for these
      across(starts_with("sum_"), function(x) replace(x, is.na(x), 0)),
      .groups = "drop"
    )

  df <- df %>%
    left_join(summ_sens, by = grouping)
  df
}

#' Join sensitivity diagnostics to variable identifiers in long form
#'
#' @param df data.frame of variables (possibly filtered to noised vars)
#' @param df_sensitivities data.frame of sensitivity diagnostics
#' @return data.frame long sensitivity table keyed by variable and dataset
#' @export
join_sensitivity_long <- function(df, df_sensitivities) {
  # Join sensitivity stats to `variable_id`.

  sens <- df_sensitivities %>%
    select(-experiment_id) %>%
    # should be the same for every experiment, so just take unique
    distinct()
  # check for dupes to be sure
  assert_that(
    sens %>% get_dupes(all_of(c(pk_variables, "dataset_name"))) %>% nrow() == 0
  )

  long <- df %>%
    filter(noised == 1) %>%
    separate_rows(component_variables, sep = ", ") %>%
    mutate(
      component_variables = trimws(component_variables),
      component_variables = ifelse(
        # if component var is missing, no components; just itself
        is.na(component_variables), variable_id, component_variables
      )
    )
  join_key <- c(pk_variables, "component_variables")
  long_sensitivity <- long %>%
    left_join(
      sens,
      by = join_by(study_id, component_variables == variable_id),
      suffix = c("_sens", ""),
      relationship = "many-to-many" # can be entries for multiple datasets per variable
    )
  # print(long_sensitivity %>% names())
  long_sensitivity <- long_sensitivity %>%
    group_by(across(all_of(join_key))) %>%
    mutate(
      n_datasets = n(),
      # includes sensitivity greater than one
      sens_gt_1 = sum(sensitivity > 1, na.rm = T) > 0,
      avg_sensitivity_norm = mean(sensitivity_norm, na.rm = T), # average over datasets; in most cases will just equal first
      avg_sensitivity_norm_range = mean(sensitivity_norm_range, na.rm = T),
    ) %>%
    ungroup() %>%
    select(
      all_of(c(
        pk_result_variables,
        "component_variables",
        "reg_role_abbrv",
        "n_datasets",
        "sensitivity",
        "avg_sensitivity_norm_range",
        "avg_sensitivity_norm",
        "sens_gt_1"
      ))
    ) %>%
    distinct()

  long_sensitivity
}

#' Summarize variable-level metadata for each result
#'
#' Compute per-result counts of noised variables, data-dependent bounds,
#' and various dummy aggregations used by downstream summaries.
#' @param results data.frame of results
#' @param variables data.frame of variable metadata
#' @return data.frame results augmented with variable summaries
#' @export
summarize_variables <- function(results, variables) {
  # summarise
  dummies <- c(
    "query_type_abbrv",
    "query_type_simple",
    "reg_role_abbrv",
    "data_type_abbrv",
    "data_domain_abbrv"
  )
  summ <- variables %>%
    group_by(across(all_of(pk_results))) %>%
    summarise(
      n_data_dependent_bounds = sum(data_dependent_bounds, na.rm = T),
      n_vars_personal = sum(!is.na(noised)), # don't include vars that were not eligible for noise
      n_vars_noised = sum(noised, na.rm = T),
      all_noised = sum(noised == 0, na.rm = T) == 0, # noised == 0 means we ran into an issue
      prop_noised_success = n_vars_noised / n_vars_personal,
      # summarise the dummy cols
      across(starts_with(paste0(dummies, "_")), ~ sum(.x[noised == 1]), .names = "n_{.col}"),
      across(starts_with(paste0(dummies, "_")), ~ sum(.x[noised == 1]) / n_vars_noised, .names = "prop_{.col}"),
      across(starts_with(paste0(dummies, "_")), ~ +(sum(.x[noised == 1]) >= 1), .names = "any_{.col}"),
      reg_role_abbrv_ind_and_dep = any_reg_role_abbrv_ind * any_reg_role_abbrv_dep,
      .groups = "drop"
    ) %>%
    ungroup()

  results %>%
    left_join(summ, by = pk_results) %>%
    mutate(
      prop_noised = n_vars_noised / df_model
    )
}

count_factor_wide <- function(df, column) {
  df %>%
    drop_na(!!sym(column)) %>%
    mutate_at(
      column, ~ paste0(column, "_", .x)
    ) %>%
    count(study_id, result_id, !!sym(column)) %>%
    pivot_wider(names_from = !!sym(column), values_from = n, values_fill = 0)
}

load_noise <- function(experiments_to_include) {
  key <- c(pk_experiments, "sim_id", "experiment_id")
  noise <- load_tables("noise", dbs_to_include) %>%
    select(-c(time)) %>%
    filter(experiment_id %in% experiments_to_include) %>%
    clean_noise()
  # inner_join(results %>% distinct(across(all_of(key))), by=key)
  log_info("Noise loaded for {noise %>% distinct(study_id, variable_id) %>% nrow()} variables")
  dupes <- noise %>%
    get_dupes(all_of(c("experiment_id", pk_noise)))
  print(dupes)
  assert_that(
    dupes %>% nrow() == 0,
    msg = "Found dupes in noise"
  )
  noise
}

load_sensitivity <- function(db) {
  load_tables("sensitivity", c(db)) %>%
    select(-c(time)) %>%
    # only use passed experiment
    # filter(experiment_id == db) %>%
    # select(-experiment_id) %>%
    clean_sensitivity()
}

load_study_metadata <- function(path="data/studies.csv") {
  study_metadata <- read.csv(path, na.strings = "") %>%
    clean_study_metadata()
  log_info("Loaded metadata for studies: {study_metadata %>% distinct(study_id) %>% nrow()}")
  study_metadata
}

load_results_metadata <- function() {
  results_metadata <- read.csv("data/estimates.csv", na.strings = "") %>%
    clean_results_metadata()
  log_info("Loaded metadata for results: {results_metadata %>% distinct(result_id) %>% nrow()}")
  results_metadata
}

load_variables_metadata <- function(results_metadata) {
  variables_metadata <- read.csv("data/variables.csv", na.strings = "", skip = 1) %>%
    clean_variables_metadata(results_metadata)
  log_info("Loaded metadata for variables: {variables_metadata %>% distinct(variable_id) %>% nrow()}")
  variables_metadata
}

read_sqlite <- function(path_to_db, table) {
  con <- dbConnect(RSQLite::SQLite(), path_to_db)
  # table = dbReadTable(con, table)
  q <- paste("SELECT * FROM", table)
  if (table == "noise") {
    q <- paste("SELECT CAST(original_min AS REAL), CAST(original_max AS REAL), * FROM", table, "WHERE typeof(original_min) != 'blob'")
  }
  df <- dbGetQuery(conn = con, statement = q)
  dbDisconnect(con)
  return(df)
}

# fct_reorg = function(fac, ...) {
#   fct_relevel(fct_recode(fac, ...), names(rlang::dots_list(...)))
# }

print_antijoin <- function(msg, df1, df2, key) {
  df <- df1 %>% anti_join(df2, by = key)
  if (nrow(df) > 0) {
    log_warn(sprintf(msg, nrow(df %>% distinct(across(all_of(key))))))
    print(df %>% distinct(across(all_of(key))))
  }
}

print_counts <- function(msg, df, save_num_studies = NULL, save_num_results = NULL) {
  num_results <- df %>%
    distinct(across(all_of(pk_results))) %>%
    nrow()
  num_studies <- df %>%
    distinct(study_id) %>%
    nrow()
  log_info(sprintf(
    paste(msg, "(%d rows)"),
    num_results,
    num_studies,
    nrow(df)
  ))
  if (!is.null(save_num_studies)) {
    report(save_num_studies, num_studies)
  }
  if (!is.null(save_num_results)) {
    report(save_num_results, num_results)
  }
}

fill_panel <- function(df) {
  panel <- get_panel_keys(df)
  partial_panel <- df %>%
    filter(!is_control & n_sims < num_sims) %>%
    distinct(across(all_of(pk_experiment_results)), n_sims)
  # missing panels --- for now, impute as NAs, assuming authors' code has failed entirely
  if (nrow(partial_panel) > 0) {
    log_warn("Filling with NAs for experiments with < {num_sims} sims: {partial_panel %>% nrow()}")
    print(partial_panel)
  }

  df$is_null_result <- FALSE
  df <- df %>%
    right_join(panel, by = pk_experiment_result_runs) %>%
    mutate(is_null_result = replace_na(is_null_result, TRUE)) %>% # mark all rows that were filled in (rows with no results), except controls
    format_treatments() # again, to get the NAs introduced by fill

  # impute model degrees of freedom for missing rows from control
  df_model_lookup <- df %>%
    filter(is_control) %>%
    distinct(across(all_of(c(pk_results, "df_model"))))
  assert_that(nrow(df_model_lookup) == df_model_lookup %>%
    distinct(across(all_of(pk_results))) %>%
    nrow())
  df <- df %>%
    select(-df_model) %>%
    left_join(df_model_lookup, by = pk_results)

  assert_that(nrow(df) == nrow(panel))
  df
}

get_panel_keys <- function(df) {
  treatments <- df %>%
    # treatment vars
    distinct(across(all_of(pk_treatments))) %>%
    expand_grid() %>% # get all combos of these variables
    expand_grid(df %>% distinct(across(all_of(c(pk_results)))))
  print_antijoin("%d treatments with no results", treatments, df, pk_experiment_results)
  # check dimensions are correct
  dim_results <- df %>%
    select(all_of(pk_results)) %>%
    n_distinct()
  dim_treatments <- df %>%
    select(all_of(pk_treatments)) %>%
    n_distinct()
  assert_that(
    nrow(treatments) == dim_results * dim_treatments
  )
  panel <- treatments %>%
    uncount(10, .id = "sim_id") %>%
    mutate(sim_id = sim_id - 1) # 0-indexing
  sprintf(
    "Expecting panel with dimensions %d x %d = %d",
    treatments %>% nrow(),
    num_sims,
    panel %>% nrow()
  )
  assert_that(
    nrow(panel) == nrow(treatments) * 10
  )
  panel
}

format_keys <- function(df) {
  df %>%
    mutate(
      across(all_of(pk_treatments), ~ case_when(
        .x == "None" | is.na(.x) ~ "Original",
        .default = .x
      )),
      # custom default names instead of original
      across(c(a_str, b_str, shrink_str, imputations_str), ~ replace(.x, .x == "Original", "None")),
      # remove after decimal
      epsilon_str = ifelse(
        epsilon_str == "Original",
        epsilon_str,
        sub(".0+$", "", epsilon_str)
      ),
      # convert to factors
      across(all_of(pk_treatments), as.factor)
    )
}

make_shrink_b_str <- function(df) {
  df %>%
    mutate(
      # combined key for shrink and b
      shrink_b_str = case_when(
        b_str == "None" ~ shrink_str,
        # shrink_str == "None" & b_str != "None" ~ b_str,
        .default = paste0(shrink_str, ", b=", b_str)
      )
    )
}

make_mechanism_mo_str <- function(df) {
  df %>%
    mutate(
      # combined key for shrink and b
      mechanism_mo_str = case_when(
        imputations_str == "None" ~ mechanism_str,
        # shrink_str == "None" & b_str != "None" ~ b_str,
        .default = paste0(mechanism_str, "_mo")
      )
    )
}

epsilon_to_latex <- function(epsilon) {
  case_when(
    is.na(epsilon) ~ "Original",
    epsilon > 1000 | epsilon <= 0.01 ~ paste0("$10^{", round(log10(epsilon)), "}$"),
    .default = paste0("$", as.character(epsilon), "^{\\,}$")
  )
}

latex_to_epsilon <- function(epsilon_str) {
  case_when(
    epsilon_str == "Original" ~ NA_real_,
    str_detect(epsilon_str, "\\$10\\^\\{(-?\\d+)\\}\\$") ~ 10^as.numeric(str_match(epsilon_str, "\\$10\\^\\{(-?\\d+)\\}\\$")[, 2]),
    # otherwise, just strip out everything except the numbers and decimal
    .default = as.numeric(str_replace_all(epsilon_str, "[^0-9\\.]", ""))
  )
}

format_treatments <- function(df) {
  df %>%
    mutate(
      across(
        c(epsilon_str, a_str, b_str, imputations_str),
        ~ as.character(.x) %>%
          na_if("Original") %>%
          na_if("None") %>%
          as.numeric(),
        .names = "{gsub('_str', '', .col)}"
      ), # create numeric versions
      across(c(epsilon, a, b), log, .names = "log_{.col}"),
      # recode and relevel
      across(c(cscale_str, mechanism_str), ~ fct_relevel(.x, "Original")),
      shrink_str = fct_recode(shrink_str, "Hudson-Berger" = "hudson-berger", "Morris-Lysy" = "morris-lysy"),
      across(c(a_str, b_str, shrink_str), ~ fct_relevel(.x, "None")),
      # special versions
      epsilon_str_sci = case_when(
        is.na(epsilon) ~ "Original",
        epsilon > 1000 | epsilon <= 0.001 ~ format(epsilon, scientific = T),
        .default = epsilon_str
      ),
      epsilon_str_latex = epsilon %>% epsilon_to_latex(),
      across(c(epsilon_str, epsilon_str_sci, epsilon_str_latex), function(x) {
        fct_relevel(
          fct_reorder(as.factor(x), desc(epsilon), .na_rm = F), "Original"
        )
      }),
      epsilon_str_eq = fct_rev(as.factor(ifelse(
        epsilon_str == "Original",
        "Original",
        paste0("epsilon==", as.character(epsilon_str))
      ))),
      a_str_eq = fct_rev(as.factor(ifelse(
        a_str == "Original",
        "Original",
        paste0("c==", as.character(a_str))
      ))),
      cscale_str = factor(
        cscale_str,
        levels = c(
          "Original" = "Original",
          "Static" = "static",
          "Value scaling" = "est"
        )
      ),
      is_dp = epsilon_str != "Original",
      is_error = cscale_str != "Original",
      is_mo = imputations_str != "None",
      is_control = !(is_dp | is_error | is_mo)
    ) %>%
    make_shrink_b_str() %>%
    make_mechanism_mo_str()
}

effect_sizes_ordered <- c(
  "Large (r > 0.6)",
  "Moderate (0.4 < r < 0.6)",
  "Small (0.2 < r < 0.4)",
  "Very small (0 < r < 0.2)",
  "Very small (-0.2 < r < 0)",
  "Moderate (-0.6 < r < -0.4)",
  "Small (-0.4 < r < -0.2)",
  "Large (r < -0.6)"
)
label_effect_size <- function(d) {
  factor(case_when( # https://cran.r-project.org/web/packages/effectsize/vignettes/interpret.html
    d > 0.6 ~ "Large (r > 0.6)",
    d > 0.4 ~ "Moderate (0.4 < r < 0.6)",
    d > 0.2 ~ "Small (0.2 < r < 0.4)",
    d > 0 ~ "Very small (0 < r < 0.2)",
    d < -0.6 ~ "Large (r < -0.6)",
    d < -0.4 ~ "Moderate (-0.6 < r < -0.4)",
    d < -0.2 ~ "Small (-0.4 < r < -0.2)",
    d < 0 ~ "Very small (-0.2 < r < 0)",
    .default = NA,
  ), levels = effect_sizes_ordered)
}

clean_results <- function(df) {
  df <- df %>%
    mutate(
      across(all_of(c("study_id", "result_id")), as.factor),
      across(where(function(x) class(x) == "integer64"), as.numeric)
    ) %>%
    format_keys() %>%
    mutate(
      time = as.POSIXct(time),
      year = as.integer(str_extract(study_id, "[^-]+$")),
      years_since_publication = 2025 - year,
      study_id_abbrv = str_to_title(paste0(substr(study_id, 1, 2), "'", str_sub(study_id, start = -2))),
      df_model = ifelse(
        is.na(df_m) | df_m == 0, # happens for certain models in stata; in these cases df_r is usually correct
        df_r,
        df_m
      ),
    ) %>%
    format_treatments()

  # resolve any repeated results by taking the most recent
  # in case a given result is not unique (i.e. upsert has failed),
  # take only the most recent
  df <- df %>%
    take_most_recent(pk_experiment_result_runs)

  # repeat the control to achieve full panel
  results_control <- df %>%
    filter(is_control)
  assert_that(
    results_control %>% get_dupes(all_of(pk_experiment_results)) %>% nrow() < 1,
    msg = "Controls contain duplicates"
  )
  results_control_rep <- results_control %>%
    select(-sim_id) %>%
    uncount(num_sims, .id = "sim_id") %>%
    mutate(sim_id = sim_id - 1) # match python indexing

  assert_that(
    nrow(results_control) * num_sims == nrow(results_control_rep)
  )
  results_rep <- df %>%
    filter(!is_control) %>%
    bind_rows(results_control_rep)
  assert_that(
    nrow(results_rep) == nrow(df) + (num_sims - 1) * nrow(results_control)
  )

  # count number of runs
  results_rep <- results_rep %>%
    group_by(across(all_of(pk_experiment_results))) %>%
    mutate(n_sims = n_distinct(sim_id)) %>%
    ungroup() %>%
    mutate(row_label = paste(as.character(study_id_abbrv), as.character(result_id)))

  # check for duplicates
  assert_that(
    results_rep %>% get_dupes(all_of(pk_experiment_result_runs)) %>% nrow() < 1,
    msg = "Found duplicates"
  )

  results_rep
}

take_most_recent <- function(df, key) {
  # resolve any repeated results by taking the most recent
  # in case a given result is not unique (i.e. upsert has failed),
  # take only the most recent
  repeats <- df %>%
    get_dupes(all_of(key))
  log_warn(sprintf("Found %d repeated results; taking the most recent.", nrow(repeats)))
  print(repeats)
  df <- df %>%
    group_by(across(all_of(key))) %>%
    slice(which.max(time)) %>%
    ungroup()
}

original_stats <- c("original_mean", "original_std", "original_min", "original_max")

clean_sensitivity <- function(df) {
  df <- df %>%
    janitor::clean_names() %>%
    dplyr::rename(
      variable_id = variable,
      dataset_name = dataset
    ) %>%
    mutate(
      across(all_of(c("sensitivity", original_stats)), as.numeric),
      sensitivity_norm = sensitivity / abs(original_mean),
      original_range = abs(original_max - original_min),
      sensitivity_norm_range = sensitivity / original_range,
      across(c(sensitivity_norm, sensitivity_norm_range), ~ replace(.x, is.infinite(.x), NA))
    )
  df
}

clean_noise <- function(df) {
  df <- df %>%
    janitor::clean_names() %>%
    dplyr::rename(
      variable_id = variable,
      dataset_name = dataset,
    ) %>%
    mutate(
      across(all_of(c("rmsd", "rmsd_norm", original_stats)), as.numeric),
      original_range = abs(original_max - original_min),
      # if the range is nonexistent, this was a preprocessed var and these stats are useless; drop
      across(all_of(original_stats), ~ replace(.x, original_range <= 0, NA)),
      rmsd_norm = rmsd / abs(original_mean),
      log_rmsd_norm = log(rmsd_norm),
      rmsd_norm_range = rmsd / original_range,
      across(c(rmsd_norm, rmsd_norm_range), ~ replace(.x, is.infinite(.x), NA))
    ) %>%
    format_keys()
  print(df %>% filter(study_id == "autor-2013") %>% select(study_id, variable_id, dataset_name, starts_with("rmsd"), starts_with("original")))
  df
}

join_noise_long <- function(df, variables_metadata, df_noise) {
  df <- df %>%
    filter(!is_control) %>%
    inner_join(variables_metadata, by = pk_results, relationship = "many-to-many") %>%
    inner_join(df_noise, by = c(pk_experiment_variable_runs, "experiment_id"), relationship = "many-to-many", suffix = c("", ".noise"))
  df
}

clean_study_metadata <- function(study_metadata) {
  study_metadata <- study_metadata %>%
    janitor::clean_names()
  # filter(grepl("Yes", suitable, ignore.case=F) | (grepl("probably", suitable, ignore.case=T) & !grepl("probably not", suitable, ignore.case=T)))

  num_studies_attempted <- study_metadata %>%
    filter(implemented %in% c(1, -1)) %>%
    nrow()
  num_studies_failed <- study_metadata %>%
    filter(implemented == -1) %>%
    nrow()
  if(num_studies_attempted > 93) {
    report("numStudiesAttempted", num_studies_attempted)
    report("numReplicationsFailed", num_studies_failed)
  }
  log_info("{num_studies_attempted} studies attempted (implemented not NA)")
  log_info("{num_studies_failed} studies failed (implemented -1)")
  log_info("{study_metadata %>% filter(implemented == 1) %>% nrow()} studies implemented (implemented 1)") 

  # sprintf("Loaded %d papers from spreadsheet", study_metadata %>% nrow())
  study_metadata <- study_metadata %>%
    filter(implemented == 1) %>%
    mutate(
      journal = str_to_title(journal),
      source = case_when(
        startsWith(source, "https://www.openicpsr.org") ~ "OpenICPSR",
        .default = source
      )
    ) %>%
    mutate_at(
      c("study_id", "journal", "language", "source"),
      as.factor
    ) %>%
    mutate(
      jel_code = jel_econ_lit_if_avail,
      journal_abbrv = fct_collapse(
        journal,
        "American Economic Review" = c("American Economic Review: Insights", "American Economic Review", "American Economic Review: Papers & Proceedings"),
        "American Economic Journal" = c(
          "American Economic Journal",
          "American Economic Journal: Economic Policy",
          "American Economic Journal: Applied Economics",
          "American Economic Journal: Macroeconomics"
        )
      ),
      source = fct_recode(
        source,
        # "ReplicationWiki"="https://replication.uni-goettingen.de/",
        "Find Economic Articles with Data" = "https://ejd.econ.mathematik.uni-ulm.de/"
      )
    ) %>%
    select(
      study_id, source, search_term, journal, journal_abbrv, language, jel_code, semantic_scholar_citation_count
    )
  # print(study_metadata %>% filter(!complete.cases(.)))
  study_metadata
}

expand_jel <- function(results) {
  # join in JEL codes & descriptions using https://www.aeaweb.org/econlit/classificationTree.xml
  jel_tree <- tibble::as_tibble(xml2::as_list(xml2::read_xml("data/jel-tree.xml")))
  for (level in c(1, 2, 3)) {
    jel_tree <- jel_tree %>%
      hoist(
        data,
        code = "code",
        description = "description",
      ) %>%
      rename_with(
        ~ paste0(.x, "_", level), c("code", "description")
      ) %>%
      unnest_longer(c(sprintf("code_%s", level), sprintf("description_%s", level)))
    if (level < 3) {
      jel_tree <- jel_tree %>%
        unnest_longer(data) %>%
        select(-data_id)
    }
  }
  jel_tree <- jel_tree %>% rename_with(~ paste0("jel_", .x))
  results %>%
    separate_rows(jel_code, sep = ", ") %>%
    left_join(jel_tree, by = join_by(jel_code == jel_code_3)) %>%
    rename(jel_code_3 = jel_code) %>%
    mutate(
      jel_description_1_abbrv = fct_recode(
        as.factor(jel_description_1),
        "Agri. & Nat. Resource/Env. & Ecolog." = "Agricultural and Natural Resource Economics &bull; Environmental and Ecological Economics",
        "Macroeconomics/Monetary" = "Macroeconomics and Monetary Economics",
        "Urban/Rural/Regional/Real Est./Transp." = "Urban, Rural, Regional, Real Estate, and Transportation Economics",
        "Econ. Dev./Innovation/Tech Change/Growth" = "Economic Development, Innovation, Technological Change, and Growth",
        "Labor/Demographic" = "Labor and Demographic Economics"
      )
    )
}

clean_results_metadata <- function(results_metadata) {
  fctrs <- c("study_id", "result_id", "dv_rq_importance", "estimation_method", "design", "stata_cmd", "time_index", "geographic_index", "other_indices")
  results_metadata <- results_metadata %>%
    janitor::clean_names() %>%
    rename(
      dv_rq_importance = research_question_importance
    ) %>%
    mutate(
      individual_level = as.logical(individual_level == "Yes"),
      across(pk_results, str_trim),
      across(all_of(fctrs), ~ as.factor(trimws(.x))),
      across(all_of(c("claim_in_abstract")), as.logical),
      dv_rq_importance_abbrv = fct_collapse(
        dv_rq_importance,
        "Primary/Co-primary" = c("Primary", "Co-primary")
      ),
      dv_rq_primary = as.logical(grepl("primary", dv_rq_importance, ignore.case = T)),
      stata_cmd_abbrv = fct_collapse(
        stata_cmd,
        "ivreg, ivreg2, xtivreg2, ivregress, ivreghdfe" = c("ivreg", "ivreg2", "ivregress", "xtivreg2", "ivreghdfe"),
        "reg, xtreg, areg, reghdfe" = c("reg", "regress", "xtreg", "areg", "reghdfe"),
        "probit, dprobit" = c("probit", "dprobit"),
        "other" = c("arima", "nbreg")
      ),
      design = fct_reorder(
        design, -as.integer(str_detect(design, "Panel")),
        .na_rm = F # put panel last
      ),
      estimation_method_abbrv = fct_collapse(
        estimation_method,
        "IV" = c("IV", "2SLS", "TSLS"),
        "DD/DDD" = c("DD", "DDD", "DID"),
        "RD" = c("RD", "RDD"),
        "other" = c("Binomial")
      ),
      time_index = fct_collapse(
        time_index,
        "year" = c("year", "Year"),
        "day" = c("day", "Day"),
        "month" = c("month", "Month")
      ),
      time_index_abbrv = fct_collapse(
        time_index,
        ">1 year" = c("2 years", "4 years", "6 years", "decade"),
        "month/quarter" = c("month", "Quarter")
      ),
      geographic_index = fct_collapse(
        geographic_index,
        "U.S. state" = c("U.S. state", "state"),
        "U.S. commuting zone" = c("U.S. Commuting Zone", "Commuting zone"),
        "MSA" = c("Metropolitan Statistical Area (MSA)", "MSA"),
        "country" = c("Country", "country")
      ),
      geographic_index_abbrv = fct_collapse(
        geographic_index,
        "State, district, province (1st division)" = c("U.S. state", "Brazilian SPMA district", "Italian province", "Indian states", "Medicare coverage region"), # medicare coverage region; just 34 in U.S.
        "County, tract, block (group), district, prefecture, residency, university (<1st division)" = c(
          "U.S. county", "U.S. census block", "U.S. census block group", "Indian district", "English district",
          "Chinese prefecture", "German county", "English district", "French district",
          "U.S. school district", "Indonesian residency", "U.S. census tract"
        ),
        "City/municipality/village, U.S. commuting zone/MSA/CBSA/Brazilian AMC" = c(
          "city", "village", "U.S. commuting zone", "MSA", "municipality", "Swiss municipality", "Brazilian municipality", "Indonesian village", "Mexican municipality", "Brazilian AMCs", "Core-based statistical areas", "municipal"
        ),
        "Organization (school, university, police unit)" = c("Pacifying Police Unit (UPP)", "school", "college", "university"),
        "Nation/country" = c("nation", "country")
      ),
      has_other_index = !is.na(other_indices)
    ) %>%
    select(
      all_of(pk_results), claim_in_abstract, region_of_qualitative_similarity, dv_rq_primary, individual_level, population_variable,
      starts_with(fctrs)
    )
  for (cat in results_metadata %>%
    select(ends_with("abbrv")) %>%
    names()) {
    print(results_metadata %>% count(!!sym(cat)) %>% arrange(desc(n)))
  }
  results_metadata
}

clean_variables_metadata <- function(metadata, results_metadata) {
  variables_long <- metadata %>%
    janitor::clean_names() %>%
    separate_rows(result_ids, sep = ", ") %>%
    rename(result_id = result_ids) %>%
    mutate_at(pk_results, str_trim) %>%
    mutate_at(
      c("study_id", "result_id", "variable_id", "query_type", "reg_role", "data_type", "data_domain", "dataset_publisher", "dataset"),
      as.factor
    ) %>%
    mutate(
      noised = as.logical(noised),
      data_dependent_bounds = data_dependent_bounds == 1,
      query_type_abbrv = fct_collapse(
        query_type,
        "count" = c("count", "count / invariant", "count * invariant"),
        "log count" = c("log count", "log count / invariant", "log (count + 1)", "log sum of counts"),
        "sum" = c("sum", "sum * invariant"),
        "count-count" = c("count - count", "count-count"),
        "mean" = c("sum / count", "count / count", "invariant / count", "invariant * count / count", "sum / invariant", "count / count * invariant"),
        "log mean" = c("log mean", "log invariant / count", "log sum / count", "log (count / count)", "log(count / count) * invariant", "log(invariant / count)", "log (count / count + 1)", "log(invariant / count)", "log count - log count", "log (sum / invariant)", "sum(counts) / count", "log invariant / mean"),
        "mean-mean" = c("change in count / count", "count / count - count / count", "(sum / count) - (sum / count)"),
        "mean*mean" = c("count / count * count / count"),
        "ratio" = c("sum / sum", "invariant / sum", "count / sum", "(count - count) / count", "(count - count) / (count - count)", "count / (count + count)", "count / sum(count)"),
        "median" = c("median", "median / invariant", "median * invariant"),
        "boolean/categorical" = c("boolean", "categorical", "boolean * boolean", "boolean * invariant"),
        "ratio ^ 2" = c("(count / count) ^ 2")
      ),
      query_type_simple = fct_collapse(
        query_type_abbrv,
        "count" = c("count", "log count"),
        # "mean_type"=c("mean", "mean-mean", "log mean", "mean*mean"),
        "mean" = c("mean", "log mean"),
        "ratio" = "ratio",
        "median" = "median",
        "boolean/categorical" = "boolean/categorical",
        other_level = "other"
      ),
      reg_role_abbrv = fct_collapse(
        reg_role,
        "dep" = c("dep", "instrumented"),
        "other" = c(
          "custom computation",
          "weights",
          "subset"
        )
      ),
      # use string replace b/c these can be comma separated
      data_type_abbrv = str_replace_all(
        data_type,
        "Estimates",
        "Blended"
      ),
      data_domain = str_replace_all(
        data_domain,
        c(
          "birth nation" = "foreign",
          "geography only" = "population",
          "ballot|vote" = "election",
          "employment/occupation" = "occupation/employment"
        )
      ),
      data_domain_abbrv = str_replace_all(
        data_domain,
        c(
          "income|taxes" = "income/taxes",
          "race/ethnicity|foreign" = "race/ethnicity/foreign"
        )
      )
    ) %>%
    drop_na(result_id)

  print(variables_long %>% count(query_type_abbrv) %>% arrange(desc(n)))
  print(variables_long %>% count(reg_role_abbrv) %>% arrange(desc(n)))

  # mapping of studies to all available results
  study_id_to_result_id <- results_metadata %>%
    select(study_id, result_id) %>%
    distinct()

  variables_long <- variables_long %>%
    # vars with result_id "all" match with everything
    filter(result_id == "all") %>%
    select(-result_id) %>%
    left_join(study_id_to_result_id, by = "study_id", relationship = "many-to-many", keep = F) %>%
    # otherwise, keep as is
    bind_rows(variables_long %>% filter(result_id != "all"))

  dummies <- c(
    "query_type_abbrv",
    "query_type_simple",
    "reg_role_abbrv",
    "data_type_abbrv",
    "data_domain_abbrv"
  )
  variables_long <- variables_long %>%
    dummy_cols(
      select_columns = dummies,
      split = "," # for vars with multiple cats
    )

  variables_long
}

expand_data_domain <- function(df) {
  df %>%
    separate_rows(data_domain, sep = ", ") %>%
    mutate(
      data_domain = fct_recode(
        as.factor(data_domain),
        "foreign" = "birth nation",
        "vote" = "ballot"
      ),
      data_domain_abbrv = fct_collapse(
        data_domain,
        "occupation/employment" = c("occupation", "occupation/employment", "employment"),
        "income/taxes" = c("income", "taxes"),
        "race/ethnicity" = c("race/ethnicity", "race"),
        "nationality/immigration" = c("foreign", "immigration", "nationality"),
        "sex/gender" = c("sex/gender", "gender"),
        "urban/suburban/rural" = c("urban/suburban/rural", "urban/suburban", "urban/surburban/rural"),
        "voting/elections" = c("vote", "voting", "election"),
        "housing/tenancy" = c("housing", "homeownership/tenancy", "homeownership", "tenancy"),
        "medical/disability" = c("medical", "disability"),
        "education/attendance" = c("education", "attendance"),
        "population" = c("population", "geography", "geography only"),
        "children" = c("household", "children")
      )
    )
}

# adapted from https://github.com/sfirke/janitor/blob/main/R/get_dupes.R
get_dupes <- function(dat, ...) {
  expr <- rlang::expr(c(...))
  pos <- tidyselect::eval_select(expr, data = dat)
  # Check if dat is grouped and if so, save structure and ungroup temporarily
  is_grouped <- dplyr::is_grouped_df(dat)
  if (is_grouped) {
    dat_groups <- dplyr::group_vars(dat)
    dat <- dat %>% dplyr::ungroup()
    if (getOption("get_dupes.grouped_warning", TRUE) && interactive()) {
      message(paste0("Data is grouped by [", paste(dat_groups, collapse = "|"), "]. Note that get_dupes() is not group aware and does not limit duplicate detection to within-groups, but rather checks over the entire data frame. However grouping structure is preserved.\nThis message is shown once per session and may be disabled by setting options(\"get_dupes.grouped_warning\" = FALSE).")) # nocov
      options("get_dupes.grouped_warning" = FALSE) # nocov
    }
  }
  if (rlang::dots_n(...) == 0) { # if no tidyselect variables are specified, check the whole data.frame
    var_names <- names(dat)
    nms <- rlang::syms(var_names)
    message("No variable names specified - using all columns.\n")
  } else {
    var_names <- names(pos)
    nms <- rlang::syms(var_names)
  }
  dupe_count <- NULL # to appease NOTE for CRAN; does nothing.
  dupes <- dat %>%
    dplyr::add_count(!!!nms, name = "dupe_count") %>%
    dplyr::filter(dupe_count > 1) %>%
    dplyr::select(!!!nms, dupe_count, dplyr::everything()) %>%
    dplyr::arrange(dplyr::desc(dupe_count), !!!nms)
  # shorten error message for large data.frames
  if (length(var_names) > 10) {
    var_names <- c(var_names[1:9], paste("... and", length(var_names) - 9, "other variables"))
  }
  # if (nrow(dupes) == 0) {
  #   message(paste0("No duplicate combinations found of: ", paste(var_names, collapse = ", ")))
  # }
  # Reapply groups if dat was grouped
  if (is_grouped) dupes <- dupes %>% dplyr::group_by(!!!rlang::syms(dat_groups))
  dupes
}
