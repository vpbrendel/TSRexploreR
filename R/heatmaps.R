#' TSS Heatmap Count Matrix
#'
#' @description
#' Generate count matrix to make TSS heatmap.
#'
#' @include TSRexplore.R
#' @include annotate.R
#'
#' @param experiment TSRexploreR object with annotated TSSs
#' @param samples Either 'all' or a vector of sample names to analyze
#' @param upstream Bases upstream of plot center
#' @param downstream Bases downstream of plot center
#' @param threshold Raw count threshold value
#' @param use_normalized Whether to use CPM-normalized counts
#' @param dominant Whether to only consider dominant TSSs
#' @param data_conditions Condition the data (filter, order, and quantile/group available)
#'
#' @details
#' This function makes a count matrix for each gene or transcript with detected features
#'   relative to the annotated TSS.
#' Whether genes or transripts are used depends on the feature type chosen
#'   when annotating the TSSs with the 'annotate_features' function.
#' The count matrix is used for plotting a heatmap using the 'plot_heatmap' function.
#'
#' The region around the annotated TSS used for plotting is controlled by
#'   'upstream' and 'downstream', which should be positive integers.
#'
#' A set of arguments to control data structure for plotting are included.
#' 'use_normalized' will use the CPM normalized scores as opposed to raw read counts.
#' 'threshold' will define the minimum number of reads a TSS or TSR
#'  must have to be considered.
#' 'dominant' specifies whether only the dominant TSS or TSR is considered 
#'   from the 'mark_dominant' function.
#' For TSSs this can be either dominant per TSR or gene, and for TSRs
#'   it is just the dominant TSR per gene.
#' 'data_conditions' allows for the advanced filtering, ordering, and grouping
#'   of data.
#'
#' @return DataFrame of counts for each gene/transcript and position
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
#' hm_mat <- tss_heatmap_matrix(tsre_exp)
#'
#' @seealso
#' \code{\link{annotate_features}} to annotate the TSSs or TSRs.
#' \code{\link{plot_heatmap}} to plot the heatmap.
#' \code{\link{tsr_heatmap_matrix}} to generate the TSR matrix data for plotting.
#'
#' @rdname tss_heatmap_matrix-function
#' @export

tss_heatmap_matrix <- function(
  experiment,
  samples="all",
  upstream=1000,
  downstream=1000,
  threshold=NULL,
  use_normalized=FALSE,
  dominant=FALSE,
  data_conditions=list(order_by="score")
) {

  ## Check inputs.
  assert_that(is(experiment, "tsr_explorer"))
  assert_that(is.character(samples))
  assert_that(is.count(upstream))
  assert_that(is.count(downstream))
  assert_that(is.null(threshold) || (is.numeric(threshold) && threshold >= 0))
  assert_that(is.flag(use_normalized))
  assert_that(is.flag(dominant))
  if (all(!is.na(data_conditions)) && !is(data_conditions, "list")) {
    stop("data_conditions must be a list of values")
  }

  ## Get requested samples.
  annotated_tss <- experiment %>%
    extract_counts("tss", samples, use_normalized) %>%
    preliminary_filter(dominant, threshold)

  annotated_tss <- annotated_tss %>%
    map(function(x) {
      x <- x[distanceToTSS >= -upstream & distanceToTSS <= downstream]
      return(x)
    })

  ## Apply conditions to data.
  if (all(!is.na(data_conditions))) {
    annotated_tss <- do.call(group_data, c(list(signal_data=annotated_tss), data_conditions))
  }

  ## Rename feature column.
  annotated_tss <- rbindlist(annotated_tss, idcol="sample")
  setnames(annotated_tss,
    old=ifelse(
      experiment@settings$annotation[, feature_type] == "transcript",
      "transcriptId", "geneId"
    ),
    new="feature"
  )

  ## Format for plotting.
  groupings <- any(names(data_conditions) %in% c("quantile_by", "grouping"))

  if(any(names(annotated_tss) == "plot_order")) {
    annotated_tss[, feature := fct_reorder(factor(feature), plot_order)]
  }
  annotated_tss[, distanceToTSS := factor(distanceToTSS, levels=seq(-upstream, downstream, 1))]

  ## Order samples if required.
  if (!all(samples == "all")) {
    annotated_tss[, sample := factor(sample, levels=samples)]
  }


  ## Return a DataFrame
  tss_df <- annotated_tss[, .(sample, distanceToTSS, score, feature)]
  tss_df <- DataFrame(tss_df)
  metadata(tss_df)$threshold <- threshold
  metadata(tss_df)$groupings <- groupings
  metadata(tss_df)$use_normalized <- use_normalized
  metadata(tss_df)$dominant <- dominant
  metadata(tss_df)$promoter <- c(upstream, downstream)

  return(tss_df)
}

