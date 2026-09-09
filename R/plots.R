original_color = "#7570b3"
original_shape = 19 # filled circle
different_color = "#d95f02"
different_shape = 4 # x
same_color = "#66c2a5"
same_shape = original_shape
invalid_original_color = "grey"
invalid_original_shape = 1 # empty circle
original_color_light = "#8da0cb"
different_color_light = "#fc8d62"
same_color_light = "#1b9e77"
na_color = "grey"
palette_diverging = "BrBG"
palette_sequential = "GnBu"
scale_color_sequential_dark = scale_color_manual(values=RColorBrewer::brewer.pal(9, palette_sequential)[4:9])
palette_qualitative = "Set2"
palette_qualitative_dark = "Dark2"

theme = list(
  theme_bw()
)

color_scale = list(
  guides(
    color=guide_colorbar("Rate of strict epistemic parity"),
    # color=guide_legend(title=invalid_original_label, override.aes=list(color=invalid_original_color))
  ),
  scale_color_gradient(low=different_color, high=same_color, na.value=invalid_original_color)
)
color_scale_discrete = list(
  guides(
    color=guide_legend(title="", override.aes=list(size=3))
  ),
  scale_color_manual(name="epistemic_parity_label", values=c(different_color, same_color, original_color_light, invalid_original_color))
)
shape_scale_discrete = list(
  guides(
    shape=guide_legend(title="")
  ),
  scale_shape_manual(name="epistemic_parity_label", values=c(different_shape, same_shape, original_shape, invalid_original_shape))
)
error_fill_guide = list(
  guides(
    fill=guide_legend(title="Construction", nrow=1),
    color=guide_legend(title="", nrow=2)
  ),
  theme(legend.direction = "vertical")
)
mech_fill_guide = list(
  guides(
    fill=guide_legend(title="Mechanism")
  ),
  scale_fill_manual(
    values=c(
      "Original"="#1F6B57",  # dark teal
      "gaussian"="#E66735",  # medium orange
      "laplace"="#B7C7E6"    # light blue
    ),
    labels=mechanism_expressions
  )
  # scale_fill_brewer(palette=palette_qualitative, labels=mechanism_expressions)
)

#' Plot point estimates with confidence intervals and faceting
#'
#' Create a plot of coefficient estimates across privacy treatments with
#' confidence intervals and shaded expected regions. Returns a ggplot object.
#' @param results data.frame of aggregated results (must contain est, se, expected_lb/ub)
#' @param scales character passed to facetting ('fixed' or 'free')
#' @return ggplot object
#' @export
plot_results = function(results, scales) {
  colors = c(original_color, different_color, same_color, invalid_original_color, na_color)
  names(colors) = c(original_label, different_label, same_label, invalid_original_label, NA)
  
  alpha = c(0.01, 0.05, 0.1)
  
  results_formatted = results
  results_ci = results_formatted %>% 
    crossing(alpha) %>%
    mutate(
      ymin = ci_lb(est, se, alpha),
      ymax = ci_ub(est, se, alpha),
      alpha_label = as.factor(alpha)
    )
  results_regions = results_formatted %>%
    group_by(across(all_of(pk_results))) %>%
    summarise_all(first)
  
  plt = ggplot() +
    geom_hline(yintercept=0, color="black", linetype="dotted") +
    geom_rect(data=results_regions, aes(
      ymin=ifelse(is.na(expected_lb), -Inf, expected_lb),
      ymax=ifelse(is.na(expected_ub), Inf, expected_ub),
      xmin=-Inf, xmax=Inf,
      fill=!!original_label,
    ), color=NA, alpha=0.1) +
    geom_point(data=results_formatted, aes(x=epsilon_str, y=est, color=epistemic_label)) +
    geom_errorbar(data=results_ci, aes(x=epsilon_str, y=est, ymin=ymin, ymax=ymax, color=epistemic_label, alpha=alpha_label)) +
    xlab(expression(epsilon)) +
    ylab("Coefficient") +
    scale_alpha_manual(values=c(0.5, 0.75, 1.0)) +
    scale_color_manual(values=colors) +
    scale_fill_manual(values=colors, labels="Region of parity") +
    guides(
      color=guide_legend(title="Strict Parity", title.position="top", nrow=2),
      fill=guide_legend(title="", title.position="top"),
      alpha=guide_legend(title=expression(paste("Confidence interval ", alpha)), title.position="top", nrow=2)
    ) +
    theme +
    theme(
      legend.position="top"
    ) +
    facet_wrap(vars(row_label), scales=scales, ncol=2)
  plt
}

