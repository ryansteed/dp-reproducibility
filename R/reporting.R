### For results reporting

report_path <- "results/reported.csv"
report_latex_path <- "results/reported.tex"

##' Save the runtime report CSV
##'
##' Persist an internal report data.frame to `results/reported.csv`.
##' @param report_df data.frame to save
##' @return invisible(NULL)
save_report <- function(report_df) {
  write.csv(report_df, report_path, row.names = FALSE)
}

##' Load the runtime report CSV
##'
##' Ensure the report CSV exists and return it as a tibble.
##' @return tibble of reported values
load_report <- function() {
  if (!file.exists(report_path)) {
    # create an empty csv file with columns
    skeleton <- data.frame(
      "name" = "nRuns",
      "value" = as.character(num_sims),
      "note" = "",
      "date" = Sys.Date()
    )
    save_report(skeleton)
  }
  return(readr::read_csv(report_path, col_types = "cccD"))
}

##' Add or update a reported key/value
##'
##' Upsert a name/value pair into the runtime report and regenerate LaTeX
##' definitions used in builds.
##' @param name string key
##' @param value value to store (will be coerced to character)
##' @param add_pct_sign logical append percent sign when writing
##' @param note optional note string
##' @return invisible(NULL)
report <- function(name, value, add_pct_sign = F, note = "") {
  value <- as.character(value)
  if (add_pct_sign) {
    value <- sprintf("%s\\%%", value)
  }
  report <- load_report() %>%
    rows_upsert(tibble(
      "name" = name,
      "value" = value,
      "note" = note,
      "date" = Sys.Date()
    ), by = c("name"))
  report %>% write.csv(report_path, row.names = FALSE)
  report %>% report_to_latex()
}

##' Retrieve a reported value by name
##'
##' @param name string key
##' @return character value from report or character(0) if missing
get_report <- function(name) {
  load_report() %>%
    filter(name == !!name) %>%
    pull(value)
}

##' Render report key/values to LaTeX macro definitions
##'
##' Write a small LaTeX file with \newcommand macros for use in build.
##' @param report data.frame or tibble of report rows (name, value, note, date)
##' @return invisible(NULL)
report_to_latex <- function(report) {
  if (file.exists(report_latex_path)) file.remove(report_latex_path)
  write("%%% AUTOMATICALLY GENERATED %%%", file = report_latex_path, append = TRUE)
  for (i in 1:nrow(report)) {
    row <- report[i, ]
    line <- sprintf(
      "\\newcommand{\\%s}{%s} %%%s [%s]",
      row$name,
      row$value,
      ifelse(is.na(row$note), "", paste0(" ", row$note)),
      row$date
    )
    write(line, file = report_latex_path, append = TRUE)
  }
}

report("nRuns", num_sims)
report("defaultSigEP", different_threshold)
report("defaultConfidence", 100 * (1 - different_threshold))
report("epistemicSignificanceLevelDefault", 100 * different_threshold, add_pct_sign = TRUE)


##' Extract coefficient estimate from model by term
##'
##' Helper to pull an estimated coefficient from a model object and map
##' the human-readable term to the internal variable name via `varnames_lookup`.
##' @param model model object (matrix-like)
##' @param term human readable term label
##' @return numeric coefficient value
get_coef <- function(model, term) {
  coefs <- model[, ] %>%
    as_tibble() %>%
    mutate(term = rownames(model))
  term <- "`%s`" %>% sprintf(varnames_lookup_inv[[term]])
  coefs %>%
    filter(term == !!term) %>%
    pull(Estimate)
}

##' Convert a number to an English CamelCase string
##' @param num numeric value
##' @return character CamelCase representation
to_english_camel <- function(num) {
  english::as.english(num) %>% to_camel()
}

##' Convert a string to CamelCase
##' @param x character string
##' @return CamelCased string
to_camel <- function(x) {
  x %>%
    stringr::str_to_title() %>%
    str_replace_all("[ |-]", "")
}

