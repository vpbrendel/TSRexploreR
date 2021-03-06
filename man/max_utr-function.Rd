% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tss_metrics.R
\name{max_utr}
\alias{max_utr}
\title{Max UTR Length}
\usage{
max_utr(
  experiment,
  samples = "all",
  threshold = 1,
  max_upstream = 1000,
  max_downstream = 100,
  feature_type = c("geneId", "transcriptId"),
  quantiles = NA
)
}
\arguments{
\item{experiment}{TSRexploreR object with annotated TSSs}

\item{samples}{Either 'all' or names of sample to analyze}

\item{threshold}{Number of reads required for each TSS}

\item{max_upstream}{Max upstream distance of TSS to consider}

\item{max_downstream}{Max downstream distance of TSS to consider}

\item{feature_type}{Feature type used when finding distance to TSS ("geneId", "transcriptId")}

\item{quantiles}{Number of quantiles to break data into.}
}
\value{
tibble with max UTR length for features
}
\description{
Get TSS with furthest distance
}
