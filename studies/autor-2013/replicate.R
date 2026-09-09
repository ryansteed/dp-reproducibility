pacman::p_load(
  # "estimatr",
  "AER",
  "huxtable",
  "dplyr",
  "lmtest",
  "sandwich"
)

controls_4 <- c("l_sh_popedu_c", "l_sh_popfborn", "l_sh_empl_f")
controls_5 <- c("l_sh_routine33", "l_task_outsource")

replicate <- function(data, print_table = FALSE) {
  # adapted from `do/czone_analysis_ipw_final.do` using `ivreg`
  # ivregress 2sls [dep] ([endo] = [iv]) [exo] [aw=[weighting var]]
  # ivreg([dep] ~ [exo] | [endo] | [ivs], weights=)
  # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag)
  # t2 [aw=timepwt48], cluster(statefip) first
  iv_formula <- function(var_ind, vars_exo, vars_endo, vars_iv) {
    endo_str <- paste0(c(vars_exo, vars_endo), collapse = "+")
    exo_str <- paste0(c(vars_exo, vars_iv), collapse = "+")
    as.formula(paste(var_ind, "~", endo_str, "|", exo_str))
  }
  run_reg <- function(controls) {
    # mi.combine won't accept tidyr >:(
    estimatr::iv_robust(
      iv_formula("d_sh_empl_mfg", controls, c("d_tradeusch_pw"), c("d_tradeotch_pw_lag")),
      weights = timepwt48, clusters = statefip, se_type = "stata",
      data = data
    )
    # m = AER::ivreg(
    #   iv_formula("d_sh_empl_mfg", controls, c("d_tradeusch_pw"), c("d_tradeotch_pw_lag")),
    #   weights = timepwt48, data = data
    # )
  }
  controls <- c("t2")
  res_1 <- run_reg(controls)
  # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag)
  # l_shind_manuf_cbp t2 [aw=timepwt48], cluster(statefip) first
  controls <- append(controls, "l_shind_manuf_cbp")
  res_2 <- run_reg(controls)
  # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag)
  # l_shind_manuf_cbp reg* t2 [aw=timepwt48], cluster(statefip) first
  reg_star <- grep("^reg.*", names(data), value = TRUE)
  controls <- c(controls, reg_star)
  res_3 <- run_reg(controls)
  # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag)
  # l_shind_manuf_cbp reg* l_sh_popedu_c l_sh_popfborn l_sh_empl_f t2
  # [aw=timepwt48], cluster(statefip) first
  res_4 <- run_reg(c(controls, controls_4))
  # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag)
  # l_shind_manuf_cbp reg* l_sh_routine33 l_task_outsource t2
  # [aw=timepwt48], cluster(statefip) first
  res_5 <- run_reg(c(controls, controls_5))
  # eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag)
  # l_shind_manuf_cbp reg* l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33
  # l_task_outsource t2 [aw=timepwt48], cluster(statefip) first
  res_6 <- run_reg(c(controls, controls_4, controls_5))
  # esttab using ../log/tab_ipw_manuf_2.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace
  if (print_table) print(reg_table(res_1, res_2, res_3, res_4, res_5, res_6))
  res_6
}

reg_table <- function(...) {
  huxtable::huxreg(
    ...,
    coefs = c(c("d_tradeusch_pw", "l_shind_manuf_cbp"), controls_4, controls_5),
    statistics = character(0),
    stars = c(`*` = 0.1, `**` = 0.05, `***` = 0.01)
  )
}
