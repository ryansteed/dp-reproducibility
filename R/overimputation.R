pacman::p_load("assertthat", "Amelia", "parallel", "dplyr", "haven")
options("show.error.messages" = TRUE)

load <- function(path) {
  haven::read_dta(path)
}

dp_rds_path <- function(name) {
  sprintf("data/imputations/imps_dp_%s.rds", name)
}

##' Prepare a single variable for Amelia overimputation
##'
##' Compute a reasonable `error.sd` (either from provided original data or
##' using `error_prop` times the variable SD) and call `Amelia::moPrep` to
##' produce priors/overimp structures used by `mo()`.
##' @param c character variable name to prepare
##' @param data data.frame containing the variable
##' @param data_original optional original (un-noised) data.frame
##' @param error_prop numeric proportion used as fallback error.sd multiplier
##' @return moPrep object (list) containing `priors` and `overimp`
prep <- function(c, data, data_original = NULL, error_prop = 0.1) {
  if (is.null(data_original)) {
    # use sd of original data times error_prop
    assert_that(!all(is.na(data[[c]])), msg = sprintf("%s: all NAs", c))
    sd <- sd(data[[c]], na.rm = TRUE) * error_prop
  } else {
    err <- data[[c]] - data_original[[c]]
    assert_that(!all(is.na(err)), msg = sprintf("%s: err is all NAs", c))
    # get se of measurement error directly
    sd <- sd(err, na.rm = TRUE)
  }
  assert_that(
    !is.na(sd) && (sd > 0),
    msg = sprintf(
      "%s: Standard deviation (%d) must be greater than 0. Was the data really noised?",
      c, sd
    )
  )

  fm <- as.formula(paste(c, "~", c))
  mp <- Amelia::moPrep(
    as.data.frame(data), # tibble throws an error, must use data frame,
    fm,
    error.sd = sd
  )
  mp
}

# mo_from_file <- function(
#   data,
#   data_original = NULL,
#   ...
# ) {
#   print("Running overimputation")
#   data <- load(data)
#   data_original <- if (is.null(data_original)) NULL else load(data_original)
#   imps <- mo(
#     data,
#     data_original = data_original,
#     ...
#   )
#   imps
# }

##' Run Amelia overimputation wrapper
##'
##' Wrapper around `Amelia::amelia()` that prepares priors/overimp matrices via
##' repeated `prep()` calls and runs Amelia with configured defaults.
##' @param data data.frame to impute
##' @param vars_to_noise character vector of variables to impute
##' @param other_vars character vector of other model variables
##' @param idvars id variable names to pass to Amelia
##' @param data_original optional original data for error estimation
##' @param stop_after integer max EM iterations (emburn)
##' @param ncpus integer number of CPUs for parallel run
##' @param qui logical quiet mode
##' @param autopri numeric default autopri passed to Amelia
##' @return object returned by `Amelia::amelia`
mo <- function(
  data,
  vars_to_noise,
  other_vars,
  idvars = c(),
  data_original = NULL,
  # reg_only = TRUE,
  stop_after = 3000,
  ncpus = 1,
  qui = FALSE,
  autopri = 0.2,
  ...
) {
  vars_to_impute <- vars_to_noise %>% as.vector()

  # format data_reg for Amelia
  data_reg_df <- as.data.frame(data)
  # ensure rownames are 1-indexed
  rownames(data_reg_df) <- seq_len(nrow(data_reg_df))
  # print(head(rownames(data_reg_df)))

  if (!qui) {
    print("Running overimputation")
  }
  preps <- lapply(
    vars_to_impute,
    function(var) {
      prep(
        var, data_reg_df, data_original = data_original
      )
    }
  )
  overimp <- bind_rows(lapply(
    preps, function(p) p$overimp %>% as.data.frame()
  ))
  #   print(head(overimp))
  #   print(dim(overimp))
  priors <- bind_rows(lapply(
    preps, function(p) p$priors %>% as.data.frame()
  ))
  #   print(head(priors))
  #   print(dim(priors))

  # had to turn off this check; moPrep sometimes removes a few rows, can't figure out why
  # maybe overimp doesn't mark missing data?
  n_cells_na <- sum(sapply(data_reg_df, function(x) sum(is.na(x))))
  expected_rows <- nrow(data_reg_df) * length(vars_to_impute) - n_cells_na
  assert_that(
    nrow(overimp) >= expected_rows,
    msg = sprintf(
      "overimp has %d rows, but expected at least %d x %d - %d rows",
      nrow(overimp), nrow(data_reg_df), length(vars_to_impute), n_cells_na
    )
  )
  # checks from Amelia
  assert_that(all(unique(overimp[, 2]) %in% seq_len(ncol(data_reg_df))))
  assert_that(all(unique(overimp[, 1]) %in% seq_len(nrow(data_reg_df))))

  Amelia::amelia(
    data_reg_df,
    priors = as.matrix(priors),
    overimp = as.matrix(overimp),
    idvars = idvars,
    emburn = c(0, stop_after),
    autopri = autopri,
    parallel = if (ncpus > 1) c("multicore") else "no",
    ncpus = ncpus,
    p2s = if (qui) 0 else 1,
    ...
    # think this is non-logged variables, actually
    # logs=data_reg %>% select(starts_with("l_")) %>% names(),
    # can also adjust polynomials of time, lags, etc.
    # can also add bounds to prevent inf values
    # empri = 0.1 * nrow(data_reg)
  )
}
