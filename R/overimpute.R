##' Overimputation workflow runner
##'
##' This script orchestrates the overimputation workflow: it loads data, calls
##' `prep()` and `mo()` from `R/overimputation.R`, and saves outputs. The
##' variables `noised_vars`, `other_vars` and `idvars` are defined for the
##' specific study and should be documented by callers.
source("R/overimputation.R")
pacman::p_load("optparse")

opt_parser <- OptionParser(option_list = list(
  make_option(c("-d", "--data"), type = "character", default = NULL,
              help = "Treatment to run [default %default]"),
  make_option(c("-o", "--data_original"), type = "character", default = NULL,
              help = "Treatment to run [default %default]"),
  make_option(c("-m", "--m"), type = "integer", default = 10,
              help = "Number of imputations [default %default]"),
  make_option(c("-s", "--stop_after"), type = "integer", default = 5000,
              help = "Stop after this many iterations [default %default]"),
  make_option(c("-q", "--quiet"), action = "store_true", default = FALSE,
              help = "Quiet mode [default %default]")
))
opt <- parse_args(opt_parser)
if (is.null(opt$data)) {
  print_help(opt_parser)
  stop("At least one argument must be supplied.", call. = FALSE)
}

noised_vars <- c(
  "l_popcount",
  "l_no_workers_totcbp",
  "l_shind_manuf_cbp",
  "l_sh_popedu_c",
  "l_sh_popfborn",
  "l_sh_empl_f",
  "l_sh_routine33",
  "d_tradeusch_pw",
  "d_tradeotch_pw_lag"
)
other_vars <- c(
  "d_sh_empl_mfg", "reg_midatl", "reg_encen", "reg_wncen",
  "reg_satl", "reg_escen", "reg_wscen", "reg_mount", "reg_pacif",
  "l_task_outsource", "timepwt48", "yr", "czone",
  "t2"
)
idvars <- c(
  "city", "statefip"
)

# reg vars only, for now
data_reg <- load(opt$data) %>% select(all_of(c(noised_vars, other_vars, idvars)))

imps_dp <- mo(
  data_reg,
  noised_vars,
  other_vars,
  idvars = idvars,
  m = opt$m, qui = opt$quiet,
  stop_after = opt$stop_after,
  data_original = if (is.null(opt$data_original)) NULL else load(opt$data_original),
  ts = "yr",
  cs = "czone"
)

print(imps_dp)