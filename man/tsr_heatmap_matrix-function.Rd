% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/heatmaps.R
\name{tsr_heatmap_matrix}
\alias{tsr_heatmap_matrix}
\title{TSR Heatmap Count Matrix}
\usage{
tsr_heatmap_matrix(
  experiment,
  samples = "all",
  upstream = 1000,
  downstream = 1000,
  threshold = NA,
  use_normalized = FALSE,
  dominant = FALSE,
  data_conditions = list(order_by = "score")
)
}
\arguments{
\item{experiment}{TSRexploreR object with annotated TSRs}

\item{samples}{Either 'all' or a vector of names of samples to analyze}

\item{upstream}{Bases upstream to consider}

\item{downstream}{bases downstream to consider}

\item{threshold}{Raw count threshold value}

\item{use_normalized}{Whether to use CPM-normalized counts}

\item{dominant}{Whether to only consider dominant TSRs}

\item{data_conditions}{Condition the data (filter and quantile/group available)}
}
\value{
Matrix of counts for each gene/transcript and position
}
\description{
Generate count matrix to make TSR heatmap
}