#' Heatmap/tile visualization for result matrices
#'
#' Plot a tile/heatmap view of disparity/parity metrics across epsilon and results.
#' @param df data.frame in long-form with `epsilon_str` and `result_id` and parity metric
#' @return ggplot object
#' @export
plot_results_tile = function(df) {
  # colors = c(different_color_light, same_color_light, na_color)
  # names(colors) = c(different_label, same_label, NA)
  
  ggplot() +
    geom_tile(
      data=df %>% format_treatments() %>% filter(is_dp),
      aes(
        x=epsilon_str,
        y=result_id,
        fill=1-epistemic_match_mean
      ),
      color="black"
    ) +
    geom_text() +
    xlab(expression(epsilon)) +
    ylab("Coefficient") +
    scale_fill_gradient(low="white", high=different_color, na.value=invalid_original_color) +
    guides(
      fill=guide_legend(title="% strict disparity"),
    ) +
    theme +
    ggforce::facet_col(facets=vars(study_id_abbrv), scales="free_y", space="free")
}

#' Scatter plot of original vs replicated effect sizes
#'
#' Plots original effect sizes against mean replication effect sizes with CIs.
#' @param df data.frame results
#' @return ggplot object
#' @export
effect_scatter = function(df) {
  df %>%
    results_means() %>%
    drop_na(r_stat_original, r_stat_mean, r_stat_se, epistemic_match_mean) %>%
    ggplot(aes(
      x=r_stat_original,
      y=r_stat_mean,
      ymin=ci_lb(r_stat_mean, r_stat_se, 0.1),
      ymax=ci_ub(r_stat_mean, r_stat_se, 0.1),
      color=epistemic_match_mean
    )) +
      geom_abline(slope=1, intercept=0, linetype="dashed", alpha=0.5) +
      xlab("Original effect size") +
      ylab(paste0("Avg. replication effect size (N=", df %>% distinct(sim_id) %>% nrow(), ")")) +
      geom_pointrange(size=0.1, alpha=0.75) +
      scale_x_continuous(labels = function(x) ifelse(x == 0, "0", x)) +
      # geom_linerange() +
      color_scale +
      theme +
      theme(legend.position="top")
}

#' Scatter plot with fitted trend line
#'
#' Produce a scatter of `epistemic_match_mean` vs `xvar` with linear fit and CIs.
#' @param df data.frame
#' @param xvar character name of x variable
#' @param xlabel label for x-axis
#' @return ggplot object
#' @export
scatter_fit = function(df, xvar, xlabel) {
  # df %>%
  #   filter(epsilon_str %in% epsilon_abbrv & epsilon < 100) %>%
  #   dot_means(
  #     y = "epistemic_match",
  #     xvar = xvar,
  #     grouping = "epsilon_str",
  #     sample_sizes = FALSE,
  #     compact = TRUE,
  #     min_results = 1,
  #     report_name = NULL
  #   ) +
  #     xlab(xlabel) +
  #     ylab("Rate of epistemic parity") +
  #     ylim(0, 1) +
  #     # linear trend line
  #     geom_smooth(method="lm", color=hline_color1, fill=hline_color1, linetype="dashed")
  df %>%
    filter(epsilon_str %in% epsilon_abbrv & epsilon < 100) %>%
    results_means() %>%
    ggplot(aes(
      x=!!sym(xvar),
      y=epistemic_match_mean,
      ymin=ci_lb(epistemic_match_mean, epistemic_match_se, 0.1),
      ymax=ci_ub(epistemic_match_mean, epistemic_match_se, 0.1)
    )) +
    xlab(xlabel) +
    ylab(paste0("Rate of strict parity (N=", df %>% distinct(sim_id) %>% nrow(), ")")) +
    geom_pointrange(size=0.1, alpha=0.75) +
    # geom_linerange() +
    facet_wrap(vars(epsilon_str_eq), labeller=label_parsed, ncol=2) +
    geom_smooth(
      method="lm",
      # formula = y ~ splines::bs(x, 2),
      aes(color="Linear fit (90% CI)"),
      fill=hline_color1, linetype="dashed", size=0.75
    ) +
    scale_colour_manual(name="legend", values=c(hline_color1)) +
    guides(
      color = guide_legend(title="", title.position="top")
    ) +
    theme +
    theme(legend.position="top")
}

