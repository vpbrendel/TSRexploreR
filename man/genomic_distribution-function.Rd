% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/genomic_distribution.R
\name{genomic_distribution}
\alias{genomic_distribution}
\title{Genomic Distribution}
\usage{
genomic_distribution(
  experiment,
  data_type = c("tss", "tsr"),
  samples = "all",
  threshold = NULL,
  use_normalized = FALSE,
  dominant = FALSE,
  data_conditions = NA
)
}
\arguments{
\item{experiment}{TSRexploreR object with annotated TSRs}

\item{data_type}{Whether to get distribution of TSSs or TSRs}

\item{samples}{Either "all" or a vector of sample names}

\item{threshold}{Raw count threshold for a TSS or TSR to be considered}

\item{use_normalized}{Whether normalized or raw counts should be used}

\item{dominant}{Whether only the dominant TSS per gene or TSR should be considered}

\item{data_conditions}{Apply conditions to data (supports filtering and quantiles/grouping)}
}
\value{
DataFrame with TSS or TSR genomic distribution stats
}
\description{
Get genomic distribution of TSSs and TSRs
}
\details{
This function summarizes the distribution of TSSs or TSRs relative
  to annotated genomic features (exons, introns, intergenic, 
  downstream and promoter regions.)
The promoter region is user defined when annotating the TSSs or TSRs.

A set of functions to control data structure for plotting are included.
'threshold' defines the minimum number of raw counts a TSS or TSR
 must have to be considered.
'dominant' specifies whether only the dominant TSS or TSR is considered 
  (annotated by the 'mark_dominant' function).
For TSSs this can be either dominant per TSR or gene, and for TSRs
  it is just the dominant TSR per gene.
'data_conditions' allows for the advanced filtering, ordering, and grouping
  of data.
}
\examples{
TSSs <- system.file("extdata", "S288C_TSSs.RDS", package="TSRexploreR")
TSSs <- readRDS(TSSs)
tsre_exp <- tsr_explorer(TSSs)
tsre_exp <- format_counts(tsre_exp, data_type="tss")
annotation <- system.file("extdata", "S288C_Annotation.gtf", package="TSRexploreR")
tsre_exp <- annotate_features(
  tsre_exp, annotation_data=annotation,
  data_type="tss", feature_type="transcript"
)
genomic_dist <- genomic_distribution(tsre_exp, data_type="tss")

}
\seealso{
\code{\link{annotate_features}} to annotate TSSs or TSRs.
  \code{\link{plot_genomic_distribution}} to plot the genomic distribution.
}
