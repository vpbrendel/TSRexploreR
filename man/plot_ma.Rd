% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/diff_exp_plots.R
\name{plot_ma}
\alias{plot_ma}
\title{DE MA Plot}
\usage{
plot_ma(
  experiment,
  data_type = c("tss", "tsr", "tss_features", "tsr_features"),
  de_comparisons = "all",
  ncol = 1,
  log2fc_cutoff = 1,
  fdr_cutoff = 0.05,
  ...
)
}
\arguments{
\item{experiment}{TSRexploreR object}

\item{data_type}{Either 'tss', 'tsr', 'tss_features', or 'tsr_features'}

\item{de_comparisons}{Which differential expression comparisons to plot}

\item{ncol}{Number of columns for the facets}

\item{log2fc_cutoff}{Log2FC cutoff value}

\item{fdr_cutoff}{FDR cutoff value}

\item{...}{Arguments passed to geom_point}
}
\value{
ggplot2 object of MA plot.
}
\description{
Generate a MA plot for differential TSRs or Genes (RNA-seq) - confused. I see the MA-plot code but no volcano.
}
\details{
This function generates an MA plot of the results from
  differential analysis of TSSs, TSRs, or features.
It is returned as a ggplot2 object.
}