#' Plot Heatmap
#'
#' @description
#' Plot heatmap from count matrix generated by tss_heatmap_matrix or tsr_heatmap_matrix
#'
#' @importFrom purrr keep
#'
#' @param heatmap_matrix TSS or TSR heatmap matrix from tss_heatmap_matrix ot tsr_heatmap_matrix
#' @param max_value Max log2 (+ 1? qq) value at which to truncate heatmap color
#' @param ncol Number of columns to use when plotting multiple samples
#' @param background_color The color of the heatmap background (is this the 0 value? qq)
#' @param low_color The low value gradient color
#' @param high_color The high value gradient color
#' @param ... Arguments passed to geom_tile
#'
#' @details
#' This plotting function generates a ggplot2 heatmap of TSS or TSR signal
#'   surrounding annotated TSSs of genes or transcripts.
#' Whether genes or transcripts are used depends on the feature type chosen
#'   when annotating the TSSs with the 'annotate_features' function. 
#'
#' @return ggplot2 object of TSS or TSR heatmap
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
#' hm_mat <- tss_heatmap_matrix(tsre_exp)
#' plot_heatmap(hm_matrix)
#'
#' @seealso
#' \code{\link{annotate_features}} to annotate the TSSs or TSRs.
#' \code{\link{tss_heatmap_matrix}} to generate the TSS matrix data for plotting.
#' \code{\link{tsr_heatmap_matrix}} to generate the TSR matrix data for plotting.
#'
#' @rdname plot_heatmap-function
#' @export

plot_heatmap <- function(
  heatmap_matrix,
  max_value=5,
  ncol=1, 
  background_color="#F0F0F0",
  low_color="#56B1F7",
  high_color="#132B43",
  ...
) {

  ## Check inputs.
  assert_that(is(heatmap_matrix, "DataFrame"))
  assert_that(is.numeric(max_value) && max_value > 2)
  assert_that(is.count(ncol))
  assert_that(is.string(background_color))
  assert_that(is.string(low_color))
  assert_that(is.string(high_color))

  ## Extract some info from the heatmap matrix.
  upstream <- metadata(heatmap_matrix)$promoter[1]
  downstream <- metadata(heatmap_matrix)$promoter[2]
  groupings <- metadata(heatmap_matrix)$groupings

  ## Convert to data.table, log2 transform scores, and then truncate values above 'max_value'.
  heatmap_mat <- as.data.table(heatmap_matrix)
  heatmap_mat[, score := ifelse(log2(score) > max_value, max_value, log2(score))]

  ## Plot heatmap.
  p <- ggplot(heatmap_mat, aes(x=.data$distanceToTSS, y=.data$feature, fill=log2(.data$score))) +
    geom_raster() +
    geom_vline(xintercept=upstream, color="black", linetype="dashed", size=0.1) +
    theme_minimal() +
    scale_x_discrete(
      breaks=seq(-upstream, downstream, 1) %>% keep(~ (./100) %% 1 == 0),
      labels=seq(-upstream, downstream, 1) %>% keep(~ (./100) %% 1 == 0)
    ) +
    scale_fill_continuous(
      limits=c(0, max_value),
      breaks=seq(0, max_value, 1),
      labels=c(seq(0, max_value - 1, 1), paste0(">=", max_value)),
      name="Log2(Score)",
      low=low_color,
      high=high_color
    ) +
    theme(
      axis.text.x=element_text(angle=45, hjust=1),
      panel.spacing=unit(1.5, "lines"),
      axis.text.y=element_blank(),
      axis.ticks.y=element_blank(),
      panel.grid=element_blank(),
      panel.background=element_rect(fill=background_color, color="black")
    ) +
    labs(x="Position", y="Feature")

  if (metadata(heatmap_matrix)$groupings) {
    p <- p + facet_wrap(grouping ~ sample, scales="free")
  } else {
    p <- p + facet_wrap(. ~ sample, ncol=ncol)
  }

  return(p)
}