#' Line/dot plotting helper for summarized means
#'
#' Build a ggplot of summarized (mean) points with error bars.
#' @param summ summarized data.frame with `avg_y` and `se_y`
#' @param xvar column name used for x-axis
#' @param colorvar optional aesthetic grouping variable
#' @param colorlabels optional labels for color legend
#' @param dropna whether to drop NA values
#' @param bar whether to plot as bar chart instead of points
#' @param hline optional horizontal line to add
#' @param vline optional vertical line to add
#' @param hlines optional additional horizontal lines to add
#' @return ggplot object
#' @export
ggplot_dot_means = function(
    summ, xvar,
    colorvar=NULL, colorlabels=NULL,
    dropna=TRUE,
    bar=F,
    hline=NULL,
    vline=NULL,
    hlines=NULL
) {
  summ = summ %>%
    drop_na(avg_y)
  plt = ggplot(data=summ, aes(
    x=!!sym(xvar), y=avg_y, color=!!colorvar, shape=!!colorvar, group=!!colorvar,
    ymin=ci_lb(avg_y, se_y, 0.1), ymax=ci_ub(avg_y, se_y, 0.1)
  ))
  if (!is.null(vline)) {
    plt = plt +
      geom_rect(
        ymin=-Inf, ymax=Inf,
        xmin=-Inf,
        xmax=vline[1],
        fill="grey",
        color=NA, alpha=0.01
      ) +
      geom_rect(
        ymin=-Inf, ymax=Inf,
        xmin=vline[2],
        xmax=Inf,
        fill="grey",
        color=NA, alpha=0.01
      ) +
      geom_vline(xintercept=vline[1], color="black", alpha=0.1) +
      geom_vline(xintercept=vline[2], color="black", alpha=0.1)
  }
  if (!is.null(hline)) {
    plt = plt +
      geom_hline(yintercept=hline, linetype="dotted")
  }
  if (!is.null(hlines)) {
    plt = plt + hlines
  }
  if (!is.null(colorvar)) {
    plt = plt +
      geom_line(alpha=0.75)
  }
  plt = plt +
    geom_errorbar(width=if (is.factor(summ[[xvar]])) 0.2 else 0.02) +
    geom_point(size=1) +
    # scale_color_sequential_dark +
    theme +
    theme(legend.position="top")
  if (is.null(colorlabels)) {
    plt = plt + scale_color_brewer(name=colorvar, palette=palette_qualitative_dark)
  }
  else {
    print(names(colorlabels))
    plt = plt +
      scale_color_brewer(name=colorvar, palette=palette_qualitative_dark, labels=colorlabels) +
      scale_shape(labels=colorlabels)
  }
  plt
}

summ_means = function(df, y) {
  df %>%
    summarise(
      avg_y = mean(!!sym(y), na.rm=T),
      sum_y = sum(!!sym(y), na.rm=T),
      sd_y = sd(!!sym(y), na.rm=T),
      n = sum(!is.na(!!sym(y))),
      se_y = sd_y / sqrt(n),
      n_results = n_distinct(across(all_of(pk_results))),
      .groups="drop"
    )
}

