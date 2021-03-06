#' Density Plots
#'
#' @description
#' Generate density plots of TSSs or TSRs
#'
#' @param experiment TSRexploreR object with annotated TSSs
#' @param samples Either 'all' to plot all samples or a vector of sample names
#' @param data_type Whether to plot TSS or TSR density
#' @param consider_score Whether the score of each TSS or TSR score be considered
#'   in addition to its unique location.
#' @param upstream Bases upstream of plot center
#' @param downstream Bases downstream of plot center
#' @param threshold Raw count threshold value for TSSs
#' @param ncol Number of columns to use for plotting data when quantiles not set
#' @param use_normalized Whether to use CPM normalized or raw counts if score is considered
#' @param dominant Consider only dominant TSS or TSR
#' @param data_conditions Data conditioning filters
#' @param color Either 'default' or a valid color format to set plot color
#' @param ... Arguments passed to geom_density
#'
#' @details
#' This plotting function generates a density plot of TSS or TSR signal
#'   relative to annotated TSSs.
#' The plot is returned as a ggplot2 object.
#'
#' By default only the TSS or TSR position is considered, effectively giving every
#'   TSS or TSR a score of 1.
#' If 'consider_score' is set to TRUE, the score of each TSS or TSR will be considered when
#'   making the plot, giving more weight to stronger TSSs or TSRs.
#'
#' The region around the annotated TSS used for plotting is controlled by
#'   'upstream' and 'downstream', which should be positive integers.
#'
#' A set of functions to control data structure for plotting are included.
#' 'use_normalized' will use the CPM normalized scores, which only matters if
#'   'consider_score' is TRUE.
#' 'threshold' defines the minimum number of raw counts a TSS or TSR
#'  must have to be considered.
#' 'dominant' specifies whether only the dominant TSS or TSR is considered 
#'   from the 'mark_dominant' function.
#' For TSSs this can be either dominant TSS per TSR or gene, and for TSRs
#'   it is the dominant TSR per gene.
#' 'data_conditions' allows for the advanced filtering, ordering, and grouping
#'   of data.
#'   
#' @return ggplot2 object of density plot
#'
#' @examples
#' TSSs <- system.file("extdata", "S288C_TSSs.RDS", package="TSRexploreR")
#' TSSs <- readRDS(TSSs)
#' tsre_exp <- tsr_explorer(TSSs)
#' tsre_exp <- format_counts(tsre_exp, data_type="tss")
#' annotation <- system.file("extdata", "S288C_Annotation.gtf", package="TSRexploreR")
#' tsre_exp <- annotate_features(
#'   tsre_exp, annotation_data=annotation,
#'   data_type="tss", feature_type="transcript"
#' )
#' plot_average(tsre_exp, data_type="tss")
#'
#' @seealso
#' \code{\link{annotate_features}} to annotate the TSSs or TSRs.
#'   \code{\link{mark_dominant}} to identify dominant TSSs or TSRs.
#'
#' @rdname plot_density-function
#' @export

plot_density <- function(
  experiment,
  data_type=c("tss", "tsr"),
  samples="all",
  consider_score=FALSE,
  upstream=1000,
  downstream=1000,
  threshold=NULL,
  ncol=1,
  use_normalized=FALSE,
  dominant=FALSE,
  data_conditions=NA,
  color="default",
  ...
) {

  ## Check inputs.
  assert_that(is(experiment, "tsr_explorer"))
  data_type <- match.arg(str_to_lower(data_type), c("tss", "tsr"))
  assert_that(is.character(samples))
  assert_that(is.flag(consider_score))
  assert_that(is.count(upstream))
  assert_that(is.count(downstream))
  assert_that(is.null(threshold) || (is.numeric(threshold) && threshold >= 0))
  assert_that(is.count(ncol))
  assert_that(is.flag(use_normalized))
  assert_that(is.flag(dominant))
  if (all(!is.na(data_conditions)) && !is(data_conditions, "list")) {
    stop("data_conditions should be a list of values")
  }

  ## Assign color type.
  color_type <- case_when(
    color == "default" & data_type == "tss" ~ "#431352",
    color == "default" & data_type == "tsr" ~ "#34698c",
    TRUE ~ color
  )

  ## Pull data out of appropriate slot.
  sample_data <- experiment %>%
    extract_counts(data_type, samples, use_normalized) %>%
    preliminary_filter(dominant, threshold)

  sample_data <- map(sample_data, ~ .x[dplyr::between(distanceToTSS, -upstream, downstream)])

  ## Condition data.
  if (all(!is.na(data_conditions))) {
    sample_data <- do.call(group_data, c(list(signal_data=sample_data), data_conditions))
  }

  ## Update data if score is to be considered in addition to unique position.
  sample_data <- rbindlist(sample_data, idcol="sample")
  if (consider_score) sample_data <- sample_data[rep(seq_len(.N), score)]

  ## Set sample order if required.
  if (!all(samples == "all")) {
    sample_data[, samples := factor(samples, levels=samples)]
  }

  ## Plot densities.
  groupings <- any(names(data_conditions) %in% c("quantile_by", "grouping"))

  p <- ggplot(sample_data, aes(.data$distanceToTSS)) +
    geom_density(fill=color_type, color=color_type, ...) +
    labs(
      x="Position Relative to Annotated TSS",
      y="Density"
    ) +
    theme_bw()

  if (groupings) {
    p <- p + facet_grid(fct_rev(factor(grouping)) ~ sample)
  } else {
    p <- p + facet_wrap(~ sample, ncol=ncol)
  }
  return(p)
}