#' TSR Heatmap Count Matrix
#'
#' Generate count matrix to make TSR heatmap
#'
#' @include TSRexplore.R
#' @include annotate.R
#'
#' @param experiment TSRexploreR object with annotated TSRs
#' @param samples Either 'all' or a vector of names of samples to analyze
#' @param upstream Bases upstream to consider
#' @param downstream bases downstream to consider
#' @param threshold Raw count threshold value
#' @param use_normalized Whether to use CPM-normalized counts
#' @param dominant Whether to only consider dominant TSRs
#' @param data_conditions Condition the data (filter and quantile/group available)
#'
#' @return Matrix of counts for each gene/transcript and position
#'
#' @rdname tsr_heatmap_matrix-function
#'
#' @export

tsr_heatmap_matrix <- function(
  experiment,
  samples="all",
  upstream=1000,
  downstream=1000,
  threshold=NA,
  use_normalized=FALSE,
  dominant=FALSE,
  data_conditions=list(order_by="score")
) {

  ## Check inputs.
  assert_that(is(experiment, "tsr_explorer"))
  assert_that(is.character(samples))
  assert_that(is.count(upstream))
  assert_that(is.count(downstream))
  assert_that(is.null(threshold) || (is.numeric(threshold) && threshold >= 0))
  assert_that(is.flag(use_normalized))
  assert_that(is.flag(dominant))
  if (all(!is.na(data_conditions)) && !is(data_conditions, "list")) stop("data_conditions must in list form")
  
  ## Get requested samples.
  annotated_tsr <- experiment %>%
    extract_counts("tsr", samples, use_normalized) %>%
    preliminary_filter(dominant, threshold)

  walk(annotated_tsr, function(x) {
    setnames(x,
      old=ifelse(
        experiment@settings$annotation[, feature_type] == "transcript",
        "transcriptId", "geneId"
      ),
      new="feature"
    )
  })

  ## Apply conditions to data.
  if (all(!is.na(data_conditions))) {
    annotated_tsr <- do.call(group_data, c(list(signal_data=annotated_tsr), data_conditions))
  }

  ## Prepare data for plotting.
  annotated_tsr <- rbindlist(annotated_tsr, idcol="sample")
  annotated_tsr[,
    c("startDist", "endDist", "tsr_id") := list(
      ifelse(strand == "+", start - geneStart, -(end - geneEnd)),
      ifelse(strand == "+", end - geneStart, -(start - geneEnd)),
      seq_len(.N)
    )
  ]

  ## Put TSR score for entire range of TSR (put it where? qq).
  new_ranges <- annotated_tsr[,
    .(sample, seqnames, start, end, strand,
    distanceToTSS=seq(as.numeric(startDist), as.numeric(endDist), 1)),
                by=tsr_id
  ]
  new_ranges[, tsr_id := NULL]
  setkeyv(new_ranges, c("sample", "seqnames", "start", "end", "strand"))

  annotated_tsr[, distanceToTSS := NULL]
  setkeyv(annotated_tsr, c("sample", "seqnames", "start", "end", "strand"))
  annotated_tsr <- merge(new_ranges, annotated_tsr, all.x=TRUE)[
    dplyr::between(distanceToTSS, -upstream, downstream)
  ]

  ## Format for plotting.
  if(any(names(annotated_tsr) == "plot_order")) {
    annotated_tsr[, feature := fct_reorder(factor(feature), plot_order)]
  }
  annotated_tsr[, distanceToTSS := factor(distanceToTSS, levels=seq(-upstream, downstream, 1))]

  ## Order samples if required.
  if (!all(samples == "all")) {
    annotated_tsr[, sample := factor(sample, levels=samples)]
  }

  ## Return DataFrame
  tsr_df <- annotated_tsr[, .(sample, distanceToTSS, score, feature)]
  tsr_df <- DataFrame(tsr_df)
  metadata(tsr_df)$threshold <- threshold
  metadata(tsr_df)$groupings <- any(names(data_conditions) == "grouping")
  metadata(tsr_df)$use_normalized <- use_normalized
  metadata(tsr_df)$promoter <- c(upstream, downstream)

  return(tsr_df)
}