dot_means = function(
    df, y, xvar, grouping, scales = "fixed", colorvar=NULL,
    sample_sizes=T, compact=F, ncol=NULL, min_results=1, bar=F, freq_order=T,
    report_name=NULL, include_na=F, facet_label_width=NULL,
    ...
  ) {
  if (!is.null(colorvar)) {
    colorvar = sym(colorvar)
  }
  summ = df %>%
    group_by(!!sym(xvar), !!sym(grouping), !!colorvar) %>%
    summ_means(y)
  print(summ %>% arrange(!!sym(xvar), avg_y))
  if (!is.null(report_name)) {
    report_dot_means(summ, xvar, colorvar, report_name=report_name)
  }
  summ_n = df %>%
    # get n for each point in each group
    # group_by(!!sym(grouping), !!sym(xvar), !!sym(colorvar)) %>%
    # mutate(
    #   n = n()
    # ) %>%
    # ungroup() %>%
    # get distinct studies, results
    group_by(!!sym(grouping)) %>%
    summarise(
      n_studies = n_distinct(study_id),
      n_results = if("result_id" %in% names(df)) n_distinct(study_id, result_id) else NA,
      n_variables = if("variable_id" %in% names(df)) n_distinct(study_id, result_id, variable_id) else NA,
      n_trials = n_distinct(sim_id),
      .groups="drop"
    )
  group_label = paste0(
    if(is.logical(summ_n[[grouping]])) paste0(grouping, '=') else '',
    summ_n[[grouping]]
  )
  print(names(summ_n))
  sample_label = paste0(
    "(",
    '<i>N</i><sub>s</sub>=', summ_n$n_studies,
    if("result_id" %in% names(df)) paste0(', <i>N</i><sub>r</sub>=', summ_n$n_results) else '',
    if("variable_id" %in% names(df)) paste0(', <i>N</i><sub>v</sub>=', summ_n$n_variables) else '',
    # paste0('$, N_t$=', summ_n$n),
    ")"
  )
  if (!is.null(facet_label_width)) {
    group_label = str_wrap(group_label, width=facet_label_width)
  }
  if (grouping != "name") {
    group_label = htmltools::htmlEscape(group_label)
  }
  group_label = str_replace_all(group_label, "\\n", "<br>")
  label_lookup = group_label
  if(sample_sizes) {
    label_lookup = paste0(group_label, if (compact) " " else "<br>", sample_label)
  }
  names(label_lookup) = summ_n[[grouping]]
  label_fxn = function(groups) {
    label_lookup[unlist(groups)]
  }
  summ = summ %>%
    mutate(
      labels = ifelse(
        is.na(!!sym(grouping)), "NA",
        label_fxn(as.character(!!sym(grouping)))
      )
    ) %>%
    filter(
      n_results > min_results
    )
  if (!include_na) {
    summ = summ %>% filter(labels != "NA")
  }
  if (freq_order) {
    summ = summ %>% mutate(
      labels = fct_reorder(labels, -n_results)
    )
  } else {
    summ = summ %>% mutate(
      labels = labels %>% fct_reorder(as.numeric(!!sym(grouping)))
    )
  }
  plt = summ %>%
    ggplot_dot_means(xvar, colorvar=colorvar, bar=bar, ...)
  
  if (grepl("tex", xvar)) {
    plt = plt + scale_x_discrete(labels=function(x) TeX(x))
  }
  else if (xvar == "epsilon") {
    plt = plt + 
      scale_x_log10()
  }
  if (!bar) {
    latex_labels = any(grepl("\\\\Delta", levels(summ$labels)))
    labeller = as_labeller(function(labels) TeX(labels), default=label_parsed)
    plt = plt +
      facet_wrap(vars(labels), ncol=ncol, labeller=if (latex_labels) labeller else label_value, scales=scales, axes="all_x") +
      theme(strip.text.x=if (latex_labels) element_text() else ggtext::element_markdown(lineheight=0.9))
  } else {
    plt = summ %>%
      drop_na(avg_y) %>%
      ggplot(aes(x=labels, y=avg_y, fill=!!sym(xvar), ymin=ci_lb(avg_y, se_y, 0.1), ymax=ci_ub(avg_y, se_y, 0.1))) +
      coord_flip() +
      geom_col(color="black", position=position_dodge(width = 0.9)) +
      geom_errorbar(width=0.2, position=position_dodge(width = 0.9)) +
      theme +
      theme(axis.text.y=ggtext::element_markdown()) +
      scale_fill_brewer(palette=palette_qualitative)
  }
  plt
}

