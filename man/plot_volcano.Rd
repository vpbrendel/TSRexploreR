% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/diff_exp_plots.R
\name{plot_volcano}
\alias{plot_volcano}
\title{DE Volcano Plot}
\usage{
plot_volcano(
  experiment,
  data_type = c("tss", "tsr", "tss_features", "tsr_features"),
  de_comparisons = "all",
  log2fc_cutoff = 1,
  fdr_cutoff = 0.05,
  ncol = 1,
  ...
)
}
\arguments{
\item{experiment}{tsr explorer object}

\item{data_type}{either 'tss', 'tsr', 'tss_features', or 'tsr_features'}

\item{de_comparisons}{The DE comparisons to plot}

\item{log2fc_cutoff}{Log2FC cutoff value}

\item{fdr_cutoff}{FDR cutoff value}

\item{ncol}{Number of columns for plot}

\item{...}{Arguments passed to geom_point}
}
\description{
DE Volcano Plot
}