report_dot_means <- function(summ, xvar, colorvar, report_name = "") {
  print(sprintf("Reporting dot means with name %s", report_name))
  colorvar <- as.character(colorvar)
  x_name <- xvar %>% case_match(
    "epsilon_str" ~ "Eps",
    "epsilon_str_latex" ~ "Eps",
    "a" ~ "A",
    .default = "ignore"
  )
  color_name <- case_match(
    colorvar,
    "mechanism_str" ~ "",
    "shrink_b_str" ~ "",
    "a_str" ~ "A",
    .default = "ignore"
  )
  assert_that(x_name != "ignore" && color_name != "ignore", msg = sprintf(
    "Ignoring report because xvar or colorvar is not recognized: xvar=%s, colorvar=%s", 
    as.character(xvar), as.character(colorvar)
  ))
  for (i in 1:nrow(summ)) {
    row <- summ[i, ]
    # strip to just numbers + decimal
    if(xvar == "epsilon_str_latex") {
      x_num <- latex_to_epsilon(row[[xvar]])
      print(row[[xvar]])
      print(x_num)
    } else {
      x_num <- as.character(row[[xvar]]) %>%
        as.numeric()
    }
    assert_that(!is.na(x_num) && is.numeric(x_num), msg = sprintf("xvar %s has NA value in row %d", xvar, i))
    if (xvar == "a") {
      x_num <- x_num * 100
    }
    name <- as.character(row[["name"]])
    prefix <- case_match(name,
      "Strict parity" ~ "epiParity",
      "Sign parity" ~ "epiSignParity",
      "FPR (sign parity)" ~ "epiSignParityFPR",
      "CI coverage" ~ "ciCoverage",
      "Sign match" ~ "signMatch",
      "Sign reversed" ~ "signFlip",
      "$\\Delta$ Strict parity" ~ "epiDisparityMarginal", # for margin it's swapped; main value is disparity not parity
      .default = "ignore"
    )
    prefix_disparity <- case_match(
      name,
      "Strict parity" ~ "epiDisparity",
      "Sign parity" ~ "epiSignDisparity",
      "Sign match" ~ "signMismatch",
      .default = "ignore"
    )
    prefix_color <- case_match(
      as.character(row[[colorvar]]),
      "gaussian" ~ "Gaussian",
      "laplace" ~ "Laplace",
      "Hudson-Berger" ~ "HB",
      "Morris-Lysy" ~ "ML",
      "0.01" ~ "AOne",
      "0.2" ~ "ATwenty",
      .default = "ignore"
    )
    if (
      (prefix == "ignore") ||
        (prefix_color == "ignore") ||
        ((xvar == "epsilon_str") && !(x_num %in% c(1000, 10, 1, 0.1, 0.01))) ||
        ((xvar == "a") && !(x_num %in% c(1, 0.1, 5)))
    ) {
      next
    }
    num_english <- x_num %>% num_to_english()
    suffix <- sprintf("%s%s%s", x_name, num_english, prefix_color)
    if ("alpha_str" %in% names(row)) {
      alpha_num <- as.character(row[["alpha_str"]]) %>%
        stringr::str_replace_all("[^0-9.]", "") %>%
        as.numeric()
      alpha_english <- to_english_camel(alpha_num * 100)
      suffix <- paste0(suffix, "Alpha", alpha_english)
    }
    make_name <- function(p) paste0(p, suffix, report_name)
    print(make_name(prefix))
    add_pct <- name != "$\\Delta$ Strict parity"
    scaling <- case_match(
      name,
      "$\\Delta$ Strict parity" ~ -100,
      .default = 100
    )
    report(
      make_name(prefix),
      sprintf("%.1f", scaling * row[["avg_y"]]),
      add_pct_sign = add_pct
    )
    report(
      make_name(paste0(prefix, "Rounded")),
      sprintf("%d", round(scaling * row[["avg_y"]])),
      add_pct_sign = add_pct
    )
    if (prefix_disparity != "ignore") {
      report(
        make_name(prefix_disparity),
        sprintf("%.1f", scaling * (1 - row[["avg_y"]])),
        add_pct_sign = add_pct
      )
      report(
        make_name(paste0(prefix_disparity, "Rounded")),
        sprintf("%d", round(scaling * (1 - row[["avg_y"]]))),
        add_pct_sign = add_pct
      )
    }
  }
}

##' Convert a number to English words
##'
##' Helper used to form readable suffixes for reporting names.
##' @param num numeric
##' @return character representation
num_to_english <- function(num) {
  num_english <- ""
  num_beforedec <- round(num)
  if (num_beforedec != 0) {
    num_english <- num_beforedec %>% to_english_camel()
  }
  num_afterdec <- num %% 1
  if (num_afterdec != 0) {
    num_english <- paste0(num_english, "Point")
    digits <- format(num_afterdec, scientific = FALSE, trim = TRUE) %>%
      stringr::str_remove("^0\\.") %>%
      strsplit("") %>%
      unlist()
    for (digit in digits) {
      num_english <- paste0(num_english, as.numeric(digit) %>% to_english_camel())
    }
  }
  num_english
}