dot_means_grid = function(df, y, xvar, gridx, gridy, colorvar=NULL, colorlabels=NULL, scales="fixed", report_name=NULL, ...) {
  if (!is.null(colorvar)) {
    colorvar = sym(colorvar)
  }
  summ = df %>%
    group_by(!!sym(xvar), !!sym(gridx), !!sym(gridy), !!colorvar) %>%
    summ_means(y) %>%
    mutate(
      label_x = as.character(!!sym(gridx)),
      label_y = as.character(!!sym(gridy))
    )
  if (!is.null(report_name)) {
    report_dot_means(summ, xvar, colorvar, report_name=report_name)
  }
  plt = summ %>% ggplot_dot_means(xvar, colorvar=colorvar, colorlabels=colorlabels, ...) +
    facet_grid(label_y ~label_x, labeller=labeller(label_x=as_labeller(function(labels) TeX(labels), default=label_parsed)), scales="fixed") +
    scale_y_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1)) +
    theme(strip.text=element_text())
  if (grepl("tex", xvar)) {
    plt = plt + scale_x_discrete(labels=function(x) TeX(x))
  }
  plt
}

violin_dots = function(results, yvar, xvar, groupvar=NULL, dots=TRUE, disparities_only=TRUE) {
  dodge_width = 0
  colorvar = sym("epistemic_parity_label")
  if (!is.null(groupvar)) {
    groupvar = sym(groupvar)
    dodge_width = 0.9
  }
  plot = results %>%
    ggplot(aes(x=!!sym(xvar), y=!!sym(yvar), fill=!!groupvar)) +
    geom_violin(draw_quantiles=c(0.25, 0.5, 0.75, 1.0), alpha = 0.35)
    # geom_boxplot(width=0.1)
  if (dots) {
    d = results
    if (disparities_only) {
      d = d %>% filter(!epistemic_match)
    }
    plot = plot + geom_point(
      data=d,
      aes(color=epistemic_parity_label, shape=epistemic_parity_label, group=!!groupvar),
      position = position_jitterdodge(jitter.width=0.4, dodge.width=dodge_width), size=0.5, alpha=0.5
    )
    # geom_dotplot(binaxis="y", stackdir="center", dotsize=0.5)
  }
  plot +
    color_scale_discrete +
    shape_scale_discrete +
    theme +
    theme(
      legend.position="top"
    )
}

epsilon_violin = function(results, y, grouping) {
  results %>%
    ggplot(aes(x=epsilon_str, y=!!sym(y))) +
    geom_violin(draw_quantiles=c(0.25, 0.5, 0.75, 1.0)) +
    geom_point(position = position_jitter(0.1)) +
    facet_wrap(vars(!!sym(grouping))) +
    theme
}

plot_sankey = function(df) {
  df %>% 
    ggsankey::make_long(names(.)) %>%
    mutate(
      node = fct_relevel(node, effect_sizes_ordered)
    ) %>%
    ggplot(aes(
      x=x,
      next_x=next_x,
      node=node,
      next_node=next_node,
      fill=node
    )) +
    geom_alluvial(flow.alpha=0.6, node.color="gray30") +
    # theme_alluvial(base_size = 10) +
    theme_minimal() +
    scale_fill_brewer(palette=palette_diverging, direction=-1) +
    # scale_fill_viridis_d(drop = FALSE, name="Average effect size", breaks=effect_sizes_ordered) +
    xlab(expression(epsilon))
}

save = function(v, h=5, w=8) {
  to_save = c(
    "data_domain",
    "data_type_abbrv",
    "dv_rq_importance_abbrv",
    "query_type_simple",
    "reg_role",
    "jel",
    "geographic_index_abbrv",
    "time_index_abbrv",
    "stata_cmd_abbrv",
    "epistemic_claim",
    "journal_abbrv"
  )
  if (v %in% to_save) {
    ggsave(sprintf("plots/x-%s.pdf", v), dpi=300, height=h, width=w)
    ggsave(sprintf("plots/x-%s.png", v), dpi=300, height=h, width=w)
  }
}
